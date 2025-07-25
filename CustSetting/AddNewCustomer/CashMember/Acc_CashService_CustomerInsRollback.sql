/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_nap,wsv_CashService" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CashService_CustomerInsRollback]
	@CustID INT,
	@RoleID TINYINT = 1
AS
/*
	Created: 20250424@Elodie
	Task : Rollback Credit Customer Setting for New accounts when failed 
	DB: DBCUST/AgencyCashService
	Original:

	Revisions:		
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
	Param's Explanation:

	Examples:
		EXEC Acc_CashService_CustomerInsRollback @CustID = xxx 
*/
BEGIN		
	SET NOCOUNT ON	
	IF @RoleID = 1
	BEGIN
		DELETE dbo.CashMemberBankAccount WITH(ROWLOCK)
		WHERE custid = @custid	
		
		/*
		DELETE dbo.CashMemberBankAccount WITH(ROWLOCK)
		OUTPUT DELETED.BankAccountMemberID, dbo.f_GetDateTime2()
		INTO dbo.CashMemberBankAccount_Del_Inhouse(BankAccountMemberID,RepUpdateTime)
		WHERE custid = @custid
		*/
	END
END
GO
