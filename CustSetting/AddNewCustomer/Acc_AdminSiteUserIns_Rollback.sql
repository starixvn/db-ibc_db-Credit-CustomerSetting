/*<info serverAlias="DBPRO-bodb02" executers="wsv_nap,Dot_Admin" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_AdminSiteUserIns_Rollback]
	@Custid	INT
AS
/*
	Created: 20250205@Virgil
	Task: Rollback AdminSiteUser for New accounts when failed 
	DB: DBPRO-bodb02
	
	Revisions:
		- 20250205@Virgil: rollback AdminSiteUser - [HotFix #217493]

	Parameter's Explanation:
		EXEC [dbo].[Acc_AdminSiteUserIns_Rollback] @Custid = XXX
*/	
BEGIN
	SET NOCOUNT ON

	DELETE dbo.AdminSiteUser WITH (ROWLOCK) WHERE custID = @custid

END
GO