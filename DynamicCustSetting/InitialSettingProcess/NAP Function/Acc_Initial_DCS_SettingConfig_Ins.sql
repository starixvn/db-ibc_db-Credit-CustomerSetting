/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfig_Ins]
	@ProductID TINYINT,
	@SportTypeList VARCHAR(MAX), 
	@BetTypeList VARCHAR(MAX),
	@Site VARCHAR(MAX),
	@Currency VARCHAR(MAX),
	@StartTime DATETIME,
	@IsTest	BIT,
	@Remark	VARCHAR	(1000) = '',
	@XMLConfig VARCHAR(MAX) = '',
	@UserId	INT = 0,
	@IP	VARCHAR(45) = '',
	@IsWarning BIT = 0 OUTPUT,
	@IsConfirmed BIT = 0
AS
/*
	Created: 20211011@Eden
	Task : Insert Initial Setting config
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition

	Example: 
		DECLARE @IsWarning BIT = 0
		EXEC [Acc_Initial_DCS_SettingConfig_Ins] 
			@ProductID		= 88,
			@SportTypeList = '888,998',
			@BetTypeList = '8888,9998',
			@Site = '0',
			@Currency = '0',
			@StartTime = '2021/10/20 09:00:00',
			@IsTest = 0,
			@Remark = '',
			@IP = '',
			@UserId = 8,
			@XMLConfig = '<ROOT>
							  <R ID="1" SportType="888" BetType="8888" IsLive="0" SettingType="19" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" />
							  <R ID="2" SportType="998" BetType="9998" IsLive="0" SettingType="19" IsDefault="1" DefaultValueSuper="0.01000000" DefaultValueMaster="0.01000000" DefaultValueAgent="0.01000000" DefaultValueMember="0.01000000" />
							  <R ID="3" SportType="998" BetType="9998" IsLive="0" SettingType="18" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" />
							  <R ID="4" SportType="888" BetType="8888" IsLive="0" SettingType="18" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" />
							  <R ID="5" SportType="888" BetType="8888" IsLive="0" SettingType="13" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" SpecialRequirement="SA-RM" />
							  <R ID="6" SportType="998" BetType="9998" IsLive="0" SettingType="13" IsDefault="1" DefaultValueSuper="1" DefaultValueMaster="1" DefaultValueAgent="1" DefaultValueMember="0" />
							  <R ID="7" SportType="998" BetType="9998" IsLive="0" SettingType="17" IsDefault="1" />
							  <R ID="8" SportType="888" BetType="8888" IsLive="0" SettingType="17" IsDefault="1" />
							  <R ID="9" SportType="888" BetType="8888" IsLive="0" SettingType="12" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" SpecialRequirement="1"/>
							  <R ID="10" SportType="998" BetType="9998" IsLive="0" SettingType="6" IsDefault="1" DefaultValueSuper="3.00000000" SpecialRequirement="1" />
							</ROOT>'
			,@IsWarning = @IsWarning OUT
			,@IsConfirmed = 1
			SELECT @IsWarning

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ActionID INT  = 201054
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT
	SET @StartRun = GETDATE()

	CREATE TABLE #TempConfig(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SettingType] [tinyint],
		[IsDefault] [bit],
		[CopyFromSportType] [smallint],
		[CopyFromBetType] [smallint],
		[DefaultValueSuper] [decimal](11,8),
		[DefaultValueMaster] [decimal](11,8),
		[DefaultValueAgent] [decimal](11,8),
		[DefaultValueMember] [decimal](11,8),
		[SpecialRequirement] [varchar](MAX),
		[SettingName] [varchar](30),
		[ID] [INT]
	)

	CREATE TABLE #ErrorTbl (ID INT,ErrorCode INT , ErrorMsg VARCHAR(max))

	EXEC Acc_Initial_DCS_SettingConfig_Check 
			@ProductID		= @ProductID,
			@SportTypeList = @SportTypeList,
			@BetTypeList = @BetTypeList,
			@Site = @Site,
			@Currency = @Currency,
			@StartTime = @StartTime,
			@IsTest = @IsTest,
			@XMLConfig = @XMLConfig,
			@IsWarning = @IsWarning OUT,
			@IsConfirmed = @IsConfirmed

	IF EXISTS ( SELECT 1 FROM #ErrorTbl)
	BEGIN
		GOTO ReturnErrorTbl;
	END

	IF @IsWarning = 1
		RETURN

	DECLARE @ConfigID INT

	--Insert Config
	INSERT INTO Initial_ProductConfig(
		 ProductID
		,SportTypeList
		,BetTypeList
		,Site
		,Currency
		,StartTime
		,IsTest
		,Status
		,Remark
	)
	SELECT @ProductID
		,@SportTypeList
		,@BetTypeList
		,@Site
		,@Currency
		,@StartTime
		,@IsTest
		,0
		,@Remark 

	SELECT @ConfigID = SCOPE_IDENTITY()

	INSERT INTO Initial_ProductConfig_Detail(
		 ConfigID
		,SportType
		,BetType
		,IsLive
		,SettingType
		,IsDefault
		,CopyFromSportType
		,CopyFromBetType
		,DefaultValueSuper
		,DefaultValueMaster
		,DefaultValueAgent
		,DefaultValueMember
		,SpecialRequirement
	)
	SELECT @ConfigID
		,SportType
		,BetType
		,IsLive
		,SettingType
		,IsDefault
		,CopyFromSportType
		,CopyFromBetType
		,DefaultValueSuper
		,DefaultValueMaster
		,DefaultValueAgent
		,DefaultValueMember
		,SpecialRequirement
	FROM #TempConfig

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF (MILLISECOND, @StartRun, @EndRun)

	DECLARE @LogData VARCHAR(MAX), @LogXML XML

	SET @LogXML = (
					SELECT  (
							SELECT   @ConfigID			AS '@ConfigID'
									,@ProductID			AS '@ProductID'	
									,@SportTypeList		AS '@SportTypeList'
									,@BetTypeList		AS '@BetTypeList'
									,@Site				AS '@Site'
									,@Currency			AS '@Currency'
									,@StartTime			AS '@StartTime'
									,@IsTest			AS '@IsTest'
									,@Remark			AS '@Remark'
									,@IP				AS '@IP'
							FOR XML PATH('InitConfig'), TYPE ),
							(
								SELECT	 SportType				AS '@SportType'
										,BetType				AS '@BetType'
										,IsLive					AS '@IsLive'
										,SettingType			AS '@SettingType'
										,IsDefault				AS '@IsDefault'
										,CopyFromSportType		AS '@CopyFromSportType'
										,CopyFromBetType		AS '@CopyFromBetType'
										,DefaultValueSuper		AS '@DefaultValueSuper'
										,DefaultValueMaster		AS '@DefaultValueMaster'
										,DefaultValueAgent		AS '@DefaultValueAgent'
										,DefaultValueMember		AS '@DefaultValueMember'
										,SpecialRequirement		AS '@SpecialRequirement'
								FROM #TempConfig				
								ORDER BY SportType, BetType, IsLive, SettingType			
							FOR XML PATH ('Row'),ROOT ('Detail'), TYPE )
						FOR XML PATH('R'), TYPE
					)

	SET @LogData = REPLACE(CONVERT(VARCHAR(MAX), @LogXML), '" />', '"/"')	

	--Write log:
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserId				= @UserId,
				@CustId				= 0,
				@ActionId			= @ActionID,
				@TrackingValue		= @LogData,
				@Duration			= @Duration

	ReturnErrorTbl:
	SELECT * FROM #ErrorTbl

	DROP TABLE #TempConfig
	DROP TABLE #ErrorTbl
END
GO


