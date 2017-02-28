Alter PROCEDURE [dbo].[Acc_UserLogCreditSel]
	@Username VARCHAR(30) ,
	@FromDate DATETIME,
	@ToDate DATETIME
AS
/*
Created: Simon
Date: 2009-09-03
Task : View Credit Log.	
DB: DBLog.bodb_CustomerLog
Original:

Revisions: 
    - 20090903@Simon: View Credit Log for UserName.	
    - 20090921:HuyNguyen:
		+ Add linked server, remove inner join that gets username and custid in customer table.	
*/

SET NOCOUNT ON

DECLARE @custid INT
SELECT @custid = NULL
SELECT @custid = custid FROM bodb02.dbo.CustInfo WITH(NOLOCK) WHERE username = @username

SELECT 
	logid,
	@Username+'<br/>('+cast(@custid as varchar(30))+')' as username,
	o.username+'<br/>('+CAST(o.custid AS VARCHAR(30))+')' AS owner,
	spname,
	OldValue,
	NewValue,
	doing,
	ip,
	logdate
FROM userlog_Credit l WITH(NOLOCK) 
	LEFT JOIN bodb02.dbo.CustInfo o WITH(NOLOCK) ON o.custid = l.userid
WHERE l.custid=@custid AND logdate BETWEEN @FromDate AND @ToDate 
ORDER BY logdate DESC


GO
GRANT EXECUTE ON [dbo].[Acc_UserLogCreditSel] TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_UserLogCreditSel] TO [vnteam]
