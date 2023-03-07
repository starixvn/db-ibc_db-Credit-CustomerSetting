/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLossLimitSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingType	SMALLINT = 6
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20160108@Elodie
	Task : Get SMA WinLoss Limit setting values of a product
	DB: DBCUST/CustDB
	Original:
	Revisions:
	- 20161011@Winnie:  Implement for Loss limit setting type RedmineID: #65472
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	
	Param's Explanation:
		• @SettingType: 6,22: WinLossLimit
						8: WinLimit
						12: LossLimit
		- @SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	CREATE TABLE #SportBettypeFilter (
			sporttype SMALLINT, 
			bettype SMALLINT, 
			IsLive BIT, 
			SettingType SMALLINT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive,SettingType)
	SELECT SportType,Bettype,IsLive,SettingType 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType,@SettingStatus)
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	--WinLossLimit Setting
	IF @SettingType IN(6,22)
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
