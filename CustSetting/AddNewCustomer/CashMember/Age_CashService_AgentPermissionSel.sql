/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_CashService, asv_CashService" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Age_CashService_AgentPermissionSel]
(
	@CustId INT,
	@IsAllowRegister BIT = 0 OUTPUT,
	@IsAllowDeposit	BIT = 0 OUTPUT
)
AS
/*
	Created: 20250424@Elodie
	Task: Get setting cash service of agent [#223896]
	DB: DBCUST.AgencyCashService
	
	Revisions:
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
		
	Parameter's Explanation:
	
*/	
BEGIN
    SET NOCOUNT ON 	
	SELECT @IsAllowRegister = v.BitValue
	FROM CashAgentManagement WITH (NOLOCK)
		CROSS APPLY (SELECT BitValue FROM f_GetValueBitmap(1, SettingInfo)) v
	WHERE AgentId = @CustId

	SELECT @IsAllowDeposit = v.BitValue
	FROM CashAgentManagement WITH (NOLOCK)
		CROSS APPLY (SELECT BitValue FROM f_GetValueBitmap(2, SettingInfo)) v
	WHERE AgentId = @CustId
END
GO