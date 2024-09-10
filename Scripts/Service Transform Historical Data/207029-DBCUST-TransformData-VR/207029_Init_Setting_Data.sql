/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240812@Louisa
	 Task: init setting [Redmine:#207029]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

 
---CLEAN UP DATA ON SIT:

IF @@SERVERNAME = 'SITDBCUST'
BEGIN
	TRUNCATE TABLE VRCustLockStatus_History

	TRUNCATE TABLE CustVirtualSetting_History

END


INSERT INTO  Dest_ServiceTransform 
(	
	TableName, Interval
	, rID, BatchSize
	, SPSelect, SPInsert, StatusID ,SiteDBGroupID ,UpdateTime, GroupID
)	
VALUES('VRCustLockStatus'	, 1000, 0, 1000, 'ServiceTransform_VRCustLockStatus_Select'		, 'ServiceTransform_VRCustLockStatus_Insert'	, 0, 0, SYSDATETIME() ,3)
	 ,('CustVirtualSetting'	, 1000, 0, 1000, 'ServiceTransform_CustVirtualSetting_Select'	, 'ServiceTransform_CustVirtualSetting_Insert'	, 0, 0, SYSDATETIME() ,3)
	 
GO 
