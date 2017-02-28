ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerKeno]
	@custid		INT
AS
/*
	Created: 20140317@Patrick	
	Task: Master edit setting of Keno on member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameters Explanation:
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

	DECLARE @srecommend INT, @mrecommend INT, @recommend INT, @DisableAutoMPT BIT		
	
	--PT
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend
	FROM dbo.custinfo WITH (NOLOCK) WHERE custid = @custid

	--Disable auto master PT
	SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT,0)
	FROM CustMaster WITH (NOLOCK) 
	WHERE CustID = @mrecommend

	--Customer Info
	SELECT username, firstname, lastname, phone, mobilephone, fax, @DisableAutoMPT as DisableAutoMPT
	FROM dbo.Customer WITH (NOLOCK)
	WHERE custID = @CustID

	--BetSetting
	SELECT gt.IBCBetTypeID, cg.MinBet, cg.MaxBet, cg.MaxPerGameType, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID
	WHERE cg.CustID = @CustID and gt.IBCBetTypeID BETWEEN 1501 AND 1599 AND gt.IsDisabled = 0
	ORDER BY gt.IBCBetTypeID

	--Get master PT value
	SELECT cs.bettype
		, cs.apositiontaking AS a1
		, cs.mpositiontaking AS m1
		, cs.isautompositiontaking AS im1
		, cs.autompositiontaking AS um1
		, csa.isautompositiontaking  AS im2
		, csm.mpositiontaking AS um1_max --um1_max=min(m3,m4)

		, CASE WHEN NOT (cs.isautopositiontaking = 0 AND csm.isautopositiontaking = 0)
			THEN csm.mpositiontaking - cs.apositiontaking 
			ELSE CASE WHEN csm.mpositiontaking - cs.apositiontaking <= css.spositiontaking - cs.spositiontaking - cs.apositiontaking 
				THEN csm.mpositiontaking - cs.apositiontaking 
				ELSE css.spositiontaking - cs.spositiontaking - cs.apositiontaking END 
			END AS m1_max --!(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)--> m1_max
		, CASE WHEN sco.minpositiontaking - cs.apositiontaking < 0 THEN 0 
			ELSE sco.minpositiontaking - cs.apositiontaking END AS m1_min --m1_min=um1_min=Max(0, N3-A1)
		, CASE WHEN sco.minpositiontaking - cs.apositiontaking < 0 THEN 0 
			ELSE sco.minpositiontaking - cs.apositiontaking END AS um1_min --m1_min=um1_min=Max(0, N3-A1)
	FROM dbo.CustSettingGame AS cs WITH (NOLOCK)
		INNER JOIN @tmp_GameType gt ON cs.Bettype = gt.IBCBetTypeID
		INNER JOIN dbo.CustSettingGame csa WITH (NOLOCK) ON csa.custid = @recommend AND csa.bettype = cs.bettype AND csa.sporttype = cs.sporttype 
		INNER JOIN dbo.CustSettingGame csm WITH (NOLOCK) ON csm.custid = @mrecommend AND csm.bettype = cs.bettype AND csm.sporttype = cs.sporttype 
		INNER JOIN dbo.CustSettingGame css WITH (NOLOCK) ON css.custid = @srecommend AND css.bettype = cs.bettype AND css.sporttype = cs.sporttype 
		INNER JOIN dbo.CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @mrecommend AND sco.bettype = cs.bettype AND sco.sporttype = cs.sporttype
	WHERE cs.custid = @custId 
		AND cs.bettype BETWEEN 1501 AND 1599
		AND cs.sporttype = 202
		AND IBCBetTypeID BETWEEN 1501 AND 1599 AND IsDisabled = 0

END




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerKeno] TO [vnteam] AS [dbo]
GO


