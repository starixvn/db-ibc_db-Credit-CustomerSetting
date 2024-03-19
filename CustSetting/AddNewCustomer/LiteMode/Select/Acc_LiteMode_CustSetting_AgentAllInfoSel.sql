/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_AgentAllInfoSel] 
	@CustID INT,		
	@GroupID INT = 0,
	@GroupType INT = 0,
	@CreationStatus TINYINT = 0
AS
/*
	Created by: 2023710@Johnson	
	Task: Select agent setting for create member on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 2023710@Johnson: initial sp [redmine: #179159]
		- 20231204@Johnson: Sort SubGroup [redmine: #197629]
		- 20240118@Eden: avoid data duplicate of Esport & Muay Thai Betsetting [redmine: #199970]
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
	
	IF @GroupType = 0 OR @GroupType = 150
	BEGIN
		DECLARE @discountMyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0
		
		SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@srecommend)
		
		IF @IsMyanmarOdds = 1
		BEGIN
			SET @discountMyanmarOdds = ISNULL((SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1),0)
		END	
	END	
	
	IF @GroupType = 0
	BEGIN
		DECLARE @UserName VARCHAR(50), 				
				@Asuspended BIT, 
				@UplineClosed BIT, 
				@Credit_AllOtherMember MONEY, 
				@Credit_Ag MONEY,
				@Credit_Mem_Max MONEY, 
				@Credit_Ag_Bal MONEY,
				@MaxCredit_Mem MONEY
		
		SELECT @Credit_AllOtherMember = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE recommend = @CustID 
			AND RoleID = 1

		SELECT	@Credit_Ag = isnull(credit, 0),
				@Asuspended = cs.reject , 
				@UplineClosed = cs.closed
		FROM CustInfo as ci with (NOLOCK) 
			CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
												, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
											FROM dbo.CustProductStatus  WITH(NOLOCK)
											WHERE CustID = ci.custid
										) AS cs
		WHERE CustID = @CustID

		SELECT @MaxCredit_Mem = isnull(maxcredit,0) 
		FROM CustAgent WITH (NOLOCK) 
		WHERE CustID = @CustID

		SELECT @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT @Credit_Mem_Max = CASE WHEN @MaxCredit_Mem =0  THEN @Credit_Ag_Bal 
									  WHEN @MaxCredit_Mem > @Credit_Ag_Bal THEN @Credit_Ag_Bal
									  ELSE @MaxCredit_Mem END 

		EXEC dbo.Age_CustomerSelSuggestUsername @prefix = @uplineusername,@custid = @custid, @roleid = 2, @seqname = @username output
				
		SELECT @UplineUsername as UplineUsername,
			@UserName as NewUserName,
			@Asuspended as suspended, 
			@UplineClosed as closed,
			@Credit_Mem_Max as Credit_Max,
			@site AS Site,
			@SiteLabel AS SiteLabel,
			@currency currency
	END
	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT, IntervalValue DECIMAL(9,8), SubType TINYINT, Child_DisplayOrder INT,SubGroupID TINYINT,SubGroupOrder TINYINT)
		
	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder)
	SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,SubGroupID,SubGroupOrder
	FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType,NULL,@CreationStatus,@siteID,@currency) 
	
	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	
	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		WITH T AS(
		SELECT sporttype, bettype,
			CASE WHEN bettype = 1 THEN groupA				
				WHEN bettype IN (4,5) THEN discount END as discount		 
		FROM custsetting WITH(NOLOCK)
		WHERE custid = @custid
			AND sporttype = 1
			AND bettype IN (1,4,5)
		UNION SELECT 2, 1, @discountMyanmarOdds WHERE @IsMyanmarOdds = 1
		)
		SELECT T.*, s.IntervalValue,s.Child_DisplayOrder
		FROM T
		INNER JOIN #SportBettypeFilter s ON t.sporttype = s.sporttype
											AND t.bettype = s.bettype
		ORDER BY SubGroupOrder, s.Child_DisplayOrder									
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN			
		;WITH T AS(
		SELECT cs.sporttype, cs.bettype, 
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 
			ISNULL(MIN(CASE WHEN cs.MaxPayoutPerMatch = 0 THEN NULL ELSE cs.MaxPayoutPerMatch END),0) MaxPayoutPerMatch,		
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustBetSetting_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.sporttype = s.sporttype
												AND cs.bettype = s.bettype
												AND s.SportType NOT IN(43,44)
		WHERE custid IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype,s.SubGroupOrder, s.Child_DisplayOrder
		UNION
		SELECT cs.sporttype, cs.bettype, 
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch,
			NULL MaxPayoutPerMatch, 
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustBetSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN #SportBettypeFilter s ON cs.sporttype = s.sporttype
												AND cs.bettype = s.bettype
		WHERE custid IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubGroupOrder, s.Child_DisplayOrder
		)
		SELECT sporttype, bettype, MinBet, MaxBet, MaxPerMatch, MaxPayoutPerMatch, Child_DisplayOrder
		FROM T
		ORDER BY SubGroupOrder,Child_DisplayOrder
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
		ORDER BY SubGroupOrder,ft.Child_DisplayOrder
	END
	
	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN
		;WITH T AS (
		SELECT cs.sporttype, cs.bettype, 0 IsLive, 
			(CASE WHEN cs.apositiontaking<co.maxpositiontaking 
				THEN CASE WHEN cs.apositiontaking < scs.apositiontaking THEN cs.apositiontaking 
						ELSE scs.apositiontaking END 
				ELSE CASE WHEN co.maxpositiontaking < scs.apositiontaking THEN co.maxpositiontaking 
						ELSE scs.apositiontaking END 
				END)*100 as A2,
			co.minpositiontaking*100 as N2,
			SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustSetting as cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
												AND s.BetType = cs.bettype
												AND s.IsLive = 0
			INNER JOIN custsetting as scs WITH(NOLOCK) ON scs.custid = @srecommend 
														AND cs.sporttype = scs.sporttype 
														AND cs.bettype = scs.bettype
			INNER JOIN custoverride as co WITH (NOLOCK) ON co.custid = cs.custid 
														AND co.sporttype = cs.sporttype 
														AND co.bettype = cs.bettype	
		WHERE cs.CustID = @CustID			
		UNION 
		SELECT cs.sporttype, cs.bettype, 1 IsLive, 
			(CASE WHEN cs.alivepositiontaking<co.maxlivepositiontaking 
				THEN CASE WHEN cs.alivepositiontaking < scs.alivepositiontaking THEN cs.alivepositiontaking 
						ELSE scs.alivepositiontaking END 
				ELSE CASE WHEN co.maxlivepositiontaking < scs.alivepositiontaking THEN co.maxlivepositiontaking 
						ELSE scs.alivepositiontaking END 
				END)*100 as A2,
			co.minlivepositiontaking*100 as N2,
			SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustSetting as cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.sporttype  
												AND s.BetType = cs.bettype
												AND s.IsLive = 1
			INNER JOIN custsetting as scs WITH(NOLOCK) ON scs.custid = @srecommend 
														AND cs.sporttype = scs.sporttype 
														AND cs.bettype = scs.bettype
			INNER JOIN custoverride as co WITH (NOLOCK) ON co.custid = cs.custid 
														AND co.sporttype = cs.sporttype 
														AND co.bettype = cs.bettype	
		WHERE cs.CustID = @CustID
			AND cs.sporttype = 1
			AND cs.bettype IN (1,3,7,8)
		UNION
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive 
			, CASE WHEN cs.AgentPT < scs.AgentPT THEN cs.AgentPT ELSE scs.AgentPT END as A2 
			, cs.MinPT  AS N2 
			, SubGroupOrder
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
		)
		SELECT SportType  
			, BetType  
			, IsLive 
			, A2
			, N2
			, Child_DisplayOrder
		FROM T
		ORDER BY Child_DisplayOrder
	END
	--END SB Settings
	----------------------------------------------------------------------------------
			
	----------------------------------------------------------------------------------
	--BEGIN RNG Games	
	--Bet Setting
	IF @GroupID = 2 AND @GroupType = 154
	BEGIN
		;WITH T AS (
		SELECT cs.sporttype, cs.bettype, 
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 
			CASE WHEN cs.Sporttype = 161 THEN 
					ISNULL(MIN(CASE WHEN cs.MaxPerNumber = 0 THEN NULL ELSE cs.MaxPerNumber END),0) 
					ELSE NULL END MaxPerNumber,	
			s.SubType,
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustBetSetting_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.sporttype = s.sporttype
												AND cs.bettype = s.bettype
		WHERE custid IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubType,SubGroupOrder, s.Child_DisplayOrder
		UNION ALL
		SELECT cs.Sporttype, cs.Bettype,
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 
			NULL MaxPerNumber,
			s.SubType,
			s.SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubType,SubGroupOrder, s.Child_DisplayOrder
		)
		SELECT Sporttype, Bettype, MinBet, MaxBet, MaxPerMatch, MaxPerNumber, SubType, Child_DisplayOrder
		FROM T
		ORDER BY SubGroupOrder,Child_DisplayOrder
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
	
	--Bet Setting
	IF @GroupID = 4 AND @GroupType = 157
	BEGIN
		;WITH T AS (
		SELECT cs.Sporttype, cs.Bettype,
			ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0)  AS MinBet, 
			ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) AS MaxBet, 
			ISNULL(MIN(CASE WHEN cs.MaxPerMatch = 0 THEN NULL ELSE cs.MaxPerMatch END),0) MaxPerMatch, 			
			SubGroupOrder,
			s.Child_DisplayOrder
		FROM CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID IN (@custid,@srecommend,@mrecommend)
		GROUP BY cs.sporttype, cs.bettype, s.SubType, SubGroupOrder,s.Child_DisplayOrder
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
			
	DROP TABLE #SportBettypeFilter
END	