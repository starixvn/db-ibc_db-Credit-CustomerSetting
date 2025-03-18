/*<info serverAlias="DBGLOB-GlobCustDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_UMConfigUpd]
	@ConfigID INT,
	@StepID TINYINT
AS
/*
	Created: 20250314@Johnson
	Task : Update UM Config
	DB: DBGLOB-GlobCustDB
	
	Revisions:
		- 20250314@Johnson: move to Glob for updating UM Config [redmine: #216870]

*/
BEGIN
	IF @StepID <> 4 
		RETURN;
	
	DECLARE @Currency VARCHAR(MAX)
	DECLARE @CurrentDTS DATETIME = GETDATE()
	
	SELECT @Currency = Currency
	FROM Initial_ProductConfig WITH(NOLOCK)
	WHERE ConfigID = @ConfigID
		AND Status = 1 --Running
	

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
		[bitmapOrder] [tinyint],
		[bitmapOrder_Source] [tinyint],
		[IsFinished] [bit] default 0,
		[ProductID] [TINYINT],
		[CopyFrom_ProductID] [TINYINT],
		[HaveWinLimit] BIT DEFAULT 1, -- 0 : Only Loss Limit
		[HaveMaxPerMatch] BIT DEFAULT 1, -- 0: Not use MaxPerMatch
		[HaveMaxPerNumber] BIT DEFAULT 0 -- 0: Not use HaveMaxPerNumber
	)
	
	INSERT INTO #TempConfig (
		 SportType
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
		,SettingName
	)
	SELECT Data.SportType
		,Data.BetType
		,Data.IsLive
		,Data.SettingType
		,Data.IsDefault
		,Data.CopyFromSportType
		,Data.CopyFromBetType
		,Data.DefaultValueSuper
		,Data.DefaultValueMaster
		,Data.DefaultValueAgent
		,Data.DefaultValueMember
		,Data.SpecialRequirement
		,tp.SettingName
	FROM Initial_ProductConfig_Detail Data WITH(NOLOCK)
		INNER JOIN ProductSettingType tp WITH(NOLOCK) ON data.SettingType = tp.SettingType
	WHERE data.ConfigID = @ConfigID
	
	UPDATE t
	SET t.ProductID = p.ProductID
	FROM #TempConfig t WITH(NOLOCK)
		INNER JOIN ProductSettingProfile p WITH(NOLOCK) 
			ON t.SportType = p.SportType AND t.BetType = p.BetType

	UPDATE t
	SET t.CopyFrom_ProductID = p.ProductID
	FROM #TempConfig t WITH(NOLOCK)
		INNER JOIN ProductSettingProfile p WITH(NOLOCK) 
			ON t.CopyFromSportType = p.SportType AND t.CopyFromBetType = p.BetType
		
	IF @Currency <> '20'
	BEGIN
		UPDATE u
		SET u.BeginTime = @CurrentDTS
		FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
			LEFT JOIN ProductSettingType st WITH(NOLOCK)
				ON u.SettingType = st.SettingType
			CROSS APPLY (	SELECT TOP 1 t.SportType
							FROM #TempConfig t 
							WHERE u.SportType IN (t.CopyFromSportType,t.SportType,0)
								AND u.BetType IN (t.CopyFromBetType,t.BetType,0)
								AND (st.SettingName = t.SettingName OR u.SettingType = 0)
								AND u.ProductID IN( t.ProductID,t.CopyFrom_ProductID)
				) tmp
		WHERE u.FunctionType = 1
			AND u.EndTime >= @CurrentDTS
			AND u.BeginTime >= @CurrentDTS
			AND u.SuperID = 0

		UPDATE u
		SET u.BeginTime = @CurrentDTS
		FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
		WHERE u.FunctionType = 2
			AND u.EndTime >= @CurrentDTS
			AND u.BeginTime >= @CurrentDTS
			AND u.SuperID = 0
	END
	ELSE --@Currency = 20
	BEGIN
		UPDATE u
		SET u.BeginTime = @CurrentDTS
		FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
			LEFT JOIN ProductSettingType st WITH(NOLOCK)
				ON u.SettingType = st.SettingType
			CROSS APPLY (	SELECT TOP 1 t.SportType
							FROM #TempConfig t 
							WHERE u.SportType IN (t.CopyFromSportType,t.SportType,0)
								AND u.BetType IN (t.CopyFromBetType,t.BetType,0)
								AND (st.SettingName = t.SettingName OR u.SettingType = 0)
								AND u.ProductID IN( t.ProductID,t.CopyFrom_ProductID)
				) tmp
		WHERE u.FunctionType = 1
			AND u.EndTime >= @CurrentDTS
			AND u.BeginTime >= @CurrentDTS
			AND u.SuperID = 0
			AND u.Currency = 20

		UPDATE u
		SET u.BeginTime = @CurrentDTS
		FROM UMConfig u WITH(ROWLOCK,UPDLOCK)
		WHERE u.FunctionType = 2
			AND u.EndTime >= @CurrentDTS
			AND u.BeginTime >= @CurrentDTS
			AND u.SuperID = 0
			AND u.Currency = 20
	END


END
