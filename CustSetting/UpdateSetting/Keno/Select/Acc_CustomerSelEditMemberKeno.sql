ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberKeno] 
	@CustID INT
AS
/*
	Created: Bobby
	Date: 20140225
	Task: Select member's Keno setting
	DB: DBCust/CustDB
		
	Revisions:
		- 20150608@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
	Parameters Explanations:
			
*/
BEGIN
	SET NOCOUNT ON

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

	DECLARE @srecommend INT, @mrecommend INT, @recommend INT, @currency INT
	SELECT @srecommend = srecommend, @mrecommend = mrecommend, @recommend = recommend, @currency = currency
	FROM dbo.custinfo WITH (NOLOCK)
	WHERE custid = @CustID

	DECLARE @AgentDisabled TABLE (gametypeid INT, IsDisabled BIT)
	INSERT INTO @AgentDisabled (gametypeid, IsDisabled)
	SELECT cg.gametypeid, cg.IsDisabled
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.CustID = @recommend

	--calculate min, max for minbet, maxbet, maxpermatch
	DECLARE @AgentSetting TABLE (
		gametypeid INT
		,MinBet_Min MONEY
		,Maxbet_Max MONEY
		,MaxPerMatch_Max MONEY
		)

	INSERT INTO @AgentSetting (
		Gametypeid
		,MinBet_Min
		,Maxbet_Max
		,MaxPerMatch_Max
		)
	SELECT gt.GameTypeID
		,ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END), 0) AS MinBet_Min
		,ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END), 0) AS Maxbet_Max
		,ISNULL(MIN(CASE WHEN MaxPerGameType = 0 THEN NULL ELSE MaxPerGameType END), 0) AS MaxPerMatch_Max
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.gametypeid = gt.gametypeid
	WHERE cg.custid IN (@srecommend, @mrecommend, @recommend)
	GROUP BY gt.GameTypeID

	--setting upline
	DECLARE @AgentPT TABLE (	
			bettype				INT,	
			apositiontaking		SMALLMONEY,--a2
			minpositiontaking	SMALLMONEY--a2_min			
	)
	--a2=min(a2,l2,a4)
	--n2
	INSERT INTO @AgentPT (
			bettype, 
			apositiontaking, 
			minpositiontaking 					
	)
	SELECT acs.bettype,
			CASE WHEN acs.apositiontaking<scs.apositiontaking
					THEN acs.apositiontaking
					ELSE scs.apositiontaking 
				END AS apositiontaking, 	
			aco.minpositiontaking					
	FROM custinfo ci WITH(NOLOCK)
		INNER JOIN custsettingGame acs WITH(NOLOCK) ON ci.custid = acs.custid 
		INNER JOIN custoverrideGame aco WITH(NOLOCK) ON ci.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
		INNER JOIN custsettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = aco.sporttype AND scs.bettype = aco.bettype
		INNER JOIN @GameType gt ON acs.bettype = gt.IBCBetTypeID AND acs.sporttype = 202
	WHERE acs.custid = @recommend 

	DECLARE @MemberPT TABLE (
		bettype			INT,
		apositiontaking	SMALLMONEY --a1_max
	)			
	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	INSERT INTO @MemberPT (bettype , apositiontaking)
	SELECT cs.bettype, 
		CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
						ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
									ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= scs.spositiontaking - cs.spositiontaking - cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking - cs.spositiontaking - cs.mpositiontaking END
								END
						 END as apositiontaking
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 		
		INNER JOIN @GameType gt ON acs.bettype = gt.IBCBetTypeID AND acs.sporttype = 202
	WHERE cs.custid = @custid 
	

	-- Customer Info
	SELECT c.custid
		,c.username
		,c.firstname
		,c.lastname
		,c.phone
		,c.mobilephone
		,c.fax
	FROM dbo.Customer c WITH (NOLOCK)
	WHERE c.custID = @CustID

	--select custgametype setting
	SELECT gt.IBCBetTypeID
		,cg.MinBet
		,cg.MaxBet
		,cg.MaxPerGameType
		,CASE WHEN acs.MinBet_Min < bs.MinBet THEN bs.MinBet ELSE acs.MinBet_Min END MinBet_Min
		,acs.MaxBet_Max
		,acs.MaxPerMatch_Max
		,cg.IsDisabled
		,ad.IsDisabled AS DisableUplinesKeno
	FROM dbo.CustGameType cg WITH (NOLOCK)
		INNER JOIN @GameType gt ON cg.GameTypeID = gt.GameTypeID
		INNER JOIN @AgentSetting acs ON cg.GameTypeID = acs.GameTypeID
		INNER JOIN @AgentDisabled ad ON cg.GameTypeID = ad.GameTypeID
		INNER JOIN ProductBetSetting bs ON gt.IBCBetTypeID = bs.bettype AND bs.sporttype = 202 AND Currency = @Currency AND IsDep = 0
	WHERE cg.CustID = @CustID
	ORDER BY gt.IBCBetTypeID

	--select PT/Comm setting
	SELECT cs.bettype
		,cs.apositiontaking as a1
		,acs.minpositiontaking AS a1_min 
		,CASE WHEN acs.apositiontaking <= m.apositiontaking THEN acs.apositiontaking ELSE m.apositiontaking END AS a1_max
		,cs.playerdiscount --commission
		,ac.discount AS playerdiscount_max --maxcommission
	FROM CustSettingGame cs WITH (NOLOCK)
		INNER JOIN @GameType gt ON cs.Bettype = gt.IBCBetTypeID 
		INNER JOIN CustSettingGame ac WITH (NOLOCK) ON ac.CustID = @recommend AND cs.bettype = ac.bettype AND cs.Sporttype = ac.sporttype
		INNER JOIN dbo.CustOverrideGame aco WITH (NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype		 
		INNER JOIN @AgentPT acs ON cs.bettype = acs.bettype
		INNER JOIN @MemberPT m ON cs.bettype= m.bettype
	WHERE cs.CustID = @CustID AND cs.bettype BETWEEN 1501 AND 1599 AND cs.sporttype = 202
	ORDER BY cs.Bettype

END
