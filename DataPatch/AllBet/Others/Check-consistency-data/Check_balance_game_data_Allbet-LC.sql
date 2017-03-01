
use bodb02
go

/*
	check balance game data for Allbet
	run on dbtrans
*/
declare @winlostdate smalldatetime

select @winlostdate = '2016-03-22' --replace winlostdate...

declare @sourcedata table (custid int, bettype smallint, winlostdate smalldatetime, winlost money)
declare @targetdata table (custid int, bettype smallint, winlostdate smalldatetime, winlost money)

--check balance game
insert into @sourcedata(custid, winlostdate, winlost, bettype)
select custid, winlostdate, sum(winlost-actual_stake) as winlost, 2401
from dbo.bettransLC with(nolock)
where productID = 211
	and gameid between 2401 and 2499
	and winlostdate = @winlostdate
	and statusID in (112, 113)
group by custid, winlostdate

insert into @targetdata(custid, winlostdate, bettype, winlost)
select custid, winlostdate, bettype, sum(balance) as winlost
from (
	select c.custid, c.winlostdate, c.bettype, c.balance
	from dbo.BalanceCreditGame c with(nolock)
	inner join @sourcedata s on c.custid = s.custid and c.winlostdate = s.winlostdate and c.bettype = s.bettype
	
	union all
	select c.custid, c.winlostdate, c.bettype, c.balance * -1
	from dbo.BalanceDebitGame c with(nolock)
	inner join @sourcedata s on c.custid = s.custid and c.winlostdate = s.winlostdate and c.bettype = s.bettype
)t
group by custid, winlostdate, bettype

select *
from @sourcedata s
	full outer join @targetdata t on t.custid = s.custid and t.winlostdate = s.winlostdate and t.bettype = s.bettype
where isnull(s.winlost, 0) <> isnull(t.winlost, 0)

go
