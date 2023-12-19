/*<info serverAlias="DBAGE-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductListInfoSel] 
	@CustId INT,
	@CreationStatus TINYINT = 0		
AS  
/*  
	 Created: 20230627@Johnson  
	 Task : Get Product List info for Lite Mode notes
	 DB:  DBAGE/bodb02  
	
	 Revisions: 
		- 20230627@Johnson: initial sp [redmine: #179159]
		- 20231201@Johnson: Separate PT for Live & RNG Casino [redmine: #197629]
	 Param's Explanation: 
		@CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO
 */  
BEGIN   
	SET NOCOUNT ON
	DECLARE @SiteID INT, @Currency INT 
	CREATE TABLE #OfferedProduct
	(
		RealProductID TINYINT,
		IsHidden BIT,
		EndOfSupportDate DATE
	)

	CREATE TABLE #ProductInfo
	(
		GroupID TINYINT,
		SubGroupID TINYINT,
		SubGroupOrder TINYINT,				
		RealProductID TINYINT
	)
	
	SELECT @SiteID = SiteID, @Currency = Currency 
	FROM customer c WITH(NOLOCK)
		INNER JOIN Site s WITH(NOLOCK) ON c.Site = s.Site
	WHERE custid = @custid	
	
	INSERT INTO #OfferedProduct
	EXEC Age_GetOfferedProductByCust @CustId = @CustId, @SettingStatus  = @CreationStatus

	INSERT INTO #OfferedProduct
	SELECT 16, 0, NULL -- hardcode for SB2

	IF @CreationStatus IN (1,0)
	BEGIN
		INSERT INTO #ProductInfo (GroupID,SubGroupID,SubGroupOrder,RealProductID)
		SELECT DISTINCT GroupID,SubGroupID,0 SubGroupOrder,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType			
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin
			AND GroupType = 153-- PT
			AND MarketType = 0
		UNION ALL
		SELECT DISTINCT GroupID,SubGroupID,0 SubGroupOrder,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType						
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin
			AND GroupType = 153-- PT
			AND MarketType = 1
			AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END			
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --FGG
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
			AND GroupID = 3--Live & RnG CS
			AND GroupType = 153-- PT
			AND (t.Productid <> 44 OR s.RealProductId = 50)
			AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
			AND GroupID = 3--Live & RnG CS
			AND GroupType = 153-- PT
			AND t.Productid IN (18,41)
			AND MarketType = 0 
			AND s.SportType NOT IN (SELECT DISTINCT SportType --Live Casino(SABA casino)
									FROM dbo.ProductSettingProfile t WITH(NOLOCK)
									WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
									  AND GroupID = 3--Live & RnG CS
									  AND GroupType = 153-- PT									 
									  AND MarketType = 1	  
									)
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino(SABA casino)
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.SportType = s.SportType	
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
			AND GroupID = 3--Live & RnG CS
			AND GroupType = 153-- PT
			AND t.Productid IN (18,41)
			AND MarketType = 1 	
			AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --Saba Casino,Virtual Games,Vgaming
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 1
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END			
		ORDER BY GroupID,SubGroupOrder  
	END
	ELSE IF @CreationStatus = 3
	BEGIN	
		INSERT INTO #ProductInfo (GroupID,SubGroupID,SubGroupOrder,RealProductID)
		SELECT DISTINCT GroupID,SubGroupID,0 SubGroupOrder,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)			
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType
		WHERE CreationStatus <> 2
		  AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin	
		  AND GroupType = 153-- PT
		  AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,0 SubGroupOrder,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType
		WHERE CreationStatus <> 2
		  AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin	
		  AND GroupType = 153-- PT
		  AND MarketType = 1
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --FGG
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
		WHERE CreationStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 0
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID
		WHERE CreationStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND t.Productid IN (18,41)
		  AND MarketType = 0 
		  AND s.SportType NOT IN (SELECT DISTINCT SportType --Live Casino(SABA casino)
									FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
									WHERE CreationStatus <> 2
									  AND GroupID = 3--Live & RnG CS
									  AND GroupType = 153-- PT									 
									  AND MarketType = 1	  
									)
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --RNG Slot,Live Casino(SABA casino)
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.SportType = s.SportType			 			
		WHERE CreationStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND t.Productid IN (18,41)
		  AND MarketType = 1 	
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		UNION ALL  		
		SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,s.RealProductID --Saba Casino,Virtual Games,Vgaming
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN ProductProfileSiteCurrency_UAT p WITH(NOLOCK) ON t.ProductSettingID = p.ProductSettingID AND SiteID = @SiteID
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND t.RealProductId = s.RealProductId
		WHERE CreationStatus <> 2
		  AND GroupID = 3--Live & RnG CS
		  AND GroupType = 153-- PT
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		  AND MarketType = 1  
		  AND 1 = CASE WHEN p.Currency = 0 OR p.Currency = @Currency THEN 1 ELSE 0 END
		ORDER BY GroupID,SubGroupOrder
	END
	
	SELECT DISTINCT GroupID,SubGroupID,SubGroupOrder,p.RealProductID
	FROM #ProductInfo p
		INNER JOIN #OfferedProduct po ON p.RealProductID = po.RealProductID 
	WHERE po.IsHidden = 0 AND (po.EndOfSupportDate > GETDATE() OR po.EndOfSupportDate IS NULL)	
	ORDER BY GroupID,SubGroupOrder
END
