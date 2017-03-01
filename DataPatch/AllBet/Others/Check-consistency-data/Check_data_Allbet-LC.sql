use bodb02
go
/*
	check data consistency on bettransLC and bettrans for Allbet
	run on db06/dbtp
*/
declare @fromdate smalldatetime, @todate smalldatetime

select @fromdate = '2016-03-22'
select @todate = '2016-03-22'

declare @tempdata table (custid int, username varchar(50), transid bigint, ProductID int, gameid smallint
	, stake money, actual_stake money, netstake money
	, apositiontaking smallmoney, mpositiontaking smallmoney, spositiontaking smallmoney, tpositiontaking smallmoney
	, playerdiscount decimal (9,8), discount decimal(9,8), adiscount decimal(9,8), sdiscount decimal(9,8)
	, winlost money, awinlost money, mwinlost money, swinlost money
	, playercomm money, comm money, acomm money, scomm money
	, winlostdate smalldatetime, status varchar(10), issum bit, StatusID tinyint)
	
declare @sourcedata table (custid int, username varchar(50), matchid int
	, bettype smallint, winlostdate smalldatetime, status varchar(10)
	, turnover money, winlost money, awinlost money, mwinlost money, swinlost money
	, scomm money, acomm money, comm money, playercomm money
	, apositiontaking smallmoney, mpositiontaking smallmoney, spositiontaking smallmoney, tpositiontaking smallmoney
	, playerdiscount decimal (9,8), discount decimal(9,8), adiscount decimal(9,8), sdiscount decimal(9,8))

declare @targetdata table (custid int, username varchar(50), matchid int
	, bettype smallint, winlostdate smalldatetime, status varchar(10)
	, turnover money, winlost money, awinlost money, mwinlost money, swinlost money
	, scomm money, acomm money, comm money, playercomm money
	, apositiontaking smallmoney, mpositiontaking smallmoney, spositiontaking smallmoney, tpositiontaking smallmoney
	, playerdiscount decimal (9,8), discount decimal(9,8), adiscount decimal(9,8), sdiscount decimal(9,8))

insert into @tempdata (custid, username, transid, ProductID, gameid
	, stake, actual_stake, netstake
	, apositiontaking, mpositiontaking, spositiontaking, tpositiontaking
	, playerdiscount, discount, adiscount, sdiscount
	, winlost, awinlost, mwinlost, swinlost
	, playercomm, comm, acomm, scomm
	, winlostdate, status, issum, StatusID)
select custid, username, transid, ProductID, gameid
	, stake, actual_stake, netstake
	, apositiontaking, mpositiontaking, spositiontaking, tpositiontaking
	, playerdiscount, discount, adiscount, sdiscount
	, winlost, awinlost, mwinlost, swinlost
	, playercomm, comm, acomm, scomm
	, winlostdate, status, issum, StatusID
from dbo.bettransLC with (nolock)
where productID = 211 --Allbet
	and gameid between 2401 and 2499
	and winlostdate between @fromdate and @todate

--Case 1: Check sum all detail tickets in BettransLC & sum ticket in Bettrans
insert into @sourcedata(custid, username, matchid, bettype, winlostdate, status
	, turnover, winlost, awinlost, swinlost, mwinlost, scomm, acomm, comm, playercomm
	, apositiontaking, mpositiontaking, spositiontaking, tpositiontaking
	, playerdiscount, discount, adiscount, sdiscount)
select custid, username, productid, gameID, winlostdate
	, case when sum(winlost-actual_stake) > 0 then 'WON'
		when sum(winlost-actual_stake) < 0 then 'LOSE'
	 else 'DRAW' end as status
	, sum(stake) as stake, sum(winlost - actual_stake) as winlost, sum(awinlost) as awinlost, sum(swinlost) as swinlost, sum(mwinlost) as mwinlost
	, sum(scomm) as scomm, sum(acomm) as acomm, sum(comm) as comm, sum(playercomm) as playercomm
	, avg(apositiontaking) as apositiontaking, avg(mpositiontaking) as mpositiontaking, avg(spositiontaking) as spositiontaking, avg(tpositiontaking) as tpositiontaking
	, avg(playerdiscount) as playerdiscount, avg(discount) as discount, avg(adiscount) as adiscount, avg(sdiscount) as sdiscount
from @tempdata 
where issum = 1
group by custid, username, productid, gameid, winlostdate

insert into @targetdata(custid, username, matchid, bettype, winlostdate, status
	, turnover, winlost, awinlost, swinlost, mwinlost, scomm, acomm, comm, playercomm
	, apositiontaking, mpositiontaking, spositiontaking, tpositiontaking
	, playerdiscount, discount, adiscount, sdiscount)
select custid, username, matchid, bettype, winlostdate, status
	, sum(stake) as stake, sum(winlost-actual_stake) as winlost
	, sum(awinlost) as awinlost, sum(swinlost) as swinlost, sum(mwinlost) as mwinlost
	, sum(scomm) as scomm, sum(acomm) as acomm, sum(comm) as comm, sum(playercomm) as playercomm
	, avg(apositiontaking) as apositiontaking, avg(mpositiontaking) as mpositiontaking, avg(spositiontaking) as spositiontaking, avg(tpositiontaking) as tpositiontaking
	, avg(playerdiscount) as playerdiscount, avg(discount) as discount, avg(adiscount) as adiscount, avg(sdiscount) as sdiscount
from dbo.bettrans with(nolock)
where matchid = 211
	and bettype between 2401 and 2499
	and winlostdate between @fromdate and @todate
	and statusid not in (0, 1)
group by custid, username, matchid, bettype, winlostdate, status

select 'Case 1' AS [CASE], s.*, t.*
from @sourcedata s
	full outer join @targetdata t 
		on s.custid = t.custid 
			and s.bettype = t.bettype 
			and s.winlostdate = t.winlostdate
where isnull(s.turnover, 0) <> isnull(t.turnover, 0)
	or isnull(s.winlost, 0) <> isnull(t.winlost, 0)
	or isnull(s.swinlost, 0) <> isnull(t.swinlost, 0) 
	or isnull(s.mwinlost, 0) <> isnull(t.mwinlost, 0) 
	or isnull(s.awinlost, 0) <> isnull(t.awinlost, 0)
	
	or isnull(s.scomm, 0) <> isnull(t.scomm, 0) 
	or isnull(s.acomm, 0) <> isnull(t.acomm, 0) 
	or isnull(s.comm, 0) <> isnull(t.comm, 0) 
	or isnull(s.playercomm, 0) <> isnull(t.playercomm, 0)

	or isnull(s.apositiontaking, 0) <> isnull(t.apositiontaking, 0)
	or isnull(s.mpositiontaking, 0) <> isnull(t.mpositiontaking, 0)
	or isnull(s.spositiontaking, 0) <> isnull(t.spositiontaking, 0)
	or isnull(s.tpositiontaking, 0) <> isnull(t.tpositiontaking, 0)

	or isnull(s.playerdiscount, 0) <> isnull(t.playerdiscount, 0)
	or isnull(s.discount, 0) <> isnull(t.discount, 0)
	or isnull(s.adiscount, 0) <> isnull(t.adiscount, 0)
	or isnull(s.sdiscount, 0) <> isnull(t.sdiscount, 0)

	or isnull(s.status, 0) <> isnull(t.status, 0)

--Case 2,3,4,5
select top 100 'Case 2,3,4' AS [CASE]
	, t.*
	, case when (winlost > actual_stake and status <> 'WON') then 'Issue: Status should be WON'
			 when (winlost = actual_stake and status not in ('DRAW', 'REFUND')) then 'Issue: Status should be DRAW/REFUND'
			 when (winlost < actual_stake and status <> 'LOSE') then 'Issue: Status should be LOSE'
			 when (-(winlost - actual_stake) * apositiontaking <> awinlost) then 'Issue: awinlost is calculated wrongly' 
			 when (-(winlost - actual_stake) * mpositiontaking <> mwinlost) then 'Issue: mwinlost is calculated wrongly' 
			 when (-(winlost - actual_stake) * spositiontaking <> swinlost) then 'Issue: swinlost is calculated wrongly' 
			 when (stake * playerdiscount <> playercomm) then 'Issue: playercomm is wrong'
			 when (netstake * discount * (1 - apositiontaking) <> comm) then 'Issue: comm is wrong'
			 when (netstake * adiscount * (1 - (mpositiontaking + apositiontaking)) <> acomm) then 'Issue: acomm is wrong'
			 when (netstake * sdiscount * (1 - (spositiontaking + mpositiontaking + apositiontaking)) <> scomm) then 'Issue: scomm is wrong'
		end as 'Comment'
from @tempdata t
where StatusId not in (0,1)
	and ((winlost > actual_stake and status <> 'WON')--Case 2: Check data in BettransLC - if winlost - actual_stake > 0 -> status=WON
		or (winlost = actual_stake and status  not in ('DRAW', 'REFUND'))--Case 3: Check data in BettransLC - if winlost - actual_stake = 0 -> status=DRAW
		or (winlost < actual_stake and status <> 'LOSE')--Case 4: Check data in BettransLC - if winlost - actual_stake < 0 -> status=LOSE

		or (-(winlost - actual_stake) * apositiontaking <> awinlost) --Case 5: Check data in BettransLC - awinlost, playercomm are calculated correctly
		or (-(winlost - actual_stake) * mpositiontaking <> mwinlost)
		or (-(winlost - actual_stake) * spositiontaking <> swinlost)

		or (statusid in (112,113) and (cast(netstake * playerdiscount as money) <> playercomm)) --Case 5b: playercomm is wrong
		or (statusid in (112,113) and (cast(netstake * discount * (1 - apositiontaking) as money) <> comm)) --Case 5c: comm is wrong
		or (statusid in (112,113) and (cast(netstake * adiscount * (1 - (mpositiontaking + apositiontaking)) as money) <> acomm)) --Case 5d: acomm is wrong
		or (statusid in (112,113) and (cast(netstake * sdiscount * (1 - (spositiontaking + mpositiontaking + apositiontaking)) as money) <> scomm)) --Case 5e: scomm is wrong
		)

--------------------------
--Case 6,7:
;with bettransLCTmp as (
	select custid, gameid, max(transid) as transid  
	from @tempdata
	where statusid not in (0,1)
	group by custid, gameID
), ptSetting as (
	select ci.custid, pt.sporttype, pt.bettype, convert(money, pt.SuperPT)/100 as SuperPT, convert(money, pt.MasterPT)/100 as MasterPT, convert(money, pt.AgentPT)/100 as AgentPT
	from dbo.CustPTGroupSetting3rd_Member pt with(nolock)
		inner join dbo.custinfo ci with(nolock)	on ci.recommend = pt.agentid
	where exists (select top 1 1 from @tempdata tt where ci.custid = tt.custid)
		and pt.sporttype = 211 and pt.bettype = 2401 and pt.IsLive = 0
	
	union all
	select pt.custid, pt.sporttype, pt.bettype, convert(money, pt.SuperPT)/100 as SuperPT, convert(money, pt.MasterPT)/100 as MasterPT, convert(money, pt.AgentPT)/100 as AgentPT
	from dbo.CustPTSetting3rd_Member pt with(nolock)
	where exists (select top 1 1 from @tempdata tt where pt.custid = tt.custid)
		and pt.sporttype = 211 and pt.bettype = 2401 and pt.IsLive = 0

), discountSetting as (
	select d.custid, d.sporttype, d.bettype, d.PlayerDiscount, d.AgentDiscount, d.MasterDiscount, d.SuperDiscount
	from dbo.CustDiscount3rd_Member d with(nolock)
	where exists (select top 1 1 from @tempdata tt where d.custid = tt.custid)
		and d.sporttype = 211 and d.bettype = 2401
)

select top 100 'Case 6,7' AS [CASE], b.custid, b.transid, b.gameID, b.playerdiscount, b.discount
	,  b.adiscount, b.sdiscount, b.apositiontaking, b.mpositiontaking, b.spositiontaking, b.tpositiontaking
	, pt.*, d.*
from bettransLC b with (nolock)
	inner join bettransLCTmp t on b.custid = t.custid and b.transid = t.transid
	inner join ptSetting pt on b.custid = pt.custid
	inner join discountSetting d on b.custid = d.custid
where (b.playerdiscount <> d.PlayerDiscount
	or b.discount <> d.AgentDiscount
	or b.adiscount <> d.MasterDiscount
	or b.sdiscount <> d.SuperDiscount
	or b.apositiontaking <> pt.AgentPT --Case 6: detect apositiontaking is wrong when placing bet
	or b.mpositiontaking <> pt.MasterPT --Case 6: detect mpositiontaking is wrong when placing bet
	or b.spositiontaking <> pt.SuperPT --Case 6: detect spositiontaking is wrong when placing bet
	or b.apositiontaking + b.mpositiontaking + b.spositiontaking <> b.tpositiontaking --Case 7: detect apositiontaking + mpositiontaking + spositiontaking <>tpositiontaking
	)

go

