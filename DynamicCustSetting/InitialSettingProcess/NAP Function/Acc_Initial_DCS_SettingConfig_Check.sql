/*<info serverAlias="DBCUST-CUSTDB" executers="bodbadminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfig_Check]
	@ProductID TINYINT,
	@SportTypeList VARCHAR(MAX), 
	@BetTypeList VARCHAR(MAX),
	@Site VARCHAR(MAX),
	@Currency VARCHAR(MAX),
	@StartTime DATETIME,
	@IsTest	BIT,
	@XMLConfig VARCHAR(MAX) = '',
	@ConfigID INT = NULL,
	@IsWarning BIT = 0 OUTPUT,
	@IsConfirmed BIT = 0
AS
/*
	Created: 20211011@Eden
	Task : Validate when insert update Initial Setting config
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 

	Parameter Definition

	Example: 
		DECLARE @IsWarning BIT = 0
		EXEC [Acc_Initial_DCS_SettingConfig_Check] 
			@ProductID		= 88,
			@SportTypeList = '888,998,211,234',
			@BetTypeList = '8888,9998,2401,3401',
			@Site = '1,3',
			@Currency = '20,72,1,2,3',
			@StartTime = '2021-07-15 10:00:00.000',
			@IsTest = 0,
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
			,@ConfigID = 1
			,@IsWarning = @IsWarning OUT
		SELECT @IsWarning

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrType VARCHAR(MAX) = ''

	DECLARE @SporttypeTbl TABLE(SportType SMALLINT)
	DECLARE @BettypeTbl TABLE(BetType SMALLINT)
	DECLARE @TBL_site TABLE(SiteID INT,Site VARCHAR(10) PRIMARY KEY)
	DECLARE @TBL_Currency TABLE(Currency INT PRIMARY KEY)

	DECLARE @DocHandler INT	
	IF ISNULL(@XMLConfig,'') <> ''
	BEGIN
		-- For read xml					
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @XMLConfig
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
			,ID
		)
		SELECT Data.SportType
			,Data.BetType
			,ISNULL(Data.IsLive,0)
			,Data.SettingType
			,Data.IsDefault
			,Data.CopyFromSportType
			,Data.CopyFromBetType
			,Data.DefaultValueSuper
			,Data.DefaultValueMaster
			,Data.DefaultValueAgent
			,Data.DefaultValueMember
			,Data.SpecialRequirement
			,Data.ID
		FROM OPENXML (@DocHandler, '/ROOT/R',1) 
		WITH (
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
			[ID] [INT]
		) AS Data

		EXEC sp_xml_removedocument @DocHandler
		-- end read xml	
	END	

	INSERT INTO @SporttypeTbl(SportType)
	SELECT value 
	FROM STRING_SPLIT(@SportTypeList,',') t
	WHERE value <> ''

	INSERT INTO @BettypeTbl(BetType)
	SELECT value 
	FROM STRING_SPLIT(@BetTypeList,',') t
	WHERE value <> ''

	--> Wrong Config
	IF EXISTS(	SELECT 1 
				FROM #TempConfig t
					LEFT JOIN @SporttypeTbl sp
						ON t.SportType = sp.SportType
				WHERE sp.SportType IS NULL
			) 
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 101
			,ErrMsg = 'Wrong sporttype(s): '
		FROM #TempConfig t
			LEFT JOIN @SporttypeTbl sp
				ON t.SportType = sp.SportType
		WHERE sp.SportType IS NULL

		RETURN
	END

	--> Wrong Config
	IF EXISTS(	SELECT 1 
				FROM #TempConfig t
					LEFT JOIN @BettypeTbl sp
						ON t.BetType = sp.BetType
				WHERE sp.BetType IS NULL
			) 
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 102
			,ErrMsg = 'Wrong bettype(s): '
		FROM #TempConfig t
			LEFT JOIN @BettypeTbl sp
				ON t.BetType = sp.BetType
		WHERE sp.BetType IS NULL

		RETURN
	END

	--> Sporttype(s) do not have any config
	SET @ErrType = ''

	SELECT @ErrType =  @ErrType + ', ' + ISNULL(s.SportName,'Sporttype ' + CONVERT(VARCHAR,sp.SportType))
	FROM @SporttypeTbl sp
		LEFT JOIN DBACC.bodb02.dbo.Sports S WITH(NOLOCK) 
			ON sp.SportType = s.SportType
		LEFT JOIN #TempConfig t
			ON t.SportType = sp.SportType
	WHERE t.SportType IS NULL

	IF @ErrType <> ''
	BEGIN
		INSERT INTO #ErrorTbl(ErrorCode,ErrorMsg)
		SELECT ErrCode = 103
			,ErrMsg = 'Sport Type(s) ' + STUFF(@ErrType,1,2,'')+ ' have not been configured. Please config it or remove them.'

		RETURN
	END

	--> Bettype(s) do not have any config
	SET @ErrType = ''

	SELECT @ErrType =  @ErrType + ', ' + CONVERT(VARCHAR,sp.bettype) + '(' + ISNULL(s.typenamee,'Bettype ' + CONVERT(VARCHAR,sp.bettype)) + ')'
	FROM @BettypeTbl sp
		LEFT JOIN DBACC.bodb02.dbo.Bettype S WITH(NOLOCK) 
			ON sp.bettype = s.typeid
		LEFT JOIN #TempConfig t
			ON t.bettype = sp.bettype
	WHERE t.bettype IS NULL

	IF @ErrType <> ''
	BEGIN
		INSERT INTO #ErrorTbl(ErrorCode,ErrorMsg)
		SELECT ErrCode = 104
			,ErrMsg = 'Bettype(s) ' + STUFF(@ErrType,1,2,'')+ ' have not been configured. Please config it or remove them.'

		RETURN
	END

	UPDATE t
	SET t.SettingName = pt.SettingName
	FROM #TempConfig t
		INNER JOIN ProductSettingType pt WITH(NOLOCK)
			ON t.SettingType = pt.SettingType

	--> Invalid Setting Type ID
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.SettingName IS NULL
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 1
			,ErrMsg = 'Invalid Setting Type ID(s): '
		FROM #TempConfig t
		WHERE t.SettingName IS NULL

		RETURN
	END

	--> Wrong Config
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
					LEFT JOIN ProductSettingDetail dt WITH(NOLOCK)
						ON t.SportType = dt.SportType
						AND t.BetType= dt.BetType
						AND t.IsLive = dt.IsLive
						AND t.SettingType = dt.SettingType
				WHERE dt.SportType IS NULL
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 2
			,ErrMsg = 'Wrong Config(s): '
		FROM #TempConfig t
			LEFT JOIN ProductSettingDetail dt WITH(NOLOCK)
				ON t.SportType = dt.SportType
				AND t.BetType= dt.BetType
				AND t.IsLive = dt.IsLive
				AND t.SettingType = dt.SettingType
		WHERE dt.SportType IS NULL

		RETURN
	END

	--> Wrong Config
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.IsDefault = 1
					AND (t.CopyFromBetType IS NOT NULL OR t.CopyFromBetType IS NOT NULL)
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 2
			,ErrMsg = 'Wrong Config(s): '
		FROM #TempConfig t
		WHERE t.IsDefault = 1
			AND (t.CopyFromBetType IS NOT NULL OR t.CopyFromBetType IS NOT NULL)

		RETURN
	END

	--> Wrong Config
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.IsDefault = 0
					AND (t.CopyFromBetType IS NULL OR t.CopyFromBetType IS NULL)
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 2
			,ErrMsg = 'Wrong Config(s): '
		FROM #TempConfig t
		WHERE t.IsDefault = 0
			AND (t.CopyFromBetType IS NULL OR t.CopyFromBetType IS NULL)

		RETURN
	END

	--> Wrong Config
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.IsDefault = 0
					AND (t.DefaultValueMember IS NOT NULL 
						OR t.DefaultValueAgent IS NOT NULL 
						OR t.DefaultValueMaster IS NOT NULL 
						OR t.DefaultValueSuper IS NOT NULL
						)
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 2
			,ErrMsg = 'Wrong Config(s): '
		FROM #TempConfig t
		WHERE t.IsDefault = 0
			AND (t.DefaultValueMember IS NOT NULL 
				OR t.DefaultValueAgent IS NOT NULL 
				OR t.DefaultValueMaster IS NOT NULL 
				OR t.DefaultValueSuper IS NOT NULL
				)

		RETURN
	END

	--> The setting type(s) do not have default option
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.IsDefault = 1
					AND SettingName IN ('Position Taking','Bet Setting')
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 3
			,ErrMsg = 'The setting type(s) do not have default option: '
		FROM #TempConfig t
				WHERE t.IsDefault = 1
					AND SettingName IN ('Position Taking','Bet Setting')

		RETURN
	END

	--> The setting type(s) do not have copy from option
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
				WHERE t.IsDefault = 0
					AND SettingName = 'Stake Level'
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 4
			,ErrMsg = 'The setting type(s) do not have copy from option: '
		FROM #TempConfig t
		WHERE t.IsDefault = 0
			AND SettingName = 'Stake Level'

		RETURN
	END

	--> The source sporttype/bettype/setting type(s) do not belong with the destination(s)
	IF EXISTS(	SELECT 1
				FROM #TempConfig t
					OUTER APPLY(	SELECT TOP(1) p.SettingType
									FROM ProductSettingType p WITH(NOLOCK) 
										INNER JOIN ProductSettingDetail d WITH(NOLOCK) 
											ON d.SettingType = p.SettingType
									WHERE p.SettingName = t.SettingName
										AND t.CopyFromSportType = d.SportType 
										AND t.CopyFromBetType = d.BetType
						) pd
				WHERE t.IsDefault = 0	
					AND pd.SettingType IS NULL
				)
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT t.ID
			,ErrCode = 5
			,ErrMsg = 'The source sporttype/bettype/setting type(s) do not belong with the destination(s): '
		FROM #TempConfig t
			OUTER APPLY(	SELECT TOP(1) p.SettingType
							FROM ProductSettingType p WITH(NOLOCK) 
								INNER JOIN ProductSettingDetail d WITH(NOLOCK) 
									ON d.SettingType = p.SettingType
							WHERE p.SettingName = t.SettingName
								AND t.CopyFromSportType = d.SportType 
								AND t.CopyFromBetType = d.BetType
				) pd
		WHERE t.IsDefault = 0	
			AND pd.SettingType IS NULL

		RETURN
	END
	
	----------Validate disable Headline by default-----------------
	--> Get List of Site/Currency by config
	INSERT INTO @TBL_site(SiteID,Site)
	SELECT DISTINCT s.siteid, s.site
	FROM Site s WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Site,',') t ON s.siteid = t.value OR @Site = '0'
	WHERE s.isActive = 1
		AND s.isLicensee = 0
		AND s.siteid NOT IN (329)--CN88

	INSERT INTO @TBL_Currency(Currency)
	SELECT DISTINCT e.ExchangeId
	FROM exchange e WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Currency,',') t ON e.ExchangeId = t.value OR @Currency = '0'
	WHERE e.IsActive = 1

	DECLARE @TempConfig_Status TABLE (ID INT, SpecialRequirement VARCHAR(MAX), IsFinished BIT DEFAULT 0)
	INSERT INTO @TempConfig_Status(ID,SpecialRequirement)
	SELECT t.ID, t.SpecialRequirement
	FROM #TempConfig t
	WHERE t.SettingName= 'Product Status'
			AND ISNULL(t.SpecialRequirement,'') <> ''
	
	DECLARE @SpecialRequirement VARCHAR(MAX), @ID INT
	DECLARE @tmpHeadline TABLE( Username varchar(30))

	WHILE 1 = 1
	BEGIN
		UPDATE TOP (1) t
		SET t.IsFinished = 1,
			@ID = t.ID,
			@SpecialRequirement = t.SpecialRequirement
		FROM @TempConfig_Status t 
		WHERE t.IsFinished = 0

		IF @@ROWCOUNT = 0
			BREAK

		SET @ErrType = ''

		INSERT INTO @tmpHeadline(Username)
		SELECT hl.value
		FROM STRING_SPLIT(@SpecialRequirement,',') hl
		WHERE value <> ''

		SELECT @ErrType =  @ErrType + ', ' + hl.Username
		FROM @tmpHeadline hl
			LEFT JOIN customer ci WITH(NOLOCK) ON hl.Username = ci.username
			LEFT JOIN CustGroupHeadline g WITH(NOLOCK) ON ci.custid = g.CustID
		WHERE (g.CustID IS NULL )

		IF @ErrType <> ''
		BEGIN
			INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
			SELECT @ID
				,ErrCode = 201
				,ErrMsg = 'Invalid headline(s): ' + STUFF(@ErrType,1,2,'') + '. Please check them again.'
		END

		DELETE FROM @tmpHeadline
	END

	IF EXISTS( SELECT 1 FROM #ErrorTbl)
	BEGIN
		RETURN
	END
	----------Validate Starttime-----------------------------
	IF EXISTS( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE StartTime = @StartTime AND ConfigID <> ISNULL(@ConfigID,0))
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT NULL
			,ErrCode = 202
			,ErrMsg = 'There already exists a row with the same time, please choose another time again.'

		RETURN
	END

	----------Validate duplicate config-----------------------------
	DECLARE @ExistingConfig TABLE( ConfigID INT PRIMARY KEY)
	DECLARE @TmpStatus TINYINT
	SET @IsWarning = 0

	INSERT INTO @ExistingConfig(ConfigID)
	SELECT DISTINCT d.ConfigID
	FROM Initial_ProductConfig_Detail d WITH(NOLOCK)
		INNER JOIN #TempConfig t 
			ON t.SportType = d.SportType
			AND t.BetType = d.BetType
			AND t.SettingType = d.SettingType
			AND ConfigID <> ISNULL(@ConfigID,0)

	IF EXISTS( SELECT 1 FROM @ExistingConfig)
	BEGIN
			SELECT TOP(1) @TmpStatus = cf.Status
			FROM Initial_ProductConfig cf WITH(NOLOCK)
				INNER JOIN @ExistingConfig t ON cf.ConfigID = t.ConfigID
				CROSS APPLY STRING_SPLIT(cf.Site,',') s 
				INNER JOIN @TBL_site ts ON s.value = ts.SiteID OR cf.Site = '0'
				CROSS APPLY STRING_SPLIT(cf.Currency,',') cr 
				INNER JOIN @TBL_Currency tcr ON cr.value = tcr.Currency OR cf.Currency = '0'
			ORDER BY cf.Status
			OPTION (MAXRECURSION 0)

			IF @TmpStatus IN (0,1) --Planned, Running
			BEGIN
				INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
				SELECT NULL
					,ErrCode = 203
					,ErrMsg = 'This product with the same Site, Currency, Sport, Bet Type, Setting Type already exists. Please change them again.'

				RETURN
			END
			ELSE IF @IsConfirmed = 0 AND @TmpStatus = 2 -- completed
			BEGIN
				SET @IsWarning = 1
			END
	END 
	----------------------------------------------------------------
	IF ISNULL(@site,'') = '' 
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT NULL
			,ErrCode = 204
			,ErrMsg = 'Site cannot be null.'

		RETURN
	END

	IF ISNULL(@Currency,'') = '' 
	BEGIN
		INSERT INTO #ErrorTbl(ID,ErrorCode,ErrorMsg)
		SELECT NULL
			,ErrCode = 205
			,ErrMsg = 'Currency cannot be null.'

		RETURN
	END


	--Generate Headline Usernames to CustID
	UPDATE t
	SET SpecialRequirement =  STUFF(
									REPLACE(
										REPLACE((	SELECT c.custid AS 'XMLHeadlineList'
													FROM STRING_SPLIT(t.SpecialRequirement,',') t
														INNER JOIN CustInfo c(NOLOCK) ON t.value = c.username
													ORDER BY c.custid
													FOR XML PATH('')
											),'<XMLHeadlineList>',','),'</XMLHeadlineList>', ''),1,1,'')
	FROM #TempConfig t
	WHERE t.SettingName = 'Product Status'
		AND ISNULL(t.SpecialRequirement,'') <> ''
	OPTION (MAXRECURSION 0)

END
GO


