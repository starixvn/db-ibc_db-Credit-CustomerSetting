/*
	Created: Helen
	Date: 20160922
	Task: Correct ResourceID of RM
	DB: DBCUST.CustDB
	
*/
USE CustDB
GO
-- TB, THB
UPDATE StakeLevel SET ResourceId = 28
WHERE ExchangeId IN (4,43) AND GameTypeID = 2402

-- INH
UPDATE StakeLevel SET ResourceId = 13
WHERE ExchangeId IN (51) AND GameTypeID = 2402