/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_10]
	@custid int,
	@roleid tinyint,
	@action varchar(30) = '',
	@EnableVirtualrate BIT = 0,
	@Suspended	BIT =0,
	@Closed		BIT =0,
	@disabledCS BIT =0,	
	@DisableVS BIT = 0,
	@EnableVS BIT = 0,
	@DisableNumberGame BIT = 0,
	@DisableGoldDeluxe BIT = 0,	
	@AutoSuspendSoccer BIT = 0,
	@AutoSuspendOtherSports BIT = 0
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
	- 20190905@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]

Param's Explanation:
	@Action: 
		+ 'Suspended': Suspended/Reject		[@Suspended]
		+ 'Closed': Closed					[@Closed]
		+ 'disabledCS': RNG Casino Status	[@disabledCS]
		+ 'DisableLiveCasino': Live Casino status [@DisableLiveCasino]
		+ 'DisableVS': Disable Virtual Sport [@DisableVS]
		+ 'EnableVS': Enable Virtual Sport [@EnableVS]
		+ 'DisableNumberGame': Number game status [@DisableNumberGame]
		
		+ 'AutoSuspend': Auto suspend all: Soccer and Other Sports [@AutoSuspendSoccer, @AutoSuspendOtherSports]
		+ 'AutoSuspendSoccer': Auto suspend for Soccer[@AutoSuspendSoccer]
		+ 'AutoSuspendOther': Auto suspend for Other Sports [@AutoSuspendOtherSports]
		+ 'UpdKeno-Hide' : Hide Keno gaming
   
*/
GO