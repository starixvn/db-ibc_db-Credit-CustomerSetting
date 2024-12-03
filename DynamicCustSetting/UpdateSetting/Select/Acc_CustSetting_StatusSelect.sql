/*<info serverAlias="DBCUST-CustDB, DBAGE-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_StatusSelect]   
   @CustID  INT  
 , @ProductID TINYINT = NULL  
 , @RoleID INT = NULL  
 , @SettingType TINYINT = NULL
 , @SettingStatus TINYINT = 0
AS  
/*  
 Created: 20180611@Elodie 
 Task : setting values of a product  
 DB: DBCUST/CustDB, DBAGE/bodb02  
 Original:  
  
 Revisions:  
	- 20180611@Elodie: Setting status of a product [Redmine: #58776]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	- 20221006@Winfred: Macau Game - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20221207@Tacy: Alpha - API Management - Support data through API [RedmineID: #171247]
	- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20230726@Tacy: Enhance performance [redmine: #190504]
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
	- 20241017@Johnson: remove column IsSync, isSyncedUpline [redmine: #201396]
 Param's Explanation:  
	- @SettingStatus: 0: Pro, 1: UAT
 
 Example: EXEC Acc_CustSetting_StatusSelect_UAT4 @CustID = 112225441, @ProductID = 53, @RoleID = 3, @SettingType = 21 , @SettingStatus = 3
   
 */  
BEGIN  
   
	DECLARE @downlines BIT  = 0   
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT , @IsIMBC BIT = 0   , @SiteID INT  , @CurrencyID  INT
   
	-- Get line information
	SELECT @SuperID = c.srecommend, @MasterID = mrecommend, @AgentID = c.recommend , @SiteID = s.siteid , @CurrencyID = c.currency
	FROM customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @CustID 
   
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @SuperID AND [Site] = 'IMBC')  
		SET @IsIMBC = 1  
    
	CREATE TABLE #SportBettypeFilter (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType TINYINT, RealProductID TINYINT, Child_DisplayOrder INT)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		Child_DisplayOrder INT,
		GroupID	TINYINT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID
	FROM dbo.f_CustSetting_ProductProfileSel(@SettingType,@SettingStatus,@SiteID,@CurrencyID)

	INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType,Child_DisplayOrder, RealProductID)
	SELECT ProductID,SportType,Bettype,IsLive, SettingType ,Child_DisplayOrder, RealProductID
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4,@SettingStatus)
	WHERE @SettingType IS NULL OR @SettingType = 4

	INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType,Child_DisplayOrder, RealProductID)
	SELECT ProductID,SportType,Bettype,IsLive, SettingType,Child_DisplayOrder, RealProductID
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus)
	WHERE @SettingType IS NULL OR @SettingType = 11

	INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType,Child_DisplayOrder, RealProductID)
	SELECT ProductID,SportType,Bettype,IsLive, SettingType ,Child_DisplayOrder, RealProductID
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus)
	WHERE @SettingType IS NULL OR @SettingType = 13	

	INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType,Child_DisplayOrder, RealProductID)
	SELECT ProductID,SportType,Bettype,IsLive, SettingType ,Child_DisplayOrder, RealProductID
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,21,@SettingStatus)
	WHERE @SettingType IS NULL OR @SettingType = 21

	DELETE FROM #SportBettypeFilter WHERE SportType = 161 --not show NG Status

	IF @RoleID = 4  
	BEGIN  
		IF EXISTS (SELECT 1 FROM custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)  
			SET @downlines = 1     
     
		SELECT ft.RealProductID, ft.ProductID, ft.SportType, ft.BetType,  			
			CAST(CASE WHEN @IsIMBC = 0 AND ft.ProductID = 20 THEN 1 
				ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, psp.bitmapOrder)) END AS BIT) AS isHidden,    
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabled, 
						
			1 AS isHiddenUpline,  
			0 AS isDisabledUpline, 
			
			CAST(CASE WHEN @downlines = 0 THEN 0
					ELSE ISNULL((	
							SELECT TOP 1 1  
							FROM dbo.custInfo ci WITH (NOLOCK)  
								CROSS APPLY (SELECT TOP 1 1 as value FROM dbo.CustProductStatus cps_temp 
											 WHERE ci.custid = cps_temp.CustID  
												AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder)) = 1) t
							WHERE srecommend = @CustID  
								AND ci.roleid IN (3,2,1)
							), 0) END AS BIT)  HasDownline ,
			psd.GroupID
		FROM #SportBettypeFilter ft 
			INNER JOIN #ProductSettingDetail psd ON ft.SportType = psd.SportType AND ft.Bettype = psd.BetType AND ft.IsLive = psd.IsLive AND ft.SettingType = psd.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Bettype = ft.BetType AND psp.Sporttype = ft.SportType                 
			CROSS JOIN dbo.CustProductStatus stt WITH (NOLOCK)
		WHERE stt.CustID = @CustID  
		ORDER BY ft.ProductID, ft.Child_DisplayOrder
    
	END  
	ELSE IF @RoleID = 3  
	BEGIN  
		IF EXISTS (SELECT 1 FROM custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 2)  
			SET @downlines = 1   
     
		SELECT ft.RealProductID, ft.ProductID, ft.SportType, ft.BetType, 
			
			CAST(CASE WHEN @IsIMBC = 0 AND ft.ProductID = 20 THEN 1 
				ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, psp.bitmapOrder)) END AS BIT) AS isHidden,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabled, 
						
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, psp.bitmapOrder)) AS isHiddenUpline,   
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabledUpline, 
			
			CAST(CASE WHEN @downlines = 0 THEN 0
					ELSE ISNULL((	
							SELECT TOP 1 1  
							FROM dbo.custInfo ci WITH (NOLOCK)  
								CROSS APPLY (SELECT TOP 1 1 as value FROM dbo.CustProductStatus cps_temp 
											 WHERE ci.custid = cps_temp.CustID  
												AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder)) = 1) t  
							WHERE mrecommend = @CustID  
								AND ci.roleid IN (2,1)
							), 0) END AS BIT)  HasDownline  ,
			psd.GroupID
		FROM #SportBettypeFilter ft 
			INNER JOIN #ProductSettingDetail psd ON ft.SportType = psd.SportType AND ft.Bettype = psd.BetType AND ft.IsLive = psd.IsLive AND ft.SettingType = psd.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Bettype = ft.BetType AND psp.Sporttype = ft.SportType                 
			CROSS JOIN dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)
		WHERE stt.CustID = @CustID AND stt_UPLINE.CustID = @SuperID  
		ORDER BY ft.ProductID, ft.Child_DisplayOrder
	END     
	ELSE IF @RoleID = 2  
	BEGIN  
		IF EXISTS ( SELECT 1 FROM custinfo WITH (NOLOCK) WHERE recommend = @CustID AND roleid = 1)  
			SET @downlines = 1   
     
		SELECT ft.RealProductID, ft.ProductID, ft.SportType, ft.BetType, 
			
			CAST(CASE WHEN @IsIMBC = 0 AND ft.ProductID = 20 THEN 1 
				ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, psp.bitmapOrder)) END AS BIT) AS isHidden,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabled, 
						
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, psp.bitmapOrder)) AS isHiddenUpline,   
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabledUpline, 
			
			CAST(CASE WHEN @downlines = 0 THEN 0
					ELSE ISNULL((	
							SELECT TOP 1 1  
							FROM dbo.custInfo ci WITH (NOLOCK)  
								CROSS APPLY (SELECT TOP 1 1 as value FROM dbo.CustProductStatus cps_temp 
											 WHERE ci.custid = cps_temp.CustID  
												AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder)) = 1) t  
							WHERE recommend = @CustID  
								AND ci.roleid=1
							), 0) END AS BIT)  HasDownline  ,
			psd.GroupID
		FROM #SportBettypeFilter ft 
			INNER JOIN #ProductSettingDetail psd ON ft.SportType = psd.SportType AND ft.Bettype = psd.BetType AND ft.IsLive = psd.IsLive AND ft.SettingType = psd.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Bettype = ft.BetType AND psp.Sporttype = ft.SportType                 
			CROSS JOIN dbo.CustProductStatus stt WITH (NOLOCK) 
			CROSS JOIN dbo.CustProductStatus stt_UPLINE WITH (NOLOCK) 
		WHERE stt.CustID = @CustID AND stt_UPLINE.CustID = @MasterID
		ORDER BY ft.ProductID, ft.Child_DisplayOrder
	END   
	ELSE IF @RoleID = 1  
	BEGIN  
		SELECT ft.RealProductID, ft.ProductID, ft.SportType, ft.BetType, 
			
			CAST(CASE WHEN @IsIMBC = 0 AND ft.ProductID = 20 THEN 1 
				ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, psp.bitmapOrder)) END AS BIT) AS isHidden,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabled, 
						
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, psp.bitmapOrder)) AS isHiddenUpline,   
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, psp.bitmapOrder)) AS isDisabledUpline, 
			
			0 As HasDownline    ,
			psd.GroupID
		FROM #SportBettypeFilter ft 
			INNER JOIN #ProductSettingDetail psd ON ft.SportType = psd.SportType AND ft.Bettype = psd.BetType AND ft.IsLive = psd.IsLive AND ft.SettingType = psd.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Bettype = ft.BetType AND psp.Sporttype = ft.SportType                 
			CROSS JOIN dbo.CustProductStatus stt WITH (NOLOCK)
			CROSS JOIN dbo.CustProductStatus stt_UPLINE WITH (NOLOCK)
		WHERE stt.CustID = @CustID AND stt_UPLINE.CustID = @AgentID
		ORDER BY ft.ProductID, ft.Child_DisplayOrder
	END   
END
GO