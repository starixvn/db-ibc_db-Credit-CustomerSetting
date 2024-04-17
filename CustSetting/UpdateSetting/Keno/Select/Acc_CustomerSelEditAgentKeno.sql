/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentKeno]
	@custid INT
AS
/*
	Created: 20140319@Patrick
	Task: Master edits agent's Keno setting
	DB: DBCust/CustDB
	
	Revisions:
		- 20150608@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
		- 20180115@Johnson: Remove downlines status for new direction change[RedmineID: #87328]
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20230314@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]

	Parameters Explanation
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @mrecommend INT, @srecommend INT, @currency INT, @DisableAutoMPT BIT
	SELECT @mrecommend = mrecommend, @srecommend = srecommend, @currency = currency FROM dbo.CustInfo WITH (NOLOCK) WHERE CustId = @custid

	----- 20150608@Kos -------------------
	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)

	BEGIN TRY
		INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
		SELECT GameTypeID, IBCBetTypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0
	END TRY
	BEGIN CATCH
		INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
		SELECT GameTypeID, IBCBetTypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0
	END CATCH
	----- 20150608@Kos -------------------
	
	DECLARE @MasterDisabled TABLE (gametypeid INT, IsDisabled BIT)
	INSERT INTO @MasterDisabled (gametypeid, IsDisabled)
	SELECT cg.gametypeid, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.CustID = @mrecommend

	--Get Min, Max, Max PerMatch of upline
	DECLARE @MasterSetting TABLE (GameTypeID INT, MinBet_Min MONEY, MaxBet_Max MONEY, MaxPerMatch_Max MONEY)
	INSERT INTO @MasterSetting(GameTypeID, MinBet_Min, MaxBet_Max, MaxPerMatch_Max)
	SELECT cg.GameTypeID
		, ISNULL(MAX(CASE WHEN cg.MinBet = 0 THEN NULL ELSE cg.MinBet END), 0) AS MinBet_Min
		, ISNULL(MIN(CASE WHEN cg.MaxBet = 0 THEN NULL ELSE cg.MaxBet END), 0) AS MaxBet_Max
		, ISNULL(MIN(CASE WHEN cg.MaxPerGameType = 0 THEN NULL ELSE cg.MaxPerGameType END), 0) AS MaxperMatch_Max		
	FROM dbo.CustGameType cg WITH(NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID		
	WHERE cg.custid IN (@srecommend, @mrecommend) 
	GROUP BY cg.GameTypeID

	--Disable auto master PT
	SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT ,0)
	FROM CustMaster WITH (NOLOCK) 
	WHERE CustID = @Mrecommend

	--Get custinfo
	SELECT username, firstname, lastname, phone, mobilephone, fax, @DisableAutoMPT as DisableAutoMPT, c.site, s.SiteLabel
	FROM dbo.Customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custID = @CustID

	--BetSetting & Enable status
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType
		, CASE WHEN ul.MinBet_Min < bs.MinBet THEN bs.MinBet ELSE ul.MinBet_Min END MinBet_Min
		, ul.MaxBet_Max, ul.MaxPerMatch_Max
		, cg.IsDisabled
		, md.IsDisabled AS DisableUplinesKeno		
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @MasterSetting ul ON cg.GameTypeID = ul.GameTypeID
		INNER JOIN @MasterDisabled md ON cg.GameTypeID = md.GameTypeID
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID		
		INNER JOIN ProductBetSetting bs ON gt.IBCBetTypeID = bs.bettype AND bs.sporttype = 202 AND Currency = @Currency	AND IsDep = 0
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--PT
	SELECT cs.BetType
		, ISNULL(cs.discount, 0) AS discount
		, ISNULL(mcs.adiscount, 0) AS discount_max
		, cs.apositiontaking AS a2 --a2
		, cs.mpositiontaking AS m2 --m2
		, cs.autompositiontaking AS u2 --u2
		, cs.isautompositiontaking AS i2 --i2
		, co.minpositiontaking AS n2 --n2
		
		, mco.minpositiontaking AS n3		
		, mcs.mpositiontaking AS m3 --m3
	FROM dbo.custsettingGame cs WITH(NOLOCK)
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN dbo.custsettingGame mcs WITH(NOLOCK) ON mcs.CustID = @mrecommend AND cs.bettype = mcs.bettype AND cs.Sporttype = mcs.sporttype
		INNER JOIN dbo.custoverrideGame mco WITH(NOLOCK) ON mco.CustID = @mrecommend AND cs.bettype = mco.bettype AND cs.Sporttype = mco.sporttype
		INNER JOIN dbo.custoverrideGame co WITH(NOLOCK) ON cs.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
	WHERE cs.custid = @custid AND cs.bettype BETWEEN 1501 AND 1599 AND cs.sporttype = 202

END
GO