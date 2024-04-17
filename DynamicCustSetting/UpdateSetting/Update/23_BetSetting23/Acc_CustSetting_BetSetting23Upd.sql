/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting23Upd] 
	  @CustID		INT
	, @BetLimit		VARCHAR(MAX)
	, @SubAccID		INT				= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
	, @SystemID		INT = 1 
	, @Language		VARCHAR(2) = 'E'
	, @isSearchAndCopy	BIT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(200)	= ''	OUTPUT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20221123@Elodie
	Task : Update Customer's Bet Limits
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		
	Param's Explanation:
	- @BetLimit:
		<ROOT>
				<BetLimit SportType="161" BetType="81" MinBet="1" MaxBet="30000" MaxPerMatch="1000000" MaxPerNumber = "30000"/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @CustList	VARCHAR(MAX) = ''

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

	DECLARE @AgentID			INT
		, @MasterID				INT
		, @SuperID				INT
		, @RoleID				INT

	DECLARE @OldBetLimitTbl TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, MinBet			MONEY
		, MaxBet			MONEY
		, MaxPerMatch		MONEY
		, MaxPerNumber		MONEY 
		, Child_DisplayOrder TINYINT
		)
	DECLARE @NewBetLimitTbl TABLE (
		  SportType			SMALLINT
		, BetType			SMALLINT
		, SubType			TINYINT
		, MinBet			MONEY
		, MaxBet			MONEY
		, MaxPerMatch		MONEY
		, MaxPerNumber		MONEY 
		, IsSpecial			BIT DEFAULT 0
		, RealProductID		TINYINT
		, Child_DisplayOrder TINYINT
		)

	DECLARE @HistoryBetSettingTbl TABLE (
		  CustID				INT
		, SportType			SMALLINT
		, BetType			SMALLINT
		, MaxBet			MONEY
		, MaxPerMatch		MONEY
		, UpdateTime		DATETIME
		)
	CREATE TABLE #ProductSettingDetail(
		SettingType SMALLINT,
		SportType SMALLINT,
		BetType SMALLINT,
		SubType TINYINT,
		IsLive BIT ,
		ProductID TINYINT,
		SettingLevel TINYINT,
		RealProductID TINYINT,
		Child_DisplayOrder TINYINT
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	--Check if XML is null or empty
	IF @BetLimit IS NULL OR @BetLimit = ''
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
		,@UserName = username
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
	
	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @BetLimit

	INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch,MaxPerNumber)
	SELECT SportType, BetType, MinBet, MaxBet, MaxPerMatch
		, MaxPerNumber = CASE WHEN SportType = 161 THEN MaxPerNumber END
	FROM OPENXML(@iDoc, '/ROOT/BetLimit', 1) WITH (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
			, MaxPerNumber	MONEY 
			)
	
	EXEC sp_xml_removedocument @iDoc

	INSERT INTO #ProductSettingDetail(SportType,BetType,SubType,SettingType,IsLive,ProductID,SettingLevel,RealProductID,Child_DisplayOrder)
	SELECT SportType,BetType,SubType,SettingType,IsLive,ProductID,SettingLevel,RealProductID,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	WHERE SettingType = 23

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetLimitTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 23
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @NewBetLimitTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	UPDATE bl
	SET bl.RealProductID = pd.RealProductId,
		bl.SubType = pd.SubType,
		bl.Child_DisplayOrder = pd.Child_DisplayOrder
	FROM @NewBetLimitTbl bl
		INNER JOIN #ProductSettingDetail pd WITH (NOLOCK) ON bl.SportType = pd.SportType AND bl.BetType = pd.BetType

	--Validate new bet settings
	EXEC [dbo].Acc_CustSetting_BetSetting23Check 
		  @CustID		= @CustID
		, @BetLimit		= @BetLimit
		, @SystemID		= @SystemID
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT
		, @SettingStatus = @SettingStatus

	IF @ErrCode <> 0
		RETURN

	--Get current Setting
	IF @RoleID > 1
	BEGIN
		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,NULL
		FROM CustBetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid AND b.SubType = 1

		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPerNumber
		FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid AND b.SubType = 2
	END
	ELSE
	BEGIN
		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,NULL
		FROM CustBetSetting3rd_Member cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid AND b.SubType = 1

		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPerNumber
		FROM CustBetSetting_Member cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid AND b.SubType = 2
	END

	IF NOT EXISTS(
		SELECT TOP 1 1
		FROM @NewBetLimitTbl t
			INNER JOIN @OldBetLimitTbl old
				ON t.SportType = old.SportType AND t.BetType = old.BetType
		WHERE (	ISNULL(t.MinBet,0)  <>  ISNULL(old.MinBet,0)
					OR ISNULL(t.MaxBet,0)  <>  ISNULL(old.MaxBet,0)
					OR ISNULL(t.MaxPerMatch,0)  <>  ISNULL(old.MaxPerMatch,0)
					OR ISNULL(t.MaxPerNumber,0)  <>  ISNULL(old.MaxPerNumber,0)
				)
	)
	BEGIN
		PRINT 'Unchanged'
		RETURN
	END

	DECLARE @BetSettingXML VARCHAR(MAX)  = '', @IsAffected BIT = 0, @IsAffected_DCS BIT = 0

	IF @RoleID > 1
	BEGIN
		-- Set IsSpecial = 1 --> not affect to downline
		UPDATE t
		SET t.IsSpecial = 1
		FROM @NewBetLimitTbl t
		WHERE ISNULL(t.MinBet,0) = 0 
			AND ISNULL(t.MaxBet,0) = 0 
			AND ISNULL(t.MaxPerMatch,0) = 0 
			AND ISNULL(t.MaxPerNumber,0) = 0 

		SELECT @BetSettingXML = CONVERT( VARCHAR(MAX), 
							(	
								SELECT  SportType			AS	'@SportType'		
										,BetType 			AS	'@BetType' 
										,MinBet 			AS	'@MinBet'
										,MaxBet 			AS	'@MaxBet' 
										,MaxPerMatch 		AS	'@MaxPerMatch' 
										,MaxPerNumber 		AS	'@MaxPerNumber' 
								FROM @NewBetLimitTbl
								WHERE IsSpecial = 0
								FOR XML PATH('Row'), ROOT ('Root'), TYPE)
							)

		--Check affected downline
		EXEC [Acc_CustomerUpd_BetSetting_Checkdownline]
			@custid = @custid,
			@RoleID = @RoleID,
			@BetSettingXML = @BetSettingXML,
			@SettingType = 23,
			@IsAffected = @IsAffected OUTPUT,
			@IsAffected_DCS = @IsAffected_DCS OUTPUT

		IF @IsAffected = 1 OR @IsAffected_DCS = 1
		BEGIN
			--Check Allowed downlines	
			EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
				@custid		= @custid
			,	@roleid		= @roleid
			,	@isExecRep	= 1
			,	@Language	= @Language
			,	@ErrCode	= @ErrCode	OUTPUT
			,	@ErrMsg		= @ErrMsg	OUTPUT

			IF @ErrCode > 0
			BEGIN
				RETURN
			END
		END

		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MinBet = t.MinBet
		FROM @NewBetLimitTbl t
			INNER JOIN CustBetSetting3rd_Agent a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid AND t.SubType = 1

		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPerNumber = t.MaxPerNumber,
			a.MinBet = t.MinBet
		FROM @NewBetLimitTbl t
			INNER JOIN CustBetSetting_Agent a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid AND t.SubType = 2
	END
	ELSE IF @RoleID = 1
	BEGIN
		IF @isSearchAndCopy=1
		BEGIN
			SELECT @BetLimit = CONVERT( VARCHAR(MAX), 
							(	
								SELECT   SportType			AS	'@SportType'		
										,BetType 			AS	'@BetType' 
										,MinBet 			AS	'@MinBet'
										,MaxBet 			AS	'@MaxBet' 
										,MaxPerMatch 		AS	'@MaxPerMatch' 
										,MaxPerNumber 		AS	'@MaxPerNumber' 
										,SubType 			AS	'@SubType'
								FROM @NewBetLimitTbl
								FOR XML PATH('BetLimit'), ROOT ('ROOT'), TYPE)
							)

			EXECUTE Acc_DynamicCustomerInfo_01
						@CustID=@CustID,
						@SettingList=@BetLimit,
						@SettingType=23
		END
		ELSE
		BEGIN
			--Update setting
			UPDATE a
			SET a.MaxBet = t.MaxBet,
				a.MaxPerMatch = t.MaxPerMatch,
				a.MinBet = t.MinBet
			OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
			INTO @HistoryBetSettingTbl(CustID, SportType, BetType, MaxBet, MaxPerMatch, UpdateTime)
			FROM @NewBetLimitTbl t
				INNER JOIN CustBetSetting3rd_Member a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
			WHERE a.CustID = @custid AND t.SubType = 1

			UPDATE a
			SET a.MaxBet = t.MaxBet,
				a.MaxPerMatch = t.MaxPerMatch,
				a.MaxPerNumber = t.MaxPerNumber,
				a.MinBet = t.MinBet
			OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
			INTO @HistoryBetSettingTbl(CustID, SportType, BetType, MaxBet, MaxPerMatch, UpdateTime)
			FROM @NewBetLimitTbl t
				INNER JOIN CustBetSetting_Member a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
			WHERE a.CustID = @custid AND t.SubType = 2

			--Insert history bet setting
			DELETE hbs
			FROM @HistoryBetSettingTbl hbs
				INNER JOIN @NewBetLimitTbl bs ON bs.SportType=hbs.SportType AND bs.BetType=hbs.BetType
			WHERE (bs.MaxBet=hbs.MaxBet AND bs.MaxPerMatch=hbs.MaxPerMatch)

			IF EXISTS (SELECT 1 FROM @HistoryBetSettingTbl)
			BEGIN
				SET @CustList = (SELECT CustID		AS '@CustID',
										SportType	AS '@SportType',
										BetType		AS '@BetType',
										MaxBet		AS '@MaxBet',
										MaxPerMatch	AS '@MaxPerMatch',
										'NULL'		AS '@StakeLevelList',
										UpdateTime	AS '@UpdateTime'
								 FROM @HistoryBetSettingTbl
								 FOR XML PATH ('r'), ROOT ('root')
								 )

				EXECUTE Acc_DynamicCustSetting3rd_08 @CustList=@CustList, @ErrMsg = @ErrMsg OUTPUT;

				IF @ErrMsg <> ''
					RETURN
			END
		END
	END

	IF (@@ERROR <> 0)
	BEGIN
	
		SELECT @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115	
		RETURN
	END

	DECLARE @Notify_agents TABLE ( CustID INT, Isfinished BIT default 0)

	IF @RoleID = 2
	BEGIN
		INSERT INTO @Notify_agents(CustID) 
		SELECT @custid
	END

	IF @RoleID > 1 AND (@IsAffected = 1 OR @IsAffected_DCS = 1)
	BEGIN
		IF EXISTS (SELECT 1 FROM @NewBetLimitTbl WHERE RealProductID = 3) 
			AND @IsAffected = 1
		BEGIN
			--> Generate affected Agents to send notify message
			IF @RoleID = 4
			BEGIN			
				INSERT INTO @Notify_agents(CustID)
				SELECT c.custid
				FROM @NewBetLimitTbl t
					INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
						ON t.SportType = a.SportType AND t.BetType = a.BetType
					INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
				WHERE c.srecommend = @custid
					AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
							OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
					AND c.roleid = 2
					AND t.IsSpecial = 0
					AND c.enabled = 1
					AND t.SubType = 2
					AND t.RealProductID = 3
			END
			ELSE IF @RoleID = 3
			BEGIN				
				INSERT INTO @Notify_agents(CustID)
				SELECT c.custid
				FROM @NewBetLimitTbl t
					INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
						ON t.SportType = a.SportType AND t.BetType = a.BetType
					INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
				WHERE c.mrecommend = @custid
					AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
							OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
					AND c.roleid = 2
					AND t.IsSpecial = 0
					AND c.enabled = 1
					AND t.SubType = 2
					AND t.RealProductID = 3
			END
		END

		IF @IsAffected_DCS = 1 -- Correct downline (subtype = 1)
		BEGIN
			SET	@BetSettingXML =	(
								SELECT	SportType,			
										BetType,			
										MinBet,
										MaxBet,
										MaxPerMatch
								FROM	@NewBetLimitTbl
								WHERE IsSpecial = 0
									AND Subtype = 1
								FOR XML RAW ('BetLimit'), ROOT ('ROOT') 
							)
				
			-- Correct downlines via ExecRep
			EXECUTE	Acc_DynamicCustSetting3rd_02
						@CustID		= @CustID,
						@RoleID		= @RoleID,
						@BetLimit	= @BetSettingXML,
						@Mode		= 'BetSetting'
		END

		IF @IsAffected = 1 -- Correct downline (subtype = 2)
		BEGIN
			SELECT @BetSettingXML = CONVERT( VARCHAR(MAX), 
								(	
									SELECT  SportType			AS	'@SportType'		
											,BetType 			AS	'@BetType' 
											,MinBet 			AS	'@MinBet'
											,MaxBet 			AS	'@MaxBet' 
											,MaxPerMatch 		AS	'@MaxPerMatch' 
											,MaxPerNumber 		AS	'@MaxPerNumber' 
									FROM @NewBetLimitTbl
									WHERE IsSpecial = 0
										AND Subtype = 2
									FOR XML PATH('Row'), ROOT ('Root'), TYPE)
								)

			--Update Downline
			EXEC dbo.Acc_CustSetting_12
				 @CustId = @CustId
				,@RoleId = @RoleId
				,@XML = @BetSettingXML
				,@Mode='SB_BetSetting'
		END
	END

	IF EXISTS (SELECT 1 FROM @Notify_agents)
	BEGIN
		--Insert notify message
		DECLARE @Notify_AgentID INT

		WHILE (1=1)
		BEGIN
			UPDATE TOP (1) @Notify_agents
			SET IsFinished = 1, 
				@Notify_AgentID = custid
			WHERE IsFinished = 0

			IF @@ROWCOUNT = 0 BREAK
		
			EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @Notify_AgentID, @userID = @UserID, @TypeID = 2
		END
	END
	--START LOGGING

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		#ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewBetLimitTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 23	-- Bet Limit
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

	DECLARE @SPName varchar(100) = 'Acc_CustSetting_BetSetting23Upd'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)

	INSERT INTO @LogAction (ActionID)
	SELECT 220034 UNION ALL
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID IS NULL AND ld.Level = @RoleID

	UPDATE bl
	SET bl.Child_DisplayOrder = pd.Child_DisplayOrder
	FROM @OldBetLimitTbl bl
		INNER JOIN #ProductSettingDetail pd WITH (NOLOCK) ON bl.SportType = pd.SportType AND bl.BetType = pd.BetType

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
					SELECT	@ProductID							AS '@ProductID',
							CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
							CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
							CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
							CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl
					ORDER BY Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
				)
		FOR XML PATH('R'),
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
		
		IF @ActionID = 220034
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
		END
		ELSE IF (@IsAffected = 1 OR @IsAffected_DCS = 1) AND @RoleID <> 1
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