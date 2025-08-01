/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_MasterAllInfoSel] 
	@CustID INT,		
	@GroupID INT = 0,
	@GroupType INT = 0,
	@SettingStatus TINYINT = 0,
	@IsDirectMember BIT = 0
AS
/*
	Created by: 20230622@Johnson	
	Task: Select master setting for create agent on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 20230622@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
		- 20240118@Eden: avoid data duplicate of Esport & Muay Thai Betsetting [redmine: #199970]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240607@Johnson: scale out DBCUST [redmine: #199915]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]   
		- 20250619@Johnson: Add Potential Win Limit for direct member [redmine: #226060]
		- 20250801@Johnson: Include Parlay for Potential Win Limit [RedmineID: #233805]
	Parameter's explaination:
		- @GroupID: 1: SB, 2: RnG Games, 3: LCS
		- @GroupType: group setting Type
		- @GroupID = 0 & @GroupType = 0: General info
		- @Site: check @IsMyanmarOdds for Direct Master
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @srecommend INT,
		@SiteLabel	VARCHAR(50),
		@UplineUsername VARCHAR(50),
		@Site VARCHAR(10),
		@SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT @UplineUsername = username,
			@Site = c.site,
			@SiteLabel = s.SiteLabel,
			@srecommend = srecommend,
			@siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid
	
	IF @GroupType = 0
	BEGIN
		DECLARE @Msuspended BIT,
				@Credit_AllOtherAgent MONEY, @Credit_AllOtherDirectMember MONEY,
				@Credit_MAg MONEY, 
				@Credit_Ag_Max MONEY,								
				@DisableAutoMPT BIT,
				@IsInternalMaster BIT,								
				@TransferOption VARCHAR(8),
				@IsAutomateTransfer BIT = 0				
 		
		SELECT @Credit_AllOtherAgent = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE mrecommend = @CustID AND RoleID = 2

		SELECT @Credit_AllOtherDirectMember = isnull(sum(credit), 0) 
		FROM custinfo as ci with (NOLOCK) 
		WHERE mrecommend = @CustID 
			AND RoleID = 1
			AND recommend = -3
		
		SELECT @Credit_MAg = isnull(credit, 0)
		FROM CustInfo as ci with (NOLOCK) 
		WHERE CustID = @CustID
		
		SELECT @Credit_Ag_Max = @Credit_MAg - @Credit_AllOtherAgent - @Credit_AllOtherDirectMember
		
		SELECT @Msuspended = CASE WHEN cps.SuspendInfo > 0 THEN 1 ELSE 0 END 
		FROM CustProductStatus cps WITH (NOLOCK) 
		WHERE CustID = @CustID
				
		--Transfer Condition for Automate Transfer
		IF EXISTS (SELECT TOP (1) 1		
			FROM dbo.Acc_ClearBalanceList AS b WITH (NOLOCK)
				INNER JOIN dbo.custinfo AS c WITH (NOLOCK) ON c.srecommend = b.CustId
			WHERE c.custid = @custId
				AND b.TransferType = 2	
			)
			SELECT @IsAutomateTransfer = 1
			
		SELECT @IsInternalMaster = isnull(IsInternal, 0),
			@DisableAutoMPT = DisableAutoMPT,
			@TransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))	
		FROM CustMaster with (NOLOCK) 
		WHERE CustID = @CustId
		
		SELECT @UplineUsername as UplineUsername,
			@Msuspended as suspended,
			@Credit_Ag_Max as Credit_Max,
			ISNULL(@DisableAutoMPT,0) as DisableAutoMPT,
			@TransferOption TransferOption,
			@IsAutomateTransfer IsAutomateTransfer,
			@IsInternalMaster as IsInternal,			
			@Site site,
			@SiteLabel SiteLabel,
			@currency currency			
	END
	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT, IntervalValue DECIMAL(9,8), SubType TINYINT, Child_DisplayOrder INT,SubGroupID TINYINT,SubGroupOrder TINYINT
		, [Parent_ProductSettingID] [int], [ProductSettingID] [int], ParentSportType SMALLINT, ParentBetType SMALLINT,SettingType smallint, MaxChoice tinyint)
		
	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice)
	SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice
	FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType,NULL,@SettingStatus,@siteID,@currency) 
	
	UPDATE t
	SET t.ParentSportType = pr.SportType, t.ParentBetType = pr.Bettype
	FROM #SportBettypeFilter t 
		INNER JOIN #SportBettypeFilter pr 
			ON t.Parent_ProductSettingID = pr.ProductSettingID
	WHERE t.Parent_ProductSettingID IS NOT NULL
	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	
	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		SELECT t.SportType, t.BetType, t.Discount, s.IntervalValue,s.Child_DisplayOrder
		FROM CustDiscount3rd_Agent t WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s 
				ON t.sporttype = s.sporttype
				AND t.bettype = s.bettype
		WHERE t.CustID = @CustID
			AND (	@IsDirectMember = 0 
					OR NOT (t.SportType = 1 AND t.BetType IN (3,7,8))
				 ) -- Load default Group A when create Direct member
		ORDER BY s.SubGroupOrder,s.Child_DisplayOrder									
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN				
		SELECT cs.sporttype, cs.bettype, 
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 
			MaxPayoutPerMatch = CASE WHEN cs.SportType IN(43,44) THEN NULL 
									 ELSE ISNULL(MIN(CASE WHEN cs.MaxPayoutPerMatch = 0 THEN NULL ELSE cs.MaxPayoutPerMatch END),0) 
								END
		FROM BetSetting_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.sporttype = s.sporttype
												AND cs.bettype = s.bettype
		WHERE custid IN (@custid,@srecommend)
		GROUP BY cs.sporttype, cs.bettype,s.SubGroupOrder, s.Child_DisplayOrder
		ORDER BY s.SubGroupOrder,s.Child_DisplayOrder
	END
	
	--Parlay MaxPayoutPerMatch
	IF @GroupID = 1 AND @GroupType = 152
	BEGIN
		DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)
				
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
		WHERE cs.custid = @srecommend  AND mMp.CustID = @custid 
		
		IF @IsDirectMember = 1
		BEGIN
			SELECT	ft.SportType,
					ft.BetType,					
					CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
							THEN mps.SingleMatchParlay
							ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES  (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
															(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS SingleMatchParlay,  

					CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
							THEN mps.Combo2
							ELSE (SELECT MIN(Combo2) FROM (VALUES  (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
															(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END)) AS t(Combo2)) END AS Combo2,  

					CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
							THEN mps.Combo35
							ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																	(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END)) AS t(Combo35)) END AS Combo35,
						
					CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
							THEN mps.ComboOver6
							ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
																(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END)) AS t(ComboOver6)) END AS ComboOver6,	
					bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
					bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
					bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
					bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit		
			FROM #SportBettypeFilter ft 
				INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype			
				INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
				INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
				LEFT JOIN MaxPayoutGlobalSetting mps WITH(NOLOCK) ON ft.BetType = mps.BetType  AND ft.SportType = mps.SportType AND mps.Currency = @currency
			WHERE sbl.CustID = @srecommend AND mbl.CustID = @custid
			ORDER BY ft.SubGroupOrder, ft.Child_DisplayOrder
		END
		ELSE
		BEGIN
			SELECT	ft.SportType,
					ft.BetType,					
					CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
							THEN 0
							ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES  (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
															(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS SingleMatchParlay,  

					CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
							THEN 0
							ELSE (SELECT MIN(Combo2) FROM (VALUES  (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
															(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END)) AS t(Combo2)) END AS Combo2,  

					CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
							THEN 0
							ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																	(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END)) AS t(Combo35)) END AS Combo35,
						
					CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
							THEN 0
							ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
																(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END)) AS t(ComboOver6)) END AS ComboOver6,	
					bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
					bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
					bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
					bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit		
			FROM #SportBettypeFilter ft 
				INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype			
				INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
				INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			WHERE sbl.CustID = @srecommend AND mbl.CustID = @custid
			ORDER BY ft.SubGroupOrder, ft.Child_DisplayOrder
		END
	END

	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN	
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, scs.AgentPT AS A4			
			, cs.MasterPT AS M3  
			, cs.MinPT  AS N3  
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder
	END
	
	--Potential Win Limit
	IF @GroupID = 1 AND @GroupType = 162 AND @IsDirectMember = 1
	BEGIN		
		SELECT Sporttype, Bettype, 0 as PotentialWinLimit, 1 as IsAutoReset, 0 as IncludeParlay
		FROM #SportBettypeFilter
	END

	--END SB Settings
	----------------------------------------------------------------------------------
			
	----------------------------------------------------------------------------------
	--BEGIN RNG Games	
	--Bet Setting
	IF @GroupID = 2 AND @GroupType = 154
	BEGIN
		SELECT cs.Sporttype, cs.Bettype,
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 
			CASE WHEN s.SubType = 2 THEN  ISNULL(MIN(CASE WHEN cs.MaxPerNumber = 0 THEN NULL ELSE cs.MaxPerNumber END),0) END AS MaxPerNumber, 
			s.SubType,
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM BetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID IN (@custid,@srecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubType,s.SubGroupOrder, s.Child_DisplayOrder
		ORDER BY s.SubGroupOrder,s.Child_DisplayOrder
	END
	
	--PT
	IF @GroupID = 2 AND @GroupType = 153
	BEGIN						
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, scs.AgentPT AS A4			
			, cs.MasterPT AS M3  
			, cs.MinPT  AS N3  
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid
		ORDER BY SubGroupOrder,Child_DisplayOrder
	END
	--END RNG Games	
	----------------------------------------------------------------------------------
		
	----------------------------------------------------------------------------------
	--BEGIN Live & RnG Casino
	
	--Comm
	IF @GroupID = 3 AND @GroupType = 156
	BEGIN
		SELECT cs.SportType, cs.Bettype, cs.Discount, s.Child_DisplayOrder			
		FROM dbo.CustDiscount3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.SportType = s.sporttype AND cs.BetType = s.bettype  
		WHERE cs.custid = @custid	
		ORDER BY SubGroupOrder,s.Child_DisplayOrder	
	END
	
	--PT
	IF @GroupID = 3 AND @GroupType = 153
	BEGIN					
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, scs.AgentPT AS A4			
			, cs.MasterPT AS M3  
			, cs.MinPT  AS N3  
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid
		ORDER BY SubGroupOrder,s.Child_DisplayOrder			
	END
	--END Live & RnG Casino
	----------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	--BEGIN Others Games
	
	--Comm
	IF @GroupID = 4 AND @GroupType = 156
	BEGIN
		SELECT cs.SportType, cs.Bettype, cs.Discount, s.Child_DisplayOrder			
		FROM dbo.CustDiscount3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.SportType = s.sporttype AND cs.BetType = s.bettype  
		WHERE cs.custid = @custid	
		ORDER BY SubGroupOrder,s.Child_DisplayOrder	
	END
	
	--Bet Setting
	IF @GroupID = 4 AND @GroupType = 157
	BEGIN
		;WITH T AS (		
		SELECT cs.sporttype, cs.bettype, 
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch,	
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM BetSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.sporttype = s.sporttype
												AND cs.bettype = s.bettype
		WHERE custid IN (@custid,@srecommend)
		GROUP BY cs.sporttype, cs.bettype, SubGroupOrder, s.Child_DisplayOrder
		)
		SELECT Sporttype, Bettype, MinBet, MaxBet, MaxPerMatch, Child_DisplayOrder
		FROM T
		ORDER BY SubGroupOrder,Child_DisplayOrder
	END
	
	--PT
	IF @GroupID = 4 AND @GroupType = 153
	BEGIN					
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, scs.AgentPT AS A4			
			, cs.MasterPT AS M3  
			, cs.MinPT  AS N3  
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK)
				ON scs.custid = @srecommend
				AND	scs.SportType = cs.sporttype  
				AND scs.BetType = cs.bettype  
				AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid	
		ORDER BY SubGroupOrder,Child_DisplayOrder		
	END
	--END Others Games
	----------------------------------------------------------------------------------
	------- Create New Direct Member
	--Product Status
	IF @GroupType = 160
	BEGIN						
		SELECT	--ft.RealProductID,
				ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				ft.ParentSportType,
				ft.ParentBetType,
				ft.Child_DisplayOrder
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
			AND ft.SportType NOT IN(161)
		ORDER BY ft.Child_DisplayOrder
	END

	--Product Status
	IF @GroupType = 155
	BEGIN
		SELECT
				CASE WHEN @GroupID = 3 THEN sbf.ProductID ELSE NULL END AS ProductID,
				wl.SportType,
				wl.BetType,
				wl.MaxWinLimit,
				wl.MaxWinLimit AS MaxWinRange,
				wl.MaxLossLimit,
				gs.MinLossLimit AS MinLossRange,
				wl.MaxLossLimit AS MaxLossRange,
				wl.IsAutoReset,
				wl.IsAutoReset AS IsAutoResetUpline,
				sbf.SubType,
				sbf.Child_DisplayOrder
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
			ORDER BY sbf.Child_DisplayOrder
	END

	--Stake Level
	IF @GroupType = 158
	BEGIN
		;WITH Temp AS(
		SELECT	csla.SportType,	csla.BetType, sl.StakeLevelID
		, StakeLevelName = sl.MinLabel + N' - ' + sl.MaxLabel
		, sl.MaxStake
		, sbtf.ProductID
		, sbtf.Child_DisplayOrder
		, sbtf.SettingType
		, sbtf.MaxChoice
		, RN = ROW_NUMBER () OVER (PARTITION BY csla.SportType, csla.BetType ORDER BY sl.MaxStake,sl.MinStake,sl.GameGroupID)
		FROM dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbtf
				ON	sbtf.SportType = csla.SportType
				AND	sbtf.BetType = csla.BetType
			CROSS APPLY	STRING_SPLIT(ISNULL(csla.StakeLevelList, ''), ',') AS ss
			INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
				ON	sl.GameTypeID = sbtf.BetType
				AND	sl.StakeLevelID = CAST(ss.value AS INT)
		WHERE csla.CustID =	@CustID
		)
		SELECT SportType, BetType, StakeLevelID, StakeLevelName, ProductID
			, isChecked = CASE WHEN RN = 1 THEN 1 ELSE 0 END
			,MaxChoice
			,ProductID
			,CAST(CASE WHEN SettingType = 17 THEN 1 ELSE 0 END AS BIT) IsMultipleChoice
		FROM Temp
		ORDER BY Child_DisplayOrder, SportType, BetType, MaxStake
	END
			
	DROP TABLE #SportBettypeFilter
END	
	