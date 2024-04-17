/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
	, @SettingType	TINYINT = 13
AS
/*
	Created: 20170125@Elodie
	Task : Get New product Status setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
		- 20170417@Elodie: Notify downline when upline enable FW's status [RedmineID: #73073]
		- 20170613@Elodie: Change logic to get HasDownlines and IsDisableDownline value [RedmineID:#78225]
		- 20170921@Johnson: fix the unsynchronized setting, fix hasDownline status to show checkbox enable downline [Redmine: #72973]
					+hasDownline = 1: has at least one customer has sync status
								=0 : all downlines not sync	
		- 20180112@Elodie: Remove HasDownlines and IsDisableDownline value [RedmineID:#87328]
		- 20200325@Elodie: Only show sport is unhided [RedmineID:#128058]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20221006@Winfred: Macau Game - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT

	Example: EXEC Acc_CustSetting_DisableNewProductStatusSelect @CustID = 1275, @ProductID = 23
	
	
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, ParentSportType SMALLINT, ParentBetType SMALLINT, Child_DisplayOrder INT)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[Parent_ProductSettingID] [int],
		[ProductSettingID] [int],
		Child_DisplayOrder INT,
		ProductID [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,Child_DisplayOrder,ProductID)
	SELECT SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,Child_DisplayOrder,ProductID
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	WHERE SettingType IN(4,11,13,21)

	INSERT INTO #SportBettypeFilter(SportType,Bettype)
	SELECT SportType,Bettype
	FROM #ProductSettingDetail 
	WHERE SportType NOT IN (161) -- Not show NG on DCS setting Page
		AND ProductID = ISNULL(@ProductID,ProductID)
		AND SettingType = ISNULL(@SettingType,SettingType)

	UPDATE t
	SET t.ParentSportType = par.SportType
		, t.ParentBetType = par.BetType
		, t.Child_DisplayOrder = d.Child_DisplayOrder
	FROM #SportBettypeFilter t 
		INNER JOIN #ProductSettingDetail d WITH(NOLOCK)
			ON t.sporttype = d.SportType
			AND t.bettype = d.BetType
			AND d.SettingType = @SettingType
		LEFT JOIN #ProductSettingDetail par WITH(NOLOCK) 
				ON d.Parent_ProductSettingID = par.ProductSettingID
	
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 4
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(0 AS BIT) AS isDisabledUpline,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END	
	ELSE IF @RoleID = 3
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END
	ELSE IF @RoleID = 2
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID	
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END	
	ELSE 
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END
	DROP TABLE #SportBettypeFilter
	DROP TABLE #ProductSettingDetail
END
GO

