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

USE bodb02
go
sp_rename 'CustArc_NewActive.AgentID', 'CustID', 'COLUMN';
ALTER TABLE CustArc_NewActive
ADD Roleid INT

-- update roleid
UPDATE c
	SET RoleID = ci.roleid
FROM CustArc_NewActive c
	INNER JOIN Custdb.dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.custid

GO