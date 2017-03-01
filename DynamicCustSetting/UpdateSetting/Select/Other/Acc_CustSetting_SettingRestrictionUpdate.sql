ALTER PROCEDURE [dbo].[Acc_CustSetting_SettingRestrictionUpdate]  
	@IsAllowed	BIT = 0
	, @UserID	INT
	, @SubAccID		INT			= 0
	, @IP		VARCHAR(50)		= ''
AS  
/*  
	Created: 20160217@Dominic  
	Task: Not Allow to update setting on Alpha
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions: 
		- Dominic@20160315:  Add Log to check who update On/Off Restriction #54083
*/  
BEGIN  
	SET NOCOUNT ON  
	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
	
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
			
	SET @startRun = GETDATE()
	
	DECLARE @CurrentVal BIT = 0
	SELECT TOP 1 @CurrentVal = CASE WHEN RestrictionMode = 1 THEN 1 ELSE 0 END
	FROM dbo.ProductSettingUpdateRestriction WITH(NOLOCK)
	
	IF @CurrentVal = @IsAllowed RETURN
	
	SET @xml = (
				SELECT	@CurrentVal						AS '@IsAllowed',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@IP								AS '@IP'
				FOR XML PATH('Acc_CustSetting_SettingRestrictionUpdate'),
				TYPE
			)
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	SET @xml = (
				SELECT	@IsAllowed						AS '@IsAllowed',
						@UserID							AS '@UserID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@IP								AS '@IP'
				FOR XML PATH('Acc_CustSetting_SettingRestrictionUpdate'),
				TYPE
			)
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		
	IF @IsAllowed = 1
	BEGIN
		UPDATE dbo.ProductSettingUpdateRestriction
		SET RestrictionMode = 1 --Read & Write
	END
	ELSE
	BEGIN
		UPDATE dbo.ProductSettingUpdateRestriction
		SET RestrictionMode = 2 --Read Only
	END
	
	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= 0
						, @ActionID			= 31301
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= 0
						, @ActionID			= 31301
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END CATCH
	
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingRestrictionUpdate] TO [bodbExtAccNet]