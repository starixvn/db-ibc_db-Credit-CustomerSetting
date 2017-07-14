
/*
	Created: Winnie	
	Task: Enable CashOut for new customer
	DB: DBCUST/CustDB
	Date: 20170515
*/ 
------------------------------------------------------
declare @MaxCustId int
set @MaxCustId = xxx	

create table #supers (srecommend int, isFinished bit default(0))
INSERT INTO #supers(srecommend)
SELECT ci.custid
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ci.roleid = 4 	
AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
AND c.Enabled=1	
AND ci.site IN ('Macaubet','Aoncash','ITCBET','9Bet','Allbetclub','m8bola','Q8Bola','NBCbet','BE7','Goobet','Bolanation','IndoWin','IvoryBet','Unobet')


INSERT INTO dbo.Dep_SupperProductSetting (CustID, ProductId, IsEnabled)
SELECT srecommend,25,1
FROM #supers WHERE srecommend>@maxcustid
	
INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
SELECT c.CustID, 25, 1
FROM Customer c WITH(NOLOCK) 
INNER JOIN #supers s ON c.srecommend=s.srecommend
WHERE custid>@maxcustid AND roleid=1 


UPDATE c SET c.VirtualMultiplier=0
FROM custInfo c WITH(ROWLOCK,UPDLOCK)
INNER JOIN TradeCust tc WITH(NOLOCK) ON c.custid=tc.custid

