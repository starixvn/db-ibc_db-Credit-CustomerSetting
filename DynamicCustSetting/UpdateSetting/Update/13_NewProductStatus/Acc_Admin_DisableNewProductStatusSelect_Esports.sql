/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
USE CustDB
GO
 
ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatusSelect_Esports] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20181026@Winnie
	Task : Get New product Status setting values of a product on ExtNAP
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20181026@Winnie: Get New product Status setting values of a product on ExtNAP [RedmineID:#101526]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]

	Param's Explanation: 

	Example: EXEC Acc_Admin_DisableNewProductStatusSelect @CustID = 1275, @ProductID = 16
	
	
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

	SELECT SportType,Bettype
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus)

	DELETE FROM #SportBettypeFilter WHERE SportType<>43
	
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
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
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
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType		
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
				ISNULL(TotalEnabledMembers,0) AS TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID		
			LEFT JOIN #DownlineEnableStatus dse ON dse.Bettype = ft.BetType AND dse.Sporttype = ft.SportType		
			LEFT JOIN #DownlineDisableStatus dsd ON dsd.Bettype = ft.BetType AND dsd.Sporttype = ft.SportType
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
				0 AS TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
	END
	DROP TABLE #SportBettypeFilter
END
GO

