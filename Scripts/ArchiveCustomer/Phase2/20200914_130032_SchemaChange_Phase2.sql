/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
/*
		Description: change schema and update data accordingly
		Create date: 20200911
		Original SP: 
		DB: DBCUST/CustDB
		
		Revisions:    
			- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
*/
USE CustDB
GO
sp_rename 'CustArc_NewActive.AgentID', 'CustID', 'COLUMN';

ALTER TABLE CustArc_NewActive
ADD Roleid INT

-- update roleid
UPDATE c
	SET RoleID = ci.roleid
FROM CustArc_NewActive c
	INNER JOIN dbo.custinfo ci WITH (NOLOCK) ON c.CustID = ci.custid

GO

