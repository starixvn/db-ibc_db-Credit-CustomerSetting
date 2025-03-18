/*<info serverAlias="DBGLOB-GlobCustDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_ScanConfig]
	@ConfigID INT = 0 OUTPUT,
	@IsProd BIT = 0 OUTPUT, --1: PROD env, 0: Testing env ( to config more replicated server)
	--@MaxcustID INT = 0 OUTPUT,
	@XMLConfig VARCHAR(MAX) = 0 OUTPUT, 
	@IsTest BIT = NULL
AS
/*
	Created: 20210713@Eden
	Task : Job detect initial Setting Process
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 
	- 20241122@Elodie : Initial by Super for UUS and YNG [Redmine: #214128]
	- 20250314@Johnson: move sp to GlobCustDB [redmine: #216870]
	Value Mapping
		CurrentStep = :
			1: Delete existing customer setting
			2: Insert customer setting
			3: Enable status
			4: Insert setting for new customers
			5: Enable status for new customers
			6: Adjust setting
			7: Adjust status
			8: Disable status headline
			....

	Example: 
	DECLARE @ConfigID INT, @XMLConfig VARCHAR(MAX), @MaxcustID INT, @IsProd BIT
	EXEC [Acc_Initial_DCS_ScanConfig] 
		@ConfigID = @ConfigID OUTPUT,
		@XMLConfig = @XMLConfig OUT,
		@IsProd = @IsProd OUT,
		@MaxcustID = @MaxcustID OUT
	SELECT @ConfigID, @IsProd,@XMLConfig, @MaxcustID
	
	*/
BEGIN
	SET NOCOUNT ON
	
	SELECT @ConfigID = 0

	IF @@SERVERNAME = 'DBCUST'
		SET @IsProd = 1
	ELSE
		SET @IsProd = 0

	IF @IsTest IS NULL
	BEGIN
		IF @IsProd = 1 
			SET @IsTest = 0 -- dont't initial for test config on PRODUCTION
		ELSE
			SET @IsTest = 1
	END

	IF EXISTS ( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE Status = 1 AND IsTest <= @IsTest) --RUNNING
	BEGIN
		PRINT 'Have process is running'
		GOTO ReturnLB;
	END

	SELECT TOP(1) @ConfigID = ConfigID  
	FROM Initial_ProductConfig WITH(NOLOCK) 
	WHERE Status IN (0) --Planned
		AND StartTime <= GETDATE()
		AND IsTest <= @IsTest
		AND ConfigID > 0
	ORDER BY StartTime, ConfigID

	IF @ConfigID IS NOT NULL
	BEGIN
		EXEC [Acc_Initial_DCS_ConfigStatus_Upd] 
			@ConfigID = @ConfigID,
			@Status = 1
	END
	ELSE
	BEGIN
		PRINT 'Have no process need to be run on this time'
		GOTO ReturnLB;
	END
	
	-------------------> Start initial data for running process-----------------------------------
	DECLARE @Site VARCHAR(MAX), @Currency VARCHAR(MAX)
	DECLARE @TBL_site TABLE(SiteID INT,Site VARCHAR(10) PRIMARY KEY)
	DECLARE @TBL_Currency TABLE(Currency INT PRIMARY KEY)

	SELECT @Site = Site, @Currency = Currency
	FROM Initial_ProductConfig WITH(NOLOCK)
	WHERE ConfigID = @ConfigID
		AND Status = 1 --Running

	IF @@ROWCOUNT = 0
	BEGIN
		PRINT 'No site/currency'
		GOTO ReturnLB;
	END
	
	IF EXISTS(
		SELECT TOP 1 1 
		FROM Initial_ProductConfig_Detail WITH(NOLOCK)
		WHERE ConfigID = @ConfigID
	)
	BEGIN
		SELECT @XMLConfig = (
		SELECT	 idt.SportType
				,idt.BetType
				,idt.IsLive
				,idt.SettingType
				,idt.IsDefault
				,idt.CopyFromSportType
				,idt.CopyFromBetType
				,idt.DefaultValueSuper
				,idt.DefaultValueMaster
				,idt.DefaultValueAgent
				,idt.DefaultValueMember
				,idt.SpecialRequirement
				,t.SettingName
		FROM Initial_ProductConfig_Detail idt WITH(NOLOCK)
			INNER JOIN ProductSettingType t WITH(NOLOCK) ON t.SettingType = idt.SettingType
		WHERE ConfigID = @ConfigID
		FOR XML RAW('R'))

		SELECT @XMLConfig = '<ROOT> ' + @XMLConfig + ' </ROOT>'
	END
	ELSE
	BEGIN
		PRINT 'No Setting'
		GOTO ReturnLB;
	END

	--> Insert Initial_StepByConfig
	EXEC Acc_Initial_DCS_InsertStepByConfigID @ConfigID = @ConfigID
	
	ReturnLB:
	SELECT CAST(StepID AS INT) AS StepID, IsScanCustomer, @XMLConfig AS XMLConfig
	FROM Initial_StepByConfig WITH(NOLOCK) 
	ORDER BY SortOrder

END
GO


