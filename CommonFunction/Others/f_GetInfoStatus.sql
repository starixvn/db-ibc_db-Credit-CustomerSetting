/*<info serverAlias="DBCUST-custDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB,DBEXT-bodb02,DBTP-bodb02" executers="" viewers="" isFunction="1" isNested="0"></info>*/

CREATE FUNCTION dbo.f_GetInfoStatus(@StatusInfo TINYINT)
RETURNS TABLE
AS 
/*
	Created by:Tina
	Date:2021-05-06
	Task: get close info status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20210506@Tina: All Sites - Lock account & indirect close account [redmine: #148600]
	Parameter's Explanation:
*/
	RETURN(SELECT CASE WHEN @StatusInfo&power(2,3) > 0 THEN 1 ELSE 0 END AS SuperStatus,
				  CASE WHEN @StatusInfo&power(2,2) > 0 THEN 1 ELSE 0 END AS MasterStatus,
				  CASE WHEN @StatusInfo&power(2,1) > 0 THEN 1 ELSE 0 END AS AgentStatus,
				  CASE WHEN @StatusInfo&power(2,0) > 0 THEN 1 ELSE 0 END AS MemberStatus)
GO	