/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutUpd] 
	  @CustID		INT
	, @MaxPayoutLimit VARCHAR(MAX)
	, @SubAccID		INT			= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
	, @ErrCode		INT			= 0	OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
	, @MsgType		TINYINT		= 0   OUTPUT
	, @GroupID		TINYINT		= 1
	, @GroupType	TINYINT		= 152
	, @SettingStatus	TINYINT		= 0
AS
/*
	Created: 20210518@Winfred
	Task : Update Customer's Parlay Max Payout
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20210518@Winfred: Initial SP  [RedmineID:#154104]
		- 20210813@Eden: no need to update downlines and write indirect log when not affected [RedmineID:#160135]
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 
		- 20241205@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
	Param's Explanation:
	@MaxPayoutLimit:
		'[
					{ "SportType": "1", "BetType": "9", "SingleMP": "3000", "Combo2": "40000", "Combo35": "6000000", "Combo6": "1000000"  },
					{ "SportType": "99", "BetType": "9", "SingleMP": "6000", "Combo2": "40000", "Combo35": "6000000", "Combo6": "1000000" }
		]'

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))
	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		, @ActionID			INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		,@logSpData_Indirectly	NVARCHAR(MAX)
		, @logSpData_Old_Indirectly	NVARCHAR(MAX)
		, @xml				XML
		,@UserName		NVARCHAR(50)
		, @MaxPayoutLimitXML		VARCHAR(MAX)  = ''
		
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT
		, @SiteID				INT 
		, @CurrencyID			INT
		
	DECLARE @OldMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)
	DECLARE @NewMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)
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

	--Check if XML is null or empty
	IF @MaxPayoutLimit IS NULL
		OR @MaxPayoutLimit = ''
		RETURN

	SET @startRun = GETDATE()
	SELECT	@ErrCode	= 0	,	@ErrMsg			= '', @MsgType	= 0

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @ErrCode = 101
		SET @MsgType = 101
		RETURN
	END

	-- Get line information
	SELECT @UserName = username, @AgentID = recommend, @MasterID = mrecommend, @SuperID = srecommend, @RoleID=RoleID, @SiteID = s.siteid , @CurrencyID = c.currency
	FROM customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @CustID

	INSERT INTO #ProductSettingDetail 	(ProductID , RealProductID , SportType , BetType , IsLive , IntervalValue , SubType , Child_DisplayOrder , SettingLevel , SettingType)
	SELECT ProductID ,RealProductID , SportType , Bettype , IsLive , IntervalValue , SubType , Child_DisplayOrder , SettingLevel , SettingType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)


	-- Parse Data Json
	INSERT INTO @NewMaxPayoutTbl  ( SportType , BetType , SingleMatchParlay , Combo2 , Combo35 , ComboOver6 )
	SELECT SportType, BetType, SingleMP, Combo2 , Combo35 , Combo6
	FROM OPENJSON(@MaxPayoutLimit)
	    WITH
		  (
			SportType		SMALLINT,
			BetType		SMALLINT,
			SingleMP		MONEY,
			Combo2		MONEY,
			Combo35		MONEY,
			Combo6		MONEY
        ) AS MaxPayoutLimit

	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @NewMaxPayoutTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 27
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END

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

	
	--Validate new Max Payout settings
	EXEC [dbo].[Acc_CustSetting_MaxPayoutCheck] @CustID	= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @MaxPayoutLimit	= @MaxPayoutLimit
						, @Language	= 'E'
						, @SettingStatus  = @SettingStatus
						, @SiteID		= @SiteID
						, @CurrencyID	= @CurrencyID
						, @ErrCode		= @ErrCode	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT
						, @MsgType		= @MsgType	OUTPUT

	IF @ErrCode <> 0
		RETURN

	DECLARE @IsAffectedDownline BIT = 0

	IF @RoleID = 1
	BEGIN
		--get old settings
		INSERT INTO @OldMaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, bl.SingleMatchParlay
			, bl.Combo2
			, bl.Combo35
			, bl.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Member bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID AND ( bl.Combo2 <> tmp.Combo2 OR bl.Combo35 <> tmp.Combo35 
		OR bl.SingleMatchParlay <> tmp.SingleMatchParlay OR bl.ComboOver6 <> tmp.ComboOver6)
		
		DELETE a FROM @NewMaxPayoutTbl a 
		WHERE NOT EXISTS( SELECT 1 FROM @OldMaxPayoutTbl WHERE SportType = a.SportType  AND BetType = a.BetType)

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END  
	 
		--update new settings
		UPDATE main
		SET main.SingleMatchParlay	 = tmp.SingleMatchParlay
			, main.Combo2		= tmp.Combo2
			, main.Combo35	= tmp.Combo35
			, main.ComboOver6	= tmp.ComboOver6
			, RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustMaxPayoutSetting_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.SingleMatchParlay		<> tmp.SingleMatchParlay
				OR main.Combo2		<> tmp.Combo2
				OR main.Combo35 <> tmp.Combo35
				OR main.ComboOver6 <> tmp.ComboOver6
				)
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		SELECT @MaxPayoutLimitXML = CONVERT( VARCHAR(MAX), 
							(	
								SELECT	 SportType			AS	'@SportType'		
										,BetType 			AS	'@BetType' 
										,SingleMatchParlay 	AS	'@SingleMatchParlay'
										,Combo2 			AS	'@Combo2' 
										,Combo35 			AS	'@Combo35' 
										,ComboOver6			AS	'@ComboOver6'
								FROM @NewMaxPayoutTbl
								FOR XML PATH('MaxPayoutLimit'), ROOT ('ROOT'), TYPE)
							)

		--get old settings
		INSERT INTO @OldMaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, bl.SingleMatchParlay
			, bl.Combo2
			, bl.Combo35
			, bl.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID AND ( bl.Combo2 <> tmp.Combo2 OR bl.Combo35 <> tmp.Combo35 
		OR bl.SingleMatchParlay <> tmp.SingleMatchParlay OR bl.ComboOver6 <> tmp.ComboOver6)
		
		DELETE a FROM @NewMaxPayoutTbl a 
		WHERE NOT EXISTS( SELECT 1 FROM @OldMaxPayoutTbl WHERE SportType = a.SportType  AND BetType = a.BetType)

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END  

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END 

		EXEC [Acc_CustSetting_MaxPayoutCheckDownline]
			@CustID = @CustID,
			@MaxPayoutLimit = @MaxPayoutLimitXML,
			@isConfirm = @IsAffectedDownline OUTPUT

		IF @IsAffectedDownline = 1
		BEGIN
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
		END
		
		--update new settings
		UPDATE main
		SET main.SingleMatchParlay	 = tmp.SingleMatchParlay
			, main.Combo2		= tmp.Combo2
			, main.Combo35	= tmp.Combo35
			, main.ComboOver6	= tmp.ComboOver6
			, RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustMaxPayoutSetting_Agent main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.SingleMatchParlay		<> tmp.SingleMatchParlay
				OR main.Combo2		<> tmp.Combo2
				OR main.Combo35 <> tmp.Combo35
				OR main.ComboOver6 <> tmp.ComboOver6
				)

		IF @IsAffectedDownline = 1 -- update Downline
		BEGIN
			EXEC dbo.Acc_CustSetting_12
				@CustId = @CustId
				,@RoleId = @RoleId
				,@XML = @MaxPayoutLimitXML
				,@GroupType		= @GroupType
		END
	END
	

	--START LOGGING
	DECLARE @SPName varchar(100) = 'Acc_CustSetting_MaxPayoutUpd'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)
	
	--SELECT l.ActionID
	--FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
	--	INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	--WHERE l.SPName = @SPName AND ld.ProductID = 1 AND ld.Level = @RoleID
	IF @RoleID = 4
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220000
		UNION SELECT 220001
	END
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220002
		UNION SELECT 220003
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220004
		UNION SELECT 220005
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @LogAction (ActionID)
			SELECT 220006
	END
	
	-- Log old data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@UserName						AS '@SourceAccount',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CASE WHEN SingleMatchParlay = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), SingleMatchParlay) AS VARCHAR(20))  END AS '@SingleMatchParlay',
							CASE WHEN Combo2 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo2) AS VARCHAR(20))  END AS '@Combo2',
							CASE WHEN Combo35 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo35) AS VARCHAR(20))	 END AS '@Combo35',
							CASE WHEN ComboOver6 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), ComboOver6) AS VARCHAR(20))	 END AS '@ComboOver6'
					FROM @OldMaxPayoutTbl
					FOR XML PATH('MaxPayoutLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_MaxPayoutUpd'),
		TYPE )
	
	SET @logSpData_Old_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	---- Log new updated data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@UserName						AS '@SourceAccount',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CASE WHEN SingleMatchParlay = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), SingleMatchParlay) AS VARCHAR(20)) END AS '@SingleMatchParlay',
							CASE WHEN Combo2 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo2) AS VARCHAR(20))	 END AS '@Combo2',
							CASE WHEN Combo35 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo35) AS VARCHAR(20)) END AS '@Combo35',
							CASE WHEN ComboOver6 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), ComboOver6) AS VARCHAR(20))  END AS '@ComboOver6'
					FROM @NewMaxPayoutTbl
					FOR XML PATH('MaxPayoutLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_MaxPayoutUpd'),
		TYPE )
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
		
		IF @ActionID NOT IN (220001,220003,220005)
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
		END
		ELSE IF @IsAffectedDownline = 1 -- write log Indirectly
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
