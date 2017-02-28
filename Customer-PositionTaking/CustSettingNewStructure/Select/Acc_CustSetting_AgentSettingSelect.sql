ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentSettingSelect]   
	@CustID			INT  
	, @ProductID	TINYINT = NULL 
	, @SettingType	SMALLINT = NULL
	, @DisableAutoMPT BIT = 0 OUTPUT
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get Agent'setting values of a product  
 DB:  DBCUST/CustDB  
 Original:  
  
 Revision:
	- 20160104@Dominic: Implementing Charge Commission Plugin Redmine #49689
	- 20160801@Elodie: Move commission part to Acc_CustSetting_DiscountSelect [Redmine: #60809]
	 
 Param's Explanation:  
 • @CustID: Agent's ID  
   
 */  
BEGIN   
	DECLARE @SuperID INT, @MasterID INT  
   
	SELECT SportType,Bettype,IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType)
		
	SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend  
	FROM dbo.custInfo ci WITH(NOLOCK)  
	WHERE ci.custid=@CustID    
	
	--PT Setting  
	IF @SettingType = 1
	BEGIN 	
		--Disable auto master PT  
		SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
		FROM CustMaster WITH (NOLOCK)  
		WHERE CustID = @MasterID 
	
		SELECT pdt.SportType  
			, pdt.BetType  
			, pdt.IsLive  
			, pt.masterPT AS M2  
			, pt.agentPT AS A2  
			, pt.IsAutoMasterPT AS IM2  
			, pt.AutoMasterPT AS UM2  
			, pt.minPT AS N2  
			, CASE   
				WHEN masterpt.masterPT < masterpt.maxPT  
				THEN masterpt.masterPT  
				ELSE masterpt.maxPT  
			END AS M3  
			, masterpt.minPT AS N3  
			, superpt.agentPT AS A4
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
		INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
			ON pdt.SportType = masterpt.sporttype  
			AND pdt.BetType = masterpt.bettype  
			AND pdt.IsLive = masterpt.islive  
			AND masterpt.custid = @MasterID  
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
				WHEN sbl.minbet >= mbl.minbet  
				AND sbl.minbet >= pbs.MinBet  
				THEN sbl.minbet  
				WHEN mbl.minbet >= sbl.minbet  
				AND mbl.minbet >= pbs.MinBet  
				THEN mbl.minbet  
				WHEN pbs.MinBet >= sbl.minbet  
				AND pbs.MinBet >= mbl.minbet  
				THEN pbs.MinBet  
			END AS MinBetMin  
			, CASE   
				WHEN (sbl.maxbet < mbl.maxbet OR mbl.maxbet = 0) AND sbl.maxbet <> 0  
				THEN sbl.maxbet  
				ELSE mbl.maxbet  
			END AS MaxBetMax  
			, CASE   
				WHEN (sbl.MaxPerMatch < mbl.MaxPerMatch OR mbl.MaxPerMatch = 0) AND sbl.MaxPerMatch <> 0  
				THEN sbl.MaxPerMatch  
				ELSE mbl.MaxPerMatch  
			END AS MaxPerMatchMax  
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
		INNER JOIN dbo.CustBetSetting3rd_Agent mbl WITH (NOLOCK)  
			ON pdt.SportType = mbl.sporttype  
			AND pdt.BetType = mbl.bettype  
			AND mbl.custid = @MasterID  
		INNER JOIN dbo.CustBetSetting3rd_Agent sbl WITH (NOLOCK)  
			ON pdt.SportType = sbl.sporttype  
			AND pdt.BetType = sbl.bettype  
			AND sbl.custid = @SuperID  
	END
	----Discount Setting / Charge Comm
	--ELSE IF @SettingType IN (3,5)
	--BEGIN  
	--	SELECT pdt.SportType  
	--		, pdt.BetType  
	--		, dc.Discount AS AgentDiscount  
	--		, mdc.Discount AS MasterDiscount  
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
	--	INNER JOIN dbo.CustDiscount3rd_Agent mdc WITH (NOLOCK)  
	--		ON pdt.SportType = mdc.sporttype  
	--		AND pdt.BetType = mdc.bettype  
	--		AND mdc.custid = @MasterID  
	--END
	--Product Status  
	ELSE IF @SettingType = 4
	BEGIN  
		DECLARE @downlines  BIT = 0
		
		IF EXISTS ( SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE recommend = @CustID	AND roleid = 1
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
							WHERE recommend = @CustID	AND roleid = 1
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
			INNER JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)	ON stt_UPLINE.CustID = @MasterID
			
		WHERE pdt.SettingType = @SettingType
	END  
	
	DROP TABLE #SportBettypeFilter
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentSettingSelect] TO [bodbExtAccNet]