/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_WinLossLimitCheck_SAg]
	@srecommend INT,	
	--WinLoss Limit
	@SettingType6 VARCHAR(MAX)= '',-- VS
	@SettingType22 VARCHAR(MAX)= '', -- RNG Lottery, LCS	
	--Loss Limit
	@SettingType12 VARCHAR(MAX)= '',-- BBIN
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20230522@Johnson  
	Task : check WinLoss Limit for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230522@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType6 = '<Root>
						<r sporttype="9908" bettype="1201" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
						...
						<r sporttype="170" bettype="3701" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
					</Root>'
		- @SettingType22 = '<Root>
						<r sporttype="9909" bettype="3700" maxwinlimit="2" maxlosslimit="20000" isautoreset="0" />
						</Root>'
		- @SettingType12 = '<Root>
						<r sporttype="241" bettype="3300" maxlosslimit="20000" isautoreset="0"  />
						</Root>'				
*/	
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @xml XML
		
	DECLARE @NewLimitTbl TABLE (
			SettingType 		TINYINT
			, SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY 
			, MaxLossLimit		MONEY 
			, IsAutoReset		BIT
			)
	DECLARE @UplineLimitTbl TABLE (
			SettingType 		TINYINT
			, SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		SMALLMONEY
			, MaxLossLimit		MONEY
			, IsAutoReset		BIT
			)
			
	IF ISNULL(@SettingType6,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType6)
			
		INSERT INTO @NewLimitTbl(
			SettingType,
			SportType, 
			BetType, 
			MaxWinLimit, 
			MaxLossLimit, 
			IsAutoReset)
		SELECT 6 as SettingType,
			T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(r/@maxwinlimit)[1]', 'smallmoney') AS MaxWinLimit,
			T.c.query('.').value('(r/@maxlosslimit)[1]', 'money') AS MaxLossLimit,
			T.c.query('.').value('(r/@isautoreset)[1]', 'bit') AS IsAutoReset
		FROM  @xml.nodes('/Root/r') T(c) 	
	END	
	
	IF ISNULL(@SettingType22,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType22)
			
		INSERT INTO @NewLimitTbl(
			SettingType,
			SportType, 
			BetType, 
			MaxWinLimit, 
			MaxLossLimit, 
			IsAutoReset)
		SELECT 22 as SettingType,
			T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(r/@maxwinlimit)[1]', 'smallmoney') AS MaxWinLimit,
			T.c.query('.').value('(r/@maxlosslimit)[1]', 'money') AS MaxLossLimit,
			T.c.query('.').value('(r/@isautoreset)[1]', 'bit') AS IsAutoReset
		FROM  @xml.nodes('/Root/r') T(c) 	
	END	
	
	IF ISNULL(@SettingType12,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType12)
			
		INSERT INTO @NewLimitTbl(
			SettingType,
			SportType, 
			BetType,  
			MaxLossLimit, 
			IsAutoReset)
		SELECT 12 as SettingType,
			T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS bettype,			
			T.c.query('.').value('(r/@maxlosslimit)[1]', 'money') AS MaxLossLimit,
			T.c.query('.').value('(r/@isautoreset)[1]', 'bit') AS IsAutoReset
		FROM  @xml.nodes('/Root/r') T(c) 	
	END	
	
	INSERT INTO @UplineLimitTbl(
			SettingType,
			SportType, 
			BetType, 
			MaxWinLimit, 
			MaxLossLimit, 
			IsAutoReset)
	SELECT tmp.SettingType 
		, wl.SportType
		, wl.BetType
		, wl.MaxWinLimit
		, wl.MaxLossLimit
		, wl.IsAutoReset
	FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.SportType AND tmp.BetType = wl.BetType
	WHERE wl.CustID	= @srecommend

	--Check Upline's win limit >= Win Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
					AND nwl.SettingType IN (6,22)
			)
	BEGIN
		SET @xml = (
				SELECT 10024 AS '@MsgID'
					, 'Maximum Win should be less than or equal to Maximum Win of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
						WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
							AND nwl.SettingType IN (6,22)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 41
		SET @ErrCode = 401

		RETURN
	END
	
	--Check Upline's loss limit >= Loss Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxLossLimit > 0 AND (nwl.MaxLossLimit = 0 OR uwl.MaxLossLimit < nwl.MaxLossLimit)
					AND nwl.SettingType IN (6,12,22)
			)
	BEGIN
		SET @xml = (
				SELECT 10033 AS '@MsgID'
					, 'Maximum Loss should be less than or equal to Maximum Loss of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
						WHERE uwl.MaxLossLimit > 0 AND (nwl.MaxLossLimit = 0 OR uwl.MaxLossLimit < nwl.MaxLossLimit)
							AND nwl.SettingType IN (6,12,22)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 41
		SET @ErrCode = 402

		RETURN
	END
	
	--Check Upline's auto reset = 0 and auto reset = 1
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
					AND nwl.SettingType IN (6,12,22)
			)
	BEGIN
		SET @xml = (
				SELECT 10033 AS '@MsgID'
					, 'Maximum Loss should be less than or equal to Maximum Loss of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
						WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
							AND nwl.SettingType IN (6,12,22)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 41
		SET @ErrCode = 403

		RETURN
	END
END	
