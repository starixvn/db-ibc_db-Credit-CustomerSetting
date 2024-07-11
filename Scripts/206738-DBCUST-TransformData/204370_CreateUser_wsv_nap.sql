/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/

/*
	 Created by: 20240628@Louisa
	 Task: mapping login with user on bodb_CustHistory [Redmine:#204370]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: mapping login with user on bodb_CustHistory [Redmine:#204370]
*/


USE [bodb_CustHistory]
GO
CREATE USER [wsv_nap] FOR LOGIN [wsv_nap]
GO
USE [bodb_CustHistory]
GO
ALTER USER [wsv_nap] WITH DEFAULT_SCHEMA=[dbo]
GO