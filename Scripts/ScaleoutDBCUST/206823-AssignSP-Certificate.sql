/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240717@Helen
	 Task: Sign up SP with certificate [Redmine:#206823]
	 DB: DBGLOB-GLOBCUSTDB

	 Revision:
		- 20240717@Helen: Assign SPs with certificate [Redmine:#206823]
*/
USE GLOBCUSTDB
GO

ADD SIGNATURE TO Acc_CustomerIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO
ADD SIGNATURE TO Acc_CustomerIns_Rollback_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO
ADD SIGNATURE TO Age_CustSubIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO
ADD SIGNATURE TO Age_CustomerInsNickName_Register_UAT2  BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO
ADD SIGNATURE TO Age_CustomerInsNickName_Rollback_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO

/*
--- others: SP(s) of Eden

ADD SIGNATURE TO API_CustomerIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
GO
ADD SIGNATURE TO API_CustomerIns_Generate_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT WITH PASSWORD = 'Admin!@#passwordagain'
*/

