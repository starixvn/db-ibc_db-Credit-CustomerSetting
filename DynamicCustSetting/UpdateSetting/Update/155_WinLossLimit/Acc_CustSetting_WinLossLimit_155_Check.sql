/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_WinLossLimit_155_Check] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @Limit		VARCHAR(MAX)
	, @GroupID		TINYINT
	, @GroupType	SMALLINT		= 155
	, @SettingStatus	TINYINT		= 0
	, @ErrCode		INT			= 0		OUTPUT
	, @MsgType		INT			= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''		OUTPUT
AS
/*
	Created: 20240216@Helios
	Task : Check Customer's Win Loss Limits
	DB: DBCUST/CustDB
	Original:
	Revisions:
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
	- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969] 
	Param's Explanation:
	- @Limit:
		22: WinLossLimit
		'[
			{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }, 
			{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"2"  , "MaxLossLimit":"20000"  , "IsAutoReset":"0" }

		]'

	- @SettingType: 6: WinLossLimit
					8: WinLimit
					12: LossLimit
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xml XML
	DECLARE @UplineLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)

	DECLARE @NewLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY 
			, MaxLossLimit		MONEY 
			, IsAutoReset		BIT
			)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[Child_DisplayOrder] [INT]
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	IF @Limit IS NULL OR @Limit = ''
		RETURN
	
	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	IF @RoleId NOT IN (1, 2, 3, 4)
	BEGIN       
		SELECT @ErrMsg = '<Root MsgID="40002" Msg="Invalid user!" />'
				, @ErrCode = 1                    
						, @MsgType = 100--just return msgID
		RETURN
	END

	DECLARE  
		@SiteID	SMALLINT,
		@Currency	SMALLINT,
		@Site		VARCHAR (10)
	
	SELECT  
		@siteID = s.siteID,
		@Currency = c.currency,
		@Site = C.site
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @CustID

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)



	-- Parse Data Json
	INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
	FROM OPENJSON(@Limit)
	WITH 
		(
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	SMALLMONEY
			, MaxLossLimit	MONEY
			, IsAutoReset	BIT
		) AS Limit

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewLimitTbl t
		INNER JOIN #ProductSettingDetail ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN ( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	IF (@RoleID = 3) OR (@RoleID = 1 AND @AgentID = -4)	-- Master or SuperDirectMember : Collect Upline Super
	BEGIN
		--Get super's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @SuperID		
	END
	ELSE IF (@RoleID = 2) OR (@RoleID = 1 AND @AgentID = -3)	-- Agent or MasterDirectMember : Collect Upline Super, Master
	BEGIN
		--Get master 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @MasterID
	END
	ELSE IF @RoleID = 1 AND @AgentID NOT IN (-4,-3) --Normal member : Collect Upline Super, Master, Agent
	BEGIN
		--Get agent 's bet limit
		INSERT INTO @UplineLimitTbl
		SELECT wl.SportType
			, wl.BetType
			, wl.MaxWinLimit
			, wl.MaxLossLimit
			, wl.IsAutoReset
		FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.SportType AND tmp.BetType = wl.BetType
		WHERE wl.CustID	= @AgentID
	END			

	--Check Upline's win limit >= Win Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
			)
	BEGIN
		SET @xml = (
				SELECT 10024 AS '@MsgID'
					, 'Maximum Win should be less than or equal to Maximum Win of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
							, psd.SettingLevel AS '@SettingLevel'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
							INNER JOIN #ProductSettingDetail psd ON uwl.SportType = psd.SportType AND uwl.BetType = psd.BetType
						WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 111
		SET @ErrCode = 2

		RETURN
	END

	--Check Upline's loss limit >= Loss Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxLossLimit > 0 AND (nwl.MaxLossLimit = 0 OR uwl.MaxLossLimit < nwl.MaxLossLimit)
			)
	BEGIN
		SET @xml = (
				SELECT 10033 AS '@MsgID'
					, 'Maximum Loss should be less than or equal to Maximum Loss of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
							, psd.SettingLevel AS '@SettingLevel'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
							INNER JOIN #ProductSettingDetail psd ON uwl.SportType = psd.SportType AND uwl.BetType = psd.BetType
						WHERE uwl.MaxLossLimit > 0 AND (nwl.MaxLossLimit = 0 OR uwl.MaxLossLimit < nwl.MaxLossLimit)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 112
		SET @ErrCode = 3

		RETURN			
	END

	--Check Upline's auto reset = 0 and auto reset = 1
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
			)
	BEGIN
		SET @xml = (
				SELECT 10022 AS '@MsgID'
					, 'You are not allowed to change Daily auto reset limit.' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
							, psd.SettingLevel AS '@SettingLevel'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
							INNER JOIN #ProductSettingDetail psd ON uwl.SportType = psd.SportType AND uwl.BetType = psd.BetType
						WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 113
		SET @ErrCode = 4

		RETURN	
END
	
END
