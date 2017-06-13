/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerUpdAllDayBalTransfer]
(    
    @Custid					INT,   
    @IsAllDayBalTransfer	BIT		= NULL,   
    @IP						VARCHAR(50)  = '',      
    @UserID					INT    = 0,  
    @Language				VARCHAR(20)  = 'E',   
    @ErrCode				VARCHAR(300) = '' OUTPUT,  
    @ErrMsg					NVARCHAR(4000) = '' OUTPUT  
      
)
AS  
/*  
    Created: Winnie  
    Date: 20160612
    Task: Enable new agent cash balance
    DB: DBCUST/CustDB

	Revisions:            
	Parameters Explanation
	
*/ 
BEGIN  
	SET NOCOUNT ON   
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	DECLARE @IsAllDayBalTransfer_Old BIT

	SET @startRun = GETDATE()

	SELECT @IsAllDayBalTransfer_Old= IsAllDayBalTransfer FROM CustSuper WITH(NOLOCK) WHERE custid=@Custid

	UPDATE CustSuper WITH (ROWLOCK,UPDLOCK)
	SET IsAllDayBalTransfer=@IsAllDayBalTransfer
	WHERE custid=@Custid
	
	DECLARE @LogSPData VARCHAR(MAX),  
			@LogSPData_Old VARCHAR(2000)  
	  
	 Select @LogSPData = '<Acc_CustomerUpdAgentCashBalance CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAllDayBalTransfer="'+ coalesce(cast(@IsAllDayBalTransfer as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  	
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	  
	  SELECT @LogSPData_Old = '<Acc_CustomerUpdAgentCashBalance CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAllDayBalTransfer="'+ coalesce(cast(@IsAllDayBalTransfer_Old as varchar(50)),space(1)) + '" '+ 	
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+	
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
		  
	 SET @endRun = GETDATE()  
	 SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)  

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 1162,  
		@TrackingValue = @LogSPData  , 
		@TrackingValue2 = @LogSPData_old  ,  
		@duration = @duration  
	END TRY 
	BEGIN CATCH		 		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 1162,  
		@TrackingValue = @LogSPData,  
		@TrackingValue2 = @LogSPData_old,  
		@duration = @duration
	END CATCH
		
  
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAllDayBalTransfer] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAllDayBalTransfer] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAllDayBalTransfer] TO [bodbExtAccNet]
GO 