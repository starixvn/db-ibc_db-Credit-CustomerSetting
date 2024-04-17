/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_04] 
 AS
    /*
        Created: Johnson
        Date: 2013-10-29
        Task: Apply execrep WHEN UPDATE min/max pt ON master AND agent
        DB: DBCUST/CustDB
        Original versions: Acc_CustomerUpdMaster_MinMaxPositiontaking
                Acc_CustomerUpdAgent_MinMaxPositiontaking
    
        Revision:
            - 20131029@Lukas: add racing product
            - 20131030@Elodie: add virtual sports
            - 20131030@Lukas: add Live casino product
            - 20131112@Johnson: merge code sp Acc_CustSetting3rd_00 into Acc_CustSetting3rd_04 for super level
            - 20131203@Johnson: UPDATE virtual-sport for super by @sporttype not hard code IN sp
            - 20140227@Elodie: Add Keno sport [Redmine:#11658]
            - 20140729@Logan: 1.Exclude disabled agents, members while updating SM's setting [Redmine: #19631]
                              2.Code aligning ON modified parts
			- 20150424@Kathy: Add Gold Deluxe product [Redmine:#34486]      
			- 20150610@Daniel: 
			  + Improve medthod check table existing in subscribers	
			  + Separate custDB to new server DBCUST   
			- 20151009@Elodie: Hot fix a1 is not updated to n2 when super edit master min pt [Redmine:#45332]  
			- 20170601@Elodie: Migrate Inspired VS to DCS structure [Redmine: #77274]
			- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
			- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]
			- 20200729@Johnson: hot fix Number Game wrong bettype [redmine:#138441]
			- 20221031@Eden: Optimize executed plan of sp getting customer's pt [redmine:#174131]
			- 20221123@Elodie: Clean code [Redmine: #179711]

        Parameter's Explanation:        
    */ 
BEGIN
    SET NOCOUNT ON 

	RETURN
END