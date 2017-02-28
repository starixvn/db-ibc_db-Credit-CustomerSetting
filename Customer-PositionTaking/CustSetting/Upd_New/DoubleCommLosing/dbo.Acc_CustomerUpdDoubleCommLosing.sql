 ALTER PROCEDURE [dbo].[Acc_CustomerUpdDoubleCommLosing]
	@custid		INT,
	@DoubleCommLosing BIT = 1,
	
	@UserID		INT = 0,
	@SubAccID	INT = 0, --Sub-AccountID
	@IP			VARCHAR(20)= '',
	@Language	VARCHAR(2) = 'E',
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2012-09-27
		Task: Update status double commission for customer
		DB: DBTXN/bodb02
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130218@Dan: Write more log on DBTXN server in case of DBLOG server failure
			- 20130507@Elodie: Correct the content of error message (MsgID=60021)
		Parameter's Explanation:
	*/
SET NOCOUNT ON
	DECLARE @startRun DATETIME
	DECLARE @endRun DATETIME
	DECLARE @duration INT
	SET @startRun = GETDATE()
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
	IF @ErrCode <>0 RETURN
	
	
	DECLARE @roleid					TINYINT,
			@uplineID				INT,
			@DoubleCommLosingUpline BIT,
			@UpdatedDownlines		BIT,	
			@DoubleCommLosing_Old	BIT
	
	SELECT @DoubleCommLosing_Old = DoubleCommLosing
	,@roleid = roleid
	,@uplineID = CASE WHEN roleid = 1 THEN recommend
					WHEN roleid = 2 THEN mrecommend
					WHEN roleid = 3 THEN srecommend END
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @custid
	
	IF @DoubleCommLosing_Old = @DoubleCommLosing
		RETURN
	
	IF @roleid < 4
	BEGIN
		SELECT @DoubleCommLosingUpline = DoubleCommLosing FROM custinfo WITH(NOLOCK) WHERE custid = @uplineID
		
		IF @DoubleCommLosingUpline = 0 AND @DoubleCOmmLosing = 1
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Cannot update double commission status for this customer because the upline is not enabled.'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](60021,@Language) END,
						@ErrCode = 100
			
			RETURN
									
		END
	END
	
	UPDATE custinfo WITH(UPDLOCK,ROWLOCK)
	SET DoubleCommLosing = @DoubleCommLosing
	WHERE custid = @custid
	
	IF @DoubleCommLosing = 0
	BEGIN
		BEGIN TRY
			IF @roleid = 4
			BEGIN
				UPDATE custinfo WITH(UPDLOCK,ROWLOCK)
				SET DoubleCommLosing = @DoubleCommLosing
				WHERE srecommend = @custid
				
				IF @@ERROR <> 0
				BEGIN
					SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END,
							@ErrCode = 100
					RETURN
				END
			END
			IF @roleid = 3
			BEGIN
				UPDATE custinfo WITH(UPDLOCK,ROWLOCK)
				SET DoubleCommLosing = @DoubleCommLosing
				WHERE mrecommend = @custid
				
				IF @@ERROR <> 0
				BEGIN
					SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END,
							@ErrCode = 101
					RETURN
				END
			END
			IF @roleid = 2
			BEGIN
				UPDATE custinfo WITH(UPDLOCK,ROWLOCK)
				SET DoubleCommLosing = @DoubleCommLosing
				WHERE recommend = @custid
				
				IF @@ERROR <> 0
				BEGIN
					SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !'
											ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END,
							@ErrCode = 102
					RETURN
				END
			END
			SELECT @UpdatedDownlines = 1
		END TRY
		BEGIN CATCH
			SELECT @UpdatedDownlines = 0
		END CATCH
	END
	
	--Log data
	DECLARE @LogData NVARCHAR(MAX)
	DECLARE @TrackingValue2 NVARCHAR(MAX)	

	SELECT @LogData ='<Acc_customerUpdDoubleCommLosing custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UpdatedDownlines="'+ COALESCE(CAST(ISNULL(@UpdatedDownlines,0) AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'
	
	SELECT @TrackingValue2 ='<Acc_customerUpdDoubleCommLosing custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing_Old AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UpdatedDownlines="'+ COALESCE(CAST(ISNULL(@UpdatedDownlines,0) AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'
	
	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

	BEGIN TRY	
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID, 
			@CustID = @custid,
			@ActionID = 1139,
			@TrackingValue = @LogData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH			
		SELECT @LogData ='<Acc_customerUpdDoubleCommLosing custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing AS VARCHAR(50)),SPACE(1)) + '" ' +
		'UpdatedDownlines="'+ COALESCE(CAST(ISNULL(@UpdatedDownlines,0) AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" ' +
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'
		
		SELECT @TrackingValue2 ='<Acc_customerUpdDoubleCommLosing custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'DoubleCommLosing="'+ COALESCE(CAST(@DoubleCommLosing_Old AS VARCHAR(50)),SPACE(1)) + '" ' +
		'UpdatedDownlines="'+ COALESCE(CAST(ISNULL(@UpdatedDownlines,0) AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" ' +
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(20)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))  + '" />'
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID, 
			@CustID = @custid,
			@ActionID = 1139,
			@TrackingValue = @LogData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration			
	END CATCH
GO
GRANT EXECUTE ON [dbo].[Acc_customerUpdDoubleCommLosing] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_customerUpdDoubleCommLosing] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_customerUpdDoubleCommLosing] TO [bodbDownlineNet]