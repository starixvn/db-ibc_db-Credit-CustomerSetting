ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLossLimitCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @Limit		VARCHAR(MAX)
	, @SettingType	SMALLINT		= 6
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160108@Elodie
	Task : Check Customer's Win Loss Limits
	DB: DBCUST/CustDB
	Original:
	Revisions:
	- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
	Param's Explanation:
	- @Limit:
		6: WinLossLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxWinLimit="2" 
						MaxLossLimit="20000" 
						IsAutoReset="0" 
				/>
		</ROOT>

		8: WinLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxWinLimit="2" 
						IsAutoReset="0" 
				/>
		</ROOT>

		12: LossLimit
		<ROOT>
				<Limit 
						SportType="1" 
						BetType="1" 
						MaxLossLimit="20000" 
						IsAutoReset="0" 
				/>
		</ROOT>

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

	--Parse XML data
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @Limit

	IF @SettingType = 6
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxWinLimit	SMALLMONEY
							, MaxLossLimit	MONEY
							, IsAutoReset	BIT
							)
	END

	IF @SettingType = 8
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, MaxWinLimit, 0 AS MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxWinLimit	SMALLMONEY
							, IsAutoReset	BIT
							)
	END

	IF @SettingType = 12
	BEGIN
		INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
		SELECT SportType, BetType, 0 AS MaxWinLimit, MaxLossLimit, IsAutoReset
		FROM OPENXML(@iDoc, '/ROOT/Limit', 1) WITH (
							SportType		SMALLINT
							, BetType		SMALLINT
							, MaxLossLimit	MONEY
							, IsAutoReset	BIT
							)
	END

	EXEC sp_xml_removedocument @iDoc

	IF @RoleID = 3
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
	ELSE IF @RoleID = 2
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
	ELSE IF @RoleID = 1
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

	IF @SettingType = 6 OR @SettingType = 8
	BEGIN
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
							FROM @UplineLimitTbl uwl
								INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
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
	END

	IF @SettingType = 6 OR @SettingType = 12
	BEGIN
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
							FROM @UplineLimitTbl uwl
								INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
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
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
						WHERE uwl.IsAutoReset = 1 AND nwl.IsAutoReset = 0
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

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitCheck] TO [bodbExtAccNet]