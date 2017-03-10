ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20170125@Elodie
	Task : Get New product Status setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
	
	Param's Explanation: 

	Example: EXEC Acc_CustSetting_DisableNewProductStatusSelect @CustID = 1275, @ProductID = 23
	
	
	*/
BEGIN
	DECLARE	@Currency	TINYINT,
			@RoleID		TINYINT,
			@SuperID	INT,
			@MasterID	INT,
			@AgentID	INT,
			@downlines	BIT  = 0

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
		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE srecommend = @CustID	AND roleid = 3
					)
			SET @downlines = 1			
			
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(CASE WHEN @downlines = 0 THEN 0
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE srecommend = @CustID	AND roleid = 3
											AND IsSynced.value = 1
										), 0) END AS BIT) AS HasDownline,
				CAST(CASE WHEN @downlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE srecommend = @CustID	AND roleid = 3
											AND IsSynced.value = 1
											AND IsDisabled.value = 1
										), 0) END AS BIT) AS IsDisabledDownline,
				CAST(0 AS BIT) AS isDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
	END	
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE mrecommend = @CustID	AND roleid = 2
					)
			SET @downlines = 1	
		
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(CASE WHEN @downlines = 0 THEN 0
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE mrecommend = @CustID	AND roleid = 2
											AND IsSynced.value = 1
										), 0) END AS BIT) AS HasDownline,
				CAST(CASE WHEN @downlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE mrecommend = @CustID	AND roleid = 2
											AND IsSynced.value = 1
											AND IsDisabled.value = 1
										), 0) END AS BIT) AS IsDisabledDownline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID;
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS ( SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE recommend = @CustID AND roleid = 1
					)
			SET @downlines = 1	
	
		SELECT	ft.SportType,
				ft.BetType,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapHasSynced, PSP.bitmapOrder)) as IsSync,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) as isHidden,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
				CAST(CASE WHEN @downlines = 0 THEN 0
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE recommend = @CustID AND roleid = 1
											AND IsSynced.value = 1
										), 0) END AS BIT) AS HasDownline,
				CAST(CASE WHEN @downlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
							ELSE ISNULL((
										SELECT TOP 1 1
										FROM dbo.custInfo ci WITH (NOLOCK)
											INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
											OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
										WHERE recommend = @CustID AND roleid = 1
											AND IsSynced.value = 1
											AND IsDisabled.value = 1
										), 0) END AS BIT) AS IsDisabledDownline,
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
				CAST(0 AS BIT) AS HasDownline,
				CAST(0 AS BIT) AS IsDisabledDownline,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline
		FROM #SportBettypeFilter ft 
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @AgentID
	END
	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_DisableNewProductStatusSelect] TO [vnteam]

