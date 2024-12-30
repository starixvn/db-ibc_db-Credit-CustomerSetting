/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_04] @custid						INT				
				,	@roleid						TINYINT			
				,	@action						VARCHAR(30)		= ''
				,	@custlist					VARCHAR(MAX) 	= ''
				,	@EnableVirtualrate			BIT				= 0
				,	@virtualmultiplier			VARCHAR(MAX)	= ''
				,	@EnableVirtualMultiplier	VARCHAR(MAX)	= ''
				,   @VRlockStatusType			TINYINT			= NULL -- 0: all, 1:soccer, 2: Other sports, 3: Basketball 
				,	@Suspended					BIT				= 0
				,	@Closed						BIT				= 0
				,	@disabledCS					BIT				= 0				
				,	@DisableVS					BIT				= 0
				,	@EnableVS					BIT				= 0
				,	@DisableNumberGame			BIT				= 0
				
				--20180109@Johnson: new direction for status [redmine:#87328]
				,	@UpdateAllMasters 			BIT 			= 0
				,	@UpdateAllAgents  			BIT 			= 0
				,	@UpdateAllMembers 			BIT 			= 0
							
				,	@DisableAllMasters 			BIT 			= NULL
				,	@DisableAllAgents  			BIT 			= NULL
				,	@DisableAllMembers 			BIT 			= NULL
				
				,	@DisableSuperLive			BIT				= 0
				,	@AutoSuspendSoccer			BIT				= 0
				,	@AutoSuspendOtherSports		BIT				= 0
				,	@AutoSuspendBasketball		BIT				= 0
				,	@IsUpdateAutoSuspendSoccer			BIT 	= 0
				,	@IsUpdateAutoSuspendOtherSports		BIT 	= 0
				,	@IsUpdateAutoSuspendBasketball 		BIT 	= 0
				,	@rowcount					INT				= 0		OUTPUT
				,	@SystemID TINYINT=1
				--20200206@Tiara: New VR structure for Soccer [Redmine: #126243]
				,	@Sporttype					INT				= NULL 
				--, @AdditionalActions			VARCHAR(MAX) = ''
				--,	@VRAccumulate_Balance		BIT				= 0
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
		- 20200206@Tiara: New VR structure for Soccer [Redmine: #126243]
		- 20200218@Eden : Web_pass_redundant_bettypes_when_updating_bettype_group_value_and_auto_suspend [Redmind: #128635]
		- 20200811@Eden: Adjust VR setting for Other Sports of Haifa, IBO, Mansion88 & Happy8 [redmine: #139229]
		- 20200827@Eden: VR Adjustment by Agent profile [#140421]
		- 20200826@Eden: Adjust VR setting for Soccer of Haifa, IBO [redmine: #140368]
		- 20201201@Eden: Just Update reason for customers who updated closed status [Redmine:145018]
		- 20210224@Eden: Implement Lock for VR update [Redmine:#149370]
		- 20210308@Eden: Copy and apply VR settings to multiple member accounts [Redmine:#149372]
		- 20210325@Eden: Implement option to override Lock VR status and values for Master/Agent and even unlocked status of members [Redmine:#152094]
		- 20220406@Elodie: Apply STRING_SPLIT() instead of strSplit UDF [Redmine: #168783]
		- 20220419@Eden: Turn off VR Basketball & E-sports for 611111 site [Redmine: #171609]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20221103@Johnson: Change data type of CustSettingAutoSuspend [Redmine: #179782]
		- 20221207@Johnson: update setting for sub-bettype for Esport is 'Follow parent' [redmine: #177594]
		- 20221207@Tacy: Remove columns and code used by Colossus Bets, GD product [RedmineID: #179132]
		- 20230302@Johnson: Add auto suspend for basketball and return Basketball VR to its original state [redmine:#184339]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230427@Luke: Separate lock function for Basketball [Redmine: #185991]
		- 20230711@Helios: VR Accumulate Balance [Redmine: #189649] 
		- 20230724@Luke: Unlock VR for Soccer, Basketball, Other Sports [Redmine: #191162]
		- 20231129@Luke: NAP - Virtual rate - Enhance VR [Redmine: #194939]
		- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting [redmine: #207029]
		- 20241129@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]		
		- 20241230@Aries: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]

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
		
			+ 'AutoSuspend': update Auto suspend for Soccer, Basketball, Other Sports [@AutoSuspendSoccer, @AutoSuspendOtherSports, @AutoSuspendBasketball]
			
			+ 'UpdKeno-Hide' : Hide Keno gaming
			+ 'GoldDeluxe': Gold Deluxe status
			+ 'SuperLive': Super Live status
			+ 'EnableVirtualMultiplier': Enable Virtual Rate [@EnableVirtualMultiplier]
			+ 'NewVRUpd': Update VR setting of an account for Esport  [@virtualmultiplier] - Redmine: #114830 and for Soccer [Redmine: #126243]

		- @AdditionalActions : Use for update VR
							 = '<ROOT>
								<VR UnlockSC3="1"  UnlockSC2="0" UnlockSC1="1" UnlockBB3="1"  UnlockBB2="0" UnlockBB1="1" UnlockOS3="1"  UnlockOS2="0" UnlockOS1="1" Enable3="0"  Enable2="1" Enable1="0" />	
							</ROOT>'
   
*/
SET NOCOUNT ON; 

IF	@action = 'VirtualMultiplier'
BEGIN
								
	DECLARE	@EnableVirtualrateOld	BIT;

	CREATE TABLE #tblCustVR (custID INT)
	CREATE TABLE #tmpCustBatchVR (CustID INT PRIMARY KEY)	
	DECLARE @batchUpdate INT = 2000,
			@maxcustid INT					
	
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
	
	IF dbo.f_CheckRepTable('custinfo') = 1
	BEGIN
		IF (@EnableVirtualrate = 1 AND @EnableVirtualrate <> @EnableVirtualrateOld)			--not enable downlines
		BEGIN
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate,
				RepUpdateTime = dbo.f_GetDateTime2()
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE custID = @custid
		END
		ELSE IF (@EnableVirtualrate = 0)																			--disable downlines
		BEGIN
			SET @batchUpdate = 2000--for update custinfo
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
					SET	ci.virtualmultiplier = @EnableVirtualrate,
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
				END	
			
				--update newly customer if any
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate,
					RepUpdateTime = dbo.f_GetDateTime2()
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
					SET	ci.virtualmultiplier = @EnableVirtualrate,
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
				END	
			
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate,
					RepUpdateTime = dbo.f_GetDateTime2()
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
					SET	ci.virtualmultiplier = @EnableVirtualrate,
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE custID IN (SELECT custID FROM #tmpCustBatchVR)
				END
			
				UPDATE	ci
				SET	ci.virtualmultiplier = @EnableVirtualrate,
					RepUpdateTime = dbo.f_GetDateTime2()
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
				SET	ci.virtualmultiplier = @EnableVirtualrate,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
				WHERE	ci.custid = @custid								
			END;
		END;			
	END
	
	DROP TABLE #tblCustVR
	DROP TABLE #tmpCustBatchVR
END;
ELSE IF	dbo.f_CheckRepTable('custinfo') = 1
BEGIN
	IF	@Action ='Suspended' 
    BEGIN
		DECLARE @tmpCust TABLE(CustID INT)
			    
		INSERT INTO @tmpCust(custid)	
		SELECT value
		FROM STRING_SPLIT(@custlist,',')
		
		UPDATE	CustInfo with (ROWLOCK, UPDLOCK) 
		SET	Reject = @Suspended,
			RepUpdateTime = dbo.f_GetDateTime2()
		WHERE custid IN (SELECT custid FROM @tmpCust)	    
    END;
    ELSE IF @Action='Closed'
    BEGIN
		create table #tempCust ( CustID int PRIMARY KEY)
	    IF @RoleID = 4 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed,
					RepUpdateTime = dbo.f_GetDateTime2()
			output INSERTED.custid into #tempCust
		    WHERE	srecommend = @custid
					AND (closed <> @Closed OR closed IS NULL)
	    END;
	    ELSE IF @RoleID = 3 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed,
					RepUpdateTime = dbo.f_GetDateTime2()
			output INSERTED.custid into #tempCust
		    WHERE	mrecommend = @custid
					AND (closed <> @Closed OR closed IS NULL)	
	    END;
	    ELSE IF @RoleID = 2 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed,
					RepUpdateTime = dbo.f_GetDateTime2()
			output INSERTED.custid into #tempCust
		    WHERE	recommend = @custid
					AND (closed <> @Closed OR closed IS NULL)	
	    END;	
		

		IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active'
		BEGIN
			IF (@SystemID=1)
			BEGIN	
			   
				UPDATE cl
				set cl.ClosedReason = 1
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustLoginInfo] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID
			 
				UPDATE cl
				set cl.ClosedReason = 1
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustLoginInfo_Member] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID

				INSERT INTO [CustLoginInfo_Member]([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason,RepUpdateTime)
				SELECT t.Custid ,NULL,NULL,NULL,GETDATE(),1,dbo.f_GetDateTime2()
				FROM #tempCust t
				INNER JOIN custInfo c ON t.CustID=c.custid
				WHERE t.CustID  NOT IN(SELECT CustID FROM [CustLoginInfo_Member] WITH(NOLOCK)) AND c.roleid=1
			 
			END			
			ELSE 
			BEGIN
				UPDATE cl
				set cl.ClosedReason = 2
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustLoginInfo] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID
			
				UPDATE cl
				set cl.ClosedReason = 2
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustLoginInfo_Member] cl with (ROWLOCK, UPDLOCK) 
				INNER JOIN #tempCust t ON cl.CustID=t.CustID

				INSERT INTO [CustLoginInfo_Member]([CustID],[SecurityCode],[IP],[LastChangedID],[LastChangedDate],ClosedReason,RepUpdateTime)
				SELECT t.Custid ,NULL,NULL,NULL,GETDATE(),2,dbo.f_GetDateTime2()
				FROM #tempCust t
				INNER JOIN custInfo c ON t.CustID=c.custid
				WHERE t.CustID  NOT IN(SELECT CustID FROM [CustLoginInfo_Member] WITH(NOLOCK)) AND c.roleid=1
			END			
		END 
    END;      

    else if @Action = 'AutoSuspend'
    BEGIN
	    IF @roleID = 4 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END,
				RepUpdateTime = dbo.f_GetDateTime2()
		    WHERE srecommend = @custID; 
	    END;

	    IF @roleID = 3 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END,
				RepUpdateTime = dbo.f_GetDateTime2()
		    WHERE mrecommend = @custID; 
	    END;

	    IF @roleID = 2 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END,
				RepUpdateTime = dbo.f_GetDateTime2()
		    WHERE recommend = @custID; 
	    END;
    END;    
    
	ELSE IF @Action = 'SuperLive'
    BEGIN
	    IF (@roleID = 4)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive,
				RepUpdateTime = dbo.f_GetDateTime2()
		    WHERE CustID <> @CustID
			    AND SRecommend = @CustID;
	    END;

	    IF (@roleID = 3)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive,
				RepUpdateTime = dbo.f_GetDateTime2()
		    WHERE CustID <> @CustID
			    AND MRecommend = @CustID;
	    END;

	    IF (@roleID = 2)
	    BEGIN
		    UPDATE dbo.CustInfo WITH (ROWLOCK, UPDLOCK) 
		    SET DisableSuperLive = @DisableSuperLive,
				RepUpdateTime = dbo.f_GetDateTime2()
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
		SELECT ss.value
		FROM @tblEnableVirtualrate AS tv
			CROSS APPLY	STRING_SPLIT(tv.CustIDs, ',') AS ss							

		UPDATE	dbo.custInfo WITH (ROWLOCK, UPDLOCK)
		SET	virtualmultiplier = 1,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM custInfo
		WHERE custid IN (SELECT custID FROM #tblCustomer)
	END
END

GO
