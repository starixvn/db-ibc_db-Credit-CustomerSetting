/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
	, @SystemID	TINYINT = 1
AS
/*
	Created: 20201118@Eden
	Task : Get SMA Bet setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revisions: 
		- 20201118@Eden: Insert New SettingType = 20 [Redmine: #131370]
		- 20201214@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221006@Winfred: Don't show setting of products which are not offered to a credit site [Redmine: #174744]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
		- @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
		
*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT, 
			@Siteid		INT

	DECLARE @BetSettingUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
		,	@Siteid		= s.siteid
	FROM	dbo.Customer AS c WITH(NOLOCK)
		INNER JOIN Site s  WITH(NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT)

	IF @SystemID IN (2, 4)
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype)
		SELECT a.SportType, a.Bettype 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,20,@SettingStatus) a
			INNER JOIN dbo.f_CustSetting_ProductHiddenStatusSettingSelect(@ProductID,@Siteid,@currency,20,@SettingStatus) b ON a.SportType  = b.SportType AND a.Bettype = b.Bettype AND a.IsLive = b.IsLive
	END
	ELSE
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype)
		SELECT SportType,Bettype 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,20,@SettingStatus)
	END
	
	IF @RoleID BETWEEN 1 AND 3
	BEGIN
		INSERT INTO @BetSettingUnlimit
		SELECT s.SportType,s.BetType,
				CASE WHEN ps.MinBet = 0 AND ps.MaxBet = 0 THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM #SportBettypeFilter s 
			INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK)  ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE ps.Currency = @Currency
	END
	IF @RoleID = 4 
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,			
				pbs.MinBet AS MinBetMin,
				pbs.MaxBet AS MaxBetMax
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.ProductBetSetting pbs WITH (NOLOCK) ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID

	ELSE IF @RoleID = 3
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MinBet
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN sbl.MaxBet 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs WITH (NOLOCK) ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
	ELSE IF @RoleID = 2
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MAX(MinBet) FROM (VALUES (sbl.MinBet), (mbl.MinBet)) AS t(MinBet)) 
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet)) AS t(MinBet)) END AS MinBetMin,  

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxBet) FROM (VALUES (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END)) AS t(MaxBet)) 
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.ProductBetSetting pbs WITH (NOLOCK) ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID
	ELSE IF @RoleID = 1
		SELECT	ft.SportType,
				ft.BetType,
				bl.MinBet,
				bl.MaxBet,
				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MAX(MinBet) FROM (VALUES (sbl.MinBet), (mbl.MinBet), (abl.MinBet)) AS t(MinBet))
						ELSE (SELECT MAX(MinBet) FROM (VALUES (pbs.MinBet), (sbl.MinBet), (mbl.MinBet), (abl.MinBet)) AS t(MinBet)) END AS MinBetMin, 

				CASE	WHEN bu.IsAllowUnlimit = 1 THEN (SELECT MIN(MaxBet) FROM (VALUES (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END), (CASE WHEN abl.MaxBet = 0 THEN NULL ELSE abl.MaxBet END)) AS t(MaxBet))
						ELSE (SELECT MIN(MaxBet) FROM (VALUES (pbs.MaxBet), (CASE WHEN sbl.MaxBet = 0 THEN NULL ELSE sbl.MaxBet END), (CASE WHEN mbl.MaxBet = 0 THEN NULL ELSE mbl.MaxBet END), (CASE WHEN abl.MaxBet = 0 THEN NULL ELSE abl.MaxBet END)) AS t(MaxBet)) END AS MaxBetMax
		FROM #SportBettypeFilter ft 
			INNER JOIN @BetSettingUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustBetSetting3rd_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.CustBetSetting3rd_Agent abl WITH (NOLOCK) ON ft.SportType = abl.sporttype AND ft.BetType = abl.bettype
			INNER JOIN dbo.ProductBetSetting pbs WITH (NOLOCK) ON pbs.SportType = bl.sporttype AND pbs.BetType = bl.bettype AND pbs.Currency = @Currency
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID AND abl.CustID = @AgentID

	DROP TABLE #SportBettypeFilter
END
GO