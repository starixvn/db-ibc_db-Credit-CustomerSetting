/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelByMAg]
	@MRecommend int,
	@IsAgentSite bit = 0,	
	@Username varchar(30)=null,
	@Enabled bit = null,
	@Closed bit=null,
	@Suspended bit = null,
	@DoubleCommLosing tinyint = 2,
	@ProductUnSync TINYINT = 0,--0: not filter
	@PageSize int = 20000,
	@PageIndex int = 1,
	@TotalPages int = 1 output,
	@TotalItems int=0 output,
	@Userid		INT = NULL,
	@SettingStatus TINYINT = 0,
	@Locked BIT = NULL -- 1: Locked filter
AS
/*
	Created by: []
	Date: []
	Task: Agent List 
	DB: DBCUST/CustDB
	Original: magentsite/account\customerlist.asp
	
	Revisions:
		- 20080912@PhuongNguyen: Remove currency, roleid and checking HR currency function
		- 20090312@Lee: Return 2 more fields for casino
		- 20090522@PhuongDao: Add 1x2 Commission 
		- 20090710@Phuc: unhide IP for TB currency.
		- 20090807@Simon: Add a column "enabled" in Select and Order by it.
		- 20090823@Phuc: paging.
		- 20090910@Shifu: Add isinternal
		- 20100531@Hanh: get one more field disableOpenTote
		- 20100907@KhoaTrinh: get more Bingo status, number game status
		- 20110311@Lukas: get racing game status (AU Horse, Greyhound, Harness)
		- 20110422@Lukas: get racing status in detail (each racing partner)
		- 20110623@Sophia: add username2  
		- 20111134@Johnson: get P2P status
		- 20120201@Sophia: Get DisableLiveCasino, SyncLiveCasino for Live Casino
		- 20120817@Sophia: Get DisableVirtualSports
		- 20120926@Sophia:	- Add parameter @DoubleCommLosing, get DoubleCommLosing
							- Output total records affects
		- 20131017@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
		- 20140116@Elodie: Hot fix to get information of disabled customer
		- 20140407@Elodie: Add Keno product [Redmine:#13156]  
		- 20140818@Lukas: multi-join on large tables reduce performance, devide into small parts then join together - tunning SP [Redmine:#20654]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#11658]
		- 20150601@Elodie: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
		- 20150825@Helen: Colossus Bet - [Redmine: #41264]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20151028@Helen: Member Information to support Muay Thai  [Redmine: #45496]
		- 20151209@Helen: Member information for Cockfighting [Redmine: #48133]
		- 20160114@Helen: Cricket - [Redmine: #50027]
		- 20160127@Billy: Member information for AllBet - [Redmine: #51591]
		- 20160407@Winnie: VoidBridge - Redmine's Ids: #55258
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
		- 20170925@Johnson: Add filter product un-sync for Casino,GD,Allbet,Macau [Redmine: #72973]
		- 20171001@Elodie: BullFighting Product - [Redmine: #81664]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20180529@Winnie: Alpha/EXT NAP - Super/Master/Agent/Member List: missing 6 new Keno bettypes in select SP [RedmineID: #96035]
		- 20180703@Elodie: Poker Games Product - [Redmine: #97675]
		- 20180830@Elodie: Add new bettype of Poker Games Product - [Redmine: #97675]
		- 20180808@Helen: DB05.DBPOLICY migration  [Redmine:99462]
		- 20180918@Winnie: Add new bettype of Esports - [Redmine: #101526]
		- 20190510@Elodie: Support search by nickname on customer list - [Redmine: #113044]
		- 20190724@Eden: add bettype 1525,1526 for Keno gametype - [Redmine: #116466]
		- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20191206@Eden: Add Virtual Games [Redmine: #122743]
		- 20200318@Elodie: Add Saba.club [Redmine: #130636]
		- 20200321@Tiara: Add SA Gaming Product [Redmine: #128058]
		- 20200321@Tiara: Add Sexy Gaming Product [Redmine: #130678]
		- 20200406@Elodie: Add BBIN Product [Redmine: #131363]
		- 20200403@Elodie: Add Table Games Product [Redmine: #129440]
		- 20200421@Elodie: Add GTCasino Product [Redmine: #130689]
		- 20200504@Eden: ION Live casino [Redmine: #132323]
		- 20200506@Tiara: Add RNG War Product [Redmine: 132018]
		- 20200713@Eden: Integrate 3 new bet types for Keno [Redmine: #137475]
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
		- 20200828@Winfred: Add WM Live casino [Redmine: #131589]
		- 20201130@Tina: Add GDG (Gold Diamond Gaming) Live casino [Redmine: #144105]
		- 20201012@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20201204@Tina: add BG (Big Gaming) [RedmineID: #142458]
		- 20210229@Winfred: add Sports Lottery [RedmineID: #147361]
		- 20210315@Tina: add PP Live Casino [RedmineID: #134041]
		- 20210426@Tina: Add VGaming [Redmine: #153938]
		- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210809@Winfred: add Bitcoin Betting / not used HideUpline [RedmineID: #159039]
		- 20220211@Winfred: add Spadegaming Jackpot [RedmineID: #167128]
		- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
		- 20220921@Winfred:  Macau Game Setting Page - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20221130@Tacy: Non-sports products - Remove GDG and Fishing World [RedmineID: #174511]
		- 20230602@Helios: Enhance stored procedure to prevent performance issue [Redmine: #189154]
		- 20230519@Luke: YeeBet - Integrate new Live Casino product [Redmine: #186046]
		- 20230628@Tacy: NG2 - Remove Setting [Redmine: #189762]
		- 20230728@Eden: Simplify Live Casino Customer Setting [RedmineID: #189389]

	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		- @ProductUnSync:
			0: not filter by product
			6: casino,12: GD, 41: Allbet + SA Gaming, 22: Macau Games
		- @SettingStatus: 0: Pro, 1: UAT
*/   
BEGIN

	SET NOCOUNT ON	
	DECLARE @RowCount int, @RowStart int, @RowEnd int
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	SET @Username = ISNULL(@Username, '')
	
	-- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT
		,	@bitmapOrder_Esports		INT
		,	@bitmapOrder_AllBetVIP		INT
		,	@bitmapOrder_VoidBridge		INT
		,	@bitmapOrder_Lottery		INT
		,	@bitmapOrder_VS				INT
		,	@bitmapOrder_VG				INT
		,	@bitmapOrder_SabaClub		INT
		,	@bitmapOrder_TableGames		INT 
		,	@bitmapOrder_RNGWar			INT 
		,	@bitmapOrder_SportsLottery	INT 
		,	@bitmapOrder_VGaming		INT 
		,	@bitmapOrder_Bitcoin		INT
		,	@bitmapOrder_SGJackpot		INT  
		,   @bitmapOrder_SabaCasino		INT
		,   @bitmapOrder_Keno			INT 
		,   @bitmapOrder_NG				INT 
		,   @bitmapOrder_LiveCasino		INT 

    SET @bitmapOrder_MuayThai = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 44 AND Bettype = 3)
	SET @bitmapOrder_Esports = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 43 AND Bettype = 1)
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SET @bitmapOrder_Lottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1024)
	SET @bitmapOrder_VS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9908 AND Bettype = 1201)
	SET @bitmapOrder_VG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 245 AND Bettype = 4601)
	SET @bitmapOrder_SabaClub = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 200 AND Bettype = 1611)
	SET @bitmapOrder_TableGames = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 222 AND Bettype = 4901)
	SET @bitmapOrder_RNGWar = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 224 AND Bettype = 5500)
	SET @bitmapOrder_SportsLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 169 AND Bettype = 3611)	
	SET	@bitmapOrder_AllBetVIP = (SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE psp.Sporttype = 211 AND	psp.Bettype = 2402)
	SET @bitmapOrder_VGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 171 AND Bettype = 3801)
	SET @bitmapOrder_Bitcoin = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 175 AND Bettype = 7901)
    SET @bitmapOrder_SGJackpot = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9904 AND Bettype = 4001 )
	SET @bitmapOrder_SabaCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 208 AND Bettype = 2101)
	SET @bitmapOrder_Keno = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 202 AND Bettype = 1501)
	SET @bitmapOrder_NG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 161 AND Bettype = 81)
	SET @bitmapOrder_LiveCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9911 AND Bettype = 2400)

    --Live Casino
	DECLARE	@IsHidden_LiveCasino	INT = 1
		,	@IsHidden_AllBet		INT = 0	
		,	@IsHidden_YeeBet		INT = 0
		,	@IsHidden_SAGaming		INT = 0
		,	@IsHidden_ION			INT = 0
		,	@IsHidden_SexyGaming	INT = 0
		,	@IsHidden_BBIN			INT = 0
		,	@IsHidden_GTCasino		INT = 0
		,	@IsHidden_BG			INT = 0
		,	@IsHidden_PPLive		INT = 0
		,	@IsHidden_WM			INT = 0

	DECLARE	@IsHidden_MuayThai			INT = 1		
		,	@IsHidden_ESports			INT = 1	
		,	@IsHidden_VoidBridge		INT = 1
		,	@IsHidden_Lottery			INT = 1
		,	@IsHidden_VS				INT = 1
		,	@IsHidden_VG				INT = 1
		,	@IsHidden_SabaClub			INT = 1
		,	@IsHidden_TableGames		INT = 1
		,	@IsHidden_RNGWar			INT = 1
		,	@IsHidden_SportsLottery		INT = 1
		,	@IsHidden_VGaming			INT = 1
		,	@IsHidden_Bitcoin			INT = 1
		,	@IsHidden_SabaCasino		INT = 1
		,	@IsHidden_Keno				INT = 1
		,	@IsHidden_NG				INT = 1

	DECLARE @SiteID INT , @Currency INT

	SELECT @Currency = ci.currency, @SiteID = s.siteid
	FROM customer ci WITH(NOLOCK) 
		INNER JOIN Site s WITH(NOLOCK) ON ci.site = s.site
	WHERE ci.custid = @MRecommend

	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 211, @Bettype = 2401, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_AllBet OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 159, @Bettype = 3151, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_YeeBet OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 244, @Bettype = 3001, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_SAGaming OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 225, @Bettype = 5601, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_ION OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 243, @Bettype = 3101, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_SexyGaming OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 241, @Bettype = 3300, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_BBIN OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 242, @Bettype = 3201, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_GTCasino OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 239, @Bettype = 3501, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_BG OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 170, @Bettype = 3701, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_PPLive OUT
	EXEC [Acc_GetSportOfferStatusBySiteCurrency] @SiteID = @SiteID, @Currency = @Currency, @Sporttype = 233, @Bettype = 3401, @SettingStatus = @SettingStatus, @IsHidden = @IsHidden_WM OUT

    EXEC Acc_CheckShowProduct @ProductID = 16, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_MuayThai OUTPUT	
	EXEC Acc_CheckShowProduct @ProductID = 18, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 220, @IsHide = @IsHidden_Lottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 16, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_ESports OUTPUT	
	EXEC Acc_CheckShowProduct @ProductID = 5, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VS OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 38, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 42, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_SabaClub OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 222, @IsHide = @IsHidden_TableGames OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 224, @IsHide = @IsHidden_RNGWar OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 169, @IsHide = @IsHidden_SportsLottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 66, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VGaming OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 69, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_Bitcoin OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 6, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_SabaCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 202, @IsHide = @IsHidden_Keno OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 161, @IsHide = @IsHidden_NG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_LiveCasino OUTPUT
	
	CREATE TABLE #customer(custid INT, RowNumber INT ,discountMyanmarOdds DECIMAL (9,8),IsMyanmarOdds BIT)

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL AND @DoubleCommLosing = 2 AND @Locked IS NULL
	BEGIN
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync = 0
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)			
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2 
			END
			ELSE IF @ProductUnSync IN (41,18)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)			
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
									OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
			END		
		END 
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT custid, RowNumber 
			FROM (
					SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) AS RowNumber 
					FROM dbo.custinfo ci WITH(NOLOCK) 
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					WHERE	MRecommend = @MRecommend 
						AND roleid=2 
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END	
		ELSE IF @ProductUnSync IN (41,18)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT custid, RowNumber 
			FROM (
					SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) AS RowNumber 
					FROM dbo.custinfo ci WITH(NOLOCK) 
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs					
					WHERE	MRecommend = @MRecommend 
						AND roleid=2 
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
									OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
						
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END	
	END
	ELSE IF @Username = ''
	BEGIN
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync = 0 
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)		
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs	
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2 
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END			
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			END		
			ELSE IF @ProductUnSync IN (41,18)  
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2 
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END			
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
									OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
					AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			END
		END
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer(custid, RowNumber)
			SELECT custid, RowNumber
			FROM (
					SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber
					FROM dbo.custinfo ci WITH (NOLOCK) 
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					WHERE MRecommend = @MRecommend 
						AND roleid=2 
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
						AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END	
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END		
		ELSE IF @ProductUnSync IN (41,18)
		BEGIN
			INSERT INTO #customer(custid, RowNumber)
			SELECT custid, RowNumber
			FROM (
					SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber
					FROM dbo.custinfo ci WITH (NOLOCK) 
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					WHERE MRecommend = @MRecommend 
						AND roleid=2 
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
						AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END	
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
									OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
						AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END
	END
	ELSE
	BEGIN
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync = 0
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 then 1 else 0 end  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2 
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @MRecommend AND c.username2 LIKE '%' + @Username + '%'))
					AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			END				
			ELSE IF @ProductUnSync IN (41,18)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 then 1 else 0 end  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				WHERE ci.MRecommend = @MRecommend 
					AND ci.roleid=2 
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @MRecommend AND c.username2 LIKE '%' + @Username + '%'))
					AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
									OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			END	
		END	
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer(custid,RowNumber)
			SELECT custid, RowNumber	
			FROM (
					SELECT ci.custid,ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber
					FROM dbo.custinfo ci WITH(NOLOCK) 
						INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					WHERE ci.MRecommend = @MRecommend 
						AND ci.roleid=2 
						AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @MRecommend AND c.username2 LIKE '%' + @Username + '%'))
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
						AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END	
						AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)	
				) t 
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END	
		ELSE IF @ProductUnSync IN (41,18)
		BEGIN
			INSERT INTO #customer(custid,RowNumber)
			SELECT custid, RowNumber	
			FROM (
					SELECT ci.custid,ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber
					FROM dbo.custinfo ci WITH(NOLOCK) 
						INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
						CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					WHERE ci.MRecommend = @MRecommend 
						AND ci.roleid=2 
						AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @MRecommend AND c.username2 LIKE '%' + @Username + '%'))
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
						AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END		
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_LiveCasino)) = 0)
								OR (@ProductUnSync = 18 AND (SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,@bitmapOrder_VoidBridge)) = 0)
								THEN 1 ELSE 0 END	
							)
						AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				) t 
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END
	END
	-- MyanmarOdds
		DECLARE @IsMyanmarOdds BIT = 0	
		SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds(@MRecommend)
	IF @IsMyanmarOdds = 1
	BEGIN
		
		UPDATE T
			SET discountMyanmarOdds = ac.CommRate
			, t.IsMyanmarOdds = @IsMyanmarOdds
		FROM #customer T
			INNER JOIN AgentCommRate ac WITH (NOLOCK) ON T.custid = AC.CustId 
		WHERE Sporttype = 1 AND Bettype = 1			
	END
	
	-- get data for filtered customers	
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )	

	IF EXISTS (SELECT 1 FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @Userid AND roleid > 4)
		INSERT INTO  @tmp (siteid , site,SpecialGroup)
		SELECT siteid , [site], SpecialGroup FROM NAP_UserControl.dbo.f_GetDeniedSiteByUser(@Userid)
	
	;WITH customers AS
	(
		SELECT	c.custid, ci.currency, ci.roleid, autosuspend, cps.reject, cps.closed, MatchLimit, VirtualMultiplier, Enabled,
				DisableOutright,		
				DoubleCommLosing,cm.IsInternal,
				-- For MuayThai
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_MuayThai)),1) AS DisableMuayThai,
				CAST(CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_MuayThai)),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideMuayThai,
				-- For ESports
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_ESports)),1) AS DisableESports,
				CAST(CASE WHEN @IsHidden_ESports = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_ESports)),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideESports,
				-- For AllBet
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableAllBet,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBetVIP)) AS DisableAllBetVIP,
				CAST(	CASE	WHEN	@IsHidden_AllBet = 0 AND @IsHidden_LiveCasino = 0
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideAllBet,
				CAST(CASE	WHEN	@IsHidden_AllBet = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideAllBetUpline,
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @bitmapOrder_LiveCasino)), 0) AS SyncedAllBet,
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapHasSynced, @bitmapOrder_LiveCasino)), 0) AS SyncedAllBetUpline,
				CASE	WHEN EXISTS	(	SELECT	1
										FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
										INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
												ON	ciDownline.custid = cpsDownline.CustID
										WHERE	ciDownline.recommend = c.custid
											AND	(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsDownline.bitmapHasSynced, @bitmapOrder_LiveCasino)) = 0)
							THEN 0
						ELSE 1
				END AS SyncedAllBetDownline,
				-- For SA Gaming
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableSAGaming,
				CAST(	CASE	WHEN	@IsHidden_SAGaming = 0 AND @IsHidden_LiveCasino = 0
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSAGaming,
				CAST(CASE	WHEN	@IsHidden_SAGaming = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideSAGamingUpline,
				-- For Sexy Gaming
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableSexyGaming,
				CAST(	CASE	WHEN	@IsHidden_SexyGaming = 0 AND @IsHidden_LiveCasino = 0
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSexyGaming,
				CAST(CASE	WHEN	@IsHidden_SexyGaming = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0
						THEN 0 ELSE 1
						END AS BIT) AS HideSexyGamingUpline,
				-- For GTCasino
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableGTCasino,
				CAST(	CASE	WHEN	@IsHidden_GTCasino = 0 AND @IsHidden_LiveCasino = 0
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideGTCasino,
				CAST(CASE	WHEN	@IsHidden_GTCasino = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0
						THEN 0 ELSE 1
						END AS BIT) AS HideGTCasinoUpline,
				
				-- For ION
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableION,			
				CAST(	CASE	WHEN	@IsHidden_ION = 0 	AND @IsHidden_LiveCasino = 0							
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideION,
				CAST(CASE	WHEN	@IsHidden_ION = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
							THEN 0 ELSE 1
							END AS BIT) AS HideIONUpline,
				-- For BBIN
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableBBIN,
				CAST(	CASE	WHEN	@IsHidden_BBIN = 0 AND @IsHidden_LiveCasino = 0
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideBBIN,
				CAST(CASE	WHEN	@IsHidden_BBIN = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0
						THEN 0 ELSE 1
						END AS BIT) AS HideBBINUpline,
				-- VoidBridge
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge)),1) AS DisableVoidBridge,
				CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VoidBridge)),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
				CAST(CASE	WHEN	@IsHidden_VoidBridge = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_VoidBridge)), 1)=0
				THEN 0 ELSE 1
				END AS BIT) AS HideVoidBridgeUpline,
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, @bitmapOrder_VoidBridge)), 0) AS SyncedVoidBridge,
				ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapHasSynced, @bitmapOrder_VoidBridge)), 0) AS SyncedVoidBridgeUpline,

				CASE	WHEN EXISTS	(	SELECT	TOP 1 1
										FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
										INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
												ON	ciDownline.custid = cpsDownline.CustID
										WHERE	ciDownline.recommend = c.custid
											AND	(SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsDownline.bitmapHasSynced, @bitmapOrder_VoidBridge)) = 0)
							THEN 0
						ELSE 1
				END AS SyncedVoidBridgeDownline,

				-- For Lottery
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Lottery)) AS DisableLottery,				
				CAST(	CASE	WHEN	@IsHidden_Lottery = 0 
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Lottery)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideLottery,
				CAST(CASE	WHEN	@IsHidden_Lottery = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_Lottery)), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideLotteryUpline,

				-- For VS
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VS)) AS DisableVirtualSports,				
				CAST(	CASE	WHEN	@IsHidden_VS = 0 
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VS)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideVirtualSports,
				CAST(CASE	WHEN	@IsHidden_VS = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_VS)), 1)=0
					THEN 0 ELSE 1
					END AS BIT) AS HideVirtualSportsUpline,

				-- For VG
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VG)) AS DisableVirtualGames,			
				CAST(	CASE	WHEN	@IsHidden_VG = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VG)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideVirtualGames,
				CAST(CASE	WHEN	@IsHidden_VG = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_VG)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideVirtualGamesUpline,
				-- For SabaClub
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SabaClub)) AS DisableSabaClub,			
				CAST(	CASE	WHEN	@IsHidden_SabaClub = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SabaClub)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSabaClub,
				CAST(CASE	WHEN	@IsHidden_SabaClub = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_SabaClub)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSabaClubUpline,
				-- For Table Games
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_TableGames)) AS DisableTableGames,			
				CAST(	CASE	WHEN	@IsHidden_TableGames = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_TableGames)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideTableGames,
				CAST(CASE	WHEN	@IsHidden_TableGames = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_TableGames)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideTableGamesUpline,
				-- For RNG War
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_RNGWar)) AS DisableRNGWar,			
				CAST(	CASE	WHEN	@IsHidden_RNGWar = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_RNGWar)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideRNGWar,
				CAST(CASE	WHEN	@IsHidden_RNGWar = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_RNGWar)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideRNGWarUpline,
				-- For WM
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableWM,			
				CAST(	CASE	WHEN	@IsHidden_WM = 0 AND @IsHidden_LiveCasino = 0								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideWM,
				CAST(CASE	WHEN	@IsHidden_WM = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
							THEN 0 ELSE 1
							END AS BIT) AS HideWMUpline,	
				-- For BG
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableBG,			
				CAST(	CASE	WHEN	@IsHidden_BG = 0 AND @IsHidden_LiveCasino = 0								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideBG,
				CAST(CASE	WHEN	@IsHidden_BG = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
							THEN 0 ELSE 1
							END AS BIT) AS HideBGUpline,
				
				-- For Sports Lottery
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SportsLottery)) AS DisableSportsLottery,			
				CAST(	CASE	WHEN	@IsHidden_SportsLottery = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SportsLottery)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSportsLottery,
				CAST(CASE	WHEN	@IsHidden_SportsLottery = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_SportsLottery)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSportsLotteryUpline,
				-- For PP Live Casino
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisablePPLive,			
				CAST(	CASE	WHEN	@IsHidden_PPLive = 0 AND @IsHidden_LiveCasino = 0								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HidePPLive,
				CAST(CASE	WHEN	@IsHidden_PPLive = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1)=0
							THEN 0 ELSE 1
							END AS BIT) AS HidePPLiveUpline,
				-- For VGaming
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VGaming)) AS DisableVGaming,			
				CAST(	CASE	WHEN	@IsHidden_VGaming = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VGaming)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideVGaming,
				-- For Bitcoin
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Bitcoin)) AS DisableBitcoin,			
				CAST(	CASE	WHEN	@IsHidden_Bitcoin = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Bitcoin)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideBitcoin,
-- For SpadeGaming Jackpot
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SGJackpot)) AS DisableSGJackpot,			
				CAST(	CASE	WHEN	@IsHidden_VoidBridge = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SGJackpot)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSGJackpot,

				-- For Saba Casino
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SabaCasino)) AS DisableSabaCasino,			
				CAST(	CASE	WHEN	@IsHidden_SabaCasino = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SabaCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSabaCasino,
				CAST(CASE	WHEN	@IsHidden_SabaCasino = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_SabaCasino)), 1)=0
							THEN 0 ELSE 1
							END AS BIT) AS HideSabaCasinoUpline,

				-- For Number Games
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_NG)) AS DisableNG,			
				CAST(	CASE	WHEN	@IsHidden_NG = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_NG)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideNG,
				CAST(CASE	WHEN	@IsHidden_NG = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_NG)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideNGUpline,

				-- For Keno
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_Keno)) AS DisableKeno,			
				CAST(	CASE	WHEN	@IsHidden_Keno = 0 								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Keno)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideKeno,
				CAST(CASE	WHEN	@IsHidden_Keno = 0 AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_Keno)), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideKenoUpline,

				-- For YeeBet
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_LiveCasino)) AS DisableYeeBet,			
				CAST(	CASE	WHEN	@IsHidden_YeeBet = 0 AND @IsHidden_LiveCasino = 0								
									AND	ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideYeeBet,
				CAST(CASE	WHEN	@IsHidden_YeeBet = 0 AND @IsHidden_LiveCasino = 0
									AND ISNULL((SELECT [value] FROM dbo.f_CustSetting_ProductStatusSel(cpsUpline.bitmapIsHidden, @bitmapOrder_LiveCasino)), 1) = 0
							THEN 0 ELSE 1
							END AS BIT) AS HideYeeBetUpline,

				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate, ISNULL(cps.Locked,0) AS Locked

		FROM Customer c WITH(NOLOCK)
			INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN CustAgent cm with(NOLOCK) on c.custid = cm.custid 
			CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 1 THEN 1 ELSE 0 END AS reject
										, Locked
										, bitmapIsHidden
										, bitmapIsDisabled
										, bitmapHasSynced
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps
			-- Upline Status
			INNER JOIN	dbo.CustProductStatus AS cpsUpline WITH (NOLOCK)
					ON	cpsUpline.CustID = @MRecommend
		WHERE c.custid IN (SELECT custid FROM #customer) AND (@Userid IS NULL OR (@Userid IS NOT NULL AND c.site NOT IN (SELECT site FROM @tmp )))
	),
	custsetting AS
	(
		SELECT cs.custid,
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupa ELSE 0 END) groupa, --- need to indicate 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupb ELSE 0 END) groupb, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupc ELSE 0 END) groupc, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupd ELSE 0 END) groupd, 
			MAX(CASE WHEN cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,	
			MAX(CASE WHEN cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2	
		FROM dbo.CustSetting cs WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM #customer)
			AND sporttype IN (1) AND bettype IN (1,4,5,20)
		GROUP BY cs.custid 
	)	
	SELECT  ctm.enabled,
			ctm.closed, 
			ISNULL(ctm.reject,0) as suspended,	
			ISNULL(ctm.DisableOutright,0) as DisableOutright,						
			
			ctm.username, 
			ctm.custid, 
			ctm.roleid,
			ISNULL(ctm.ugroup, '') as ugroup , 
			ISNULL(ctm.firstname, '') as firstname , 
			ISNULL(ctm.lastname, '') as lastname, 
			ctm.username2,
			ISNULL(ctm.phone, '') as phone,
			ISNULL(ctm.mobilephone, '') as mobilephone,
			ISNULL(ctm.iplogin, '') as lastloginip,
			cs.groupa as groupa, 
			cs.groupb as groupb, 
			cs.groupc as groupc, 
			cs.groupd as groupd, 
			discountcs discountcs,	
			discount1x2 discount1x2,		
			ctm.currency,	
			ctm.matchlimit,
			ctm.virtualmultiplier-1 as VirtualMultiplier,
			ctm.creatdate as createdate,
			
			ctm.isinternal,		
			
			---- For VirtualSports
			ctm.DoubleCommLosing,			
			
			ctm.DisableMuayThai,
			ctm.HideMuayThai,
			ctm.DisableESports,
			ctm.HideESports,

			ctm.DisableAllBet,
			ctm.DisableAllBetVIP,
			ctm.HideAllBet,
			ctm.HideAllBetUpline,
			ctm.SyncedAllBet,
			ctm.SyncedAllBetUpline,
			ctm.SyncedAllBetDownline,
			--SA Gaming
			ctm.DisableSAGaming,
			ctm.HideSAGaming,
			ctm.HideSAGamingUpline,
			--Sexy Gaming
			ctm.DisableSexyGaming,
			ctm.HideSexyGaming,
			ctm.HideSexyGamingUpline,
			--GTCasino
			ctm.DisableGTCasino,
			ctm.HideGTCasino,
			ctm.HideGTCasinoUpline,
			--ION
			ctm.DisableION,
			ctm.HideION,
			ctm.HideIONUpline,
			--BBIN
			ctm.DisableBBIN,
			ctm.HideBBIN,
			ctm.HideBBINUpline,
			-- VoidBrigde
			ctm.DisableVoidBridge,
			ctm.HideVoidBridge,
			ctm.HideVoidBridgeUpline,
			ctm.SyncedVoidBridge,
			ctm.SyncedVoidBridgeUpline,
			ctm.SyncedVoidBridgeDownline,
			-- Lottery
			ctm.DisableLottery,
			ctm.HideLottery,
			ctm.HideLotteryUpline,
			-- VS
			ctm.DisableVirtualSports,
			ctm.HideVirtualSports,
			ctm.HideVirtualSportsUpline,
			--VG
			ctm.DisableVirtualGames,
			ctm.HideVirtualGames,
			ctm.HideVirtualGamesUpline,
			--SabaClub
			ctm.DisableSabaClub,
			ctm.HideSabaClub,
			ctm.HideSabaClubUpline,
			--TableGames
			ctm.DisableTableGames,
			ctm.HideTableGames,
			ctm.HideTableGamesUpline,
			--RNGWar
			ctm.DisableRNGWar,
			ctm.HideRNGWar,
			ctm.HideRNGWarUpline,
			--WM
			ctm.DisableWM,
			ctm.HideWM,
			ctm.HideWMUpline,
			--BG
			ctm.DisableBG,
			ctm.HideBG,
			ctm.HideBGUpline,
			--Sports Lottery
			ctm.DisableSportsLottery,
			ctm.HideSportsLottery,
			ctm.HideSportsLotteryUpline,
			--PP Live Casino
			ctm.DisablePPLive,
			ctm.HidePPLive,
			ctm.HidePPLiveUpline,
			
			--VGaming
			ctm.DisableVGaming,
			ctm.HideVGaming,
			--Bitcoin
			ctm.DisableBitcoin,
			ctm.HideBitcoin,
			--SpadeGaming Jackpot
			ctm.DisableSGJackpot,
			ctm.HideSGJackpot,
			--Saba Casino
			ctm.DisableSabaCasino,
			ctm.HideSabaCasino,
			ctm.HideSabaCasinoUpline,

			--NumberGame
			ctm.DisableNG,
			ctm.HideNG,
			ctm.HideNGUpline,
			--Keno
			ctm.DisableKeno,
			ctm.HideKeno,
			ctm.HideKenoUpline,
			--YeeBet
			ctm.DisableYeeBet,
			ctm.HideYeeBet,
			ctm.HideYeeBetUpline,
			-- MyanmarOdds
			ISNULL(t.IsMyanmarOdds,0) AS IsMyanmarOdds,
			ISNULL(t.discountMyanmarOdds,0) AS discountMyanmarOdds,
			ctm.Locked,
			RowNumber,
			ISNULL(cl.ClosedReason,0) AS ClosedReason
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN custsetting cs WITH (NOLOCK) ON ctm.custid = cs.custid
		LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON t.custid=cl.CustID
		
	ORDER BY  t.RowNumber	

	DROP TABLE #customer
END
GO
