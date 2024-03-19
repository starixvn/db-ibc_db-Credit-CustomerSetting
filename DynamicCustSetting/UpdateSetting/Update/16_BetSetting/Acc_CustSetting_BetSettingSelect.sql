/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20171010@Elodie
	Task : Get SMA Bet setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revisions: 
		- 20171017@Elodie: Implementing BetSetting Plugin - [Redmine #83729]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
		
*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	DECLARE @BetSettingUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype)
	SELECT SportType,Bettype 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,16,@SettingStatus)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID
	
	IF @RoleID BETWEEN 1 AND 3
	BEGIN
		INSERT INTO @BetSettingUnlimit
		SELECT cs.SportType,cs.BetType,
				CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
							OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE cs.custid = @SuperID AND ps.Currency = @Currency
	END

	IF @RoleID = 4
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerMatch,				
				pbs.MinBet AS MinBetMin,
				pbs.MaxBet AS MaxBetMax,
				pbs.MaxPerMatch AS MaxPerMatchMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID

	ELSE IF @RoleID = 3
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerMatch,
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MinBet
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MaxBet 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax,  
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MaxPerMatch 
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END)) AS t(MaxPerMatch)) END AS MaxPerMatchMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
	ELSE IF @RoleID = 2
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerMatch,

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MAX(MinBet) FROM (VALUES (sbl.MinBet), (mbl.MinBet)) AS t(MinBet)) 
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxBet) FROM (VALUES (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END)) AS t(MaxBet)) 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax,  

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxPerMatch) FROM (VALUES (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END), (CASE WHEN mbl.MaxPerMatch = 0 THEN NULL ELSE mbl.MaxPerMatch END)) AS t(MaxPerMatch)) 
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END), (CASE WHEN mbl.MaxPerMatch = 0 THEN NULL ELSE mbl.MaxPerMatch END)) AS t(MaxPerMatch)) END AS MaxPerMatchMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID
	ELSE IF @RoleID = 1
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				bl.MaxPerMatch AS MaxPerMatch,

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MAX(MinBet) FROM (VALUES (sbl.MinBet), (mbl.MinBet), (abl.MinBet)) AS t(MinBet))
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet), (abl.MinBet)) AS t(MinBet)) END AS MinBetMin, 
						 
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxBet) FROM (VALUES (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END), (CASE WHEN abl.MaxBet = 0 THEN NULL ELSE abl.MaxBet END)) AS t(MaxBet))
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END), (CASE WHEN abl.MaxBet = 0 THEN NULL ELSE abl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax,  

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxPerMatch) FROM (VALUES (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END), (CASE WHEN mbl.MaxPerMatch = 0 THEN NULL ELSE mbl.MaxPerMatch END), (CASE WHEN abl.MaxPerMatch = 0 THEN NULL ELSE abl.MaxPerMatch END)) AS t(MaxPerMatch))
						ELSE (SELECT MIN(MaxPerMatch) FROM (VALUES (pbs.MaxPerMatch), (CASE WHEN sbl.MaxPerMatch = 0 THEN NULL ELSE sbl.MaxPerMatch END), (CASE WHEN mbl.MaxPerMatch = 0 THEN NULL ELSE mbl.MaxPerMatch END), (CASE WHEN abl.MaxPerMatch = 0 THEN NULL ELSE abl.MaxPerMatch END)) AS t(MaxPerMatch)) END AS MaxPerMatchMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK) ON ft.SportType = abl.sporttype AND ft.BetType = abl.bettype
			INNER JOIN dbo.ProductBetSetting pbs ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID AND abl.CustID = @AgentID

	DROP TABLE #SportBettypeFilter
END
GO