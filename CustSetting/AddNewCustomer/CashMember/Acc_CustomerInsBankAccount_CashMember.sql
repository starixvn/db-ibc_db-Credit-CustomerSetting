/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_nap" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsBankAccount_CashMember]
(
	@custid INT OUTPUT,	
	@BankId	INT = NULL,
	@AccountNumber VARCHAR(50) = NULL,	
	@Language VARCHAR(2)= 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
	)
AS

/*
	Created: 20250424@Elodie
	Task: Agent create cash member - Insert bank account [#223896]
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
		
	Parameter's Explanation:
	
*/	
BEGIN
    SET NOCOUNT ON 
	
	BEGIN TRY
		
		INSERT INTO CashMemberBankAccount(custid, BankId, AccountNumber, RepUpdateTime)
		SELECT @custid, @BankId, @AccountNumber, [dbo].[f_GetDateTime2]()
					
	END TRY
	BEGIN CATCH		
		SELECT @ErrMsg = CASE @Language
							WHEN 'E' THEN 'Create customer failed. Please try again.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40004,@Language)
							END,
				@ErrCode = 200
		RETURN
    END CATCH
END
GO