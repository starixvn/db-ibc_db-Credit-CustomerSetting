ALTER PROCEDURE [dbo].[Acc_CustomerSelHRMaster_All]
	@custid int
AS
/*
Created: 20081028@PhuongNguyen
Task : Super edit master.
DB: DBCUST.CustDB

Revisions:
	- 20090515@Phuc: PT for HR
	- 20090701@Phuc: allow super disable auto MPT.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100414@Shifu: OpenTote
	- 20101231@Johnson: Get setting for HR AU, Greyhound, Harness
	- 20130306@Johnson: Check bet setting  with setting of 3rd
	- 20130520@Johnson: check null bet setting of 3rd
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: super ID
*/

	SET NOCOUNT ON
	Declare			
		@srecommend int,
		@v151Minbet_31 money,--@Minbet_31 -> @v151Minbet_31 
		@v151Maxbet_31 money,--@Maxbet_31 -> @v151Maxbet_31
		@v151MaxPerMatch_31 money,--@MaxPerMatch_31 -> @v151MaxPerMatch_31 
		@v151MinBet_31_Min money,--@MinBet_Min_31 -> @v151MinBet_Min_31 
		@v151MinBet3rd_31 money,
		@v151MaxBet_31_Max money,--@MaxBet_Max_31 -> @v151MaxBet_Max_31 
		@v151MaxPerMatch_31_Max money,--@MaxPerMatch_Max_31 -> @v151MaxPerMatch_Max_31 
		
		@v151Minbet_41 money,--@Minbet_41 -> @v151Minbet_41 
		@v151Maxbet_41 money,--@Maxbet_41 -> @v151Maxbet_41 
		@v151MaxPerMatch_41 money,--@MaxPerMatch_41 -> @v151MaxPerMatch_41 
		@v151MinBet_41_Min money,--@MinBet_Min_41 -> @v151MinBet_Min_41 
		@v151Minbet3rd_41 money,
		@v151MaxBet_41_Max money,--@MaxBet_Max_41 -> @v151MaxBet_Max_41 
		@v151MaxPerMatch_41_Max money,--@MaxPerMatch_Max_41 -> @v151MaxPerMatch_Max_41 
		
		@v151MinBet_51 money,
		@v151MaxBet_51 money,
		@v151MaxPerMatch_51 money,
		@v151MinBet_51_Min money,
		@v151MinBet3rd_51 money,
		@v151MaxBet_51_Max money,
		@v151MaxPerMatch_51_Max money,
		
		@v152MinBet_41 money,
		@v152MaxBet_41 money,
		@v152MaxPerMatch_41 money,
		@v152MinBet_41_Min money,
		@v152MinBet3rd_41 money,
		@v152MaxBet_41_Max money,
		@v152MaxPerMatch_41_Max money,
		
		@v152MinBet_51 money,
		@v152MaxBet_51 money,
		@v152MaxPerMatch_51 money,
		@v152MinBet_51_Min money,
		@v152MinBet3rd_51 money,
		@v152MaxBet_51_Max money,
		@v152MaxPerMatch_51_Max money,
		
		@v153MinBet_51 money,
		@v153MaxBet_51 money,
		@v153MaxPerMatch_51 money,
		@v153MinBet_51_Min money,
		@v153MinBet3rd_51 money,
		@v153MaxBet_51_Max money,
		@v153MaxPerMatch_51_Max money,
		
		@v151discount_31 money,
		@v151discount_41 money,
		@v151discount_51 money,
		@v152discount_41 money,
		@v152discount_51 money,
		@v153discount_51 money,
		@v151discount_31_Max money,
		@v151discount_41_Max money,
		@v151discount_51_Max money,
		@v152discount_41_Max money,
		@v152discount_51_Max money,
		@v153discount_51_Max money,
		
		@DisableDownlines151_31 BIT,-- @DisableDownlinesHR -> @DisableDownlines151_31
		@DisableDownlines151_41 BIT,-- @DisableDownlinesOpenTote -> @DisableDownlines151_41
		@DisableDownlines151_51 BIT,
		@DisableDownlines152_41 BIT,
		@DisableDownlines152_51 BIT,
		@DisableDownlines153_51 BIT,		
		@DisableAutoMPT bit,		
		
		@v151mpositiontaking_31_max smallmoney,
		@v151mpositiontaking_32_max smallmoney,
		@v151mpositiontaking_41_max smallmoney,
		@v151mpositiontaking_42_max smallmoney,
		@v151mpositiontaking_51_max smallmoney,
		@v151mpositiontaking_52_max smallmoney,		
		@v151mspositiontaking_31_max smallmoney,
		@v151mspositiontaking_32_max smallmoney,
		@v151mspositiontaking_41_max smallmoney,
		@v151mspositiontaking_42_max smallmoney,
		@v151mspositiontaking_51_max smallmoney,
		@v151mspositiontaking_52_max smallmoney,
		@v151mspositiontaking_31_min smallmoney,
		@v151mspositiontaking_32_min smallmoney,
		@v151mspositiontaking_41_min smallmoney,
		@v151mspositiontaking_42_min smallmoney,
		@v151mspositiontaking_51_min smallmoney,
		@v151mspositiontaking_52_min smallmoney,
		
		@v152mpositiontaking_41_max smallmoney,
		@v152mpositiontaking_42_max smallmoney,
		@v152mpositiontaking_51_max smallmoney,
		@v152mpositiontaking_52_max smallmoney,		
		@v152mspositiontaking_41_max smallmoney,
		@v152mspositiontaking_42_max smallmoney,
		@v152mspositiontaking_51_max smallmoney,
		@v152mspositiontaking_52_max smallmoney,
		@v152mspositiontaking_41_min smallmoney,
		@v152mspositiontaking_42_min smallmoney,
		@v152mspositiontaking_51_min smallmoney,
		@v152mspositiontaking_52_min smallmoney,
		
		@v153mpositiontaking_51_max smallmoney,
		@v153mpositiontaking_52_max smallmoney,
		@v153mspositiontaking_51_max smallmoney,
		@v153mspositiontaking_52_max smallmoney,
		@v153mspositiontaking_51_min smallmoney,
		@v153mspositiontaking_52_min smallmoney,
		
		@downlines BIT,
		@currency	INT
		--@ADisableHR bit
		
	SELECT @downlines = CASE WHEN EXISTS(SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE mrecommend = @custid and roleid = 2) THEN 1 ELSE 0 END

	select top 1 @DisableDownlines151_31 = isnull(DisableHorseRacing,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and DisableHorseRacing = 1
	select top 1 @DisableDownlines151_41 = isnull(DisableOpenTote,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and DisableOpenTote = 1
	select top 1 @DisableDownlines151_51 = isnull(Disable151_AU,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and Disable151_AU = 1
	select top 1 @DisableDownlines152_41 = isnull(Disable152_UK,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and Disable152_UK = 1
	select top 1 @DisableDownlines152_51 = isnull(Disable152_AU,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and Disable152_AU = 1
	select top 1 @DisableDownlines153_51 = isnull(Disable153_AU,0) from custinfo with (NOLOCK) WHERE mrecommend = @custid and roleid = 2 and Disable153_AU = 1
		
	--Disable auto master PT
	Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @CustID

	SELECT @srecommend = srecommend, @currency = currency
	FROM custinfo WITH (NOLOCK) WHERE custid = @custid
	 	
Select
	--get @mpt_max = m4
	@v151mpositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype=151 then cs.mpositiontaking else 0 end),
	@v151mpositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype=151 then cs.mpositiontaking else 0 end),
	@v151mpositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=151 then cs.mpositiontaking else 0 end),	
	@v151mpositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=151 then cs.mpositiontaking else 0 end),	
	@v151mpositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=151 then cs.mpositiontaking else 0 end),	
	@v151mpositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=151 then cs.mpositiontaking else 0 end),	
	
	@v152mpositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=152 then cs.mpositiontaking else 0 end),	
	@v152mpositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=152 then cs.mpositiontaking else 0 end),	
	@v152mpositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=152 then cs.mpositiontaking else 0 end),	
	@v152mpositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=152 then cs.mpositiontaking else 0 end),	
	
	@v153mpositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=153 then cs.mpositiontaking else 0 end),	
	@v153mpositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=153 then cs.mpositiontaking else 0 end),	
	-------------------------------------
	--get @mspt_max = min(s4, l4)

	@v151mspositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v151mspositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v151mspositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v151mspositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v151mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v151mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	
	@v152mspositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v152mspositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v152mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v152mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	
	@v153mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=153 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	@v153mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=153 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),
	
	--n4
	@v151mspositiontaking_31_min = max(case when co.bettype = 31 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151mspositiontaking_32_min = max(case when co.bettype = 32 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151mspositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151mspositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=151 then co.minpositiontaking else 0 end),
	
	@v152mspositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152mspositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=152 then co.minpositiontaking else 0 end),
	
	@v153mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=153 then co.minpositiontaking else 0 end),
	@v153mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=153 then co.minpositiontaking else 0 end)
From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @srecommend and cs.sporttype between 151 and 153

	--customer info
	
	--end--		

	--v151
	--HR setting--
	SELECT
		@v151Minbet_31 = cs.minbet, 
		@v151Maxbet_31 = cs.maxbet, 
		@v151MaxPerMatch_31 = ci.maxpermatch151
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 31 AND cs.sporttype = 151
	
	SELECT  
		@v151MinBet_31_Min = MinBet,   
		@v151MaxBet_31_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 31 and cs.sporttype=151  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v151MaxperMatch_31_Max = MaxPerMatch151	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 
	
	--OptenTote setting--
	SELECT
		@v151Minbet_41 = cs.minbet, 
		@v151Maxbet_41 = cs.maxbet, 
		@v151MaxPerMatch_41 = ci.MaxPerMatch151_OT
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 151
	
	SELECT  
		@v151MinBet_41_Min = MinBet,   
		@v151MaxBet_41_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 41 and cs.sporttype=151  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v151MaxperMatch_41_Max = MaxPerMatch151_OT	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 	 	
	--END
	
	--HR AU setting--
	SELECT
		@v151Minbet_51 = cs.minbet, 
		@v151Maxbet_51 = cs.maxbet, 
		@v151MaxPerMatch_51 = ci.MaxPerMatch151_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 151
	
	SELECT  
		@v151MinBet_51_Min = MinBet,   
		@v151MaxBet_51_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 51 and cs.sporttype=151  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v151MaxperMatch_51_Max = MaxPerMatch151_AU	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 	 	
	--END
	
	--v152
	--UK setting
	SELECT
		@v152Minbet_41 = cs.minbet, 
		@v152Maxbet_41 = cs.maxbet, 
		@v152MaxPerMatch_41 = ci.MaxPerMatch152_UK
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 152
	
	SELECT  
		@v152MinBet_41_Min = MinBet,   
		@v152MaxBet_41_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 41 and cs.sporttype=152  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v152MaxperMatch_41_Max = MaxPerMatch152_UK	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 
	--END
	
	--AU setting
	SELECT
		@v152Minbet_51 = cs.minbet, 
		@v152Maxbet_51 = cs.maxbet, 
		@v152MaxPerMatch_51 = ci.MaxPerMatch152_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 152
	
	SELECT  
		@v152MinBet_51_Min = MinBet,   
		@v152MaxBet_51_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 51 and cs.sporttype=152  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v152MaxperMatch_51_Max = MaxPerMatch152_AU	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 
	--END
	
	--v153 
	--AU setting
	SELECT
		@v153Minbet_51 = cs.minbet, 
		@v153Maxbet_51 = cs.maxbet, 
		@v153MaxPerMatch_51 = ci.MaxPerMatch153_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 153
	
	SELECT  
		@v153MinBet_51_Min = MinBet,   
		@v153MaxBet_51_Max = MaxBet			 	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on cs.CustID = ci.sRecommend and cs.bettype = 51 and cs.sporttype=153  
	WHERE ci.custid = @custId 
	
	SELECT 		
		@v153MaxperMatch_51_Max = MaxPerMatch153_AU	 	
	FROM custinfo WITH (NOLOCK)
	WHERE custid = @srecommend 
	--END
	
	--check bet setting with setting of 3rd
	SELECT @v151MinBet3rd_31 = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 31 THEN minbet ELSE 0 END),0),
		@v151MinBet3rd_41 = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 41 THEN minbet ELSE 0 END),0),
		@v151MinBet3rd_51 = ISNULL(MAX(CASE WHEN sporttype = 151 and bettype = 51 THEN minbet ELSE 0 END),0),
		@v152MinBet3rd_41 = ISNULL(MAX(CASE WHEN sporttype = 152 and bettype = 41 THEN minbet ELSE 0 END),0),
		@v152MinBet3rd_51 = ISNULL(MAX(CASE WHEN sporttype = 152 and bettype = 51 THEN minbet ELSE 0 END),0),
		@v153MinBet3rd_51 = ISNULL(MAX(CASE WHEN sporttype = 153 and bettype = 51 THEN minbet ELSE 0 END),0)
	FROM RacingBetSetting WITH(NOLOCK)
	WHERE currency = @currency
	
	SELECT @v151MinBet_31_Min = CASE WHEN @v151MinBet_31_Min > @v151MinBet3rd_31 THEN @v151MinBet_31_Min ELSE @v151MinBet3rd_31 END,
		@v151MinBet_41_Min = CASE WHEN @v151MinBet_41_Min > @v151MinBet3rd_41 THEN @v151MinBet_41_Min ELSE @v151MinBet3rd_41 END,
		@v151MinBet_51_Min = CASE WHEN @v151MinBet_51_Min > @v151MinBet3rd_51 THEN @v151MinBet_51_Min ELSE @v151MinBet3rd_51 END,
		@v152MinBet_41_Min = CASE WHEN @v152MinBet_41_Min > @v152MinBet3rd_41 THEN @v152MinBet_41_Min ELSE @v152MinBet3rd_41 END,
		@v152MinBet_51_Min = CASE WHEN @v152MinBet_51_Min > @v152MinBet3rd_51 THEN @v152MinBet_51_Min ELSE @v152MinBet3rd_51 END,
		@v153MinBet_51_Min = CASE WHEN @v153MinBet_51_Min > @v153MinBet3rd_51 THEN @v153MinBet_51_Min ELSE @v153MinBet3rd_51 END
		
	--v151 Comm--	
	SELECT 
		@v151discount_31 = max(case when bettype = 31 then adiscount else 0 end),
		@v151discount_41 = max(case when bettype = 41 then adiscount else 0 end),
		@v151discount_51 = max(case when bettype = 51 then adiscount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=151	
	
	--v152 Comm--
	SELECT 
		@v152discount_41 = max(case when bettype = 41 then adiscount else 0 end),
		@v152discount_51 = max(case when bettype = 51 then adiscount else 0 end)
	FROM 
		custsetting3rd as cs WITH(NOLOCK)
	WHERE cs.custid = @custid AND cs.sporttype = 152		
	
	--v153 Comm--
	SELECT 
		@v153discount_51 = adiscount
	FROM 
		custsetting3rd as cs WITH(NOLOCK)
	WHERE cs.custid = @custid AND cs.sporttype = 153 and cs.bettype =51		
	
	--v151 Supper Comm	
	SELECT 
		@v151discount_31_Max = max(case when bettype = 31 then sdiscount else 0 end),
		@v151discount_41_Max = max(case when bettype = 41 then sdiscount else 0 end),
		@v151discount_51_Max = max(case when bettype = 51 then sdiscount else 0 end)
	FROM CustSetting3rd with (nolock)
	WHERE sporttype = 151 and custid = @srecommend
	
	--v152 Supper Comm
	SELECT 		
		@v152discount_41_Max = max(case when bettype = 41 then sdiscount else 0 end),
		@v152discount_51_Max = max(case when bettype = 51 then sdiscount else 0 end)
	FROM CustSetting3rd with (nolock)
	WHERE sporttype = 152 and custid = @srecommend
	--END--
	
	--v153 Supper Comm
	SELECT 		
		@v153discount_51_Max = sdiscount
	FROM CustSetting3rd with (nolock)
	WHERE sporttype = 153 and bettype = 51 and custid = @srecommend
	--END--
	
	SELECT c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		ci.DisableHorseracing as Disable151_31,		
		si.DisableHorseracing AS DisableUplines151_31,
		case when @downlines = 0 then ci.DisableHorseracing else isnull(@DisableDownlines151_31,0) end as DisableDownlines151_31,		
		ci.DisableOpenTote as Disable151_41,				
		si.DisableOpenTote AS DisableUplines151_41,
		case when @downlines = 0 then ci.DisableOpenTote else isnull(@DisableDownlines151_41,0) end as DisableDownlines151_41,
		ci.Disable151_AU as Disable151_51,				
		si.Disable151_AU AS DisableUplines151_51,
		case when @downlines = 0 then ci.Disable151_AU else isnull(@DisableDownlines151_51,0) end as DisableDownlines151_51,
		ci.Disable152_UK as Disable152_41,				
		si.Disable152_UK AS DisableUplines152_41,
		case when @downlines = 0 then ci.Disable152_UK else isnull(@DisableDownlines152_41,0) end as DisableDownlines152_41,
		ci.Disable152_AU as Disable152_51,				
		si.Disable152_AU AS DisableUplines152_51,
		case when @downlines = 0 then ci.Disable152_AU else isnull(@DisableDownlines152_51,0) end as DisableDownlines152_51,
		ci.Disable153_AU as Disable153_51,				
		si.Disable153_AU AS DisableUplines153_51,
		case when @downlines = 0 then ci.Disable153_AU else isnull(@DisableDownlines153_51,0) end as DisableDownlines153_51,
		isnull(@DisableAutoMPT,0) as DisableAutoMPT,
		c.srecommend as parentid,
		--v151
		ISNULL(@v151minbet_31,0)			AS v151minbet_31, 
		ISNULL(@v151maxbet_31,0)			AS v151maxbet_31, 
		ISNULL(@v151maxpermatch_31,0)		AS v151maxpermatch_31,
		ISNULL(@v151MinBet_31_Min,0)		AS v151MinBet_31_Min,
		ISNULL(@v151MaxBet_31_Max,0)		AS v151MaxBet_31_Max,
		ISNULL(@v151MaxperMatch_31_Max,0)	AS v151MaxperMatch_31_Max,
		
		ISNULL(@v151minbet_41,0)			AS v151minbet_41, 
		ISNULL(@v151maxbet_41,0)			AS v151maxbet_41, 
		ISNULL(@v151maxpermatch_41,0)		AS v151maxpermatch_41,
		ISNULL(@v151MinBet_41_Min,0)		AS v151MinBet_41_Min,
		ISNULL(@v151MaxBet_41_Max,0)		AS v151MaxBet_41_Max,
		ISNULL(@v151MaxperMatch_41_Max,0)	AS v151MaxperMatch_41_Max,
		
		ISNULL(@v151minbet_51,0)		AS v151minbet_51, 
		ISNULL(@v151maxbet_51,0)		AS v151maxbet_51, 
		ISNULL(@v151maxpermatch_51,0)	AS v151maxpermatch_51,
		ISNULL(@v151MinBet_51_Min,0)	AS v151MinBet_51_Min,
		ISNULL(@v151MaxBet_51_Max,0)	AS v151MaxBet_51_Max,
		ISNULL(@v151MaxperMatch_51_Max,0) AS v151MaxperMatch_51_Max,
		
		--v152
		ISNULL(@v152minbet_41,0)		AS v152minbet_41, 
		ISNULL(@v152maxbet_41,0)		AS v152maxbet_41, 
		ISNULL(@v152maxpermatch_41,0)	AS v152maxpermatch_41,
		ISNULL(@v152MinBet_41_Min,0)	AS v152MinBet_41_Min,
		ISNULL(@v152MaxBet_41_Max,0)	AS v152MaxBet_41_Max,
		ISNULL(@v152MaxperMatch_41_Max,0) AS v152MaxperMatch_41_Max,
		
		ISNULL(@v152minbet_51,0)		AS v152minbet_51, 
		ISNULL(@v152maxbet_51,0)		AS v152maxbet_51, 
		ISNULL(@v152maxpermatch_51,0)	AS v152maxpermatch_51,
		ISNULL(@v152MinBet_51_Min,0)	AS v152MinBet_51_Min,
		ISNULL(@v152MaxBet_51_Max,0)	AS v152MaxBet_51_Max,
		ISNULL(@v152MaxperMatch_51_Max,0) AS v152MaxperMatch_51_Max,
		
		--v153
		ISNULL(@v153minbet_51,0)		AS v153minbet_51, 
		ISNULL(@v153maxbet_51,0)		AS v153maxbet_51, 
		ISNULL(@v153maxpermatch_51,0)	AS v153maxpermatch_51,
		ISNULL(@v153MinBet_51_Min,0)	AS v153MinBet_51_Min,
		ISNULL(@v153MaxBet_51_Max,0)	AS v153MaxBet_51_Max,
		ISNULL(@v153MaxperMatch_51_Max,0) AS v153MaxperMatch_51_Max,
				
		--Discount
		ISNULL(@v151discount_31,0) as v151discount_31,
		ISNULL(@v151discount_41,0) as v151discount_41,
		ISNULL(@v151discount_51,0) as v151discount_51,
		ISNULL(@v152discount_41,0) as v152discount_41,
		ISNULL(@v152discount_51,0) as v152discount_51,
		ISNULL(@v153discount_51,0) as v153discount_51,
		ISNULL(@v151discount_31_max,0) as v151discount_31_max,
		ISNULL(@v151discount_41_max,0) as v151discount_41_max,
		ISNULL(@v151discount_51_max,0) as v151discount_51_max,
		ISNULL(@v152discount_41_max,0) as v152discount_41_max,
		ISNULL(@v152discount_51_max,0) as v152discount_51_max,
		ISNULL(@v153discount_51_max,0) as v153discount_51_max,		
		
		--s3
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
		
		--m3
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
		
		--u3
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_52,
		
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_52,
		
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.autopositiontaking else 0 end) as auto_v153spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.autopositiontaking else 0 end) as auto_v153spositiontaking_52,
		
		--s3_max=min(s4,l4)
		@v151mspositiontaking_31_max as v151spositiontaking_31_max,
		@v151mspositiontaking_32_max as v151spositiontaking_32_max,
		@v151mspositiontaking_41_max as v151spositiontaking_41_max,
		@v151mspositiontaking_42_max as v151spositiontaking_42_max,
		@v151mspositiontaking_51_max as v151spositiontaking_51_max,
		@v151mspositiontaking_52_max as v151spositiontaking_52_max,
		
		@v152mspositiontaking_41_max as v152spositiontaking_41_max,
		@v152mspositiontaking_42_max as v152spositiontaking_42_max,
		@v152mspositiontaking_51_max as v152spositiontaking_51_max,
		@v152mspositiontaking_52_max as v152spositiontaking_52_max,
		
		@v153mspositiontaking_51_max as v153spositiontaking_51_max,
		@v153mspositiontaking_52_max as v153spositiontaking_52_max,		
		--u3_max=min(s4,l4)
		@v151mspositiontaking_31_max as auto_v151spositiontaking_31_max,
		@v151mspositiontaking_32_max as auto_v151spositiontaking_32_max,
		@v151mspositiontaking_41_max as auto_v151spositiontaking_41_max,
		@v151mspositiontaking_42_max as auto_v151spositiontaking_42_max,
		@v151mspositiontaking_51_max as auto_v151spositiontaking_51_max,
		@v151mspositiontaking_52_max as auto_v151spositiontaking_52_max,
		
		@v152mspositiontaking_41_max as auto_v152spositiontaking_41_max,
		@v152mspositiontaking_42_max as auto_v152spositiontaking_42_max,
		@v152mspositiontaking_51_max as auto_v152spositiontaking_51_max,
		@v152mspositiontaking_52_max as auto_v152spositiontaking_52_max,
		
		@v153mspositiontaking_51_max as auto_v153spositiontaking_51_max,
		@v153mspositiontaking_52_max as auto_v153spositiontaking_52_max,
		
		--i3
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_52,
		
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_52,
		
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.isautopositiontaking else 0 end) as isauto_v153spositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.isautopositiontaking else 0 end) as isauto_v153spositiontaking_52,	

		--m3_max=min(s4,l4)
		@v151mspositiontaking_31_max as v151mspositiontaking_31_max,
		@v151mspositiontaking_32_max as v151mspositiontaking_32_max,
		@v151mspositiontaking_41_max as v151mspositiontaking_41_max,
		@v151mspositiontaking_42_max as v151mspositiontaking_42_max,
		@v151mspositiontaking_51_max as v151mspositiontaking_51_max,
		@v151mspositiontaking_52_max as v151mspositiontaking_52_max,
		
		@v152mspositiontaking_41_max as v152mspositiontaking_41_max,
		@v152mspositiontaking_42_max as v152mspositiontaking_42_max,
		@v152mspositiontaking_51_max as v152mspositiontaking_51_max,
		@v152mspositiontaking_52_max as v152mspositiontaking_52_max,
		
		@v153mspositiontaking_51_max as v153mspositiontaking_51_max,
		@v153mspositiontaking_52_max as v153mspositiontaking_52_max,
		
		--n4 
		@v151mspositiontaking_31_min as v151mspositiontaking_31_min,
		@v151mspositiontaking_32_min as v151mspositiontaking_32_min,
		@v151mspositiontaking_41_min as v151mspositiontaking_41_min,
		@v151mspositiontaking_42_min as v151mspositiontaking_42_min,
		@v151mspositiontaking_51_min as v151mspositiontaking_51_min,
		@v151mspositiontaking_52_min as v151mspositiontaking_52_min,
		
 		@v152mspositiontaking_41_min as v152mspositiontaking_41_min,
		@v152mspositiontaking_42_min as v152mspositiontaking_42_min,
		@v152mspositiontaking_51_min as v152mspositiontaking_51_min,
		@v152mspositiontaking_52_min as v152mspositiontaking_52_min,
		
		@v153mspositiontaking_51_min as v153mspositiontaking_51_min,
		@v153mspositiontaking_52_min as v153mspositiontaking_52_min,
		
		--n3
		max(case when co.bettype = 31 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_31_min,
		max(case when co.bettype = 32 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_32_min,
		max(case when co.bettype = 41 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_41_min,
		max(case when co.bettype = 42 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_42_min,
		max(case when co.bettype = 51 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151mpositiontaking_52_min,
		
		max(case when co.bettype = 41 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152mpositiontaking_41_min,
		max(case when co.bettype = 42 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152mpositiontaking_42_min,
		max(case when co.bettype = 51 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152mpositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152mpositiontaking_52_min,
		
		max(case when co.bettype = 51 and co.sporttype = 153 then co.minpositiontaking else 0 end) as v153mpositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 153 then co.minpositiontaking else 0 end) as v153mpositiontaking_52_min,

		--m3<=min(m4,l3)	
		max(case when co.bettype = 31 and co.sporttype = 151 then case when @v151mpositiontaking_31_max<co.maxpositiontaking then @v151mpositiontaking_31_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_31_max,
		max(case when co.bettype = 32 and co.sporttype = 151 then case when @v151mpositiontaking_32_max<co.maxpositiontaking then @v151mpositiontaking_32_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_32_max,
		max(case when co.bettype = 41 and co.sporttype = 151 then case when @v151mpositiontaking_41_max<co.maxpositiontaking then @v151mpositiontaking_41_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_41_max,
		max(case when co.bettype = 42 and co.sporttype = 151 then case when @v151mpositiontaking_42_max<co.maxpositiontaking then @v151mpositiontaking_42_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_42_max,
		max(case when co.bettype = 51 and co.sporttype = 151 then case when @v151mpositiontaking_51_max<co.maxpositiontaking then @v151mpositiontaking_51_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 151 then case when @v151mpositiontaking_52_max<co.maxpositiontaking then @v151mpositiontaking_52_max else co.maxpositiontaking end else 0 end) as v151mpositiontaking_52_max,
		
		max(case when co.bettype = 41 and co.sporttype = 152 then case when @v152mpositiontaking_41_max<co.maxpositiontaking then @v152mpositiontaking_41_max else co.maxpositiontaking end else 0 end) as v152mpositiontaking_41_max,
		max(case when co.bettype = 42 and co.sporttype = 152 then case when @v152mpositiontaking_42_max<co.maxpositiontaking then @v152mpositiontaking_42_max else co.maxpositiontaking end else 0 end) as v152mpositiontaking_42_max,
		max(case when co.bettype = 51 and co.sporttype = 152 then case when @v152mpositiontaking_51_max<co.maxpositiontaking then @v152mpositiontaking_51_max else co.maxpositiontaking end else 0 end) as v152mpositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 152 then case when @v152mpositiontaking_52_max<co.maxpositiontaking then @v152mpositiontaking_52_max else co.maxpositiontaking end else 0 end) as v152mpositiontaking_52_max,
		
		max(case when co.bettype = 51 and co.sporttype = 153 then case when @v153mpositiontaking_51_max<co.maxpositiontaking then @v153mpositiontaking_51_max else co.maxpositiontaking end else 0 end) as v153mpositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 153 then case when @v153mpositiontaking_52_max<co.maxpositiontaking then @v153mpositiontaking_52_max else co.maxpositiontaking end else 0 end) as v153mpositiontaking_52_max
	FROM customer c with (NOLOCK)
		INNER JOIN custinfo ci with (NOLOCK) on c.custid = ci.custid	
		INNER JOIN custinfo si WITH (NOLOCK) ON c.srecommend = si.custid
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
		INNER JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	WHERE c.custid = @custid and c.roleid = 3 and cs.sporttype between 151 and 153
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
		c.srecommend,
		si.DisableHorseracing,
		si.DisableOpenTote,
		si.Disable151_AU,
		si.Disable152_UK,
		si.Disable152_AU,
		si.Disable153_AU

		
		

		
		
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMaster_All] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMaster_All] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMaster_All] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMaster_All] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRMaster_All] TO [vnteam]
