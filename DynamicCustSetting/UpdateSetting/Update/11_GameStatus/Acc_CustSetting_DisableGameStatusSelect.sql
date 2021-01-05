/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableGameStatusSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20160801@Elodie
	Task : Get Game Status setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
		- 20180112@Elodie: Remove HasDownlines and IsDisableDownline value [RedmineID:#87328]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]

	Param's Explanation: 
		- @SettingStatus: 0: Pro, 1: UAT

	Example: EXEC Acc_CustSetting_DisableGameStatusSelect @CustID = 1275, @ProductID = 23
	
	
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT

	SELECT SportType,Bettype
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus)
	
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
				CAST(0 AS BIT) AS isDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
	END	
	ELSE IF @RoleID = 3
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID;
	END
	ELSE IF @RoleID = 2
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID		
	END	
	ELSE 
	BEGIN
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
	END
	DROP TABLE #SportBettypeFilter
END
GO

