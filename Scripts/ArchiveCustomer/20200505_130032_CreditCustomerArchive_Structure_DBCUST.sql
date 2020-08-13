/*
	Created: 20200505@Helen
	Task: https://nexdev.net/issues/130032
	DB: DBCUST.custdb
*/
USE CustDB
GO
CREATE TABLE [dbo].[tmpCustGroupLevelArchived]
(
	custid INT -- for super and master only
	, Roleid TINYINT
	, GroupLevelName VARCHAR(100)
	, StageID TINYINT
) ON [PRIMARY]

GO
