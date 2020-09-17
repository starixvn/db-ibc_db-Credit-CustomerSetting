/*<info serverAlias="DBTXN-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20200505@Helen
	Task: https://nexdev.net/issues/130032
	DB: DBTXN.custdb
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
