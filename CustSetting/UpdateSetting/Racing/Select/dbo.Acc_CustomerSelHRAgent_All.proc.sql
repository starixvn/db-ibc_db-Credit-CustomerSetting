ALTER PROCEDURE [dbo].[Acc_CustomerSelHRAgent_All]
	@custid int--agentID
AS
/*
Created: 20081028@PhuongNguyen
Task : Master edit agent.
DB: DBCUST.CustDB

Revisions:
	- 20090515@Phuc: PT for HR
	- 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20100414@Shifu: OpenTote
	- 20100729@Henry: Grant permission for bodbExtAccNet
	- 20101231@Johnson: Get setting for HR AU, Greyhound, Harness
	- 20130306@Johnson: Check bet setting with setting of 3rd
	- 20130506@Johnson: check null bet setting of 3rd
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: super ID
*/

	SET NOCOUNT ON
	Declare			
		@mrecommend int,
		@srecommend int,
		@v151Minbet_31 money,-- @Minbet_31 -> @v151Minbet_31		
		@v151Maxbet_31 money,-- @Maxbet_31 -> @v151Maxbet_31 
		@v151MaxPerMatch_31 money,-- @MaxPerMatch_31 -> @v151MaxPerMatch_31 
		@v151MinBet_31_Min money,--@MinBet_Min_31 -> @v151MinBet_Min_31 
		@v151Minbet3rd_31 money,
		@v151MaxBet_31_Max money,-- @MaxBet_Max_31 -> @v151MaxBet_Max_31 
		@v151MaxPerMatch_31_Max money,-- @MaxPerMatch_Max_31 -> @v151MaxPerMatch_Max_31 
		
		@v151Minbet_41 money,-- @Minbet_41 -> @v151Minbet_41
		@v151Maxbet_41 money,-- @Maxbet_41 -> @v151Maxbet_41
		@v151MaxPerMatch_41 money,-- @MaxPerMatch_41 -> @v151MaxPerMatch_41
		@v151MinBet_41_Min money,-- @MinBet_Min_41  -> @v151MinBet_Min_41 
		@v151Minbet3rd_41 money,
		@v151MaxBet_41_Max money,-- @MaxBet_Max_41 -> @v151MaxBet_Max_41 
		@v151MaxPerMatch_41_Max money,-- @MaxPerMatch_Max_41 -> @v151MaxPerMatch_Max_41 
		
		@v151MinBet_51 money,
		@v151MaxBet_51 money,
		@v151MaxPerMatch_51 money,
		@v151MinBet_51_Min money,
		@v151Minbet3rd_51 money,
		@v151MaxBet_51_Max money,
		@v151MaxPerMatch_51_Max money,
		
		@v152MinBet_41 money,
		@v152MaxBet_41 money,
		@v152MaxPerMatch_41 money,
		@v152MinBet_41_Min money,
		@v152Minbet3rd_41 money,
		@v152MaxBet_41_Max money,
		@v152MaxPerMatch_41_Max money,
		
		@v152MinBet_51 money,
		@v152MaxBet_51 money,
		@v152MaxPerMatch_51 money,
		@v152MinBet_51_Min money,
		@v152Minbet3rd_51 money,
		@v152MaxBet_51_Max money,
		@v152MaxPerMatch_51_Max money,
		
		@v153MinBet_51 money,
		@v153MaxBet_51 money,
		@v153MaxPerMatch_51 money,
		@v153MinBet_51_Min money,
		@v153Minbet3rd_51 money,
		@v153MaxBet_51_Max money,
		@v153MaxPerMatch_51_Max money,
			
		@v151discount_31 decimal(9,8),
		@v151discount_41 decimal(9,8),
		@v151discount_51 decimal(9,8),
		@v152discount_41 decimal(9,8),
		@v152discount_51 decimal(9,8),
		@v153discount_51 decimal(9,8),
		@v151discount_31_Max decimal(9,8),
		@v151discount_41_Max decimal(9,8),
		@v151discount_51_Max decimal(9,8),
		@v152discount_41_Max decimal(9,8),
		@v152discount_51_Max decimal(9,8),
		@v153discount_51_Max decimal(9,8),
		
		@DisableDownlines151_31 BIT,-- @DisableDownlinesHR -> @DisableDownlines151_31
		@DisableUplines151_31 BIT,-- @DisableUplineHR -> @DisableUplines151_31
		@DisableDownlines151_41 BIT,-- @DisableDownlinesOpenTote -> @DisableDownlines151_41
		@DisableUplines151_41 BIT,-- @DisableUplineOpenTote -> @DisableUplines151_41
		@DisableDownlines151_51 BIT,
		@DisableUplines151_51 BIT,
		@DisableDownlines152_41 BIT,
		@DisableUplines152_41 BIT,
		@DisableDownlines152_51 BIT,
		@DisableUplines152_51 BIT,
		@DisableDownlines153_51 BIT,
		@DisableUplines153_51 BIT,
		@DisableAutoMPT BIT,
		
		@downlines	BIT,
		@currency	INT 
 
		--@MeDisableHR bit
	SELECT @downlines = CASE WHEN EXISTS(SELECT top 1 1 FROM custinfo WITH(NOLOCK) WHERE recommend = @custid and roleid = 1) THEN 1 ELSE 0 END

	SELECT @mrecommend = mrecommend, @srecommend = srecommend, @currency = currency
	FROM custinfo WITH (NOLOCK) WHERE custid = @custid
	
	select @DisableUplines151_31 = isnull(DisableHorseRacing,0),
		   @DisableUplines151_41 = isnull(DisableOpenTote,0),
		   @DisableUplines151_51 = isnull(Disable151_AU,0),
		   @DisableUplines152_41 = isnull(Disable152_UK,0),
		   @DisableUplines152_51 = isnull(Disable152_AU,0),
		   @DisableUplines153_51 = isnull(Disable153_AU,0)		 
	 FROM custinfo with (NOLOCK) WHERE custid = @mrecommend
	 
	 
	--v151
	select top 1 @DisableDownlines151_31 = isnull(DisableHorseRacing,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and DisableHorseRacing = 1
	select top 1 @DisableDownlines151_41 = isnull(DisableOpenTote,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and DisableOpenTote = 1
	select top 1 @DisableDownlines151_51 = isnull(Disable151_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable151_AU = 1
	--v152
	select top 1 @DisableDownlines152_41 = isnull(Disable152_UK,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable152_UK = 1
	select top 1 @DisableDownlines152_51 = isnull(Disable152_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable152_AU = 1
	--v153
	select top 1 @DisableDownlines153_51 = isnull(Disable153_AU,0) from custinfo with (NOLOCK) WHERE recommend = @custid and roleid = 1 and Disable153_AU = 1
	
	--Disable auto master PT
	Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @Mrecommend
	
	
	--v151--
	--HR bet setting--
	SELECT
		@v151Minbet_31 = cs.minbet, 
		@v151Maxbet_31 = cs.maxbet, 
		@v151MaxPerMatch_31 = ci.maxpermatch151
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 31 AND cs.sporttype = 151
	
	SELECT  
		@v151MinBet_31_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v151MaxBet_31_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 31 and cs.sporttype=151  
	WHERE ci.custid = @CustID 	
	
	SELECT	@v151MaxperMatch_31_Max = Min(case when cs.MaxPerMatch151 = 0 then NULL else cs.MaxPerMatch151 end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID
	--end--	
	
	--OpenTote bet setting--
	SELECT
		@v151Minbet_41 = cs.minbet, 
		@v151Maxbet_41 = cs.maxbet, 
		@v151MaxPerMatch_41 = ci.maxpermatch151_OT
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 151
	
	SELECT  
		@v151MinBet_41_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v151MaxBet_41_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 41 and cs.sporttype=151  
	WHERE ci.custid = @CustID 	
	
	SELECT	@v151MaxperMatch_41_Max = Min(case when cs.MaxPerMatch151_OT = 0 then NULL else cs.MaxPerMatch151_OT end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID
	--end--	
	
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
		@v151MinBet_51_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v151MaxBet_51_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype=151  
	WHERE ci.custid = @CustID  
	
	SELECT	@v151MaxperMatch_51_Max = Min(case when cs.MaxPerMatch151_AU = 0 then NULL else cs.MaxPerMatch151_AU end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID 	
	--END
	
	--v152--
	--UK bet setting--
	SELECT
		@v152Minbet_41 = cs.minbet, 
		@v152Maxbet_41 = cs.maxbet, 
		@v152MaxPerMatch_41 = ci.maxpermatch152_UK
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 41 AND cs.sporttype = 152
	
	SELECT  
		@v152MinBet_41_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v152MaxBet_41_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 41 and cs.sporttype=152  
	WHERE ci.custid = @CustID 	
	
	SELECT	@v152MaxperMatch_41_Max = Min(case when cs.MaxPerMatch152_UK = 0 then NULL else cs.MaxPerMatch152_UK end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID
	--end--	
	
	--AU bet setting--
	SELECT
		@v152Minbet_51 = cs.minbet, 
		@v152Maxbet_51 = cs.maxbet, 
		@v152MaxPerMatch_51 = ci.MaxPerMatch152_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 152
	
	SELECT  
		@v152MinBet_51_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v152MaxBet_51_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype=152
	WHERE ci.custid = @CustID  
	
	SELECT	@v152MaxperMatch_51_Max = Min(case when cs.MaxPerMatch152_AU = 0 then NULL else cs.MaxPerMatch152_AU end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID 	
	--END
	
	--v153
	--AU bet setting--
	SELECT
		@v153Minbet_51 = cs.minbet, 
		@v153Maxbet_51 = cs.maxbet, 
		@v153MaxPerMatch_51 = ci.MaxPerMatch153_AU
	FROM custinfo as ci with (NOLOCK)
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on ci.custid  = cs.custid
	WHERE 
		ci.custid = @custId AND cs.bettype = 51 AND cs.sporttype = 153
	
	SELECT  
		@v153MinBet_51_Min = ISNULL(Max(case when MinBet = 0 then NULL else MinBet end),0),   
		@v153MaxBet_51_Max = ISNULL(Min(case when MaxBet = 0 then NULL else MaxBet end),0)	
	FROM CustSetting3rd as cs WITH (NOLOCK)  
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 51 and cs.sporttype=153
	WHERE ci.custid = @CustID  
	
	SELECT	@v153MaxperMatch_51_Max = Min(case when cs.MaxPerMatch153_AU = 0 then NULL else cs.MaxPerMatch153_AU end)	
	FROM custinfo as cs WITH (NOLOCK) 
		INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @CustID 	
	--END
	
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
		
	--v151 Comm--	
	SELECT 
		@v151discount_31 = max(case when bettype = 31 then discount else 0 end),
		@v151discount_41 = max(case when bettype = 41 then discount else 0 end),
		@v151discount_51 = max(case when bettype = 51 then discount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=151		
	--v152 Comm--
	SELECT 
		@v152discount_41 = max(case when bettype = 41 then discount else 0 end),
		@v152discount_51 = max(case when bettype = 51 then discount else 0 end)
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=152
	--v153 Comm--
	SELECT 		
		@v153discount_51 = discount
	FROM 
		CustSetting3rd as cs WITH (NOLOCK)
	WHERE cs.custid = @custid and cs.sporttype=153 and bettype = 51
	
	
	--Master Comm 	
	--v151--
	SELECT 
		@v151discount_31_Max = max(case when bettype = 31 then adiscount else 0 end),
		@v151discount_41_Max = max(case when bettype = 41 then adiscount else 0 end),
		@v151discount_51_Max = max(case when bettype = 51 then adiscount else 0 end)
	FROM CustSetting3rd with (nolock)
	WHERE custid = @mrecommend and sporttype = 151 
	
	--v152--
	SELECT 		
		@v152discount_41_Max = max(case when bettype = 41 then adiscount else 0 end),
		@v152discount_51_Max = max(case when bettype = 51 then adiscount else 0 end)
	FROM CustSetting3rd with (nolock)
	WHERE custid = @mrecommend and sporttype = 152 
	
	--v153
	SELECT 				
		@v153discount_51_Max = adiscount 
	FROM CustSetting3rd with (nolock)
	WHERE custid = @mrecommend and sporttype = 153 and bettype = 51	
	--END--	
	
Declare @min_v151mapositiontaking_31 smallmoney,
		@min_v151mapositiontaking_32 smallmoney,
		@min_v151mapositiontaking_41 smallmoney,
		@min_v151mapositiontaking_42 smallmoney,
		@min_v151mapositiontaking_51 smallmoney,
		@min_v151mapositiontaking_52 smallmoney,
		@min_v152mapositiontaking_41 smallmoney,
		@min_v152mapositiontaking_42 smallmoney,
		@min_v152mapositiontaking_51 smallmoney,
		@min_v152mapositiontaking_52 smallmoney,
		@min_v153mapositiontaking_51 smallmoney,
		@min_v153mapositiontaking_52 smallmoney,
		
		@max_v151mapositiontaking_31 smallmoney,
		@max_v151mapositiontaking_32 smallmoney,
		@max_v151mapositiontaking_41 smallmoney,
		@max_v151mapositiontaking_42 smallmoney,
		@max_v151mapositiontaking_51 smallmoney,
		@max_v151mapositiontaking_52 smallmoney,
		@max_v152mapositiontaking_41 smallmoney,
		@max_v152mapositiontaking_42 smallmoney,
		@max_v152mapositiontaking_51 smallmoney,
		@max_v152mapositiontaking_52 smallmoney,
		@max_v153mapositiontaking_51 smallmoney,
		@max_v153mapositiontaking_52 smallmoney,
		
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
		@v153apositiontaking_52_max smallmoney
--n3,l3		
--v151
select @min_v151mapositiontaking_31 =minpositiontaking, @max_v151mapositiontaking_31 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=31 and sporttype=151
select @min_v151mapositiontaking_32 =minpositiontaking, @max_v151mapositiontaking_32 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=32 and sporttype=151
select @min_v151mapositiontaking_41 =minpositiontaking, @max_v151mapositiontaking_41 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=151
select @min_v151mapositiontaking_42 =minpositiontaking, @max_v151mapositiontaking_42 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=151
select @min_v151mapositiontaking_51 =minpositiontaking, @max_v151mapositiontaking_51 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=151
select @min_v151mapositiontaking_52 =minpositiontaking, @max_v151mapositiontaking_52 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=151
--v152
select @min_v152mapositiontaking_41 =minpositiontaking, @max_v152mapositiontaking_41 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=41 and sporttype=152
select @min_v152mapositiontaking_42 =minpositiontaking, @max_v152mapositiontaking_42 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=42 and sporttype=152
select @min_v152mapositiontaking_51 =minpositiontaking, @max_v152mapositiontaking_51 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=152
select @min_v152mapositiontaking_52 =minpositiontaking, @max_v152mapositiontaking_52 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=152
--v153
select @min_v153mapositiontaking_51 =minpositiontaking, @max_v153mapositiontaking_51 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=51 and sporttype=153
select @min_v153mapositiontaking_52 =minpositiontaking, @max_v153mapositiontaking_52 =maxpositiontaking from CustOverride3rd with (NOLOCK) where custid = @mrecommend and bettype=52 and sporttype=153

--min(m3,l3)
--v151
Select
	@max_v151mapositiontaking_31 = max(case when cs.bettype = 31 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v151mapositiontaking_32 = max(case when cs.bettype = 32 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v151mapositiontaking_41 = max(case when cs.bettype = 41 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v151mapositiontaking_42 = max(case when cs.bettype = 42 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v151mapositiontaking_51 = max(case when cs.bettype = 51 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v151mapositiontaking_52 = max(case when cs.bettype = 52 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end)
from
	CustSetting3rd as cs with (nolock)
	inner join CustOverride3rd as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
where cs.custid = @mrecommend and cs.sporttype = 151
--v152
Select	
	@max_v152mapositiontaking_41 = max(case when cs.bettype = 41 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v152mapositiontaking_42 = max(case when cs.bettype = 42 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v152mapositiontaking_51 = max(case when cs.bettype = 51 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v152mapositiontaking_52 = max(case when cs.bettype = 52 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end)
from
	CustSetting3rd as cs with (nolock)
	inner join CustOverride3rd as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
where cs.custid = @mrecommend and cs.sporttype = 152
--v153
Select		
	@max_v153mapositiontaking_51 = max(case when cs.bettype = 51 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end),
	@max_v153mapositiontaking_52 = max(case when cs.bettype = 52 then case when cs.mpositiontaking < mco.maxpositiontaking then cs.mpositiontaking else mco.maxpositiontaking end else 0 end)
from
	CustSetting3rd as cs with (nolock)
	inner join CustOverride3rd as mco with (nolock) on cs.custid = mco.custid and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype
where cs.custid = @mrecommend and cs.sporttype = 153

--a4
--v151
Select
	@v151apositiontaking_31_max = max(case when cs.bettype = 31 then cs.apositiontaking else 0 end),
	@v151apositiontaking_32_max = max(case when cs.bettype = 32 then cs.apositiontaking else 0 end),
	@v151apositiontaking_41_max = max(case when cs.bettype = 41 then cs.apositiontaking else 0 end),
	@v151apositiontaking_42_max = max(case when cs.bettype = 42 then cs.apositiontaking else 0 end),
	@v151apositiontaking_51_max = max(case when cs.bettype = 51 then cs.apositiontaking else 0 end),
	@v151apositiontaking_52_max = max(case when cs.bettype = 52 then cs.apositiontaking else 0 end)
from CustSetting3rd as cs with (nolock)
where custid = @srecommend and sporttype = 151
--v152
SELECT
	@v152apositiontaking_41_max = max(case when cs.bettype = 41 then cs.apositiontaking else 0 end),
	@v152apositiontaking_42_max = max(case when cs.bettype = 42 then cs.apositiontaking else 0 end),
	@v152apositiontaking_51_max = max(case when cs.bettype = 51 then cs.apositiontaking else 0 end),
	@v152apositiontaking_52_max = max(case when cs.bettype = 52 then cs.apositiontaking else 0 end)
from CustSetting3rd as cs with (nolock)
where custid = @srecommend and sporttype = 152
--v153
SELECT
	@v153apositiontaking_51_max = max(case when cs.bettype = 51 then cs.apositiontaking else 0 end),
	@v153apositiontaking_52_max = max(case when cs.bettype = 52 then cs.apositiontaking else 0 end)
from CustSetting3rd as cs with (nolock)
where custid = @srecommend and sporttype = 153

	SELECT c.custid, c.username, c.firstname, c.lastname, 	
		ci.roleid, 			
		c.currency,	
		c.phone, 
		c.mobilephone, 
		c.fax, 
		
		ci.DisableHorseracing as Disable151_31,		
		case when @downlines = 0 then ci.DisableHorseRacing else isnull(@DisableDownlines151_31,0) end AS DisableDownlines151_31,
		isnull(@DisableUplines151_31,0) as DisableUplines151_31,			
		ci.DisableOpenTote as Disable151_41,		
		case when @downlines = 0 then ci.DisableOpenTote else isnull(@DisableDownlines151_41,0) end AS DisableDownlines151_41,
		isnull(@DisableUplines151_41,0) as DisableUplines151_41,			
		ci.Disable151_AU as Disable151_51,
		case when @downlines = 0 then ci.Disable151_AU else isnull(@DisableDownlines151_51,0) end as DisableDownlines151_51,
		isnull(@DisableUplines151_51,0) as DisableUplines151_51,
		ci.Disable152_UK as Disable152_41,
		case when @downlines = 0 then ci.Disable152_UK else isnull(@DisableDownlines152_41,0) end as DisableDownlines152_41,
		isnull(@DisableUplines152_41,0) as DisableUplines152_41,
		ci.Disable152_AU as Disable152_51,
		case when @downlines = 0 then ci.Disable152_AU else isnull(@DisableDownlines152_51,0) end as DisableDownlines152_51,
		isnull(@DisableUplines152_51,0) as DisableUplines152_51,
		ci.Disable153_AU as Disable153_51,
		case when @downlines = 0 then ci.Disable153_AU else isnull(@DisableDownlines153_51,0) end as DisableDownlines153_51,
		isnull(@DisableUplines153_51,0) as DisableUplines153_51,		
		isnull(@DisableAutoMPT,0) as DisableAutoMPT,
		
		c.mrecommend as parentid,
		
		--v151--
		ISNULL(@v151Minbet_31,0)			AS v151minbet_31, 
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
		--v152--
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
		--v153--
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
		ISNULL(@v151discount_31_Max,0) as v151discount_31_max,
		ISNULL(@v151discount_41_Max,0) as v151discount_41_max,
		ISNULL(@v151discount_51_Max,0) as v151discount_51_max,
		ISNULL(@v152discount_41_Max,0) as v152discount_41_max,
		ISNULL(@v152discount_51_Max,0) as v152discount_51_max,
		ISNULL(@v153discount_51_Max,0) as v153discount_51_max,
		
		--a2
		--v151--
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_52,
		
		--v152--
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_52,
		
		--v153--
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_52,
		
		--m2
		--v151--
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_52,
		--v152--
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_52,
		--v153
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_52,

		--u2
		--v151--
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_52,
		--v152--
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_52,
		--v153--
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_52,
		
		--i2
		--v151--
		max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_31,
		max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_32,
		max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_52,
		--v152
		max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_41,
		max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_42,
		max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_52,
		--v153--
		max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_51,
		max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_52,
		
		--u2_max
		@max_v151mapositiontaking_31 as auto_v151mpositiontaking_31_max,
		@max_v151mapositiontaking_32 as auto_v151mpositiontaking_32_max,
		@max_v151mapositiontaking_41 as auto_v151mpositiontaking_41_max,
		@max_v151mapositiontaking_42 as auto_v151mpositiontaking_42_max,
		@max_v151mapositiontaking_51 as auto_v151mpositiontaking_51_max,
		@max_v151mapositiontaking_52 as auto_v151mpositiontaking_52_max,
		
		@max_v152mapositiontaking_41 as auto_v152mpositiontaking_41_max,
		@max_v152mapositiontaking_42 as auto_v152mpositiontaking_42_max,
		@max_v152mapositiontaking_51 as auto_v152mpositiontaking_51_max,
		@max_v152mapositiontaking_52 as auto_v152mpositiontaking_52_max,
		
		@max_v153mapositiontaking_51 as auto_v153mpositiontaking_51_max,
		@max_v153mapositiontaking_52 as auto_v153mpositiontaking_52_max,

		--(m2+a2)max
		@max_v151mapositiontaking_31 as v151mapositiontaking_31_max,
		@max_v151mapositiontaking_32 as v151mapositiontaking_32_max,
		@max_v151mapositiontaking_41 as v151mapositiontaking_41_max,
		@max_v151mapositiontaking_42 as v151mapositiontaking_42_max,
		@max_v151mapositiontaking_51 as v151mapositiontaking_51_max,
		@max_v151mapositiontaking_52 as v151mapositiontaking_52_max,
		
		@max_v152mapositiontaking_41 as v152mapositiontaking_41_max,
		@max_v152mapositiontaking_42 as v152mapositiontaking_42_max,
		@max_v152mapositiontaking_51 as v152mapositiontaking_51_max,
		@max_v152mapositiontaking_52 as v152mapositiontaking_52_max,
		
		@max_v153mapositiontaking_51 as v153mapositiontaking_51_max,
		@max_v153mapositiontaking_52 as v153mapositiontaking_52_max,
		
		--(m2+a2)min
		@min_v151mapositiontaking_31 as v151mapositiontaking_31_min,
		@min_v151mapositiontaking_32 as v151mapositiontaking_32_min,
		@min_v151mapositiontaking_41 as v151mapositiontaking_41_min,
		@min_v151mapositiontaking_42 as v151mapositiontaking_42_min,
		@min_v151mapositiontaking_51 as v151mapositiontaking_51_min,
		@min_v151mapositiontaking_52 as v151mapositiontaking_52_min,
		
		@min_v152mapositiontaking_41 as v152mapositiontaking_41_min,
		@min_v152mapositiontaking_42 as v152mapositiontaking_42_min,
		@min_v152mapositiontaking_51 as v152mapositiontaking_51_min,
		@min_v152mapositiontaking_52 as v152mapositiontaking_52_min,
		
		@min_v153mapositiontaking_51 as v153mapositiontaking_51_min,
		@min_v153mapositiontaking_52 as v153mapositiontaking_52_min,
		--n2
		max(case when co.bettype = 31 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_31_min,
		max(case when co.bettype = 32 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_32_min,
		max(case when co.bettype = 41 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_41_min,
		max(case when co.bettype = 42 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_42_min,
		max(case when co.bettype = 51 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 151 then co.minpositiontaking else 0 end) as v151apositiontaking_52_min,
		
		max(case when co.bettype = 41 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152apositiontaking_41_min,
		max(case when co.bettype = 42 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152apositiontaking_42_min,
		max(case when co.bettype = 51 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152apositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 152 then co.minpositiontaking else 0 end) as v152apositiontaking_52_min,
		
		max(case when co.bettype = 51 and co.sporttype = 153 then co.minpositiontaking else 0 end) as v153apositiontaking_51_min,
		max(case when co.bettype = 52 and co.sporttype = 153 then co.minpositiontaking else 0 end) as v153apositiontaking_52_min,
		--min(a4,l2)
		max(case when co.bettype = 31 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_31_max then co.maxpositiontaking else @v151apositiontaking_31_max end else 0 end) as v151apositiontaking_31_max,
		max(case when co.bettype = 32 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_32_max then co.maxpositiontaking else @v151apositiontaking_32_max end else 0 end) as v151apositiontaking_32_max,
		max(case when co.bettype = 41 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_41_max then co.maxpositiontaking else @v151apositiontaking_41_max end else 0 end) as v151apositiontaking_41_max,
		max(case when co.bettype = 42 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_42_max then co.maxpositiontaking else @v151apositiontaking_42_max end else 0 end) as v151apositiontaking_42_max,
		max(case when co.bettype = 51 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_51_max then co.maxpositiontaking else @v151apositiontaking_51_max end else 0 end) as v151apositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 151 then case when co.maxpositiontaking<@v151apositiontaking_52_max then co.maxpositiontaking else @v151apositiontaking_52_max end else 0 end) as v151apositiontaking_52_max,
		
		max(case when co.bettype = 41 and co.sporttype = 152 then case when co.maxpositiontaking<@v152apositiontaking_41_max then co.maxpositiontaking else @v152apositiontaking_41_max end else 0 end) as v152apositiontaking_41_max,
		max(case when co.bettype = 42 and co.sporttype = 152 then case when co.maxpositiontaking<@v152apositiontaking_42_max then co.maxpositiontaking else @v152apositiontaking_42_max end else 0 end) as v152apositiontaking_42_max,
		max(case when co.bettype = 51 and co.sporttype = 152 then case when co.maxpositiontaking<@v152apositiontaking_51_max then co.maxpositiontaking else @v152apositiontaking_51_max end else 0 end) as v152apositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 152 then case when co.maxpositiontaking<@v152apositiontaking_52_max then co.maxpositiontaking else @v152apositiontaking_52_max end else 0 end) as v152apositiontaking_52_max,
		
		max(case when co.bettype = 51 and co.sporttype = 153 then case when co.maxpositiontaking<@v153apositiontaking_51_max then co.maxpositiontaking else @v153apositiontaking_51_max end else 0 end) as v153apositiontaking_51_max,
		max(case when co.bettype = 52 and co.sporttype = 153 then case when co.maxpositiontaking<@v153apositiontaking_52_max then co.maxpositiontaking else @v153apositiontaking_52_max end else 0 end) as v153apositiontaking_52_max
		
	FROM customer c with (nolock)
		INNER JOIN custinfo ci with (NOLOCK) on c.custid = ci.custid
		INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
		INNER JOIN CustOverride3rd as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype=cs.bettype
	WHERE c.custid = @custid AND cs.sporttype between 151 AND 153
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
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_All] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_All] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_All] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRAgent_All] TO [bodbDownlineNetView]
GO

