/*<info serverAlias="DBGLOB-GlobCustDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfig_Del]
	@ConfigID INT,
	@UserId	INT = 0,
	@IP	VARCHAR(45) = '',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg	VARCHAR(200) = '' OUTPUT
AS
/*
	Created: 20211011@Eden
	Task : Delete Initial Setting config
	DB: DBGLOB-GlobCustDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20250218@Johnson: move sp to GlobCustDB [redmine: #216870]
	Parameter Definition

	Example: 
		DECLARE @ErrCode INT = 0 ,@ErrMsg	VARCHAR(200) = ''
		EXEC [Acc_Initial_DCS_SettingConfig_Del] 
			@ConfigID = 2,
			@UserId = 8,
			@ErrCode =  @ErrCode OUT,
			@ErrMsg = @ErrMsg OUT
		SELECT @ErrCode, @ErrMsg

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @Status TINYINT
	DECLARE @ActionID INT  = 201055
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT
	SET @StartRun = GETDATE()

	IF NOT EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE ConfigID = @ConfigID)
	BEGIN
		SELECT @ErrCode = 301
			,@ErrMsg = 'This row does not exist, please refresh again.'

		RETURN
	END

	IF EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE ConfigID = @ConfigID AND Status <> 0)
	BEGIN
		SELECT @ErrCode = 302
			,@ErrMsg = 'The status of this row is no longer "Planned". You cannot edit or delete this row.'

		RETURN
	END

	DELETE 
	FROM Initial_ProductConfig_Detail WITH(ROWLOCK,UPDLOCK)
	WHERE ConfigID = @ConfigID 

	DELETE 
	FROM Initial_ProductConfig WITH(ROWLOCK,UPDLOCK)
	WHERE ConfigID = @ConfigID 

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF (MILLISECOND, @StartRun, @EndRun)

	DECLARE @LogData VARCHAR(MAX)
	SELECT  @LogData = '<R '
						+ 'ConfigID="'+ coalesce(cast(@ConfigID as varchar(50)),space(1)) + '" ' 
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


