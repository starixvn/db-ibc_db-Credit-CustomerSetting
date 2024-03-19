/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_10]
AS 
/*
Created: Daniel
Date: 20150605
Task : Update custinfo
DB: DBCUST/CustDB
Replication Info: Inlcude in exec rep from DBCUST.custDB -> DBTRANS.custDB & DB05x/DB06/DB04x/DBTP.bodb02
Original: Acc_CustomerInfo_Execrep_04


Revisions:
	- 20150605@Daniel: 
	  + Created, split update custinfo part in SP Acc_CustomerInfo_Execrep_04 into this SP for separate custDB to new server DBCUST
	  + Improve medthod check table existing in subscribers
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
	- 20190905@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699] -- CLEAN CODE  
*/
GO