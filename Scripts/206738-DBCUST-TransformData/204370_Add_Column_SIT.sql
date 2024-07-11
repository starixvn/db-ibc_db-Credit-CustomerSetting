/*<info serverAlias="DBHIS-bodb_CustHistory" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240628@Louisa
	 Task: init structure [Redmine:#204370]
	 DB: DBTP-bodb02
*/

---DEPLOY ON SIT Only 

USE bodb_CustHistory
GO

---- DROP TABLE IF EXISTS Dest_ServiceTransform
ALTER TABLE Dest_ServiceTransform ADD SiteDBGroupID	SMALLINT
GO
