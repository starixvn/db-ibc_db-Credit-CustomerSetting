/*
	Created: 20170714@Elodie
	Task : Initial data CashOut for 12Bet - Add dummy trade [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/

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
	

DECLARE @srecommend INT

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC Acc_CustomerInsDummyTrade	
		@ProductID	=25	
		,@CustID	=@srecommend
		,@UserID	=10278938
END