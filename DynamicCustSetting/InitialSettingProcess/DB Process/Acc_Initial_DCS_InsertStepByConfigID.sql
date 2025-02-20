/*<info serverAlias="DBGLOB-GlobCustDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_InsertStepByConfigID]
	@ConfigID INT
AS
/*
	Created: 20210713@Eden
	Task : insert data for Initial_StepByConfig
	DB: DBGLOB-GlobCustDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20250218@Johnson: move sp to GlobCustDB [redmine: #216870]
	Parameter Definition
		StepID = :
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
	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @EnableStatus_Step BIT = 0
	DECLARE @IsInsertUpdateSetting_Step BIT = 0

	TRUNCATE TABLE Initial_StepByConfig

	IF EXISTS(
		SELECT 1
		FROM Initial_ProductConfig_Detail i WITH(NOLOCK)
			INNER JOIN ProductSettingType t WITH(NOLOCK) ON i.SettingType = t.SettingType AND t.SettingName != 'Product Status'
		WHERE i.ConfigID = @ConfigID
	)
		SET @IsInsertUpdateSetting_Step = 1

	IF @IsInsertUpdateSetting_Step = 1
	BEGIN
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 1,1 UNION ALL
		SELECT 2,1
	END

	IF EXISTS(
		SELECT 1
		FROM Initial_ProductConfig_Detail i WITH(NOLOCK)
			INNER JOIN ProductSettingType t WITH(NOLOCK) ON i.SettingType = t.SettingType AND t.SettingName = 'Product Status'
		WHERE i.ConfigID = @ConfigID
	)
	BEGIN
		SET @EnableStatus_Step = 1

		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 3,1
	END

	IF @IsInsertUpdateSetting_Step = 1
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 4,0
	
	IF @EnableStatus_Step = 1
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 5,0

	IF @IsInsertUpdateSetting_Step = 1
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 6,0

	IF EXISTS(
		SELECT 1
		FROM Initial_ProductConfig_Detail i WITH(NOLOCK)
			INNER JOIN ProductSettingType t WITH(NOLOCK) ON i.SettingType = t.SettingType AND t.SettingName = 'Product Status' AND i.IsDefault = 0
		WHERE i.ConfigID = @ConfigID
	)
	BEGIN
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 7,0
	END

	IF @EnableStatus_Step = 1
		AND EXISTS( 
					SELECT 1
					FROM Initial_ProductConfig_Detail i WITH(NOLOCK)
						INNER JOIN ProductSettingType t WITH(NOLOCK) ON i.SettingType = t.SettingType AND t.SettingName = 'Product Status'
					WHERE i.ConfigID = @ConfigID
						AND ISNULL(i.SpecialRequirement,'') <> ''
				)
	BEGIN
		INSERT Initial_StepByConfig(StepID, IsScanCustomer)
		SELECT 8,0
	END
END
GO


