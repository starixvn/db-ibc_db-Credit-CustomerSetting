ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLossLimitSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingType	SMALLINT = 6
AS
/*
	Created: 20160108@Elodie
	Task : Get SMA WinLoss Limit setting values of a product
	DB: DBCUST/CustDB
	Original:
	Revisions:
	- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
	
	Param's Explanation:
		• @SettingType: 6: WinLossLimit
						8: WinLimit
						12: LossLimit
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	SELECT SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	--WinLossLimit Setting
	IF @SettingType = 6
	BEGIN		
		IF @RoleID = 4
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					CONVERT(SMALLMONEY,0) AS MaxWinRange,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					CONVERT(MONEY,0) AS MaxLossRange, --Unlimited
					wl.IsAutoReset,
					CONVERT(BIT,1) AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
		ELSE IF @RoleID IN (3,2)
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = CASE	WHEN @RoleID = 3 THEN @SuperID
										WHEN @RoleID = 2 THEN @MasterID END
		ELSE
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = @AgentID
	END
	--Win Limit Setting
	ELSE IF @SettingType = 8
	BEGIN
		IF @RoleID = 4
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					CONVERT(SMALLMONEY,0) AS MaxWinRange,
					wl.IsAutoReset,
					CONVERT(BIT,1) AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
			WHERE wl.CustId = @CustID 
		ELSE IF @RoleID IN (3,2)
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = CASE	WHEN @RoleID = 3 THEN @SuperID
										WHEN @RoleID = 2 THEN @MasterID END
		ELSE
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = @AgentID
	END
	--Loss Limit Setting
	ELSE IF @SettingType = 12
	BEGIN
		IF @RoleID = 4
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					CONVERT(MONEY,0) AS MaxLossRange, --Unlimited
					wl.IsAutoReset,
					CONVERT(BIT,1) AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
		ELSE IF @RoleID IN (3,2)
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = CASE	WHEN @RoleID = 3 THEN @SuperID
										WHEN @RoleID = 2 THEN @MasterID END
		ELSE
			SELECT	wl.SportType,
					wl.BetType,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline
			FROM CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN	#SportBettypeFilter AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = @ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = @AgentID
	END
	
	
	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_WinLossLimitSelect] TO [bodbExtAccNet]