ALTER PROCEDURE [dbo].[Acc_CustomerSelHRAgent_SAg]
	@custid int--agentID
AS
/*
Created: 20090526@Phuc
Task : Get Horse Racing information(Super view agent info)
DB: DBCUST.CustDB

Revisions:
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100422@Terry: Get bet setting by bettype for Open Tote
	- 20110228@Johnson: get setting for GreyHound and Harness
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: AgentID
*/

	SET NOCOUNT ON
	Declare			
		@mrecommend int,
		@srecommend int,
		@v151Minbet_31 money, -- @Minbet_31 -> @v151Minbet_31
		@v151Maxbet_31 money,-- @Maxbet_31 -> @v151Maxbet_31
		@v151MaxPerMatch_31 money,-- @MaxPerMatch_31 -> @v151MaxPerMatch_31
		@v151Minbet_41 money,-- @Minbet_41 -> @v151Minbet_41
		@v151Maxbet_41 money,-- @Maxbet_41 -> @v151Maxbet_41
		@v151MaxPerMatch_41 money,-- @MaxPerMatch_41 -> @v151MaxPerMatch_41
		@v151Minbet_51 money,
		@v151Maxbet_51 money,
		@v151MaxPerMatch_51 money,
		@v152Minbet_41 money,
		@v152Maxbet_41 money,
		@v152MaxPerMatch_41 money,
		@v152Minbet_51 money,
		@v152Maxbet_51 money,
		@v152MaxPerMatch_51 money,
		@v153Minbet_51 money,
		@v153Maxbet_51 money,
		@v153MaxPerMatch_51 money,
		
		@v151discount_31 decimal(9,8),
		@v151discount_41 decimal(9,8),
		@v151discount_51 decimal(9,8),
		@v152discount_41 decimal(9,8),
		@v152discount_51 decimal(9,8),
		@v153discount_51 decimal(9,8),
		
		@DisableDownlines151_31 BIT, -- @DisableDownlinesHR -> @DisableDownlines151_31
		@DisableUplines151_31 BIT,-- @DisableUplineHR -> @DisableUpline151_31
		@DisableDownlines151_41 BIT,-- @DisableDownlinesOpenTote -> @DisableDownlines151_41
		@DisableUplines151_41 BIT , -- @DisableUplinesOpenTote -> @DisableUplines151_41
		@DisableDownlines151_51 BIT, 
		@DisableUplines151_51 BIT,
		@DisableDownlines152_41 BIT, 
		@DisableUplines152_41 BIT,
		@DisableDownlines152_51 BIT, 
		@DisableUplines152_51 BIT,
		@DisableDownlines153_51 BIT, 
		@DisableUplines153_51 BIT
 
		--@MeDisableHR bit


	SELECT @mrecommend = mrecommend, @srecommend = srecommend
	FROM custinfo WITH (NOLOCK) WHERE custid = @custid
	
	select top 1 @DisableDownlines151_31 = isnull(DisableHorseRacing,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and DisableHorseRacing = 1
	select top 1 @DisableDownlines151_41 = isnull(DisableOpenTote,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and DisableOpenTote = 1
	select top 1 @DisableDownlines151_51 = isnull(Disable151_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable151_AU = 1
	select top 1 @DisableDownlines152_41 = isnull(Disable152_UK,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable152_UK = 1
	select top 1 @DisableDownlines152_51 = isnull(Disable152_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable152_AU = 1
	select top 1 @DisableDownlines153_51 = isnull(Disable153_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable153_AU = 1
	
	select @DisableUplines151_31 = isnull(DisableHorseRacing,0), 
			@DisableUplines151_41 = isnull(DisableOpenTote,0), 
			@DisableUplines151_51 = isnull(Disable151_AU,0), 
			@DisableUplines152_41 = isnull(Disable152_UK,0),
			@DisableUplines152_51 = isnull(Disable152_AU,0),
			@DisableUplines153_51 = isnull(Disable153_AU,0) 
	from custinfo with (NOLOCK) WHERE custid = @mrecommend
	
	
	--HR bet setting of SA Tote--
	SELECT
		@v151Minbet_31 = cs.minbet, 
		@v151Maxbet_31 = cs.maxbet, 
		@v151MaxPerMatch_31 = ci.maxpermatch151
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 31 AND cs.sporttype = 151
	--	HR bet setting of UK Tote--
	SELECT
		@v151Minbet_41 = cs.minbet, 
		@v151Maxbet_41 = cs.maxbet, 
		@v151MaxPerMatch_41 = ci.maxpermatch151_OT
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 151
	
	--	HR bet setting of AU
	SELECT
		@v151Minbet_51 = cs.minbet, 
		@v151Maxbet_51 = cs.maxbet, 
		@v151MaxPerMatch_51 = ci.maxpermatch151_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 151
		
	--	GreyHound bet setting of UK 
	SELECT
		@v152Minbet_41 = cs.minbet, 
		@v152Maxbet_41 = cs.maxbet, 
		@v152MaxPerMatch_41 = ci.maxpermatch152_UK
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 152
		
	--	GreyHound bet setting of AU
	SELECT
		@v152Minbet_51 = cs.minbet, 
		@v152Maxbet_51 = cs.maxbet, 
		@v152MaxPerMatch_51 = ci.maxpermatch152_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 152
		
	--	Harness bet setting of AU
	SELECT
		@v153Minbet_51 = cs.minbet, 
		@v153Maxbet_51 = cs.maxbet, 
		@v153MaxPerMatch_51 = ci.maxpermatch153_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 153
		
	--HR Comm--	
	SELECT 
		@v151discount_31 = max(case when bettype = 31 and sporttype = 151 then discount else 0 end),
		@v151discount_41 = max(case when bettype = 41 and sporttype = 151 then discount else 0 end),
		@v151discount_51 = max(case when bettype = 51 and sporttype = 151 then discount else 0 end),
		@v152discount_41 = max(case when bettype = 41 and sporttype = 152 then discount else 0 end),
		@v152discount_51 = max(case when bettype = 51 and sporttype = 152 then discount else 0 end),
		@v153discount_51 = max(case when bettype = 51 and sporttype = 153 then discount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid	
	--Master Comm 	

	SELECT c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		ci.DisableHorseracing as Disable151_31,
		ci.DisableOpenTote as Disable151_41,	
		ci.Disable151_AU as Disable151_51,
		ci.Disable152_UK as Disable152_41,
		ci.Disable152_AU as Disable152_51,
		ci.Disable153_AU as Disable153_51,			
		isnull(@DisableDownlines151_31,0) AS DisableDownlines151_31,
		isnull(@DisableUplines151_31,0) as DisableUplines151_31,	
		isnull(@DisableDownlines151_41,0) as DisableDownlines151_41,		
		isnull(@DisableUplines151_41,0) as DisableUplines151_41,	
		isnull(@DisableDownlines151_51,0) as DisableDownlines151_51,		
		isnull(@DisableUplines151_51,0) as DisableUplines151_51,
		isnull(@DisableDownlines152_41,0) as DisableDownlines152_41,		
		isnull(@DisableUplines152_41,0) as DisableUplines152_41,
		isnull(@DisableDownlines152_51,0) as DisableDownlines152_51,		
		isnull(@DisableUplines152_51,0) as DisableUplines152_51,
		isnull(@DisableDownlines153_51,0) as DisableDownlines153_51,		
		isnull(@DisableUplines153_51,0) as DisableUplines153_51,
		
		c.mrecommend as parentid,
		
		@v151minbet_31 AS v151minbet_31, 
		@v151maxbet_31 AS v151maxbet_31, 
		@v151maxpermatch_31 AS v151maxpermatch_31,
		
		@v151minbet_41 AS v151minbet_41, 
		@v151maxbet_41 AS v151maxbet_41, 
		@v151maxpermatch_41 AS v151maxpermatch_41,
		
		@v151minbet_51 AS v151minbet_51, 
		@v151maxbet_51 AS v151maxbet_51, 
		@v151maxpermatch_51 AS v151maxpermatch_51,
		
		@v152minbet_41 AS v152minbet_41, 
		@v152maxbet_41 AS v152maxbet_41, 
		@v152maxpermatch_41 AS v152maxpermatch_41,
		
		@v152minbet_51 AS v152minbet_51, 
		@v152maxbet_51 AS v152maxbet_51, 
		@v152maxpermatch_51 AS v152maxpermatch_51,
		
		@v153minbet_51 AS v153minbet_51, 
		@v153maxbet_51 AS v153maxbet_51, 
		@v153maxpermatch_51 AS v153maxpermatch_51,
		
		@v151discount_31 as v151discount_31,
		@v151discount_41 as v151discount_41,
		@v151discount_51 as v151discount_51,
		@v152discount_41 as v152discount_41,
		@v152discount_51 as v152discount_51,
		@v153discount_51 as v153discount_51,
		
		--a2
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_52,
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_52,
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_52,
		--m2
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_52,
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_52,
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_52,

		--u2
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_52,
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_52,
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_52,
		

		--i2
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_52,
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_52,
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_52
	FROM customer c with (nolock)
		INNER JOIN custinfo ci with (NOLOCK) on c.custid = ci.custid
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
		INNER JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	WHERE c.custid = @custid and cs.sporttype between 151 AND 153
	GROUP BY 
		c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		ci.DisableHorseracing,		
		ci.DisableOpenTote,	
		ci.Disable151_AU,
		ci.Disable152_UK,
		ci.Disable152_AU,
		ci.Disable153_AU,
		c.mrecommend

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_SAg] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_SAg] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_SAg] TO vnteam
GO