/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdAllDayBalTransfer]
	@UserId					INT = 0
	,@CustId				INT
	,@IsAllDayBalTransfer	BIT = NULL
	,@IsIncludedDownline	BIT = NULL
	,@IP					VARCHAR(50) = ''
	,@Language				VARCHAR(20) = 'E'
	,@ErrCode				VARCHAR(300) = '' OUTPUT
	,@ErrMsg				NVARCHAR(4000) = '' OUTPUT
AS

/*  
    Created: 20160612@Winnie
	DB: DBCUST.CustDB
    Task: Enable new agent cash balance

	Revisions:
		- 20200310@Percy: Add master level [RedmineID: #130091]
		- 20200319@Percy: Add option enable downline if enable super [RedmineID: #130741]
		- 20200602@Sol: Update IsAutoEnableADBMaster [Redmine: #134242]
		- 20240523@Lewis: Change SQL Account [Redmine: #204021]
		- 20241125@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
*/

BEGIN  
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
	DECLARE @endRun		DATETIME
	DECLARE @duration	INT
	DECLARE @ActionID	INT = 705
	DECLARE @IsAllDayBalTransfer_Old BIT, @roleId TINYINT, @IsAutoEnableADBMaster_Old BIT

	SET @startRun = GETDATE()
	SELECT @ErrCode = 0, @ErrMsg = ''

	SELECT @roleId = roleid FROM dbo.Customer WITH (NOLOCK) WHERE custid = @CustId

	IF ISNULL(@roleId, 0) NOT IN (3, 4)
	BEGIN
		-- 'Customer does not exist.'
		SELECT @ErrCode = 100, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40014, @Language)
		RETURN
	END

	IF @roleId = 4
	BEGIN
		SELECT 
			@IsAllDayBalTransfer_Old = IsAllDayBalTransfer,
			@IsAutoEnableADBMaster_Old = IsAutoEnableADBMaster
		FROM dbo.CustSuper WITH (NOLOCK) WHERE custid = @Custid

		BEGIN TRY
			UPDATE dbo.CustSuper WITH (ROWLOCK)
			SET IsAllDayBalTransfer = @IsAllDayBalTransfer,
				IsAutoEnableADBMaster = CASE WHEN @IsAllDayBalTransfer = 0 THEN 0 ELSE IsAutoEnableADBMaster END,
				RepUpdateTime = dbo.f_GetDateTime2()
			WHERE custid = @CustId
		END TRY
		BEGIN CATCH
			-- Action failed. Please try again.
			SELECT @ErrCode = 101, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40049, @Language)
			RETURN
		END CATCH

		IF @IsAllDayBalTransfer = 0 -- Uncheck super --> uncheck all masters
			OR (@IsAllDayBalTransfer = 1 AND @IsIncludedDownline = 1) -- Check super and include downline --> check all masters
		BEGIN
			BEGIN TRY
				UPDATE m WITH (ROWLOCK)
				SET IsAllDayBalTransfer = @IsAllDayBalTransfer,
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.CustMaster m
					INNER JOIN dbo.Customer c WITH (NOLOCK) ON m.custid = c.custid
				WHERE c.srecommend = @CustId
					AND c.roleid = 3
			END TRY
			BEGIN CATCH
				-- Rollback manually
				UPDATE dbo.CustSuper WITH (ROWLOCK)
				SET IsAllDayBalTransfer = @IsAllDayBalTransfer_Old,
					RepUpdateTime = dbo.f_GetDateTime2()
				WHERE custid = @CustId

				-- Action failed. Please try again.
				SELECT @ErrCode = 102, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40049, @Language)
				RETURN
			END CATCH
		END
	END
	ELSE IF @roleId = 3
	BEGIN
		IF SUSER_NAME() = 'wsv_alp'
		BEGIN
			SELECT @ActionID = 706

			IF NOT EXISTS (SELECT 1 FROM dbo.CustSuper WITH (NOLOCK) WHERE custid = @UserId AND IsAllDayBalTransfer = 1)
			BEGIN
				-- You are not authorized on this function.
				SELECT @ErrCode = 103, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40028, @Language)
				RETURN
			END
		END

		SELECT @IsAllDayBalTransfer_Old = IsAllDayBalTransfer FROM dbo.CustMaster WITH (NOLOCK) WHERE custid = @Custid

		BEGIN TRY
			UPDATE dbo.CustMaster WITH (ROWLOCK)
			SET IsAllDayBalTransfer = @IsAllDayBalTransfer,
				RepUpdateTime = dbo.f_GetDateTime2()
			WHERE custid = @CustId
		END TRY
		BEGIN CATCH
			-- Action failed. Please try again.
			SELECT @ErrCode = 104, @ErrMsg = dbo.f_Get_MsgNamebyMsgID(40049, @Language)
			RETURN
		END CATCH
	END
	
	DECLARE @LogSPData VARCHAR(MAX),  
			@LogSPData_Old VARCHAR(2000)  
	  
	Select @LogSPData = '<Acc_CustomerUpdAllDayBalTransfer CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAllDayBalTransfer="'+ coalesce(cast(@IsAllDayBalTransfer as varchar(50)),space(1)) + '" '+  
		  CASE WHEN @roleId = 4 THEN 'IsAutoEnableADBMaster="'+ coalesce(cast(0 as varchar(50)),space(1)) + '" '  ELSE '' END +
		  'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+  	
		  'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+  
		  'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+  
		  'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+  
		  'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'  
	  
	SELECT @LogSPData_Old = '<Acc_CustomerUpdAllDayBalTransfer CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+  
		  'IsAllDayBalTransfer="'+ coalesce(cast(@IsAllDayBalTransfer_Old as varchar(50)),space(1)) + '" '+ 	
		  CASE WHEN @roleId = 4 THEN 'IsAutoEnableADBMaster="'+ coalesce(cast(@IsAutoEnableADBMaster_Old as varchar(50)),space(1)) + '" ' ELSE '' END + 	
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

	-- Write log to support downlines view upline's actions
	IF @RoleId = 4
		AND (
			@IsAllDayBalTransfer = 0
			OR (@IsAllDayBalTransfer = 1 AND @IsIncludedDownline = 1)
		)
	BEGIN
		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
				@UserID				= @UserID
				,@CustID			= @CustID
				,@ActionID			= 65019 -- master view on super action
				,@TrackingValue		= @LogSPData
				,@TrackingValue2	= @LogSPData_old
				,@duration			= @duration
		END TRY 
		BEGIN CATCH
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
				@UserID				= @UserID
				,@CustID			= @CustID
				,@ActionID			= 65019 -- master view on super action
				,@TrackingValue		= @LogSPData
				,@TrackingValue2	= @LogSPData_old
				,@duration			= @duration
		END CATCH
	END
END
GO