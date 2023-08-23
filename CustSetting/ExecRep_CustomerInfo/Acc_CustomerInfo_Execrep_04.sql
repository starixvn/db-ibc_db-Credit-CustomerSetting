/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
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
				,	@DisableColossusBet			BIT				= 0				
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
				,   @AdditionalActions			VARCHAR(MAX) = ''
				,	@VRAccumulate_Balance		BIT				= 0
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
		- 20230302@Johnson: Add auto suspend for basketball and return Basketball VR to its original state [redmine:#184339]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230427@Luke: Separate lock function for Basketball [Redmine: #185991]
		- 20230711@Helios: VR Accumulate Balance [Redmine: #189649] 
		- 20230724@Luke: Unlock VR for Soccer, Basketball, Other Sports [Redmine: #191162]

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

IF	@action = 'NewVRUpd'
BEGIN
	CREATE TABLE #New_VRCustSetting (LevelID INT, ValueIDLive TINYINT, ValueIDNonLive TINYINT)
	DECLARE @DocHandlerSport INT	

	IF @VirtualMultiplier <> ''
	BEGIN				
		EXEC sp_xml_preparedocument @DocHandlerSport OUTPUT, @virtualmultiplier

		INSERT INTO #New_VRCustSetting(LevelID, ValueIDLive, ValueIDNonLive)
		SELECT Data.LevelID,
			Data.ValueIDLive,
			Data.ValueIDNonLive
		FROM OPENXML (@DocHandlerSport, '/Root/Row',1) 
		WITH (
			LevelID	INT,
			ValueIDLive TINYINT,
			ValueIDNonLive TINYINT	
		) AS Data

		EXEC sp_xml_removedocument @DocHandlerSport
	END

	--DELETE FROM #New_VRCustSetting WHERE ValueIDLive = 0 AND ValueIDNonLive = 0

	IF(dbo.f_CheckRepTable('VRCustSetting') = 1 AND dbo.f_CheckRepTable('VRSettingHierarchy') = 1)
	BEGIN

		UPDATE main
		SET main.ValueIDLIVE = vr.ValueIDLive
			, main.ValueIDNonLIVE = vr.ValueIDNonLIVE
		FROM VRCustSetting main
			INNER JOIN #New_VRCustSetting VR ON main.CustID = @custid AND VR.LevelID = main.LevelID
			INNER JOIN VRSettingHierarchy H WITH (NOLOCK) ON VR.LevelID = H.LevelID
		WHERE H.SportType = @Sporttype

		DELETE V
		FROM VRCustSetting V WITH (ROWLOCK) INNER JOIN VRSettingHierarchy H WITH (NOLOCK) ON V.LevelID = H.LevelID
		WHERE custid = @custid
			AND (V.LevelID NOT IN (SELECT LevelID FROM #New_VRCustSetting)
				OR (ValueIDLive = 0 AND ValueIDNonLive = 0)
				)
			AND H.SportType = @Sporttype
			
		INSERT INTO [dbo].[VRCustSetting]
           ([CustID]
           ,[LevelID]
           ,[ValueIDLIVE]
           ,[ValueIDNonLIVE])
		SELECT @custid [CustID]
           ,VR.[LevelID]
           ,VR.[ValueIDLIVE]
           ,VR.[ValueIDNonLIVE]
		FROM #New_VRCustSetting VR WITH (NOLOCK) INNER JOIN VRSettingHierarchy H WITH (NOLOCK) ON VR.LevelID = H.LevelID
		WHERE VR.[LevelID] NOT IN (SELECT LevelID FROM [VRCustSetting] WITH (NOLOCK) WHERE CustID=@custid)
			AND H.SportType = @Sporttype
			AND (VR.ValueIDLive <> 0 OR VR.ValueIDNonLive <> 0)
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

	DECLARE	@virtualXML_Soccer	TABLE (
									seqNo				TINYINT PRIMARY KEY
								,	Pos			VARBINARY(64)
								,	Val			VARBINARY(64)
								);
	DECLARE	@virtualXML_Basketball		TABLE ( --Basketball
									seqNo				TINYINT PRIMARY KEY
								,	Pos			VARBINARY(64)
								,	Val			VARBINARY(64)
								);
	DECLARE	@virtualXML_OS		TABLE ( --other sport except basketball and Esport
									seqNo				TINYINT PRIMARY KEY
								,	Pos			VARBINARY(64)
								,	Val			VARBINARY(64)
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
	
	IF dbo.f_CheckRepTable('custinfo') = 1
	BEGIN
		IF (@EnableVirtualrate = 1 AND @EnableVirtualrate <> @EnableVirtualrateOld)			--not enable downlines
		BEGIN
			UPDATE	ci
			SET	ci.virtualmultiplier = @EnableVirtualrate
			FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
			WHERE custID = @custid
		END
		ELSE IF (@EnableVirtualrate = 0)																			--disable downlines
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
	END
	
	IF	(dbo.f_CheckRepTable('CustVirtualSetting') = 1 AND (SELECT TOP 1 1 FROM @tblVirtualrate) IS NOT NULL)
	BEGIN
		INSERT INTO @virtualXML_Soccer
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType = 1
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType = 1
				FOR XML PATH ('')						
			), 2) AS Val
		) p2;
		INSERT INTO @virtualXML_Basketball																														
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType = 2									
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType = 2									
				FOR XML PATH ('')																						
			), 2) AS Val																				
		) p2;																							
		INSERT INTO @virtualXML_OS 
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType NOT IN (1, 2, 43)								
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
				WHERE	ipvs.seqNo = pvs.seqNo AND tmp.SportType NOT IN (1, 2, 43)								
				FOR XML PATH ('')						
			), 2) AS Val
		) p2;

		--> Update VR for itself --soccer
		UPDATE cvs
		SET cvs.bitmapVirtual = bm.bitmap
		FROM		CustVirtualSetting	AS cvs WITH(UPDLOCK, ROWLOCK)
		INNER JOIN	custInfo			AS ci WITH(NOLOCK)
				ON	ci.custid = cvs.custid
		INNER JOIN	@virtualXML_Soccer			AS tmp
				ON	cvs.seqNo = tmp.seqNo
		CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
		WHERE	ci.custid = @custid;

		--> Update VR for itself --Basketball									
		UPDATE cvs																
		SET cvs.bitmapVirtual = bm.bitmap										
		FROM		CustVirtualSetting	AS cvs WITH(UPDLOCK, ROWLOCK)			
		INNER JOIN	custInfo			AS ci WITH(NOLOCK)						
				ON	ci.custid = cvs.custid										
		INNER JOIN	@virtualXML_Basketball			AS tmp						
				ON	cvs.seqNo = tmp.seqNo										
		CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm	
		WHERE	ci.custid = @custid;											

		--> Update VR for itself --Other sports
		UPDATE cvs
		SET cvs.bitmapVirtual = bm.bitmap
		FROM		CustVirtualSetting	AS cvs WITH(UPDLOCK, ROWLOCK)
		INNER JOIN	custInfo			AS ci WITH(NOLOCK)
				ON	ci.custid = cvs.custid
		INNER JOIN	@virtualXML_OS			AS tmp
				ON	cvs.seqNo = tmp.seqNo
		CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
		WHERE	ci.custid = @custid;

		--update batch 2k cust for CustVirtualSetting coz each customer has 3 seqNo
		SET @batchUpdate = 2000	

		IF @roleid = 1
		BEGIN
			RETURN --Not update VR for its downline
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM @virtualXML_Soccer) 
				AND NOT EXISTS (SELECT 1 FROM @virtualXML_OS)
				AND NOT EXISTS (SELECT 1 FROM @virtualXML_Basketball)			
		BEGIN
			RETURN --Not update VR for its downline
		END
		ELSE IF @roleid = 4
		BEGIN
			DELETE #tblCustVR
			
			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.srecommend = @custid AND ci.custid <> @custid

			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR

			--> not scan to update for downline with have VR status Locked all sports
			DELETE t
			FROM #tblCustVR t
				INNER JOIN VRCustLockStatus l1 WITH(NOLOCK) ON t.custID = l1.CustID AND l1.Type = 1
				INNER JOIN VRCustLockStatus l2 WITH(NOLOCK) ON t.custID = l2.CustID AND l2.Type = 2
				INNER JOIN VRCustLockStatus l3 WITH(NOLOCK) ON t.custID = l3.CustID AND l3.Type = 3		
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
				
				--> Update Soccer VR
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
						FROM @virtualXML_Soccer	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 1
					)

				--> Update Basketball VR												
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
						FROM @virtualXML_Basketball	AS tmp								
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm		
						WHERE cvs.seqNo = tmp.seqNo										
					) bm																
				 WHERE	NOT EXISTS (													
						SELECT	1														
						FROM	VRCustLockStatus lm WITH(NOLOCK)						
						WHERE	lm.custID = tmpCust.custid 								
								AND lm.Type = 3											
					)																	

				--> Update OtherSport VR
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
						FROM @virtualXML_OS	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 2
					)
			END	
			
			--> Update for new accounts
			UPDATE cvs					
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_Soccer			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.srecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 1
					)

			UPDATE cvs																
			SET cvs.bitmapVirtual = bm.bitmap										
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)			
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)						
					ON	ci.custid = cvs.custid										
			INNER JOIN	@virtualXML_Basketball			AS tmp						
					ON	cvs.seqNo = tmp.seqNo										
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm		
			WHERE	ci.srecommend = @custid											
				AND ci.custID > @maxcustid											
				AND	NOT EXISTS (													
						SELECT	1													
						FROM	VRCustLockStatus lm WITH(NOLOCK)					
						WHERE	lm.custID = ci.custid 								
								AND lm.Type = 3										
					)																

			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_OS			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.srecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 2
					)
		END;
		ELSE IF @roleid = 3
		BEGIN
			DELETE #tblCustVR

			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.mrecommend = @custid  AND ci.custid <> @custid

			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR

			--> not scan to update for downline with have VR status Locked all sports
			DELETE t
			FROM #tblCustVR t
				INNER JOIN VRCustLockStatus l1 WITH(NOLOCK) ON t.custID = l1.CustID AND l1.Type = 1
				INNER JOIN VRCustLockStatus l2 WITH(NOLOCK) ON t.custID = l2.CustID AND l2.Type = 2
				INNER JOIN VRCustLockStatus l3 WITH(NOLOCK) ON t.custID = l3.CustID AND l3.Type = 3			
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;

				--> Update Soccer VR
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
						FROM @virtualXML_Soccer	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 1
					)

				--> Update Basketball VR												
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
						FROM @virtualXML_Basketball	AS tmp								
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm			
						WHERE cvs.seqNo = tmp.seqNo										
					) bm																
				 WHERE	NOT EXISTS (													
						SELECT	1														
						FROM	VRCustLockStatus lm WITH(NOLOCK)						
						WHERE	lm.custID = tmpCust.custid 								
								AND lm.Type = 3											
					)																	

				--> Update OtherSport VR
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
						FROM @virtualXML_OS	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 2
					)
			END	
			
			--> Update for new accounts
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_Soccer			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.mrecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 1
					)

			UPDATE cvs																		
			SET cvs.bitmapVirtual = bm.bitmap												
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)					
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)								
					ON	ci.custid = cvs.custid												
			INNER JOIN	@virtualXML_Basketball			AS tmp								
					ON	cvs.seqNo = tmp.seqNo												
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm		
			WHERE	ci.mrecommend = @custid													
				AND ci.custID > @maxcustid													
				AND	NOT EXISTS (															
						SELECT	1															
						FROM	VRCustLockStatus lm WITH(NOLOCK)							
						WHERE	lm.custID = ci.custid 										
								AND lm.Type = 3												
					)																		

			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_OS			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.mrecommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 2
					)
		END;
		ELSE IF @roleid = 2
		BEGIN
			DELETE #tblCustVR

			INSERT INTO #tblCustVR(custID)
			SELECT ci.custid
			FROM dbo.custInfo ci WITH (NOLOCK)
			WHERE	ci.recommend = @custid  AND ci.custid <> @custid

			SELECT @maxcustid = ISNULL(MAX(custID),0)
			FROM #tblCustVR
			
			--> not scan to update for downline with have VR status Locked all sports
			DELETE t
			FROM #tblCustVR t
				INNER JOIN VRCustLockStatus l1 WITH(NOLOCK) ON t.custID = l1.CustID AND l1.Type = 1
				INNER JOIN VRCustLockStatus l2 WITH(NOLOCK) ON t.custID = l2.CustID AND l2.Type = 2
				INNER JOIN VRCustLockStatus l3 WITH(NOLOCK) ON t.custID = l3.CustID AND l3.Type = 3		
			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR
				
				DELETE TOP (@batchUpdate) t
				OUTPUT DELETED.custid INTO #tmpCustBatchVR
				FROM #tblCustVR t
				
				IF @@rowcount = 0 
					BREAK;
				
				--> Update Soccer VR
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
						FROM @virtualXML_Soccer	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 1
					)

				--> Update Basketball VR												
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
						FROM @virtualXML_Basketball	AS tmp								
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm		
						WHERE cvs.seqNo = tmp.seqNo										
					) bm																
				 WHERE	NOT EXISTS (													
						SELECT	1														
						FROM	VRCustLockStatus lm WITH(NOLOCK)						
						WHERE	lm.custID = tmpCust.custid 								
								AND lm.Type = 3											
					)																	

				--> Update OtherSport VR
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
						FROM @virtualXML_OS	AS tmp
							CROSS APPLY dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos) AS bm
						WHERE cvs.seqNo = tmp.seqNo
					) bm
				 WHERE	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = tmpCust.custid 
								AND lm.Type = 2
					)
			END	
			
			--> Update for new accounts
			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_Soccer			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.recommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 1
					)

			UPDATE cvs																
			SET cvs.bitmapVirtual = bm.bitmap										
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)			
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)						
					ON	ci.custid = cvs.custid										
			INNER JOIN	@virtualXML_Basketball			AS tmp						
					ON	cvs.seqNo = tmp.seqNo										
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm		
			WHERE	ci.recommend = @custid											
				AND ci.custID > @maxcustid											
				AND	NOT EXISTS (													
						SELECT	1													
						FROM	VRCustLockStatus lm WITH(NOLOCK)					
						WHERE	lm.custID = ci.custid 								
								AND lm.Type = 3										
					)																

			UPDATE cvs
			SET cvs.bitmapVirtual = bm.bitmap
			FROM		CustVirtualSetting	AS cvs WITH (UPDLOCK, ROWLOCK)
			INNER JOIN	custInfo			AS ci WITH (NOLOCK)
					ON	ci.custid = cvs.custid
			INNER JOIN	@virtualXML_OS			AS tmp
					ON	cvs.seqNo = tmp.seqNo
			CROSS APPLY (SELECT TOP 1 bitmap FROM dbo.f_GenerateVirtualSetting_inline(cvs.bitmapVirtual, tmp.Val, tmp.Pos)) AS bm
			WHERE	ci.recommend = @custid
				AND ci.custID > @maxcustid
				AND	NOT EXISTS (
						SELECT	1
						FROM	VRCustLockStatus lm WITH(NOLOCK)
						WHERE	lm.custID = ci.custid 
								AND lm.Type = 2
					)
		END;
	END;

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
		    WHERE	srecommend = @custid
					AND (closed <> @Closed OR closed IS NULL)
	    END;
	    ELSE IF @RoleID = 3 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed 
			output INSERTED.custid into #tempCust
		    WHERE	mrecommend = @custid
					AND (closed <> @Closed OR closed IS NULL)	
	    END;
	    ELSE IF @RoleID = 2 
	    BEGIN
		    UPDATE	custinfo WITH (ROWLOCK, UPDLOCK) 
		    SET		closed = @closed 
			output INSERTED.custid into #tempCust
		    WHERE	recommend = @custid
					AND (closed <> @Closed OR closed IS NULL)	
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

    else if @Action = 'AutoSuspend'
    BEGIN
	    IF @roleID = 4 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END
		    WHERE srecommend = @custID; 
	    END;

	    IF @roleID = 3 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END
		    WHERE mrecommend = @custID; 
	    END;

	    IF @roleID = 2 
	    BEGIN
		    UPDATE custinfo WITH (ROWLOCK,UPDLOCK)	
		    SET	autosuspend2 = CASE WHEN @IsUpdateAutoSuspendOtherSports = 1 THEN @AutoSuspendOtherSports ELSE autosuspend2 END, 
			    autosuspend = CASE WHEN @IsUpdateAutoSuspendSoccer = 1 THEN @AutoSuspendSoccer ELSE autosuspend END,
				autosuspend3 = CASE WHEN @IsUpdateAutoSuspendBasketball = 1 THEN @AutoSuspendBasketball ELSE autosuspend3 END
		    WHERE recommend = @custID; 
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
		SELECT ss.value
		FROM @tblEnableVirtualrate AS tv
			CROSS APPLY	STRING_SPLIT(tv.CustIDs, ',') AS ss							

		UPDATE	dbo.custInfo WITH (ROWLOCK, UPDLOCK)
		SET	virtualmultiplier = 1
		FROM custInfo
		WHERE custid IN (SELECT custID FROM #tblCustomer)
	END

	ELSE IF @action = 'ApplyVRAccBalanceAllDownlines' 
	BEGIN
		IF dbo.f_CheckRepTable('VRCustLockStatus') = 1	
		BEGIN
			
			CREATE TABLE #TblCustDownline_VRAccBalance			(custID INT)
			CREATE TABLE #TblCustDownline_tmpBatch_VRAccBalance (CustID INT PRIMARY KEY)	
			DECLARE @VRAccBalance_batchUpdate INT = 5000
		
			IF @roleid = 4
			BEGIN
				INSERT INTO #TblCustDownline_VRAccBalance(custID)
				SELECT c.custid
				FROM CustInfo c WITH (NOLOCK)
				WHERE c.srecommend = @custid
					AND c.Enabled = 1
			END
			ELSE IF @roleid = 3
			BEGIN
				INSERT INTO #TblCustDownline_VRAccBalance(custID)
				SELECT c.custid
				FROM CustInfo c WITH (NOLOCK)
				WHERE c.mrecommend = @custid
					AND c.Enabled = 1
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #TblCustDownline_VRAccBalance(custID)
				SELECT c.custid
				FROM CustInfo c WITH (NOLOCK)
				WHERE c.recommend = @custid
					AND c.Enabled = 1
			END

			IF NOT EXISTS( SELECT TOP 1 1 FROM #TblCustDownline_VRAccBalance)
				RETURN

			IF @VRAccumulate_Balance = 0
			BEGIN
				WHILE(1=1)
				BEGIN
					TRUNCATE TABLE #TblCustDownline_tmpBatch_VRAccBalance
				
					DELETE TOP (@VRAccBalance_batchUpdate) t
					OUTPUT DELETED.custid INTO #TblCustDownline_tmpBatch_VRAccBalance
					FROM #TblCustDownline_VRAccBalance t
				
					IF @@rowcount = 0 
						BREAK;

					DELETE vr
					FROM VRCustLockStatus vr WITH (ROWLOCK, UPDLOCK)
					INNER JOIN #TblCustDownline_tmpBatch_VRAccBalance tmp ON vr.CustID = tmp.CustID
					WHERE vr.Type = 4
				END		
			END

			ELSE
			BEGIN
				WHILE(1=1)
				BEGIN
					TRUNCATE TABLE #TblCustDownline_tmpBatch_VRAccBalance
				
					DELETE TOP (@VRAccBalance_batchUpdate) tem
					OUTPUT DELETED.custid INTO #TblCustDownline_tmpBatch_VRAccBalance
					FROM #TblCustDownline_VRAccBalance tem WITH (NOLOCK)
					WHERE NOT EXISTS (SELECT 1 FROM VRCustLockStatus vr WITH (NOLOCK) WHERE vr.CustID = tem.custID AND vr.Type = 4) 
				
					IF @@rowcount = 0 
						BREAK;

					INSERT INTO VRCustLockStatus (CustID , Type)
					SELECT CustID , 4
					FROM #TblCustDownline_tmpBatch_VRAccBalance
				END		
			END

			DROP TABLE #TblCustDownline_VRAccBalance	
			DROP TABLE #TblCustDownline_tmpBatch_VRAccBalance
		
		END
	END

	ELSE IF @Action = 'EnableVRLockStatus'--execrep just use for enable 
	BEGIN
		--IF OBJECT_ID (N'VRCustLockStatus', N'U') IS NOT NULL --check table is existing ?
		IF dbo.f_CheckRepTable('VRCustLockStatus') = 1
		BEGIN
			CREATE TABLE #TblCustDownline (custID INT)
			CREATE TABLE #TblCustDownline_tmpBatch (CustID INT PRIMARY KEY)	
			DECLARE @VRlock_batchUpdate INT = 5000
			CREATE TABLE #TblType (Type TINYINT)

			IF @VRlockStatusType = 0
			BEGIN
				INSERT INTO #TblType (Type)
				SELECT 1	UNION ALL		--soccer
				SELECT 2	UNION ALL		--Other sports			
				SELECT 3					--Basketball			
			END
			ELSE IF @VRlockStatusType = 1
			BEGIN
				INSERT INTO #TblType (Type)
				SELECT 1  --soccer
			END
			ELSE IF @VRlockStatusType = 2
			BEGIN
				INSERT INTO #TblType (Type)
				SELECT 2  --Other sports
			END
			ELSE IF @VRlockStatusType = 3			
			BEGIN								
				INSERT INTO #TblType (Type)		
				SELECT 3  --Basketball			
			END	
		
			ELSE
			BEGIN
				RETURN
			END

			--> Insert for main account
			INSERT INTO VRCustLockStatus(CustID,Type)
			SELECT @custid,Type
			FROM #TblType t
			WHERE NOT EXISTS ( SELECT 1 FROM VRCustLockStatus WITH(NOLOCK) WHERE custid = @custid and Type = t.Type)

			--Process locked for downline by batch update
			IF @roleid = 4
			BEGIN
				INSERT INTO #TblCustDownline(custID)
				SELECT ci.custid
				FROM dbo.custInfo ci WITH (NOLOCK)
				WHERE	ci.srecommend = @custid AND ci.custid <> @custid
			END
			ELSE IF @roleid = 3
			BEGIN
				INSERT INTO #TblCustDownline(custID)
				SELECT ci.custid
				FROM dbo.custInfo ci WITH (NOLOCK)
				WHERE ci.mrecommend = @custid AND ci.custid <> @custid
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #TblCustDownline(custID)
				SELECT ci.custid
				FROM dbo.custInfo ci WITH (NOLOCK)
				WHERE ci.recommend = @custid AND ci.custid <> @custid
			END

			IF NOT EXISTS( SELECT TOP 1 1 FROM #TblCustDownline)
				RETURN

			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #TblCustDownline_tmpBatch
				
				DELETE TOP (@VRlock_batchUpdate) t
				OUTPUT DELETED.custid INTO #TblCustDownline_tmpBatch
				FROM #TblCustDownline t
				
				IF @@rowcount = 0 
					BREAK;

				INSERT INTO VRCustLockStatus(CustID,Type)
				SELECT t.CustID,tp.Type
				FROM  #TblCustDownline_tmpBatch t
					CROSS JOIN #TblType tp
					LEFT JOIN VRCustLockStatus v WITH(NOLOCK) ON t.CustID = v.CustID AND tp.Type = v.Type
				WHERE v.CustID IS NULL
			END		
			
			DROP TABLE #TblCustDownline	
			DROP TABLE #TblCustDownline_tmpBatch
			DROP TABLE #TblType
		END
	END
	
	ELSE IF @Action IN ('EnableVRDownline', 'UnlockVRDownline')
	BEGIN
		IF @RoleID = 1 
			RETURN

		CREATE TABLE #tblCustVR_Additional (custID INT, type TINYINT)
		CREATE TABLE #tmpCustBatchVR_Additional (CustID INT, type TINYINT)	
		DECLARE @batchUpdate_Additional INT = 5000,
				@maxcustid_Additional INT

		DECLARE	@RoleID_Unlock3_SC		TINYINT,
				@RoleID_Unlock2_SC		TINYINT,
				@RoleID_Unlock1_SC		TINYINT,

				@RoleID_Unlock3_BB		TINYINT,
				@RoleID_Unlock2_BB		TINYINT,
				@RoleID_Unlock1_BB		TINYINT,

				@RoleID_Unlock3_OS		TINYINT,
				@RoleID_Unlock2_OS		TINYINT,
				@RoleID_Unlock1_OS		TINYINT,

				@RoleID_Enable3		TINYINT,
				@RoleID_Enable2		TINYINT,
				@RoleID_Enable1		TINYINT
		DECLARE @DocHandler_EnableUnlockVR INT
		EXEC sp_xml_preparedocument @DocHandler_EnableUnlockVR OUTPUT, @AdditionalActions

		SELECT
					@RoleID_Unlock3_SC = CASE WHEN @roleid = 4			AND Data.UnlockSC3 = 1 THEN 3 ELSE 0 END,
					@RoleID_Unlock2_SC = CASE WHEN @roleid IN (4,3)		AND Data.UnlockSC2 = 1 THEN 2 ELSE 0 END,
					@RoleID_Unlock1_SC = CASE WHEN @roleid IN (4,3,2)	AND Data.UnlockSC1 = 1 THEN 1 ELSE 0 END,

					@RoleID_Unlock3_BB = CASE WHEN @roleid = 4			AND Data.UnlockBB3 = 1 THEN 3 ELSE 0 END,
					@RoleID_Unlock2_BB = CASE WHEN @roleid IN (4,3)		AND Data.UnlockBB2 = 1 THEN 2 ELSE 0 END,
					@RoleID_Unlock1_BB = CASE WHEN @roleid IN (4,3,2)	AND Data.UnlockBB1 = 1 THEN 1 ELSE 0 END,

					@RoleID_Unlock3_OS = CASE WHEN @roleid = 4			AND Data.UnlockOS3 = 1 THEN 3 ELSE 0 END,
					@RoleID_Unlock2_OS = CASE WHEN @roleid IN (4,3)		AND Data.UnlockOS2 = 1 THEN 2 ELSE 0 END,
					@RoleID_Unlock1_OS = CASE WHEN @roleid IN (4,3,2)	AND Data.UnlockOS1 = 1 THEN 1 ELSE 0 END,

					@RoleID_Enable3 = CASE WHEN @roleid = 4			AND Data.Enable3 = 1 THEN 3 ELSE 0 END,
					@RoleID_Enable2 = CASE WHEN @roleid IN (4,3)	AND Data.Enable2 = 1 THEN 2 ELSE 0 END,
					@RoleID_Enable1 = CASE WHEN @roleid IN (4,3,2)	AND Data.Enable1 = 1 THEN 1 ELSE 0 END
		FROM OPENXML (@DocHandler_EnableUnlockVR, '/ROOT/VR',1) 
		WITH (
			UnlockSC3		BIT,
			UnlockSC2		BIT,
			UnlockSC1		BIT,

			UnlockBB3		BIT,
			UnlockBB2		BIT,
			UnlockBB1		BIT,

			UnlockOS3		BIT,
			UnlockOS2		BIT,
			UnlockOS1		BIT,

			Enable3		BIT,
			Enable2		BIT,
			Enable1		BIT
		) AS Data

		EXEC sp_xml_removedocument @DocHandler_EnableUnlockVR

		DECLARE @BetTradeAccount1 TABLE (CustID INT)

		IF @action = 'EnableVRDownline'
			AND NOT(@RoleID_Enable1 = 0 AND @RoleID_Enable2 = 0 AND @RoleID_Enable3 = 0 ) 
		BEGIN
			IF( dbo.f_CheckRepTable('Customer') = 1 AND dbo.f_CheckRepTable('BetTradeCust') = 1)
			BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM Customer c WITH(NOLOCK) WHERE custid = @custid AND site IN ('TLC', 'asiabet88'))
				BEGIN
					IF @roleid = 4 
					BEGIN
						INSERT INTO @BetTradeAccount1 (CustID)
						SELECT c.Custid  
						FROM Customer c WITH(NOLOCK)
							INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
						WHERE c.srecommend = @custid 
					END
					ELSE IF @roleid = 3
					BEGIN
						INSERT INTO @BetTradeAccount1 (CustID)
						SELECT c.Custid  
						FROM Customer c WITH(NOLOCK)
							INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
						WHERE c.mrecommend = @custid 
					END
					ELSE IF @roleid = 2
					BEGIN
						INSERT INTO @BetTradeAccount1 (CustID)
						SELECT c.Custid  
						FROM Customer c WITH(NOLOCK)
							INNER JOIN BetTradeCust b WITH(NOLOCK) ON c.custid=b.custid
						WHERE c.recommend = @custid 
					END
				END
			END
	
			IF( dbo.f_CheckRepTable('Customer') = 1 AND dbo.f_CheckRepTable('TradeCust') = 1 )
			BEGIN	
				IF @roleid = 4 
				BEGIN
					INSERT INTO @BetTradeAccount1 (CustID)
					SELECT c.Custid  
					FROM Customer c WITH(NOLOCK)
						INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
					WHERE c.srecommend = @custid 
				END
				ELSE IF @roleid = 3
				BEGIN
					INSERT INTO @BetTradeAccount1 (CustID)
					SELECT c.Custid  
					FROM Customer c WITH(NOLOCK)
						INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
					WHERE c.mrecommend = @custid 
				END
				ELSE IF @roleid = 2
				BEGIN
					INSERT INTO @BetTradeAccount1 (CustID)
					SELECT c.Custid  
					FROM Customer c WITH(NOLOCK)
						INNER JOIN TradeCust b WITH(NOLOCK) ON c.custid=b.custid
					WHERE c.recommend = @custid 		
				END
			END
	
			IF	dbo.f_CheckRepTable('custinfo') = 1
			BEGIN
				SET @batchUpdate_Additional = 5000--for update custinfo
				IF	@roleid = 4
				BEGIN			
					DELETE #tblCustVR_Additional
			
					INSERT INTO #tblCustVR_Additional(custID)
					SELECT custid
					FROM dbo.custInfo ci WITH (NOLOCK)
					WHERE	ci.srecommend = @custid
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)
					AND ci.roleid IN (@RoleID_Enable1,@RoleID_Enable2,@RoleID_Enable3)
					
					SELECT @maxcustid_Additional = MAX(custID)
					FROM #tblCustVR_Additional
			
					WHILE(1=1)
					BEGIN
						TRUNCATE TABLE #tmpCustBatchVR_Additional
				
						DELETE TOP (@batchUpdate_Additional) t
						OUTPUT DELETED.custid INTO #tmpCustBatchVR_Additional(CustID)
						FROM #tblCustVR_Additional t
				
						IF @@rowcount = 0 
							BREAK;
					
						UPDATE	ci
						SET	ci.virtualmultiplier = 1
						FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
						WHERE custID IN (SELECT custID FROM #tmpCustBatchVR_Additional)
							AND ci.VirtualMultiplier = 0
					END	
			
					--update newly customer if any
					UPDATE	ci
					SET	ci.virtualmultiplier = 1
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE	ci.srecommend = @custid
					AND ci.custid > @maxcustid_Additional
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)	
					AND ci.roleid IN (@RoleID_Enable1,@RoleID_Enable2,@RoleID_Enable3)
					AND ci.VirtualMultiplier = 0

				END;
				ELSE IF	@roleid = 3
				BEGIN			
					DELETE #tblCustVR_Additional
			
					INSERT INTO #tblCustVR_Additional(custID)
					SELECT custid
					FROM dbo.custInfo ci WITH (NOLOCK)
					WHERE	ci.mrecommend = @custid
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)
					AND ci.roleid IN (@RoleID_Enable1,@RoleID_Enable2)
					
					SELECT @maxcustid_Additional = MAX(custID)
					FROM #tblCustVR_Additional
			
					WHILE(1=1)
					BEGIN
						TRUNCATE TABLE #tmpCustBatchVR_Additional
				
						DELETE TOP (@batchUpdate_Additional) t
						OUTPUT DELETED.custid INTO #tmpCustBatchVR_Additional(CustID)
						FROM #tblCustVR_Additional t
				
						IF @@rowcount = 0 
							BREAK;
					
						UPDATE	ci
						SET	ci.virtualmultiplier = 1
						FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
						WHERE custID IN (SELECT custID FROM #tmpCustBatchVR_Additional)
							AND ci.VirtualMultiplier = 0
					END	
			
					--update newly customer if any
					UPDATE	ci
					SET	ci.virtualmultiplier = 1
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE	ci.mrecommend = @custid
					AND ci.custid > @maxcustid_Additional
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)	
					AND ci.roleid IN (@RoleID_Enable1,@RoleID_Enable2)
					AND ci.VirtualMultiplier = 0

				END;
				ELSE IF	@roleid = 2
				BEGIN			
					DELETE #tblCustVR_Additional
			
					INSERT INTO #tblCustVR_Additional(custID)
					SELECT custid
					FROM dbo.custInfo ci WITH (NOLOCK)
					WHERE	ci.recommend = @custid
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)
					AND ci.roleid IN (@RoleID_Enable1)
					
					SELECT @maxcustid_Additional = MAX(custID)
					FROM #tblCustVR_Additional
			
					WHILE(1=1)
					BEGIN
						TRUNCATE TABLE #tmpCustBatchVR_Additional
				
						DELETE TOP (@batchUpdate_Additional) t
						OUTPUT DELETED.custid INTO #tmpCustBatchVR_Additional(CustID)
						FROM #tblCustVR_Additional t
				
						IF @@rowcount = 0 
							BREAK;
					
						UPDATE	ci
						SET	ci.virtualmultiplier = 1
						FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
						WHERE custID IN (SELECT custID FROM #tmpCustBatchVR_Additional)
							AND ci.VirtualMultiplier = 0
					END	
			
					--update newly customer if any
					UPDATE	ci
					SET	ci.virtualmultiplier = 1
					FROM dbo.custInfo ci WITH (ROWLOCK, UPDLOCK)
					WHERE	ci.recommend = @custid
					AND ci.custid > @maxcustid_Additional
					AND	NOT EXISTS (
								SELECT	1
								FROM	@BetTradeAccount1 AS lm
								WHERE	lm.custID = ci.custid
							)	
					AND ci.roleid IN (@RoleID_Enable1)
					AND ci.VirtualMultiplier = 0

				END;
			END;
		END
		ELSE IF @action = 'UnlockVRDownline' AND dbo.f_CheckRepTable('VRCustLockStatus') = 1
		BEGIN
			CREATE TABLE #unlockTempCust(custid INT, roleid TINYINT)

			TRUNCATE TABLE #tblCustVR_Additional

			IF @roleid = 4
			BEGIN	
				INSERT INTO #unlockTempCust(custid, roleid)
				SELECT c.custid, c.roleid
				FROM custInfo c WITH (NOLOCK)
				WHERE c.srecommend = @custid

				INSERT INTO #tblCustVR_Additional(custID, type)
				SELECT t.custid, 1 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_SC, @RoleID_Unlock2_SC, @RoleID_Unlock3_SC)
				UNION ALL
				SELECT t.custid, 3 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_BB, @RoleID_Unlock2_BB, @RoleID_Unlock3_BB)
				UNION ALL
				SELECT t.custid, 2 AS type
				FROM  #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_OS, @RoleID_Unlock2_OS, @RoleID_Unlock3_OS)
			END

			ELSE IF @roleid = 3
			BEGIN
				INSERT INTO #unlockTempCust(custid, roleid)
				SELECT c.custid, c.roleid
				FROM custInfo c WITH (NOLOCK)
				WHERE c.mrecommend = @custid

				INSERT INTO #tblCustVR_Additional(custID, type)
				SELECT t.custid, 1 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_SC, @RoleID_Unlock2_SC)
				UNION ALL
				SELECT t.custid, 3 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_BB, @RoleID_Unlock2_BB)
				UNION ALL
				SELECT t.custid, 2 AS type
				FROM  #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid IN (@RoleID_Unlock1_OS, @RoleID_Unlock2_OS)
			END

			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #unlockTempCust(custid, roleid)
				SELECT c.custid, c.roleid
				FROM custInfo c WITH (NOLOCK)
				WHERE c.recommend = @custid

				INSERT INTO #tblCustVR_Additional(custID, type)
				SELECT t.custid, 1 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid = @RoleID_Unlock1_SC
				UNION ALL
				SELECT t.custid, 3 AS type
				FROM #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid = @RoleID_Unlock1_BB
				UNION ALL
				SELECT t.custid, 2 AS type
				FROM  #unlockTempCust t WITH (NOLOCK)
				WHERE t.roleid = @RoleID_Unlock1_OS
			END

			SET @batchUpdate_Additional = 2000

			WHILE(1=1)
			BEGIN
				TRUNCATE TABLE #tmpCustBatchVR_Additional
				
				DELETE TOP (@batchUpdate_Additional) t
				OUTPUT deleted.custid, deleted.type INTO #tmpCustBatchVR_Additional(CustID, type)
				FROM #tblCustVR_Additional t
				
				IF @@rowcount = 0 
					BREAK;
					
				DELETE c
				FROM VRCustLockStatus c WITH(ROWLOCK)
					INNER JOIN #tmpCustBatchVR_Additional t
						ON c.CustID = t.CustID AND c.Type = t.type
			END	
			DROP TABLE #unlockTempCust
		END

		DROP TABLE #tmpCustBatchVR_Additional
		DROP TABLE #tblCustVR_Additional
	END
	ELSE IF @Action = ('DisableVR2Downline')
	BEGIN
		IF dbo.f_CheckRepTable('VRSettingManualUpdAcc') = 0 RETURN
		IF dbo.f_CheckRepTable('VRCustSetting') = 0 RETURN
		IF dbo.f_CheckRepTable('CustSettingAutoSuspend') = 0 RETURN

		CREATE TABLE #tmpCustVR2Downline (CustID INT PRIMARY KEY,RoleID TINYINT)

		--> Get all downline of direct account
		IF @RoleId = 4
		BEGIN
			INSERT INTO #tmpCustVR2Downline(CustID,roleid)
			SELECT ci.custid,ci.roleid
			FROM custinfo ci WITH(NOLOCK)
			WHERE ci.roleid IN (1,2,3)
				AND ci.srecommend = @CustId
				AND ci.enabled = 1
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #tmpCustVR2Downline(CustID,roleid)
			SELECT ci.custid,ci.roleid
			FROM custinfo ci WITH(NOLOCK)
			WHERE ci.roleid IN (1,2)
				AND ci.mrecommend = @CustId
				AND ci.enabled = 1
		END
		ELSE IF @RoleId = 2
		BEGIN
			INSERT INTO #tmpCustVR2Downline(CustID,roleid)
			SELECT ci.custid,ci.roleid
			FROM custinfo ci WITH(NOLOCK)
			WHERE ci.roleid IN (1)
				AND ci.recommend = @CustId
				AND ci.enabled = 1
		END

		--Set Manual VR for all downline
		WHILE 1 = 1
		BEGIN
			INSERT INTO [VRSettingManualUpdAcc](CustID,SportType)
			SELECT TOP (5000) t.CustID, @Sporttype AS SportType
			FROM #tmpCustVR2Downline t
				LEFT JOIN [VRSettingManualUpdAcc] v WITH(NOLOCK)
					ON t.CustID = v.CustID 
					AND v.SportType = @Sporttype
			WHERE v.CustID IS NULL

			IF @@ROWCOUNT = 0
				BREAK;
		END

		DECLARE @VRCustSetting TABLE (CustID int, LevelID int)
		DECLARE @VRCustSettingBatch TABLE (CustID int, LevelID int)

		DeletePrivateVR: --Step Delete all private VR of Master/Agent/Member

		INSERT INTO @VRCustSetting(CustID,LevelID)
		SELECT vr.CustID,vr.LevelID
		FROM VRCustSetting vr WITH(NOLOCK)
			INNER JOIN VRSettingHierarchy h WITH(NOLOCK) ON vr.LevelID = h.LevelID
			INNER JOIN #tmpCustVR2Downline t ON vr.CustID = t.CustID
		WHERE h.SportType = @Sporttype
		ORDER by vr.CustID,VR.LevelID

		--Delete all private VR of Master/Agent/Member( VR will follow  their Super)
		WHILE 1 = 1
		BEGIN
			DELETE FROM @VRCustSettingBatch

			DELETE TOP(5000) t
			OUTPUT deleted.CustID,deleted.LevelID INTO @VRCustSettingBatch(CustID,LevelID)
			FROM @VRCustSetting t

			IF @@ROWCOUNT = 0
				BREAK;

			DELETE vr
			FROM VRCustSetting vr WITH(ROWLOCK,UPDLOCK)
				INNER JOIN @VRCustSettingBatch t 
					ON vr.CustID = t.CustID
					AND vr.LevelID = t.LevelID
		END

		IF EXISTS(
			SELECT TOP 1 1
			FROM VRCustSetting vr WITH(NOLOCK)
				INNER JOIN VRSettingHierarchy h WITH(NOLOCK) ON vr.LevelID = h.LevelID
				INNER JOIN #tmpCustVR2Downline t ON vr.CustID = t.CustID
			WHERE h.SportType = @Sporttype
		)
		BEGIN
			PRINT 'Delete Again'
			GOTO DeletePrivateVR --Delete Again
		END

		--Set OverrideAS = 1 ( Esport Level) for all members
		IF @Sporttype = 43
		BEGIN
			IF @roleid = 1
			BEGIN
				INSERT INTO #tmpCustVR2Downline(CustID,roleid)
				SELECT @custid, 1
			END

			DECLARE @OverrideAS_True varbinary(128)  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

			WHILE 1 = 1
			BEGIN
				UPDATE TOP (5000) v
				SET OverrideASLive = @OverrideAS_True
					,OverrideASNonLive = @OverrideAS_True
				FROM #tmpCustVR2Downline t
					INNER JOIN CustSettingAutoSuspend v WITH(NOLOCK)
						ON t.CustID = v.CustID 
						AND v.SportType = @Sporttype
				WHERE t.roleid = 1
				AND NOT(  
						OverrideASLive = @OverrideAS_True
						AND OverrideASNonLive = @OverrideAS_True
					)

				IF @@ROWCOUNT = 0
					BREAK;
			END

			WHILE 1 = 1
			BEGIN
				INSERT INTO CustSettingAutoSuspend(CustID,SportType,AutoSuspendLive,AutoSuspendNonLive,OverrideASLive,OverrideASNonLive)
				SELECT TOP (5000) t.CustID, @Sporttype AS SportType, @OverrideAS_True, @OverrideAS_True, @OverrideAS_True, @OverrideAS_True
				FROM #tmpCustVR2Downline t
					LEFT JOIN CustSettingAutoSuspend v WITH(NOLOCK)
						ON t.CustID = v.CustID 
						AND v.SportType = @Sporttype
				WHERE v.CustID IS NULL
					AND t.roleid = 1

				IF @@ROWCOUNT = 0
					BREAK;
			END	
		END
		DROP TABLE #tmpCustVR2Downline
	END
END

GO
