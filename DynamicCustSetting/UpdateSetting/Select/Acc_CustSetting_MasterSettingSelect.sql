ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterSettingSelect]   
	@CustID			INT  
	, @ProductID	TINYINT  
	, @SettingType	SMALLINT
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get Master'setting values of a product  
 DB:  DBCUST/CustDB  
 Original:  
 
 Revision:
	- 20160104@Dominic: Implementing Charge Commission Plugin Redmine #49689
	- 20160801@Elodie: Move commission part to Acc_CustSetting_DiscountSelect [Redmine: #60809]
  
 Param's Explanation:  
 • @CustID: Master's ID  
   
 */  
BEGIN  
	DECLARE @SuperID INT  

	SELECT SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
	
	SELECT @SuperID=ci.srecommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID  
	
	--PT Setting 
	IF @SettingType = 1
	BEGIN 
		SELECT pdt.SportType  
			, pdt.BetType  
			, pdt.IsLive  
			, pt.superPT  AS S3  
			, pt.masterPT  AS M3  
			, pt.IsAutoSuperPT AS IS3  
			, pt.AutoSuperPT AS US3  
			, pt.minPT   AS N3  
			, superpt.SuperPT AS S4  
			, superpt.MasterPT AS M4  
			, superpt.MinPT  AS N4  
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
		INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
			ON pdt.SportType = superpt.sporttype  
			AND pdt.BetType = superpt.bettype  
			AND pdt.IsLive = superpt.islive  
			AND superpt.custid = @SuperID   
	END
	--Bet Limit Setting
	ELSE IF @SettingType = 2
	BEGIN 
		DECLARE @Currency TINYINT  

		SELECT @Currency = Currency  
		FROM dbo.Customer c  
		WHERE c.custID = @CustID  
 
		SELECT pdt.SportType  
		, pdt.BetType  
		, bl.MinBet  
		, bl.MaxBet  
		, bl.MaxPerMatch  
		, CASE   
			WHEN sbl.minbet > pbs.MinBet  
			THEN sbl.minbet  
			ELSE pbs.MinBet  
		END AS MinBetMin  
		, sbl.maxbet AS MaxBetMax  
		, sbl.maxpermatch AS MaxPerMatchMax  
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
		INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)  
			ON pdt.SportType = sbl.sporttype  
			AND pdt.BetType = sbl.bettype  
			AND sbl.custid = @SuperID  
	END 
	----Discount Setting  / Charge Comm
	--ELSE IF @SettingType IN (3,5)
	--BEGIN 
	--	SELECT pdt.SportType  
	--		, pdt.BetType  
	--		, dc.Discount AS MasterDiscount  
	--		, sdc.Discount AS SuperDiscount  
	--	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)  
	--	INNER JOIN #SportBettypeFilter ft 
	--			ON pdt.SportType = ft.sporttype
	--				AND pdt.BetType = ft.bettype
	--				AND pdt.IsLive = ft.islive
	--				AND pdt.SettingType = ft.SettingType
	--	INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)  
	--		ON pdt.SportType = dc.sporttype  
	--		AND pdt.BetType = dc.bettype  
	--		AND dc.custid = @CustID  
	--	INNER JOIN dbo.CustDiscount3rd_Agent sdc WITH (NOLOCK)  
	--		ON pdt.SportType = sdc.sporttype  
	--		AND pdt.BetType = sdc.bettype  
	--		AND sdc.custid = @SuperID  
	--END
	--Product Status  
	ELSE IF @SettingType = 4
	BEGIN 
		
		DECLARE @downlines BIT  = 0 
		
		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE mrecommend = @CustID	AND roleid = 2
					)
			SET @downlines = 1	
		
		SELECT 	pdt.SportType
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
							WHERE mrecommend = @CustID	AND roleid = 2
								AND dbo.f_GetProductStatus(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) = 1
							), 0)
							
			 END AS BIT) AS IsDisabledDownline
										 
			, dbo.f_GetProductStatus(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder) as IsDisabledUpline
		
		FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype
												AND pdt.BetType = ft.bettype
												AND pdt.IsLive = ft.islive
												AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType															
			INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @CustID
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @SuperID
			
		WHERE pdt.SettingType = @SettingType
		
	END    
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterSettingSelect] TO [bodbExtAccNet]