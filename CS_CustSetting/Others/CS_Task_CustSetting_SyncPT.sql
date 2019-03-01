/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/

CREATE PROCEDURE CS_Task_CustSetting_SyncPT	
AS
/*
	Created: 20181212@Elodie
	Task : Sync PT
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
			
*/

BEGIN
	SET NOCOUNT ON
	
	UPDATE cs
	SET cs.MinPT2 = cs.MinPT,
		cs.MaxPT2 = cs.MaxPT,
		cs.SuperPT2 = cs.SuperPT,
		cs.MasterPT2 = cs.MasterPT,
		cs.AgentPT2 = cs.AgentPT		
	FROM dbo.CS_CustPTSetting_Agent cs WITH (ROWLOCK)
	WHERE cs.MinPT <> cs.MinPT2
		OR cs.MaxPT <> cs.MaxPT2
		OR cs.SuperPT <> cs.SuperPT2
		OR cs.MasterPT <> cs.MasterPT2
		OR cs.AgentPT <> cs.AgentPT2

	UPDATE cs
	SET cs.SuperPT2 = cs.SuperPT,
		cs.MasterPT2 = cs.MasterPT,
		cs.AgentPT2 = cs.AgentPT		
	FROM dbo.CS_CustPTGroupSetting_Member cs WITH (ROWLOCK)
	WHERE cs.SuperPT <> cs.SuperPT2
		OR cs.MasterPT <> cs.MasterPT2
		OR cs.AgentPT <> cs.AgentPT2
END
GO
