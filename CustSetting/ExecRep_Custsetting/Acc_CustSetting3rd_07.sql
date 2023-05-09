/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_07] 
AS
/*
    Created: Johnson
    Date: 2013-10-30
    Task: Apply execrep when corrects pt on members
    DB: DBCUST/CustDB
    Original versions: Acc_CustomerUpdSuper_AutoPositiontaking
                Acc_CustomerUpdMaster_MaxPositiontaking
                Acc_CustomerUpdAgent_MaxPositiontaking                    
                Acc_CustomerUpdMasterVS_MaxPositiontaking
                Acc_CustomerUpdAgentVS_MaxPositiontaking                                        
                Acc_CustomerUpdSuperLiveCS_Positiontaking    
                Acc_CustomerUpdMasterLiveCS_MaxPositiontaking    
                Acc_CustomerUpdAgentLiveCS_MaxPositionTaking
                Acc_CustomerUpdSuperHR_Positiontaking
                Acc_CustomerUpdMasterHR_MaxPositiontaking
                Acc_CustomerUpdAgentHR_MaxPositiontaking                    
    Revision:
        - 20131104@Johnson: Add virtual sports, live casino, racing
        - 20131203@Johnson: Update virtual-sport for agent by @sporttype not hard code in sp
        - 20140314@Elodie: Add Keno product [Redmine:#13326]
        - 20140818@Logan: Exclude disabled members while updating Super, Master setting [Redmine:#19631]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
	   - 20150610@Daniel: 
	      + Improve medthod check table existing in subscribers	
	      + Separate custDB to new server DBCUST  		
	   - 20150917@Johnson: check constraint n4 when update s4 [Redmine:#43808]     
	   - 20180125@Winnie: Hide inactive products [RedmineID: #86086]             
	   - 20190313@Johnson: enhance perf  [redmine:#109979]
	   - 20221123@Elodie: Clean code [Redmine: #179711]
    Parameter's Explanation:
*/ 
BEGIN
    SET NOCOUNT ON
 	RETURN   
END
GO



