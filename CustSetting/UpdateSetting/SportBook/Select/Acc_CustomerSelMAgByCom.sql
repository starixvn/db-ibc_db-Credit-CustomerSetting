/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO 

ALTER PROCEDURE [dbo].[Acc_CustomerSelMAgByCom]
	@Currency int = NULL,
	@Closed bit = NULL,
	@DoubleCommLosing bit = NULL,
	@IsInternal bit = NULL,
	@Keyword nvarchar(50)='%',
	@FirstChar nvarchar(6)='%',
	@PageSize int=50,
	@PageIndex int=1,
	@TotalPages int=0 OUTPUT,
	@TotalItems int=0 OUTPUT,
	@Userid		INT=NULL
AS
BEGIN
/*
	Task : Select Direct Master Agent list
	DB: DBCUST/CustDB
	Original: magentsite/account\customerlist.asp

	Revisions:
		- @update2008/01/14 search username
		- phuong.nguyen, check customer's currency for Horseracing spottype
		- 20090329@Kiwi: Improve Performance:
						+ At count @TotalPages, remove inner join custsetting, exchange, group by.
						+ Remove un-necessary inner join exchange at selection details.
		- 20090331@Shifu: Remove allowHRCurrency	
		- 20090522@PhuongDao: Add 1x2 Commission 
		- 20090807@Simon: Add a column "enabled" in Select and Order by it.	
		- 20090910@Shifu: Add IsInternal
		- 20101001@Lukas: Get commission for Number Game 
		- 20110117@Steven: get synccasino
		- 20110623@Sophia: add username2
		- 20120525@Dom: exclude licensee customer
		- 20120927@Johnson: - get double comm losing status and upline double comm losing status
							- output total records affect 
		- 20131018@Kathy: Add HR Fixed Odds (154)[Redmine:#6505]
		- 20140116@Elodie:	Hot fix to get information of disabled customer
							Output total records affect
		- 20140407@Elodie: Add Keno product [Redmine:#13156]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#11658]
		- 20150601@Elodie: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
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
		- 20160810@Winnie: #61733 add more bettype VIP Barcarat setting
		- 20170120@Elodie: Don't offer Massac(1507), Malta(1509) anymore [#70693]
		- 20161028@Winnie: Fishing world [Redmine's Ids: #65474]
		- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]		
		- 20170417@Winnie: Change to call the sp Acc_CheckShowProduct- [Redmine #72336]	
		- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
		- 20170801@Elodie: Add Keno Lottery Product - [Redmine #74313]
		- 20170605@Winnie: Apply Color for closed account [Redmine's Ids: #74494]
		- 20170808@Elodie: Lucky3 Product - [Redmine: #75521]
		- 20171001@Elodie: BullFighting Product - [Redmine: #81664]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20180703@Elodie: Poker Games Product - [Redmine: #97675]

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
	DECLARE @SearchQuery varchar(1024)
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpUserid VARCHAR(50)
	SELECT @tmpUserid=CAST(@Userid AS VARCHAR(50))
	SELECT @SearchQuery = 'SELECT * 
	FROM OPENQUERY(DBPOLICY, 
	''SELECT siteid , site,SpecialGroup FROM bodb02.dbo.f_GetDeniedSiteByUser( ''''' + @tmpUserid + ''''')'')'
	INSERT INTO  @tmp (siteid , site,SpecialGroup)
	EXECUTE(@SearchQuery)

	CREATE TABLE #TempMaster(CustID INT PRIMARY KEY,Site VARCHAR(10),IsInternal BIT,ugroup VARCHAR(3),firstname NVARCHAR(50),lastname NVARCHAR(50),username2 NVARCHAR(50),phone NVARCHAR(50),mobilephone NVARCHAR(50),iplogin NVARCHAR(20), RowNumber BIGINT)
	INSERT INTO #TempMaster(CustID,Site,IsInternal,RowNumber)
	select ci.custid,c.site,cm.IsInternal,
		ROW_NUMBER() OVER (ORDER BY CASE when isnull(ci.enabled,0) = 0 then 3 WHEN isnull(ci.closed,0) = 1 THEN 2 WHEN isnull(ci.reject,0) = 1 THEN 1 ELSE 0 end, ci.username) as RowNumber
	FROM Customer c WITH(NOLOCK)
	INNER JOIN custInfo as ci with (NOLOCK) ON c.custid=ci.custid
	INNER JOIN CustMaster cm WITH (NOLOCK) ON ci.custid = cm.custid
	WHERE ci.SRecommend < 100 and ci.roleid=3
	and ci.currency = case when @Currency is null then ci.currency else @Currency end
	and ci.closed = case when @closed is null then ci.closed else @closed end
	AND cm.isinternal = case when @IsInternal is null then cm.isinternal else @IsInternal end
	and ci.username like @Keyword and ci.username like @FirstChar
	and ci.srecommend NOT IN(SELECT custid from f_DepSuper_1 ('all'))
	and ci.DoubleCommLosing = case when @DoubleCommLosing is null then ci.DoubleCommLosing else @DoubleCommLosing end
	AND (@Userid IS NULL OR (@Userid IS NOT NULL AND c.site NOT IN (SELECT site FROM @tmp )))

	DECLARE @RowCount int, @RowStart int, @RowEnd int 
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	IF @TotalPages = 0
	BEGIN
		SELECT @TotalItems = count(t.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
		From #TempMaster t
	END
 
    -- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT
		,	@bitmapOrder_CockFighting	INT
		,	@bitmapOrder_Cricket		INT
		,	@bitmapOrder_AllBet			INT
		,	@bitmapOrder_AllBetVIP		INT
		,	@bitmapOrder_VoidBridge		INT
		,	@bitmapOrder_Lottery		INT
		,	@bitmapOrder_NG2			INT
		,	@bitmapOrder_Lucky3			INT
		,	@bitmapOrder_FishingWorld	INT
		,	@bitmapOrder_VS				INT
		,	@bitmapOrder_BullFighting	INT
		,	@bitmapOrder_PokerGames1401	INT
		,	@bitmapOrder_PokerGames1402	INT
		,	@bitmapOrder_PokerGames1403	INT
		,	@bitmapOrder_PokerGames1404	INT

    SET @bitmapOrder_MuayThai = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 44 AND Bettype = 3)
    SET @bitmapOrder_CockFighting = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 206 AND Bettype = 1003)
    SET @bitmapOrder_Cricket = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 50 AND Bettype = 501)
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitmapOrder_Lottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitmapOrder_NG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitmapOrder_Lucky3 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 160 AND Bettype = 1600)
	SET @bitmapOrder_FishingWorld = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitmapOrder_VS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	SET @bitmapOrder_BullFighting = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 207 AND Bettype = 1004)

	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
    SELECT	@bitmapOrder_AllBetVIP = (SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE psp.Sporttype = 211 AND	psp.Bettype = 2402)
	SELECT	@bitmapOrder_PokerGames1401 =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 163 AND	psp.Bettype = 1401)
    SELECT	@bitmapOrder_PokerGames1402 = (SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE psp.Sporttype = 163 AND	psp.Bettype = 1402)
	SELECT	@bitmapOrder_PokerGames1403 =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 163 AND	psp.Bettype = 1403)
    SELECT	@bitmapOrder_PokerGames1404 = (SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE psp.Sporttype = 163 AND	psp.Bettype = 1404)  
    
    DECLARE	@IsHidden_MuayThai			INT = 1
		,	@IsHidden_CockFighting		INT = 1
		,	@IsHidden_Cricket			INT = 1
		,	@IsHidden_AllBet			INT = 1
		,	@IsHidden_VoidBridge		INT = 1
		,	@IsHidden_Lottery			INT = 1
		,	@IsHidden_NG2				INT = 1
		,	@IsHidden_Lucky3			INT = 1    
		,	@IsHidden_FishingWorld		INT = 1
		,	@IsHidden_VS				INT = 1
		,	@IsHidden_BullFighting		INT = 1
		,	@IsHidden_PokerGames		INT = 1

    EXEC Acc_CheckShowProduct @ProductID = 16, @IsHide = @IsHidden_MuayThai OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 19, @IsHide = @IsHidden_CockFighting OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 20, @IsHide = @IsHidden_Cricket OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 21, @IsHide = @IsHidden_AllBet OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 22, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 28, @IsHide = @IsHidden_Lottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 23, @IsHide = @IsHidden_NG2 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 26, @IsHide = @IsHidden_Lucky3 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 24, @IsHide = @IsHidden_FishingWorld OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 30, @IsHide = @IsHidden_BullFighting OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 5, @IsHide = @IsHidden_VS OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 33, @IsHide = @IsHidden_PokerGames OUTPUT

	Select * From 
	(
		SELECT 		
			m.RowNumber,
			ci.enabled, 
			ci.closed, 
			ci.roleid,
			ci.reject as suspended,
			ci.username, 
			m.custid,
			ci.srecommend,
			m.ugroup, 
			m.firstname, 
			m.lastname, 
			m.username2,
			m.phone,
			m.mobilephone,
			ci.matchlimit,
			ci.virtualmultiplier-1 as VirtualMultiplier,
			m.iplogin as lastloginip,
			u.synccasino as SyncCasinoUpline,
			u.doublecommlosing as DoubleCommLosingUpline,
			
			MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupa else 0 end) as groupa,
			MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupb else 0 end) as groupb,
			MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupc else 0 end) as groupc,
			MAX(case when cs.bettype = 1 and cs.sporttype=1 then cs.groupd else 0 end) as groupd,
		
			max(case when cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end) as discountcs,
			max(case when cs.bettype = 5 and cs.sporttype=1 then cs.adiscount else 0 end) as discount1x2,
			max(case when cs3.bettype = 81 and cs3.sporttype = 161 then cs3.adiscount else 0 end) as discountnumber,			
			ci.currency as exchangeid,
			ci.currency,
			m.isinternal,
			ci.synccasino,
			ci.DoubleCommLosing,

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
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBetVIP)) AS DisableAllBetVIP,
			CAST(	CASE	WHEN	@IsHidden_AllBet = 0 
								--AND	MAX(sbhsc.IsHidden) = 0
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_AllBet), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideAllBet,
			CAST(CASE	WHEN	@IsHidden_AllBet = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_AllBet), 1)=0
			THEN 0 ELSE 1
			END AS BIT) AS HideAllBetUpline,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_AllBet), 0) AS SyncedAllBet,
			ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_AllBet), 0) AS SyncedAllBetUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.mrecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_AllBet) = 0)
						THEN 0
					ELSE 1
			END AS SyncedAllBetDownline,
			-- For Poker Games
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_PokerGames1401)) AS DisablePokerGames1401,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_PokerGames1402)) AS DisablePokerGames1402,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_PokerGames1402)) AS DisablePokerGames1403,
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_PokerGames1402)) AS DisablePokerGames1404,
			CAST(CASE WHEN @IsHidden_PokerGames = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_PokerGames1401), 1) = 0 THEN 0 ELSE 1 END AS BIT) AS HidePokerGames,
			CAST(CASE WHEN @IsHidden_PokerGames = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_PokerGames1401), 1)=0 THEN 0 ELSE 1 END AS BIT) AS HidePokerGamesUpline,
			-- For Lucky3
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Lucky3)) AS DisableLucky3,		
			CAST(	CASE	WHEN	@IsHidden_Lucky3 = 0 						
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Lucky3), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideLucky3,
			CAST(CASE	WHEN	@IsHidden_Lucky3 = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_Lucky3), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideLucky3Upline,

			-- For FishingWorld
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_FishingWorld)) AS DisableFishingWorld,
			CAST(	CASE	WHEN	@IsHidden_FishingWorld = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_FishingWorld), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideFishingWorld,
			CAST(CASE	WHEN	@IsHidden_FishingWorld = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_FishingWorld), 1)=0
			THEN 0 ELSE 1
			END AS BIT) AS HideFishingWorldUpline,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_FishingWorld), 0) AS SyncedFishingWorld,
			ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_FishingWorld), 0) AS SyncedFishingWorldUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.mrecommend = m.custid
										AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_FishingWorld) = 0)
						THEN 0
					ELSE 1
			END AS SyncedFishingWorldDownline,

			CASE WHEN ac.CustId IS NOT NULL THEN 1 ELSE 0 END AS IsMyanmarOdds,
			ISNULL(AC.CommRate,0) AS discountMyanmarOdds,

			-- For VoidBridge
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge), 1) AS DisableVoidBridge,
			CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VoidBridge), 1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
			CAST(CASE	WHEN	@IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VoidBridge), 1)=0
				THEN 0 ELSE 1
				END AS BIT) AS HideVoidBridgeUpline,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridge,
			ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridgeUpline,
			CASE	WHEN EXISTS	(	SELECT	1
									FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
									INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
											ON	ciDownline.custid = cpsDownline.CustID
									WHERE	ciDownline.mrecommend = m.custid
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
			CAST(CASE	WHEN	@IsHidden_Lottery = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_Lottery), 1)=0
			THEN 0 ELSE 1
			END AS BIT) AS HideLotteryUpline,

			-- For NG2
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
			CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2Upline,			
			ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
			ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2Upline,
			ISNULL(cl.closedreason,0) AS closedreason,
			-- For VS
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VS)) AS DisableVirtualSports,
			CAST(	CASE	WHEN	@IsHidden_VS = 0 							
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VS), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideVirtualSports,
			CAST(CASE WHEN @IsHidden_VS = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VS), 1)=0 THEN 0 ELSE 1 END AS BIT) AS HideVirtualSportsUpline,
			-- For BullFighting
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_BullFighting)) AS DisableBullFighting,		
			CAST(	CASE	WHEN	@IsHidden_BullFighting = 0 						
								AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_BullFighting), 1) = 0 
								THEN 0
							ELSE 1 
					END AS BIT) AS HideBullFighting,
			CAST(CASE	WHEN	@IsHidden_BullFighting = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_BullFighting), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideBullFightingUpline,

			-- For Cricket
			CASE WHEN m.[site] = 'IMBC' THEN 1 ELSE 0 END AS IsIMBC,
			ISNULL(cda.Discount,0) AS discountCricket,
			ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Cricket),1) AS DisableCricket,
			CAST(CASE WHEN m.[site] = 'IMBC' AND @IsHidden_Cricket = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Cricket),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCricket
		
		FROM 
			#TempMaster AS m with (NOLOCK)
			INNER JOIN custInfo as ci with (NOLOCK) on m.custid = ci.custid
			LEFT JOIN CustSetting as cs with (NOLOCK) on m.custid = cs.custid
			LEFT JOIN custsetting3rd cs3 with(nolock)on m.custid = cs3.custid
			LEFT JOIN CustGameType cg with(nolock) on m.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516)	
			INNER JOIN (select synccasino, doublecommlosing, custid from custinfo with (nolock)) u on ci.srecommend = u.custid
			LEFT JOIN AgentCommRate ac WITH (NOLOCK) ON ac.CustId = ci.custid AND AC.Sporttype = 1 AND AC.Bettype = 301 
			LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
			LEFT JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON  cda.CustID = ci.custid AND cda.SportType = 50 AND cda.BetType = 501
			LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON m.custid=cl.CustID
			-- Check isHidden AllBet
			--OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(m.custid, @AllBet) AS sbhsc
		
			-- Upline Status
			INNER JOIN	dbo.CustProductStatus AS cpsUpline WITH (NOLOCK)
					ON	cpsUpline.CustID =	CASE	WHEN ci.roleid = 1 THEN ci.recommend
													WHEN ci.roleid = 2 THEN ci.mrecommend
													ELSE ci.srecommend
											END
		WHERE m.RowNumber BETWEEN @RowStart AND @RowEnd
		group by
			ci.enabled, 
			ci.closed,
			ci.roleid, 
			ci.reject,
			ci.matchlimit,
			ci.virtualmultiplier,
			ci.username, 
			m.custid, 
			m.ugroup, 
			m.firstname, 
			m.lastname, 
			m.username2,
			ci.roleid,
			m.phone,
			m.mobilephone,
			m.iplogin,
			ci.srecommend,
			ci.currency,
			m.isinternal,
			u.synccasino,
			u.DoubleCommLosing,
			ci.synccasino,
			ci.DoubleCommLosing,
			ci.HideKeno,
			ci.HideGoldDeluxe,
			ci.DisableGoldDeluxe,
			ci.HideColossusBet,
			ci.DisableColossusBet,
			cps.bitmapIsDisabled,
			cps.bitmapIsHidden,
			cps.bitmapHasSynced,
			cpsUpline.bitmapHasSynced,
			cpsUpline.bitmapIsHidden,
			AC.CommRate,
			ac.CustId,
			m.site,
			cda.Discount,
			cl.ClosedReason,
			m.RowNumber
	) a
	ORDER BY a.RowNumber
END
GO


