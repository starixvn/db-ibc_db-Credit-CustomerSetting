/*<info serverAlias="DBAGE-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductListInfoSel] 
	@CustId INT = NULL,
	@Site VARCHAR(10) = NULL, 
	@Currency INT = NULL,
	@SettingStatus TINYINT = 0
AS  
/*  
	 Created: 20230627@Johnson  
	 Task : Get Product List info for Lite Mode notes 
	 DB:  DBAGE/bodb02  
	
	 Revisions: 
		- 20230627@Johnson: initial sp [redmine: #179159]
		- 20231201@Johnson: Separate PT for Live & RNG Casino [redmine: #197629]
		- 20231219@Johnson: call sp Age_GetOfferedProductBySiteCurrency [redmine: #197629]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240316@Eden: Unify Live RNG Casino [Redmine: #198960]
		- 20240521@Helios: Unify RNG Games [Redmine: #204358]

	 Param's Explanation: 
		@SettingStatus: 0: Pro, 1: UAT, 3: UAT/PRO
 */  

BEGIN   
	SET NOCOUNT ON
	DECLARE @SiteID INT
	CREATE TABLE #OfferedProduct
	(
		RealProductID TINYINT,
		ProductName VARCHAR(50), 
		EndOfSupportDate date, 
		IsHidden BIT,
		[Type] tinyint,
		OrderNo int
	)

	CREATE TABLE #ProductInfo
	(
		GroupID TINYINT,
		SubGroupID TINYINT,
		SubGroupOrder TINYINT,				
		RealProductID TINYINT
	)
	
	IF @custID IS NOT NULL
	BEGIN
		SELECT @SiteID = s.SiteID, @Site = c.Site, @Currency = Currency 
		FROM customer c WITH(NOLOCK)
			INNER JOIN Site s WITH(NOLOCK) ON c.Site = s.Site
		WHERE custid = @custid	
	END
	ELSE -- Create super or Direct Master
	BEGIN
		SELECT @SiteID = s.SiteID
		FROM Site s WITH(NOLOCK) 
		WHERE s.Site = @Site
	END
	
	IF @SiteID IS NOT NULL AND @Currency IS NOT NULL
	BEGIN
		INSERT INTO #OfferedProduct (RealProductID, ProductName, IsHidden, EndOfSupportDate, OrderNo, [Type])
		EXEC Age_GetOfferedProductBySiteCurrency @Site = @Site, @Currency = @Currency, @SettingStatus  = @SettingStatus
	END

	
	IF @SettingStatus IN (1,0)
	BEGIN
		INSERT INTO #ProductInfo (GroupID,SubGroupID,SubGroupOrder,RealProductID)
		
		-- Get data for SportsBook , Bit Coint 
		SELECT DISTINCT GroupID, SubGroupID,0 AS SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
		  AND GroupID IN ( 1,4) 
			AND GroupType = 153-- PT
			AND MarketType = 0
		UNION ALL
		SELECT DISTINCT GroupID, SubGroupID,0 AS SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IN ( 1,4)
			AND GroupType = 153-- PT
			AND MarketType = 1
			AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END	
		UNION ALL

		-- Get data for RNG Games
		SELECT DISTINCT GroupID, SubGroupID,0 AS SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportTypeRefPT AND t.BetType = s.BetTypeRefPT
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 2
			AND GroupType = 153-- PT
			AND MarketType = 0
		UNION ALL
		SELECT DISTINCT GroupID, SubGroupID,0 AS SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportTypeRefPT AND t.BetType = s.BetTypeRefPT	
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 2
			AND GroupType = 153-- PT
			AND MarketType = 1
			AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END	
		UNION ALL  		

		-- Get data for Live & RNG Casino
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --FGG
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 3
			AND GroupType = 153-- PT
			AND (t.Productid <> 44 OR s.RealProductId = 50)
			AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END 
			AND GroupID = 3
			AND GroupType = 153-- PT
			AND t.Productid IN (53,41)
			AND MarketType = 0 
			AND s.SportType NOT IN (SELECT DISTINCT SportType --Live Casino(SABA casino)
									FROM dbo.ProductSettingProfile t WITH(NOLOCK)
									WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
									  AND GroupID = 3--Live & RnG CS
									  AND GroupType = 153-- PT									 
									  AND MarketType = 1	  
									)
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino(SABA casino)
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType	
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END  
			AND GroupID = 3
			AND GroupType = 153-- PT
			AND t.Productid IN (53,41)
			AND MarketType = 1 	
			AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --Saba Casino,Virtual Games,Vgaming
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END 
		  AND GroupID = 3
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 1
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END			
	END
	ELSE IF @SettingStatus = 3
	BEGIN	
		INSERT INTO #ProductInfo (GroupID,SubGroupID,SubGroupOrder,RealProductID)

		-- Get data for SportsBook , Bit Coint 
		SELECT DISTINCT GroupID, SubGroupID,0 SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)			
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID IN ( 1,4) 
		  AND GroupType = 153-- PT
		  AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID, SubGroupID,0 SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID IN ( 1,4) 
		  AND GroupType = 153-- PT
		  AND MarketType = 1
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END

		UNION ALL

		-- Get data for RNG Games
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)			
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportTypeRefPT AND t.BetType = s.BetTypeRefPT
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 2
		  AND GroupType = 153-- PT
		  AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID, SubGroupID, SubGroupOrder, ISNULL(s.RealProductID, t.ProductID) AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			LEFT JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportTypeRefPT AND t.BetType = s.BetTypeRefPT
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 2
		  AND GroupType = 153-- PT
		  AND MarketType = 1
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL

		-- Get data for Live & RNG Casino
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --FGG
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 3
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 3
		  AND GroupType = 153-- PT
		  AND t.Productid IN (53,41)
		  AND MarketType = 0 
		  AND s.SportType NOT IN (SELECT DISTINCT SportType --Live Casino(SABA casino)
									FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
									WHERE SettingStatus <> 2
									  AND GroupID = 3--Live & RnG CS
									  AND GroupType = 153-- PT									 
									  AND MarketType = 1	  
									)
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino(SABA casino)
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.SportType = s.SportType		
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND t.Productid IN (53,41)
		  AND MarketType = 1 	
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --Saba Casino,Virtual Games,Vgaming
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN f_CustSetting_SportBetTypeSettingMatrix (@SettingStatus) s 
				ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId 
				AND s.isLicensee = 0 AND s.Site = 'All'
		WHERE SettingStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 1  
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		
	END

	-- Get data of Sportsbook , RNG Games , Other Games (Bitcoin)
	SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,p.RealProductID
	FROM #ProductInfo p
		INNER JOIN #OfferedProduct po ON p.RealProductID = po.RealProductID 
	WHERE po.IsHidden = 0 AND (po.EndOfSupportDate > GETDATE() OR po.EndOfSupportDate IS NULL)
	AND p.GroupID IN (1,2,4)
	UNION ALL

	-- Get data of Other RNG Casino
	SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,p.RealProductID
	FROM #ProductInfo p
		INNER JOIN #OfferedProduct po ON p.RealProductID = po.RealProductID 
	WHERE po.IsHidden = 0 AND (po.EndOfSupportDate > GETDATE() OR po.EndOfSupportDate IS NULL)
	AND po.Type = 53
	AND p.GroupID = 3
	AND p.SubGroupID = 5
	AND po.RealProductID IN (6,42,66,38,86)
	UNION ALL

	-- Get data of Live & RNG Casino
	SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,p.RealProductID
	FROM #ProductInfo p
		INNER JOIN #OfferedProduct po ON p.RealProductID = po.RealProductID 
	WHERE po.IsHidden = 0 AND (po.EndOfSupportDate > GETDATE() OR po.EndOfSupportDate IS NULL)
	AND po.Type IN (41,53)
	AND p.GroupID = 3
	AND p.SubGroupID IN (6,8)
	AND po.RealProductID NOT IN (6,42,66,38,86)

	ORDER BY GroupID,SubGroupOrder

	DROP TABLE #OfferedProduct
	DROP TABLE #ProductInfo
END
