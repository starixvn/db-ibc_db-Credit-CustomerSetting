/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_05]
AS
/*
    Created: Johnson
    Date: 2013-10-29
    Task: Apply execrep when UPDATE auto pt ON master , agent, member levels
    DB: DBCUST/custDB
    Original versions: Acc_CustomerUpdMaster_AutoPositiontaking
                Acc_CustomerUpdAgent_AutoPositiontaking                    
                Acc_CustomerUpdMasterVS_Positiontaking
                Acc_CustomerUpdAgentVS_PositionTaking
                Acc_CustomerUpdMasterLiveCS_Positiontaking
                Acc_CustomerUpdAgentLiveCS_PositionTaking
                Acc_CustomerUpdMasterHR_Positiontaking
                Acc_CustomerUpdAgentHR_PositionTaking
    Revision:
        - 20131104@Johnson: Add virtual sports, live casino, racing
        - 20140320@Patrick: Add more Keno product
        - 20140818@Logan: Exclude disabled members while updating Master setting [Redmine: #19631]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#34486]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST   		
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]
		- 20221123@Elodie: Clean code [Redmine: #179711]
    Parameter's Explanation:
*/
BEGIN
    SET NOCOUNT ON
	RETURN   

END

GO