/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_CashService " isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE dbo.Acc_CustomerSelBankAccount_CashMember
	@CustID INT
AS 
/*  
	Created By: Helios
	Created Date: 2025-04-18
	Description: Agency Cash Service - Get Member Bank Account for General Info [Redmine #223896] 
	DB: DBCust.AgencyCashService
	
	Revisions:
		- 20250623@Helios: Offer CashService - Get Bank Account Member [RedmineID: #231204]
	
	Sample:
		EXEC Acc_CustomerSelBankAccount_CashMember @CustID = 1986752
*/  
BEGIN 
	SET NOCOUNT ON;

	SELECT 
		mb.BankAccountMemberID      AS MemberBankAccountID,
		mb.AccountNumber            AS MemberBankAccountNumber,
		mb.BankId                   AS MemberBankID,
		mbk.BankCode                AS MemberBankCode,
		ISNULL(ag.AgentBankAccountID , 0)       AS AgentBankAccountID,
		ISNULL(ag.BankAccountNumber , '')        AS AgentBankAccountNumber,
		ISNULL(ag.BankID , 0)                   AS AgentBankID,
		ISNULL(agbk.BankCode , '')               AS AgentBankCode,
		CASE 
			  WHEN ag.AgentBankAccountID IS NULL THEN NULL
			  WHEN ag.IsActive = 1 
				 AND BankAccountStatus = 1 
				 AND (
					',' + ag.TransTypeList + ',' LIKE '%,1,%'
				   OR ',' + ag.TransTypeList + ',' LIKE '%,2,%'
				 )
			  THEN 1
			  ELSE 0
		END                        AS AgentBankAccountStatus
	FROM CashMemberBankAccount mb WITH (NOLOCK)
	INNER JOIN CashBankList mbk WITH(NOLOCK) ON mb.BankID = mbk.BankID
	LEFT JOIN CashAgentBankAccount ag WITH (NOLOCK) ON mb.BankAccountAgentID = ag.AgentBankAccountID
	LEFT JOIN CashBankList agbk WITH (NOLOCK) ON ag.BankID = agbk.BankID
	WHERE mb.IsActive = 1
	AND mb.CustId = @CustID
	ORDER BY mb.BankAccountMemberID ASC
END

GO