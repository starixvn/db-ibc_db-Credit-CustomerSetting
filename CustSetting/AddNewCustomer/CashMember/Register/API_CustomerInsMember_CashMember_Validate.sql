/*<info serverAlias="DBCUST-CUSTDB" executers="asv_CashService" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[API_CustomerInsMember_CashMember_Validate]
	@username		VARCHAR(30)
	,@Domain		VARCHAR(500)
	,@AgentId		INT		
	,@AgentName		VARCHAR(30) OUTPUT
	,@ErrCode		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(MAX) = '' OUTPUT	
	
AS
/*
	Created: 20250509@Elodie	
	Task: Validate when member register from member site
	DB: DBCUST.CustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 
		
	Parameter's Explanation:	
	
*/	
BEGIN
	SET NOCOUNT ON	

	EXEC [Acc_CheckUM] @CustID = @AgentId
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = 'EN'

	IF @ErrCode <> 0 RETURN	
	
	--Check an account disabled OR not 
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @AgentId, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output 
    IF @ErrCode <>0	
	RETURN

	DECLARE @ServiceType TINYINT = 0, @IsAllowRegister BIT = 0, @IsAllowDeposit BIT = 0, @CloseInfo TINYINT = 0, @SuspendInfo TINYINT = 0
	
	SELECT @AgentName = username 
	FROM customer WITH(NOLOCK)
	WHERE custid = @AgentId

	SELECT 
		@ServiceType = ServiceType, @CloseInfo = CloseInfo, @SuspendInfo = SuspendInfo
	FROM vw_CustInfoExtra WITH(NOLOCK) 
	WHERE custid = @AgentId

	IF @CloseInfo <> 0 
	BEGIN
		SELECT @ErrMsg = 'Your upline was closed.	', @ErrCode = 104
		RETURN
	END

	IF @SuspendInfo <> 0 
	BEGIN
		SELECT @ErrMsg = 'Your upline was suspended.	', @ErrCode = 105
		RETURN
	END
	
	IF @ServiceType = 0 
	BEGIN
		SELECT @ErrMsg = 'Your upline has not yet enabled the Cash Service. Kindly check with them for further assistance.', @ErrCode = 101
		RETURN
	END

	EXEC AgencyCashService.dbo.Age_CashService_AgentPermissionSel 
		@CustId = @AgentId		
		,@IsAllowRegister = @IsAllowRegister OUTPUT
		,@IsAllowDeposit = @IsAllowDeposit OUTPUT	

	IF @IsAllowRegister = 0 
	BEGIN
		SELECT @ErrMsg = 'Self-registration is disabled by your upline. Please contact them to enable it.', @ErrCode = 102
		RETURN
	END
	
	---- check domain is valid
	DECLARE @IsValidDomain BIT = 0
	EXEC AgencyCashService.dbo.Age_CashService_AgentDomainCheck @CustId = @AgentId, @Domain = @Domain, @IsValid = @IsValidDomain OUTPUT
	IF @IsValidDomain = 0 
	BEGIN
		SELECT @ErrMsg = 'The domain name is invalid.', @ErrCode = 103
		RETURN
	END

	EXEC Acc_CustomerLimitCreatedAccountCheck
			@Custid				= @AgentId , 
			@RuleID				= 'CashAG' , 
			@existingMrecommend = 0 , 
			@existingSrecommend = 0 , 
			@ServiceType 		= @ServiceType,
			@Prefix				= @AgentName , 
			@GroupName			= '' , 
			@IsQRCode			= 0 , 
			@SystemID			= 0 , 
			@Credit				= 0 ,
			@ErrCode			= @ErrCode OUTPUT , 
			@ErrMsg				= @ErrMsg OUTPUT 
			
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode , @ErrMsg
		RETURN		
	END					
END
GO
