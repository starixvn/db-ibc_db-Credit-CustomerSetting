/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20200911@Helen
	Task: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO

-- New actionid for stage 2 when disable agent & master/super
INSERT INTO dbo.LogAction (ActionID,ActionTypeID,SPName,ActionNameEN,ActionNameCH,ActionNameCS,ActionNameJP,ActionNameTH,ActionNameKO,IsInternal,ActionNameVI)
VALUES 
	(1177,5, 'DBA_ArchiveAccount2_DisableMasterSuper'
		,'Disable Super/Master level to Archive by IT Admin'
		,'Disable Super/Master level to Archive by IT Admin'
		,'Disable Super/Master level to Archive by IT Admin'
		,'Disable Super/Master level to Archive by IT Admin'
		,'Disable Super/Master level to Archive by IT Admin'
		,'Disable Super/Master level to Archive by IT Admin'
		,0
		,'Disable Super/Master level to Archive by IT Admin'
		)
	,(1178,5, 'DBA_ArchiveAccount2_DisableAgentLine'
			,'Disable Agent to Archive by IT Admin'
			,'Disable Agent to Archive by IT Admin'
			,'Disable Agent to Archive by IT Admin'
			,'Disable Agent to Archive by IT Admin'
			,'Disable Agent to Archive by IT Admin'
			,'Disable Agent to Archive by IT Admin'
			,0
			,'Disable Agent to Archive by IT Admin'
			)
-- Re-use action 1503 & 1504 to clear balance for agent and master
UPDATE la
	SET SPName = 'DBA_ArchiveAccount3_ClearBalance_AgentMaster'
		, ActionNameEN = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameCH = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameCS = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameJP = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameTH = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameKO = N'Clear Agent Balance to archive account by IT Admin'
		, ActionNameVI = N'Clear Agent Balance to archive account by IT Admin'
FROM LogAction la
WHERE ActionID = 1503

UPDATE la
	SET SPName = 'DBA_ArchiveAccount3_ClearBalance_MasterSuper'
		, ActionNameEN = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameCH = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameCS = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameJP = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameTH = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameKO = N'Clear Master Balance to archive account by IT Admin'
		, ActionNameVI = N'Clear Master Balance to archive account by IT Admin'
FROM LogAction la
WHERE ActionID = 1504
