/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLimit_161_Select] 
	  @CustID		INT
	, @GroupID		TINYINT = 3
	, @GroupType	SMALLINT = 161
	, @SettingStatus  TINYINT = 0
AS
/*
	Created: 20250507@Elodie
	Task : Get SMA Win Limit setting values of a product
	DB: DBCUST/CustDB
	Original:
	Revisions:
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
	Param's Explanation:
		- @SettingType: 29: WinLimit					
		- @SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
	DECLARE	@Currency	INT,
			@RoleID	TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT,
			@SiteID		INT,
			@AgentCredit MONEY

	CREATE TABLE #ProductSettingDetail(
		[SettingType]		[smallint],
		[SportType]			[smallint],
		[BetType]			[smallint],
		[ProductID]			[tinyint],
		[SubType]			[tinyint],
		[Child_DisplayOrder]	INT
	)


	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
		,	@SiteID		= s.siteid		
	FROM	dbo.Customer AS c WITH(NOLOCK)
	INNER JOIN CustInfo AS ci WITH (NOLOCK) ON c.custid = ci.custid		
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	SELECT @AgentCredit	= ci.credit 
	FROM CustInfo ci WITH (NOLOCK)
	WHERE	custid = @AgentID

	INSERT INTO #ProductSettingDetail ( SettingType , SportType , BetType , ProductID , SubType , Child_DisplayOrder )
	SELECT SettingType , SportType , BetType , ProductID , SubType , Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	--WinLimit Setting
	--IF @SettingType IN(29)
	--BEGIN		
	IF @RoleID = 1 AND @AgentID NOT IN (-4,-3) --Normal member 
	BEGIN
		SELECT	CASE WHEN @GroupID = 3 THEN sbf.ProductID ELSE NULL END AS ProductID,
				wl.SportType,
				wl.BetType,
				wl.MaxWinLimit,
				uwl.MaxWinLimit * @AgentCredit AS MaxWinRange,					
				wl.IsAutoReset,
				uwl.IsAutoReset AS IsAutoResetUpline,
				sbf.SubType,
				sbf.Child_DisplayOrder
		FROM CustWinLossLimit_Member wl WITH (NOLOCK)
		INNER JOIN	#ProductSettingDetail AS sbf
				ON	sbf.Bettype = wl.BetType
				AND	sbf.SportType = wl.SportType
			INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
		WHERE wl.CustId = @CustID 
			AND uwl.CustId = @AgentID
		ORDER BY sbf.Child_DisplayOrder
	END
	--ELSE IF @RoleID = 1 AND @AgentID = -4 --Super Direct Member
	--	BEGIN
	--		SELECT	CASE WHEN @GroupID = 3 THEN sbf.ProductID ELSE NULL END AS ProductID,
	--				wl.SportType,
	--				wl.BetType,
	--				wl.MaxWinLimit,
	--				uwl.MaxWinLimit AS MaxWinRange,
	--				wl.MaxLossLimit,
	--				gs.MinLossLimit AS MinLossRange,
	--				uwl.MaxLossLimit AS MaxLossRange,
	--				wl.IsAutoReset,
	--				uwl.IsAutoReset AS IsAutoResetUpline,
	--				sbf.SubType,
	--				sbf.Child_DisplayOrder
	--		FROM CustWinLossLimit_Member wl WITH (NOLOCK)
	--		INNER JOIN	#ProductSettingDetail AS sbf
	--				ON	sbf.Bettype = wl.BetType
	--				AND	sbf.SportType = wl.SportType
	--			INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
	--			INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
	--		WHERE wl.CustId = @CustID 
	--			AND uwl.CustId = @SuperID
	--		ORDER BY sbf.Child_DisplayOrder
	--	END
	--ELSE IF @RoleID = 1 AND @AgentID = -3 --Master Direct Member
	--	BEGIN
	--		SELECT	CASE WHEN @GroupID = 3 THEN sbf.ProductID ELSE NULL END AS ProductID,
	--				wl.SportType,
	--				wl.BetType,
	--				wl.MaxWinLimit,
	--				uwl.MaxWinLimit AS MaxWinRange,
	--				wl.MaxLossLimit,
	--				gs.MinLossLimit AS MinLossRange,
	--				uwl.MaxLossLimit AS MaxLossRange,
	--				wl.IsAutoReset,
	--				uwl.IsAutoReset AS IsAutoResetUpline,
	--				sbf.SubType,
	--				sbf.Child_DisplayOrder
	--		FROM CustWinLossLimit_Member wl WITH (NOLOCK)
	--		INNER JOIN	#ProductSettingDetail AS sbf
	--				ON	sbf.Bettype = wl.BetType
	--				AND	sbf.SportType = wl.SportType
	--			INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
	--			INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
	--		WHERE wl.CustId = @CustID 
	--			AND uwl.CustId = @MasterID
	--		ORDER BY sbf.Child_DisplayOrder
	--	END
	
	DROP TABLE #ProductSettingDetail
END
