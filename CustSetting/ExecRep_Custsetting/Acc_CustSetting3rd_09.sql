/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_09]
 AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update auto pt on member
		DB: DBCUST/bodb02
		Original versions:	Acc_CustomerUpdMember_Super
				Acc_CustomerUpdMember_Master
				Acc_CustomerUpdMemberHR_SAg
				Acc_CustomerUpdMemberHR_MAg
				
		Revision:
			- 20131104@Johnson: Add racing
			- 20140220@Johnson: Merge code correct pt on members after update auto pt for number game[RedmineID: #11562]
			- 20140313@Johnson: Merge code correct pt on members after update auto pt for racing [RedmineID: #11562]
			- 20140424@Johnson: fix bug number game correct super pt on member after master update auto pt on member
			- 20150610@Daniel: 
		       + Improve medthod check table existing in subscribers	
		       + Separate custDB to new server DBCUST  	
			- 20180125@Winnie: Hide inactive products [RedmineID: #86086] 
			- 20221123@Elodie: Clean code [Redmine: #179711]
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON 
	RETURN
END
GO