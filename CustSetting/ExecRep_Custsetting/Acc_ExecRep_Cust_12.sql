/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [Acc_ExecRep_Cust_12]  
AS  
/*  

Created: Daniel  
Date: 2012-09-19  
Task: exec replicate to update status and bet setting virtual sports for downlines  
DB: DBCUST/CustDB  

Revisions:  
	- 20121203@Scott : update status and bet setting for virtual tennis by setting's virtual soccer  
	- 20121211@Scott : don't update status virtual sport
	- 20120221@Johnson: add virtual horse racing setting (sporttype :181)
	- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)	
	- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]					
 	- 20150613@Daniel: 
 	    + Created, split update custinfo part in SP Acc_CustSetting3rd_03 into this SP for separate custDB to new server DBCUST
	    + Improve medthod check table existing in subscribers	
	- 20190905@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699] -- CLEAN CODE 
	
Parameter's Explanation:  

*/
GO