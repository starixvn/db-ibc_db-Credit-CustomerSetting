/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Custsetting3rd_08]	
AS
	/*
		Created: Johnson
		Date: 2013-10-30
		Task: Apply execrep update pt on member
		DB: DBCUST/bodb02
		Original versions: Acc_CustomerUpdMember_Super
					Acc_CustomerUpdMember_Master
					Acc_CustomerUpdMember_PositionTaking
					Acc_CustomerUpdMemberHR_SAg
					Acc_CustomerUpdMemberHR_MAg
					Acc_CustomerUpdMemberHR_PositionTaking
					
		Revision:
			- 20131104@Johnson: Add live casino, racing
			- 20140221@Johnson: merge code correct pt after update pt on member for number game [RedmineId: #11562]
			- 20140313@Johnson: merge code correct pt after update pt on member for racing
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