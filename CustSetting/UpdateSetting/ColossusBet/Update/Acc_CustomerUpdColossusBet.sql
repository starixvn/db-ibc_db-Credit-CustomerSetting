
ALTER PROCEDURE [dbo].[Acc_CustomerUpdColossusBet]
(    
    @custid        INT,          
    
    -- Update Flags 
    @IsUpdateCommission BIT = NULL,
    @IsUpdateCashInShare BIT = NULL,
    @IsUpdateDisable BIT = NULL,
        
    -- updated Value for Commission & Cash In Share
    @v204Commission_18001 DECIMAL(9,8) = NULL,  
    @v204CashInShare_18002 DECIMAL(9,8)= NULL,  
    @EnableDownlines BIT = 0,
	@Disable BIT = NULL,
	@SubAccID	INT = 0, 
    @IP         VARCHAR(50)  = '',      
    @UserID        INT    = 0,  
    @Language       VARCHAR(20)  = 'E',          
    
    @ErrCode       VARCHAR(300) = '' OUTPUT,  
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT  
      
)
AS  
/*  
    Created: Helen  
    Date: 20150821
    Task: Updating Colossus Bet Module: Disable/Commission/Cash In Share (Redmine: #41264)
    DB: DBCUST / CustDB
    
    
	Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]			            
	Parameters Explanation
	
*/ 
BEGIN  
	SET NOCOUNT ON   

	DECLARE @roleid  TINYINT  
		,@ErrCode_Cur INT  
		,@ErrMsg_Cur NVARCHAR(4000)  
		,@ErrAcc  NVARCHAR(4000)  

	SELECT @ErrCode_Cur = 0  
		,@ErrMsg_Cur = ''  
		,@ErrCode = ''  
		,@ErrMsg = ''  

	---------------------------  
	-- ***Check Downline Belonging***  
	EXEC Age_CustomerSelCheckBelongingByCustID   
		@SessionCustID = @Userid,   
		@Custid   = @custid,  
		@roleid   = @roleid OUTPUT  

	IF (@roleid = 0)   
		RETURN  
	
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103
		RETURN
	END
	
	--Check disable user  
	EXEC Acc_CustomerSelCheckEnable   
		@custid  = @custid  
		,@ErrCode = @ErrCode_Cur OUTPUT  
		,@ErrMsg = @ErrMsg_Cur OUTPUT  

	IF @ErrCode_Cur > 0  
	BEGIN  
		SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_cur AS VARCHAR(300)) + CHAR(7)  
				,@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
	  
		RETURN  
	END  

	-- Find parent
	DECLARE @ParentCustID INT = NULL
	
	IF @roleid <> 4
	BEGIN
		SELECT @ParentCustID = CASE 
									WHEN @roleid = 2 THEN mrecommend
									WHEN @roleid = 3 THEN srecommend
								END	
		FROM custInfo WITH (NOLOCK)
		WHERE custid = @custid
	END 	
	
	-- Reset discount value in case its value > upline
	IF @ParentCustID IS NOT NULL
	BEGIN
		-- Commission
		SELECT @v204Commission_18001 = CASE 
											WHEN @v204Commission_18001 > commRate THEN commRate
											ELSE @v204Commission_18001   
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @ParentCustID   
			AND sporttype = 204   
			AND bettype = 18001  
		
		-- Cash In Share
		SELECT @v204CashInShare_18002 = CASE 
											WHEN @v204CashInShare_18002 > commRate THEN commRate
											ELSE @v204CashInShare_18002   
										END  
		FROM AgentCommRate WITH(NOLOCK)  
		WHERE custid = @ParentCustID   
			AND sporttype = 204   
			AND bettype = 18002  	
		
	
	END
	-- Update Comission Processing
	DECLARE @ActionID_Commission INT
	
	IF @IsUpdateCommission = 1  
	BEGIN 
		IF @roleid = 4
			SET @ActionID_Commission = 242
		ELSE IF @roleid = 3 
			SET @ActionID_Commission = 243
		ELSE IF @roleid = 2
			SET @ActionID_Commission = 244
			
		EXEC Acc_CustomerUpdColossusBet_Commission  
			@custid    = @custid  
			,@roleid = @roleid
			,@DiscountValue = @v204Commission_18001
			,@DiscountType =  18001
			,@ActionID = @ActionID_Commission
			,@IP    = @IP 
			,@UserID   = @userid 
			,@SubAccID = @SubAccID 
			,@Language   = @Language  
			,@ErrCode   = @ErrCode_Cur OUTPUT  
			,@ErrMsg   = @ErrMsg_Cur OUTPUT  
	   
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		END  
		ELSE  
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)          
	END  

	-- Update Cash In Share Processing 
	DECLARE @ActionID_CashInShare INT
	IF @IsUpdateCashInShare = 1  
	BEGIN
		IF @roleid = 4
			SET @ActionID_CashInShare = 245
		ELSE IF @roleid = 3 
			SET @ActionID_CashInShare = 246
		ELSE IF @roleid = 2
			SET @ActionID_CashInShare = 247
		
		EXEC Acc_CustomerUpdColossusBet_Commission  
			@custid    = @custid  
			,@DiscountValue = @v204CashInShare_18002
			,@DiscountType =  18002
			,@roleid = @roleid
			,@ActionID = @ActionID_CashInShare
			,@IP    = @IP 
			,@UserID   = @userid  
			,@SubAccID =  @SubAccID 
			,@Language   = @Language  
			,@ErrCode   = @ErrCode_Cur OUTPUT  
			,@ErrMsg   = @ErrMsg_Cur OUTPUT  
		   
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT  @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
			
		END  
		ELSE  
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)          
	END  
	
	-- Update Disable Colossus Bet Product
	IF @IsUpdateDisable = 1
	BEGIN
		
		EXEC Acc_CustomerUpdDisableColossusBet @custid=@custid,@Disable=@Disable,@EnableDownlines=@EnableDownlines,@UserID=@UserID,@SubAccID=@SubAccID,@IP=@IP,@Language='E',@ErrCode=@ErrCode_Cur OUTPUT,@ErrMsg=@ErrMsg_Cur OUTPUT  
		
		IF @ErrCode_Cur <> 0  
		BEGIN  
			SELECT	@ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),  
					@ErrMsg  = @ErrMsg + @ErrMsg_Cur + CHAR(7)  
		      
		END  
		ELSE  
		
			SELECT @ErrCode  = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)   
		
		
	END
	
	SET NOCOUNT OFF
  
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet] TO [bodbExtAccNet]
GO 