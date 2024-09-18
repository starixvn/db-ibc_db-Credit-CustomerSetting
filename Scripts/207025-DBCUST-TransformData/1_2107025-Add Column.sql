/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240723@Louisa
	 Task: Add column [Redmine:#207025]
	 DB: DBTP-bodb_CustHistory
*/

USE bodb_CustHistory
GO

ALTER TABLE Dest_ServiceTransform ADD GroupID TINYINT
GO