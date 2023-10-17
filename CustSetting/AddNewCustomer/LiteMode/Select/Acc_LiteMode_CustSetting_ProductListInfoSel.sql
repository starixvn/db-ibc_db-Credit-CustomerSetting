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

	 Param's Explanation: 
		@CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO
 */  
BEGIN   
	SET NOCOUNT ON
	CREATE TABLE #OfferedProduct
	(
		RealProductID TINYINT,
		IsHidden BIT,
		EndOfSupportDate DATE
	)

	CREATE TABLE #ProductInfo
	(
		GroupID TINYINT,
		ProductID TINYINT,
		RealProductID TINYINT
	)

	INSERT INTO #OfferedProduct
	EXEC Age_GetOfferedProductByCust @CustId = @CustId, @SettingStatus  = @CreationStatus

	INSERT INTO #OfferedProduct
	SELECT 16, 0, NULL -- hardcode for SB2

	IF @CreationStatus IN (1,0)
	BEGIN
		INSERT INTO #ProductInfo (GroupID, ProductID, RealProductID)
		SELECT DISTINCT GroupID,0 ProductID,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
		  AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin	
		UNION ALL  		
		SELECT DISTINCT GroupID,CASE WHEN t.ProductID <> 41 THEN 53 ELSE t.ProductID END ,s.RealProductID --Saba Casino,RNG Slot
		FROM dbo.ProductSettingProfile t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
		  AND GroupID = 3--Live & RnG CS
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		ORDER BY GroupID,ProductID  
	END
	ELSE IF @CreationStatus = 3
	BEGIN	
		INSERT INTO #ProductInfo (GroupID, ProductID, RealProductID)
		SELECT DISTINCT GroupID,0 ProductID,CASE WHEN t.ProductID = 16 THEN t.ProductID ELSE s.RealProductID END AS RealProductID 
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID AND CASE WHEN t.SportType = 9908 THEN 180 ELSE t.SportType END = s.SportType
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
		  AND GroupID IN ( 1,2,4) --SB,SB2, RnG Games, Bitcoin	
		UNION ALL  		
		SELECT DISTINCT GroupID,CASE WHEN t.ProductID <> 41 THEN 53 ELSE t.ProductID END ,s.RealProductID --Saba Casino,RNG Slot
		FROM dbo.ProductSettingProfile_UAT t WITH(NOLOCK)
			INNER JOIN SportBettypeSettingMatrix s WITH(NOLOCK) ON t.ProductID = s.ProductID
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END 
		  AND GroupID = 3--Live & RnG CS
		  AND (t.Productid <> 44 OR s.RealProductId = 50)
		ORDER BY GroupID,ProductID   		
	END

	SELECT GroupID, ProductID, p.RealProductID
	FROM #ProductInfo p
		INNER JOIN #OfferedProduct po ON p.RealProductID = po.RealProductID 
	WHERE po.IsHidden = 0 AND (po.EndOfSupportDate > GETDATE() OR po.EndOfSupportDate IS NULL)	
END