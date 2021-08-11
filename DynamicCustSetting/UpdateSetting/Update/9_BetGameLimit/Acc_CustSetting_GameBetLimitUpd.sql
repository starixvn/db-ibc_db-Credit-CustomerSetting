/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetLimitUpd] 
	  @CustID		INT
	, @GameBetLimit	VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
	, @SystemID     TINYINT = 1 --20200305@Tiara
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160801@Elodie
	Task : Update Customer's Game Bet Limits
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20160801@Elodie: Initial SP
		- 20200305@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20200708@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20210727@Elodie: Adjust downline's betsetting [Redmine: #158073]
	Param's Explanation:
	• @GameBetLimit:
		<ROOT>
				<GameBetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
						MaxPerNumber="1000000"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))
	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		, @ActionID		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @logSpData_Indirectly	NVARCHAR(MAX)
		, @logSpData_Old_Indirectly	NVARCHAR(MAX)
		, @xml				XML
		, @UserName			NVARCHAR(50)
		
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT
		, @IsAdjustDownline	BIT = 0

	DECLARE @OldBetLimitTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, MinBet			MONEY
		, MaxBet			MONEY
		, MaxPerNumber		MONEY
		)
	DECLARE @NewBetLimitTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, MinBet			MONEY
		, MaxBet			MONEY
		, MaxPerNumber		MONEY
		)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	--Check if XML is null or empty
	IF @GameBetLimit IS NULL
		OR @GameBetLimit = ''
		RETURN

	SET @startRun = GETDATE()

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		, @UserName = username
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Check belonging
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END
	
	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
												@custid		= @custid
											,	@roleid		= @roleid
											,	@isExecRep	= 1
											,	@Language	= 'E'
											,	@ErrCode	= @ErrCode	OUTPUT
											,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @GameBetLimit

	INSERT @NewBetLimitTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/GameBetLimit', 1) WITH (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerNumber	MONEY
			)

	EXEC sp_xml_removedocument @iDoc

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetLimitTbl t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 9
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @NewBetLimitTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	--Validate new bet settings
	EXEC [dbo].[Acc_CustSetting_GameBetLimitCheck] @CustID	= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @GameBetLimit	= @GameBetLimit
						, @SystemID		= @SystemID
						, @ProductID    = @ProductID
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType  OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	IF @RoleID = 1
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Member bl WITH (NOLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxPerNumber
		FROM dbo.CustBetSetting3rd_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxPerNumber
				)
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID

		--update new settings
		UPDATE main
		SET main.minbet			= tmp.MinBet
			, main.maxbet		= tmp.MaxBet
			, main.maxpermatch	= tmp.MaxPerNumber
		FROM dbo.CustBetSetting3rd_Agent main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.minbet		<> tmp.MinBet
				OR main.maxbet		<> tmp.MaxBet
				OR main.maxpermatch <> tmp.MaxPerNumber
				)
		
		IF EXISTS (SELECT 1
					FROM dbo.CustBetSetting3rd_Agent bsm WITH(NOLOCK)
						INNER JOIN @NewBetLimitTbl fil ON bsm.sporttype = fil.sporttype AND bsm.bettype = fil.bettype
						INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON bsm.custid = ci.custid
															AND ((@RoleID = 4 AND ci.srecommend = @CustID AND ci.roleid = 3)
															OR (@RoleID = 3 AND ci.mrecommend = @CustID AND ci.roleid = 2)
															OR (@RoleID = 2 AND ci.recommend = @CustID AND ci.roleid = 1))
					WHERE NOT (fil.MinBet = 0 AND fil.MaxBet = 0 AND fil.MaxPerNumber = 0)
						AND (bsm.MaxBet > fil.MaxBet OR bsm.MaxPerMatch > fil.MaxPerNumber
							OR (fil.MinBet = 0 AND fil.MaxBet < 1 AND fil.MaxPerNumber < 1)))
			SELECT @IsAdjustDownline = 1

		
		IF @IsAdjustDownline = 1
		BEGIN
			--Updating upline to 0/0/0/0 does not count reducing Bet setting, downline's bet setting will not be changed.
			SET	@GameBetLimit =	(
								SELECT	SportType,			
										BetType,			
										MinBet,
										MaxBet,
										MaxPerNumber
								FROM	@NewBetLimitTbl
								WHERE NOT (MinBet = 0 AND MaxBet = 0 AND MaxPerNumber = 0)
								FOR XML RAW ('GameBetLimit'), ROOT ('ROOT') 
							)
					
			-- Correct downlines via ExecRep
			EXECUTE	Acc_DynamicCustSetting3rd_02
						@CustID		= @CustID,
						@RoleID		= @RoleID,
						@BetLimit	= @GameBetLimit,
						@Mode		= 'GameBetLimit'
		END
	END

	--START LOGGING

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewBetLimitTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 9	-- Bet Limit
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

	DECLARE @SPName varchar(100) = 'Acc_CustSetting_GameBetLimitUpd'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)

	INSERT INTO @LogAction (ActionID)
	SELECT 392 UNION ALL
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID IS NULL AND ld.Level = @RoleID

	-- Log old data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@ProductID								AS '@ProductID',
							CONVERT(DECIMAL(20,2), MinBet)			AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)			AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType								AS '@SportType',
							CONVERT(DECIMAL(20,2), MinBet)			AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)			AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	BetType								AS '@BetType',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	SET @logSpData_Old_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@ProductID							AS '@ProductID',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	BetType								AS '@BetType',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@UserName						AS '@SourceAccount',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					FOR XML PATH('GameBetLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_GameBetLimitUpd'),
		TYPE
	)
	END
	SET @logSpData_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old_Indirectly = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old_Indirectly)
	SELECT @logSpData_Indirectly = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Indirectly)

	SET @logSpData = REPLACE(@logSpData_Indirectly, 'SourceAccount="'+ @UserName +'"', '')
	SET @logSpData_Old = REPLACE(@logSpData_Old_Indirectly, 'SourceAccount="'+ @UserName +'"', '')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK
		
		IF @ActionID = 392
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
		END
		ELSE IF @IsAdjustDownline = 1
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @logSpData_Indirectly,
				@TrackingValue2 = @logSpData_Old_Indirectly,
				@duration = @duration	
		END
	END
END
GO
