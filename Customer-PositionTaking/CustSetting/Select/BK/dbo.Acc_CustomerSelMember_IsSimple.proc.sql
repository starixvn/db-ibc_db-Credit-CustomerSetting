ALTER PROCEDURE [dbo].[Acc_CustomerSelMember_IsSimple]
	@CustID		INT , -- AgID
	@IsSimple	BIT = 0 OUTPUT
AS
/*
Created: 
Task : Check is simple mode(agent create member)
DB: DBCUST.CustDB
Revisions:
	- 20090412@Phuc: Remove unused parameters. 
	- 20090424@Phuc:Separate finance sporttype(201).
	- 20090612@Phuc: remove HR.
	- 20101012@Lukas: add number game & mix sports parlay	
	- 20110801@Lukas: (Number Game)
		- Add more bettypes: Warrior, Next Combo, Number Group
		- Remove Dead ball Over/Under
	- 20110831@Lukas: Not offer Number Group yet (exclude when check Is simple)
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
	• @CustID: AgentID.
	• @IsSimple: Simple mode.
*/

Set nocount on
declare 	
	@minpt1378 smallmoney,
	@minpt456920 smallmoney,
	@minpt10 smallmoney,
	@minptlive17 smallmoney,
	@minptlive38 smallmoney,

	@minpt81 smallmoney,
	@minptlive85 smallmoney,

	@MinBet_Max money,
	@MaxBet_Min money,
	@MaxPerMatch_Min money,
	@MaxPermatch_Max money,
	@MaxperMatchv1_Max money,
	@MaxPerMatchv2_Max money,
	@MaxPerMatchv3_Max money,
	@MaxPerMatchv5_Max money,
	@MaxPerMatchv8_Max money,
	@MaxPerMatchv10_Max money,
	@MaxPerMatchv11_Max money,
	@MaxPerMatchv99_Max money,

	@MaxPerMatchv99MP_Max money,
	@MaxPerMatchv161_Max money,

	@pt1378 smallmoney,
	@pt456920 smallmoney,
	@pt10 smallmoney,
	@ptlive17 smallmoney,
	@ptlive38 smallmoney,
	
	@pt81 smallmoney,
	@ptlive85 smallmoney,

	@MinBet money,
	@MaxBet money,
	@MaxPerMatch money
	
-- Minbet maxbet	

/*
Select 
	@MinBet_Max = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxBet_Min = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN (Select custid,mrecommend,srecommend from custinfo with(nolock) where custid = @CustID) ci 
		on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) 
		and ( (cs.bettype = 1 and cs.sporttype in (1,2,3,5,8,10,11,99)))
where ci.custid = @CustID
*/

select	@MinBet_Max = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0),
		@MaxBet_Min = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from (
		Select
			isnull(Max(case when MinBet = 0 then NULL else MinBet end),0) MinBet,
			isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0) MaxBet
		from 
			custsetting as cs WITH (NOLOCK)
			INNER JOIN (Select custid,mrecommend,srecommend from custinfo with(nolock) where custid = @CustID) ci 
				on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) 
				and ( (cs.bettype = 1 and cs.sporttype in (1,2,3,5,8,10,11,99)))
		where ci.custid = @CustID
		UNION ALL
		Select 
			isnull(Max(case when MinBet = 0 then NULL else MinBet end),0) MinBet, 
			isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0) MaxBet
		from 
			custsetting3rd as cs3 WITH (NOLOCK)
			INNER JOIN (Select custid,mrecommend,srecommend from custinfo with(nolock) where custid = @CustID) ci
				on (cs3.CustID = ci.CustID or cs3.CustID = ci.MRecommend or cs3.CustID = ci.SRecommend)
				and ( (cs3.bettype = 81 and cs3.sporttype = 161))
		where ci.custid = @CustID
	 ) a


-- MaxPerMatch
Select	
	@MaxPerMatch_Min = 0,
	@MaxperMatchv1_Max = isnull(Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),0), 
	@MaxPerMatchv2_Max = isnull(Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),0),
	@MaxPerMatchv3_Max = isnull(Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),0),
	@MaxPerMatchv5_Max = isnull(Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),0),
	@MaxPerMatchv8_Max = isnull(Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),0),
	@MaxPerMatchv10_Max = isnull(Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),0),
	@MaxPerMatchv11_Max = isnull(Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),0),
	@MaxPerMatchv99_Max = isnull(Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),0),
	@MaxPerMatchv99MP_Max = isnull(Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),0),
	@MaxPerMatchv161_Max = isnull(Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),0)	
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

select @maxpermatch_max = min(a.maxpermatch_max) from
(
	select @MaxperMatchv1_Max as maxpermatch_max
	union all
	select @MaxPerMatchv2_Max as maxpermatch_max
	union all
	select @MaxPerMatchv3_Max as maxpermatch_max
	union all
	select @MaxPerMatchv5_Max as maxpermatch_max
	union all
	select @MaxPerMatchv8_Max as maxpermatch_max
	union all
	select @MaxPerMatchv10_Max as maxpermatch_max
	union all
	select @MaxPerMatchv11_Max as maxpermatch_max
	union all
	select @MaxPerMatchv99_Max as maxpermatch_max
	union all
	select @MaxPerMatchv99MP_Max as maxpermatch_max
	union all
	select @MaxPerMatchv161_Max as maxpermatch_max
) a
-- Positiontaking
Select
	@minpt1378 = min(case when cs.bettype in(1,2,3,7,8) and cs.sporttype in (1,2,3,5,8,10,11,99) then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 1 end) ,
	@minpt456920 = min(case when cs.bettype in(4,5,6,9,20) then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 1 end),
	@minpt10 = min(case when cs.bettype in(10) then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 1 end),
	@minptlive17 = min(case when cs.bettype in(1,7) and cs.sporttype = 1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 1 end),
	@minptlive38 = min(case when cs.bettype in(3,8) and cs.sporttype = 1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 1 end)
From CustSetting as cs with (NOLOCK) 
	LEFT JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype= cs.bettype
Where cs.CustID = @CustID

-- number game
select	@minpt81 = min(case when cs3.bettype in (81,83,86,88) and cs3.sporttype = 161 then case when cs3.apositiontaking < co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 1 end),
		@minptlive85 = min (case when cs3.bettype in (85,86,87,89) and cs3.sporttype = 161 then case when cs3.alivepositiontaking < co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 1 end)
from custsetting3rd cs3 with(nolock)
	left join custoverride3rd co3 with(nolock) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
where cs3.custid = @custid

SELECT @minpt81 = CASE WHEN @minpt81 < @minptlive85 THEN  @minpt81 ELSE @minptlive85 END

Select
	@pt1378 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@pt456920 = max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),
	@pt10 = max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end),

	@ptlive17 = max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end),
	@ptlive38 = max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end)
From 
	CustSetting as cs with (NOLOCK) 
	LEFT JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype= cs.bettype
Where cs.CustID = @CustID

-- number game
select	@pt81 = max(case when cs3.bettype = 81 and cs3.sporttype = 161 then case when cs3.apositiontaking < co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end),
		@ptlive85 = max(case when cs3.bettype = 85 and cs3.sporttype = 161 then case when cs3.alivepositiontaking < co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end)
from custsetting3rd cs3 with(nolock)
		left join custoverride3rd co3 with(nolock) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
where cs3.custid = @custid

SELECT @pt81 = CASE WHEN @pt81 > @ptlive85 THEN  @pt81 ELSE @ptlive85 END

Select 
	@MinBet = isnull(Max(case when MinBet = 0 then NULL else MinBet end),0), 
	@MaxBet = isnull(Min(case when MaxBet = 0 then NULL else MaxBet end),0)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select	
	@MaxPerMatch = isnull(Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end),0) 
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

IF @Pt1378 <= @minpt1378 and @pt456920 <= @minpt456920 and @pt10 <= @minpt10 and @pt81 <= @minpt81 and @ptlive17 <= @minptlive17 and @ptlive38 <= @minptlive38
	and @MinBet >= @MinBet_Max and @MaxBet <= @MaxBet_Min and @MaxPerMatch >= @MaxPerMatch_Min and @MaxPerMatch <= @MaxPerMatch_Max 
		set @IsSimple = 1 
else
	set @IsSimple = 0






GO

GRANT EXECUTE ON [dbo].[Acc_CustomerSelMember_IsSimple] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMember_IsSimple] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMember_IsSimple] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMember_IsSimple] TO [vnteam]
