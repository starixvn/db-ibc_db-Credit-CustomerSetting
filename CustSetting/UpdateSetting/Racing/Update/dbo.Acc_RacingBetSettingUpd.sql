ALTER PROCEDURE [dbo].[Acc_RacingBetSettingUpd]
	@userid		INT,
	
	@sporttype	INT,
	@bettype	INT, 
	@currency	INT,
	@minbet		MONEY,
	
	@ErrCode	INT = 0 OUTPUT,
	@ErrMsg		VARCHAR(200) = '' OUTPUT,
	@System		VARCHAR (50) = 'ACCOUNTING'
 AS
	/*
		Created: Johnson
		Date: 2013-03-07
		Task: Update bet setting of 3rd
		DB: DBCUST/CustDB
		
		Revisions:
			- 20130520@Johnson: insert racing bet setting of 3rd incase of not exists
			- 20130808@Elodie: Splitting DBTXN into DBCUST
		Parameter's Explanation:
	*/
SET NOCOUNT ON
	DECLARE @Begin		AS DATETIME, 
			@End		AS DATETIME, 
			@Duration	AS INT;
	
	SET @Begin = GETDATE();
	
	EXEC DBPOLICY.bodb02.dbo.Acc_Con_CheckPermission @custid = @UserID, @funcname = '[RacingDefaultSetting]', @System = @System, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT;
	
	IF @ErrCode <> 0
		RETURN;
	
	DECLARE @minbet_old MONEY
	
	SELECT @minbet_old = minbet 
	FROM RacingBetSetting WITH(NOLOCK) 
	WHERE sporttype = @sporttype 
		AND bettype = @bettype 
		AND currency = @currency
	
	IF @minbet = @minbet_old 
		RETURN
	
	IF @minbet_old IS NULL
	BEGIN
		INSERT INTO RacingBetSetting(sporttype,bettype,currency,minbet)
		VALUES(@sporttype,@bettype,@currency,@minbet)		
	END
	ELSE
	BEGIN
		UPDATE RacingBetSetting WITH(UPDLOCK,ROWLOCK)
		SET minbet = @minbet
		WHERE sporttype = @sporttype 
			AND bettype = @bettype 
			AND currency = @currency
	END
	
	DECLARE @LogSPData	AS NVARCHAR(500), 	
			@TrackingValueDB AS NVARCHAR(500)
					
	SELECT @LogSPData = '<Acc_RacingBetSettingUpd sporttype="'+ COALESCE(cast(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'bettype="'+ COALESCE(cast(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'currency="' + COALESCE(cast(@currency AS VARCHAR(10)),SPACE(1)) + '" ' +
												'minbet="' + COALESCE(cast(@minbet AS VARCHAR(10)),SPACE(1)) + '" />'
												
	SELECT @TrackingValueDB = '<Acc_RacingBetSettingUpd sporttype="'+ COALESCE(cast(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'bettype="'+ COALESCE(cast(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'currency="' + COALESCE(cast(@currency AS VARCHAR(10)),SPACE(1)) + '" ' +
												'minbet="' + COALESCE(cast(@minbet_old AS VARCHAR(10)),SPACE(1)) + '" />'
	
	SET @End = GETDATE()
	SET @Duration = DATEDIFF(millisecond,@Begin,@End)	
		
	IF @minbet_old IS NOT NULL
	BEGIN 
		BEGIN TRY	
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @userid,		
			@ActionID = 376,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
		END TRY		
		BEGIN CATCH
		SELECT @LogSPData = '<Acc_RacingBetSettingUpd sporttype="'+ COALESCE(cast(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'bettype="'+ COALESCE(cast(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'currency="' + COALESCE(Cast(@currency AS VARCHAR(10)),SPACE(1)) + '" ' +
												'minbet="' + COALESCE(cast(@minbet AS VARCHAR(10)),SPACE(1)) + '" '+
												'ErrMsg="' + ERROR_MESSAGE() + '" />'
												
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @userid,		
				@ActionID = 376,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @TrackingValueDB,
				@duration = @duration	
		END CATCH		
	END
	ELSE 
	BEGIN
		BEGIN TRY	
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @userid,		
			@ActionID = 377,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
		END TRY		
		BEGIN CATCH
		SELECT @LogSPData = '<Acc_RacingBetSettingUpd sporttype="'+ COALESCE(cast(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'bettype="'+ COALESCE(cast(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' +
												'currency="' + COALESCE(Cast(@currency AS VARCHAR(10)),SPACE(1)) + '" ' +
												'minbet="' + COALESCE(cast(@minbet AS VARCHAR(10)),SPACE(1)) + '" '+
												'ErrMsg="' + ERROR_MESSAGE() + '" />'
												
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
				@UserID = @userid,		
				@ActionID = 377,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @TrackingValueDB,
				@duration = @duration	
		END CATCH		
	END

GO
GRANT EXECUTE ON [dbo].[Acc_RacingBetSettingUpd] TO [bodbadminNet] AS [dbo]