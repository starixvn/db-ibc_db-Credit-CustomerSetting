/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240812@Louisa
	 Task: enable syn data process [Redmine:#207029]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240812@Louisa: enable syn data process [Redmine:#207029]
*/

USE bodb_CustHistory
GO

UPDATE Dest_ServiceTransform WITH(ROWLOCK, UPDLOCK)
SET StatusID = 1
WHERE StatusID = 0
	AND TableName IN ('VRCustLockStatus_History', 'CustVirtualSetting_History' )