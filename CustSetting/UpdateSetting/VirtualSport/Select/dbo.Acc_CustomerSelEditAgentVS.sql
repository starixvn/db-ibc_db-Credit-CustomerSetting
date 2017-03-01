USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerSelEditAgentVS]    Script Date: 6/9/2015 4:48:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustomerSelEditAgentVS]
	@custid int--agentID
AS
/*
Created: 20120810@Dan
Task : Master edit agent (VS).
DB: DBCUST.CustDB

Revisions:
	- 20121130@Tom: Add  virtual tennis setting (sporttype : 186 , bettype : 1220)
	- 20130220@Johnson: get virtual horse racing setting (sporttype: 181, bettype: 1231)
	- 20131121@Kathy: Add Virtual Greyhounds (182), Virtual Motor Racing (184) [Redmine:#7234]
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]
	- 20150609@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
	• @CustID: agent ID
*/

	SET NOCOUNT ON
	DECLARE
		@mrecommend int,
		@srecommend int,
	
		@DisableVirtualSports	BIT,
		@HideVirtualSports		BIT,
		@MaxPerMatch180			MONEY,
		@MaxPerMatch181			MONEY,
		@MaxPerMatch182			MONEY,
		@MaxPerMatch183			MONEY,
		@MaxPerMatch184			MONEY,
		@MaxPerMatch185			MONEY,
		@MaxPerMatch186			MONEY,
		
		@downlines BIT, 
		@DisableDownlinesVirtualSports BIT,
		@DisableUplineVirtualSports BIT,
		
		@DisableAutoMPT BIT
		 		
	SELECT @downlines = CASE WHEN EXISTS(SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE recommend = @custid and roleid = 1) THEN 1 ELSE 0 END

	SELECT @mrecommend = mrecommend, @srecommend = srecommend
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	select @DisableUplineVirtualSports = isnull(DisableVirtualSports,0)		   		 
	FROM custinfo with (NOLOCK) WHERE custid = @mrecommend
	 	 	
	select top 1 @DisableDownlinesVirtualSports = isnull(DisableVirtualSports,0) 
	from custinfo with (NOLOCK) 
	WHERE recommend = @custid and roleid = 1 and DisableVirtualSports = 1
			
	--Disable auto master PT
	SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT ,0)
	FROM CustMaster WITH (NOLOCK) 
	WHERE CustID = @Mrecommend
		
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
	WHERE ci.custid IN (@Mrecommend, @srecommend)
		AND sporttype in (180, 181, 182, 183, 184, 185, 186) and bettype  in (1201, 1231, 1220)
	GROUP BY sporttype, bettype
	
	-- get n3,l3, a4 for Web
	DECLARE @MasterPT TABLE(
			sporttype int, 
			bettype int, 
			n3 smallmoney,	
			m3 smallmoney		
			)
	--n3, min(m3,l3)
	INSERT INTO @MasterPT(sporttype, bettype,n3,m3)
	SELECT cs.sporttype, cs.bettype, 
			MAX(minpositiontaking) as n3, 
			MAX(CASE WHEN cs.mpositiontaking< co.maxpositiontaking 
					THEN cs.mpositiontaking 
					ELSE co.maxpositiontaking END) as m3
	FROM CustSetting3rd as cs WITH (NOLOCK)
		INNER JOIN CustOverride3rd as co with (nolock) on cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
	WHERE cs.custid = @mrecommend and cs.sporttype in (180, 181, 182, 183, 184, 185, 186) and cs.bettype in (1201, 1231, 1220)
	GROUP BY cs.sporttype, cs.bettype
	
	--a4
	DECLARE @SuperPT TABLE(
			sporttype int, 
			bettype int, 
			m4 smallmoney,
			a4 smallmoney
			)		
	INSERT INTO @SuperPT(sporttype, bettype, m4, a4)
	SELECT	sporttype, bettype, 
		cs.mpositiontaking as m4,	
		cs.apositiontaking as a4	
	FROM CustSetting3rd as cs with (nolock)
	WHERE custid = @srecommend and sporttype  in (180, 181, 182, 183, 184, 185, 186) and bettype in (1201, 1231, 1220)

	SELECT @DisableVirtualSports	= ISNULL(DisableVirtualSports,0),
			@HideVirtualSports		= ISNULL(HideVirtualSports,0),
			@MaxPerMatch180			= MaxPerMatch180,
			@MaxPerMatch181			= MaxPerMatch181,
			@MaxPerMatch182			= MaxPerMatch182,
			@MaxPerMatch183			= MaxPerMatch183,
			@MaxPerMatch184			= MaxPerMatch184,
			@MaxPerMatch185			= MaxPerMatch185,
			@MaxPerMatch186			= MaxPerMatch186
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid

	-- CUSTOMER
	SELECT	c.username, 
			c.username2, 
			c.firstname,
			c.lastname,
			c.phone,
			c.mobilephone,
			c.email,
			c.fax,
			@DisableVirtualSports as DisableVirtualSports,
			@HideVirtualSports as HideVirtualSports,
			CASE WHEN @downlines = 0 then @DisableVirtualSports ELSE ISNULL(@DisableDownlinesVirtualSports,0) END AS DisableDownlinesVirtualSports,
			@DisableUplineVirtualSports as DisableUplineVirtualSports,
			@DisableAutoMPT as DisableAutoMPT
	FROM	Customer c WITH (NOLOCK)			
	WHERE	c.custID = @CustID 

	SELECT 
		cs.sporttype,
		cs.bettype,
		cs.minbet, 
		cs.maxbet,
		CASE cs.sporttype WHEN 180 then @MaxPerMatch180
							WHEN 181 then @MaxPerMatch181
							WHEN 182 then @MaxPerMatch182
							WHEN 183 then @MaxPerMatch183
							WHEN 184 then @MaxPerMatch184
							WHEN 185 then @MaxPerMatch185
							WHEN 186 then @MaxPerMatch186 END AS MaxPerMatch,
				
		MinBet_Min,
		Maxbet_Max,
		MaxperMatch_Max, 
								
		--a2
		cs.apositiontaking as a2,
		--m2
		cs.mpositiontaking as m2,		
		--um2
		cs.autompositiontaking as um2,		
		--im2
		cs.isautompositiontaking as im2,		
		--n2
		co.minpositiontaking as n2,		
		
		-- n3
		n3,
		-- m3
		m3, 
		-- a4
		a4,
		--m4 
		m4 
		/*
		-- web will hable min/max
		--m2_min = Max(0, N3-A4)
		case when n3 - a4 > 0 then n3 - a4 else 0 end as m2_min,
		
		--m2_max = Min(M3, M4)
		case when m3<m4 then m3 else m4 end as m2_max,		
		
		--a2_min = (im2=0?Max(0, N3-M2):Max(0, M3-UM2))
		case when cs.isautompositiontaking = 0 
			then (case when n3-cs.mpositiontaking >0 then n3-cs.mpositiontaking else 0 end)
			else (case when m3-cs.autompositiontaking >0 then m3-cs.autompositiontaking else 0 end)
		end as a2_min,
		
		--a2_max = (im2=0?Min(A4, M3-M2): Min(A4, M3))
		case when cs.isautompositiontaking = 0 
			then (case when m3-cs.mpositiontaking < a4 then m3-cs.mpositiontaking  else a4 end)
			else (case when a4 < m3 then a4 else m3 end)
		end as a2_max,			
		
		--um2_min = Max(0, N3-A4)
		case when n3 - a4 > 0 then n3 - a4 else 0 end as um2_min,
		
		--um2_max = Min(M3, M4)
		case when m3<m4 then m3 else m4 end as um2_max
		*/
	FROM CustSetting3rd as cs with (NOLOCK) 
		JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
		JOIN @MinMaxBetUpline as mu on co.sporttype=mu.sporttype and mu.bettype=cs.bettype
		JOIN @MasterPT m on co.sporttype=m.sporttype and m.bettype=cs.bettype
		JOIN @SuperPT s on co.sporttype=s.sporttype and s.bettype=cs.bettype	
	WHERE cs.custid = @custid AND cs.sporttype  in (180, 181, 182, 183, 185, 184, 186) and cs.bettype in (1201, 1231, 1220)




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentVS] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentVS] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentVS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditAgentVS] TO [bodbDownlineNetView]
GO

