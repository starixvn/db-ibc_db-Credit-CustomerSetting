/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperKeno]
	@CustID		INT
AS
/*
	Created: Elodie
	Date: 20140225
	Task: Select super's Keno setting
	DB: DBCust/CustDB
		
	Revisions:
		- 20150608@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
		- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
		- 20180115@Johnson: Remove downlines status for new direction change[RedmineID: #87328]
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20230314@Tacy: NAP/Alpha - Split 789y site [RedmineID: #181596]

	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON

	----- 20150608@Kos -------------------
	DECLARE @GameType TABLE (GameTypeID INT, IBCBetTypeID INT)
	DECLARE @currency INT
	
	BEGIN TRY
		INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
		SELECT GameTypeID, IBCBetTypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0
	END TRY
	BEGIN CATCH
		INSERT INTO @GameType (GameTypeID, IBCBetTypeID)
		SELECT GameTypeID, IBCBetTypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK) WHERE IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0
	END CATCH
	----- 20150608@Kos -------------------

	SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid

	--Customer Info
	SELECT c.username, c.firstname, c.lastname, c.phone, c.mobilephone, c.fax, c.site, s.SiteLabel
	FROM dbo.Customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE c.custID = @CustID 

	--BetSetting & Enable status
	SELECT	gt.IBCBetTypeID, 
			cg.MinBet, 
			bs.MinBet AS MinBet_Min,			
			cg.MaxBet, 
			cg.MaxPerGameType, 
			cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID		
		INNER JOIN ProductBetSetting bs ON gt.IBCBetTypeID = bs.bettype AND bs.sporttype = 202 AND Currency = @Currency	AND IsDep = 0
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--PT & commission
	SELECT	cs.Bettype,
			cs.spositiontaking as s4, --s4
			co.minpositiontaking as n4, --n4
			gs.MaxPositiontaking as l4, --l4
			cs.sdiscount,
			gs.Maxsdiscount
	FROM dbo.CustSettingGame cs WITH (NOLOCK)
		INNER JOIN dbo.CustOverrideGame co WITH (NOLOCK) ON cs.CustID = co.CustID AND cs.Bettype = co.Bettype AND cs.Sporttype = co.Sporttype
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN ProductGlobalSetting gs ON gt.IBCBetTypeID = gs.bettype AND gs.sporttype = co.Sporttype AND IsDep = 0
	WHERE cs.CustID = @CustID AND cs.Bettype BETWEEN 1501 AND 1599 AND cs.Sporttype = 202
	ORDER BY cs.Bettype
END
GO
