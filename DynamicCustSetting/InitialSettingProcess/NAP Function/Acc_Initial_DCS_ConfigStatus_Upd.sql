/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_ConfigStatus_Upd]
	@ConfigID INT,
	@Status TINYINT,
	@UserId	INT = 0,
	@IP	VARCHAR(45) = '',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg	VARCHAR(200) = '' OUTPUT
AS
/*
	Created: 20210713@Eden
	Task : Update Initial_ProductConfig.Status
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition
		@Status = :
			0: Planned
			1: Running 
			2: Completed 
			3: Aborted

	Example: 
		DECLARE @ErrCode INT = 0 ,@ErrMsg	VARCHAR(200) = ''
		EXEC [Acc_Initial_DCS_ConfigStatus_Upd] 
			@ConfigID = 1,
			@Status = 2,
			@ErrCode =  @ErrCode OUT,
			@ErrMsg = @ErrMsg OUT
		SELECT @ErrCode, @ErrMsg
	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ActionID INT  = 201051
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT
	SET @StartRun = GETDATE()
	DECLARE @Old_Status TINYINT

	IF ISNULL(@Status,0) = 0
		RETURN

	IF NOT EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE ConfigID = @ConfigID)
	BEGIN
		SELECT @ErrCode = 301
			,@ErrMsg = 'This row does not exist, please refresh again.'

		RETURN
	END

	SELECT @Old_Status = Status
	FROM Initial_ProductConfig WITH(NOLOCK)
	WHERE ConfigID = @ConfigID

	IF @Status IN (2,3) AND @Old_Status = 0
	BEGIN
		IF @Status = 3
		BEGIN
			SELECT @ErrCode = 1,
				@ErrMsg = 'The status of this row is no longer "Running". You cannot abort this row.'
		END
		ELSE
		BEGIN
			SELECT @ErrCode = 1,
				@ErrMsg = 'The status of this row is no longer "Running".'
		END

		RETURN
	END

	IF @Old_Status IN (2,3)
	BEGIN
		IF @Status = 3
		BEGIN
			SELECT @ErrCode = 1,
				@ErrMsg = 'The status of this row is no longer "Running". You cannot abort this row.'
		END
		ELSE
		BEGIN
			SELECT @ErrCode = 1,
				@ErrMsg = 'The status of this row is no longer "Running".'
		END

		RETURN
	END
	
	UPDATE Initial_ProductConfig WITH(ROWLOCK,UPDLOCK)
	SET Status = @Status,
		EndTime = CASE WHEN @Status = 2 THEN GETDATE() ELSE EndTime END,
		CurrentStep = CASE WHEN @Status = 2 THEN NULL ELSE CurrentStep END
	WHERE ConfigID = @ConfigID

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF (MILLISECOND, @StartRun, @EndRun)

	DECLARE @LogData VARCHAR(MAX)
	SELECT  @LogData = '<R '
						+ 'ConfigID="'+ coalesce(cast(@ConfigID as varchar(50)),space(1)) + '" ' 
						+ 'Status="'+ coalesce(cast(@Status as varchar(50)),space(1)) + '" ' 
						+ 'IP="' + COALESCE(@IP, SPACE(1)) + '" '
						+ ' />'

	--Write log:
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserId				= @UserId,
				@CustId				= 0,
				@ActionId			= @ActionID,
				@TrackingValue		= @LogData,
				@Duration			= @Duration
END
GO


