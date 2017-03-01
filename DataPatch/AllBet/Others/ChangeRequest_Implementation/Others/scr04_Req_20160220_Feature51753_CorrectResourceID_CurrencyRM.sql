/*
	Created: Helen
	Date: 20160922
	Task: Correct ResourceID of RM
	DB: DBCUST.CustDB
	
*/
USE CustDB
GO
UPDATE StakeLevel SET ResourceId = 135
WHERE ExchangeId = 2 AND GameTypeID = 2402 AND resourceid = 12