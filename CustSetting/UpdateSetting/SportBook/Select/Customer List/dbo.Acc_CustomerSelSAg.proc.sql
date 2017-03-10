ALTER PROCEDURE [dbo].[Acc_CustomerSelSAg]
	@Currency int = NULL,
	@Closed bit = NULL,
	@DoubleCommLosing BIT = NULL,
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@IsInternal bit = NULL,
	@System varchar(50) = 'ACCOUNTING',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 OUTPUT,
	@TotalItems int=0 OUTPUT,
	@Userid		INT=NULL
AS
BEGIN
/*
Task : Select Super Agent list
DB: DBCust/CustDB
Revisions:
    - @update2008/01/14 search username
    - phuong.nguyen, check customer's currency for Horseracing spottype
    - 20090329@Kiwi: At count @TotalPages, remove inner join custsetting, group by.	
    - 20090331@Shifu: Remove allowHRCurrency	
    - 20090522@PhuongDao: Add 1x2 Commission 		
    - 20090807@Simon: Add a column "enabled" in Select and Order by it.
    - 20090905@Shifu: Add IsInternal
	- 20100721@Shifu: Get super list by System
	- 20101001@Jamie: Get commission for Number Game
	- 20101119@Johnson: get super list by site from Acc_CustSite table if system is not Accounting 
	- 20101214@Kevin: add synccasino
	- 20110427@Jamie: 
		+ Remove the condition srecommend > 100 for External Group 
		+ Remove JOIN IN customer in COUNT TOTAL PAGE
	- 20110623@Sophia: add username2
	- 20120525@Dom: exclude licensee customer for accounting site
	- 20120927@Johnson: - Get super list by double comm status
						- output total records affects
	- 20130121@Dan: call to bodb_AGE for Acc_CustGroup
	- 20131018@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
	- 20131029@Elodie: Put link server DBAGE [Redmine:#7261]
	- 20140116@Elodie: Hot fix to get information of disabled customer
	- 20140407@Elodie: Add Keno product [Redmine:#13156]
	- 20150422@Elodie: Add Gold Deluxe product [Redmine:#11658]
	- 20150601@Elodie: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
	- 20150709@DAniel: Enhance code get custsetting data
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20150904@Helen: commission setting for MO [Redmine #41470]
	- 20151019@Helen: Display wrong comm rate of Group A,B,C,D [Redmine: #45851]
	- 20151028@Helen: Member Information to support Muay Thai  [Redmine: #45496]
	- 20151209@Helen: Member information for Cockfighting [Redmine: #48133]
	- 20160114@Helen: Cricket - [Redmine: #50027]
	- 20160127@Billy: Member information for AllBet - [Redmine: #51591]
	- 20160407@Winnie: VoidBridge - [Redmine: #55259 ]
	- 20160620@Winnie: #48948 Hide_special_sites_from_unautorized_users	
	- 20160801@Elodie: NG2 Product - [Redmine: #60809]
	- 20170120@Elodie: Don't offer Massac(1507), Malta(1509) anymore [#70693]
	- 20161028@Winnie: Fishing world [Redmine's Ids: #65474]
	- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]	

Pattern Explanation:
Search keyword: '%keyword%'
First char
A: 'A%'
B: 'B%'
0-9: '[0-9]%'
*/

	SET NOCOUNT ON
	----- Elodie @ 01 JUN 2015 -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)	

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
	----- /Elodie @ 01 JUN 2015 -------------------

	DECLARE @RowCount int, @RowStart int, @RowEnd int
	DECLARE @isAccountingSystem bit
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	Declare @tbDummySuper table (custid int primary key)
	Declare @tbCurrency table (exchangeId int primary key)
	DECLARE @SearchQuery varchar(1024)
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpUserid VARCHAR(50)

	 -- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT
		,	@bitmapOrder_CockFighting	INT
		,	@bitmapOrder_Cricket		INT
		,	@bitmapOrder_AllBet			INT		
		,	@bitmapOrder_VoidBridge		INT		
		,	@bitmapOrder_NG2			INT
		,	@bitmapOrder_FishingWorld	INT
    
    SET @bitmapOrder_MuayThai = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 44 AND Bettype = 3)
    SET @bitmapOrder_CockFighting = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 206 AND Bettype = 1003)
    SET @bitmapOrder_Cricket = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 50 AND Bettype = 501)
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitmapOrder_NG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitmapOrder_FishingWorld = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)


	SET	@bitmapOrder_AllBet =	(
									SELECT	psp.bitmapOrder
									FROM	dbo.ProductStatusProfile AS psp WITH(NOLOCK)
									WHERE	psp.Sporttype = 211
										AND	psp.Bettype = 2401
								)   
    
    DECLARE	@IsHidden_MuayThai			INT = 1
		,	@IsHidden_CockFighting		INT = 1
		,	@IsHidden_Cricket			INT = 1
		,	@IsHidden_AllBet			INT = 1
		,	@IsHidden_VoidBridge		INT = 1
		,	@IsHidden_NG2				INT = 1
		,	@IsHidden_FishingWorld		INT = 1
    
    DECLARE	@SportBook2					INT = 16
		,	@CockFighting				INT = 19
		,	@Cricket					INT = 20
		,	@AllBet						INT = 21
		,	@VoidBridge					INT = 22
		,	@NG2						INT = 23
		,	@FishingWorld				INT = 24
    
	IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@SportBook2,4))
	BEGIN
		SET @IsHidden_MuayThai = 0
	END
	IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@CockFighting,4))
	BEGIN
		SET @IsHidden_CockFighting = 0
	END
    IF EXISTS(SELECT TOP(1) 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@AllBet, 4))
	BEGIN
	    SET	@IsHidden_AllBet = 0
	END
    
    IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@Cricket,4))
	BEGIN
		SET @IsHidden_Cricket = 0
	END

	 IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@VoidBridge,4))
	BEGIN
		SET @IsHidden_VoidBridge = 0
	END
	IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@NG2,11))
	BEGIN
		SET @IsHidden_NG2 = 0
	END
	 IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@FishingWorld,13))
	BEGIN
		SET @IsHidden_FishingWorld = 0
	END

	IF(@System = 'ACCOUNTING')
	BEGIN
	SELECT @tmpUserid=CAST(@Userid AS VARCHAR(50))
	SELECT @SearchQuery = 'SELECT * 
	FROM OPENQUERY(DBPOLICY, 
	''SELECT siteid , site,SpecialGroup FROM bodb02.dbo.f_GetDeniedSiteByUser( ''''' + @tmpUserid + ''''')'')'

	INSERT INTO  @tmp (siteid , site,SpecialGroup)
	EXECUTE(@SearchQuery)
	
		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			From
			(
				Select m.custid
				FROM 
					Custinfo as m with (NOLOCK)
					INNER JOIN Customer a WITH(NOLOCK) ON m.custid=a.custid
					INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
				WHERE m.currency = case when @Currency is null then m.currency else @Currency end											
					and m.closed = case when @closed is null then m.closed else @closed end
					and csuper.isinternal = case when @IsInternal is null then csuper.isinternal else @IsInternal end
					and m.roleid=4 and m.custid>100 and m.username like @Keyword and m.username like @FirstChar		
					and m.custid NOT IN(SELECT custid from f_DepSuper_1 ('all'))	
					and m.DoubleCommLosing = case when @DoubleCommLosing is null then m.DoubleCommLosing else @DoubleCommLosing end
					AND (@Userid IS NULL OR (@Userid IS NOT NULL AND a.site NOT IN (SELECT site FROM @tmp )))
			) t
		END

		select * from 
		(
		SELECT 
			ci.enabled, 
			ci.closed, 
			ci.reject as suspended,
			ci.synccasino,
			ci.DoubleCommLosing,
			csuper.isinternal,
			m.username, 
			m.custid, 
			m.ugroup, 
			m.firstname, 
			m.lastname,
			m.username2,
			m.phone,
			m.mobilephone,
			m.iplogin as lastloginip,
			m.currency,
			m.roleid,
			groupa, 
			groupb, 
			groupc, 
			groupd,
			
			discountcs,
			discount1x2,	
			max(case when cs3rd.bettype = 81 and cs3rd.sporttype = 161 then cs3rd.sdiscount else 0 end) as discountNumber,	
			discountHRFixedOdds,
			ci.matchlimit,
			ci.virtualmultiplier-1 as VirtualMultiplier,

			ci.HideKeno,
			min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516) then cg.IsDisabled else 1 end) as DisableKeno,
			ISNULL(ci.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ISNULL(ci.HideGoldDeluxe,1) AS HideGoldDeluxe,
			ISNULL(ci.DisableColossusBet,1) AS DisableColossusBet,
			ISNULL(ci.HideColossusBet,1) AS HideColossusBet,
			
			-- For MuayThai
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
			CAST(CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideMuayThai,
			-- For CockFighting
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_CockFighting),1) AS DisableCockFighting,
			CAST(CASE WHEN @IsHidden_CockFighting = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_CockFighting),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCockFighting,
		   -- For AllBet
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBet)) AS DisableAllBet,			
			CAST(	CASE	WHEN	@IsHidden_AllBet = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_AllBet), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideAllBet,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_AllBet), 0) AS SyncedAllBet,
			1 AS SyncedAllBetUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.srecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_AllBet) = 0)
						THEN 0
					ELSE 1
			END AS SyncedAllBetDownline,
			 -- For FishingWorld
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_FishingWorld)) AS DisableFishingWorld,
			CAST(	CASE	WHEN	@IsHidden_FishingWorld = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_FishingWorld), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideFishingWorld,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_FishingWorld), 0) AS SyncedFishingWorld,
			1 AS SyncedFishingWorldUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.srecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_FishingWorld) = 0)
						THEN 0
					ELSE 1
			END AS SyncedFishingWorldDownline,

			CASE WHEN ac.CustId IS NOT NULL THEN 1 ELSE 0 END AS IsMyanmarOdds,  
			ISNULL(AC.CommRate,0) AS discountMyanmarOdds,  

			-- For VoidBridge
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge), 1) AS DisableVoidBridge,
			CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VoidBridge), 1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridge,
			1 AS SyncedVoidBridgeUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.srecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_VoidBridge) = 0)
						THEN 0
					ELSE 1
			END AS SyncedVoidBridgeDownline,
			
			-- For NG2
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
			1 AS SyncedNG2Upline,

			-- Cricket
			CASE WHEN m.[site] = 'IMBC' THEN 1 ELSE 0 END AS IsIMBC,
			ISNULL(cda.Discount,0) AS discountCricket,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Cricket),1) AS DisableCricket,
			CAST(CASE WHEN m.[site] = 'IMBC' AND @IsHidden_Cricket = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Cricket),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCricket,
			
			ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
			
		FROM 
			customer AS m with (NOLOCK)
			INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
			LEFT JOIN
			(
				select
					custid, 
					
					MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
					MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
					MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
					MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
				
					max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
					max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
					max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.sdiscount else 0 end) as discountHRFixedOdds			
				from custsetting cs with (nolock)
				group by custid
			) cs on m.custid = cs.custid	
			LEFT JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
			LEFT JOIN CustGameType cg with(nolock) on m.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516)			
			INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
		   LEFT JOIN AgentCommRate AC WITH (NOLOCK) ON AC.CustId = CI.custid AND AC.Sporttype = 1 AND AC.Bettype = 301 
		   LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 
		   LEFT JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON  cda.CustID = ci.custid AND cda.SportType = 50 AND cda.BetType = 501

		   -- Check isHidden AllBet
		   --OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(m.custid, @AllBet) AS sbhsc
		   
		WHERE m.currency = case when @Currency is null then m.currency else @Currency end
			and ci.closed = case when @closed is null then ci.closed else @closed end
			and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
			and csuper.isinternal = case when @IsInternal is null then csuper.isinternal else @IsInternal end
			and m.roleid=4 and m.custid>100 and m.username like @Keyword and m.username like @FirstChar
			and m.custid NOT IN(SELECT custid from f_DepSuper_1 ('all'))
			AND (@Userid IS NULL OR (@Userid IS NOT NULL AND m.site NOT IN (SELECT site FROM @tmp )))
		group by
			ci.enabled, 
			ci.closed, 
			ci.reject,
			ci.synccasino,
			ci.DoubleCommLosing,
			csuper.isinternal,
			m.username, 
			m.custid, 
			m.ugroup, 
			m.firstname, 
			m.lastname, 
			m.username2,
			m.roleid,
			m.phone,
			m.mobilephone,
			m.iplogin,
			m.currency, 
			m.roleid,--phuong.nguyen, get currency name	
			ci.matchlimit,
			ci.virtualmultiplier,
			ci.HideKeno,
			ci.HideGoldDeluxe,
			ci.DisableGoldDeluxe,
			
			ci.HideColossusBet,
			ci.DisableColossusBet,
			cps.bitmapIsDisabled,
			cps.bitmapIsHidden,
			cps.bitmapHasSynced,
			groupa, 
			groupb, 
			groupc, 
			groupd,		
			discountcs,
			discount1x2,
			discountHRFixedOdds,
			AC.CommRate	,
			ac.CustId,
			m.[site],cda.Discount	
		--ORDER BY ci.closed, m.username
		) a
		WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd
	END
	ELSE -- Others system
	BEGIN

		--INSERT INTO @tbCurrency
		--SELECT exchangeid FROM dbo.f_CurrencyBySystem(@System)

		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			From
			(
				Select m.custid
				FROM 
					Custinfo as m with (NOLOCK)
					INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
				WHERE	
					m.custid IN (SELECT custid FROM DBAGE.bodb_AGE.dbo.Acc_CustGroup WITH (NOLOCK) WHERE GroupName = @System)
					AND m.roleid=4 
					AND csuper.IsInternal = 0	
					AND m.closed = case when @closed is null then m.closed else @closed end
					AND m.username like @Keyword and m.username like @FirstChar			
					and m.DoubleCommLosing = case when @DoubleCommLosing is null then m.DoubleCommLosing else @DoubleCommLosing end
			) t
		END

		select * from 
		(
		SELECT 
			ci.enabled, 
			ci.closed, 
			ci.reject as suspended,
			ci.synccasino,
			ci.DoubleCommLosing,
			csuper.isinternal,
			m.username, 
			m.custid, 
			m.ugroup, 
			m.firstname, 
			m.lastname, 
			m.username2,
			m.phone,
			m.mobilephone,
			m.iplogin as lastloginip,
			m.currency,
			m.roleid,
			max(cs.groupa) as groupa, 
			max(cs.groupb) as groupb, 
			max(cs.groupc) as groupc, 
			max(cs.groupd) as groupd, 

			max(case when cs.bettype = 4 and cs.sporttype=1 then cs.sdiscount else 0 end) as discountcs,
			max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2,
			max(case when cs3rd.bettype = 81 and cs3rd.sporttype = 161 then cs3rd.sdiscount else 0 end) as discountNumber,		
			max(case when cs.bettype = 20 and cs.sporttype = 154 then cs.sdiscount else 0 end) as discountHRFixedOdds,
			ci.matchlimit,
			ci.virtualmultiplier-1 as VirtualMultiplier,

			ci.HideKeno,
			min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516) then cg.IsDisabled else 1 end) as DisableKeno,
			ISNULL(ci.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ISNULL(ci.HideGoldDeluxe,1) AS HideGoldDeluxe,
			
			ISNULL(ci.DisableColossusBet,1) AS DisableColossusBet,
			ISNULL(ci.HideColossusBet,1) AS HideColossusBet,
			
			-- For MuayThai
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
			CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS HideMuayThai,
			-- For CockFighting
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_CockFighting),1) AS DisableCockFighting,
			CASE WHEN @IsHidden_CockFighting = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_CockFighting),1) = 0 THEN 0 ELSE 1 END AS HideCockFighting,
			-- For AllBet
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBet)) AS DisableAllBet,			
			CAST(	CASE	WHEN	@IsHidden_AllBet = 0 
								--AND	MAX(sbhsc.IsHidden) = 0
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_AllBet), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideAllBet,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_AllBet), 0) AS SyncedAllBet,
			-- FishingWorld
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_FishingWorld)) AS DisableFishingWorld,		
			CAST(	CASE	WHEN	@IsHidden_FishingWorld = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_FishingWorld), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideFishingWorld,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_FishingWorld), 0) AS SyncedFishingWorld,

			ISNULL(csuper.IsMyanmarOdds,0) AS IsMyanmarOdds,
			ISNULL(AC.CommRate,0) AS discountMyanmarOdds,
			 -- For VoidBridge
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge), 1) AS DisableVoidBridge,
			CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VoidBridge), 1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridge,
			1 AS SyncedVoidBridgeUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.srecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_VoidBridge) = 0)
						THEN 0
					ELSE 1
			END AS SyncedVoidBridgeDownline,
			
			-- For NG2
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
			1 AS SyncedNG2Upline,
			
			-- Cricket
			CASE WHEN m.[site] = 'IMBC' THEN 1 ELSE 0 END AS IsIMBC,
			ISNULL(cda.Discount,0) AS discountCricket,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Cricket),1) AS DisableCricket,
			CAST(CASE WHEN m.[site] = 'IMBC' AND @IsHidden_Cricket = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Cricket),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCricket,
			
			
			ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
		FROM 
			customer AS m with (NOLOCK)
			INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
			LEFT JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid	
			LEFT JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
			LEFT JOIN CustGameType cg with(nolock) on m.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516)
			INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
			LEFT JOIN AgentCommRate AC WITH (NOLOCK) ON AC.CustId = CI.custid AND AC.Sporttype = 1 AND AC.Bettype = 301 AND csuper.IsMyanmarOdds = 1
			LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 
			LEFT JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON  cda.CustID = ci.custid AND cda.SportType = 50 AND cda.BetType = 501

		   -- Check isHidden AllBet
		   --OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(m.custid, @AllBet) AS sbhsc
		   
			
		WHERE	
				m.custid IN (SELECT custid FROM DBAGE.bodb_AGE.dbo.Acc_CustGroup WITH (NOLOCK) WHERE groupname = @system AND roleid = 4)
				AND m.roleid=4 
				AND csuper.IsInternal = 0
				AND ci.closed = case when @closed is null then ci.closed else @closed end
				and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
				AND m.username like @Keyword and m.username like @FirstChar			
		group by
			ci.enabled, 
			ci.closed, 
			ci.reject,
			ci.synccasino,
			ci.DoubleCommLosing,
			csuper.isinternal,
			m.username, 
			m.custid, 
			m.ugroup, 
			m.firstname, 
			m.lastname, 
			m.phone,
			m.username2,
			m.roleid,
			m.mobilephone,
			m.iplogin,
			m.currency, 
			m.roleid,--phuong.nguyen, get currency name	
			ci.matchlimit,
			ci.virtualmultiplier,
			ci.HideKeno,
			ci.HideGoldDeluxe,
			ci.DisableGoldDeluxe,
			ci.HideColossusBet,
			ci.DisableColossusBet,
			cps.bitmapIsDisabled,
			cps.bitmapIsHidden,
			cps.bitmapHasSynced,
			csuper.IsMyanmarOdds,
			ac.CommRate,
			m.[site],cda.Discount			
		) a
		WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd
	END
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelSAg] TO [vnteam] AS [dbo]