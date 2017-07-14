/*
	Created: 20170714@Elodie
	Task : Initial data CashOut for 12Bet - Enable CashOut for new customer [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/
------------------------------------------------------
UPDATE 
INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
SELECT 14543986 AS CustID, 25, 1


