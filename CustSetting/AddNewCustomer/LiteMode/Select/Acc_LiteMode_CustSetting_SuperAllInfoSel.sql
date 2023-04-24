/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_SuperAllInfoSel] 
	@CustID INT,
	@Site VARCHAR(50) ='',
	@GroupID INT = 0,
	@GroupType INT = 0,
	@CreationStatus TINYINT = 0
AS
/*
	Created by: 20230419@Johnson	
	Task: Select super setting for create master on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 20230419@Johnson: initial sp [redmine: #179159]
		
	Parameter's explaination:
		- @GroupID: 1: SB, 2: RnG Games, 3: LCS, 4: NG2
		- @GroupType: group setting Type
		- @GroupID = 0 & @GroupType = 0: General info
		- @Site: check @IsMyanmarOdds for Direct Master
*/
BEGIN
	SET NOCOUNT ON
	
	IF @GroupType = 0 OR @GroupType = 150
	BEGIN
		DECLARE @discountMyanmarOdds DECIMAL (9,8),@IsMyanmarOdds BIT = 0
		DECLARE @SiteAgent NVARCHAR(50), @SiteLabel VARCHAR(50)
		
		SELECT @SiteAgent = c.site, @SiteLabel=s.SiteLabel 
		FROM customer c WITH(NOLOCK) 
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		WHERE CustID = @custid

		-- For direct Master
		IF @custid > 100 -- get site FROM upline IF not direct master
		BEGIN
		   SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@SiteAgent)
		END
		ELSE
		BEGIN
			-- For Direct Master
			SET @IsMyanmarOdds = dbo.fn_IsMyanmarOddsBySite(@Site)
		END
		
		IF @IsMyanmarOdds = 1
			SET @discountMyanmarOdds = (SELECT CommRate FROM AgentCommRate WITH (NOLOCK) WHERE CustId = @CustID AND Sporttype = 1 AND Bettype = 1)
	END
	
	--general info
	IF @GroupType = 0
	BEGIN
		DECLARE @UserName VARCHAR(50), 
				@UplineUserName VARCHAR(50),
				@Ssuspended BIT, 
				@IsInternal BIT	
		
		DECLARE @Credit_AllOtherMaster MONEY, 
				@Credit_SAg MONEY, 
				@Credit_MAg_Max MONEY,
				@TransferOption	VARCHAR(8),		
				@CurrencyID INT, 
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
			@CurrencyID=ci.currency,
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
			
		EXEC dbo.Age_CustomerSelSuggestUsername @prefix = @uplineusername,@custid = @custid, @roleid = 4, @seqname = @username output
		
		SELECT 
			@UserName AS NewUserName,
			@Ssuspended AS suspended,
			@Credit_MAg_Max as Credit_Max,
			@TransferOption as TransferOption,
			@IsAutomateTransfer IsAutomateTransfer,
			@IsInternal as IsInternal,	
			@SiteAgent AS Site,
			@SiteLabel AS SiteLabel,
			@IsMyanmarOdds AS IsMyanmarOdds
	END
	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT)
	DECLARE	@Currency	TINYINT
	
	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	
	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		SELECT sporttype, bettype,
			CASE WHEN bettype = 1 THEN groupA
				WHEN bettype = 3 THEN groupB
				WHEN bettype = 7 THEN groupC
				WHEN bettype = 8 THEN groupD
				WHEN bettype IN (4,5) THEN sdiscount END as discount		 
		FROM custsetting WITH(NOLOCK)
		WHERE custid = @custid
			AND sporttype = 1
			AND bettype IN (1,3,7,8,4,5)
		UNION SELECT 2, 1, @discountMyanmarOdds WHERE @IsMyanmarOdds = 1
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType)
		SELECT DISTINCT SportType	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
				
		SELECT sporttype, bettype, MinBet, MaxBet, MaxPerMatch, MaxPayoutPerMatch
		FROM CustBetSetting_Agent WITH(NOLOCK)
		WHERE custid = @custid
			AND sporttype IN (SELECT sporttype FROM #SportBettypeFilter)
		UNION 
		SELECT sporttype, bettype, MinBet, MaxBet, MaxPerMatch, NULL MaxPayoutPerMatch
		FROM CustBetSetting3rd_Agent WITH(NOLOCK)
		WHERE custid = @custid
			AND sporttype IN (SELECT sporttype FROM #SportBettypeFilter)
	END
	
	--Parlay MaxPayoutPerMatch
	IF @GroupID = 1 AND @GroupType = 152
	BEGIN
		DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype)
		SELECT DISTINCT SportType,Bettype 	
		FROM dbo.MaxPayoutGlobalSetting WITH(NOLOCK)
		WHERE SettingStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END  
		
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
						ELSE sbl.SingleMatchParlay END AS Upline_SingleMatchParlay,  
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo2 END AS Upline_Combo2,
				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo35 END AS Upline_Combo35,
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.ComboOver6 END AS Upline_ComboOver6,
				bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
				bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
				bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
				bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit		
		FROM #SportBettypeFilter ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype			
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE sbl.CustID = @custid
	END
	
	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
			
		SELECT cs.sporttype, cs.bettype, 0 IsLive, 
			CASE WHEN cs.spositiontaking<co.maxpositiontaking THEN cs.spositiontaking ELSE co.maxpositiontaking END S4,
			cs.mpositiontaking M4, 
			co.minpositiontaking AS N4			
		FROM CustSetting cs WITH(NOLOCK) 
			LEFT JOIN custoverride as co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype=co.sporttype and cs.bettype=co.bettype
		WHERE cs.CustID = @custid
			AND 1 = case when cs.Sporttype = 2 AND cs.Bettype IN (7,8) THEN 0 ELSE 1 END
		UNION ALL 
		SELECT cs.sporttype, cs.bettype, 1 as IsLive,			
			CASE WHEN cs.slivepositiontaking<co.maxlivepositiontaking THEN cs.slivepositiontaking ELSE co.maxlivepositiontaking END S4,
			cs.mlivepositiontaking M4,
			co.minlivepositiontaking AS N4 
		FROM CustSetting cs WITH(NOLOCK) 
			LEFT JOIN custoverride as co WITH (NOLOCK) ON cs.custid = co.custid AND cs.sporttype=co.sporttype and cs.bettype=co.bettype
		WHERE cs.CustID = @custid
			AND cs.sporttype = 1
			AND cs.bettype IN (1,3,7,8)
		UNION ALL
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
	END
	
	--END SB Settings
	----------------------------------------------------------------------------------
			
	----------------------------------------------------------------------------------
	--BEGIN RNG Games	
	--Bet Setting
	IF @GroupID = 2 AND @GroupType = 154
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
		
		SELECT cs.Sporttype, cs.Bettype, MinBet, MaxBet, MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch
		FROM CustBetSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID = @custid 
		UNION ALL
		SELECT cs.Sporttype, cs.Bettype, MinBet, MaxBet, MaxPerMatch,NULL MaxPerNumber, NULL MaxPayoutPerMatch
		FROM CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.Sporttype = s.SportType
												AND cs.Bettype = s.Bettype
		WHERE cs.CustID = @custid	
	END
	
	--PT
	IF @GroupID = 2 AND @GroupType = 153
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
						
		SELECT cs.SportType  
			, cs.BetType  
			, cs.IsLive  
			, cs.SuperPT AS S4  
			, cs.MasterPT AS M4  
			, cs.MinPT  AS N4  
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON cs.SportType = ft.sporttype
												AND cs.BetType = ft.bettype
												AND cs.IsLive = ft.islive
		WHERE custid = @custid
	END
	
	--WinLoss Limit
	IF @GroupID = 2 AND @GroupType = 155
	BEGIN
		SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid
		--SELECT @ProductID = 44
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT DISTINCT SportType,Bettype,IsLive,ProductID 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
			
		SELECT	wl.SportType,
				wl.BetType,
				wl.MaxWinLimit AS MaxWinRange,				
				gs.MinLossLimit AS MinLossRange,
				wl.MaxLossLimit AS MaxLossRange,
				wl.IsAutoReset AS IsAutoResetUpline				
		FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
		INNER JOIN	#SportBettypeFilter AS sbf
				ON	sbf.Bettype = wl.BetType
				AND	sbf.SportType = wl.SportType
			INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
		WHERE wl.CustId = @CustID 	
	END
	--END RNG Games	
	----------------------------------------------------------------------------------
		
	----------------------------------------------------------------------------------
	--BEGIN Live & RnG Casino
	
	--Comm
	IF @GroupID = 3 AND @GroupType = 156
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
					
		SELECT cs.SportType, cs.Bettype, cs.Discount			
		FROM dbo.CustDiscount3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.SportType = s.sporttype AND cs.BetType = s.bettype  
		WHERE cs.custid = @custid				
	END
	
	--PT
	IF @GroupID = 3 AND @GroupType = 153
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
					
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
	END
	
	--WinLoss Limit
	IF @GroupID = 3 AND @GroupType = 155
	BEGIN
		SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid
				
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT DISTINCT SportType,Bettype,IsLive, ProductID 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
			
		SELECT	wl.SportType,
				wl.BetType,
				wl.MaxWinLimit AS MaxWinRange,				
				gs.MinLossLimit AS MinLossRange,
				wl.MaxLossLimit AS MaxLossRange,
				wl.IsAutoReset AS IsAutoResetUpline				
		FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
		INNER JOIN	#SportBettypeFilter AS sbf
				ON	sbf.Bettype = wl.BetType
				AND	sbf.SportType = wl.SportType
			INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
		WHERE wl.CustId = @CustID 	
	END
	
	--Loss Limit
	IF @GroupID = 3 AND @GroupType = 157
	BEGIN
		SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid
				
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID)
		SELECT DISTINCT SportType,Bettype,IsLive, ProductID 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
			
		SELECT	wl.SportType,
				wl.BetType,				
				gs.MinLossLimit AS MinLossRange,
				wl.MaxLossLimit AS MaxLossRange,
				wl.IsAutoReset AS IsAutoResetUpline				
		FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
		INNER JOIN	#SportBettypeFilter AS sbf
				ON	sbf.Bettype = wl.BetType
				AND	sbf.SportType = wl.SportType
			INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
		WHERE wl.CustId = @CustID 
	END
	
	--END Live & RnG Casino
	----------------------------------------------------------------------------------
		
	----------------------------------------------------------------------------------
	--BEGIN NG2	
	--Comm
	IF @GroupID = 4 AND @GroupType = 158
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
					
		SELECT cs.SportType, cs.Bettype, cs.Discount			
		FROM dbo.CustDiscount3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON cs.SportType = s.sporttype AND cs.BetType = s.bettype  
		WHERE cs.custid = @custid	
	END
	
	--Bet Setting
	IF @GroupID = 4 AND @GroupType = 159
	BEGIN
		DECLARE @BetGameUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)
		
		SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid
		
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
		
		INSERT INTO @BetGameUnlimit
		SELECT cs.SportType,cs.BetType,
				CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
							OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE cs.custid = @custid AND ps.Currency = @Currency 	
		
		SELECT	ft.SportType,
				ft.BetType,				
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MinBet
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MaxBet 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax,  
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MaxPerMatch 
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END)) AS t(MaxPerMatch)) END AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetGameUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype			
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = sbl.sporttype AND pbs.BetType = sbl.bettype AND pbs.Currency = @Currency
		WHERE sbl.CustID = @custid
	END
	
	--PT
	IF @GroupID = 4 AND @GroupType = 160
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive)
		SELECT DISTINCT SportType,Bettype,IsLive 	
		FROM dbo.f_LiteMode_CustSetting_SportBetFilterSelect(@GroupID, @GroupType, @CreationStatus) 
					
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
	END
	--END NG2
	----------------------------------------------------------------------------------
	
END
