  /*
	Created: 20170307Winnie
	Task : Initial data for CashOut. Add dummy trade
	DB: DBCust/CustDB.	 [RedmineID: #71727]
*/

CREATE TABLE #supers (custid INT PRIMARY KEY, currency INT,isfinished bit default(0))
INSERT INTO #supers(custid,currency)
SELECT ci.custid, ci.currency
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ci.roleid = 4 	
AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
AND c.Enabled=1	
AND ci.site IN ('Macaubet','Aoncash','ITCBET','9Bet','Allbetclub','m8bola','Q8Bola','NBCbet','BE7','Goobet','Bolanation','IndoWin','IvoryBet','Unobet')

DECLARE @srecommend INT
WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC Acc_CustomerInsDummyTrade	@ProductID	=25	
										,@CustID	=@srecommend
										,@UserID	=10278938
END