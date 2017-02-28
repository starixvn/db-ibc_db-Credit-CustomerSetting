ALTER PROCEDURE [dbo].[Acc_CustomerSelAgentInfo] 
	@CustID int--agentID
AS
/*
Created by: []
Date:[]
Task: Add new Member at Agent Site
DB: DBAGE/BODB02, DBTXN/BODB02
Original: agentsite\account\addnewmember.asp

Revisions:
	- @PphuongDoan: remove '_1' on the SP name
	- 20090515@PhuongDao: Add 1x2 Commission
	- 20090521@PhuongDao: Get maxcredit from CustAgent 
	- 20090630@Phuc: remove check allowPT.
	- 20091118@Jamie: Assign the closed status of upline to member
	- 20091215@Kiwi: Remove HR (151) and Financials (201).
	- 20100729@Shifu: Grant execute for bodbExAccNet
	- 20100828@Henry: Add Mix Parlay Mixed Sports & Number Game
	- 20101027@Lukas: add max per ball (number game)
	- 20110614@Johnson: not check currency for HR SA Tote
*/
SET NOCOUNT ON

Declare @UserName varchar(20), @UplineUsername varchar(20),@Asuspended bit, @UplineClosed bit 
Declare @MinBet_Max money,
		@MaxBet_Min money,		
		@MaxPerMatch_Min money,
		@MaxPerMatch_Max money,
		
		@MinBetv2_Max money, 
		@MaxBetv2_Min money,		
		@MaxPerMatchv2_Min money,
		@MaxPerMatchv2_Max money,
		
		@MinBetv3_Max money, 
		@MaxBetv3_Min money,		
		@MaxPerMatchv3_Min money,
		@MaxPerMatchv3_Max money,

		@MinBetv5_Max money, 
		@MaxBetv5_Min money,		
		@MaxPerMatchv5_Min money,
		@MaxPerMatchv5_Max money,

		@MinBetv8_Max money, 
		@MaxBetv8_Min money,		
		@MaxPerMatchv8_Min money,
		@MaxPerMatchv8_Max money,

		@MinBetv10_Max money, 
		@MaxBetv10_Min money,		
		@MaxPerMatchv10_Min money,
		@MaxPerMatchv10_Max money,

		@MinBetv11_Max money, 
		@MaxBetv11_Min money,		
		@MaxPerMatchv11_Min money,
		@MaxPerMatchv11_Max money,
		
		@MinBetv99_Max money, 
		@MaxBetv99_Min money,		
		@MaxPerMatchv99_Min money,
		@MaxPerMatchv99_Max money,
		
		@MinBetv99MP_Max money,
		@MaxBetv99MP_Min money,
		@MaxPerMatchv99MP_Min money,
		@MaxPerMatchv99MP_Max money,
		
		@MinBetv161_Max money,
		@MaxBetv161_Min money,
		@MaxPerMatchv161_Min money,
		@MaxPerMatchv161_Max money,
	
		@MaxPerBallv161_Max money,	
	
		@Credit_AllOtherMember money, 
		@Credit_Ag money,
		@Credit_Mem_Max money, 
		@Credit_Ag_Bal money,
		@MaxCredit_Mem money,
		--@AllowedCurr bit,
		@CurrencyID int

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select @Credit_AllOtherMember = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where recommend = @CustID and RoleID = 1

select	@Credit_Ag = isnull(credit, 0),
		@Asuspended = reject , 
		@UplineClosed = closed,
		@CurrencyID=ci.currency
from CustInfo as ci with (NOLOCK) where CustID = @CustID

select @MaxCredit_Mem = isnull(maxcredit,0) from CustAgent WITH (NOLOCK) where CustID = @CustID

select @Credit_Ag_Bal = @Credit_Ag - @Credit_AllOtherMember
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select @Credit_Mem_Max = case when @MaxCredit_Mem =0  then @Credit_Ag_Bal 
							  when @MaxCredit_Mem > @Credit_Ag_Bal then @Credit_Ag_Bal
							  else @MaxCredit_Mem end 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @mrecommend int
select @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Select 
	@MinBet_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBet_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=1
where ci.custid = @CustID

Select 
	@MinBetv2_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv2_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=2
where ci.custid = @CustID

Select 
	@MinBetv3_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv3_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=3
where ci.custid = @CustID

Select 
	@MinBetv5_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv5_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=5
where ci.custid = @CustID

Select 
	@MinBetv8_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv8_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=8
where ci.custid = @CustID

Select 
	@MinBetv10_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv10_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=10
where ci.custid = @CustID

Select 
	@MinBetv11_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv11_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=11
where ci.custid = @CustID

Select 
	@MinBetv99_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 1 and cs.sporttype=99
where ci.custid = @CustID

Select 
	@MinBetv99MP_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv99MP_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 9 and cs.sporttype=99
where ci.custid = @CustID


Select 
	@MinBetv161_Max = Max(case when MinBet = 0 then NULL else MinBet end), 
	@MaxBetv161_Min = Min(case when MaxBet = 0 then NULL else MaxBet end)
from 
	custsetting3rd as cs WITH (NOLOCK)
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend) and cs.bettype = 81 and cs.sporttype=161
where ci.custid = @CustID


/*
--Revert MPM
Select 	
	@MaxPerMatch_Min = 0, @MaxPerMatchv2_Min = 0,
	@MaxPerMatch_Max = isnull(max(isnull(aci.MaxPerMatch, 0)), 0) - isnull(sum(ci.MaxPerMatch), 0),
	@MaxPerMatchv2_Max = isnull(max(isnull(aci.MaxPerMatchv2, 0)), 0) - isnull(sum(ci.MaxPerMatchv2), 0)
from 
	custinfo as aci WITH (NOLOCK) 
	LEFT JOIN custinfo as ci WITH (NOLOCK) on (aci.CustID = ci.Recommend)  and ci.roleid=1
where aci.custid=@custid
*/

Select	
	@MaxPerMatch_Min = 0,
	@MaxPerMatchv2_Min = 0,
	@MaxPerMatchv3_Min = 0,
	@MaxPerMatchv5_Min = 0,
	@MaxPerMatchv8_Min = 0,
	@MaxPerMatchv10_Min = 0,
	@MaxPerMatchv11_Min = 0,
	@MaxPerMatchv99_Min = 0,
	@MaxPerMatchv99MP_Min = 0,
	@MaxPerMatchv161_Min = 0,
	
	@MaxperMatch_Max = Min(case when cs.MaxPerMatch = 0 then NULL else cs.MaxPerMatch end), 
	@MaxPerMatchv2_Max = Min(case when cs.MaxPerMatch2 = 0 then NULL else cs.MaxPerMatch2 end),
	@MaxPerMatchv3_Max = Min(case when cs.MaxPerMatch3 = 0 then NULL else cs.MaxPerMatch3 end),
	@MaxPerMatchv5_Max = Min(case when cs.MaxPerMatch5 = 0 then NULL else cs.MaxPerMatch5 end),
	@MaxPerMatchv8_Max = Min(case when cs.MaxPerMatch8 = 0 then NULL else cs.MaxPerMatch8 end),
	@MaxPerMatchv10_Max = Min(case when cs.MaxPerMatch10 = 0 then NULL else cs.MaxPerMatch10 end),
	@MaxPerMatchv11_Max = Min(case when cs.MaxPerMatch11 = 0 then NULL else cs.MaxPerMatch11 end),	
	@MaxPerMatchv99_Max = Min(case when cs.MaxPerMatch99 = 0 then NULL else cs.MaxPerMatch99 end),
	@MaxPerMatchv99MP_Max = Min(case when cs.MaxPerMatch99MP = 0 then NULL else cs.MaxPerMatch99MP end),
	@MaxPerMatchv161_Max = Min(case when cs.MaxPerMatch161 = 0 then NULL else cs.MaxPerMatch161 end),
	@MaxPerBallv161_Max = Min(case when cs.MaxPerBall161 = 0 then NULL else cs.MaxPerBall161 end)
from 
	custinfo as cs WITH (NOLOCK) 
	INNER JOIN custinfo as ci WITH (NOLOCK) on (cs.CustID = ci.CustID or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
where ci.custid = @CustID

select @UplineUsername = ci.username 
from custinfo ci with (nolock) where custid = @CustID

/* Check Currency upline*/

--Exec Acc_CheckHRAllowedCurrency
--@currencyID=@CurrencyID,
--@Allowed= @AllowedCurr OUTPUT
----------------------------------------


Select @username = isnull(right(max(username),3), '000')
from customer with (nolock)
where recommend = @custid and roleid = 1
	and charindex(@UplineUsername, username) = 1
	and len(username) = len(@UplineUsername) + 3

Select
	@UserName as NewUserName,
	@Asuspended as suspended, 
	@UplineClosed as closed,
	--@AllowedCurr AS AllowedCurr,
	@Credit_Mem_Max as Credit_Max,
		
	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_3,
	max(case when cs.bettype = 4 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_4,
	max(case when cs.bettype = 5 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_5,
	max(case when cs.bettype = 6 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_6,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_8,
	max(case when cs.bettype = 9 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_9,
	max(case when cs.bettype = 10 and cs.sporttype=1 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as apositiontaking_10,

	max(case when cs.bettype = 1 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end) as alivepositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end) as alivepositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end) as alivepositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=1 then case when cs.alivepositiontaking<co.maxlivepositiontaking then cs.alivepositiontaking else co.maxlivepositiontaking end else 0 end) as alivepositiontaking_8,

	max(case when cs.bettype = 1 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_3,
	max(case when cs.bettype = 7 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_7,
	max(case when cs.bettype = 8 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_8,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=2 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v2apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v3apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v3apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v3apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=3 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v3apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v5apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v5apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v5apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=5 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v5apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v8apositiontaking_1,
	max(case when cs.bettype = 3 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v8apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=8 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v8apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v10apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v10apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v10apositiontaking_3,
	max(case when cs.bettype = 20 and cs.sporttype=10 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v10apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v11apositiontaking_1,
	max(case when cs.bettype = 20 and cs.sporttype=11 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v11apositiontaking_20,

	max(case when cs.bettype = 1 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v99apositiontaking_1,
	max(case when cs.bettype = 2 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v99apositiontaking_2,
	max(case when cs.bettype = 3 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v99apositiontaking_3,
	max(case when cs.bettype = 9 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v99apositiontaking_9,
	max(case when cs.bettype = 20 and cs.sporttype=99 then case when cs.apositiontaking<co.maxpositiontaking then cs.apositiontaking else co.maxpositiontaking end else 0 end) as v99apositiontaking_20,
	
	
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end) as v161apositiontaking_81,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end) as v161apositiontaking_83,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end) as v161apositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.apositiontaking<co3.maxpositiontaking then cs3.apositiontaking else co3.maxpositiontaking end else 0 end) as v161apositiontaking_86,
	
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161alivepositiontaking_85,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161alivepositiontaking_86,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then case when cs3.alivepositiontaking<co3.maxlivepositiontaking then cs3.alivepositiontaking else co3.maxlivepositiontaking end else 0 end) as v161alivepositiontaking_87,

--	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.discount else 0 end) as discount,
	max(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,
	max(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2,
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then cs3.discount else 0 end) as discountnumber,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
	max(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
	ci.maxpermatch,
	ci.maxpermatch2 as maxpermatchv2,
	ci.maxpermatch3 as maxpermatchv3,
	ci.maxpermatch5 as maxpermatchv5,
	ci.maxpermatch8 as maxpermatchv8,
	ci.maxpermatch10 as maxpermatchv10,
	ci.maxpermatch11 as maxpermatchv11,	
	ci.maxpermatch99 as maxpermatchv99,
	ci.maxpermatch99MP as maxpermatchv99MP,
	ci.maxpermatch161 as maxpermatchv161,
	ci.maxperball161 as maxperballv161,

	IsNull(@MinBet_Max, 0) as MinBet_Max,
	IsNull(@MaxBet_Min, 0) as MaxBet_Min,
	IsNull(@MaxPerMatch_Min, 0) as MaxPerMatch_Min,
	IsNull(@MaxPerMatch_Max, 0) as MaxPerMatch_Max,
	
	IsNull(@MinBetv2_Max, 0) as minbetv2_Max,	
	IsNull(@MaxBetv2_Min, 0) as maxbetv2_Min,	
	IsNull(@MaxPerMatchv2_Min, 0) as MaxPerMatchv2_Min,	
	IsNull(@MaxPerMatchv2_Max, 0) as MaxPerMatchv2_Max,
	
	IsNull(@MinBetv3_Max, 0) as minbetv3_Max,	
	IsNull(@MaxBetv3_Min, 0) as maxbetv3_Min,	
	IsNull(@MaxPerMatchv3_Min, 0) as MaxPerMatchv3_Min,	
	IsNull(@MaxPerMatchv3_Max, 0) as MaxPerMatchv3_Max,

	IsNull(@MinBetv5_Max, 0) as minbetv5_Max,	
	IsNull(@MaxBetv5_Min, 0) as maxbetv5_Min,	
	IsNull(@MaxPerMatchv5_Min, 0) as MaxPerMatchv5_Min,	
	IsNull(@MaxPerMatchv5_Max, 0) as MaxPerMatchv5_Max,

	IsNull(@MinBetv8_Max, 0) as minbetv8_Max,	
	IsNull(@MaxBetv8_Min, 0) as maxbetv8_Min,	
	IsNull(@MaxPerMatchv8_Min, 0) as MaxPerMatchv8_Min,	
	IsNull(@MaxPerMatchv8_Max, 0) as MaxPerMatchv8_Max,

	IsNull(@MinBetv10_Max, 0) as minbetv10_Max,	
	IsNull(@MaxBetv10_Min, 0) as maxbetv10_Min,	
	IsNull(@MaxPerMatchv10_Min, 0) as MaxPerMatchv10_Min,	
	IsNull(@MaxPerMatchv10_Max, 0) as MaxPerMatchv10_Max,

	IsNull(@MinBetv11_Max, 0) as minbetv11_Max,	
	IsNull(@MaxBetv11_Min, 0) as maxbetv11_Min,	
	IsNull(@MaxPerMatchv11_Min, 0) as MaxPerMatchv11_Min,	
	IsNull(@MaxPerMatchv11_Max, 0) as MaxPerMatchv11_Max,
	
	IsNull(@MinBetv99_Max, 0) as minbetv99_Max,	
	IsNull(@MaxBetv99_Min, 0) as maxbetv99_Min,	
	IsNull(@MaxPerMatchv99_Min, 0) as MaxPerMatchv99_Min,	
	IsNull(@MaxPerMatchv99_Max, 0) as MaxPerMatchv99_Max,
	
	IsNull(@MinBetv99MP_Max, 0) as minbetv99MP_Max,	
	IsNull(@MaxBetv99MP_Min, 0) as maxbetv99MP_Min,	
	IsNull(@MaxPerMatchv99MP_Min, 0) as MaxPerMatchv99MP_Min,	
	IsNull(@MaxPerMatchv99MP_Max, 0) as MaxPerMatchv99MP_Max,
	
	IsNull(@MinBetv161_Max, 0) as minbetv161_Max,	
	IsNull(@MaxBetv161_Min, 0) as maxbetv161_Min,	
	IsNull(@MaxPerMatchv161_Min, 0) as MaxPerMatchv161_Min,	
	IsNull(@MaxPerMatchv161_Max, 0) as MaxPerMatchv161_Max,
	isnull(@MaxPerBallv161_Max, 0) as MaxPerBallv161_Max,
	
	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_3_min,
	max(case when cs.bettype = 4 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_4_min,
	max(case when cs.bettype = 5 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_5_min,
	max(case when cs.bettype = 6 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_6_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_8_min,
	max(case when cs.bettype = 9 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_9_min,
	max(case when cs.bettype = 10 and cs.sporttype=1 then co.minpositiontaking else 0 end) as apositiontaking_10_min,

	max(case when cs.bettype = 1 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=1 then co.minlivepositiontaking else 0 end) as alivepositiontaking_8_min,

	max(case when cs.bettype = 1 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_3_min,
	max(case when cs.bettype = 7 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_7_min,
	max(case when cs.bettype = 8 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_8_min,
	--max(case when cs.bettype = 9 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_9_min,
	max(case when cs.bettype = 20 and cs.sporttype=2 then co.minpositiontaking else 0 end) as v2apositiontaking_20_min,
	
	max(case when cs.bettype = 1 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=3 then co.minpositiontaking else 0 end) as v3apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=5 then co.minpositiontaking else 0 end) as v5apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_1_min,
	max(case when cs.bettype = 3 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=8 then co.minpositiontaking else 0 end) as v8apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_3_min,
	max(case when cs.bettype = 20 and cs.sporttype=10 then co.minpositiontaking else 0 end) as v10apositiontaking_20_min,

	max(case when cs.bettype = 1 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_1_min,
	max(case when cs.bettype = 20 and cs.sporttype=11 then co.minpositiontaking else 0 end) as v11apositiontaking_20_min,
	
	max(case when cs.bettype = 1 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_1_min,
	max(case when cs.bettype = 2 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_2_min,
	max(case when cs.bettype = 3 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_3_min,
	max(case when cs.bettype = 9 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_9_min,	
	max(case when cs.bettype = 20 and cs.sporttype=99 then co.minpositiontaking else 0 end) as v99apositiontaking_20_min,
		
	
	
	--v161
	max(case when cs3.bettype = 81 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_81_min,
	max(case when cs3.bettype = 83 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_83_min,
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_85_min,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then co3.minpositiontaking else 0 end) as v161apositiontaking_86_min,
		
	max(case when cs3.bettype = 85 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_85_min,
	max(case when cs3.bettype = 86 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_86_min,
	max(case when cs3.bettype = 87 and cs3.sporttype=161 then co3.minlivepositiontaking else 0 end) as v161alivepositiontaking_87_min
	
	
From 
	Customer with (NOLOCK)
	INNER JOIN custinfo as ci with (NOLOCK) on Customer.CustID = ci.CustID
	INNER JOIN CustSetting as cs with (NOLOCK) on Customer.CustID = CS.CustID
	LEFT JOIN custoverride as co with (NOLOCK) on co.custid = cs.custid and co.sporttype=cs.sporttype and co.bettype= cs.bettype
	INNER JOIN CustSetting3rd as cs3 with (NOLOCK) on Customer.custid = cs3.custid 
	LEFT JOIN CustOverride3rd as co3 with (NOLOCK) on co3.custid = cs3.custid and co3.sporttype = cs3.sporttype and co3.bettype = cs3.bettype
	
Where Customer.CustID = @CustID
group by ci.maxpermatch,
	ci.maxpermatch2,
	ci.maxpermatch3,
	ci.maxpermatch5,
	ci.maxpermatch8,
	ci.maxpermatch10,
	ci.maxpermatch11,	
	ci.maxpermatch99,
	ci.maxpermatch99MP,
	ci.maxpermatch161,
	ci.maxperball161

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelAgentInfo] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelAgentInfo] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelAgentInfo] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelAgentInfo] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelAgentInfo] TO [vnteam]
