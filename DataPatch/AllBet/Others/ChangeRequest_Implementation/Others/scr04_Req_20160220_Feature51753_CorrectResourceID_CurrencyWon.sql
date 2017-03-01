/*
	Created: Helen
	Date: 20160922
	Task: Correct ResourceID of WON
	DB: DBCUST.CustDB
	
*/
USE CustDB
GO
-- WON
UPDATE StakeLevel SET resourceid = 136
WHERE GameTypeID = 2402 and exchangeid = 45 and resourceid = 42