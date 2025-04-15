/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_MAg_Validate]
(
	@Credit money
	,@MaxCredit money
	,@mrecommend int	
	,@ExistingCustid int
	,@Language varchar(2)= 'E'
	,@IP varchar(15)=''		
	,@ErrCode int = 0 output
	,@ErrMsg nvarchar(4000) = '' output
	,@SystemID TINYINT=1
)
AS
/*  
 Created by: Helen  
 Date:20240704
 Original: 
 Task: Add new agent from existing agent
 DB: DBCUST/CustDB  
  
 Revisions:  
	- 20240704@Helen: Revise code for scaleout dbcust - [Redmine:#206823]
	- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
 Explanation's Param:  
	- @ErrCode:
		= 0: Create agent successfully.
		> 0: Specific Error.
	  
	- @ErrMsg: Error description.	
*/
BEGIN
	SET NOCOUNT ON

	EXEC [Acc_CheckUM] @CustID = @ExistingCustid
		,@FunctionType = 2
		,@ErrCode = @ErrCode OUTPUT
		,@ErrMsg = @ErrMsg OUTPUT
		,@ReturnUMData = 0
		,@Language = @Language

	IF @ErrCode <> 0 RETURN

	IF @credit <0
	BEGIN
		SELECT  @ErrCode = 2
		SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Credits must be positive.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](70025,@Language)
							END
		RETURN
	END


	DECLARE @recommend int		
		,@CreditRM MONEY
	
	-- Check role and master of existing agent
	DECLARE @existingUsername varchar(30),@roleid tinyint, @existingMrecommend int, @Enabled BIT, @currency INT, @ExistingSrecommend INT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @existingMrecommend = ISNULL(mrecommend,0), @Enabled = ISNULL(Enabled, 0), @currency = currency, @ExistingSrecommend = srecommend
	FROM dbo.CustInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	IF ( NOT (@roleid = 2 AND @existingMrecommend = @mrecommend))
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user ' + '(' + @existingUsername + ')!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language) + ' (' + @existingUsername + ')!'
								END, 
						@ErrCode = 202
		return		

	END	

	IF @Enabled = 0
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'This account was disabled!' + ' (' + @existingUsername + ')'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60020,@Language) + ' (' + @existingUsername + ')'
								END, 
						@ErrCode = 203
		RETURN		
	END	
	
	-- New Code #190167
	DECLARE 
		@GroupName				VARCHAR(50),
		@IsQRCode				BIT,
		@Master_Username		VARCHAR(30)

	SELECT @Master_Username = Username
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @mrecommend

	EXEC Acc_CustomerLimitCreatedAccountCheck 
				@Custid				= @mrecommend , 
				@RuleID				= 'CMAG' , 
				@existingMrecommend = @existingMrecommend , 
				@existingSrecommend = 0 , 
				@Prefix				= @Master_Username , 
				@GroupName			= '' , 
				@IsQRCode			= 0 , 
				@SystemID			= 0 , 
				@IP					= @IP ,
				@Credit				= @Credit ,
				@ErrCode			= @ErrCode OUTPUT , 
				@ErrMsg				= @ErrMsg OUTPUT , 
				@Language			= @Language
		IF @ErrCode <> 0
		BEGIN
			SELECT @ErrCode , @ErrMsg
			RETURN		
		END	

	--CREDIT CHECK
	DECLARE @Credit_AllOtherDownline MONEY, @Credit_MAg MONEY
	
	SELECT @Credit_MAg = ISNULL(credit, 0)		
	FROM CustInfo as ci with (NOLOCK) 
	WHERE CustID = @mrecommend

	SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
	FROM custinfo WITH(NOLOCK) 
	WHERE MRecommend = @mrecommend 
		AND (RoleID = 2  --Masters
				OR (roleid = 1 AND recommend = -3) --master direct members
			)	

	IF @Credit_AllOtherDownline + @Credit >@Credit_MAg
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'You have exceeded your credit limit.'  
							ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language)
						END,
			@ErrCode = 101
		return
	END
	
	-- maxcredit 
	if (isnull(@maxcredit ,0) > @credit )
	BEGIN 
		Select @ErrMsg = case @Language
			WHEN 'E' THEN 'You have exceeded your credit limit.'  
			ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
		 end,  
	  @ErrCode = 102  
	 return  
	END 
		
	
END
GO