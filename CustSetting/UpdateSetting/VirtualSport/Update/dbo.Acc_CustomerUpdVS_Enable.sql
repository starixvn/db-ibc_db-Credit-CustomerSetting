USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdVS_Enable]    Script Date: 06/10/2015 16:42:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdVS_Enable    Script Date: 11/27/2014 5:09:46 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdVS_Enable]  
	@custid   INT,  
	@DisableVS  BIT = 0,  
	@DisableDownlinesVS  BIT = 0,  
	@UserID   INT,  
	@Language  VARCHAR(2) = 'E',  
	@ErrCode  INT = 0 OUTPUT,  
	@ErrMsg   NVARCHAR(200) = '' OUTPUT,  
	@IP    VARCHAR(15)=''  
AS  
 /*  
 
  Created: Scott  
  Date: 2012-12-10
  Task: Update status virtual sports  
  DB: DBTXN/BODB02  
      
  Revisions:       
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure  
	- 20130926@Kathy: Apply exec rep
	- 20131108@Elodie: Splitting bodb02 into CustDB (Turn to use Acc_ExecRep_Cust_04)	
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]	
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]
  Parameters Explanation:  
  
 */   
SET NOCOUNT ON   

DECLARE @startRun DATETIME,  
   @endRun DATETIME,  
   @duration INT,  
   @roleid TINYINT,  
   @srecommend INT,  
   @mrecommend INT,  
   @recommend INT,  
   @DisableUplineVS BIT  
   
 SET @startRun = GETDATE()  
  
 --Check disable user  
 EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output  
 IF @ErrCode <>0 RETURN  
   
 SELECT @recommend = recommend,   
		@mrecommend = mrecommend,  
		@srecommend = srecommend,    
		@roleid = roleid  
 FROM custinfo WITH(NOLOCK)  
 WHERE custid = @custid  
  
--Check Allowed downlines during peak hour at weekend   
 IF  @DisableVS = 0 and @DisableDownlinesVS = 0  
 BEGIN  
  EXEC dbo.Acc_CustomerSelCheckAllowedDownlines @custid=@custid,  
           @roleid=@roleid,  
           @isExecRep=1,  
           @Language=@Language,  
           @ErrMsg=@ErrMsg output,  
           @ErrCode=@ErrCode output  
  IF @ErrCode <>0 RETURN  
 END  
--END   


 IF @roleid = 3  
  SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @srecommend  
 ELSE IF @roleid = 2  
  SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @mrecommend  
 ELSE IF @roleid = 1  
  SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @recommend  
  
   
 IF ISNULL(@DisableUplineVS,0) = 1  
 BEGIN  
  SELECT @ErrMsg = 'Upline is disable virtual sports.',  
    @ErrCode = 100  
  RETURN   
 END   
   
 IF @DisableVS = 0  
 BEGIN  
	UPDATE custinfo WITH(UPDLOCK,ROWLOCK)  
	SET DisableVirtualSports = @DisableVS,  
		HideVirtualSports = CASE WHEN HideVirtualSports = 1 THEN 0 ELSE HideVirtualSports END
	WHERE custid = @custid  
    
	IF (@@ERROR <> 0)  
	BEGIN     
		SELECT	@ErrMsg = 'Update process is unsuccessful.',  
				@ErrCode = 201  
		RETURN  
	END 
 
	--check conditions update downline  
	IF @DisableVS = 0 and @DisableDownlinesVS = 0  
	BEGIN TRY
		--20130926@Kathy: Apply ExecRep 
		EXEC [Acc_CustomerInfo_Execrep_04]
			@CustID		= @CustID,
			@RoleID		= @RoleID,
			@Action		= 'EnableVS',
			@EnableVS = @DisableVS      
	END TRY
	BEGIN CATCH
		SELECT @ErrMsg = 'Update process is unsuccessful.', @ErrCode = 201  
		RETURN  
	END CATCH   
 END  
  
    
 DECLARE @LogSPData VARCHAR(MAX),  
   @LogSPData_Old VARCHAR(2000)  
  
 Select @LogSPData = '<Acc_CustomerUpdVS_Enable CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
      'DisableVS="'+ coalesce(cast(@DisableVS as varchar(50)),space(1)) + '" '+  
      'ApplyDownlinesVS="'+ coalesce(cast(CASE WHEN @DisableDownlinesVS = 1 THEN 0 ELSE 1 END as varchar(50)),space(1)) + '" '+  
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
	@ActionID = 1138,  
	@TrackingValue = @LogSPData  ,  
	@duration = @duration  
END TRY 
BEGIN CATCH
	Select @LogSPData = '<Acc_CustomerUpdVS_Enable CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
      'DisableVS="'+ coalesce(cast(@DisableVS as varchar(50)),space(1)) + '" '+  
      'ApplyDownlinesVS="'+ coalesce(cast(CASE WHEN @DisableDownlinesVS = 1 THEN 0 ELSE 1 END as varchar(50)),space(1)) + '" '+  
      'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  
      'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
      'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
      'ErrMsg="'+ ERROR_MESSAGE() +'" '+  
      'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
	@UserID = @UserID,  
	@CustID = @CustID,  
	@ActionID = 1138,  
	@TrackingValue = @LogSPData  ,  
	@duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdVS_Enable] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdVS_Enable] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdVS_Enable] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdVS_Enable] TO [vnteam] AS [dbo]