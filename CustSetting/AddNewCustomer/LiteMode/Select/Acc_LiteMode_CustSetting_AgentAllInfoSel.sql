/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_AgentAllInfoSel] 
	@CustID INT,		
	@GroupID INT = 0,
	@GroupType INT = 0,
	@SettingStatus TINYINT = 0,
	@ServiceType TINYINT = 0
AS
/*
	Created by: 2023710@Johnson	
	Task: Select agent setting for create member on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 2023710@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
		- 20240118@Eden: avoid data duplicate of Esport & Muay Thai Betsetting [redmine: #199970]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240423@Elodie: Member Max Credit, Member Given Credit enhancements [Redmine: #203332]
		- 20240607@Johnson: scale out DBCUST [redmine: #199915]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
		- 20250512@Johnson: Add Potential Win Limit for create member [redmine: #226060]
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
		- 20250626@Dave: Add AccumCredit of AllCashMember to AgentUsedCredit [Redmine: #231524]
		
	Parameter's explaination:
		- @GroupID: 1: SB, 2: RnG Games, 3: LCS
		- @GroupType: group setting Type
		- @GroupID = 0 & @GroupType = 0: General info
		- @Site: check @IsMyanmarOdds for Direct Master
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @srecommend INT, 
			@mrecommend INT,	
			@SiteLabel	VARCHAR(50),
			@Site VARCHAR(10),
			@SiteID SMALLINT,
			@Currency SMALLINT,
			@UplineUsername VARCHAR(50)
		
	SELECT @UplineUsername = username,@srecommend = srecommend, @mrecommend = mrecommend,
		@Site = c.site,
		@SiteLabel = s.SiteLabel,
		@SiteID = s.SiteID,
		@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid
	
	IF @GroupType = 0 
	BEGIN
		DECLARE @Asuspended BIT, 
				@UplineClosed BIT, 
				@Credit_AllOtherMember MONEY, 
				@Credit_Ag MONEY,
				@Credit_Mem_Max MONEY, 
				@Credit_Ag_Bal MONEY,
				@MaxCredit_Mem MONEY,
				@AccumCredit_AllCashMember MONEY
		
		IF @ServiceType = 0
		BEGIN
			SELECT @Credit_AllOtherMember = ISNULL(SUM(credit), 0) 
			FROM custinfo as ci WITH (NOLOCK) 
			WHERE recommend = @CustID 
				AND RoleID = 1

			SELECT	@Credit_Ag = isnull(credit, 0)
			FROM CustInfo as ci with (NOLOCK) 
			WHERE CustID = @CustID

			SELECT @MaxCredit_Mem = isnull(maxcredit,0) 
			FROM CustAgent WITH (NOLOCK) 
			WHERE CustID = @CustID

			SELECT @AccumCredit_AllCashMember = ISNULL(SUM(AccumCreditReturn),0)
    		FROM dbo.CashAccumCredit WITH (NOLOCK)
			WHERE recommend = @CustID;

			SELECT @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember - @AccumCredit_AllCashMember;
		END

		SELECT
			@Asuspended = CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END, 				 
			@UplineClosed = CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END	
		FROM dbo.CustProductStatus  WITH(NOLOCK)
		WHERE CustID = custid
					
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--SELECT @Credit_Mem_Max = CASE WHEN @MaxCredit_Mem =0  THEN @Credit_Ag_Bal 
		--							  WHEN @MaxCredit_Mem > @Credit_Ag_Bal THEN @Credit_Ag_Bal
		--							  ELSE @MaxCredit_Mem END 
				
		SELECT @UplineUsername as UplineUsername,
			@Asuspended as suspended, 
			@UplineClosed as closed,
			@Credit_Ag_Bal as Credit_Ag_Bal,
			@MaxCredit_Mem AS MaxCredit_Mem,
			@site AS Site,
			@SiteLabel AS SiteLabel,
			@currency currency
	END
	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT
				, ProductID TINYINT, IntervalValue DECIMAL(9,8), SubType TINYINT, Child_DisplayOrder INT,SubGroupID TINYINT,SubGroupOrder TINYINT
				, [Parent_ProductSettingID] [int], [ProductSettingID] [int], ParentSportType SMALLINT, ParentBetType SMALLINT,SettingType smallint, MaxChoice tinyint)
		
	IF @ServiceType = 0
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice)
		SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType,NULL,@SettingStatus,@siteID,@currency) 
	END
	ELSE IF @ServiceType = 1
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice)
		SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder,Parent_ProductSettingID,ProductSettingID,SettingType,MaxChoice
		FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterCashSelect(@GroupID, @GroupType,NULL,@SettingStatus,@siteID,@currency) 
	END

	UPDATE t
	SET t.ParentSportType = pr.SportType, t.ParentBetType = pr.Bettype
	FROM #SportBettypeFilter t 
		INNER JOIN #SportBettypeFilter pr 
			ON t.Parent_ProductSettingID = pr.ProductSettingID
	WHERE t.Parent_ProductSettingID IS NOT NULL
	
	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	------- Create New Cash Member
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
			AND ft.SportType NOT IN (161)
		ORDER BY ft.Child_DisplayOrder
	END

	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		SELECT t.SportType, t.BetType, t.Discount, s.IntervalValue
		FROM CustDiscount3rd_Agent t WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s 
				ON t.sporttype = s.sporttype
				AND t.bettype = s.bettype
		WHERE t.CustID = @CustID
			AND NOT (t.SportType = 1 AND t.BetType IN (3,7,8)) -- Load default Group A 
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder									
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN			
		SELECT cs.Sporttype, cs.Bettype,
			ISNULL(MAX(CASE WHEN cs.MinBet = 0 THEN NULL ELSE cs.MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN cs.MaxBet = 0 THEN NULL ELSE cs.MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 	
			MaxPayoutPerMatch = CASE WHEN cs.SportType IN(43,44) THEN NULL 
									 ELSE ISNULL(MIN(CASE WHEN cs.MaxPayoutPerMatch = 0 THEN NULL ELSE cs.MaxPayoutPerMatch END),0) 
								END
		FROM BetSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype,s.SubGroupOrder,s.Child_DisplayOrder
		ORDER BY s.SubGroupOrder,s.Child_DisplayOrder
	END
	
	--Parlay MaxPayoutPerMatch
	IF @GroupID = 1 AND @GroupType = 152
	BEGIN
		DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)
		
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 AND aMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 AND aMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0 AND aMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0 AND aMp.ComboOver6 = 0 THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent aMp WITH (NOLOCK) ON s.SportType = aMp.sporttype AND s.BetType = aMp.bettype
		WHERE cs.custid = @srecommend  AND mMp.CustID = @mrecommend AND aMp.CustID = @custid

		SELECT	ft.SportType,
				ft.BetType,				
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
						THEN mps.SingleMatchParlay
						ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
																(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END), 
																(CASE WHEN bl.SingleMatchParlay = 0 THEN NULL ELSE bl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS SingleMatchParlay, 
						 
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
						THEN mps.Combo2
						ELSE (SELECT MIN(Combo2) FROM (VALUES (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
																(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END), 
																(CASE WHEN bl.Combo2 = 0 THEN NULL ELSE bl.Combo2 END)) AS t(Combo2)) END AS Combo2,  

				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
						THEN mps.Combo35
						ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END), 
																(CASE WHEN bl.Combo35 = 0 THEN NULL ELSE bl.Combo35 END)) AS t(Combo35)) END AS Combo35,
			
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
						THEN mps.ComboOver6
						ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
																	(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END), 
																	(CASE WHEN bl.ComboOver6 = 0 THEN NULL ELSE bl.ComboOver6 END)) AS t(ComboOver6)) END AS ComboOver6,		
				bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
				bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
				bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
				bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit,
				ft.Child_DisplayOrder	
		FROM #SportBettypeFilter ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			LEFT JOIN MaxPayoutGlobalSetting mps WITH(NOLOCK) ON ft.BetType = mps.BetType  AND ft.SportType = mps.SportType AND mps.Currency = @currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @srecommend AND mbl.CustID = @mrecommend		
		ORDER BY ft.SubGroupOrder,ft.Child_DisplayOrder
	END
	
	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END as A2 
			, cs.MinPT  AS N2 
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
											AND s.BetType = cs.bettype  
											AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid = @srecommend
																AND	scs.SportType = cs.sporttype  
																AND scs.BetType = cs.bettype  
																AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder
	END

	--Potential Win Limit
	IF @GroupID = 1 AND @GroupType = 162
	BEGIN		
		SELECT Sporttype, Bettype, 0 as PotentialWinLimit, 1 as IsAutoReset
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
		WHERE cs.CustID IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubType,SubGroupOrder, s.Child_DisplayOrder
		ORDER BY s.SubGroupOrder,s.Child_DisplayOrder
	END
	
	--PT
	IF @GroupID = 2 AND @GroupType = 153
	BEGIN	
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END as A2 
			, cs.MinPT  AS N2 
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
											AND s.BetType = cs.bettype  
											AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid = @srecommend
																AND	scs.SportType = cs.sporttype  
																AND scs.BetType = cs.bettype  
																AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid	
		ORDER BY SubGroupOrder, Child_DisplayOrder
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
			, CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END as A2 
			, cs.MinPT  AS N2 
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
											AND s.BetType = cs.bettype  
											AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid = @srecommend
																AND	scs.SportType = cs.sporttype  
																AND scs.BetType = cs.bettype  
																AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid	
		ORDER BY SubGroupOrder,Child_DisplayOrder
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
	

	--PT
	IF @GroupID = 4 AND @GroupType = 153
	BEGIN	
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END as A2 
			, cs.MinPT  AS N2 
			, s.Child_DisplayOrder
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
											AND s.BetType = cs.bettype  
											AND s.IsLive = cs.islive
			INNER JOIN CustPTSetting3rd_Agent scs WITH (NOLOCK) ON scs.custid = @srecommend
																AND	scs.SportType = cs.sporttype  
																AND scs.BetType = cs.bettype  
																AND scs.IsLive = cs.islive	
		WHERE cs.CustID = @custid	
		ORDER BY SubGroupOrder,Child_DisplayOrder
	END
	--END Others Games
	----------------------------------------------------------------------------------
	------- Create New Cash Member -------		
	IF @GroupType = 161
	BEGIN
		SELECT
				CASE WHEN @GroupID = 3 THEN sbf.ProductID ELSE NULL END AS ProductID,
				wl.SportType,
				wl.BetType,
				wl.MaxWinLimit * ci.credit AS MaxWinLimit,
				wl.MaxWinLimit * ci.credit AS MaxWinRange,				
				wl.IsAutoReset,
				wl.IsAutoReset AS IsAutoResetUpline,
				sbf.SubType,
				sbf.Child_DisplayOrder
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustInfo ci WITH (NOLOCK) ON wl.custid = ci.custid
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

	DROP TABLE #SportBettypeFilter
END	