/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
/*
	Created: 20200608@Max
	Task: [NAP CM] Archiving credit accounts process for Master & Agent levels - [Redmine: #130032]
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO

INSERT INTO dbo.LogAction (ActionID,SPName,ActionNameEN,ActionNameCH,ActionNameCS,ActionNameJP,ActionNameTH,ActionNameKO,IsInternal,ActionNameVI)
VALUES 
(1222,'Task_ArchiveAccount'
		,'Update Given Credit by Archiving Process'
		,'Update Given Credit by Archiving Process'
		,'Update Given Credit by Archiving Process'
		,'Update Given Credit by Archiving Process'
		,'Update Given Credit by Archiving Process'
		,'Update Given Credit by Archiving Process'
		,0
		,'Update Given Credit by Archiving Process'
		)


