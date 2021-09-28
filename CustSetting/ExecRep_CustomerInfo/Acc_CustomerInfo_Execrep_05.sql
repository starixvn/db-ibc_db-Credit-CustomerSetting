/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_05]   
AS  

/*  
	Created: 20150613@Daniel
	Task: enable/disable number game for whole line - custinfo only
	DB: DBCUST/CustDB

	Revisions:	
 	- 20150613@Daniel: 
 	    + Created, split update custinfo part in SP Acc_CustSetting3rd_02 into this SP for separate custDB to new server DBCUST
	    + Improve medthod check table existing in subscribers		
	- 20210802@Eden: Max Payout Per Match - Clean unused SP [redmine: #158073]  
 
	Param's Explanation:
 
*/ 	
GO