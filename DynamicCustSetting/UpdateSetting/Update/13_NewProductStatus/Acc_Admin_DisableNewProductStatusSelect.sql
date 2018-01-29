/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO
 
ALTER PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatusSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20180118@Elodie
	Task : Get New product Status setting values of a product on NAP & ExtNAP
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20180118@Elodie: Get New product Status setting values of a product on NAP & ExtNAP [RedmineID:#87328]

	Param's Explanation: 

	Example: EXEC Acc_Admin_DisableNewProductStatusSelect @CustID = 1275, @ProductID = 23
	
	
	*/
BEGIN
	DECLARE	@Currency				TINYINT,
			@RoleID					TINYINT,
			@SuperID				INT,
			@MasterID				INT,
			@AgentID				INT

	CREATE TABLE #DownlineStatus (	Sporttype SMALLINT, Bettype SMALLINT, 
									TotalDisabledMasters INT,
									TotalEnabledMasters INT,
									TotalDisabledAgents INT,
									TotalEnabledAgents INT,
									TotalDisabledMembers INT,
									TotalEnabledMembers INT)

	SELECT SportType,Bettype
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13)
	
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
		INSERT INTO #DownlineStatus (Sporttype, Bettype, TotalDisabledMasters, TotalEnabledMasters, TotalDisabledAgents, TotalEnabledAgents, TotalDisabledMembers, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				SUM(CASE WHEN roleid = 3 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 3 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.srecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID
		
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(0 AS BIT) AS isDisabledUpline,
				CAST(0 AS BIT) AS isHiddenUpline,
				TotalDisabledMasters,
				TotalEnabledMasters, 
				TotalDisabledAgents, 
				TotalEnabledAgents, 
				TotalDisabledMembers,
				TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN #DownlineStatus ds ON ds.Bettype = ft.BetType AND ds.Sporttype = ft.SportType		
	END	
	ELSE IF @RoleID = 3
	BEGIN
		INSERT INTO #DownlineStatus (Sporttype, Bettype, TotalDisabledMasters, TotalEnabledMasters, TotalDisabledAgents, TotalEnabledAgents, TotalDisabledMembers, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				0,
				0,
				SUM(CASE WHEN roleid = 2 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 2 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.mrecommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID

		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder)) AS isHiddenUpline,
				TotalDisabledMasters,
				TotalEnabledMasters, 
				TotalDisabledAgents, 
				TotalEnabledAgents, 
				TotalDisabledMembers,
				TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			INNER JOIN #DownlineStatus ds ON ds.Bettype = ft.BetType AND ds.Sporttype = ft.SportType		
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO #DownlineStatus (Sporttype, Bettype, TotalDisabledMasters, TotalEnabledMasters, TotalDisabledAgents, TotalEnabledAgents, TotalDisabledMembers, TotalEnabledMembers)
		SELECT	ft.SportType, ft.Bettype,
				0,
				0,
				0,
				0,
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1 THEN 1 ELSE 0 END),
				SUM(CASE WHEN roleid = 1 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 0 THEN 1 ELSE 0 END)
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON ci.recommend = @CustID AND ci.custid <> @CustID
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = ci.CustID

		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder)) AS isHiddenUpline,
				TotalDisabledMasters,
				TotalEnabledMasters, 
				TotalDisabledAgents, 
				TotalEnabledAgents, 
				TotalDisabledMembers,
				TotalEnabledMembers
		FROM #SportBettypeFilter ft 
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID		
			INNER JOIN #DownlineStatus ds ON ds.Bettype = ft.BetType AND ds.Sporttype = ft.SportType		
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

