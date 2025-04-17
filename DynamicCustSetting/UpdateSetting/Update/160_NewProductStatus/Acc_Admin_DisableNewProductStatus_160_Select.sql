/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatus_160_Select] 
	  @CustID			INT
	, @GroupID			TINYINT	 = 3
	, @GroupType		TINYINT	 = 160  
	, @SettingStatus		TINYINT	 = 0
AS
/*
	Created: 20240216@Helios
	Task : Get New product Status setting values of a product on NAP & ExtNAP
	DB: DBCUST/CustDB
	Original:
		Acc_Admin_DisableNewProductStatusSelect

	Revision:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
		- 20250410@Johnson: change datatype for ExchangeID[redmine: #223630]
	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT

	EXEC Acc_Admin_DisableNewProductStatus_160_Select @CustID = 112216817, @SettingStatus = 3 , @GroupID = 3 , @GroupType = 160
	*/
BEGIN
	DECLARE	@Currency		INT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT,
			@SiteID		INT,
			@UplineID	INT

	CREATE TABLE #DownlineEnableStatus (	Sporttype SMALLINT, Bettype SMALLINT, 
											TotalEnabledMasters INT,
											TotalEnabledAgents INT,
											TotalEnabledMembers INT,
											TotalEnabledSuperDirectMembers INT,
											TotalEnabledMasterDirectMembers INT)

	CREATE TABLE #DownlineDisableStatus (	Sporttype SMALLINT, Bettype SMALLINT, 
											TotalDisabledMasters INT,
											TotalDisabledAgents INT,
											TotalDisabledMembers INT,
											TotalDisabledSuperDirectMembers INT,
											TotalDisabledMasterDirectMembers INT)

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, ParentSportType SMALLINT, ParentBetType SMALLINT, Child_DisplayOrder INT)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[Parent_ProductSettingID] [int],
		[ProductSettingID] [int],
		Child_DisplayOrder INT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)


	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@SuperID	= c.srecommend
		,	@MasterID	= c.mrecommend
		,	@AgentID	= c.recommend
		,	@siteid	= s.siteid
	FROM	dbo.Customer c WITH(NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE	c.custid = @CustID


	INSERT INTO #SportBettypeFilter(SportType,Bettype)
	SELECT SportType,Bettype
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)	


	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,Child_DisplayOrder)
	SELECT t.SportType,t.BetType,t.SettingType,t.IsLive,t.Parent_ProductSettingID,t.ProductSettingID,t.Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency) AS t
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)	

	UPDATE t
	SET t.ParentSportType = par.SportType
		, t.ParentBetType = par.BetType
		, t.Child_DisplayOrder = d.Child_DisplayOrder
	FROM #SportBettypeFilter t 
		INNER JOIN #ProductSettingDetail d WITH(NOLOCK)
			ON t.sporttype = d.SportType
			AND t.bettype = d.BetType
			AND d.SettingType = 21
		LEFT JOIN #ProductSettingDetail par WITH(NOLOCK) 
				ON d.Parent_ProductSettingID = par.ProductSettingID

	IF @RoleID = 4
	BEGIN
		INSERT INTO #DownlineDisableStatus (Sporttype, Bettype, TotalDisabledMasters, TotalDisabledAgents, TotalDisabledMembers, TotalDisabledSuperDirectMembers, TotalDisabledMasterDirectMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend NOT IN (-3,-4) THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -4 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -3 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.srecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		INSERT INTO #DownlineEnableStatus (Sporttype, Bettype, TotalEnabledMasters, TotalEnabledAgents, TotalEnabledMembers, TotalEnabledSuperDirectMembers, TotalEnabledMasterDirectMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend NOT IN (-3,-4) THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -4 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -3 THEN 1 ELSE 0 END)
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
				ISNULL(dsd.TotalDisabledSuperDirectMembers,0) AS TotalDisabledSuperDirectMembers,
				ISNULL(dse.TotalEnabledSuperDirectMembers,0) AS TotalEnabledSuperDirectMembers,
				ISNULL(dsd.TotalDisabledMasterDirectMembers,0) AS TotalDisabledMasterDirectMembers,
				ISNULL(dse.TotalEnabledMasterDirectMembers,0) AS TotalEnabledMasterDirectMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END	
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO #DownlineDisableStatus (Sporttype, Bettype, TotalDisabledMasters, TotalDisabledAgents, TotalDisabledMembers, TotalDisabledMasterDirectMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend NOT IN (-3,-4) THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -3 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.mrecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) = 1
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		GROUP BY ft.SportType, ft.Bettype

		INSERT INTO #DownlineEnableStatus (Sporttype, Bettype, TotalEnabledMasters, TotalEnabledAgents, TotalEnabledMembers, TotalEnabledMasterDirectMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend NOT IN (-3,-4) THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND ci.recommend = -3 THEN 1 ELSE 0 END)
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
				0 AS TotalDisabledSuperDirectMembers,
				0 AS TotalEnabledSuperDirectMembers,
				ISNULL(dsd.TotalDisabledMasterDirectMembers,0) AS TotalDisabledMasterDirectMembers,
				ISNULL(dse.TotalEnabledMasterDirectMembers,0) AS TotalEnabledMasterDirectMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType		
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
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
				0 AS TotalDisabledSuperDirectMembers,
				0 AS TotalEnabledSuperDirectMembers,
				0 AS TotalDisabledMasterDirectMembers,
				0 AS TotalEnabledMasterDirectMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID		
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END	
	ELSE IF @RoleID = 1
	BEGIN
		SELECT @UplineID = CASE WHEN @AgentID = -4 THEN @SuperID 
								WHEN @AgentID = -3 THEN @MasterID 
								ELSE @AgentID
							END
		
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
				0 AS TotalDisabledSuperDirectMembers,
				0 AS TotalEnabledSuperDirectMembers,
				0 AS TotalDisabledMasterDirectMembers,
				0 AS TotalEnabledMasterDirectMembers,
				ft.ParentSportType,
				ft.ParentBetType
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @UplineID
		WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY ft.Child_DisplayOrder
	END

	DROP TABLE #SportBettypeFilter
	DROP TABLE #DownlineDisableStatus
	DROP TABLE #DownlineEnableStatus
	DROP TABLE #ProductSettingDetail
END
GO

