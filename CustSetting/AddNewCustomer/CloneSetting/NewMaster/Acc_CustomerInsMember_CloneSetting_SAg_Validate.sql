/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CloneSetting_SAg_Validate]
(
	@Credit MONEY	
	,@srecommend INT	
	,@ExistingCustid INT
	,@Language VARCHAR(2)= 'E'
	,@IP VARCHAR(15)= ''		
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
	,@SystemID TINYINT=1
)
AS
/*  
 Created by: Helen  
 Date:20240704
 Original: 
 Task: Add new master from existing master
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

	DECLARE @mrecommend INT
		,@CreditRM MONEY
		 
	-- Check role and master of existing agent
	DECLARE @existingUsername VARCHAR(30),@roleid tinyint, @existingSrecommend INT, @Enabled BIT, @site NVARCHAR(50), @currency INT
	
	SELECT @existingUsername =  ISNULL(username,''), @roleid = ISNULL(roleid,0), @existingSrecommend = ISNULL(srecommend,0), @Enabled = ISNULL(Enabled, 0), @currency = currency
	FROM dbo.custInfo WITH(NOLOCK) 
	WHERE custid = @ExistingCustid
	
	SET @site = (SELECT Site FROM dbo.Customer WITH (NOLOCK) WHERE custid = @ExistingCustid)
		
	IF ( NOT (@roleid = 3 AND @existingSrecommend = @srecommend))
	BEGIN		
		 SELECT @ErrMsg = CASE @Language 
								WHEN 'E' THEN 'Invalid user' + ' (' + @existingUsername + ')!'
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
		@Super_Username			VARCHAR(30)

	SELECT @Super_Username = Username
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @srecommend

	EXEC Acc_CustomerLimitCreatedAccountCheck 
				@Custid				= @srecommend , 
				@RuleID				= 'CSAG' , 
				@existingMrecommend = 0 , 
				@existingSrecommend = @existingSrecommend , 
				@Prefix				= @Super_Username , 
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

	DECLARE @Credit_AllOtherDownline MONEY, @Credit_SAg MONEY
	SELECT @Credit_AllOtherDownline = ISNULL(sum(Credit), 0) 
	FROM custinfo WITH(NOLOCK) 
	WHERE SRecommend = @srecommend 
		AND (RoleID = 3  --Masters
				OR (roleid = 1 AND recommend = -4) --Super direct members
			)
  
	SELECT @Credit_SAg = ISNULL(credit, 0)		
	FROM CustInfo as ci with (NOLOCK) 
	WHERE CustID = @srecommend

	IF @Credit_AllOtherDownline + @Credit > @Credit_SAg
	BEGIN  
		SET @ErrMsg = CASE @Language   
		  WHEN 'E' THEN 'You have exceeded your credit limit.'  
		  ELSE [dbo].[f_Get_MsgNamebyMsgID](70010,@Language) 
		 END   
		SELECT @ErrCode = 101  
		RETURN  
	END  

END
GO