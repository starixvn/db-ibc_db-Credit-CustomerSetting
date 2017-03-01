SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

ALTER PROCEDURE	dbo.Acc_CustSetting_10
					@VirtualMultiplier		VARCHAR(MAX)
AS
/*
	Created:	20160406@Billy
	Task:		Multiple update Virtual Multiplier for multiple customers
	DB:			DBCUST/CustDB
	Original:  
  
	Revisions: 
	Param's Explanation:  
		- @VirtualMultiplier = '<ROOT>
									<Rate CustIDs="1,2,3,4,5,6" VirtualMultiplier="0.7" />	
									<Rate CustIDs="11,22,33,44,55,66" VirtualMultiplier="1.5" />
								</ROOT>'
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
		,	CAST(Data.VirtualMultiplier * 100 AS INT)
	FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
	WITH (
		CustIds				NVARCHAR(MAX)
	,	VirtualMultiplier	SMALLMONEY	
	) AS Data
	CROSS APPLY	dbo.strSplit(Data.CustIds, ',') AS ss

	EXECUTE	sp_xml_removedocument
				@DocHandler
	-- END - Read XML

	IF	dbo.f_CheckRepTable('CustVirtualSetting') <> 1 OR NOT EXISTS (SELECT 1 FROM #tblVirtualrate)
		RETURN

	SELECT	TOP 1
			@seqNo = pvs.seqNo
		,	@profileId = 1 + (pvs.profileID - 1) % 64
	FROM	dbo.ProfileVirtualSetting AS pvs WITH (NOLOCK)
	ORDER BY pvs.profileID DESC

	WHILE 0 = 0
	BEGIN
		DELETE FROM @processingCustID

	    UPDATE TOP(500) #tblVirtualRate
		SET	isFinished = 1
		OUTPUT	Deleted.CustID
		INTO	@processingCustID (CustID)
		WHERE	isFinished = 0

		IF	@@ROWCOUNT = 0
			BREAK

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
END