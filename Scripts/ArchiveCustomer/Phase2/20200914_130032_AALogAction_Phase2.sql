/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20200911@Helen
	Task: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO
INSERT INTO dbo.LogAction (ActionID,ActionTypeID,SPName,ActionNameEN,ActionNameCH,ActionNameCS,ActionNameJP,ActionNameTH,ActionNameKO,IsInternal,ActionNameVI)
VALUES 
(1175,5, 'DBA_ArchiveAccount1_CloseMaster'
		,'Close Master to Archive by IT Admin'
		,'Close Master to Archive by IT Admin'
		,'Close Master to Archive by IT Admin'
		,'Close Master to Archive by IT Admin'
		,'Close Master to Archive by IT Admin'
		,'Close Master to Archive by IT Admin'
		,0
		,'Close Master to Archive by IT Admin'
		)
,(1176,5, 'DBA_ArchiveAccount1_CloseSuper'
		,'Close Super to Archive by IT Admin'
		,'Close Super to Archive by IT Admin'
		,'Close Super to Archive by IT Admin'
		,'Close Super to Archive by IT Admin'
		,'Close Super to Archive by IT Admin'
		,'Close Super to Archive by IT Admin'
		,0
		,'Close Super to Archive by IT Admin'
		)
--,(1177,5, 'DBA_ArchiveAccount2_DisableMasterSuper'
--		,'Disable Account to Archive by IT Admin'
--		,'Disable Account to Archive by IT Admin'
--		,'Disable Account to Archive by IT Admin'
--		,'Disable Account to Archive by IT Admin'
--		,'Disable Account to Archive by IT Admin'
--		,'Disable Account to Archive by IT Admin'
--		,0
--		,'Disable Account to Archive by IT Admin'
--		)




