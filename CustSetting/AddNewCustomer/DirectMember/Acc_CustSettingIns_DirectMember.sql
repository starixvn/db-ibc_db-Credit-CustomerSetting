/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSettingIns_DirectMember]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@UplineRoleID TINYINT = NULL,
	@roleid INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	@SystemID TINYINT=1,
	@ugroup	VARCHAR(5) = NULL,
	@SettingXML VARCHAR(MAX) = '',
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
AS
/*
	Created: 20241107@Eden	
	Task: Insert member setting when Super/Master create direct member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
		- 20250421@Eden: HF - wrong PT of new direct member [redmine: #224900] 
		- 20250528@Johnson: Add potential win limit setting for direct member [redmine: #226060]	
		- 20250611@Johnson: update potential win limit setting for direct member [redmine: #226060]
		- 20250801@Johnson: Include Parlay for Potential Win Limit [RedmineID: #233805]
	Parameter's Explanation:
	- @SettingXML:
		'{
			--Commission:
			"150": [
				{"SportType": "1","BetType": "1","Discount": "0.0010000"},
				{"SportType": "1","BetType": "5","Discount": "0.0030000"},
				{"SportType": "1","BetType": "4","Discount": "0.0035000"}
			],
			"156": [
				{"SportType": "9911","BetType": "2400","Discount": "0.0035000"},
				{"SportType": "175","BetType": "7901","Discount": "0.0025000"}
			],

			--BetSetting:
			"151": [
				{"SportType": "1","BetType": "9","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "2","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "9902","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "1","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "9901","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "11","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "99","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "3","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "5","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "8","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "10","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "99","BetType": "9","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "43","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10"},
				{"SportType": "44","BetType": "3","MinBet": "0","MaxBet": "0","MPM": "0"}
			],
			"154": [
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			],

			--Parlay Maxpayout:
			"152": [
				{"SportType": "99","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"},
				{"SportType": "1","BetType": "9","SingleMP": "31000","Combo2": "47000","Combo35": "157000","Combo6": "628000"}
        
			],

			--PT:
			"153": [
				{"SportType": "9914","BetType": "915","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "917","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "917","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9915","BetType": "918","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "915","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9913","BetType": "916","IsLive": "1"	,"SuperPT": "38"},
				{"SportType": "9914","BetType": "916","IsLive": "0"	,"SuperPT": "38"},
				{"SportType": "9906","BetType": "4001","IsLive": "0","SuperPT": "38"},
				{"SportType": "9909","BetType": "3700","IsLive": "0","SuperPT": "38"},
				{"SportType": "9911","BetType": "2400","IsLive": "0","SuperPT": "38"},
				{"SportType": "9918","BetType": "4601","IsLive": "0","SuperPT": "38"}

			],

			--Winloss Limit:
			"155": [
					{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }

				],

			--Stake Level:
			"158": [
					{"SportType": "159","BetType": "3151","StakeLevelList": "3151"},
					{"SportType": "211","BetType": "2401","StakeLevelList": "3151"}
				],

			--Product Status:
			"160": [
					{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
					{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
					{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
				],

			--Potential Win Limit:
			"162": [
				{"SportType": "0","BetType": "0","WinLimit": "0","IsAutoReset":"1","IncludeParlay":"0"}
			]
		}'	
	
*/	
BEGIN
	SET NOCOUNT ON
	
	SELECT @ErrCode = 0
	DECLARE @UplineID INT
	DECLARE @xmlStrDisabled XML
	DECLARE @xmlStrHidden XML
	DECLARE @xmlStrSync XML
	
	CREATE TABLE #ProductSettingDetail_tmp00(
		[SettingType] [smallint] ,
		[SportType] [smallint] ,
		[BetType] [smallint] ,
		[IsLive] [bit] ,
		[ProductID] [tinyint] ,
		[MaxPT] [smallmoney] ,
		[MaxDiscount] [decimal](9, 8) ,
		[IsSync] [bit] ,
		[IsHidden] [bit] ,
		[IsDisabled] [bit] ,
		[SettingLevel] [tinyint] ,
		[DisplayOrder] [tinyint] ,
		[SettingStatus] [tinyint] ,
		[IntervalValue] [decimal](19, 8) ,
		[RealProductId] [tinyint] ,
		[MaxChoice] [tinyint] ,
		[ProductSettingID] [int] ,
		[Parent_ProductSettingID] [int] ,
		[Child_DisplayOrder] [int] ,
		SubType [TINYINT],
		GroupType [TINYINT],
		IsFollowUpline [TINYINT] DEFAULT (0),
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_tmp00(SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
		,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType,GroupType)
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
			,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType,GroupType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)

	CREATE TABLE #ProductSettingSiteDisplay(ProductID TINYINT, SettingType SMALLINT,SystemID TINYINT,DisplayMode TINYINT)    
  
	INSERT INTO #ProductSettingSiteDisplay(ProductID,SettingType,SystemID,DisplayMode)    
	SELECT ProductID,SettingType,SystemID,DisplayMode  
	FROM dbo.ProductSettingSystemDisplay WITH(NOLOCK)    
	WHERE SystemID = @SystemID 

	--Update IsFollowUpline, if displaymode = 3 (hidden on UI) , or not depent any grouptype, or Number Games --> setting follow upline
	UPDATE p
	SET p.IsFollowUpline = 1
	FROM #ProductSettingDetail_tmp00 p WITH(NOLOCK)     
		INNER JOIN #ProductSettingSiteDisplay dpl    
			ON dpl.SettingType = p.SettingType    
			AND dpl.ProductID = p.ProductID 
			AND dpl.DisplayMode = 3

	UPDATE p
	SET p.IsFollowUpline = 1
	FROM #ProductSettingDetail_tmp00 p WITH(NOLOCK)     
	WHERE GroupType IS NULL

	UPDATE p
	SET p.IsFollowUpline = 1
	FROM #ProductSettingDetail_tmp00 p WITH(NOLOCK)     
	WHERE GroupType = 160 
		AND SportType = 161
		AND Bettype = 81
		
	IF (@UplineRoleID = 4) 
		SET @UplineID = @srecommend
	ELSE IF (@UplineRoleID = 3)
		SET @UplineID = @mrecommend	

	
	/*********************** Product Status: GroupType = 160 **************************/
	BEGIN TRY
		DECLARE @SportBettypeStatus TABLE (SportType SMALLINT, Bettype SMALLINT, bitmapOrder TINYINT)
		--Get sporttype/Bettype for Status which do not follow upline
		INSERT INTO @SportBettypeStatus(SportType,Bettype,bitmapOrder)
		SELECT DISTINCT psd.SportType,psd.Bettype,pbs.bitmapOrder 
		FROM #ProductSettingDetail_tmp00 psd WITH(NOLOCK)  
			INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.[SportType] = psd.[SportType]	AND pbs.[BetType] = psd.[BetType]
		WHERE psd.GroupType = 160
			AND psd.IsFollowUpline = 0

		INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,RepUpdateTime)
		SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced,cs.SuspendInfo,cs.CloseInfo,dbo.f_GetDateTime2()
		FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
		WHERE cs.CustID = @UplineID

		SET @xmlStrDisabled = (
					SELECT (
							SELECT DISTINCT ft.bitmapOrder	AS '@b'
								, stt.IsDisabled	AS '@s'
							FROM @SportBettypeStatus ft 
								INNER JOIN OPENJSON(@SettingXML,'$."160"') WITH (
											 SportType			SMALLINT	
											,BetType			SMALLINT
											,IsDisabled			BIT
										) AS Stt
										ON stt.SportType = ft.SportType
											AND stt.bettype = ft.Bettype
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

		UPDATE cs
		SET bitmapIsDisabled = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
		WHERE cs.CustID = @CustID     
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 160
		RETURN
	END CATCH

	/********************************************* Position Taking: GroupType = 153 ***********************************/
	DECLARE @tblPT TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsLive			BIT,
			SuperPT			SMALLMONEY,
			MasterPT		SMALLMONEY		
			)

	INSERT INTO @tblPT( SportType,BetType,IsLive,SuperPT,MasterPT)
	SELECT pt.SportType,pt.BetType,pt.IsLive,pt.SuperPT,pt.MasterPT
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
		 SportType SMALLINT  '$.SportType'
		,BetType SMALLINT  '$.BetType'
		,IsLive BIT  '$.IsLive'
		,SuperPT SMALLMONEY  '$.SuperPT'
		,MasterPT SMALLMONEY  '$.MasterPT'
	) pt
		INNER JOIN #ProductSettingDetail_tmp00 p
			ON p.SportType = pt.SportType
			AND p.BetType = pt.BetType
			AND p.IsLive = pt.IsLive
			AND GroupType = 153

	DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @MasterPT SMALLMONEY	
					
	IF @UplineRoleID = 3 -- correct s1
	BEGIN
		--correct PT 	
		--@temp1 = n4 - m1
		--@temp2 = min(s3{us3}, s4 - m1)
		--s1 = max(@temp1,@temp2)	
		UPDATE t
		SET @temp1 = scs.MinPT - t.MasterPT,
			@temp2 = CASE WHEN mcs.IsAutoSuperPT = 0
								THEN 
									CASE WHEN mcs.SuperPT < scs.SuperPT - t.MasterPT
												THEN mcs.SuperPT
											ELSE scs.SuperPT - t.MasterPT
									END	
								ELSE	CASE WHEN mcs.AutoSuperPT < scs.SuperPT - t.MasterPT
												THEN mcs.AutoSuperPT
											ELSE scs.SuperPT - t.MasterPT
									END		
						END,	
			t.SuperPT = CASE WHEN @temp1 > @temp2 THEN @temp1 ELSE @temp2 END
		FROM @tblPT t 
			INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
													AND mcs.sporttype = t.sporttype
													AND mcs.bettype = t.bettype
													AND mcs.IsLive = t.IsLive
			INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
													AND scs.sporttype = t.sporttype
													AND scs.bettype = t.bettype
													AND scs.IsLive = t.IsLive
	END
	ELSE --set m1 = 0
	BEGIN
		UPDATE @tblPT SET MasterPT = 0
	END

	BEGIN TRY
		INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped,RepUpdateTime)
		SELECT @CustID,0,dbo.f_GetDateTime2()
			
		INSERT INTO [dbo].[CustPTSetting3rd_Member]
				([CustID]
				,[SportType]
				,[BetType]
				,[IsLive]
				,[SuperPT]
				,[MasterPT]
				,[AgentPT]
				,[IsAutoMasterPT]
				,[AutoMasterPT]
				,[IsAutoSuperPT]
				,[AutoSuperPT]
				,RepUpdateTime
				)
		SELECT @CustID,SportType,BetType,Islive,SuperPT,MasterPT
			,0 AS AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT,dbo.f_GetDateTime2()
		FROM @tblPT t 
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 153			
		RETURN
	END CATCH

	/********************************************* Bet Limit : GroupType = 154, 151 ****************************************/
	BEGIN TRY
		INSERT INTO [dbo].[BetSetting_Member]
				([CustID]
				,[SportType]
				,[BetType]
				,[MinBet]
				,[MaxBet]
				,[MaxPerMatch]
				,[MaxPayoutPerMatch]
				,[RepUpdateTime]
				)
		SELECT @CustID AS CustID
			,bs.SportType
			,bs.BetType
			,ISNULL(bs.MinBet,0) AS [MinBet]
			,ISNULL(bs.MaxBet,0) AS [MaxBet]
			,ISNULL(bs.MPM,0) AS  [MaxPerMatch]
			,bs.MaxPayout AS [MaxPayoutPerMatch]
			,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."151"') WITH (
				 SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,MinBet MONEY  '$.MinBet'
				,MaxBet MONEY  '$.MaxBet'
				,MPM MONEY  '$.MPM'
				,MaxPayout MONEY  '$.MaxPayout'
			) AS bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 151
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 151			
		RETURN
	END CATCH
	
	BEGIN TRY
		INSERT INTO [dbo].[BetSetting3rd_Member]
				([CustID]
				,[SportType]
				,[BetType]
				,[MinBet]
				,[MaxBet]
				,[MaxPerMatch]
				,MaxPerNumber
				,[RepUpdateTime]
				)
		SELECT @CustID AS CustID
			,bs.SportType
			,bs.BetType
			,ISNULL(bs.MinBet,0) AS [MinBet]
			,ISNULL(bs.MaxBet,0) AS [MaxBet]
			,ISNULL(bs.MPM,0) AS  [MaxPerMatch]
			,CASE WHEN p.SubType = 2 THEN ISNULL(bs.MaxPerNumber,0) END 
			,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."154"') WITH (
				 SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,MinBet MONEY  '$.MinBet'
				,MaxBet MONEY  '$.MaxBet'
				,MPM MONEY  '$.MPM'
				,MaxPerNumber MONEY  '$.MaxPerNumber'
			) AS bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 154
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 154			
		RETURN
	END CATCH
	
	/********************************************* Max Parlay Payout : GroupType = 152 ****************************************/
	BEGIN TRY
		INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,[RepUpdateTime])
		SELECT @custid,bs.SportType,bs.BetType,bs.SingleMP,bs.Combo2,bs.Combo35,bs.Combo6,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."152"') WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,SingleMP MONEY  '$.SingleMP'
				,Combo2 MONEY  '$.Combo2'
				,Combo35 MONEY  '$.Combo35'
				,Combo6 MONEY  '$.Combo6'
			) bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 152
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 152			
		RETURN
	END CATCH

	/********************************************* Commision : GroupType = 150, 156 ****************************************/
	BEGIN TRY
		DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, 
										bettype SMALLINT, 
										playerdiscount DECIMAL(9,8), 
										sdiscount DECIMAL(9,8), 
										adiscount DECIMAL(9,8), 
										discount DECIMAL(9,8),
										GroupType TINYINT
										)

		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,GroupType)
		SELECT c.SportType,c.BetType,c.Discount,p.GroupType
		FROM OPENJSON(@SettingXML,'$."150"') WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,Discount DECIMAL(9,8)  '$.Discount'
			) c
			INNER JOIN #ProductSettingDetail_tmp00 p
						ON p.SportType = c.SportType
						AND p.BetType = c.BetType
						AND p.GroupType = 150

		INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,GroupType)
		SELECT c.SportType,c.BetType,c.Discount,p.GroupType
		FROM OPENJSON(@SettingXML,'$."156"') WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,Discount DECIMAL(9,8)  '$.Discount'
			) c
			INNER JOIN #ProductSettingDetail_tmp00 p
						ON p.SportType = c.SportType
						AND p.BetType = c.BetType
						AND p.GroupType = 156

		UPDATE t
		SET t.sdiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @srecommend
			AND NOT( t.sporttype = 1 AND t.bettype = 1)

		--Asian HDP, OU, OE Comm, correct by ugroup
		UPDATE t
		SET t.sdiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
																AND cs.bettype = CASE WHEN @ugroup in ('a','hka','dea') THEN 1
																					WHEN @ugroup in ('b','hkb','deb') THEN 3
																					WHEN @ugroup in ('c','hkc','dec') THEN 7
																					ELSE 8 
																				END
		WHERE custid = @srecommend
			AND ( t.sporttype = 1 AND t.bettype = 1)
			AND cs.BetType IN (1,3,7,8)

		IF @UplineRoleID = 3
		BEGIN
			UPDATE t
			SET t.adiscount = cs.Discount
			FROM @NewDiscountTbl t
				INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
																AND t.bettype = cs.bettype
			WHERE custid = @mrecommend	
				AND NOT( t.sporttype = 1 AND t.bettype = 1)

			UPDATE t
			SET t.adiscount = cs.Discount
			FROM @NewDiscountTbl t
				INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
																	AND cs.bettype = CASE WHEN @ugroup in ('a','hka','dea') THEN 1
																						WHEN @ugroup in ('b','hkb','deb') THEN 3
																						WHEN @ugroup in ('c','hkc','dec') THEN 7
																						ELSE 8 
																					END
			WHERE custid = @mrecommend	
				AND ( t.sporttype = 1 AND t.bettype = 1)
				AND cs.BetType IN (1,3,7,8)
		END
		ELSE --Set masterdiscount = playerdiscount
		BEGIN
			UPDATE t
			SET t.adiscount = t.playerdiscount
			FROM @NewDiscountTbl t
		END

		--Set agentdiscount = playerdiscount
		UPDATE t
		SET t.discount = t.playerdiscount
		FROM @NewDiscountTbl t
		
		--correct discount
		UPDATE t
		SET adiscount = sdiscount
		FROM @NewDiscountTbl t
		WHERE adiscount > sdiscount		
		
		UPDATE t
		SET discount = adiscount
		FROM @NewDiscountTbl t
		WHERE discount > adiscount
		
		UPDATE t
		SET playerdiscount = discount
		FROM @NewDiscountTbl t
		WHERE playerdiscount > discount

		INSERT INTO [dbo].[CustDiscount3rd_Member]
			([CustID]
			,[SportType]
			,[BetType]
			,[PlayerDiscount]
			,[AgentDiscount]
			,[MasterDiscount]
			,[SuperDiscount]
			,[RepUpdateTime]
			)
		SELECT @CustID
			,dc.SportType
			,dc.BetType
			,dc.playerdiscount
			,dc.discount
			,dc.adiscount
			,dc.sdiscount
			,dbo.f_GetDateTime2()
		FROM @NewDiscountTbl dc
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 150			
		RETURN
	END CATCH

	/********************************************* WinLossLimit : GroupType = 155 ****************************************/
	BEGIN TRY
		INSERT INTO [dbo].[CustWinLossLimit_Member]
					([CustID]
					,[SportType]
					,[BetType]
					,[MaxWinLimit]
					,[MaxLossLimit]
					,[IsAutoReset]
					,RepUpdateTime
					)
		SELECT @custID
			,bs.SportType
			,bs.BetType
			,bs.MaxWinLimit
			,bs.MaxLossLimit
			,bs.IsAutoReset
			,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."155"') WITH (
				SportType		SMALLINT
				,BetType		SMALLINT
				,MaxWinLimit	SMALLMONEY
				,MaxLossLimit	MONEY
				,IsAutoReset	BIT
			) AS bs
			INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 155
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 155			
		RETURN
	END CATCH

	/********************************************* StakeLevel : GroupType = 158 ****************************************/
	BEGIN TRY
		INSERT INTO	dbo.CustStakeLevel_Member(CustID,SportType,BetType,StakeLevelList,LastUpdated,RepUpdateTime)
		SELECT @custID, ox.SportType,ox.BetType,ox.StakeLevelList,GETDATE(),dbo.f_GetDateTime2() 
		FROM OPENJSON(@SettingXML,'$."158"') WITH (
					 SportType		SMALLINT
					,BetType		INT
					,StakeLevelList	VARCHAR(200)	
				) AS ox
			INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = ox.SportType
				AND p.BetType = ox.BetType
				AND p.GroupType = 158
		
		INSERT INTO	dbo.CustStakeLevel_Member(CustID,SportType,BetType,StakeLevelList,LastUpdated,RepUpdateTime)
		SELECT @custID, p.SportType,p.BetType,'',GETDATE(),dbo.f_GetDateTime2() 
		FROM #ProductSettingDetail_tmp00 p 
		WHERE NOT EXISTS (SELECT 1 FROM CustStakeLevel_Member cs WITH (NOLOCK) 
							WHERE p.SportType = cs.SportType AND p.BetType = cs.BetType AND cs.CustID = @custid)
			AND p.GroupType = 158

	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 158			
		RETURN
	END CATCH

	--162: Potential Win Limit
	BEGIN TRY
		DECLARE @tblPotentialWinLimit TABLE (
			SportType		SMALLINT,
			BetType			SMALLINT,
			IsAutoReset		BIT,
			PotentialWinLimit MONEY,
			IncludeParlay  	BIT			
		)
		
		INSERT INTO @tblPotentialWinLimit(SportType,BetType,IsAutoReset,PotentialWinLimit,IncludeParlay)
		SELECT SportType,BetType,IsAutoReset, WinLimit, IncludeParlay
		FROM OPENJSON(@SettingXML,'$."162"') WITH (
				SportType		SMALLINT
				,BetType		SMALLINT
				,WinLimit		MONEY 
				,IsAutoReset	BIT
				,IncludeParlay	BIT
			) AS p

		IF EXISTS (SELECT 1 FROM @tblPotentialWinLimit)
		BEGIN
			INSERT INTO [dbo].[CustPotentialWinLimit]
						([CustID]
						,[SportType]
						,[BetType]
						,[PotentialWinLimit]					
						,[IsAutoReset]
						,OfferOption
						,RepUpdateTime
						)
			SELECT @custID, t.SportType, t.Bettype, t.PotentialWinLimit, t.IsAutoReset, t.IncludeParlay, dbo.f_GetDateTime2()
			FROM #ProductSettingDetail_tmp00 p 
				INNER JOIN @tblPotentialWinLimit t
					ON p.SportType = t.SportType
					AND p.BetType = t.BetType
			WHERE SettingType = 30 	
		END
		ELSE
		BEGIN
			INSERT INTO [dbo].[CustPotentialWinLimit]
						([CustID]
						,[SportType]
						,[BetType]
						,[PotentialWinLimit]					
						,[IsAutoReset]
						,OfferOption
						,RepUpdateTime
						)
			SELECT @custID, SportType, Bettype, 0, 1, 0, dbo.f_GetDateTime2()
			FROM #ProductSettingDetail_tmp00 p 
			WHERE SettingType = 30 
		END	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 162			
		RETURN
	END CATCH

	DROP TABLE #ProductSettingDetail_tmp00
	DROP TABLE #ProductSettingSiteDisplay
END
GO
