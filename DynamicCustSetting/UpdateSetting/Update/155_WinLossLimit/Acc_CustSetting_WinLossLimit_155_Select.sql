/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_WinLossLimit_155_Select] 
	  @CustID		INT
	, @GroupID		TINYINT = 3
	, @GroupType	SMALLINT = 155
	, @SettingStatus  TINYINT = 0
AS
/*
	Created: 20240216@Helios
	Task : Get SMA WinLoss Limit setting values of a product
	DB: DBCUST/CustDB
	Original:
	Revisions:
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
	
	Param's Explanation:
		• @SettingType: 6,22: WinLossLimit
						8: WinLimit
						12: LossLimit
		- @SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID	TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT,
			@SiteID	INT

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
		,	@SiteID	= s.siteid
	FROM	dbo.Customer AS c WITH(NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID

	INSERT INTO #ProductSettingDetail ( SettingType , SportType , BetType , ProductID , SubType , Child_DisplayOrder )
	SELECT SettingType , SportType , BetType , ProductID , SubType , Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	--WinLossLimit Setting
	--IF @SettingType IN(6,22)
	--BEGIN		
	IF @RoleID = 4
		BEGIN
			SELECT	sbf.ProductID,
				wl.SportType,
				wl.BetType,
				wl.MaxWinLimit,
				CONVERT(SMALLMONEY,0) AS MaxWinRange,
				wl.MaxLossLimit,
				gs.MinLossLimit AS MinLossRange,
				CONVERT(MONEY,0) AS MaxLossRange, --Unlimited
				wl.IsAutoReset,
				CONVERT(BIT,1) AS IsAutoResetUpline,
				sbf.SubType,
				sbf.Child_DisplayOrder
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#ProductSettingDetail AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
		
			ORDER BY sbf.Child_DisplayOrder
		END
	ELSE IF @RoleID IN (3,2)
		BEGIN
			SELECT	sbf.ProductID,
					wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline,
					sbf.SubType,
					sbf.Child_DisplayOrder
			FROM CustWinLossLimit_Agent wl WITH (NOLOCK)
			INNER JOIN	#ProductSettingDetail AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = CASE	WHEN @RoleID = 3 THEN @SuperID
										WHEN @RoleID = 2 THEN @MasterID END
			ORDER BY sbf.Child_DisplayOrder
		END
	ELSE
		BEGIN
			SELECT	sbf.ProductID,
					wl.SportType,
					wl.BetType,
					wl.MaxWinLimit,
					uwl.MaxWinLimit AS MaxWinRange,
					wl.MaxLossLimit,
					gs.MinLossLimit AS MinLossRange,
					uwl.MaxLossLimit AS MaxLossRange,
					wl.IsAutoReset,
					uwl.IsAutoReset AS IsAutoResetUpline,
					sbf.SubType,
					sbf.Child_DisplayOrder
			FROM CustWinLossLimit_Member wl WITH (NOLOCK)
			INNER JOIN	#ProductSettingDetail AS sbf
					ON	sbf.Bettype = wl.BetType
					AND	sbf.SportType = wl.SportType
				INNER JOIN CustWinLossLimit_Agent uwl WITH (NOLOCK) ON wl.SportType = uwl.SportType AND wl.BetType = uwl.BetType
				INNER JOIN LossLimit_GlobalSetting gs WITH (NOLOCK) ON gs.ProductId = sbf.ProductID AND gs.ExchangeId = @Currency
			WHERE wl.CustId = @CustID 
				AND uwl.CustId = @AgentID
			ORDER BY sbf.Child_DisplayOrder
		END
	--END
	
	
	DROP TABLE #ProductSettingDetail
END
