/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_06]
AS
/*
	Created: Kathy
    Date: 20131029
    Task : Update commission [Redmine:#3244]
    DB: DBCUST/CustDB
    Original: 
    Revisions:
        - 20131029@Kathy: Update NumberGame's commission for all level. Refer to:
            + Acc_CustomerUpdSuper_Commission
            + Acc_CustomerUpdMaster_Commission
            + Acc_CustomerUpdAgent_Commission
            + Acc_CustomerUpdMember_Commission
        - 20131030@Kathy: Apply exec rep for all level Horse Racing. Refer to:
            + Acc_CustomerUpdSuper_CommissionHR
            + Acc_CustomerUpdMaster_CommissionHR
            + Acc_CustomerUpdAgent_CommissionHR
            + Acc_CustomerUpdMember_CommissionHR
        - 20131031@Kathy: Apply exec rep for super, master, agent level Live Casino. Refer to:
            + Acc_CustomerUpdSuperLiveCS_Commission
            + Acc_CustomerUpdMasterLiveCS_Commission
            + Acc_CustomerUpdAgentLiveCS_Commission
        - 20131118@Kathy: Update live casino commission for super and all downlines. Refer to:
            + Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels                        
        - 20131122@Francis: Add checking for super Deposit Type
            + If super is Deposit, do not update commission on its downline members for LiveCasino
        - 20140227@Elodie: Add Keno sport [Redmine:#11658]
        - 20140729@Logan:   1.Exclude disabled agents while updating SM's setting [Redmine: #19631]
                            2.Code aligning on modified parts
		- 20141113@Johnson: Hardcode agent list not give commission for downlines 
						and add Keno, LiveCasino sport for member level [Redmine #25787]                                              
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST  
		- 20150616@Johnson: Add more hard customers not give commission [Redmine: #34798]	
		- 20150825@Helen: Colossus Bet - [Redmine: #41264]
		- 20151111@Helen: Add more hard customers not give commission [Redmine: #47068]
		- 20151222@Johnson: Add more customers not give commission [Redmine: #49494]
		- 20160125@Helen: Add more customers not give commission [Redmine: #51057]		
		- 20160608@Elodie: Add more customers not give commission [Redmine: #58999]	\
		- 20160909@Winnie: Not apply CustNoComm for 3rd product [Redmine: #63736]	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190829@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20221123@Elodie: Clean code [Redmine: #179711]

    Param's Explanation: 
        @mode: 
                - 'Numbergame': Number game
                - 'Keno': Keno
				- 'GoldDeluxe': Gold Deluxe
            
    */
BEGIN
    SET NOCOUNT ON;
	RETURN    	  
END
GO