ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetLimitUpd] 
	  @CustID		INT
	, @GameBetLimit	VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
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

	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		, @xml				XML
		
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT
		
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

	--Validate new bet settings
	EXEC [dbo].[Acc_CustSetting_GameBetLimitCheck] @CustID	= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @GameBetLimit	= @GameBetLimit
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

	-- Log old data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
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
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
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
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= @CustID
						, @ActionID			= 392
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
						, @CustID			= @CustID
						, @ActionID			= 392
						, @TrackingValue	= @logSpData
						, @TrackingValue2	= @logSpData_Old
						, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitUpd] TO [bodbExtAccNet]