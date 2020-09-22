/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperGoldDeluxe_All]
    @custid								INT,        
    
    @v255spositiontaking_1701			SMALLMONEY,
    @v255spositiontaking_1701_min		SMALLMONEY,
    @v255discount_1701					SMALLMONEY,
    
    @v255UpdatePositiontaking_1701		BIT				= 1,
    @v255UpdateMinPositiontaking_1701	BIT				= 1,
    @v255UpdateCommission_1701			BIT				= 1,
    
    @IP									VARCHAR(50)		= '',    
    @UserID								INT				= 0,
    @Language							VARCHAR(20)		= 'E',        
    @ErrCode							VARCHAR(300)	= ''	OUTPUT,
    @ErrMsg								NVARCHAR(4000)	= ''	OUTPUT
    
AS
    /*
        Created: Kathy
        Date: 20150423
        Task: Company updates live casino setting on super
        DB: DBTXN/BODB02
        
        Revisions:
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]    
			- 20200722@Eden: Minimize UM Time - Lock updating customer settings [#136464]
        Parameters Explanation:
    */
BEGIN
	SET NOCOUNT ON 

	DECLARE @roleid		TINYINT
			,@ErrCode_Cur	INT
			,@ErrMsg_Cur	NVARCHAR(4000)
			,@ErrAcc		NVARCHAR(4000)
		
	SELECT	@ErrCode_Cur = 0
			,@ErrMsg_Cur = ''
			,@ErrCode = ''
			,@ErrMsg = ''

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 12
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN
	
	SET @ErrCode = ''
	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid, 
		@Custid			= @custid,
		@roleid			= @roleid	OUTPUT
		
	IF (@roleid = 0) 
		RETURN
	---------------------------

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	--Check disable user
	EXEC Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode_Cur	OUTPUT
		,@ErrMsg	= @ErrMsg_Cur	OUTPUT
		
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT	@ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7)
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
		RETURN
	END
	--end


	--check n4<=s4
	IF @v255spositiontaking_1701 < @v255spositiontaking_1701_min
	BEGIN 
		SELECT @ErrMsg = 
					CASE @Language 
							WHEN 'E' THEN 'Wrong position taking .<br>'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](20001,@Language) + '<br>'
					END, @ErrCode = 100
		RETURN    
	END

	IF @v255UpdateCommission_1701 = 1
	BEGIN        
		EXEC Acc_CustomerUpdSuperGoldDeluxe_Commission 
			@custid				= @custid
			,@v255discount_1701 = @v255discount_1701
			,@IP				= @IP 
			,@UserID			= @userid
			,@Language			= @Language
			,@ErrCode			= @ErrCode_Cur OUTPUT
			,@ErrMsg			= @ErrMsg_Cur OUTPUT
	    
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT	@ErrCode	= @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
					@ErrMsg		= @ErrMsg + @ErrMsg_Cur + CHAR(7)
			RETURN    
		END
		ELSE
			SELECT @ErrCode		= @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)        
	END


	IF @v255UpdatePositiontaking_1701 = 1
	BEGIN
		EXEC Acc_CustomerUpdSuperGoldDeluxe_Positiontaking 
			@custid						= @custid
			,@v255spositiontaking_1701	= @v255spositiontaking_1701
			,@IP						= @IP 
			,@UserID					= @userid
			,@Language					= @Language
			,@ErrCode					= @ErrCode_Cur	OUTPUT
			,@ErrMsg					= @ErrMsg_Cur	OUTPUT
	    
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
				
			RETURN    
		END
		ELSE
			SELECT	@ErrCode = @ErrCode + '-103' + CHAR(7)
					,@ErrMsg = @ErrMsg + CHAR(7)        
	END


	IF @v255UpdateMinPositiontaking_1701 = 1
	BEGIN
		EXEC Acc_CustOverrideUpdGoldDeluxe 
			@custid							= @custid
			,@min_v255positiontaking_1701	= @v255spositiontaking_1701_min
			,@IP							= @IP 
			,@UserID						= @userid
			,@Language						= @Language
			,@ErrCode						= @ErrCode_Cur OUTPUT
			,@ErrMsg						= @ErrMsg_Cur OUTPUT
	    
		IF @ErrCode_Cur <> 0
		BEGIN
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7)
					,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
					
			RETURN    
		END
		ELSE
			SELECT	@ErrCode = @ErrCode + '-102' + CHAR(7)
					,@ErrMsg = @ErrMsg + CHAR(7)        
	END

END
GO

