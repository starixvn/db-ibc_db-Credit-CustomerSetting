ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberVS] 
	@custid		INT
AS
/*
	Created: Johnson
	Date: 2012-08-09
	Task: Agent get setting virtual sports for agent edit member
	DB: DBCUST.CustDB

	Revisions:
		- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
		- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)
		- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
		- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameter's Explanation:
*/
SET NOCOUNT ON 
---------------------------
	DECLARE	@srecommend INT,
			@mrecommend INT,
			@recommend	INT,
			
			@DisableVirtualSports		BIT,
			@HideVirtualSports			BIT,
			@v180MaxPerMatch_1201		MONEY,
			@v181MaxPerMatch_1231		MONEY,
			@v182MaxPerMatch_1231		MONEY,
			@v183MaxPerMatch_1231		MONEY,
			@v184MaxPerMatch_1231		MONEY,
			@v185MaxPerMatch_1231		MONEY,
			@v186MaxPerMatch_1220		MONEY,
			@DisableUplineVirtualSports BIT

	--setting upline
	DECLARE @AgentSetting TABLE (	
		sporttype			INT, 
		bettype				INT,	
		apositiontaking		SMALLMONEY,--a2
		minpositiontaking	SMALLMONEY--a2_min
	)
	
	DECLARE @MemberSetting TABLE (
		sporttype		INT,
		bettype			INT,
		apositiontaking	SMALLMONEY --a1_max
	)

	SELECT @srecommend				= srecommend,
			@mrecommend				= mrecommend,
			@recommend				= recommend, 
			@DisableVirtualSports	= ISNULL(DisableVirtualSports, 0),
			@HideVirtualSports		= ISNULL(HideVirtualSports, 0),
			@v180MaxPerMatch_1201	= MaxPerMatch180,
			@v181MaxPerMatch_1231	= MaxPerMatch181,
			@v182MaxPerMatch_1231	= MaxPerMatch182,
			@v183MaxPerMatch_1231	= MaxPerMatch183,
			@v184MaxPerMatch_1231	= MaxPerMatch184,
			@v185MaxPerMatch_1231	= MaxPerMatch185,
			@v186MaxPerMatch_1220	= MaxPerMatch186
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
		
	--upline setting	
	select @DisableUplineVirtualSports = ISNULL(DisableVirtualSports,0)
	FROM custinfo with (NOLOCK) WHERE custid = @recommend
	
	--a2=min(a2,l2,a4)
	--n2
	INSERT INTO @AgentSetting (
		sporttype , 
		bettype, 
		apositiontaking, 
		minpositiontaking
	)
	SELECT acs.sporttype,
			acs.bettype,
			--acs.apositiontaking,
			CASE WHEN acs.apositiontaking<aco.maxpositiontaking 
				THEN CASE WHEN acs.apositiontaking<scs.apositiontaking
					THEN acs.apositiontaking
					ELSE scs.apositiontaking 
				END
			ELSE CASE WHEN aco.maxpositiontaking < scs.apositiontaking
					THEN aco.maxpositiontaking
					ELSE scs.apositiontaking 
				END
			END AS apositiontaking, 	
			aco.minpositiontaking
	FROM custinfo ci WITH(NOLOCK)
		INNER JOIN custsetting3rd acs WITH(NOLOCK) ON ci.custid = acs.custid 
		INNER JOIN custoverride3rd aco WITH(NOLOCK) ON ci.custid = aco.custid AND acs.sporttype = aco.sporttype AND acs.bettype = aco.bettype
		INNER JOIN custsetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = aco.sporttype AND scs.bettype = aco.bettype
	WHERE acs.custid = @recommend 
		AND acs.sporttype in (180, 181, 182, 183, 184, 185, 186)
		AND acs.bettype in (1201, 1231, 1220)
	
	--calculate min, max for minbet, maxbet, maxpermatch for Web
	DECLARE @MinMaxBetUpline table(
				sporttype int, 
				bettype int, 
				MinBet_Min MONEY,
				Maxbet_Max MONEY,
				MaxperMatch_Max MONEY
			)
	INSERT INTO @MinMaxBetUpline(sporttype, bettype, MinBet_Min, Maxbet_Max, MaxperMatch_Max)
	SELECT  sporttype, bettype,
		ISNULL(MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END),0) as MinBet_Min ,   
		ISNULL(MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END),0) as Maxbet_Max,
		--ISNULL(MIN(CASE WHEN ci.maxpermatch180 = 0 THEN NULL ELSE ci.maxpermatch180 END),0) as MaxperMatch_Max
		ISNULL(MIN(CASE cs.sporttype 
						WHEN 180 then 
							CASE WHEN ci.maxpermatch180 = 0 THEN NULL ELSE ci.maxpermatch180 END
						WHEN 181 then 
							CASE WHEN ci.maxpermatch181 = 0 THEN NULL ELSE ci.maxpermatch181 END
						WHEN 182 then 
							CASE WHEN ci.maxpermatch182 = 0 THEN NULL ELSE ci.maxpermatch182 END
						WHEN 183 then 
							CASE WHEN ci.maxpermatch183 = 0 THEN NULL ELSE ci.maxpermatch183 END
						WHEN 184 then 
							CASE WHEN ci.maxpermatch184 = 0 THEN NULL ELSE ci.maxpermatch184 END
						WHEN 185 then 
							CASE WHEN ci.maxpermatch185 = 0 THEN NULL ELSE ci.maxpermatch185 END
						WHEN 186 then 
							CASE WHEN ci.MaxPerMatch186 = 0 THEN NULL ELSE ci.MaxPerMatch186 END
					END ),0 )AS MaxperMatch_Max		
	FROM CustSetting3rd as cs WITH (NOLOCK) JOIN custinfo as ci WITH (NOLOCK) 
			ON cs.custid=ci.custid		
	WHERE ci.custid IN (@Mrecommend, @srecommend, @recommend)
		AND sporttype in (180, 181, 182, 183, 184, 185, 186) and bettype  in (1201, 1231, 1220)
	GROUP BY sporttype, bettype
	
	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	INSERT INTO @MemberSetting (sporttype, bettype , apositiontaking)
	SELECT cs.sporttype, cs.bettype, 
		CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
						ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
									ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= scs.spositiontaking - cs.spositiontaking - cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else scs.spositiontaking - cs.spositiontaking - cs.mpositiontaking END
								END
						 END as apositiontaking
	FROM CustSetting3rd cs WITH(NOLOCK)
		INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
		INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSetting3rd acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 		
	WHERE cs.custid = @custid AND cs.sporttype in (180, 181, 182, 183, 184, 185, 186) AND cs.bettype  in (1201, 1231, 1220)
	
	SELECT username,
			username2,
			firstname,
			lastname,
			phone,
			mobilephone,
			fax,
			roleid,
			@DisableUplineVirtualSports as DisableUplineVirtualSports,
			@DisableVirtualSports as DisableVirtualSports,
			@HideVirtualSports as HideVirtualSports
	FROM customer WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT cs.sporttype,
			cs.bettype,
			cs.minbet,
			cs.maxbet,
			CASE cs.sporttype 
				WHEN 180 THEN @v180MaxPerMatch_1201 
				WHEN 181 THEN @v181MaxPerMatch_1231 
				WHEN 182 THEN @v182MaxPerMatch_1231 
				WHEN 183 THEN @v183MaxPerMatch_1231 
				WHEN 184 THEN @v184MaxPerMatch_1231 
				WHEN 185 THEN @v185MaxPerMatch_1231 
				WHEN 186 THEN @v186MaxPerMatch_1220 
			END AS MaxPerMatch,
			mu.MinBet_Min as minbet_min,
			mu.MaxBet_Max as maxbet_max,
			mu.MaxperMatch_Max as maxpermatch_max,
			cs.apositiontaking as a1,
			acs.minpositiontaking as a1_min,
			CASE 
				WHEN acs.apositiontaking <= m.apositiontaking THEN acs.apositiontaking 
				ELSE m.apositiontaking 
			END as a1_max
	FROM custsetting3rd cs WITH(NOLOCK)
		JOIN @MinMaxBetUpline as mu on cs.sporttype=mu.sporttype and mu.bettype=cs.bettype
		JOIN @AgentSetting acs ON cs.sporttype = acs.sporttype AND cs.bettype = acs.bettype
		JOIN @MemberSetting m ON cs.sporttype = m.sporttype AND cs.bettype= m.bettype
	WHERE cs.custid = @custid
		AND cs.sporttype in (180, 181,182, 183, 184, 185, 186)
		AND cs.bettype in (1201, 1231, 1220)

	
	




GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMemberVS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberVS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberVS] TO [bodbDownlineNetView]	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberVS] TO [bodbExtAccNet]	

