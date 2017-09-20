/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_10_xpre]
					@VirtualMultiplier		VARCHAR(MAX),
					@SportType				SMALLINT		= 0
AS
/*
	Created:	20160406@Billy
	Task:		Multiple update Virtual Multiplier for multiple customers
	DB:			DBCUST/CustDB
	Original:  
  
	Revisions: 
		- 20170328@Elodie: Expand the range of VR setting [RedmineID:#73808]
		- 20170915@Winnie: Update logic to VR auto-adjustment job Phase 2 RedmineID:#82312
	Param's Explanation:  
		- @VirtualMultiplier = '<ROOT>
									<Rate CustIds="1,2,3,4,5,6" VirtualMultiplier="0.7" />	
									<Rate CustIds="11,22,33,44,55,66" VirtualMultiplier="1.5" />
								</ROOT>'
		- @SportType = 0 : All
					 = 1 : Soccer
					 = 2 : Other Sports
*/
BEGIN
    SET NOCOUNT ON



	CREATE TABLE	#tblVirtualRate (
						CustID				INT
							CONSTRAINT PK_tblVirtualRate PRIMARY KEY CLUSTERED
					,	VirtualMultiplier	TINYINT
					,	isFinished			BIT
							CONSTRAINT DF_tblVirtualRate_isFinished DEFAULT 0
					)

	CREATE TABLE #Temp (custid INT,sporttype INT,bettype INT,isLive BIT,virtualRate SMALLMONEY,
						CONSTRAINT PK_Temp PRIMARY KEY CLUSTERED( custid, sporttype, bettype, isLive))

	DECLARE	@processingCustID	TABLE (
									CustID				INT
								)

	DECLARE	@DocHandler		INT
		,	@seqNo			TINYINT
		,	@profileID		INT
	
	-- BEGIN - Read XML			
	EXECUTE	sp_xml_preparedocument
				@DocHandler				OUTPUT
			,	@virtualmultiplier
	
	INSERT INTO #tblVirtualRate 
		(	CustID, VirtualMultiplier)
	SELECT	CAST(ss.val AS INT)
		,	CASE WHEN CAST(Data.VirtualMultiplier * 100 AS INT) > 200 THEN (CAST(Data.VirtualMultiplier * 100 AS INT)-200)/5+200 ELSE CAST(Data.VirtualMultiplier * 100 AS INT) END
	FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
	WITH (
		CustIds				NVARCHAR(MAX)
	,	VirtualMultiplier	SMALLMONEY	
	) AS Data
	CROSS APPLY	dbo.strSplit(Data.CustIds, ',') AS ss
		
	IF (@SportType=1)	
	BEGIN
			INSERT INTO #Temp(CustID,sporttype,bettype,isLive,virtualRate)			
			SELECT	CAST(ss.val AS INT),aa.sporttype,aa.bettype,aa.isLive
			, Data.VirtualMultiplier
			FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
			WITH (
				CustIds				NVARCHAR(MAX)
			,	VirtualMultiplier	SMALLMONEY	
			) AS Data
			CROSS APPLY	dbo.strSplit(Data.CustIds, ',') AS ss		
			CROSS APPLY (SELECT sporttype,bettype,islive FROM [ProfileVirtualSetting] WITH(NOLOCK) WHERE sporttype=1) aa
	END
	ELSE IF (@SportType=2)			
	BEGIN
			INSERT INTO #Temp(CustID,sporttype,bettype,isLive,virtualRate)			
			SELECT	CAST(ss.val AS INT),aa.sporttype,aa.bettype,aa.isLive
			, Data.VirtualMultiplier
			FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
			WITH (
				CustIds				NVARCHAR(MAX)
			,	VirtualMultiplier	SMALLMONEY	
			) AS Data
			CROSS APPLY	dbo.strSplit(Data.CustIds, ',') AS ss		
			CROSS APPLY (SELECT sporttype,bettype,islive FROM [ProfileVirtualSetting] WITH(NOLOCK) WHERE sporttype<>1) aa
	END 
	
	EXECUTE	sp_xml_removedocument
				@DocHandler
	-- END - Read XML
	
	IF	dbo.f_CheckRepTable('CustVirtualSetting') <> 1 --OR NOT EXISTS (SELECT 1 FROM #tblVirtualrate)
		RETURN

	SELECT	TOP 1
			@seqNo = pvs.seqNo
		,	@profileId = 1 + (pvs.profileID - 1) % 64
	FROM	dbo.ProfileVirtualSetting AS pvs WITH (NOLOCK)
	ORDER BY pvs.profileID DESC

	WHILE 0 = 0
	BEGIN
			UPDATE TOP(500) #tblVirtualRate
			SET	isFinished = 1
			OUTPUT	Deleted.CustID
			INTO	@processingCustID (CustID)
			WHERE	isFinished = 0

		IF	@@ROWCOUNT = 0
			BREAK
		
		IF(@SportType=0)
		BEGIN
			
			-- Update filled bitmapVirtual
			UPDATE	cvs
			SET	cvs.bitmapVirtual = CONVERT(BINARY(64), REPLICATE(CAST(CAST(tvr.VirtualMultiplier AS BINARY(1)) AS VARCHAR), 64))
			FROM		dbo.CustVirtualSetting AS cvs WITH (ROWLOCK, UPDLOCK)
			INNER JOIN	@processingCustID AS pci
					ON	pci.CustID = cvs.custid
			INNER JOIN	#tblVirtualRate AS tvr
					ON	tvr.CustID = pci.CustID
			WHERE	cvs.seqNo < @seqNo

			-- Update the last bitmapVirtual
			UPDATE	cvs
			SET	cvs.bitmapVirtual = CONVERT(BINARY(64),	REPLICATE(CAST(CAST(tvr.VirtualMultiplier AS BINARY(1)) AS VARCHAR), @profileID) + REPLICATE(CAST(CAST(0 AS BINARY(1)) AS VARCHAR), 64 - @profileID))
			FROM		dbo.CustVirtualSetting AS cvs WITH (ROWLOCK, UPDLOCK)
			INNER JOIN	@processingCustID AS pci
					ON	pci.CustID = cvs.custid
			INNER JOIN	#tblVirtualRate AS tvr
					ON	tvr.CustID = pci.CustID
			WHERE	cvs.seqNo = @seqNo
		END
		ELSE IF(@SportType=1)
		BEGIN
			
			UPDATE cvs
				SET		bitmapVirtual = (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_multiple(bitmapVirtual, CONVERT(VARCHAR(MAX), virtualXML)))
				FROM		CustVirtualSetting AS cvs WITH(UPDLOCK, ROWLOCK)
				CROSS APPLY (
					SELECT (
						SELECT	(
									SELECT	ipvs.profileID			AS '@p',
											tmp.virtualRate			AS '@v'
									FROM		#Temp				AS tmp
									INNER JOIN	ProfileVirtualSetting	AS ipvs WITH(NOLOCK)
											ON	tmp.sporttype	= ipvs.sporttype
											AND tmp.bettype		= ipvs.bettype
											AND tmp.isLive		= ipvs.islive
									WHERE	ipvs.seqNo = cvs.seqNo
										AND tmp.custid = cvs.custid
									FOR XML PATH ('r'), 
									TYPE
								)
						FOR XML PATH ('root'), 
						TYPE
					) AS virtualXML
				) p
				WHERE cvs.custid IN (SELECT custid FROM #tblVirtualRate)			
		END
		ELSE
		BEGIN
			
			UPDATE cvs
				SET		bitmapVirtual = (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_multiple(bitmapVirtual, CONVERT(VARCHAR(MAX), virtualXML)))
				FROM		CustVirtualSetting AS cvs WITH(UPDLOCK, ROWLOCK)
				CROSS APPLY (
					SELECT (
						SELECT	(
									SELECT	ipvs.profileID			AS '@p',
											tmp.virtualRate			AS '@v'
									FROM		#Temp				AS tmp
									INNER JOIN	ProfileVirtualSetting	AS ipvs WITH(NOLOCK)
											ON	tmp.sporttype	= ipvs.sporttype
											AND tmp.bettype		= ipvs.bettype
											AND tmp.isLive		= ipvs.islive
									WHERE	ipvs.seqNo = cvs.seqNo
										AND tmp.custid = cvs.custid
									FOR XML PATH ('r'), 
									TYPE
								)
						FOR XML PATH ('root'), 
						TYPE
					) AS virtualXML
				) p
				WHERE cvs.custid IN (SELECT custid FROM #tblVirtualRate)			
		END
	END	
END


GO