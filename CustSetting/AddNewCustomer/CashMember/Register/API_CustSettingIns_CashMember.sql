/*<info serverAlias="DBCUST-CUSTDB" executers="asv_CashService" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[API_CustSettingIns_CashMember]
	@custid INT,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,	
	@AgentCredit MONEY,
	@UplineRoleID TINYINT = 2,
	@siteid SMALLINT = 0,
	@currency SMALLINT = 0,
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
AS
/*
	Created: 20250423@Elodie
	Task: Insert cash member setting when Super/Master create direct member
	DB: DBCUST/CustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		
	Parameter's Explanation:
		
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
		
	IF (@UplineRoleID = 4) 
		SET @UplineID = @srecommend
	ELSE IF (@UplineRoleID = 3)
		SET @UplineID = @mrecommend	
	ELSE IF (@UplineRoleID = 2)
		SET @UplineID = @recommend	
	
	/*********************** Product Status: GroupType = 160 **************************/
	BEGIN TRY		
		--INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,ServiceType,RepUpdateTime)
		--SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced,cs.SuspendInfo,cs.CloseInfo,ServiceType,dbo.f_GetDateTime2()
		--FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
		--WHERE cs.CustID = @UplineID

		INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,RepUpdateTime)
		SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced,cs.SuspendInfo,cs.CloseInfo,dbo.f_GetDateTime2()
		FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
		WHERE cs.CustID = @UplineID

		INSERT INTO [dbo].[CustProductStatus_UAT]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,ServiceType,RepUpdateTime)
		SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced,cs.SuspendInfo,cs.CloseInfo,1,dbo.f_GetDateTime2()
		FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
		WHERE cs.CustID = @UplineID		   
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
	FROM CustPTSetting3rd_Agent pt WITH(NOLOCK)
		INNER JOIN #ProductSettingDetail_tmp00 p
			ON p.SportType = pt.SportType
			AND p.BetType = pt.BetType
			AND p.IsLive = pt.IsLive
			AND GroupType = 153
		WHERE pt.CustID = @UplineID			
		

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
			,ISNULL(bs.MaxPerMatch,0) AS  [MaxPerMatch]
			,bs.MaxPayoutPerMatch AS [MaxPayoutPerMatch]
			,dbo.f_GetDateTime2()
		FROM BetSetting_Agent bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 151
		WHERE bs.CustID = @UplineID		
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
			,ISNULL(bs.MaxPerMatch,0) AS  [MaxPerMatch]
			,CASE WHEN p.SubType = 2 THEN ISNULL(bs.MaxPerNumber,0) END 
			,dbo.f_GetDateTime2()
		FROM BetSetting3rd_Agent bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 154
		WHERE bs.CustID = @UplineID	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 154			
		RETURN
	END CATCH
	
	/********************************************* Max Parlay Payout : GroupType = 152 ****************************************/
	BEGIN TRY
		INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,[RepUpdateTime])
		SELECT @custid,bs.SportType,bs.BetType,bs.SingleMatchParlay,bs.Combo2,bs.Combo35,bs.ComboOver6,dbo.f_GetDateTime2()
		FROM CustMaxPayoutSetting_Agent bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 152
		WHERE bs.CustID = @UplineID	
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
		INSERT INTO	dbo.CustStakeLevel_Member (	CustID, SportType, BetType, StakeLevelList, LastUpdated, RepUpdateTime)
		SELECT	@CustID, csla.SportType, csla.BetType, ISNULL(sr.LowestStakeLevel, ''), GETDATE(), dbo.f_GetDateTime2()
		FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
			INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = csla.SportType
				AND p.BetType = csla.BetType
				AND p.GroupType = 158
			OUTER APPLY (
				SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
				FROM (
					SELECT	CAST(value AS INT) AS val
					FROM	STRING_SPLIT(csla.StakeLevelList, ',')
				) AS ss
				INNER JOIN	GlobCustDB.dbo.StakeLevel AS sl WITH(NOLOCK)
						ON	ss.val = sl.StakeLevelID
				ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
			) sr
		WHERE	csla.CustID = @UplineID
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
			,bs.MaxWinLimit * @AgentCredit
			,0
			,bs.IsAutoReset
			,dbo.f_GetDateTime2()
		FROM CustWinLossLimit_Agent bs
		INNER JOIN #ProductSettingDetail_tmp00 p
				ON p.SportType = bs.SportType
				AND p.BetType = bs.BetType
				AND p.GroupType = 161
		WHERE bs.CustID = @UplineID	
	END TRY
	BEGIN CATCH 
		SELECT @ErrCode = 161			
		RETURN
	END CATCH

	DROP TABLE #ProductSettingDetail_tmp00
END
GO
