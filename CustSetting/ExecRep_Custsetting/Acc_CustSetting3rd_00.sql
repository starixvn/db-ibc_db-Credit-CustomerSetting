/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_00] 
AS
/*
	Created: 20131113@Johnson
	Task : Correct PT after SMA update pt on member
	DB: DBCUST/CustDB
	Original: Acc_CustomerUpdMemberHR_MinPositiontaking, 
			Acc_CustomerUpdMember_MinPositiontaking, 
			Acc_CustomerUpdMemberFI_MinPositiontaking

	Revisions:
		- 20140314@Elodie: Add Keno product [Redmine:#13326]
		- 20150424@Kathy: Add Gold Deluxe product [Redmine:#34486]
		- 20150610@Daniel: 
			+ Improve medthod check table existing in subscribers	
			+ Separate custDB to new server DBCUST
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]
		- 20221123@Elodie: Clean code [Redmine: #179711]
	Param's Explanation:
		• @mode:
			= 'number': Number Game
		• @ErrCode:
			= 0: Update successfully.
			> 0: Specific Error.
  
		• @ErrMsg: Error description.
*/
SET NOCOUNT ON

RETURN
GO