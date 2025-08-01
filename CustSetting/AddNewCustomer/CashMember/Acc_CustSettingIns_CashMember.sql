/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSettingIns_CashMember]
	@custid INT = 0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,	
	@UplineRoleID TINYINT = 2,
	@siteid SMALLINT = 0,
	@currency SMALLINT = 0,
	@SystemID TINYINT = 1,	
	@SettingXML VARCHAR(MAX) = '',
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
AS
/*
	Created: 20250423@Elodie
	Task: Insert cash member setting when Super/Master create direct member
	DB: DBCUST/CustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		- 20250801@Johnson: Include Parlay to Potential Win Limit [redmine: #233805]
	Parameter's Explanation:
	- @SettingXML:
		'{
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
			--Winloss Limit:
			"161": [
					{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2000" , "IsAutoReset":"0" }, 
					{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2000" , "IsAutoReset":"0" }, 
					{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2000" , "IsAutoReset":"0" }
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
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@siteid,@currency)	

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
	ELSE IF (@UplineRoleID = 2)
		SET @UplineID = @recommend	
	
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

		INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,ServiceType,RepUpdateTime)
		SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced,cs.SuspendInfo,cs.CloseInfo,ServiceType,dbo.f_GetDateTime2()
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
			MasterPT		SMALLMONEY,
			AgentPT			SMALLMONEY	
			)

	INSERT INTO @tblPT( SportType,BetType,IsLive,AgentPT)
	SELECT pt.SportType,pt.BetType,pt.IsLive,pt.AgentPT
	FROM OPENJSON(@SettingXML,'$."153"') WITH (
		 SportType SMALLINT  '$.SportType'
		,BetType SMALLINT  '$.BetType'
		,IsLive BIT  '$.IsLive'
		,AgentPT SMALLMONEY  '$.AgentPT'		
	) pt
		INNER JOIN #ProductSettingDetail_tmp00 p
			ON p.SportType = pt.SportType
			AND p.BetType = pt.BetType
			AND p.IsLive = pt.IsLive
			AND GroupType = 153

	DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @MasterPT SMALLMONEY	
					
	--correct PT 
	--IF u2 = 0 THEN m1 = m2
	--else	IF u2 < m3 - a1 THEN m1 = u2
	--		else m1 = m3 - a1
	
	--@max_spt = @maxdownlinepos + spt 
	--IF @auto_spt = 0 THEN @spt = s3
	--else	IF @auto_spt < s4 - @mpt - @apt THEN @spt = @auto_spt
	--		else @spt = s4 - @mpt - @apt
	UPDATE t
	SET @MasterPT = CASE WHEN cs.IsAutoMasterPT = 0 THEN cs.MasterPT 
						ELSE CASE WHEN cs.AutoMasterPT < mcs.MasterPT - t.AgentPT THEN cs.AutoMasterPT
									ELSE mcs.MasterPT - t.AgentPT END
						END,
		t.SuperPT = CASE WHEN mcs.IsAutoSuperPT = 0 THEN mcs.SuperPT
								ELSE CASE WHEN mcs.AutoSuperPT < scs.SuperPT - @MasterPT - t.AgentPT
											THEN mcs.AutoSuperPT
											ELSE scs.SuperPT - @MasterPT - t.AgentPT
										END		
								END,
		t.MasterPT = @MasterPT				
	FROM @tblPT t 
		INNER JOIN CustPTSetting3rd_Agent cs WITH(NOLOCK) ON cs.custid = @recommend
												AND cs.sporttype = t.sporttype
												AND cs.bettype = t.bettype
												AND cs.IsLive = t.IsLive
		INNER JOIN CustPTSetting3rd_Agent mcs WITH(NOLOCK) ON mcs.custid = @mrecommend
												AND mcs.sporttype = t.sporttype
												AND mcs.bettype = t.bettype
												AND mcs.IsLive = t.IsLive
		INNER JOIN CustPTSetting3rd_Agent scs WITH(NOLOCK) ON scs.custid = @srecommend
												AND scs.sporttype = t.sporttype
												AND scs.bettype = t.bettype
												AND scs.IsLive = t.IsLive

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
			,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT,dbo.f_GetDateTime2()
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
		SELECT SportType,BetType,0,GroupType
		FROM #ProductSettingDetail_tmp00
		WHERE groupType IN (150,156) 		

		UPDATE t
		SET t.sdiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @srecommend			

		UPDATE t
		SET t.adiscount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @mrecommend

		UPDATE t
		SET t.discount = cs.Discount
		FROM @NewDiscountTbl t
			INNER JOIN CustDiscount3rd_Agent cs WITH(NOLOCK) ON t.sporttype = cs.sporttype
															AND t.bettype = cs.bettype
		WHERE custid = @recommend

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
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 158			
		RETURN
	END CATCH	

	/********************************************* WinLimit : GroupType = 161 ****************************************/
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
			,0
			,bs.IsAutoReset
			,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."161"') WITH (
				SportType		SMALLINT
				,BetType		SMALLINT
				,MaxWinLimit	MONEY
				,IsAutoReset	BIT
			) AS bs
			INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 161
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 161			
		RETURN
	END CATCH

	/********************************************* Potential Win Limit : GroupType = 162 ****************************************/
	BEGIN TRY
		INSERT INTO [dbo].[CustPotentialWinLimit]
					([CustID]
					,[SportType]
					,[BetType]
					,[PotentialWinLimit]					
					,[IsAutoReset]
					,OfferOption
					,RepUpdateTime
					)
		SELECT @custID
			,bs.SportType
			,bs.BetType
			,bs.WinLimit		
			,bs.IsAutoReset
			,bs.IncludeParlay
			,dbo.f_GetDateTime2()
		FROM OPENJSON(@SettingXML,'$."162"') WITH (
				SportType		SMALLINT
				,BetType		SMALLINT
				,WinLimit		MONEY
				,IsAutoReset	BIT
				,IncludeParlay	BIT
			) AS bs
			INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 162
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 162		
		RETURN
	END CATCH

	DROP TABLE #ProductSettingDetail_tmp00
	DROP TABLE #ProductSettingSiteDisplay
END
GO
