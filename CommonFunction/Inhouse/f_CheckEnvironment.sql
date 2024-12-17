/*<info serverAlias="DBCust-CustDB,DBTP-bodb02,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION dbo.f_CheckEnvironment()
RETURNS VARCHAR(10)
AS
/*
	Created:	20241217@Johnson
	Database:	DBCust-CustDB,DBTP-bodb02,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB
	
	Revision:
		- 20241217@Johnson: check env (Active/Standby) on KBT/DR KL for execrep sps [RedmineID: #212684]
		
	Param's Explanation:
	SELECT dbo.f_CheckEnvironment()
	Notes: 
		Any change on this function need to deploy all servers
*/
BEGIN
	RETURN 'Active' --'Standby'
END