ALTER PROCEDURE [dbo].[Acc_CustomerSelHRSuper_All]
	@custid int
AS

/*
Created: 20081028@PhuongNguyen
Task : Get Horse Racing information
DB: DBCUST.CustDB

Revisions:
	- 20090515@Phuc: PT for HR
	- 20100414@Shifu: PT for OpenTote
	- 20101231@Johnson: Get setting for HR AU, Greyhound, Harness
	- 20130305@Johnson: Get bet setting of 3rd
	- 20130520@Johnson: check null bet setting of 3rd
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
	@CustID: super ID
*/
	SET NOCOUNT ON
	Declare			
		@SuperID int,
		@v151Minbet_31		money,-- @Minbet_31 -> @v151Minbet_31
		@v151Minbet_31_min	money,
		@v151Maxbet_31		money,-- @Maxbet_31 -> @v151Maxbet_31 
		@v151MaxPerMatch_31 money,--@MaxPerMatch_31 -> @v151MaxPerMatch_31
		@v151Minbet_41		money,--@Minbet_41 -> @v151Minbet_41
		@v151Minbet_41_min	money,
		@v151Maxbet_41		money,--@Maxbet_41 -> @v151Maxbet_41 
		@v151MaxPerMatch_41 money,--@MaxPerMatch_41 -> @v151MaxPerMatch_41
		@v151MinBet_51		money,
		@v151MinBet_51_min	money,
		@v151MaxBet_51		money,
		@v151MaxPerMatch_51 money,
		@v152MinBet_41		money,
		@v152MinBet_41_min	money,
		@v152MaxBet_41		money,
		@v152MaxPerMatch_41 money,
		@v152MinBet_51		money,
		@v152MinBet_51_min	money,
		@v152MaxBet_51		money,
		@v152MaxPerMatch_51 money,
		@v153MinBet_51		money,
		@v153MinBet_51_min	money,
		@v153MaxBet_51		money,
		@v153MaxPerMatch_51 money,
			
		@v151discount_31 money,--commission for tote.
		@v151discount_41 MONEY,--commission for fixed odds.
		@v151discount_51 money,
		@v152discount_41 money,
		@v152discount_51 money,
		@v153discount_51 money,
		
		@DisableDownlines151_31 BIT, -- @DisableDownlinesHR -> @DisableDownlines151_31
		@DisableDownlines151_41 BIT,-- @DisableDownlinesOpenTote -> @DisableDownlines151_41
		@DisableDownlines151_51 BIT,
		@DisableDownlines152_41 BIT,
		@DisableDownlines152_51 BIT,
		@DisableDownlines153_51 BIT,
		
		@v151IBCPositiontaking_31 smallmoney,
		@v151IBCPositiontaking_41 smallmoney,
		@v151IBCPositiontaking_51 smallmoney,
		@v152IBCPositiontaking_41 smallmoney,
		@v152IBCPositiontaking_51 smallmoney,
		@v153IBCPositiontaking_51 smallmoney,
		
		@downlines BIT,
		@currency  INT
		 
		--@MaDisableHR BIT
	SELECT @downlines = CASE WHEN EXISTS(SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE srecommend = @custid and roleid = 3) THEN 1 ELSE 0 END
								 
	select top 1 @DisableDownlines151_31 = isnull(DisableHorseRacing,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and DisableHorseRacing = 1
	select top 1 @DisableDownlines151_41 = isnull(DisableOpenTote,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and DisableOpenTote = 1
	select top 1 @DisableDownlines151_51 = isnull(Disable151_AU,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and Disable151_AU = 1
	select top 1 @DisableDownlines152_41 = isnull(Disable152_UK,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and Disable152_UK = 1
	select top 1 @DisableDownlines152_51 = isnull(Disable152_AU,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and Disable152_AU = 1
	select top 1 @DisableDownlines153_51 = isnull(Disable153_AU,0) from custinfo with (NOLOCK) WHERE srecommend = @custid and roleid = 3 and Disable153_AU = 1
		
	--end--		
	SELECT @v151IBCPositiontaking_31 = AutoIBCPositiontaking_Tote, @v151IBCPositiontaking_41 = AutoIBCPositiontaking_Fixed, @v151IBCPositiontaking_51 = AutoIBCPT151_AU,
		@v152IBCPositiontaking_41 = AutoIBCPT152_UK, @v152IBCPositiontaking_51 = AutoIBCPT152_AU, @v153IBCPositiontaking_51 = AutoIBCPT153_AU
	FROM CustSuper (nolock) where custid = @custid
	
	SELECT @currency = currency FROM custinfo WITH(NOLOCK) WHERE custid = @custid
	
	--HR setting--
	SELECT
		@v151Minbet_31 = cs.minbet, 
		@v151Maxbet_31 = cs.maxbet, 
		@v151MaxPerMatch_31 = ci.maxpermatch151
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 31 AND cs.sporttype = 151
	--end--	
	
	--OpenTote setting--
	SELECT
		@v151Minbet_41 = cs.minbet, 
		@v151Maxbet_41 = cs.maxbet, 
		@v151MaxPerMatch_41 = ci.maxpermatch151_ot
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 151
	--end--	
	
	--HR AU setting--
	SELECT
		@v151Minbet_51 = cs.minbet, 
		@v151Maxbet_51 = cs.maxbet, 
		@v151MaxPerMatch_51 = ci.maxpermatch151_au
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 151
	--end--	
	
	--Greyhound UK setting--
	SELECT
		@v152Minbet_41 = cs.minbet, 
		@v152Maxbet_41 = cs.maxbet, 
		@v152MaxPerMatch_41 = ci.maxpermatch152_uk
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 152
	--end--	
	
	--Greyhound AU setting--
	SELECT
		@v152Minbet_51 = cs.minbet, 
		@v152Maxbet_51 = cs.maxbet, 
		@v152MaxPerMatch_51 = ci.maxpermatch152_au
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 152
	--end--	
	
	--Harness AU setting--
	SELECT
		@v153Minbet_51 = cs.minbet, 
		@v153Maxbet_51 = cs.maxbet, 
		@v153MaxPerMatch_51 = ci.maxpermatch153_au
	FROM custinfo AS ci WITH (NOLOCK)
		INNER JOIN CustSetting3rd AS cs WITH (NOLOCK) ON ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 153
	--end--	
	
	SELECT @v151Minbet_31_min = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 31 THEN minbet ELSE 0 END),0),
		@v151Minbet_41_min = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 41 THEN minbet ELSE 0 END),0),
		@v151Minbet_51_min = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 51 THEN minbet ELSE 0 END),0),
		@v152Minbet_41_min = ISNULL(MAX(CASE WHEN sporttype = 152 and bettype = 41 THEN minbet ELSE 0 END),0),
		@v152Minbet_51_min = ISNULL(MAX(CASE WHEN sporttype = 152 and bettype = 51 THEN minbet ELSE 0 END),0),
		@v153Minbet_51_min = ISNULL(MAX(CASE WHEN sporttype = 153 and bettype = 51 THEN minbet ELSE 0 END),0)		
	FROM RacingBetSetting WITH(NOLOCK)
	WHERE currency = @currency
	
	--HR Comm--	
	SELECT 
		@v151discount_31 = max(case when bettype = 31 then sdiscount else 0 end),
		@v151discount_41 = max(case when bettype = 41 then sdiscount else 0 end),
		@v151discount_51 = max(case when bettype = 51 then sdiscount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=151	
	--END--
	
	--Greyhound Comm--	
	SELECT 		
		@v152discount_41 = max(case when bettype = 41 then sdiscount else 0 end),
		@v152discount_51 = max(case when bettype = 51 then sdiscount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=152	
	--END--
	
	--Harness Comm--	
	SELECT 				
		@v153discount_51 = max(case when bettype = 51 then sdiscount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=153	
	--END--
	
	--customer info
	SELECT c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		ci.DisableHorseracing as Disable151_31,
		case when @downlines = 0 then ci.DisableHorseracing else isnull(@DisableDownlines151_31,0) end as DisableDownlines151_31,
		ci.DisableOpenTote  as Disable151_41,
		case when @downlines = 0 then ci.DisableOpenTote else isnull(@DisableDownlines151_41,0) end as DisableDownlines151_41,
		ci.Disable151_AU  as Disable151_51,
		case when @downlines = 0 then ci.Disable151_AU else isnull(@DisableDownlines151_51,0) end as DisableDownlines151_51,
		ci.Disable152_UK  as Disable152_41,
		case when @downlines = 0 then ci.Disable152_UK else isnull(@DisableDownlines152_41,0) end as DisableDownlines152_41,
		ci.Disable152_AU  as Disable152_51,
		case when @downlines = 0 then ci.Disable152_AU else isnull(@DisableDownlines152_51,0) end as DisableDownlines152_51,
		ci.Disable153_AU  as Disable153_51,
		case when @downlines = 0 then ci.Disable153_AU else isnull(@DisableDownlines153_51,0) end as DisableDownlines153_51,
		
		ISNULL(@v151Minbet_31,0)		AS v151minbet_31,
		ISNULL(@v151Minbet_31_min,0)	AS v151minbet_31_min, 
		ISNULL(@v151maxbet_31,0)		AS v151maxbet_31, 
		ISNULL(@v151maxpermatch_31,0)	AS v151maxpermatch_31,	 
		ISNULL(@v151minbet_41,0)		AS v151minbet_41, 
		ISNULL(@v151minbet_41_min,0)	AS v151minbet_41_min, 
		ISNULL(@v151maxbet_41,0)		AS v151maxbet_41, 		
		ISNULL(@v151maxpermatch_41,0)	AS v151maxpermatch_41,	
		ISNULL(@v151minbet_51,0)		as v151minbet_51,
		ISNULL(@v151minbet_51_min,0)	as v151minbet_51_min,
		ISNULL(@v151maxbet_51,0)		as v151maxbet_51,
		ISNULL(@v151maxpermatch_51,0)	as v151maxpermatch_51,
		ISNULL(@v152minbet_41,0)		as v152minbet_41,
		ISNULL(@v152minbet_41_min,0)	as v152minbet_41_min,
		ISNULL(@v152maxbet_41,0)		as v152maxbet_41,
		ISNULL(@v152maxpermatch_41,0)	as v152maxpermatch_41,
		ISNULL(@v152minbet_51,0)		as v152minbet_51,
		ISNULL(@v152minbet_51_min,0)	as v152minbet_51_min,
		ISNULL(@v152maxbet_51,0)		as v152maxbet_51,
		ISNULL(@v152maxpermatch_51,0)	as v152maxpermatch_51,
		ISNULL(@v153minbet_51,0)		as v153minbet_51,
		ISNULL(@v153minbet_51_min,0)	as v153minbet_51_min,
		ISNULL(@v153maxbet_51,0)		as v153maxbet_51,
		ISNULL(@v153maxpermatch_51,0)	as v153maxpermatch_51,
		
		ISNULL(@v151discount_31,0) as v151discount_31,
		ISNULL(@v151discount_41,0) as v151discount_41,
		ISNULL(@v151discount_51,0) as v151discount_51,
		ISNULL(@v152discount_41,0) as v152discount_41,
		ISNULL(@v152discount_51,0) as v152discount_51,
		ISNULL(@v153discount_51,0) as v153discount_51,
		
		0.01 as v151discount_31_max,
		0.01 as v151discount_41_max,
		0.01 as v151discount_51_max,
		0.01 as v152discount_41_max,
		0.01 as v152discount_51_max,
		0.01 as v153discount_51_max,
				
		ISNULL(@v151IBCPositiontaking_31,0) as v151IBCPositiontaking_31,
		ISNULL(@v151IBCPositiontaking_41,0) as v151IBCPositiontaking_41,
		ISNULL(@v151IBCPositiontaking_51,0) as v151IBCPositiontaking_51,
		ISNULL(@v152IBCPositiontaking_41,0) as v152IBCPositiontaking_41,
		ISNULL(@v152IBCPositiontaking_51,0) as v152IBCPositiontaking_51,
		ISNULL(@v153IBCPositiontaking_51,0) as v153IBCPositiontaking_51,
		
		0.7 as v151IBCPositiontaking_31_max,
		0.7 as v151IBCPositiontaking_41_max,
		0.7 as v151IBCPositiontaking_51_max,
		0.7 as v152IBCPositiontaking_41_max,
		0.7 as v152IBCPositiontaking_51_max,
		0.7 as v153IBCPositiontaking_51_max,
		--n4
		max(case when co.bettype = 31 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_31_min,
		max(case when co.bettype = 32 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_32_min,
		max(case when co.bettype = 41 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_41_min,
		max(case when co.bettype = 42 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_42_min,
		max(case when co.bettype = 51 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_51_min,
		max(case when co.bettype = 52 and cs.sporttype = 151 then co.minpositiontaking else 0 end) as v151spositiontaking_52_min,		
		max(case when co.bettype = 41 and cs.sporttype = 152 then co.minpositiontaking else 0 end) as v152spositiontaking_41_min,
		max(case when co.bettype = 42 and cs.sporttype = 152 then co.minpositiontaking else 0 end) as v152spositiontaking_42_min,
		max(case when co.bettype = 51 and cs.sporttype = 152 then co.minpositiontaking else 0 end) as v152spositiontaking_51_min,
		max(case when co.bettype = 51 and cs.sporttype = 152 then co.minpositiontaking else 0 end) as v152spositiontaking_52_min,
		max(case when co.bettype = 51 and cs.sporttype = 153 then co.minpositiontaking else 0 end) as v153spositiontaking_51_min,
		max(case when co.bettype = 52 and cs.sporttype = 153 then co.minpositiontaking else 0 end) as v153spositiontaking_52_min,
		
		--l4
		0.5 as v151spositiontaking_31_max,
		0.5 as v151spositiontaking_32_max,
		0.5 as v151spositiontaking_41_max,
		0.5 as v151spositiontaking_42_max,
		0.5 as v151spositiontaking_51_max,
		0.5 as v151spositiontaking_52_max,
		0.5 as v152spositiontaking_41_max,
		0.5 as v152spositiontaking_42_max,
		0.5 as v152spositiontaking_51_max,
		0.5 as v152spositiontaking_52_max,
		0.5 as v153spositiontaking_51_max,
		0.5 as v153spositiontaking_52_max,
		--s4
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_52,		
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_52,
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.spositiontaking else 0 end) as v153spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.spositiontaking else 0 end) as v153spositiontaking_52,
		--m4
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
		--a4
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
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_52
		
	FROM customer c WITH (NOLOCK)
		INNER JOIN custinfo ci WITH (NOLOCK) ON c.custid = ci.custid
		INNER JOIN CustSetting3rd cs WITH (NOLOCK) ON c.custid = cs.custid 
		INNER JOIN CustOverride3rd co WITH(NOLOCK) ON c.custid = co.custid AND cs.sporttype = co.sporttype AND cs.bettype = co.bettype
	WHERE 
		c.custid = @custid and cs.sporttype between 151 and 153
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
		ci.Disable153_AU

		
		
		
		
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRSuper_All] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRSuper_All] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRSuper_All] TO [vnteam]