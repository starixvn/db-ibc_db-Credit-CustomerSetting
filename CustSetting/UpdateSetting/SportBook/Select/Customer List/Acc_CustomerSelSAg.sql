/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
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
	@SiteType SMALLINT = 0, --credit or deposit
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
	- 20170417@Winnie: Change to call the sp Acc_CheckShowProduct- [Redmine #72336]	
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170801@Elodie: Add Keno Lottery Product - [Redmine #74313]
	- 20170620@Winnie: Apply color for closed accounts - [Redmine #74494]	
	- 20170808@Elodie: Lucky3 Product - [Redmine: #75521]
	- 20171001@Elodie: BullFighting Product - [Redmine: #81664]
	- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
	- 20180529@Winnie: Alpha/EXT NAP - Super/Master/Agent/Member List: missing 6 new Keno bettypes in select SP [RedmineID: #96035]
	- 20180703@Elodie: Poker Games Product - [Redmine: #97675]	
	- 20180704@Vicky:  NAP - Add new permission control to view Licensee Account [Redminid: #96118]
	- 20180808@Helen: DB05.DBPOLICY migration  [Redmine:99462]
	- 20180918@Winnie: Esports Product - [Redmine: #101526]	
	- 20181122@Elodie: DB053/bodb_Age Migration [Redmine:#104770]
	- 20190724@Eden: add bettype 1525,1526 for Keno gametype - [Redmine: #116466]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20191206@Eden: Add Virtual Games [Redmine: #122743]
	- 20200318@Elodie: Add Saba.club [Redmine: #130636]
	- 20200303@Tiara: Add SA Gaming Product [Redmine: #128058]

Pattern Explanation:
		Search keyword: '%keyword%'
		First char
		A: 'A%'
		B: 'B%'
		0-9: '[0-9]%'
		- @SiteType: 1: Credit; 2: Deposit; 0: ALL
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
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpUserid VARCHAR(50)

	 -- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT		
		,	@bitmapOrder_Esports		INT	
		,	@bitmapOrder_AllBet			INT		
		,	@bitmapOrder_VoidBridge		INT		
		,	@bitmapOrder_Lottery		INT
		,	@bitmapOrder_NG2			INT
		,	@bitmapOrder_FishingWorld	INT
		,	@bitmapOrder_VS				INT
		,	@bitmapOrder_VG				INT
		,	@bitmapOrder_SabaClub		INT
		,	@bitmapOrder_SAGaming		INT 

    SET @bitmapOrder_MuayThai = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 44 AND Bettype = 3)  
	SET @bitmapOrder_Esports = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 43 AND Bettype = 1)  
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitmapOrder_Lottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitmapOrder_NG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitmapOrder_FishingWorld = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitmapOrder_VS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	SET @bitmapOrder_VG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 245 AND Bettype = 4601)
	SET @bitmapOrder_SabaClub = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 200 AND Bettype = 1611)
	SET @bitmapOrder_SAGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 244 AND Bettype = 3001)

	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
    
    DECLARE	@IsHidden_MuayThai			INT = 1
		,	@IsHidden_Esports			INT = 1
		,	@IsHidden_AllBet			INT = 1
		,	@IsHidden_VoidBridge		INT = 1
		,	@IsHidden_Lottery			INT = 1
		,	@IsHidden_NG2				INT = 1

		,	@IsHidden_FishingWorld		INT = 1
		,	@IsHidden_VS				INT = 1
		,	@IsHidden_VG				INT = 1
		,	@IsHidden_SabaClub			INT = 1
		,	@IsHidden_SAGaming			INT = 1


    EXEC Acc_CheckShowProduct @ProductID = 16, @IsHide = @IsHidden_MuayThai OUTPUT	
	EXEC Acc_CheckShowProduct @ProductID = 41, @IsHide = @IsHidden_AllBet OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 22, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 28, @IsHide = @IsHidden_Lottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 23, @IsHide = @IsHidden_NG2 OUTPUT

	EXEC Acc_CheckShowProduct @ProductID = 24, @IsHide = @IsHidden_FishingWorld OUTPUT

	EXEC Acc_CheckShowProduct @ProductID = 5, @IsHide = @IsHidden_VS OUTPUT

	EXEC Acc_CheckShowProduct @ProductID = 16, @IsHide = @IsHidden_Esports OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 38, @IsHide = @IsHidden_VG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 42, @IsHide = @IsHidden_SabaClub OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @IsHide = @IsHidden_SAGaming OUTPUT

	IF(@System = 'ACCOUNTING')
	BEGIN
	SELECT @tmpUserid=CAST(@Userid AS VARCHAR(50))

	INSERT INTO  @tmp (siteid , site,SpecialGroup)
	SELECT siteid , [site], SpecialGroup FROM NAP_UserControl.dbo.f_GetDeniedSiteByUser(@tmpUserid)
	
	INSERT INTO  @tmp (siteid, site, SpecialGroup)
	SELECT s.siteID, s.site, s.SpecialGroup
    FROM site s WITH (NOLOCK)
    WHERE s.siteid NOT IN (SELECT siteid FROM @tmp)
	      AND 1 =  CASE  
	                  WHEN @SiteType = 0 THEN 0 
	                  WHEN @SiteType = 1 AND s.isLicensee = 1 THEN 1 --excludes deposit site
	                  WHEN @SiteType = 2 AND s.isLicensee = 0 THEN 1 --excludes credit site
	               END
	
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
			ci.matchlimit,
			ci.virtualmultiplier-1 as VirtualMultiplier,

			ci.HideKeno,
			min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524,1525,1526) then cg.IsDisabled else 1 end) as DisableKeno,
			ISNULL(ci.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ISNULL(ci.HideGoldDeluxe,1) AS HideGoldDeluxe,
			ISNULL(ci.DisableColossusBet,1) AS DisableColossusBet,
			ISNULL(ci.HideColossusBet,1) AS HideColossusBet,
			
			-- For MuayThai
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
			CAST(CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideMuayThai,
				
			-- For Esports
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Esports),1) AS DisableEsports,
			CAST(CASE WHEN @IsHidden_Esports = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Esports),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideEsports,
			
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
			
			-- For SA Gaming
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SAGaming)) AS DisableSAGaming,			
			CAST(	CASE	WHEN	@IsHidden_SAGaming = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SAGaming), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideSAGaming,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_SAGaming), 0) AS SyncedSAGaming,
			1 AS SyncedSAGamingUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.srecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_SAGaming) = 0)
						THEN 0
					ELSE 1
			END AS SyncedSAGamingDownline,
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
			
			 -- For Lottery
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Lottery)) AS DisableLottery,
			CAST(	CASE	WHEN	@IsHidden_Lottery = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Lottery), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideLottery,

			-- For NG2
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
			1 AS SyncedNG2Upline,

			-- For VS
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VS)) AS DisableVirtualSports,
			CAST(	CASE	WHEN	@IsHidden_VS = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VS), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideVirtualSports,	
			-- For VG
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VG)) AS DisableVirtualGames,			
			CAST(	CASE	WHEN	@IsHidden_VG = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VG), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideVirtualGames,	
			-- For SabaClub
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SabaClub)) AS DisableSabaClub,			
			CAST(	CASE	WHEN	@IsHidden_SabaClub = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SabaClub), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideSabaClub,

			ISNULL(cl.ClosedReason,0) AS ClosedReason,
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
					max(case when cs.bettype = 5 and cs.sporttype=1 then cs.sdiscount else 0 end) as discount1x2					
				from custsetting cs with (nolock)
				group by custid
			) cs on m.custid = cs.custid	
			LEFT JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
			LEFT JOIN CustGameType cg with(nolock) on m.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524,1525,1526)			
			INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
		   LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 
		   LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON m.custid=cl.CustID
		   
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
			m.[site],
			cl.ClosedReason	
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
					m.custid IN (SELECT custid FROM dbo.Acc_CustGroup WITH (NOLOCK) WHERE GroupName = @System)
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
			ci.matchlimit,
			ci.virtualmultiplier-1 as VirtualMultiplier,

			ci.HideKeno,
			min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524,1525,1526) then cg.IsDisabled else 1 end) as DisableKeno,
			ISNULL(ci.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ISNULL(ci.HideGoldDeluxe,1) AS HideGoldDeluxe,
			
			ISNULL(ci.DisableColossusBet,1) AS DisableColossusBet,
			ISNULL(ci.HideColossusBet,1) AS HideColossusBet,
			
			-- For MuayThai
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
			CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS HideMuayThai,
			-- For Esports
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Esports),1) AS DisableEsports,
			CASE WHEN @IsHidden_Esports = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Esports),1) = 0 THEN 0 ELSE 1 END AS HideEsports,

			-- For AllBet
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBet)) AS DisableAllBet,			
			CAST(	CASE	WHEN	@IsHidden_AllBet = 0 
								--AND	MAX(sbhsc.IsHidden) = 0
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_AllBet), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideAllBet,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_AllBet), 0) AS SyncedAllBet,

			-- For SA Gaming
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SAGaming)) AS DisableSAGaming,			
			CAST(	CASE	WHEN	@IsHidden_SAGaming = 0 
								--AND	MAX(sbhsc.IsHidden) = 0
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SAGaming), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideSAGaming,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_SAGaming), 0) AS SyncedSAGaming,
			
			-- FishingWorld
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_FishingWorld)) AS DisableFishingWorld,		
			CAST(	CASE	WHEN	@IsHidden_FishingWorld = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_FishingWorld), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideFishingWorld,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_FishingWorld), 0) AS SyncedFishingWorld,
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
			-- For Lottery
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Lottery)) AS DisableLottery,
			CAST(	CASE	WHEN	@IsHidden_Lottery = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Lottery), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideLottery,
			-- For NG2
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
			1 AS SyncedNG2Upline,
			
			-- For VS
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VS)) AS DisableVirtualSports,
			CAST(	CASE	WHEN	@IsHidden_VS = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VS), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideVirtualSports,
			-- For VG
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VG)) AS DisableVirtualGames,			
			CAST(	CASE	WHEN	@IsHidden_VG = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VG), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideVirtualGames,
			-- For SabaClub
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SabaClub)) AS DisableSabaClub,			
			CAST(	CASE	WHEN	@IsHidden_SabaClub = 0 								
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SabaClub), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideSabaClub,			
			ISNULL(cl.ClosedReason,0) AS ClosedReason,
			
			ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, m.username) as RowNumber
		FROM 
			customer AS m with (NOLOCK)
			INNER JOIN custinfo as ci with (NOLOCK) on m.custid = ci.custid
			LEFT JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid	
			LEFT JOIN CustSetting3rd as cs3rd with (NOLOCK) on m.custid = cs3rd.custid 
			LEFT JOIN CustGameType cg with(nolock) on m.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524,1525,1526)
			INNER JOIN CustSuper as csuper with (NOLOCK) on m.custid = csuper.custid
			LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 
			LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON m.custid=cl.CustID
		   
			
		WHERE	
				m.custid IN (SELECT custid FROM dbo.Acc_CustGroup WITH (NOLOCK) WHERE groupname = @system AND roleid = 4)
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
			m.[site],
			cl.ClosedReason	
		) a
		WHERE a.RowNumber BETWEEN @RowStart AND @RowEnd
	END
END
GO
