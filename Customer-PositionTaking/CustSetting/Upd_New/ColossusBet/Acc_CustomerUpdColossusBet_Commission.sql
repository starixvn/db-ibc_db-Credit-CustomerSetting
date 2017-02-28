ALTER PROCEDURE [dbo].[Acc_CustomerUpdColossusBet_Commission]   

    @custid    INT,  
    @DiscountValue DECIMAL(9,8) = NULL,  
    @DiscountType INT = NULL,
    @roleID INT = NULL,
    @ActionID INT = NULL,  
    @IP     VARCHAR(50)  = '',      
    @UserID    INT    = 0,  
    @SubAccID INT = 0,
    @Language   VARCHAR(20)  = 'E',          
    @ErrCode   INT    = 0   OUTPUT,  
    @ErrMsg    NVARCHAR(4000) = ''  OUTPUT  
AS 
/*  
    Created: Helen  
    Date: 20150821
    Task: Updating: Commission/Cash In Share (Redmine: #41264)
    DB: DBCUST / CustDB
    
	Revisions:
	
	Parameters Explanation:
		@DiscountValue: New discount value needs to be updated
		@DiscountType: Type of update action
			+ @v204DiscountType = 18001: Commision
			+ @v204DiscountType =	18002: Cash In Share
		@ActionID: only for Log action
			+ @ActionID = 242,243,244: Commission
			+ @ActionID = 245,246,247: Cash In Share
	
*/ 
 
BEGIN  
  
	SET NOCOUNT ON  

	DECLARE @startRun DATETIME  
		,@endRun DATETIME   
		,@duration INT  
		

	SET @startRun = GETDATE()  

	DECLARE @ErrCode_Cur INT  
		,@ErrMsg_Cur NVARCHAR(4000)  
		,@ErrAcc  NVARCHAR(4000)  
		 
	SELECT @ErrCode_Cur = 0  
		,@ErrMsg_Cur = ''  
		,@ErrCode = ''  
		,@ErrMsg = ''  


	DECLARE @LogSPData varchar(MAX), @TrackingValueDB varchar(4000)  
	DECLARE @db_v204discountValue DECIMAL(9,8)  
	DECLARE @v204MaxdiscountValue DECIMAL(9,8)  
	
  
	IF @DiscountType IS NOT NULL  
	BEGIN         
		 SELECT @db_v204discountValue = CommRate
		 FROM AgentCommRate WITH(NOLOCK)  
		 WHERE custid = @custid   
			   AND sporttype = 204   
			   AND bettype = @DiscountType
		  
		 IF @db_v204discountValue = @DiscountValue   
			RETURN  
		       
		 SET @v204MaxdiscountValue = (SELECT Maxsdiscount FROM ProductGlobalSetting WITH (NOLOCK) WHERE Sporttype = 204 AND Bettype = @DiscountType) 
		 
		 IF @DiscountValue < 0 OR ( @DiscountValue > @v204MaxdiscountValue)  
		 BEGIN      
			  SELECT @ErrMsg = CASE 
									WHEN @Language = 'E' AND @DiscountType = 18001 THEN 'Invalid commission rate.' 
									WHEN @Language = 'E' AND @DiscountType = 18002 THEN 'Invalid Cash-In Share rate.'
									
									WHEN @Language <> 'E' AND @DiscountType = 18001 THEN [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
									  
									ELSE [dbo].[f_Get_MsgNamebyMsgID](10,@Language)  
								END  
				   ,@ErrCode = 103  
			  RETURN  
		 
		 END  
		 
		 DECLARE @DiscountValueText VARCHAR(30)  = ''
		 IF @DiscountType = 18001
			SET @DiscountValueText = 'v204discountValue_Commission'
		 IF @DiscountType = 18002	
			SET @DiscountValueText = 'v204discountValue_CashInShare'
		 -- Apply exec rep  
		  EXEC [Acc_CustSetting3rd_06]  
			   @CustId    = @custid,  
			   @RoleId    = @roleid,  
			   @Discount   = @DiscountValue,  
			   @mode    = 'ColossusBet',  
			   @Sporttype   = 204,  
			   @Bettype   = @DiscountType  
	 
		        
		 SELECT @LogSPData = '<Acc_CustomerUpdColossusBet_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
			  @DiscountValueText + '="' + COALESCE(CAST(@DiscountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
			  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
			  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'  
		  
		 SELECT @TrackingValueDB = '<Acc_CustomerUpdColossusBet_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
			  @DiscountValueText + '="' + COALESCE(CAST(@db_v204discountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
			  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
			  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
			  'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'  
		  
		  
		 SET @endRun = GETDATE()  
		 SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)  
		  
		 --Log customer info   
		 BEGIN TRY  
			  EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			   @UserID   = @UserID,  
			   @CustID   = @CustID,  
			   @ActionID  = @ActionID,  
			   @TrackingValue = @LogSPData,  
			   @TrackingValue2 = @TrackingValueDB,  
			   @duration  = @duration  
		 END TRY  
		 BEGIN CATCH  
			  SELECT @LogSPData = '<Acc_CustomerUpdColossusBet_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +   
				  @DiscountValueText + '="' + + COALESCE(CAST(@DiscountValue AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
				  'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +  
				  'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +  
				  'ErrMsg="'+ ERROR_MESSAGE() + '" />'  
		       
			  EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			   @UserID = @UserID,  
			   @CustID = @CustID,  
			   @ActionID = @ActionID,  
			   @TrackingValue = @LogSPData,  
			   @TrackingValue2 = @TrackingValueDB,  
			   @duration = @duration  
		 END CATCH 
		 
		 END   
		 
	 SET NOCOUNT OFF
	   
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet_Commission] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet_Commission] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdColossusBet_Commission] TO [bodbExtAccNet]
GO 