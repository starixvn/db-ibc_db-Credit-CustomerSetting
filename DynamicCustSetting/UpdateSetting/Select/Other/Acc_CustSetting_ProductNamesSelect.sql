/*<info serverAlias="DBAGE-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_ProductNamesSelect]   
   @ProductID TINYINT = NULL,
   @SettingType SMALLINT = NULL,
   @LanguageKey CHAR(2) = ''
AS  
/*  
 Created: 20150226@Dominic  
 Task : Get names in multi-language of one or all products  
 DB:  DBAGE/bodb02  
 Original:  
  
 Param's Explanation:  
	• @ProductID: ID of a product, NULL to get all products  
	• @SettingType: 1: PT 
					2: BetLimit
					3: Comm
					4: ProductStatus
 Revision:
    - add new parameter @SettingType
	- 20200321@Tiara: Handle dummy product for Sexy Gaming/Allbet/SA Gaming [Redmine: #130678]
   
 */  
BEGIN  
	DECLARE @DCSProducts TABLE(ProductID TINYINT)
	CREATE TABLE #TmpProductSettingDetail
	(
		SettingType SMALLINT,
		SportType SMALLINT,
		ProductID TINYINT
	)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(1,211,21)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(3,211,21)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(6,211,21)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(7,211,21)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(13,211,21)

	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(1,244,39)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(3,244,39)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(6,244,39)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(7,244,39)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(13,244,39)
	
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(1,243,45)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(3,243,45)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(6,243,45)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(7,243,45)
	INSERT INTO #TmpProductSettingDetail ([SettingType],[SportType],[ProductID]) VALUES(13,243,45)
	
	INSERT @DCSProducts
	SELECT DISTINCT ProductID
	FROM dbo.ProductSettingDetail
	WHERE SettingStatus < 2 AND (@SettingType IS NULL OR SettingType = @SettingType)
		AND ProductID <> 41
	UNION ALL
	SELECT DISTINCT T.ProductID
	FROM #TmpProductSettingDetail T WITH (NOLOCK) INNER JOIN dbo.ProductSettingDetail P WITH (NOLOCK) ON T.SportType = P.SportType AND T.SettingType = P.SettingType
	WHERE P.SettingStatus < 2 AND (@SettingType IS NULL OR T.SettingType = @SettingType) 
	
	SELECT [ProductID], CASE WHEN SUBSTRING([Language],12,LEN([Language]) - 11) = '' THEN 'EN' ELSE UPPER(SUBSTRING([Language],12,LEN([Language]) - 11)) END [Language], Name
	FROM 
	   (SELECT p.[ProductID]  
			  ,CAST([ProductName]   AS NVARCHAR(50)) [ProductName]
			  ,ISNULL([ProductNameCh],[ProductName])  ProductNameCh  
			 ,ISNULL([ProductNameCs],[ProductName])  ProductNameCs    
			 ,ISNULL([ProductNameJp],[ProductName])  ProductNameJp   
			 ,ISNULL([ProductNameIt],[ProductName])  ProductNameIt     
			 ,ISNULL([ProductNameTh],[ProductName])  ProductNameTh     
			 ,ISNULL([ProductNameKo],[ProductName])  ProductNameKo     
			 ,ISNULL([ProductNameES],[ProductName])  ProductNameES     
			 ,ISNULL([ProductNameVN],[ProductName])  ProductNameVN     
			 ,ISNULL([ProductNameEL],[ProductName])  ProductNameEL     
			 ,ISNULL([ProductNameRU],[ProductName])  ProductNameRU     
			 ,ISNULL([ProductNameID],[ProductName])  ProductNameID    
		  FROM [dbo].[Products] p 
		  INNER JOIN @DCSProducts f ON f.ProductID = p.ProductID
		  WHERE @ProductID IS NULL OR p.[ProductID]=@ProductID  ) p
	UNPIVOT
	   (Name FOR [Language] IN 
		  ([ProductName],[ProductNameCh]  
			  ,[ProductNameCs]  
			  ,[ProductNameJp]  
			  ,[ProductNameIt]  
			  ,[ProductNameTh]  
			  ,[ProductNameKo]  
			  ,[ProductNameES]  
			  ,[ProductNameVN]  
			  ,[ProductNameEL]  
			  ,[ProductNameRU]  
			  ,[ProductNameID])
	)AS unpvt
	WHERE SUBSTRING([Language],12,LEN([Language]) - 11) = @LanguageKey
		OR (SUBSTRING([Language],12,LEN([Language]) - 11) = '' AND @LanguageKey='EN')
	;
	DROP TABLE #TmpProductSettingDetail
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ProductNamesSelect] TO [bodbExtAccNet]