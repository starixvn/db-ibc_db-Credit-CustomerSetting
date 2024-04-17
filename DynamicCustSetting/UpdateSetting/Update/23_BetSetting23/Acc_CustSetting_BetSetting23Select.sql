/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting23Select] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20221123@Elodie
	Task : Get SMA Bet Limit setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision: 
		- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
		
*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, SubType TINYINT, Child_DisplayOrder TINYINT)

	DECLARE @BetSetting TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, SubType			TINYINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPerNumber		MONEY 
			, MinBetMin			MONEY
			, MaxBetMax			MONEY
			, MaxPerMatchMax	MONEY
			, MaxPerNumberMax   MONEY 
			, Child_DisplayOrder TINYINT
		)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,SubType,Child_DisplayOrder)
	SELECT SportType,Bettype,SubType, Child_DisplayOrder
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,23,@SettingStatus)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 4
	BEGIN
		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				ft.SubType,
				ft.Child_DisplayOrder,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch,
				bl.MaxPerNumber,				
				0 AS MinBetMin,
				0 AS MaxBetMax,
				0 AS MaxPerMatchMax,
				0 AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
		WHERE bl.CustID = @CustID

		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				ft.SubType,
				ft.Child_DisplayOrder,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch,
				NULL AS MaxPerNumber,				
				0 AS MinBetMin,
				0 AS MaxBetMax,
				0 AS MaxPerMatchMax,
				NULL AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
		WHERE bl.CustID = @CustID
	END
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				MAX(bl.MaxPerNumber)AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				ISNULL(MIN(CASE WHEN sbl.MaxPerNumber = 0 then NULL ELSE sbl.MaxPerNumber END),0) AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
		GROUP BY ft.sporttype,ft.bettype

		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				NULL AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				NULL AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
		GROUP BY ft.sporttype,ft.bettype
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				MAX(bl.MaxPerNumber)AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				ISNULL(MIN(CASE WHEN sbl.MaxPerNumber = 0 then NULL ELSE sbl.MaxPerNumber END),0) AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID IN (@SuperID, @MasterID)
		GROUP BY ft.sporttype,ft.bettype

		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				NULL AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				NULL AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID IN (@SuperID, @MasterID)
		GROUP BY ft.sporttype,ft.bettype
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				MAX(bl.MaxPerNumber)AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				ISNULL(MIN(CASE WHEN sbl.MaxPerNumber = 0 then NULL ELSE sbl.MaxPerNumber END),0) AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID IN (@SuperID, @MasterID, @AgentID)
		GROUP BY ft.sporttype,ft.bettype

		INSERT INTO @BetSetting( SportType,BetType,SubType,Child_DisplayOrder			
								,MinBet,MaxBet,MaxPerMatch,MaxPerNumber		
								,MinBetMin,MaxBetMax,MaxPerMatchMax,MaxPerNumberMax)
		SELECT	ft.SportType,
				ft.BetType,
				MAX(ft.SubType) AS SubType,
				MAX(ft.Child_DisplayOrder) AS Child_DisplayOrder,
				MAX(bl.MinBet) AS MinBet,
				MAX(bl.MaxBet) AS MaxBet,
				MAX(bl.MaxPerMatch) AS MaxPerMatch, 
				NULL AS MaxPerNumber,
				ISNULL(MAX(CASE WHEN sbl.MinBet = 0 then NULL ELSE sbl.MinBet END),0) AS MinBetMin,  
				ISNULL(MIN(CASE WHEN sbl.MaxBet = 0 then NULL ELSE sbl.MaxBet END),0) AS MaxBetMax,  
				ISNULL(MIN(CASE WHEN sbl.MaxPerMatch = 0 then NULL ELSE sbl.MaxPerMatch END),0) AS MaxPerMatchMax, 
				NULL AS MaxPerNumberMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID IN (@SuperID, @MasterID, @AgentID)
		GROUP BY ft.sporttype,ft.bettype
	END

	SELECT  t.SportType			
		, t.BetType			
		, t.SubType			
		, t.MinBet			
		, t.MaxBet			
		, t.MaxPerMatch		
		, t.MaxPerNumber		
		, CASE WHEN t.MinBetMin > pbs.MinBet  THEN t.MinBetMin  ELSE pbs.MinBet  END AS MinBetMin	
		, t.MaxBetMax			
		, t.MaxPerMatchMax	
		, t.MaxPerNumberMax   
		, t.Child_DisplayOrder 
	FROM @BetSetting t
		INNER JOIN dbo.ProductBetSetting pbs  WITH(NOLOCK)
			ON pbs.SportType = t.sporttype  
			AND pbs.BetType = t.bettype  
			AND pbs.Currency = @Currency  
	WHERE t.SubType = 1
	UNION ALL
	SELECT  SportType			
		, BetType			
		, SubType			
		, MinBet			
		, MaxBet			
		, MaxPerMatch		
		, MaxPerNumber		
		, MinBetMin			
		, MaxBetMax			
		, MaxPerMatchMax	
		, MaxPerNumberMax   
		, Child_DisplayOrder 
	FROM @BetSetting t
	WHERE t.SubType = 2
	ORDER BY Child_DisplayOrder

	DROP TABLE #SportBettypeFilter
END

GO