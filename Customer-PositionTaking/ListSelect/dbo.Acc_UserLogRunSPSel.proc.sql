USE [bodb_CustomerLog]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Acc_UserLogRunSPSel]
	@Username varchar(30) ,
	@FromDate datetime,
	@ToDate datetime
as
/*
Created: 
Task : View log Run SP
DB: DB052.bodb_CustomerLog
Original:

Revisions:
	- 20090921:HuyNguyen:
		+ Add linked server, remove inner join that gets username and custid in customer table.	

Param's Explanation:
• @Username:Customer who will be shown his logs
*/
SET NOCOUNT ON
Declare @custid int
Select @custid = null
Select @custid = custid From bodb02.dbo.CustInfo with(nolock) where username = @username

Select 
	logid,
	@Username+'<br/>('+cast(@custid as varchar(30))+')' as username,
	o.username+'<br/>('+cast(o.custid as varchar(30))+')' as owner,
	spname,
	doing,
	logdate
from userlog_runsp l with(nolock) 
	inner join bodb02.dbo.CustInfo o with(nolock) on o.custid = l.userid
where l.custid=@custid and logdate between @FromDate and @ToDate 
order by logid desc,spname



GO
GRANT EXECUTE ON [dbo].[Acc_UserLogRunSPSel] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_UserLogRunSPSel] TO [vnteam]