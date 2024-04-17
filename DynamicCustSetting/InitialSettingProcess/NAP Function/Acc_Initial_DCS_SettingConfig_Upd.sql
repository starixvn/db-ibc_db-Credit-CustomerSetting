/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfig_Upd]
	@ConfigID INT,
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
	Task : Update Initial Setting config
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition

	Example: 
		DECLARE @IsWarning BIT = 0
		EXEC [Acc_Initial_DCS_SettingConfig_Upd] 
			@ProductID		= 88,
			@SportTypeList = '888,998',
			@BetTypeList = '8888,9998',
			@Site = '1',
			@Currency = '0',
			@StartTime = '2021-07-15 01:00:00.000',
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
							  <R ID="9" SportType="888" BetType="8888" IsLive="0" SettingType="12" IsDefault="0" CopyFromSportType="211" CopyFromBetType="2401" SpecialRequirement="1" />
							  <R ID="10" SportType="998" BetType="9998" IsLive="0" SettingType="6" IsDefault="1" DefaultValueSuper="3.00000000" SpecialRequirement="1" />
							</ROOT>'
			,@ConfigID = 1
			,@IsWarning = @IsWarning OUT
			,@IsConfirmed = 1
			SELECT @IsWarning

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ActionID INT  = 201056
	DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT
	SET @StartRun = GETDATE()
	DECLARE @LogData VARCHAR(MAX), @LogXML XML
		,@LogData_old VARCHAR(MAX), @LogXML_old XML

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

	IF NOT EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE ConfigID = @ConfigID)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT NULL
			,ErrCode = 301
			,ErrMsg = 'This row does not exist, please refresh again.'

		GOTO ReturnErrorTbl;
	END

	IF EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE ConfigID = @ConfigID AND Status <> 0)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT NULL
			,ErrCode = 302
			,ErrMsg = 'The status of this row is no longer "Planned". You cannot edit or delete this row.'

		GOTO ReturnErrorTbl;
	END

	EXEC Acc_Initial_DCS_SettingConfig_Check 
			@ConfigID = @ConfigID,
			@ProductID	= @ProductID,
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

	--> Get old data for write log
	SET @LogXML_old = (
					SELECT  (
							SELECT   ConfigID			AS '@ConfigID'
									,ProductID			AS '@ProductID'	
									,SportTypeList		AS '@SportTypeList'
									,BetTypeList		AS '@BetTypeList'
									,Site				AS '@Site'
									,Currency			AS '@Currency'
									,StartTime			AS '@StartTime'
									,IsTest				AS '@IsTest'
									,Remark				AS '@Remark'
									,@IP				AS '@IP'
							FROM Initial_ProductConfig WITH(NOLOCK)
								WHERE ConfigID = @ConfigID	
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
								FROM Initial_ProductConfig_Detail WITH(NOLOCK)
								WHERE ConfigID = @ConfigID							
							FOR XML PATH ('Row'),ROOT ('Detail'), TYPE )
						FOR XML PATH('R'), TYPE
					)

	--> Update Initial_ProductConfig
	UPDATE Initial_ProductConfig WITH(ROWLOCK,UPDLOCK)
	SET  ProductID			= @ProductID
		,SportTypeList		= @SportTypeList
		,BetTypeList		= @BetTypeList
		,Site				= @Site
		,Currency			= @Currency
		,StartTime			= @StartTime
		,IsTest				= @IsTest
		,Remark				= @Remark 
	WHERE ConfigID = @ConfigID

	--> Reresh Initial_ProductConfig_Detail
	MERGE Initial_ProductConfig_Detail dt
	USING #TempConfig t
		ON dt.ConfigID = @ConfigID
		AND dt.Sporttype = t.Sporttype
		AND dt.BetType = t.BetType
		AND dt.IsLive = t.IsLive
		AND dt.SettingType = t.SettingType
	WHEN MATCHED AND NOT ( dt.IsDefault							= t.IsDefault
						AND ISNULL(dt.CopyFromSportType,0)		= ISNULL(t.CopyFromSportType,0)
						AND ISNULL(dt.CopyFromBetType,0)		= ISNULL(t.CopyFromBetType,0)
						AND ISNULL(dt.DefaultValueSuper,0)		= ISNULL(t.DefaultValueSuper,0)
						AND ISNULL(dt.DefaultValueMaster,0)		= ISNULL(t.DefaultValueMaster,0)
						AND ISNULL(dt.DefaultValueAgent,0)		= ISNULL(t.DefaultValueAgent,0)
						AND ISNULL(dt.DefaultValueMember,0)		= ISNULL(t.DefaultValueMember,0)
						AND ISNULL(dt.SpecialRequirement,'')	= ISNULL(t.SpecialRequirement,'')
					)
			THEN 
						UPDATE
						SET  dt.IsDefault			= t.IsDefault
							,dt.CopyFromSportType	= t.CopyFromSportType
							,dt.CopyFromBetType		= t.CopyFromBetType
							,dt.DefaultValueSuper	= t.DefaultValueSuper
							,dt.DefaultValueMaster	= t.DefaultValueMaster
							,dt.DefaultValueAgent	= t.DefaultValueAgent
							,dt.DefaultValueMember	= t.DefaultValueMember
							,dt.SpecialRequirement	= t.SpecialRequirement
	WHEN NOT MATCHED THEN 
						INSERT (
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
						VALUES( @ConfigID
								,t.SportType
								,t.BetType
								,t.IsLive
								,t.SettingType
								,t.IsDefault
								,t.CopyFromSportType
								,t.CopyFromBetType
								,t.DefaultValueSuper
								,t.DefaultValueMaster
								,t.DefaultValueAgent
								,t.DefaultValueMember
								,t.SpecialRequirement
							)
	WHEN NOT MATCHED BY SOURCE AND dt.ConfigID = @ConfigID
		THEN DELETE; 

	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF (MILLISECOND, @StartRun, @EndRun)

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
	SET @LogData_old = REPLACE(CONVERT(VARCHAR(MAX), @LogXML_old), '" />', '"/"')

	--Write log:
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserId				= @UserId,
				@CustId				= 0,
				@ActionId			= @ActionID,
				@TrackingValue		= @LogData,
				@TrackingValue2		= @LogData_old,
				@Duration			= @Duration

	ReturnErrorTbl:
	SELECT * FROM #ErrorTbl

	DROP TABLE #TempConfig
	DROP TABLE #ErrorTbl
END
GO


