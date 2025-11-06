/*<info serverAlias="DBCUST-CUSTDB,DBAGE-bodb02" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_StatusSettingSelect]   
   @CustID  INT  
 , @ProductID TINYINT = NULL  
 , @RoleID INT = NULL  
 , @SettingType TINYINT = NULL
 , @SettingStatus TINYINT = 0
 , @GroupID		TINYINT = 0
 , @GroupType	SMALLINT = 0
 , @Mode		BIT	= 0
AS  
/*  
 Created: 20151012@Helen  
 Task : setting values of a product  
 DB: DBCUST/CustDB, DBAGE/bodb02  
 Original:  
  
 Revisions:  
	- 20160114@Helen: Cricket - [Redmine: #50027]  
	- 20160330@Elodie: Get more IsSyncedUpline, IsSyncedDownline infomation [Redmine: #49606]  
	- 20160413@Billy: Remove Site Currency check - [Redmine: #54672]  
	- 20160429@Winnie: Return column IsHiddenUpline for AllBet, VoidBridge  
	- 20160801@Elodie: Get Game status (setting type = 11) - [Redmine: #60809]   
	- 20170307@Elodie: Get New product status (setting type = 13) - [Redmine: #70722]   
	- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
	- 20170803@Winnie: Change Data Type of Sporttype [RedmineID: #73545]
	- 20170919@Johnson: fix the unsynchronized setting, remove IsDownlineSynced 
					and fix hasDownline status to show checkbox enable downline [Redmine: #72973]
						+hasDownline = 1: has at least one customer has sync status
									=0 : all downlines not sync	
	- 20200325@Elodie: Only show sport is unhided [RedmineID:#128058]
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	- 20221006@Winfred: Macau Game - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
	- 20241023@Johnson: remove columns IsSync/IsSyncedUpline [Redmine: #201396]
	- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
	- 20251106@Eden: Enhance SP [RedmineID: #243612]
 Param's Explanation:  
	- @CustID: 
	- @SettingStatus: 0: Pro, 1: UAT
	- @Mode : 0 (default) >> Input @SettingStatus
	- @Mode : 1 >> Input @GroupID , @GroupType
 Example: EXEC Acc_CustSetting_StatusSettingSelect 
									@CustID	    = 112225106
								    , @ProductID	    = NULL
								    , @RoleID	    = 3
								    , @SettingType    = 21
								    , @SettingStatus  = 3
								    , @GroupID	    = 3
								    , @GroupType	    = 160
								    , @Mode		    = 1
	    EXEC Acc_CustSetting_StatusSettingSelect 
									@CustID	    = 112225106
								    , @ProductID	    = 44
								    , @RoleID	    = 3
								    , @SettingType    = 13
								    , @SettingStatus  = 3
								    , @GroupID	    = 0
								    , @GroupType	    = 0
								    , @Mode		    = 0

 */ 

BEGIN  
   
	DECLARE @IsDisabledDownline BIT, @downlines BIT  = 0   
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT , @IsIMBC BIT = 0 , @SiteID	  INT  , @CurrencyID	INT
	DECLARE @_CustID INT -- void parameter sniffing
	SELECT @_CustID = @CustID
   
	-- Get line information
	SELECT @SuperID = c.srecommend, @MasterID = mrecommend, 
	@AgentID = CASE 
				WHEN c.recommend = -3 THEN c.mrecommend
				WHEN c.recommend = -4 THEN c.srecommend
				ELSE c.recommend
			END  
	, @SiteID = s.siteid , @CurrencyID = c.currency
	FROM customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @_CustID  
   
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @SuperID AND [Site] = 'IMBC')  
		SET @IsIMBC = 1  
      
	CREATE TABLE #SportBettypeFilter (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType TINYINT, Child_DisplayOrder INT)

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
 
	IF @Mode =0
	BEGIN
		INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID)
		SELECT SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 4

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 11

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 13	

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,21,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 21
	END
	
	IF @Mode > 0
	BEGIN
		INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID)
		SELECT SportType,BetType,SettingType,IsLive,ProductID,Child_DisplayOrder,GroupID
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
		WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)	

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 4

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 11

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 13	

		INSERT INTO #SportBettypeFilter (ProductID,SportType,Bettype,IsLive, SettingType)
		SELECT ProductID,SportType,Bettype,IsLive, SettingType   
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,21,@SettingStatus)
		WHERE @SettingType IS NULL OR @SettingType = 21
	END

	DELETE FROM #SportBettypeFilter WHERE SportType = 161 --not show NG Status
   
	UPDATE t
	SET t.Child_DisplayOrder = d.Child_DisplayOrder
	FROM #SportBettypeFilter t 
		INNER JOIN #ProductSettingDetail d WITH(NOLOCK)
			ON t.sporttype = d.SportType
			AND t.bettype = d.BetType
			AND t.IsLive = d.IsLive
			AND d.SettingType = t.SettingType

	IF @RoleID = 4  
	BEGIN  
		IF EXISTS (SELECT 1 FROM custinfo WITH (NOLOCK) WHERE srecommend = @_CustID AND Custid <> @CustID)  
			SET @downlines = 1     
     
		SELECT pdt.ProductID, pdt.SportType, pdt.BetType,  			
			CAST(CASE WHEN stt.CustID IS NULL  OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 ELSE   
					(CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden,    
			1 AS isHiddenUpline,  
			CASE WHEN stt.CustID IS NULL THEN 1 ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) END as isDisabled, 
			CASE WHEN @downlines = 0 THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))  
				ELSE ISNULL((	SELECT TOP 1 1  
								FROM dbo.custInfo ci WITH (NOLOCK)  
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID  
								WHERE srecommend = @_CustID 									
									AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder)) = 1  
								), 0) END AS IsDisabledDownline,
											 
			0 AS isDisabledUpline, 			
			@downlines AS HasDownline,
			pdt.GroupID
		FROM #ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType                 
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @_CustID  
		WHERE pdt.SettingType IN (4,11,13,21) AND (@SettingType IS NULL OR ft.SettingType = @SettingType)
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY pdt.ProductID ASC, ft.Child_DisplayOrder ASC
	END  
	ELSE IF @RoleID = 3  
	BEGIN  
		IF EXISTS (SELECT 1 FROM custinfo WITH (NOLOCK) WHERE mrecommend = @_CustID AND Custid <> @CustID)  
			SET @downlines = 1   
     
		SELECT pdt.ProductID, pdt.SportType, pdt.BetType,  
			
			CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 
					ELSE (CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden,   
			CAST(CASE WHEN (SELECT ISNULL(value,1) FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder))=0 THEN 0 ELSE 1 END AS BIT) AS isHiddenUpline, 
			CASE WHEN stt.CustID IS NULL THEN 1 ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) END as isDisabled,  
			CASE WHEN @downlines = 0 THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))  
				ELSE ISNULL((	SELECT TOP 1 1  
								FROM dbo.custInfo ci WITH (NOLOCK)  
								INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID  
								WHERE mrecommend = @_CustID   
									AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder)) = 1  
								), 0) END AS IsDisabledDownline,  
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) as IsDisabledUpline,  
			@downlines AS HasDownline,
			pdt.GroupID
		FROM #ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType                 
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @_CustID  
			LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK) ON stt_UPLINE.CustID = @SuperID  
		WHERE pdt.SettingType IN (4,11,13,21) AND (@SettingType IS NULL OR ft.SettingType = @SettingType)
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY pdt.ProductID ASC, ft.Child_DisplayOrder ASC
	END     
	ELSE IF @RoleID = 2  
	BEGIN  
		IF EXISTS ( SELECT 1 FROM custinfo WITH (NOLOCK) WHERE recommend = @_CustID AND Custid <> @CustID)  
			SET @downlines = 1   
     
		SELECT pdt.ProductID, pdt.SportType, pdt.BetType,  
			
			CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 
						ELSE (CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden,    
			CAST(CASE WHEN (SELECT ISNULL(value,1) FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder))=0 THEN 0 ELSE 1 END AS BIT) AS isHiddenUpline,  
			CASE WHEN stt.CustID IS NULL THEN 1 ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) END AS isDisabled, 
			CASE WHEN @downlines = 0 THEN (SELECT ISNULL(value,0) FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder))  
				ELSE ISNULL((	SELECT TOP 1 1  
								FROM dbo.custInfo ci WITH (NOLOCK)  
									INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID  
								WHERE recommend = @_CustID  
									AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder)) = 1   
								), 0) END AS IsDisabledDownline, 			
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,  			
			@downlines AS HasDownline,
			pdt.GroupID
		FROM #ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType                 
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @_CustID  
			LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK) ON stt_UPLINE.CustID = @MasterID  
		WHERE pdt.SettingType IN (4,11,13,21) AND (@SettingType IS NULL OR ft.SettingType = @SettingType)
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY pdt.ProductID ASC, ft.Child_DisplayOrder ASC
	END   
	ELSE IF @RoleID = 1  
	BEGIN  
		SELECT pdt.ProductID, pdt.SportType, pdt.BetType,  
			
			CAST(CASE WHEN stt.CustID IS NULL OR (@IsIMBC = 0 AND pdt.ProductID = 20) THEN 1 
					ELSE (CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0 THEN 0 ELSE 1 END) END AS BIT) AS isHidden,    
			CAST(CASE WHEN (SELECT ISNULL(value,1) FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsHidden, PSP.bitmapOrder))=0 THEN 0 ELSE 1 END AS BIT) AS isHiddenUpline,   
			CASE WHEN stt.CustID IS NULL THEN 1 ELSE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) END AS isDisabled,  
			0 AS IsDisabledDownline,			
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt_UPLINE.bitmapIsDisabled, PSP.bitmapOrder)) AS IsDisabledUpline,  
			0 As HasDownline  ,
			pdt.GroupID
		FROM #ProductSettingDetail pdt WITH (NOLOCK)  
			INNER JOIN #SportBettypeFilter ft ON pdt.SportType = ft.sporttype AND pdt.BetType = ft.bettype AND pdt.IsLive = ft.islive AND pdt.SettingType = ft.SettingType
			INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = pdt.BetType AND PSP.Sporttype = PDT.SportType                 
			LEFT JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON stt.CustID = @_CustID  
			LEFT JOIN  dbo.CustProductStatus stt_UPLINE WITH (NOLOCK) ON stt_UPLINE.CustID = @AgentID  
		WHERE pdt.SettingType IN (4,11,13,21) AND (@SettingType IS NULL OR ft.SettingType = @SettingType)
			AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsHidden, PSP.bitmapOrder)) = 0
		ORDER BY pdt.ProductID ASC, ft.Child_DisplayOrder ASC
	END   


	DROP TABLE #ProductSettingDetail
	DROP TABLE #SportBettypeFilter

END

GO