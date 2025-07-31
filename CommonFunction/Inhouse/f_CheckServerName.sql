/*<info serverAlias="DBCust-CustDB,DBTP-bodb02,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION dbo.f_CheckServerName()
RETURNS BIT
AS
/*
	Created:	20241217@Johnson
	Database:	DBCust-CustDB,DBTP-bodb02,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB
	
	Revision:
		- 20241217@Johnson: check servername DBCUST for execrep sps [RedmineID: #212684]
		- 20250730@Tacy: Add DBSPARE1 [RedmineID: #234728]
		
	Param's Explanation:
	SELECT dbo.f_CheckEnvironment()
	Notes: 
		Any change on this function need to deploy all servers
*/
BEGIN
	RETURN CASE WHEN @@SERVERNAME NOT IN ('DBCUST','DBSPARE','DBSPARE1','SITDBCUST','TESTDBCUST','DB-60\DEVDBCUST') 
				THEN 0 ELSE 1 END
END