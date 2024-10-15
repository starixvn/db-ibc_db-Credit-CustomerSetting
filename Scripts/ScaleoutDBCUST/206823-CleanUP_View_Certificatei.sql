/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="" viewers="" isFunction="0"></info>*/
/*
	 Created by: 20240717@Helen
	 Task: CLEAN UP [Redmine:#206823]
	 DB: DBGLOB-GLOBCUSTDB

	 Revision:
		- 20240916@Helen: CLEAN UP IN UM to release scaleout phase 1 [Redmine:#206823]
*/
USE GlobCustDB
GO

DROP SIGNATURE FROM OBJECT::dbo.Acc_CustomerIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Acc_CustomerIns_Rollback_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Age_CustomerInsNickName_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Age_CustomerInsNickName_Rollback_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Age_CustSubIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.API_CustomerIns_Generate_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.API_CustomerIns_Register_UAT2 BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Dot_Admin_CreateCustInfoMiniAccount_Test BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Dot_Member_CheckNickname_Cust_Mini_test BY CERTIFICATE cert_scaleout_dbcust_UAT
DROP SIGNATURE FROM OBJECT::dbo.Dot_Member_UpdateNickname_Cust_Mini_test BY CERTIFICATE cert_scaleout_dbcust_UAT

DROP VIEW CustinfoMini
GO
DROP VIEW CustSubMini
GO
DROP CERTIFICATE cert_scaleout_dbcust_UAT
GO
DROP SEQUENCE seq_CustinfoMini
GO
DROP SEQUENCE seq_CustSubMini
GO
USE [CustDB]
GO
DROP USER [user_cert_scaleout_dbcust_UAT]
GO