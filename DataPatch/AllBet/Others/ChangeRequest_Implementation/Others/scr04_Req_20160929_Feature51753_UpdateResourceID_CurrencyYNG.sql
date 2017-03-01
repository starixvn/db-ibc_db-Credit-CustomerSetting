
/*
	Created By: Helen
	Created Date: 20160929
	Task: Update resourceid - https://nexdev.net/issues/64912
	
	DB: DBCUST/CustDB
*/
USE CustDB
GO

UPDATE T
	SET ResourceId = 149
FROM StakeLevel T
WHERE T.ExchangeId = 72 AND T.GameTypeID = 2401

GO

UPDATE T
	SET ResourceId = 150
FROM StakeLevel T
WHERE T.ExchangeId = 72 AND T.GameTypeID = 2402
