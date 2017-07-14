/*
	Created: 20170714@Elodie
	Task : Enable CashOut for 12BETINH0151487 customer [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/
------------------------------------------------------
UPDATE Dep_CustProductSetting WITH (ROWLOCK,UPDLOCK)
SET IsEnabled = 1
WHERE custid = 14543986 AND ProductID = 25


