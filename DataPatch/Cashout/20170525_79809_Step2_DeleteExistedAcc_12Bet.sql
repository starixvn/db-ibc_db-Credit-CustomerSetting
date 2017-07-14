/*
	Created: 20170714@Elodie
	Task : Initial data CashOut for 12Bet - Delete existed customer [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/
------------------------------------------------------

CREATE TABLE #supers (custid INT PRIMARY KEY, isfinished bit default(0))

INSERT INTO #supers(custid)
SELECT ci.srecommend
FROM Customer ci WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE (ci.roleid = 4 	
	AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
	AND c.Enabled=1	
	AND ci.site IN ('12Bet')
	AND ci.currency = 20) OR ci.custid = 14543986 --vndcsd


DELETE FROM dbo.Dep_SupperProductSetting
WHERE ProductId = 25 
	AND CustID IN (SELECT custid FROM #supers)

DELETE cs
FROM dbo.Dep_CustProductSetting cs
	INNER JOIN Customer c WITH(NOLOCK) ON cs.custid=c.Custid
WHERE cs.ProductId = 25 
	AND c.srecommend IN (SELECT custid FROM #supers)
	

