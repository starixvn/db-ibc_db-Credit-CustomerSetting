/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240628@Louisa
	 Task: enable syn data process [Redmine:#204370]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: enable syn data process [Redmine:#204370]
*/

USE bodb_CustHistory
GO

UPDATE Dest_ServiceTransform WITH(ROWLOCK, UPDLOCK)
SET StatusID = 1
WHERE StatusID = 0