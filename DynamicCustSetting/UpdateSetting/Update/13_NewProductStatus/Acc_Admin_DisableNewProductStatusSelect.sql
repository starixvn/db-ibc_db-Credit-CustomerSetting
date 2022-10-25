/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatusSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
	, @SettingType	TINYINT = NULL
AS
/*
	Created: 20180118@Elodie
	Task : Get New product Status setting values of a product on NAP & ExtNAP
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20180118@Elodie: Get New product Status setting values of a product on NAP & ExtNAP [RedmineID:#87328]
		- 20200325@Elodie: Only show sport is unhided [RedmineID:#128058]
		- 20200702@Winfred: Get enabled status of Cust when SettingType = 4 (ProductStatus)  (ProductStatus) [RedmineID:#136210]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20221006@Winfred: Macau Game - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT

	Example: EXEC Acc_Admin_DisableNewProductStatusSelect @CustID = 1275, @ProductID = 23
	
	
	*/
BEGIN
	DECLARE	@Currency				TINYINT,
			@RoleID					TINYINT,
			@SuperID				INT,
			@MasterID				INT,
			@AgentID				INT

	CREATE TABLE #DownlineEnableStatus (	Sporttype SMALLINT, Bettype SMALLINT, 
											TotalEnabledMasters INT,
											TotalEnabledAgents INT,
											TotalEnabledMembers INT)

	CREATE TABLE #DownlineDisableStatus (	Sporttype SMALLINT, Bettype SMALLINT, 
											TotalDisabledMasters INT,
											TotalDisabledAgents INT,
											TotalDisabledMembers INT)

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, ParentSportType SMALLINT, ParentBetType SMALLINT, ChildDisplayOrder INT)

	IF @SettingType IS NULL
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype)
		SELECT SportType,Bettype
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus)

		INSERT INTO #SportBettypeFilter (SportType,Bettype)
		SELECT SportType,Bettype
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4,@SettingStatus)
	END
	ELSE 
	BEGIN
		INSERT INTO #SportBettypeFilter (SportType,Bettype)
		SELECT SportType,Bettype
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType,@SettingStatus)
	END

	UPDATE t
	SET t.ParentSportType = par.SportType
		, t.ParentBetType = par.BetType
		, t.ChildDisplayOrder = d.ChildDisplayOrder
	FROM #SportBettypeFilter t 
		INNER JOIN ProductSettingDetail d WITH(NOLOCK)
			ON t.sporttype = d.SportType
			AND t.bettype = d.BetType
			AND d.SettingType = @SettingType
		INNER JOIN ProductSettingDetail par WITH(NOLOCK) 
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
		INSERT INTO #DownlineDisableStatus (Sporttype, Bettype, TotalDisabledMasters, TotalDisabledAgents, TotalDisabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.srecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		INSERT INTO #DownlineEnableStatus (Sporttype, Bettype, TotalEnabledMasters, TotalEnabledAgents, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.srecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype
		
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(0 AS BIT) AS isDisabledUpline,
				CAST(0 AS BIT) AS isHiddenUpline,
				ISNULL(TotalDisabledMasters,0) AS TotalDisabledMasters,
				ISNULL(TotalEnabledMasters,0) AS TotalEnabledMasters, 
				ISNULL(TotalDisabledAgents,0) AS TotalDisabledAgents, 
				ISNULL(TotalEnabledAgents,0) AS TotalEnabledAgents, 
				ISNULL(TotalDisabledMembers,0) AS TotalDisabledMembers,
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.ChildDisplayOrder
	END	
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO #DownlineDisableStatus (Sporttype, Bettype, TotalDisabledMasters, TotalDisabledAgents, TotalDisabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.mrecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		INSERT INTO #DownlineEnableStatus (Sporttype, Bettype, TotalEnabledMasters, TotalEnabledAgents, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.mrecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder)) AS isHiddenUpline,
				ISNULL(TotalDisabledMasters,0) AS TotalDisabledMasters,
				ISNULL(TotalEnabledMasters,0) AS TotalEnabledMasters, 
				ISNULL(TotalDisabledAgents,0) AS TotalDisabledAgents, 
				ISNULL(TotalEnabledAgents,0) AS TotalEnabledAgents, 
				ISNULL(TotalDisabledMembers,0) AS TotalDisabledMembers,
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType		
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.ChildDisplayOrder
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO #DownlineDisableStatus (Sporttype, Bettype, TotalDisabledMasters, TotalDisabledAgents, TotalDisabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.recommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		INSERT INTO #DownlineEnableStatus (Sporttype, Bettype, TotalEnabledMasters, TotalEnabledAgents, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.recommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder)) AS isHiddenUpline,
				ISNULL(TotalDisabledMasters,0) AS TotalDisabledMasters,
				ISNULL(TotalEnabledMasters,0) AS TotalEnabledMasters, 
				ISNULL(TotalDisabledAgents,0) AS TotalDisabledAgents, 
				ISNULL(TotalEnabledAgents,0) AS TotalEnabledAgents, 
				ISNULL(TotalDisabledMembers,0) AS TotalDisabledMembers,
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID		
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.ChildDisplayOrder
	END	
	ELSE 
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder)) AS isHiddenUpline,
				0 AS TotalDisabledMasters,
				0 AS TotalEnabledMasters, 
				0 AS TotalDisabledAgents, 
				0 AS TotalEnabledAgents, 
				0 AS TotalDisabledMembers,
				0 AS TotalEnabledMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.ChildDisplayOrder
	END

	DROP TABLE #SportBettypeFilter
	DROP TABLE #DownlineDisableStatus
	DROP TABLE #DownlineEnableStatus
END
GO

