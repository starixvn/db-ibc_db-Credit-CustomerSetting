ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerKeno]
	@CustID		INT
AS
/*
	Created: 20140317@Patrick
	Task: Super edit setting Keno on member
	DB: DBCUST.CustDB
		
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON

	----- 20150610@Kos -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)	

	BEGIN TRY
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
	-----20150610@Kos -------------------

	DECLARE @srecommend INT, @mrecommend INT
	
	--Customer Info
	SELECT username, firstname, lastname, phone, mobilephone, fax
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID

	--BetSetting
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID
	WHERE cg.CustID = @CustID AND gt.IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID

	--PT
	SELECT @srecommend = srecommend, @mrecommend = mrecommend
	FROM dbo.custinfo WITH(NOLOCK) WHERE custid = @custid
	
	SELECT cs.bettype
		, cs.apositiontaking AS a1
		, cs.mpositiontaking AS m1
		, cs.spositiontaking AS s1
		, cs.isautopositiontaking AS is1
		, cs.autopositiontaking AS us1
		, mcs.isautopositiontaking AS is3
		, scs.spositiontaking AS us1_max
		, CASE WHEN scs.spositiontaking - mcs.mpositiontaking > sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking)
				THEN scs.spositiontaking - mcs.mpositiontaking
				ELSE sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking) END AS s1_max --s1_max = Max(N4-M1-A1, S4-M3)
		,CASE WHEN sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking) < 0 
				THEN 0
				ELSE sco.minpositiontaking - (cs.mpositiontaking + cs.apositiontaking) END AS s1_min --s1_min = Max(0, N4-M1-A1)
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN @tmp_GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN dbo.CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.bettype = cs.bettype AND mcs.sporttype = cs.sporttype
		INNER JOIN dbo.CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.bettype = cs.bettype AND scs.sporttype = cs.sporttype
		INNER JOIN dbo.CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.bettype = cs.bettype AND sco.sporttype = cs.sporttype
	WHERE cs.custid = @custid
		AND cs.bettype BETWEEN 1501 AND 1599
		AND cs.sporttype = 202
		AND IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerKeno] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerKeno] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerKeno] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSEditCustomerKeno] TO [vnteam] AS [dbo]


