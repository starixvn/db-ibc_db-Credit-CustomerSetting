ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperSettingSelect] 
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingType	SMALLINT
AS
/*
	Created: 20141104@Dominic
	Task : Get Super'setting values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20160104@Dominic: Implementing Charge Commission Plugin Redmine #49689
		- 20160801@Elodie: Move commission part to Acc_CustSetting_DiscountSelect [Redmine: #60809]
	
	Param's Explanation:
	- @CustID: Super's ID
	
	*/
BEGIN
	
	SELECT SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	--PT Setting
	IF @SettingType = 1
	BEGIN		
		SELECT pdt.SportType
			, pdt.BetType
			, pdt.IsLive
			, pt.SuperPT	AS S4
			, pt.MasterPT	AS M4
			, pt.AgentPT	AS A4
			, pt.MinPT		AS N4
			, pdt.MaxPT		AS DefaultMaxPT
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
		INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
			ON pdt.SportType = pt.sporttype
				AND pdt.BetType = pt.bettype
				AND pdt.IsLive = pt.islive
				AND pt.custid = @CustID
	END
	--Bet Limit Setting
	ELSE IF @SettingType = 2
	BEGIN
		DECLARE @Currency TINYINT
	
		SELECT @Currency = Currency
		FROM dbo.Customer c WITH(NOLOCK)
		WHERE c.custID = @CustID
	
		SELECT pdt.SportType
			, pdt.BetType
			, bl.MinBet
			, bl.MaxBet
			, bl.MaxPerMatch
			, pbs.MinBet AS MinBetMin
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
		INNER JOIN #SportBettypeFilter ft 
				ON pdt.SportType = ft.sporttype
					AND pdt.BetType = ft.bettype
					AND pdt.IsLive = ft.islive
					AND pdt.SettingType = ft.SettingType
		INNER JOIN dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
			ON pdt.SportType = bl.sporttype
				AND pdt.BetType = bl.bettype
				AND bl.custid = @CustID
		INNER JOIN dbo.ProductBetSetting pbs
			ON pbs.SportType = bl.sporttype
				AND pbs.BetType = bl.bettype
				AND pbs.Currency = @Currency
	END
	----Discount Setting / Charge Comm
	--ELSE IF @SettingType IN (3,5)
	--BEGIN
	--	SELECT pdt.SportType
	--		, pdt.BetType
	--		, dc.Discount AS SuperDiscount
	--		, ISNULL(pdt.MaxDiscount, 0) AS DefaultMaxDiscount
	--	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	--	INNER JOIN #SportBettypeFilter ft 
	--			ON pdt.SportType = ft.sporttype
	--				AND pdt.BetType = ft.bettype
	--				AND pdt.IsLive = ft.islive
	--				AND pdt.SettingType = ft.SettingType
	--	INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
	--		ON pdt.SportType = dc.sporttype
	--			AND pdt.BetType = dc.bettype
	--			AND dc.custid = @CustID
	--END
	--Product Status
	ELSE IF @SettingType = 4
	BEGIN
		DECLARE @IsDisabledDownline BIT, @downlines BIT  = 0 

		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE srecommend = @CustID	AND roleid = 3
					)
		SET @downlines = 1			
			
		SELECT pdt.SportType
			, pdt.BetType
			, dbo.f_GetProductStatus(stt.bitmapHasSynced, PSP.bitmapOrder) as IsSync
			, dbo.f_GetProductStatus(stt.bitmapIsHidden, PSP.bitmapOrder) as isHidden
			, dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) as isDisabled
			, @downlines HasDownline
			, CAST(CASE 	
					WHEN @downlines = 0	THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
					ELSE ISNULL((
							SELECT TOP 1 1
							FROM dbo.custInfo ci WITH (NOLOCK)
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
							WHERE srecommend = @CustID	AND roleid = 3
								AND dbo.f_GetProductStatus(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) = 1
							), 0)
							
			 END AS BIT) AS IsDisabledDownline
			, CAST(0 AS BIT) AS isDisabledUpline
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
												AND pdt.BetType = ft.bettype
												AND pdt.IsLive = ft.islive
												AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
		WHERE pdt.SettingType = @SettingType
	END	
	
	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperSettingSelect] TO [bodbExtAccNet]

