/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].Acc_CustomerUpd_IsAutoEnableADBMaster
	@UserId					INT = 0
	,@CustId				INT
	,@IsAutoEnableADBMaster	BIT = NULL
	,@IP					VARCHAR(50) = ''
	,@Language				VARCHAR(20) = 'E'
	,@ErrCode				VARCHAR(300) = '' OUTPUT
	,@ErrMsg				NVARCHAR(4000) = '' OUTPUT
AS

/*  
    Created: 20200602@Sol
	DB: DBCUST.CustDB
    Task: Update IsAutoEnableADBMaster value

	Revisions:
		- 20200602@Sol: Update IsAutoEnableADBMaster [Redmine: #134242]
*/

BEGIN  
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
	DECLARE @endRun		DATETIME
	DECLARE @duration	INT
	DECLARE @ActionID	INT = 707
	DECLARE @IsAutoEnableADBMaster_Old BIT, @roleId TINYINT

	SET @startRun = GETDATE()
	SELECT @ErrCode = 0, @ErrMsg = ''

	SELECT @roleId = roleid FROM dbo.Customer WITH (NOLOCK) WHERE custid = @CustId

	IF ISNULL(@roleId, 0) <> 4
	BEGIN
		-- 'Customer does not exist.'
		SELECT @ErrCode = 100, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40014, @Language)
		RETURN
	END

	IF @roleId = 4
	BEGIN
		
		SELECT @IsAutoEnableADBMaster_Old = IsAutoEnableADBMaster FROM dbo.CustSuper WITH (NOLOCK) WHERE custid = @Custid

		BEGIN TRY
			UPDATE dbo.CustSuper WITH (ROWLOCK)
			SET IsAutoEnableADBMaster = @IsAutoEnableADBMaster
			WHERE custid = @CustId
		END TRY
		BEGIN CATCH
			-- Action failed. Please try again.
			SELECT @ErrCode = 101, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40049, @Language)
			RETURN
		END CATCH
		
	END
	
	DECLARE @LogSPData VARCHAR(MAX),  
			@LogSPData_Old VARCHAR(2000)  
	  
	Select @LogSPData = '<Acc_CustomerUpd_IsAutoEnableADBMaster CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAutoEnableADBMaster="'+ coalesce(cast(@IsAutoEnableADBMaster as varchar(50)),space(1)) + '" '+  
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  	
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	  
	SELECT @LogSPData_Old = '<Acc_CustomerUpd_IsAutoEnableADBMaster CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAutoEnableADBMaster="'+ coalesce(cast(@IsAutoEnableADBMaster_Old as varchar(50)),space(1)) + '" '+ 	
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+	
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
		  
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF (MILLISECOND, @startRun, @endRun)  

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			@UserID				= @UserID
			,@CustID			= @CustID
			,@ActionID			= @ActionID
			,@TrackingValue		= @LogSPData
			,@TrackingValue2	= @LogSPData_old
			,@duration			= @duration
	END TRY 
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
			@UserID				= @UserID
			,@CustID			= @CustID
			,@ActionID			= @ActionID
			,@TrackingValue		= @LogSPData
			,@TrackingValue2	= @LogSPData_old
			,@duration			= @duration
	END CATCH
END
GO