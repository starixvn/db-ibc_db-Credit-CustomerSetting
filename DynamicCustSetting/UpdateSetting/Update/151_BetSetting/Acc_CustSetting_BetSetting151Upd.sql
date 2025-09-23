/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_BetSetting151Upd]
	@custid			INT			,
	@BetSetting			VARCHAR(MAX)	,
	@SubAccID			INT			= 0,
	@UserID			INT			,	
	@IP				VARCHAR(15)		='',
	@SystemID			TINYINT		= 1,
	@SettingStatus		TINYINT		= 0,
	@ErrCode			INT			= 0 OUTPUT,
	@ErrMsg			NVARCHAR(4000)	= '' OUTPUT,
	@MsgType			INT			= 0 OUTPUT,
	@GroupID			TINYINT		= 1,
	@GroupType			TINYINT		= 151
AS
/*
	Created: 20230310@Helios
	Task : Update Bet Setting of Sportbook (use for all level Super/master/agent/member)
	DB: DBCUST/CUSTDB
	Original: Acc_CustomerUpd_BetSetting 

	Revisions:
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20240610@Johnson: Scale out DBCUST [redmine: #199915]
		- 20250617@Johnson: add Max Payout Per Match for E-Sports & Muay Thai [redmine: #230652]
		- 20250915@Johnson: Max Payout Per Match - Change to Max Win [redmine: #236447]
	Param's Explanation:
	- @ErrCode:
		= 0: Update successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
	- @GroupType : 151 is BetSetting
	- @BetSetting: Json Type
		'[
				  { "SportType": "1","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "880" },
				  { "SportType": "1","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "2","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "3","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "5","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "8","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "10","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "11","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9901","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9902","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "43","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" },
				  { "SportType": "44","BetType": "3","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" }
		]'
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @CustList VARCHAR(MAX)

	DECLARE 
	  @startRun		DATETIME	
	, @endRun		DATETIME	
	, @duration		INT 
	, @RoleID		TINYINT
	, @recommend	INT
	, @mrecommend	INT
	, @srecommend	INT
	, @UserName		VARCHAR(30)
	, @SiteID		INT 
	, @CurrencyID	INT
	, @XML		XML

	DECLARE @Old_BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPayoutPerMatch MONEY
		PRIMARY KEY(SportType, Bettype)
	);	

	DECLARE @New_BetSetting TABLE(
		CustID		  INT,
		SportType		  SMALLINT, 
		BetType		  SMALLINT, 
		MinBet		  MONEY, 
		MaxBet		  MONEY, 
		MaxPerMatch		  MONEY, 
		MaxPayoutPerMatch   MONEY,
		IsSpecial		  BIT DEFAULT (0),
		LogOrder		  TINYINT
		PRIMARY KEY(CustID, SportType, Bettype)
	);
		
	CREATE TABLE #ProductSettingDetail(
		ProductID		TINYINT,
		RealProductID	TINYINT,		
		SportType		SMALLINT,
		BetType		SMALLINT,
		IsLive		BIT,
		IntervalValue	DECIMAL(19,8),
		SubType		TINYINT,
		Child_DisplayOrder TINYINT,
		SettingLevel	TINYINT,
		SettingType		TINYINT
	PRIMARY KEY(SportType ASC , BetType ASC)
	)
	
	--------------------Collect Data--------------------
	-- Check if XML is null or empty
	IF @BetSetting IS NULL OR @BetSetting = ''
		RETURN

	SET @startRun = GETDATE()	

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg	= ''

	-- Check disable user 
	EXEC dbo.Acc_CustomerSelCheckEnable 
							@custid		= @custid
						,	@ErrCode		= @ErrCode OUTPUT
						,	@ErrMsg		= @ErrMsg OUTPUT
	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	-- Check belonging
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

	-- Get line information
	SELECT @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend, @RoleID=RoleID, @SiteID = s.siteid , @CurrencyID = c.currency
	FROM customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @CustID


	INSERT INTO #ProductSettingDetail 	(ProductID , RealProductID , SportType , BetType , IsLive , IntervalValue , SubType , Child_DisplayOrder , SettingLevel , SettingType)
	SELECT ProductID ,RealProductID , SportType , Bettype , IsLive , IntervalValue , SubType , Child_DisplayOrder , SettingLevel , SettingType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)


	-- Parse Data Json
	INSERT INTO @New_BetSetting (CustID , SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch , LogOrder)
	SELECT
	    @custid,
	    BetSetting.SportType,
	    BetSetting.BetType,
	    MinBet,
	    MaxBet,
	    MPM,
	    MaxPayout,
	    psd.Child_DisplayOrder
	FROM
	#ProductSettingDetail psd
	INNER JOIN 
	    OPENJSON(@BetSetting)
	    WITH
		  (
			SportType		SMALLINT,
			BetType		SMALLINT,
			MinBet		MONEY,
			MaxBet		MONEY,
			MPM			MONEY,
			MaxPayout		MONEY
        ) AS BetSetting ON BetSetting.SportType = psd.SportType AND BetSetting.BetType = psd.BetType


	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @New_BetSetting t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 26
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @New_BetSetting)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END


	--Validate new bet settings
	EXEC dbo.Acc_CustSetting_BetSetting151Check
		@CustID	= @CustID
	,	@RoleID	= @RoleID
	,	@AgentId	= @recommend
	,	@MasterID	= @mrecommend
	,	@SuperID	= @srecommend
	,	@BetSetting	= @BetSetting
	,	@SystemID	= @SystemID
	,	@SettingStatus = @SettingStatus
	,	@CurrencyID	= @CurrencyID
	,	@siteid	= @siteid
	,	@GroupID	= @GroupID
	,	@GroupType	= @GroupType
	,	@ErrCode	= @ErrCode		OUTPUT
	,	@MsgType	= @MsgType		OUTPUT
	,	@ErrMsg	= @ErrMsg		OUTPUT
	
	IF @ErrCode <> 0
		RETURN
	    
	--Get current Setting
	IF @RoleID > 1
	BEGIN
		INSERT INTO @Old_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPayoutPerMatch
		FROM BetSetting_Agent cb WITH (NOLOCK)
			INNER JOIN @New_BetSetting b ON cb.CustID = b.CustID AND cb.SportType = b.SportType AND cb.BetType = b.BetType
	END
	ELSE
	BEGIN
		INSERT INTO @Old_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPayoutPerMatch
		FROM BetSetting_Member cb WITH (NOLOCK)
			INNER JOIN @New_BetSetting b ON cb.CustID = b.CustID AND cb.SportType = b.SportType AND cb.BetType = b.BetType
	END

	IF NOT EXISTS(
		SELECT TOP 1 1
		FROM @New_BetSetting t
			INNER JOIN @Old_BetSetting old
				ON t.SportType = old.SportType AND t.BetType = old.BetType
		WHERE ISNULL(t.MinBet,0)  <>  ISNULL(old.MinBet,0)
			OR ISNULL(t.MaxBet,0)  <>  ISNULL(old.MaxBet,0)
			OR ISNULL(t.MaxPerMatch,0)  <>  ISNULL(old.MaxPerMatch,0)
			OR ISNULL(t.MaxPayoutPerMatch,0)  <>  ISNULL(old.MaxPayoutPerMatch,0)
	)
	BEGIN
		RETURN	-- Data Not Changed so Return
	END

	DECLARE @BetSettingXML VARCHAR(MAX)  = '', @IsAffected BIT = 0

	IF @RoleID > 1
	BEGIN
		-- Set IsSpecial = 1 --> not affect to downline
		UPDATE t
		SET t.IsSpecial = 1
		FROM @New_BetSetting t
		WHERE ISNULL(t.MinBet,0) = 0 
			AND ISNULL(t.MaxBet,0) = 0 
			AND ISNULL(t.MaxPerMatch,0) = 0 
			AND ISNULL(t.MaxPayoutPerMatch,0) = 0 

		SELECT @BetSettingXML = CONVERT( VARCHAR(MAX), 
							(	
								SELECT	 SportType			AS	'@SportType'		
										,BetType 			AS	'@BetType' 
										,MinBet 			AS	'@MinBet'
										,MaxBet 			AS	'@MaxBet' 
										,MaxPerMatch 		AS	'@MaxPerMatch' 
										,MaxPayoutPerMatch	AS	'@MaxPayoutPerMatch'
								FROM @New_BetSetting
								WHERE IsSpecial = 0
								FOR XML PATH('Row'), ROOT ('Root'), TYPE)
							)

		--Check affected downline
		EXEC [Acc_CustomerUpd_BetSetting_Checkdownline]
			@custid		= @custid,
			@RoleID		= @RoleID,
			@BetSettingXML	= @BetSettingXML,
			@IsAffected		= @IsAffected OUTPUT
		
		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPayoutPerMatch = t.MaxPayoutPerMatch,
			a.MinBet = t.MinBet,
			a.RepUpdateTime = SYSDATETIME()
		FROM @New_BetSetting t
			INNER JOIN BetSetting_Agent a WITH(ROWLOCK,UPDLOCK)
				ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPayoutPerMatch = t.MaxPayoutPerMatch,
			a.MinBet = t.MinBet,
			a.RepUpdateTime = SYSDATETIME()
		FROM @New_BetSetting t
			INNER JOIN BetSetting_Member a WITH(ROWLOCK,UPDLOCK)
				ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid	
	END

	IF (@@ERROR <> 0)
	BEGIN
		SELECT  @ErrCode	= '<Root MsgID="90001" Msg="Update process is unsuccessful !" />'
			, @ErrCode  = 115                    
			, @MsgType  = 100 --just return MsgID
	END

	DECLARE @Notify_agents TABLE ( CustID INT, Isfinished BIT default 0)

	IF @RoleID = 2
	BEGIN
		INSERT INTO @Notify_agents(CustID) 
		SELECT @custid
	END

	IF @RoleID > 1 AND @IsAffected = 1
	BEGIN
		--> Generate affected Agents to send notify message
		IF @RoleID = 4
		BEGIN
			INSERT INTO @Notify_agents(CustID)
			SELECT c.custid
			FROM @New_BetSetting t
				INNER JOIN BetSetting_Agent a WITH(NOLOCK)
					ON t.SportType = a.SportType AND t.BetType = a.BetType
				INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
			WHERE c.srecommend = @custid
				AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
						OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
						OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0))
				AND c.roleid = 2
				AND t.IsSpecial = 0
				AND c.enabled = 1
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO @Notify_agents(CustID)
			SELECT c.custid
			FROM @New_BetSetting t
				INNER JOIN BetSetting_Agent a WITH(NOLOCK)
					ON t.SportType = a.SportType AND t.BetType = a.BetType
				INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
			WHERE c.mrecommend = @custid
				AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
						OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
						OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0))
				AND c.roleid = 2
				AND t.IsSpecial = 0
				AND c.enabled = 1
		END

		--Update Downline
		EXEC dbo.Acc_CustSetting_BetSettingSportsbookUpd
			 @CustId    = @CustId
			,@RoleId    = @RoleId
			,@XML		= @BetSettingXML
			,@GroupType = @GroupType
	END

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

	------------------------------ write log-------------------------------
	DECLARE @LogSPData VARCHAR(MAX), @LogSPData_Old VARCHAR(MAX),@ActionID INT, @LogSPData_Indirect VARCHAR(MAX), @LogSPData_Old_Indirect VARCHAR(MAX)
	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))
	
	--INSERT INTO @LogAction (ActionID)
	--SELECT l.ActionID
	--FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
	--	INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	--WHERE l.SPName = @SPName AND ld.ProductID = 1 AND ld.Level = @RoleID

	IF @RoleID = 4
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220051
		UNION SELECT 220052
	END
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220053
		UNION SELECT 220054
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220055
		UNION SELECT 220056
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220057
	END

	SET @xml = (
				SELECT	@custid							AS '@custid',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						@UserName							AS '@SourceAccount',
						(
							SELECT	t.SportType									AS '@SportType',
									t.BetType									AS '@BetType',
									CONVERT(DECIMAL(20,2), old.MinBet)					AS '@MinBet',
									CONVERT(DECIMAL(20,2), old.MaxBet)					AS '@MaxBet',
									CONVERT(DECIMAL(20,2), old.MaxPerMatch)				AS '@MaxPerMatch',
									CONVERT(DECIMAL(20,2), old.MaxPayoutPerMatch)			AS '@MaxWinPerMatch'
							FROM @New_BetSetting t
								INNER JOIN @Old_BetSetting old ON t.SportType = old.SportType AND t.BetType = old.BetType
							ORDER BY LogOrder 
							FOR XML PATH('BetLimit'),
							TYPE
						)
				FOR XML PATH('ROOT'),
				TYPE
			)

	SET @LogSPData_Old_Indirect = REPLACE(CONVERT(VARCHAR(MAX), @XML), '" />', '"/"')

	SET @xml = (
				SELECT	@custid							AS '@Custid',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						@UserName							AS '@SourceAccount',
						(
							SELECT	SportType								AS '@SportType',
									BetType								AS '@BetType',
									CONVERT(DECIMAL(20,2), MinBet)				AS '@MinBet',
									CONVERT(DECIMAL(20,2), MaxBet)				AS '@MaxBet',
									CONVERT(DECIMAL(20,2), MaxPerMatch)				AS '@MaxPerMatch',
									CONVERT(DECIMAL(20,2), MaxPayoutPerMatch)			AS '@MaxWinPerMatch'
							FROM @New_BetSetting t
							ORDER BY LogOrder 
							FOR XML PATH('BetLimit'),
							TYPE
						)
				FOR XML PATH('ROOT'),
				TYPE
			)

	SET @LogSPData_Indirect = REPLACE(CONVERT(VARCHAR(MAX), @XML), '" />', '"/"')

	SELECT @LogSPData_Indirect = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData_Indirect)

	SELECT @LogSPData_Old_Indirect = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData_Old_Indirect)

	SET @logSpData = REPLACE(@LogSPData_Indirect, 'SourceAccount="'+ @UserName +'"', '')
	SET @logSpData_Old = REPLACE(@LogSPData_Old_Indirect, 'SourceAccount="'+ @UserName +'"', '')

	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK
		
		IF @ActionID NOT IN (220052,220054,220056) -- Direct log
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @LogSPData_Old,
				@duration = @duration	
		END
		ELSE IF @IsAffected = 1 -- Indirect log
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData_Indirect,
				@TrackingValue2 = @LogSPData_Old_Indirect,
				@duration = @duration	
		END
	END
END
GO
