ALTER PROCEDURE [dbo].[Acc_CustomerSelHRMember_All]
	@custid int
AS
/*
Created: 20081028@PhuongNguyen
Task : Get Horse Racing information
DB: DBCUST.CustDB

Revisions:
	- 20090515@Phuc: PT for HR
	- 20090630@Phuc: auto master PT on member level.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100510@Shifu: Get OpenTote min/max bet
	- 20110103@Johnson: Get setting for HR AU, Greyhound, Harness
	- 20130307@Johnson: Check bet setting with setting of 3rd
	- 20130520@Johnson: check null bet setting of 3rd
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: super ID
*/
SET NOCOUNT ON
Declare 
	@AgentID int,		
	@MasterID int,
	@SuperID int,
	@currency int,
	@v151Minbet_31 money,-- @Minbet_31 -> @v151Minbet_31
	@v151Maxbet_31 money,-- @Maxbet_31 -> @v151Maxbet_31
	@v151MaxPerMatch_31 money,-- @MaxPerMatch_31 -> @v151MaxPerMatch_31
	@v151MinBet_31_Min money,-- @MinBet_Min_31 -> @v151MinBet_31_Min
	@v151Minbet3rd_31 money,
	@v151MaxBet_31_Max money,-- @MaxBet_Max_31 -> @v151MaxBet_31_Max
	@v151MaxPerMatch_31_Max money,-- @MaxPerMatch_Max_31 -> @v151MaxPerMatch_31_Max
	
	@v151Minbet_41 money,-- @Minbet_41 -> @v151Minbet_41
	@v151Maxbet_41 money,-- @Maxbet_41-> @v151Maxbet_41
	@v151MaxPerMatch_41 money,-- @MaxPerMatch_41 -> @v151MaxPerMatch_41 
	@v151MinBet_41_Min money,-- @MinBet_Min_41-> @v151MinBet_41_Min
	@v151Minbet3rd_41 money,
	@v151MaxBet_41_Max money,-- @MaxBet_Max_41-> @v151MaxBet_41_Max
	@v151MaxPerMatch_41_Max money,-- @MaxPerMatch_Max_41 -> @v151MaxPerMatch_41_Max
	
	@v151Minbet_51 money,
	@v151Maxbet_51 money,
	@v151MaxPerMatch_51 money,
	@v151MinBet_51_Min money,
	@v151Minbet3rd_51 money,
	@v151MaxBet_51_Max money,
	@v151MaxPerMatch_51_Max money,
	
	@v152Minbet_41 money,
	@v152Maxbet_41 money,
	@v152MaxPerMatch_41 money,
	@v152MinBet_41_Min money,
	@v152Minbet3rd_41 money,
	@v152MaxBet_41_Max money,
	@v152MaxPerMatch_41_Max money,
	
	@v152Minbet_51 money,
	@v152Maxbet_51 money,
	@v152MaxPerMatch_51 money,
	@v152MinBet_51_Min money,
	@v152Minbet3rd_51 money,
	@v152MaxBet_51_Max money,
	@v152MaxPerMatch_51_Max money,
	
	@v153Minbet_51 money,
	@v153Maxbet_51 money,
	@v153MaxPerMatch_51 money,
	@v153MinBet_51_Min money,
	@v153Minbet3rd_51 money,
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
		
	@v151discount_31_Master money,
	@v151discount_41_Master money,
	@v151discount_51_Master money,
	@v152discount_41_Master money,
	@v152discount_51_Master money,
	@v153discount_51_Master money,
	
	@v151apositiontaking_31_max smallmoney,
	@v151apositiontaking_32_max smallmoney,
	@v151apositiontaking_41_max smallmoney,
	@v151apositiontaking_42_max smallmoney,
	@v151apositiontaking_51_max smallmoney,
	@v151apositiontaking_52_max smallmoney,
	
	@v152apositiontaking_41_max smallmoney,
	@v152apositiontaking_42_max smallmoney,
	@v152apositiontaking_51_max smallmoney,
	@v152apositiontaking_52_max smallmoney,
	
	@v153apositiontaking_51_max smallmoney,
	@v153apositiontaking_52_max smallmoney,
	
	@v151apositiontaking_31_min smallmoney,
	@v151apositiontaking_32_min smallmoney,
	@v151apositiontaking_41_min smallmoney,
	@v151apositiontaking_42_min smallmoney,
	@v151apositiontaking_51_min smallmoney,
	@v151apositiontaking_52_min smallmoney,
	
	@v152apositiontaking_41_min smallmoney,
	@v152apositiontaking_42_min smallmoney,
	@v152apositiontaking_51_min smallmoney,
	@v152apositiontaking_52_min smallmoney,
	
	@v153apositiontaking_51_min smallmoney,
	@v153apositiontaking_52_min smallmoney,
	
	@v151sp_31 smallmoney,
	@v151sp_32 smallmoney,
	@v151sp_41 smallmoney,
	@v151sp_42 smallmoney,
	@v151sp_51 smallmoney,
	@v151sp_52 smallmoney,
	@v152sp_41 smallmoney,
	@v152sp_42 smallmoney,
	@v152sp_51 smallmoney,
	@v152sp_52 smallmoney,
	@v153sp_51 smallmoney,
	@v153sp_52 smallmoney,
	
	@cs_v151ap_31 smallmoney,
	@cs_v151ap_32 smallmoney,
	@cs_v151ap_41 smallmoney,
	@cs_v151ap_42 smallmoney,
	@cs_v151ap_51 smallmoney,
	@cs_v151ap_52 smallmoney,
	@cs_v152ap_41 smallmoney,
	@cs_v152ap_42 smallmoney,
	@cs_v152ap_51 smallmoney,
	@cs_v152ap_52 smallmoney,
	@cs_v153ap_51 smallmoney,
	@cs_v153ap_52 smallmoney
	--end--		
	
	SELECT @AgentID = recommend, @MasterID = mrecommend, @SuperID = srecommend, @currency = currency
	FROM customer WITH (NOLOCK) WHERE custid = @custid
	
	--v151
	--HR bet setting--
	SELECT
		@v151Minbet_31 = MAX(CASE WHEN cs3.bettype = 31 AND cs3.sporttype = 151 THEN cs3.minbet ELSE 0 END), 
		@v151Maxbet_31 = MAX(CASE WHEN cs3.bettype = 31 AND cs3.sporttype = 151 THEN cs3.maxbet ELSE 0 END), 
		@v151Minbet_41 = MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 151 THEN cs3.minbet ELSE 0 END), 
		@v151Maxbet_41 = MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 151 THEN cs3.maxbet ELSE 0 END), 
		@v151Minbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 151 THEN cs3.minbet ELSE 0 END), 
		@v151Maxbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 151 THEN cs3.maxbet ELSE 0 END), 
		@v152Minbet_41 = MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 152 THEN cs3.minbet ELSE 0 END), 
		@v152Maxbet_41 = MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 152 THEN cs3.maxbet ELSE 0 END), 
		@v152Minbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 152 THEN cs3.minbet ELSE 0 END), 
		@v152Maxbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 152 THEN cs3.maxbet ELSE 0 END), 
		@v153Minbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 153 THEN cs3.minbet ELSE 0 END), 
		@v153Maxbet_51 = MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 153 THEN cs3.maxbet ELSE 0 END)
	FROM CustSetting3rd as cs3 with (NOLOCK)
	WHERE 
		cs3.custid = @custId AND cs3.sporttype BETWEEN 151 AND 153

	SELECT	@v151MaxPerMatch_31 = maxpermatch151,
			@v151MaxPerMatch_41 = maxpermatch151_OT,
			@v151MaxPerMatch_51 = maxpermatch151_AU,
			@v152MaxPerMatch_41 = maxpermatch152_UK,
			@v152MaxPerMatch_51 = maxpermatch152_AU,
			@v153MaxPerMatch_51 = maxpermatch153_AU
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custId


	SELECT  
		@v151MinBet_31_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 31 AND cs3.sporttype = 151 THEN MinBet ELSE NULL END),0),   
		@v151MaxBet_31_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 31 AND cs3.sporttype = 151 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END ELSE NULL END),0),	
		@v151MinBet_41_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 151 THEN MinBet ELSE NULL END),0),  
		@v151MaxBet_41_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 151 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END  ELSE NULL END),0),	
		@v151MinBet_51_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 151 THEN MinBet ELSE NULL END),0),  
		@v151MaxBet_51_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 151 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END  ELSE NULL END),0),	
		@v152MinBet_41_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 152 THEN MinBet ELSE NULL END),0),  
		@v152MaxBet_41_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 41 AND cs3.sporttype = 152 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END  ELSE NULL END),0),	
		@v152MinBet_51_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 152 THEN MinBet ELSE NULL END),0),  
		@v152MaxBet_51_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 152 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END  ELSE NULL END),0),	
		@v153MinBet_51_Min = ISNULL(MAX(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 153 THEN MinBet ELSE NULL END),0),  
		@v153MaxBet_51_Max = ISNULL(MIN(CASE WHEN cs3.bettype = 51 AND cs3.sporttype = 153 THEN CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END  ELSE NULL END),0)	
	FROM CustSetting3rd as cs3 WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) ON 
			(cs3.CustID = ci.Recommend or cs3.CustID = ci.MRecommend or cs3.CustID = ci.SRecommend) 			
	WHERE ci.custid = @CustID  AND cs3.sporttype BETWEEN 151 AND 153
	
	--Check bet setting with setting of 3rd
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
		

	SELECT 		
		@v151MaxperMatch_31_Max = MIN(CASE WHEN cs.MaxPerMatch151    = 0 THEN NULL ELSE cs.MaxPerMatch151    END),
		@v151MaxperMatch_41_Max = MIN(CASE WHEN cs.MaxPerMatch151_OT = 0 THEN NULL ELSE cs.MaxPerMatch151_OT END),
		@v151MaxperMatch_51_Max = MIN(CASE WHEN cs.MaxPerMatch151_AU = 0 THEN NULL ELSE cs.MaxPerMatch151_AU END),
		@v152MaxperMatch_41_Max = MIN(CASE WHEN cs.MaxPerMatch152_UK = 0 THEN NULL ELSE cs.MaxPerMatch152_UK END),
		@v152MaxperMatch_51_Max = MIN(CASE WHEN cs.MaxPerMatch152_AU = 0 THEN NULL ELSE cs.MaxPerMatch152_AU END),
		@v153MaxperMatch_51_Max = MIN(CASE WHEN cs.MaxPerMatch153_AU = 0 THEN NULL ELSE cs.MaxPerMatch153_AU END)
	FROM custinfo as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID
	--end--
	
	
	--HR commission
	SELECT 
		@v151discount_31 = MAX(CASE WHEN bettype = 31 AND sporttype = 151 THEN playerdiscount ELSE 0 END),
		@v151discount_41 = MAX(CASE WHEN bettype = 41 AND sporttype = 151 THEN playerdiscount ELSE 0 END),
		@v151discount_51 = MAX(CASE WHEN bettype = 51 AND sporttype = 151 THEN playerdiscount ELSE 0 END),
		@v152discount_41 = MAX(CASE WHEN bettype = 41 AND sporttype = 152 THEN playerdiscount ELSE 0 END),
		@v152discount_51 = MAX(CASE WHEN bettype = 51 AND sporttype = 152 THEN playerdiscount ELSE 0 END),
		@v153discount_51 = MAX(CASE WHEN bettype = 51 AND sporttype = 153 THEN playerdiscount ELSE 0 END)
	FROM CustSetting3rd with (nolock)
	WHERE sporttype BETWEEN 151 AND 153 AND custid = @custid
	
	--Agent Comm
	SELECT 
		@v151discount_31_Max = MAX(CASE WHEN bettype = 31 AND sporttype = 151 THEN discount ELSE 0 END),
		@v151discount_41_Max = MAX(CASE WHEN bettype = 41 AND sporttype = 151 THEN discount ELSE 0 END),
		@v151discount_51_Max = MAX(CASE WHEN bettype = 51 AND sporttype = 151 THEN discount ELSE 0 END),
		@v152discount_41_Max = MAX(CASE WHEN bettype = 41 AND sporttype = 152 THEN discount ELSE 0 END),
		@v152discount_51_Max = MAX(CASE WHEN bettype = 51 AND sporttype = 152 THEN discount ELSE 0 END),
		@v153discount_51_Max = MAX(CASE WHEN bettype = 51 AND sporttype = 153 THEN discount ELSE 0 END)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @AgentID and cs.sporttype	BETWEEN 151 AND 153
	
	--Master Comm 	
	SELECT 
		@v151discount_31_Master = MAX(CASE WHEN bettype = 31 AND sporttype = 151 THEN adiscount ELSE 0 END),
		@v151discount_41_Master = MAX(CASE WHEN bettype = 41 AND sporttype = 151 THEN adiscount ELSE 0 END),
		@v151discount_51_Master = MAX(CASE WHEN bettype = 51 AND sporttype = 151 THEN adiscount ELSE 0 END),
		@v152discount_41_Master = MAX(CASE WHEN bettype = 41 AND sporttype = 152 THEN adiscount ELSE 0 END),
		@v152discount_51_Master = MAX(CASE WHEN bettype = 51 AND sporttype = 152 THEN adiscount ELSE 0 END),
		@v153discount_51_Master = MAX(CASE WHEN bettype = 51 AND sporttype = 153 THEN adiscount ELSE 0 END)
	FROM CustSetting3rd as cs with (nolock)
	WHERE cs.custid = @MasterID AND cs.sporttype BETWEEN 151 AND 153
	
	
--@apos_max = min(a2,l2)
Select 	
	@v151apositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v151apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=151 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@v152apositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v152apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=152 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
	@v153apositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype=153 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@v153apositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype=153 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	
		
	@v151apositiontaking_31_min = max(case when co.bettype = 31 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151apositiontaking_32_min = max(case when co.bettype = 32 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151apositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151apositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151apositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=151 then co.minpositiontaking else 0 end),
	@v151apositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=151 then co.minpositiontaking else 0 end),
	
	@v152apositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152apositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152apositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=152 then co.minpositiontaking else 0 end),
	@v152apositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=152 then co.minpositiontaking else 0 end),
	
	@v153apositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype=153 then co.minpositiontaking else 0 end),
	@v153apositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype=153 then co.minpositiontaking else 0 end)
From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @AgentID and cs.sporttype between 151 and 153

Select 
	@v151sp_31 = max(case when Scs.bettype = 31 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	@v151sp_32 = max(case when Scs.bettype = 32 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	@v151sp_41 = max(case when Scs.bettype = 41 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	@v151sp_42 = max(case when Scs.bettype = 42 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	@v151sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	@v151sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype=151 then Scs.spositiontaking else 0 end),
	
	@v152sp_41 = max(case when Scs.bettype = 41 and Scs.sporttype=152 then Scs.spositiontaking else 0 end),
	@v152sp_42 = max(case when Scs.bettype = 42 and Scs.sporttype=152 then Scs.spositiontaking else 0 end),
	@v152sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype=152 then Scs.spositiontaking else 0 end),
	@v152sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype=152 then Scs.spositiontaking else 0 end),
	
	@v153sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype=153 then Scs.spositiontaking else 0 end),
	@v153sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype=153 then Scs.spositiontaking else 0 end)
From CustSetting3rd as Scs with (NOLOCK)
where scs.CustID = @SuperID and scs.sporttype between 151 and 153

--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
Select 
	@cs_v151ap_31 = max(case when cs.bettype = 31 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_31-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_31-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_32 = max(case when cs.bettype = 32 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_32-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_32-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_41 = max(case when cs.bettype = 41 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_41-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_41-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_42 = max(case when cs.bettype = 42 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_42-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_42-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_51 = max(case when cs.bettype = 51 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_51-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_51-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v151ap_52 = max(case when cs.bettype = 52 and cs.sporttype=151 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v151sp_52-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v151sp_52-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_v152ap_41 = max(case when cs.bettype = 41 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v152sp_41-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v152sp_41-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_42 = max(case when cs.bettype = 42 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v152sp_42-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v152sp_42-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_51 = max(case when cs.bettype = 51 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v152sp_51-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v152sp_51-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v152ap_52 = max(case when cs.bettype = 52 and cs.sporttype=152 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v152sp_52-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v152sp_52-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	
	@cs_v153ap_51 = max(case when cs.bettype = 51 and cs.sporttype=153 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v153sp_51-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v153sp_51-cs.spositiontaking-cs.mpositiontaking end end end else 0 end),
	@cs_v153ap_52 = max(case when cs.bettype = 52 and cs.sporttype=153 then case when (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1) then acs.apositiontaking else case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 ) then mcs.mpositiontaking-cs.mpositiontaking else case when mcs.mpositiontaking-cs.mpositiontaking<=@v153sp_52-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v153sp_52-cs.spositiontaking-cs.mpositiontaking end end end else 0 end)			
From CustSetting3rd as cs with (NOLOCK) 
	inner join customer as c with (nolock) on cs.custid = c.custid
	inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend and mcs.bettype = cs.bettype and mcs.sporttype = cs.sporttype
	inner join CustSetting3rd as acs with (nolock) on acs.custid = c.recommend and acs.bettype = cs.bettype and acs.sporttype = cs.sporttype
where cs.custid = @custid and cs.sporttype between 151 and 153

--max_a1 = min(min(a2,l2),max_a1)
select 
	@v151apositiontaking_31_max = case when @v151apositiontaking_31_max <= @cs_v151ap_31 then @v151apositiontaking_31_max else @cs_v151ap_31 end,
	@v151apositiontaking_32_max = case when @v151apositiontaking_32_max <= @cs_v151ap_32 then @v151apositiontaking_32_max else @cs_v151ap_32 end,
	@v151apositiontaking_41_max = case when @v151apositiontaking_41_max <= @cs_v151ap_41 then @v151apositiontaking_41_max else @cs_v151ap_41 end,
	@v151apositiontaking_42_max = case when @v151apositiontaking_42_max <= @cs_v151ap_42 then @v151apositiontaking_42_max else @cs_v151ap_42 end,
	@v151apositiontaking_51_max = case when @v151apositiontaking_51_max <= @cs_v151ap_51 then @v151apositiontaking_51_max else @cs_v151ap_51 end,
	@v151apositiontaking_52_max = case when @v151apositiontaking_52_max <= @cs_v151ap_52 then @v151apositiontaking_52_max else @cs_v151ap_52 end,
	
	@v152apositiontaking_41_max = case when @v152apositiontaking_41_max <= @cs_v152ap_41 then @v152apositiontaking_41_max else @cs_v152ap_41 end,
	@v152apositiontaking_42_max = case when @v152apositiontaking_42_max <= @cs_v152ap_42 then @v152apositiontaking_42_max else @cs_v152ap_42 end,
	@v152apositiontaking_51_max = case when @v152apositiontaking_51_max <= @cs_v152ap_51 then @v152apositiontaking_51_max else @cs_v152ap_51 end,
	@v152apositiontaking_52_max = case when @v152apositiontaking_52_max <= @cs_v152ap_52 then @v152apositiontaking_52_max else @cs_v152ap_52 end,
	
	@v153apositiontaking_51_max = case when @v153apositiontaking_51_max <= @cs_v153ap_51 then @v153apositiontaking_51_max else @cs_v153ap_51 end,
	@v153apositiontaking_52_max = case when @v153apositiontaking_52_max <= @cs_v153ap_52 then @v153apositiontaking_52_max else @cs_v153ap_52 end

	--customer info
	SELECT 
		c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		
		ci.DisableHorseracing as Disable151_31,			
		ai.DisableHorseracing AS DisableUplines151_31,		
		ci.DisableOpenTote as Disable151_41,			
		ai.DisableOpenTote AS DisableUplines151_41,		
		ci.Disable151_AU as Disable151_51,
		ai.Disable151_AU as DisableUplines151_51,		
		ci.Disable152_UK as Disable152_41,
		ai.Disable152_UK as DisableUplines152_41,		
		ci.Disable152_AU as Disable152_51,
		ai.Disable152_AU as DisableUplines152_51,		
		ci.Disable153_AU as Disable153_51,
		ai.Disable153_AU as DisableUplines153_51,
		
		c.recommend AS parentid,
		
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
		ISNULL(@v151minbet_51,0)			AS v151minbet_51, 
		ISNULL(@v151maxbet_51,0)			AS v151maxbet_51, 
		ISNULL(@v151maxpermatch_51,0)		AS v151maxpermatch_51,
		ISNULL(@v151MinBet_51_Min,0)		AS v151MinBet_51_Min,
		ISNULL(@v151MaxBet_51_Max,0)		AS v151MaxBet_51_Max,
		ISNULL(@v151MaxperMatch_51_Max,0)	AS v151MaxperMatch_51_Max,
		
		--v152
		ISNULL(@v152minbet_41,0)			AS v152minbet_41, 
		ISNULL(@v152maxbet_41,0)			AS v152maxbet_41, 
		ISNULL(@v152maxpermatch_41,0)		AS v152maxpermatch_41,
		ISNULL(@v152MinBet_41_Min,0)		AS v152MinBet_41_Min,
		ISNULL(@v152MaxBet_41_Max,0)		AS v152MaxBet_41_Max,
		ISNULL(@v152MaxperMatch_41_Max,0)	AS v152MaxperMatch_41_Max,
		ISNULL(@v152minbet_51,0)			AS v152minbet_51, 
		ISNULL(@v152maxbet_51,0)			AS v152maxbet_51, 
		ISNULL(@v152maxpermatch_51,0)		AS v152maxpermatch_51,
		ISNULL(@v152MinBet_51_Min,0)		AS v152MinBet_51_Min,
		ISNULL(@v152MaxBet_51_Max,0)		AS v152MaxBet_51_Max,
		ISNULL(@v152MaxperMatch_51_Max,0)	AS v152MaxperMatch_51_Max,
		
		--v153
		ISNULL(@v153minbet_51,0)			AS v153minbet_51, 
		ISNULL(@v153maxbet_51,0)			AS v153maxbet_51, 
		ISNULL(@v153maxpermatch_51,0)		AS v153maxpermatch_51,
		ISNULL(@v153MinBet_51_Min,0)		AS v153MinBet_51_Min,
		ISNULL(@v153MaxBet_51_Max,0)		AS v153MaxBet_51_Max,
		ISNULL(@v153MaxperMatch_51_Max,0)	AS v153MaxperMatch_51_Max,
		
		ISNULL(@v151discount_31,0) as v151discount_31,
		ISNULL(@v151discount_41,0) as v151discount_41,
		ISNULL(@v151discount_51,0) as v151discount_51,
		ISNULL(@v152discount_41,0) as v152discount_41,
		ISNULL(@v152discount_51,0) as v152discount_51,
		ISNULL(@v153discount_51,0) as v153discount_51,
		
		ISNULL(@v151discount_31_Max,0) as v151discount_31_Max,
		ISNULL(@v151discount_41_Max,0) as v151discount_41_Max,
		ISNULL(@v151discount_51_Max,0) as v151discount_51_Max,
		ISNULL(@v152discount_41_Max,0) as v152discount_41_Max,
		ISNULL(@v152discount_51_Max,0) as v152discount_51_Max,
		ISNULL(@v153discount_51_Max,0) as v153discount_51_Max,
		
		ISNULL(@v151discount_31_Master,0) as v151adiscount_31,
		ISNULL(@v151discount_41_Master,0) as v151adiscount_41,
		ISNULL(@v151discount_51_Master,0) as v151adiscount_51,
		ISNULL(@v152discount_41_Master,0) as v152adiscount_41,
		ISNULL(@v152discount_51_Master,0) as v152adiscount_51,	
		ISNULL(@v153discount_51_Master,0) as v153adiscount_51,	
				
		--a1
		isnull(max(case when cs.bettype = 31 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_31,
		isnull(max(case when cs.bettype = 32 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_32,
		isnull(max(case when cs.bettype = 41 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_41,
		isnull(max(case when cs.bettype = 42 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_42,
		isnull(max(case when cs.bettype = 51 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_51,
		isnull(max(case when cs.bettype = 52 and cs.sporttype = 151	then cs.apositiontaking else 0 end), 0) as v151apositiontaking_52,
		
		isnull(max(case when cs.bettype = 41 and cs.sporttype = 152	then cs.apositiontaking else 0 end), 0) as v152apositiontaking_41,
		isnull(max(case when cs.bettype = 42 and cs.sporttype = 152	then cs.apositiontaking else 0 end), 0) as v152apositiontaking_42,
		isnull(max(case when cs.bettype = 51 and cs.sporttype = 152	then cs.apositiontaking else 0 end), 0) as v152apositiontaking_51,
		isnull(max(case when cs.bettype = 52 and cs.sporttype = 152	then cs.apositiontaking else 0 end), 0) as v152apositiontaking_52,
		
		isnull(max(case when cs.bettype = 51 and cs.sporttype = 153	then cs.apositiontaking else 0 end), 0) as v153apositiontaking_51,
		isnull(max(case when cs.bettype = 52 and cs.sporttype = 153	then cs.apositiontaking else 0 end), 0) as v153apositiontaking_52,
		--a1_max
		isnull(@v151apositiontaking_31_max, 0) as v151pos_31_max,
		isnull(@v151apositiontaking_32_max, 0) as v151pos_32_max,
		isnull(@v151apositiontaking_41_max, 0) as v151pos_41_max,
		isnull(@v151apositiontaking_42_max, 0) as v151pos_42_max,
		isnull(@v151apositiontaking_51_max, 0) as v151pos_51_max,
		isnull(@v151apositiontaking_52_max, 0) as v151pos_52_max,
		
		isnull(@v152apositiontaking_41_max, 0) as v152pos_41_max,
		isnull(@v152apositiontaking_42_max, 0) as v152pos_42_max,
		isnull(@v152apositiontaking_51_max, 0) as v152pos_51_max,
		isnull(@v152apositiontaking_52_max, 0) as v152pos_52_max,
		
		isnull(@v153apositiontaking_51_max, 0) as v153pos_51_max,
		isnull(@v153apositiontaking_52_max, 0) as v153pos_52_max,
		
		--n2
		isnull(@v151apositiontaking_31_min, 0) as v151pos_31_min,
		isnull(@v151apositiontaking_32_min, 0) as v151pos_32_min,
		isnull(@v151apositiontaking_41_min, 0) as v151pos_41_min,
		isnull(@v151apositiontaking_42_min, 0) as v151pos_42_min,
		isnull(@v151apositiontaking_51_min, 0) as v151pos_51_min,
		isnull(@v151apositiontaking_52_min, 0) as v151pos_52_min,
		
		isnull(@v152apositiontaking_41_min, 0) as v152pos_41_min,
		isnull(@v152apositiontaking_42_min, 0) as v152pos_42_min,
		isnull(@v152apositiontaking_51_min, 0) as v152pos_51_min,
		isnull(@v152apositiontaking_52_min, 0) as v152pos_52_min,
		
		isnull(@v153apositiontaking_51_min, 0) as v153pos_51_min,
		isnull(@v153apositiontaking_52_min, 0) as v153pos_52_min
	FROM customer c WITH (NOLOCK)
		INNER JOIN custinfo ci WITH (NOLOCK) ON c.custid = ci.custid
		INNER JOIN custinfo ai WITH (NOLOCK) ON c.recommend = ai.custid	
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	WHERE c.custid = @custid and cs.sporttype between 151 and 153
	GROUP BY 
		c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		ci.DisableHorseracing,			
		ai.DisableHorseracing,
		ci.DisableOpenTote,			
		ai.DisableOpenTote,
		ci.Disable151_AU,
		ai.Disable151_AU,
		ci.Disable152_UK,
		ai.Disable152_UK,
		ci.Disable152_AU,
		ai.Disable152_AU,
		ci.Disable153_AU,
		ai.Disable153_AU,
		c.recommend

	


	



	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMember_All] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMember_All] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMember_All] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRMember_All] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRMember_All] TO [vnteam]