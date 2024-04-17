/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_SiteCurrencySettingInfoSel] 
	@Currency INT = 0,
	@Site VARCHAR(50) ='',
	@GroupID INT = 0,
	@GroupType INT = 0,
	@SettingStatus TINYINT = 0
AS
/*
	Created by: 20230920@Eden	
	Task: Select site currency setting for create super
	DB: DBCUST.CustDB
	
	Revisions:
		- 20230920@Eden: initial sp [redmine: #193083]
		
	Parameter's explaination:
		- @GroupID: 1: SB
		- @GroupType: group setting Type
		- @GroupID = 0 & @GroupType = 0: General info

	Examples:
		EXEC [Acc_CustSetting_SiteCurrencySettingInfoSel]
			  @Currency = 20
			, @Site = 'BEST-ODDS'
			, @GroupID = 1
			, @GroupType = 150
			, @SettingStatus = 3
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @siteID SMALLINT
		
	SELECT  @SiteID = s.siteID
	FROM Site s WITH (NOLOCK) 
	WHERE s.site = @site

	
	CREATE TABLE #SportBettypeFilter(SportType SMALLINT,Bettype SMALLINT, IsLive BIT, ProductID TINYINT
									, IntervalValue DECIMAL(9,8), SubType TINYINT, Child_DisplayOrder INT
									, MaxPT smallmoney, MaxDiscount	decimal(9,8)
									, SubGroupID TINYINT,SubGroupOrder TINYINT
									)
		
	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,MaxDiscount,MaxPT,SubGroupID,SubGroupOrder)
	SELECT SportType,Bettype,IsLive,ProductID,IntervalValue,SubType,Child_DisplayOrder,MaxDiscount,MaxPT,SubGroupID,SubGroupOrder
	FROM dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID, @GroupType,NULL,@SettingStatus,@siteID,@currency) 

	----------------------------------------------------------------------------------
	--BEGIN SB Settings
	
	--comm SB
	IF  @GroupID = 1 AND @GroupType = 150
	BEGIN
		SELECT sporttype, bettype, MaxDiscount AS discount, IntervalValue 
		FROM #SportBettypeFilter t
		ORDER BY t.SubGroupOrder,t.Child_DisplayOrder	
	END
	
	--Bet setting SB
	IF @GroupID = 1 AND @GroupType = 151
	BEGIN				
		SELECT sporttype, bettype, 0 AS MinBet, 0 AS MaxBet, 0 AS MaxPerMatch
				,CASE WHEN SportType IN(43,44) THEN NULL ELSE 0 END AS MaxPayoutPerMatch
		FROM #SportBettypeFilter t
		ORDER BY t.SubGroupOrder,t.Child_DisplayOrder		
	END
	
	--Parlay MaxPayoutPerMatch
	IF @GroupID = 1 AND @GroupType = 152
	BEGIN
		SELECT t.sporttype,t.bettype,
			ISNULL(gl.SingleMatchParlay,0.1) AS SingleMatchParlay,
			ISNULL(gl.Combo2,0.1) AS Combo2,
			ISNULL(gl.Combo35,0.1) AS Combo35,
			ISNULL(gl.ComboOver6,0.1) AS ComboOver6,
			CASE WHEN gl.SportType IS NOT NULL THEN 1 ELSE 0  END AS SingleMatchParlay_IsAllowUnlimit,
			CASE WHEN gl.SportType IS NOT NULL THEN 1 ELSE 0  END  AS Combo2_IsAllowUnlimit,
			CASE WHEN gl.SportType IS NOT NULL THEN 1 ELSE 0  END  AS Combo35_IsAllowUnlimit,
			CASE WHEN gl.SportType IS NOT NULL THEN 1 ELSE 0  END  AS ComboOver6_IsAllowUnlimit
		FROM #SportBettypeFilter t
			LEFT JOIN MaxPayoutGlobalSetting gl WITH(NOLOCK) 
				ON t.SportType = gl.SportType
				AND t.Bettype = gl.BetType
				AND gl.Currency = @Currency
		ORDER BY t.SubGroupOrder,t.Child_DisplayOrder		
	END
	
	--SB PT
	IF @GroupID = 1 AND @GroupType = 153
	BEGIN			
		SELECT t.sporttype,t.bettype,t.IsLive,t.MaxPT AS S4, t.MaxPT AS M4,t.MaxPT AS A4,t.MaxPT AS N4, t.MaxPT as DefaultMaxPT
		FROM #SportBettypeFilter t
		ORDER BY t.SubGroupOrder,t.Child_DisplayOrder	
	END
	
	DROP TABLE #SportBettypeFilter
END
