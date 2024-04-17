/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_SuperAllInfoSel] 
	@CustID INT,
	@Site VARCHAR(50) ='',
	@GroupID INT = 0,
	@GroupType INT = 0,
	@SettingStatus TINYINT = 0
AS
/*
	Created by: 20230419@Johnson	
	Task: Select super setting for create master on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 20230419@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
		- 20240118@Eden: avoid data duplicate of Esport & Muay Thai Betsetting [redmine: #199970]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
	Parameter's explaination:
		- @GroupID: 1: SB, 2: RnG Games, 3: LCS
		- @GroupType: group setting Type
		- @GroupID = 0 & @GroupType = 0: General info
		- @Site: check @IsMyanmarOdds for Direct Master
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @SiteAgent NVARCHAR(50), @SiteLabel VARCHAR(50), @siteID SMALLINT, @currency SMALLINT  
    
	SELECT @SiteAgent = c.site, @SiteLabel=s.SiteLabel, @currency = c.currency  
	FROM customer c WITH(NOLOCK)   
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site  
	WHERE CustID = @custid  

	--> If @site <> @SiteAgent --> Direct Master
	SET  @Site = ISNULL(NULLIF(@Site,''),@SiteAgent)

	SELECT @SiteID = siteid
	FROM Site WITH(NOLOCK) 
	WHERE site = @site
	
	--general info
	IF @GroupType = 0
	BEGIN
		DECLARE @UplineUserName VARCHAR(50),
				@Ssuspended BIT, 
				@IsInternal BIT	
		
		DECLARE @Credit_AllOtherMaster MONEY, 
				@Credit_SAg MONEY, 
				@Credit_MAg_Max MONEY,
				@TransferOption	VARCHAR(8),
				@srecommend INT = 0,
				@IsAutomateTransfer BIT = 0
		
		--Transfer Condition for Automate Transfer
		IF EXISTS (SELECT TOP (1) 1		
			FROM dbo.Acc_ClearBalanceList AS b WITH (NOLOCK)
				INNER JOIN dbo.custinfo AS c WITH (NOLOCK) ON c.srecommend = b.CustId
			WHERE c.custid = @custId
				AND b.TransferType = 2	
			)
			SELECT @IsAutomateTransfer = 1
		
		SELECT @TransferOption = dbo.F_Decimal_Binary(ISNULL(TransferOption, 0))
		FROM CustSuper WITH (NOLOCK) 
		WHERE custid = @CustId
			
		SELECT @Credit_AllOtherMaster = isnull(sum(credit), 0) 
		FROM custinfo as ci with (NOLOCK) 
		WHERE srecommend = @CustID 
			AND RoleID = 3
			
		SELECT @Credit_SAg = isnull(credit, 0), 
			@srecommend = srecommend,
			@UplineUserName = username 
		FROM CustInfo as ci with (NOLOCK) 
		WHERE CustID = @CustID
		
		SELECT @Ssuspended = CASE WHEN cps.SuspendInfo > 0 THEN 1 ELSE 0 END FROM CustProductStatus cps WITH (NOLOCK) WHERE CustID = @CustID
		
		SELECT @IsInternal = isnull(IsInternal, 0) 
		FROM custsuper with (NOLOCK) 
		WHERE CustID = @CustId
		
		IF @CustID <= 100
		BEGIN
			--Set unlimited for dummy super
			SELECT @Credit_MAg_Max = 10000000000
		END
		ELSE
		BEGIN
			SELECT @Credit_MAg_Max = @Credit_SAg - @Credit_AllOtherMaster
		END
		
		SELECT 
			@UplineUserName AS UplineUserName,
			@Ssuspended AS suspended,
			@Credit_MAg_Max as Credit_Max,
			@TransferOption as TransferOption,
			@IsAutomateTransfer IsAutomateTransfer,
			@IsInternal as IsInternal,	
			@SiteAgent AS Site,
			@SiteLabel AS SiteLabel,
			@currency currency
	END
	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT, IntervalValue DECIMAL(9,8), SubType TINYINT, Child_DisplayOrder INT,SubGroupID TINYINT,SubGroupOrder TINYINT)
		
	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder)
	SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder
	FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType,NULL,@SettingStatus,@siteID,@currency) 
	
	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	
	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		SELECT t.SportType, t.BetType, t.Discount, s.IntervalValue
		FROM CustDiscount3rd_Agent t WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s 
				ON t.sporttype = s.sporttype
				AND t.bettype = s.bettype
		WHERE t.CustID = @CustID
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN				
		SELECT cs.sporttype, cs.bettype, MinBet, MaxBet, MaxPerMatch, 
			MaxPayoutPerMatch = CASE WHEN s.SportType IN(43,44) THEN NULL ELSE ISNULL(MaxPayoutPerMatch,0) END
		FROM CustBetSetting_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s 
				ON cs.sporttype = s.sporttype
				AND cs.bettype = s.bettype
		WHERE cs.custid = @custid	
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder
	END
	
	--Parlay MaxPayoutPerMatch
	IF @GroupID = 1 AND @GroupType = 152
	BEGIN
		DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)
		
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		WHERE cs.custid = @custid
				
		SELECT	ft.SportType,
				ft.BetType,					
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 THEN 0
						ELSE sbl.SingleMatchParlay END AS SingleMatchParlay,  
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo2 END AS Combo2,
				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo35 END AS Combo35,
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.ComboOver6 END AS ComboOver6,
				bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
				bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
				bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
				bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit
		FROM #SportBettypeFilter ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype			
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE sbl.CustID = @custid
		ORDER BY ft.SubGroupOrder,ft.Child_DisplayOrder	
	END
	
	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN			
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, cs.SuperPT AS S4  
			, cs.MasterPT AS M4  
			, cs.MinPT  AS N4  
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  		
				AND s.IsLive = cs.islive 
		WHERE cs.CustID = @custid
		ORDER BY s.SubGroupOrder, s.Child_DisplayOrder
	END
	
	--END SB Settings
	----------------------------------------------------------------------------------
			
	----------------------------------------------------------------------------------
	--BEGIN RNG Games	
	--Bet Setting
	IF @GroupID = 2 AND @GroupType = 154
	BEGIN
		;WITH T AS (
		SELECT cs.Sporttype, cs.Bettype, MinBet, MaxBet, MaxPerMatch,MaxPerNumber,s.SubType,s.SubGroupOrder,s.Child_DisplayOrder
		FROM CustBetSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID = @custid 
		UNION ALL
		SELECT cs.Sporttype, cs.Bettype, MinBet, MaxBet, MaxPerMatch,NULL MaxPerNumber,s.SubType,s.SubGroupOrder,s.Child_DisplayOrder
		FROM CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID = @custid
		)
		SELECT Sporttype, Bettype, MinBet, MaxBet, MaxPerMatch,MaxPerNumber,SubType,Child_DisplayOrder
		FROM T
		ORDER BY SubGroupOrder,Child_DisplayOrder
	END
	
	--PT
	IF @GroupID = 2 AND @GroupType = 153
	BEGIN						
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, cs.SuperPT AS S4  
			, cs.MasterPT AS M4  
			, cs.MinPT  AS N4  
			, ft.Child_DisplayOrder
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
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
			, cs.SuperPT AS S4  
			, cs.MasterPT AS M4  
			, cs.MinPT  AS N4 
			, s.Child_DisplayOrder	
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
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
		SELECT cs.Sporttype, cs.Bettype, MinBet, MaxBet, MaxPerMatch,s.Child_DisplayOrder
		FROM CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID = @custid		
		ORDER BY SubGroupOrder,Child_DisplayOrder
	END
	
	--PT
	IF @GroupID = 4 AND @GroupType = 153
	BEGIN					
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, cs.SuperPT AS S4  
			, cs.MasterPT AS M4  
			, cs.MinPT  AS N4 
			, s.Child_DisplayOrder	
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter s 
				ON s.SportType = cs.sporttype  
				AND s.BetType = cs.bettype  
				AND s.IsLive = cs.islive
		WHERE cs.CustID = @custid
		ORDER BY SubGroupOrder,Child_DisplayOrder	
	END
	--END Others Games
	----------------------------------------------------------------------------------
		
	DROP TABLE #SportBettypeFilter
END
