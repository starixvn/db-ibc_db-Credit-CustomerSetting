/*
	Created: 20170714@Elodie
	Task : Initial data CashOut for 12Bet - Enable CashOut for new customer [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/
------------------------------------------------------
DECLARE @MaxCustId INT
SET @MaxCustId = xxx	

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

INSERT INTO dbo.Dep_SupperProductSetting (CustID, ProductId, IsEnabled)
SELECT custid,25,1
FROM #supers WHERE custid > @maxcustid
	
INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
SELECT c.CustID, 25, 1
FROM Customer c WITH(NOLOCK) 
INNER JOIN #supers s ON c.srecommend=s.custid
WHERE c.custid > @maxcustid AND roleid=1 

UPDATE c 
SET c.VirtualMultiplier=0
FROM custInfo c WITH(ROWLOCK,UPDLOCK)
	INNER JOIN TradeCust tc WITH(NOLOCK) ON c.custid = tc.custid

INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
SELECT 14543986 AS CustID, 25, 1


