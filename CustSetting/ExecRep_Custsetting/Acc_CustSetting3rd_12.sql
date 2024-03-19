/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_12]
AS
/*
	Created: Elodie
	Date: 20150108
	Task : Licensee Setting Configuration - Update PT [#6304]
	DB: DBCUST/CustDB
	Original:

	Revisions:
	     - 20150610@Daniel: 
	      + Improve medthod check table existing in subscribers	
	      + Separate custDB to new server DBCUST  	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
		- 20190924@Elodie: 3rd party products - Remove Inactive Products Phase 2 [Redmine: #118699]
		- 20211101@Winfred: Merge Sports Lottery under Sportsbook when turn on BA [redmine:#163191]
		- 20221123@Elodie: Clean code [Redmine: #179711]
	Param's Explanation:
		@Sporttype: 1 = Sportbook
					161 = Number Game
					202 = Keno
*/ 
BEGIN

	SET NOCOUNT ON
	
	RETURN
END
GO