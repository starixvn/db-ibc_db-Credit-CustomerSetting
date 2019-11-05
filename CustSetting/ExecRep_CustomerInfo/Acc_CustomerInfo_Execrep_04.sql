/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_04] @custid						INT				
				,	@roleid						TINYINT			
				,	@action						VARCHAR(30)		= ''
				,	@custlist					VARCHAR(MAX) 	= ''
				,	@EnableVirtualrate			BIT				= 0
				,	@virtualmultiplier			VARCHAR(MAX)	= ''
				,	@EnableVirtualMultiplier	VARCHAR(MAX)	= ''
				,	@lockedVRmembers			VARCHAR(MAX)	= ''
				,	@Suspended					BIT				= 0
				,	@Closed						BIT				= 0
				,	@disabledCS					BIT				= 0				
				,	@DisableVS					BIT				= 0
				,	@EnableVS					BIT				= 0
				,	@DisableNumberGame			BIT				= 0
				,	@DisableGoldDeluxe			BIT				= 0
				--20180109@Johnson: new direction for status [redmine:#87328]
				,	@UpdateAllMasters 			BIT 			= 0
				,	@UpdateAllAgents  			BIT 			= 0
				,	@UpdateAllMembers 			BIT 			= 0
							
				,	@DisableAllMasters 			BIT 			= NULL
				,	@DisableAllAgents  			BIT 			= NULL
				,	@DisableAllMembers 			BIT 			= NULL
				
				,	@DisableSuperLive			BIT				= 0
				,	@DisableColossusBet			BIT				= 0				
				,	@AutoSuspendSoccer			BIT				= 0
				,	@AutoSuspendOtherSports		BIT				= 0
				,	@rowcount					INT				= 0		OUTPUT
				,	@SystemID TINYINT=1
AS 
/*
	Created:	Jamie
	Date:		20141125
	Task:		Update customer/custinfo settings
	DB:			DBCUST/CustDB
	Original:	Acc_ExecRep_Cust_04

	Revisions:
		- 20141230@Johnson:	separate virtual rate by sporttype and bettype
		- 20150424@Johnson:	add Gold Deluxe
		- 20150603@Daniel:	Improve medthod check table existing in subscribers	
		- 20150707@Elodie:	Add SuperLive
		- 20150825@Helen:	Colossus Bet - [Redmine: #41264]
		- 20151029@Billy:	Change to new VirtualRate structure [Redmine: #46541]
		- 20160422@Billy:	Exclude Auto Adjusted VR Members when update VR - [Redmine: #56525]
		- 20160613@Elodie: Update enable virtualrate for mutiple members
		- 20160907@Winnie:	Reset the virtual rate of bettrade accounts - [Redmine: #63519]
		- 20170228@Winnie:	Reset the virtual rate of cashout accounts - [Redmine: #72171]
		- 20170228@Winnie:	Reset the virtual rate of cashout accounts - [Redmine: #72171]
		- 20170504@Winnie:	Color for closed Accounts  - [Redmine:#74494]
		- 20170921@Johnson: Fix the unsynchronized setting for GoldDeluxe, only update enable status for sync downline [Redmine: #72973]	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
		--20180109@Johnson: new direction for status [redmine:#87328]
		- 20180808@Johnson: Enhance VirtualRate setting [Redmine:#99839]
		- 20180823@Paul: Enhance VirtualRate setting [Redmine:#99839]
		- 20190417@Paul: Enhance VirtualRate setting [Redmine:#110345]
		- 20190424@Johnson: add suspendinfo [redmine: #105587]
		- 20190701@Dominic: Update VR setting of an account for Esport  [Redmind: #114830]
		- 20190906@Winnie: Colossus Bet - Miss enable product [Redmind: #119642]
		- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	Param's Explanation:
		@Action: 
			+ 'VirtualMultiplier': Virtual Rate [@virtualmultiplier]
			+ 'Suspended': Suspended/Reject		[@Suspended]
			+ 'Closed': Closed					[@Closed]
			+ 'disabledCS': RNG Casino Status	[@disabledCS]
			+ 'DisableLiveCasino': Live Casino status [@DisableLiveCasino]
			+ 'DisableVS': Disable Virtual Sport [@DisableVS]
			+ 'EnableVS': Enable Virtual Sport [@EnableVS]
			+ 'DisableNumberGame': Number game status [@DisableNumberGame]
		
			+ 'AutoSuspend': Auto suspend all: Soccer and Other Sports [@AutoSuspendSoccer, @AutoSuspendOtherSports]
			+ 'AutoSuspendSoccer': Auto suspend for Soccer[@AutoSuspendSoccer]
			+ 'AutoSuspendOther': Auto suspend for Other Sports [@AutoSuspendOtherSports]
			+ 'UpdKeno-Hide' : Hide Keno gaming
			+ 'GoldDeluxe': Gold Deluxe status
			+ 'SuperLive': Super Live status
			+ 'EnableVirtualMultiplier': Enable Virtual Rate [@EnableVirtualMultiplier]
			+ 'EsportVRUpd': Update VR setting of an account for Esport  [@virtualmultiplier] - Redmine: #114830
   
*/
SET NOCOUNT ON; 

IF	@action = 'EsportVRUpd'
BEGIN
	CREATE TABLE #New_VRCustSetting (LevelID INT, ValueIDLive TINYINT, ValueIDNonLive TINYINT)
	DECLARE @DocHandlerEsport INT	

	IF @VirtualMultiplier <> ''
	BEGIN				
		EXEC sp_xml_preparedocument @DocHandlerEsport OUTPUT, @virtualmultiplier

		INSERT INTO #New_VRCustSetting(LevelID, ValueIDLive, ValueIDNonLive)
		SELECT Data.LevelID,
			Data.ValueIDLive,
			Data.ValueIDNonLive
		FROM OPENXML (@DocHandlerEsport, '/Root/Row',1) 
		WITH (
			LevelID	INT,
			ValueIDLive TINYINT,
			ValueIDNonLive TINYINT	
		) AS Data

		EXEC sp_xml_removedocument @DocHandlerEsport
	END

	IF(dbo.f_CheckRepTable('VRCustSetting') = 1)
	BEGIN
		UPDATE main
		SET main.ValueIDLIVE = vr.ValueIDLive
			, main.ValueIDNonLIVE = vr.ValueIDNonLIVE
		FROM VRCustSetting main
			INNER JOIN #New_VRCustSetting vr ON main.CustID = @custid AND vr.LevelID = main.LevelID

		DELETE VRCustSetting
		WHERE custid = @custid
			AND LevelID NOT IN (SELECT LevelID FROM #New_VRCustSetting)

		INSERT INTO [dbo].[VRCustSetting]
           ([CustID]
           ,[LevelID]
           ,[ValueIDLIVE]
           ,[ValueIDNonLIVE])
		SELECT @custid [CustID]
           ,[LevelID]
           ,[ValueIDLIVE]
           ,[ValueIDNonLIVE]
		FROM #New_VRCustSetting
		WHERE [LevelID] NOT IN (SELECT LevelID FROM [VRCustSetting] WHERE CustID=@custid)
	END
END
ELSE IF	@action = 'VirtualMultiplier'
BEGIN
	DECLARE	@tblVirtualrate		TABLE (
									SportType			INT
								,	BetType				INT
								,	IsLive				BIT
								,	VirtualMultiplier	SMALLMONEY	
								);
								
	DECLARE	@DocHandler				INT
		,	@EnableVirtualrateOld	BIT;

	DECLARE	@virtualXML			TABLE (
									seqNo				TINYINT PRIMARY KEY
								,	Pos			VARBINARY(64)
								,	Val			VARBINARY(64)
								);

	DECLARE	@lockedMembers		TABLE (
									custID				INT
								);
	CREATE TABLE #tblCustVR (custID INT)
	CREATE TABLE #tmpCustBatchVR (CustID INT PRIMARY KEY)	
	DECLARE @batchUpdate INT = 5000,
			@maxcustid INT					
	
	IF	@virtualmultiplier <> ''
	BEGIN			
		-- For read xml					
		EXECUTE sp_xml_preparedocument @DocHandler OUTPUT, @virtualmultiplier;

		INSERT INTO	@tblVirtualrate (
						SportType
					,	BetType
					,	IsLive
					,	VirtualMultiplier
				)
		SELECT	Data.SportType
			,	Data.BetType
			,	Data.IsLive
			,	Data.VirtualMultiplier
		FROM OPENXML (@DocHandler, '/ROOT/Rate',1) 
		WITH (	SportType			SMALLINT
			,	BetType				SMALLINT
			,	IsLive				BIT
			,	VirtualMultiplier	SMALLMONEY	
		) AS Data;

		EXECUTE sp_xml_removedocument @DocHandler;
		-- end read xml
	END;	
	
	SELECT	@EnableVirtualrateOld = virtualmultiplier
	FROM	CustInfo WITH (NOLOCK)
	WHERE	custid = @custid;
	
	DECLARE @BetTradeAccount TABLE (CustID INT)
	
	IF( dbo.f_CheckRepTable('Customer') = 1 AND dbo.f_CheckRepTable('BetTradeCust') = 1)
	BEGIN
	IF (@EnableVirtualrate=1 AND @EnableVirtualrateOld <> @EnableVirtualrate 
	AND EXISTS(SELECT TOP 1 1 FROM Customer c WITH(NOLOCK) WHERE custid = @custid AND site IN ('TLC', 'asiabet88')))
	
	BEGIN
		IF @roleid = 4 
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.srecommend = @custid 
		END
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.mrecommend = @custid 
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.recommend = @custid 
		END
	END
	END
	
	IF( dbo.f_CheckRepTable('Customer') = 1 AND dbo.f_CheckRepTable('TradeCust') = 1 AND @EnableVirtualrate=1 AND @EnableVirtualrateOld <> @EnableVirtualrate )
	BEGIN	
		IF @roleid = 4 
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.srecommend = @custid 
		END
		ELSE IF @roleid = 3
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.mrecommend = @custid 
		END
		ELSE IF @roleid = 2
		BEGIN
			INSERT INTO @BetTradeAccount (CustID)
			SELECT c.Custid  
			FROM Customer c WITH(NOLOCK)
				INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
			WHERE c.recommend = @custid 		
		END
	END
	
	IF	(@EnableVirtualrateOld <> @EnableVirtualrate AND dbo.f_CheckRepTable('custinfo') = 1)
	BEGIN
		SET @batchUpdate = 5000--for update custinfo
		IF	@roleid = 4
		BEGIN			
			DELETE #tblCustVR
			
			INSERT INTO #tblCustVR(custID)
			SELECT custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.srecommend = @custid
			AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)
					
			SELECT @maxcustid = MAX(custID)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
					
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate
				FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
				WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
			END	
			
			--update newly customer if any
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE	ci.srecommend = @custid
			AND ci.custid > @maxcustid
			AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)	
		END;
		ELSE IF	@roleid = 3
		BEGIN			
			DELETE #tblCustVR
			
			INSERT INTO #tblCustVR(custID)
			SELECT custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.mrecommend = @custid
			AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)
					
			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
					
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate
				FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
				WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
			END	
			
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE	ci.mrecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)
		END;
		ELSE IF	@roleid = 2
		BEGIN			
			DELETE #tblCustVR
			
			INSERT INTO #tblCustVR(custID)
			SELECT custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.recommend = @custid
			AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)
					
			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
					
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate
				FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
				WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
			END
			
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE	ci.recommend = @custid
				AND custid > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	@BetTradeAccount AS lm
						WHERE	lm.custID = ci.custid
					)		
		END;
		ELSE IF	@roleid = 1
		BEGIN			
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE	ci.custid = @custid								
		END;
	END;
	
	IF	(@EnableVirtualrate = 1 AND dbo.f_CheckRepTable('CustVirtualSetting') = 1 AND (SELECT TOP 1 1 FROM @tblVirtualrate) IS NOT NULL)
	BEGIN
		INSERT INTO @virtualXML
			(	seqNo, Pos, Val                       )
		SELECT	seqNo, p1.Pos, p2.Val
		FROM (
			SELECT	DISTINCT seqNo
			FROM	ProfileVirtualSetting WITH (NOLOCK)
		) pvs
		CROSS APPLY (
			SELECT CONVERT(VARBINARY(64), (
				SELECT	CONVERT(VARCHAR, CAST(ipvs.profileID - 64 * (ipvs.seqNo - 1) AS BINARY(1)), 2)
				FROM		@tblVirtualrate			AS tmp
					INNER JOIN	ProfileVirtualSetting	AS ipvs WITH (NOLOCK)
						ON	tmp.sporttype	= ipvs.sporttype
							AND	tmp.bettype		= ipvs.bettype
							AND	tmp.isLive		= ipvs.islive
				WHERE	ipvs.seqNo = pvs.seqNo
				FOR XML PATH ('')						
			), 2) AS Pos
		) p1
		CROSS APPLY (
			SELECT CONVERT(VARBINARY(64), (
				SELECT	CONVERT(VARCHAR, CAST(CASE WHEN CAST(VirtualMultiplier * 100 AS INT) > 200 THEN ((CAST(VirtualMultiplier * 100 AS INT) - 200) / 5 + 200) ELSE CAST(VirtualMultiplier * 100 AS INT) END AS BINARY(1)), 2)
				FROM		@tblVirtualrate			AS tmp
					INNER JOIN	ProfileVirtualSetting	AS ipvs WITH (NOLOCK)
						ON	tmp.sporttype	= ipvs.sporttype
							AND	tmp.bettype		= ipvs.bettype
							AND	tmp.isLive		= ipvs.islive
				WHERE	ipvs.seqNo = pvs.seqNo
				FOR XML PATH ('')						
			), 2) AS Val
		) p2;

		-- READ locked VR members

		EXECUTE sp_xml_preparedocument @DocHandler OUTPUT, @lockedVRmembers;

		INSERT INTO	@lockedMembers
			(	CustID     )
		SELECT	Data.CustID
		FROM OPENXML (@DocHandler, '/ROOT/LockedVR', 1) 
		WITH (	CustID			INT) AS Data;

		EXECUTE sp_xml_removedocument @DocHandler;
	
		--update batch 2k cust for CustVirtualSetting coz each customer has 3 seqNo
		SET @batchUpdate = 2000	
		IF @roleid = 4
		BEGIN
			DELETE #tblCustVR
			
			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM @lockedMembers AS lm
				RIGHT HASH JOIN dbo.custInfo ci WITH (NOLOCK) ON lm.custID = ci.custid
			WHERE	ci.srecommend = @custid
				AND	lm.custID IS NULL

			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;

				UPDATE cvs
				SET cvs.bitmapVirtual = bm.bitmap
				FROM	#tmpCustBatchVR tmpCust
					CROSS APPLY (
						SELECT TOP 3 cvs.seqNo, cvs.bitmapVirtual
						FROM CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
						WHERE cvs.custID = tmpCust.custID
					) cvs
					CROSS APPLY (
						SELECT TOP 1 bm.bitmap
						FROM @virtualXML			AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
			END	
			
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.srecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	@lockedMembers AS lm
						WHERE	lm.custID = ci.custid
					);
		END;
		ELSE IF @roleid = 3
		BEGIN
			DELETE #tblCustVR

			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM @lockedMembers AS lm
				RIGHT HASH JOIN dbo.custInfo ci WITH (NOLOCK) ON lm.custID = ci.custid
			WHERE	ci.mrecommend = @custid
				AND	lm.custID IS NULL
			
			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;

				UPDATE cvs
				SET cvs.bitmapVirtual = bm.bitmap
				FROM	#tmpCustBatchVR tmpCust
					CROSS APPLY (
						SELECT TOP 3 cvs.seqNo, cvs.bitmapVirtual
						FROM CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
						WHERE cvs.custID = tmpCust.custID
					) cvs
					CROSS APPLY (
						SELECT TOP 1 bm.bitmap
						FROM @virtualXML			AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
			END	
			
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.mrecommend = @custid
				AND ci.custid > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	@lockedMembers AS lm
						WHERE	lm.custID = ci.custid
					)
		END;
		ELSE IF @roleid = 2
		BEGIN
			DELETE #tblCustVR

			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM @lockedMembers AS lm
				RIGHT HASH JOIN dbo.custInfo ci WITH (NOLOCK) ON lm.custID = ci.custid
			WHERE	ci.recommend = @custid
				AND	lm.custID IS NULL
			
			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
				
				UPDATE cvs
				SET cvs.bitmapVirtual = bm.bitmap
				FROM	#tmpCustBatchVR tmpCust
					CROSS APPLY (
						SELECT TOP 3 cvs.seqNo, cvs.bitmapVirtual
						FROM CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
						WHERE cvs.custID = tmpCust.custID
					) cvs
					CROSS APPLY (
						SELECT TOP 1 bm.bitmap
						FROM @virtualXML			AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
			END	
			
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.recommend = @custid
				AND ci.custid > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	@lockedMembers AS lm
						WHERE	lm.custID = ci.custid
					)
		END;
		ELSE IF @roleid = 1
		BEGIN
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH(UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH(NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.custid = @custid;
		END;
	END;
END;
ELSE IF	dbo.f_CheckRepTable('custinfo') = 1
BEGIN
	IF	@Action ='Suspended' 
    BEGIN
		DECLARE @tmpCust TABLE(CustID INT)
			    
		INSERT INTO @tmpCust(custid)	
		SELECT val
		FROM dbo.strSplit(@custlist,',')
		
		UPDATE	CustInfo with (ROWLOCK, UPDLOCK) 
		SET	Reject = @Suspended
		WHERE custid IN (SELECT custid FROM @tmpCust)	    
    END;
    ELSE IF @Action='Closed'
    BEGIN
		create table #tempCust ( CustID int PRIMARY KEY)
	    IF @RoleID = 4 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed 
			output INSERTED.custid into #tempCust
		    WHERE	srecommend = @custid;
	    END;
	    ELSE IF @RoleID = 3 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed 
			output INSERTED.custid into #tempCust
		    WHERE	mrecommend = @custid;		
	    END;
	    ELSE IF @RoleID = 2 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed 
			output INSERTED.custid into #tempCust
		    WHERE	recommend = @custid;		
	    END;	
		

		IF	dbo.f_CheckRepTable('CustLoginInfo') = 1 and dbo.f_CheckRepTable('CustLoginInfo_Member') = 1 
		BEGIN
			IF (@SystemID=1)
			BEGIN	
			   
				UPDATE cl
				set cl.ClosedReason = 1
				FROM [dbo].[CustLoginInfo] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID
			 
				UPDATE cl
				set cl.ClosedReason = 1
				FROM [dbo].[CustLoginInfo_Member] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID

				INSERT INTO [CustLoginInfo_Member]([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason)
				SELECT t.Custid ,NULL,NULL,NULL,GETDATE(),1
				FROM #tempCust t
				INNER JOIN custInfo c ON t.CustID=c.custid
				WHERE t.CustID  NOT IN(SELECT CustID FROM [CustLoginInfo_Member] WITH(NOLOCK)) AND c.roleid=1
			 
			END			
			ELSE 
			BEGIN
				UPDATE cl
				set cl.ClosedReason = 2
				FROM [dbo].[CustLoginInfo] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID
			
				UPDATE cl
				set cl.ClosedReason = 2
				FROM [dbo].[CustLoginInfo_Member] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID

				INSERT INTO [CustLoginInfo_Member]([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason)
				SELECT t.Custid ,NULL,NULL,NULL,GETDATE(),2
				FROM #tempCust t
				INNER JOIN custInfo c ON t.CustID=c.custid
				WHERE t.CustID  NOT IN(SELECT CustID FROM [CustLoginInfo_Member] WITH(NOLOCK)) AND c.roleid=1
			END			
		END 
    END;
    ELSE IF @Action ='disabledCS'
    BEGIN
	    IF @RoleID = 4
	    BEGIN
			IF @DisabledCS = 1
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = @disabledCS
				WHERE	SyncCasino=1 AND srecommend=@custid AND roleid BETWEEN 1 AND 3; 
			END
			ELSE
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = CASE WHEN @UpdateAllMasters = 1 AND roleID =3 THEN @DisableAllMasters
											 WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
											 WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
											 ELSE DisableCasino	END	
				WHERE	SyncCasino=1 AND srecommend=@custid AND roleid BETWEEN 1 AND 3;
			END
	    END;
	    ELSE IF @RoleID = 3
	    BEGIN
			IF @DisabledCS = 1
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = @disabledCS
				WHERE	SyncCasino=1 AND mrecommend=@custid AND roleid BETWEEN 1 AND 2; 
			END
			ELSE
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = CASE WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
											 WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
											 ELSE DisableCasino	END	
				WHERE	SyncCasino=1 AND mrecommend=@custid AND roleid BETWEEN 1 AND 2;
			END
	    END;
	    ELSE IF @RoleID = 2
	    BEGIN
			IF @DisabledCS = 1
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = @disabledCS
				WHERE	SyncCasino=1 AND recommend=@custid AND roleid = 1;
			END
			ELSE
			BEGIN
				UPDATE	CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET		DisableCasino = CASE WHEN @UpdateAllMembers = 1 THEN @DisableAllMembers
											 ELSE DisableCasino	END
				WHERE	SyncCasino=1 AND recommend=@custid AND roleid = 1;
			END
	    END;
    END;
   
    
    ELSE IF @Action = 'DisableNumberGame'
    BEGIN
	    IF @RoleID = 4 
		BEGIN
			IF @DisableNumberGame = 1
			BEGIN
				UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableNumber = @DisableNumberGame 
				WHERE SRecommend = @CustID;
			END	
			ELSE
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK)   
				SET DisableNumber = CASE WHEN @UpdateAllMasters = 1 AND roleID =3 THEN @DisableAllMasters
										WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
										WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
										ELSE DisableNumber END  
				WHERE CustID <> @CustID  
					AND SRecommend = @CustID;
			END
		END 
	    IF @RoleID = 3 
		BEGIN
		    IF @DisableNumberGame = 1
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableNumber = @DisableNumberGame 
				WHERE MRecommend = @CustID;
			END
			ELSE 
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK)   
				SET DisableNumber = CASE WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
										WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
										ELSE DisableNumber END  
				WHERE CustID <> @CustID  
					AND MRecommend = @CustID;
			END
		END
		
	    IF @RoleID = 2 
		BEGIN
			IF @DisableNumberGame =1
			BEGIN
				UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableNumber = @DisableNumberGame 
				WHERE Recommend = @CustID;
			END
			ELSE
			BEGIN
				UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableNumber = CASE WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
										ELSE DisableNumber END   
				WHERE CustID <> @CustID 
					AND Recommend = @CustID;
			END	
		END	
    END;

    else if @Action = 'AutoSuspend'
    BEGIN
	    IF @roleID = 4 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = @AutoSuspendOtherSports, 
			    autosuspend = @AutoSuspendSoccer
		    WHERE srecommend = @custID; 
	    END;

	    IF @roleID = 3 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = @AutoSuspendOtherSports,	
			    autosuspend = @AutoSuspendSoccer
		    WHERE mrecommend = @custID; 
	    END;

	    IF @roleID = 2 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = @AutoSuspendOtherSports,	
			    autosuspend = @AutoSuspendSoccer
		    WHERE recommend = @custID; 
	    END;
    END;
    else IF @Action = 'AutoSuspendSoccer'
    begin 
	    IF @roleID = 4 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend = @AutoSuspendSoccer	
		    WHERE srecommend = @custID; 
	    END;

	    IF @roleID = 3 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend = @AutoSuspendSoccer	
		    WHERE mrecommend = @custID; 
	    END;

	    IF @roleID = 2 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend = @AutoSuspendSoccer	
		    WHERE recommend = @custID; 
	    END;
    end;
    else if @Action = 'AutoSuspendOther'
    begin
	    IF @roleID = 4 
		    BEGIN
			    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
			    SET	autosuspend2 = @AutoSuspendOtherSports
			    WHERE srecommend = @custID; 	
		    END;

	    IF @roleID = 3 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = @AutoSuspendOtherSports	
		    WHERE mrecommend = @custID; 
	    END;

	    IF @roleID = 2 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = @AutoSuspendOtherSports	
		    WHERE recommend = @custID; 
	    END;
    end;
    /**20140228@Bobby: Update Keno status [Redmine:#12474]**/
    else if @Action = 'UpdKeno-Hide'
    begin
	    IF (@roleID = 4)
	    BEGIN
		    UPDATE cust
		    SET HideKeno = 0
		    FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		    WHERE CustID <> @CustID
			    AND SRecommend = @CustID
				AND HideKeno = 1
				AND ((Roleid = 3 AND @UpdateAllMasters =1)
					OR (Roleid = 2 AND @UpdateAllAgents =1)
					OR (Roleid = 1 AND @UpdateAllMembers =1)
					)
	    END;

	    IF (@roleID = 3)
	    BEGIN
		    UPDATE cust
		    SET HideKeno = 0
		    FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		    WHERE CustID <> @CustID
			    AND MRecommend = @CustID
				AND HideKeno = 1
				AND ((Roleid = 2 AND @UpdateAllAgents =1)
					OR (Roleid = 1 AND @UpdateAllMembers =1)
					)
	    END;

	    IF (@roleID = 2)
	    BEGIN
		    UPDATE cust
		    SET HideKeno = 0
		    FROM dbo.CustInfo cust WITH (ROWLOCK, UPDLOCK) 
		    WHERE CustID <> @CustID
			    AND Recommend = @CustID
				AND HideKeno = 1
				AND (Roleid = 1 AND @UpdateAllMembers =1);
	    END;
    end;
    --@20150424@Johnson: add Gold Deluxe
    ELSE IF @Action = 'GoldDeluxe'
    BEGIN
	    IF (@roleID = 4)
	    BEGIN
			IF @DisableGoldDeluxe = 1
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = @DisableGoldDeluxe		
				WHERE CustID <> @CustID
					AND SRecommend = @CustID
					AND HideGoldDeluxe = 0;
			END
			ELSE
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = CASE WHEN @UpdateAllMasters = 1 AND roleID =3 THEN @DisableAllMasters
											 WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
											 WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
											 ELSE DisableGoldDeluxe	END	
				WHERE CustID <> @CustID
					AND SRecommend = @CustID
					AND HideGoldDeluxe = 0;
			END
	    END;

	    IF (@roleID = 3)
	    BEGIN
			IF @DisableGoldDeluxe = 1
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = @DisableGoldDeluxe			    
				WHERE CustID <> @CustID
					AND MRecommend = @CustID
					AND HideGoldDeluxe = 0;
			END
			ELSE
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = CASE WHEN @UpdateAllAgents = 1 AND roleID =2 THEN @DisableAllAgents
											 WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
											 ELSE DisableGoldDeluxe	END	
				WHERE CustID <> @CustID
					AND MRecommend = @CustID
					AND HideGoldDeluxe = 0;
			END	
	    END;

	    IF (@roleID = 2)
	    BEGIN
			IF @DisableGoldDeluxe = 1
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = @DisableGoldDeluxe
				WHERE CustID <> @CustID
					AND Recommend = @CustID
					AND HideGoldDeluxe = 0;
			END
			ELSE 
			BEGIN
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
				SET DisableGoldDeluxe = CASE WHEN @UpdateAllMembers = 1 AND roleID =1 THEN @DisableAllMembers
											 ELSE DisableGoldDeluxe	END	
				WHERE CustID <> @CustID
					AND Recommend = @CustID
					AND HideGoldDeluxe = 0;
			END		
	    END;
    END;
	ELSE IF @Action = 'SuperLive'
    BEGIN
	    IF (@roleID = 4)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive
		    WHERE CustID <> @CustID
			    AND SRecommend = @CustID;
	    END;

	    IF (@roleID = 3)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive
		    WHERE CustID <> @CustID
			    AND MRecommend = @CustID;
	    END;

	    IF (@roleID = 2)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive
		    WHERE CustID <> @CustID
			    AND Recommend = @CustID;
	    END;
    END;
    
    ELSE IF @Action = 'ColossusBet'  
	BEGIN  
		IF (@roleID = 4)  
		BEGIN  
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK)   
				SET DisableColossusBet = @DisableColossusBet,  
					HideColossusBet = CASE WHEN HideColossusBet = 1 THEN 0 ELSE HideColossusBet END    
				WHERE CustID <> @CustID  
					AND SRecommend = @CustID;  
		END;  

		IF (@roleID = 3)  
		BEGIN  
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK)   
				SET DisableColossusBet = @DisableColossusBet,  
					HideColossusBet = CASE WHEN HideColossusBet = 1 THEN 0 ELSE HideColossusBet END      
				WHERE CustID <> @CustID  
					AND MRecommend = @CustID; 
		END;  

		IF (@roleID = 2)  
		BEGIN  
				UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK)   
					SET DisableColossusBet = @DisableColossusBet,  
					HideColossusBet = CASE WHEN HideColossusBet = 1 THEN 0 ELSE HideColossusBet END      
				WHERE CustID <> @CustID  
					AND Recommend = @CustID;  
		END;  
	END;    

	ELSE IF	@action = 'EnableVirtualMultiplier'
	BEGIN
		DECLARE	@tblEnableVirtualrate	TABLE (CustIDs VARCHAR(MAX))
		CREATE	TABLE #tblCustomer (CustID INT PRIMARY KEY)
		DECLARE	@DocHandlerXML			INT

		IF	@EnableVirtualMultiplier <> ''
		BEGIN			
			-- For read xml					
			EXECUTE sp_xml_preparedocument @DocHandlerXML OUTPUT, @EnableVirtualMultiplier;

			INSERT INTO	@tblEnableVirtualrate (CustIDs)
			SELECT	Data.CustIDs
			FROM OPENXML (@DocHandlerXML, '/ROOT/Rate',1) 
			WITH (
					CustIds				VARCHAR(MAX)
				,	VirtualMultiplier	SMALLMONEY	
				) AS Data;

			EXECUTE sp_xml_removedocument @DocHandlerXML;
			-- end read xml
		END;	
		
		INSERT INTO #tblCustomer (CustID)
		SELECT ss.val
		FROM @tblEnableVirtualrate AS tv
			CROSS APPLY	dbo.strSplit(tv.CustIDs, ',') AS ss;							

		UPDATE	dbo.custInfo WITH (ROWLOCK, UPDLOCK)
		SET	virtualmultiplier = 1
		FROM custInfo
		WHERE custid IN (SELECT custID FROM #tblCustomer)
	END
END
GO