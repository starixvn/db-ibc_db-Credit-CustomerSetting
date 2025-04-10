/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting_154_Upd] 
	  @CustID			INT
	, @BetLimit			VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)		= ''
	, @SystemID			INT = 1 
	, @Language			VARCHAR(2) = 'E'
	, @isSearchAndCopy	BIT				= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(1000)	= ''	OUTPUT
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 154
	, @GroupID			TINYINT = 2
AS
/*
	Created: 20240520@Eden
	Task : Update Customer's Bet Limits
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		- 20241205@Tacy: Capture old value - MaxPerNumber [RedmineId: #199571]

	Param's Explanation:
	- @BetLimit:
		[
			{"SportType": "169","BetType": "3611","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9919","BetType": "1501","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9908","BetType": "1201","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "161","BetType": "81","MinBet": "1","MaxBet": "10","MPM": "100","MaxPerNumber": "80"}
		]
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
		  CustID			INT
		, SportType			SMALLINT
		, BetType			SMALLINT
		, MaxBet			MONEY
		, MaxPerMatch		MONEY
		, MaxPerNumber		MONEY
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
	
	--Parse Json
	INSERT @NewBetLimitTbl (SportType, BetType, MinBet, MaxBet, MaxPerMatch,MaxPerNumber)
	SELECT SportType, BetType, MinBet, MaxBet, MaxPerMatch
		, MaxPerNumber = CASE WHEN SportType = 161 THEN MaxPerNumber END
	FROM OPENJSON(@BetLimit) WITH (
			SportType smallint  '$.SportType',
			BetType smallint  '$.BetType',
			MinBet MONEY  '$.MinBet',
			MaxBet MONEY  '$.MaxBet',
			MaxPerMatch MONEY  '$.MPM',
			MaxPerNumber MONEY  '$.MaxPerNumber'
		)

	DECLARE  @SiteID SMALLINT,
			@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	INSERT INTO #ProductSettingDetail(SportType,BetType,SubType,SettingType,IsLive,ProductID,SettingLevel,RealProductID,Child_DisplayOrder)
	SELECT SportType,BetType,SubType,SettingType,IsLive,ProductID,SettingLevel,RealProductID,Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetLimitTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

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
	EXEC [dbo].Acc_CustSetting_BetSetting_154_Check 
		  @CustID		= @CustID
		, @BetLimit		= @BetLimit
		, @SystemID		= @SystemID
		, @ErrCode		= @ErrCode	OUTPUT
		, @MsgType		= @MsgType  OUTPUT
		, @ErrMsg		= @ErrMsg	OUTPUT
		, @SettingStatus = @SettingStatus
		, @GroupType = @GroupType
		, @GroupID = @GroupID

	IF @ErrCode <> 0
		RETURN

	--Get current Setting
	IF @RoleID > 1
	BEGIN
		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch
			,CASE WHEN b.SubType = 2 THEN cb.MaxPerNumber END
		FROM BetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid
	END
	ELSE
	BEGIN
		INSERT INTO @OldBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch
			,CASE WHEN b.SubType = 2 THEN cb.MaxPerNumber END
		FROM BetSetting3rd_Member cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid
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

	DECLARE @BetSettingJson VARCHAR(MAX)  = '', @IsAffected_NG BIT = 0, @IsAffected_DCS BIT = 0

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

		SELECT @BetSettingJson = (
			SELECT SportType,BetType,MinBet,MaxBet,MaxPerMatch AS MPM,MaxPerNumber
			FROM @NewBetLimitTbl
			WHERE IsSpecial = 0
			FOR JSON PATH
		)

		--Check affected downline
		EXEC [Acc_BetSetting3rd_CheckAffectedDownline]
			@custid = @custid,
			@RoleID = @RoleID,
			@JsonData = @BetSettingJson,
			@IsAffected_NG = @IsAffected_NG OUTPUT,
			@IsAffected_DCS = @IsAffected_DCS OUTPUT

		IF @IsAffected_DCS = 1 
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
			a.MaxPerNumber = CASE WHEN t.SubType = 2 THEN t.MaxPerNumber END,
			a.MinBet = t.MinBet,
			a.RepUpdateTime = dbo.f_GetDateTime2()
		FROM @NewBetLimitTbl t
			INNER JOIN BetSetting3rd_Agent a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid
			AND (	ISNULL(t.MinBet,0)  <>  ISNULL(a.MinBet,0)
					OR ISNULL(t.MaxBet,0)  <>  ISNULL(a.MaxBet,0)
					OR ISNULL(t.MaxPerMatch,0)  <>  ISNULL(a.MaxPerMatch,0)
					OR ISNULL(t.MaxPerNumber,0)  <>  ISNULL(a.MaxPerNumber,0)
				)
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPerNumber = CASE WHEN t.SubType = 2 THEN t.MaxPerNumber END,
			a.MinBet = t.MinBet,
			a.RepUpdateTime = dbo.f_GetDateTime2()
		OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, deleted.MaxPerNumber, GETDATE()
		INTO @HistoryBetSettingTbl(CustID, SportType, BetType, MaxBet, MaxPerMatch, MaxPerNumber, UpdateTime)
		FROM @NewBetLimitTbl t
			INNER JOIN BetSetting3rd_Member a WITH(ROWLOCK,UPDLOCK) ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid
			AND (	ISNULL(t.MinBet,0)  <>  ISNULL(a.MinBet,0)
					OR ISNULL(t.MaxBet,0)  <>  ISNULL(a.MaxBet,0)
					OR ISNULL(t.MaxPerMatch,0)  <>  ISNULL(a.MaxPerMatch,0)
					OR ISNULL(t.MaxPerNumber,0)  <>  ISNULL(a.MaxPerNumber,0)
				)

		IF EXISTS (SELECT 1 FROM @HistoryBetSettingTbl) AND ISNULL(@isSearchAndCopy,0) = 0
		BEGIN
			--Insert history bet setting
			DELETE hbs
			FROM @HistoryBetSettingTbl hbs
				INNER JOIN @NewBetLimitTbl bs ON bs.SportType=hbs.SportType AND bs.BetType=hbs.BetType
			WHERE (bs.MaxBet=hbs.MaxBet AND bs.MaxPerMatch=hbs.MaxPerMatch AND ISNULL(bs.MaxPerNumber,0)=ISNULL(hbs.MaxPerNumber,0))

			SET @CustList = (SELECT CustID		AS '@CustID',
									SportType	AS '@SportType',
									BetType		AS '@BetType',
									MaxBet		AS '@MaxBet',
									MaxPerMatch	AS '@MaxPerMatch',
									MaxPerNumber AS '@MaxPerNumber',
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

	IF @RoleID > 1 AND @IsAffected_DCS = 1
	BEGIN
		IF EXISTS (SELECT 1 FROM @NewBetLimitTbl WHERE SportType = 161) 
			AND @IsAffected_NG = 1
		BEGIN
			--> Generate affected Agents to send notify message
			IF @RoleID = 4
			BEGIN			
				INSERT INTO @Notify_agents(CustID)
				SELECT c.custid
				FROM @NewBetLimitTbl t
					INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
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
					AND t.SportType = 161
			END
			ELSE IF @RoleID = 3
			BEGIN				
				INSERT INTO @Notify_agents(CustID)
				SELECT c.custid
				FROM @NewBetLimitTbl t
					INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
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
					AND t.SportType = 161
			END
		END

		--Adjust downline
		EXEC dbo.Acc_CustSetting_AdjustDownline
			 @CustId = @CustId
			,@RoleId = @RoleId
			,@JsonData = @BetSettingJson
			,@Mode='BetSetting'
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

	DECLARE @SPName varchar(100) = 'Acc_CustSetting_BetSetting_154_Upd'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)

	INSERT INTO @LogAction (ActionID)
	SELECT 220047 UNION ALL
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID IS NULL AND ld.Level = @RoleID

	-- Log old data
	SET @xml = (
		SELECT  @custid                         AS '@CustID',
				@UserName						AS '@SourceAccount',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP                             AS '@IP',
				(
						
					SELECT	@GroupID		AS '@GroupID'
						, p.ProductID		AS '@ProductID'
						, p.SportType 		AS '@SportType'
						, p.BetType			AS '@BetType'
						, p.SettingLevel	AS '@SettingLevel'
						, CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet'
						, CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet'
						, CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch'
						, CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @OldBetLimitTbl	AS bl
						INNER JOIN #ProductSettingDetail p 
							ON bl.BetType = p.BetType
								AND bl.SportType = p.SportType
					ORDER BY p.Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
					
				)
		FOR XML PATH('ROOT'), 
		TYPE
	)

	SET @logSpData_Old_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated data
	SET @xml = (
		SELECT  @custid                         AS '@CustID',
				@UserName						AS '@SourceAccount',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP                             AS '@IP',
				(
						
					SELECT	@GroupID		AS '@GroupID'
						, p.ProductID		AS '@ProductID'
						, p.SportType 		AS '@SportType'
						, p.BetType			AS '@BetType'
						, p.SettingLevel	AS '@SettingLevel'
						, CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet'
						, CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet'
						, CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch'
						, CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber'
					FROM @NewBetLimitTbl	AS bl
						INNER JOIN #ProductSettingDetail p 
							ON bl.BetType = p.BetType
								AND bl.SportType = p.SportType
					ORDER BY p.Child_DisplayOrder
					FOR XML PATH('BetLimit'),
					TYPE
					
				)
		FOR XML PATH('ROOT'), 
		TYPE
	)
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
		
		IF @ActionID = 220047
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
		END
		ELSE IF @IsAffected_DCS = 1 AND @RoleID <> 1 --Indirect log
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