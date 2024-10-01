/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,asv_cust" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerIns_Rollback]
(
	@SubAccID	INT = 0, -- for sub account
	@custid		INT
)
AS
/*
	Created: Helen
	Date: 2024-07-04
	Task: register username/nickname/custid for CREDIT
	DB: DBGLOB-GLOBCUSTDB
	
	Revisions:
		- 20240704@Helen: rollback username/nickname/custid for CREDIT/Deposit - [Redmine:#206823]
		- 20241001@Helen: release with new structure on GlobCustDB instead of using view on CUSTDB - [Redmine:#206823]

	Parameter's Explanation:
	
*/	
BEGIN
	SET NOCOUNT ON

	IF @SubAccID = 0 -- normal account
	BEGIN
		DELETE CustInfoMini WITH (ROWLOCK)
		
		OUTPUT DELETED.[CustID], SYSDATETIME()
		INTO CustInfoMini_Del_Inhouse ([CustID], [RepUpdateTime])
		
		WHERE custID = @custid
	END
	ELSE -- subaccount
	BEGIN
		DELETE CustSubMini WITH (ROWLOCK)
		
		OUTPUT DELETED.[subaccid],  SYSDATETIME()
		INTO CustSubMini_Del_Inhouse ([subaccid], [RepUpdateTime])
		
		WHERE subaccid = @SubAccID AND custid = @custid
	END

END
GO



