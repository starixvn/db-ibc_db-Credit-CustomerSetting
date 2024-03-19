/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_ExecRep_Cust_04]
AS 
/*
Created: 20121126@Thien
Task : Update customer/custinfo settings
DB: DBCUST/CustDB

Revisions:
	- 20121126@Thien: implement the 'VirtualMultiplier' update
	- 20130709@Jamie: Apply Exec Rep for Update CLOSED, SUSPENDED and RNG Casino Status
	- 20130926@Kathy: Apply Exec Rep for Live Casino, Virtual sport status, Number Game, Bingo status
	- 20131011@Elodie: Add HR Fixed Odds [Redmine:#6505]
	- 20131024@Kathy: Apply Exec Rep for auto suspend soccer and other sports [Redmine:#5520]
	- 20140228@Bobby: Update Keno status [Redmine:#12474]
	- 20140320@Bobby: remove Keno disable
	- 20150610@Daniel: 
	    + Improve medthod check table existing in subscribers	
	    + Separate custDB to new server DBCUST 	
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
	- 20190905@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699] -- CLEAN CODE 
*/
RETURN
GO
