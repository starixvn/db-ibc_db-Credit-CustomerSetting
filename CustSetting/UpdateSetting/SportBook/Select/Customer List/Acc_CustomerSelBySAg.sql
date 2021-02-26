/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelBySAg]
	@SRecommend int,
	@IsAgentSite bit = 0,
	@Username varchar(30)=null,
	@Enabled bit = null,
	@Closed bit=null,
	@Suspended bit=null,
	@DoubleCommLosing tinyint = 2,
	@ProductUnSync TINYINT = 0,--0: not filter
	@PageSize int = 20000,
	@PageIndex int = 1,
	@TotalPages int = 1 output,
	@TotalItems int=0 output,
	@SettingStatus TINYINT = 0
AS
/*
	Created by: []
	Date: []
	Task: Master List 
	DB: DBCust/CustDB
	Original: magentsite/account\customerlist.asp
	
	Revisions:
		- 20080912@PhuongNguyen: Remove checking HR currency
		- 20090312@Lee: Return 2 more fields for casino
		- 20090522@PhuongDao: Add 1x2 Commission 
		- 20090701@Phuc: allow super disable auto MPT.
		- 20090710@Phuc: unhide IP for TB currency.
		- 20090807@Simon: Add a column "enabled" in Select and Order by it.
		- 20090823@Phuc: paging.
		- 20090910@Shifu: Add IsInternal
		- 20100531@Hanh: get one more field disableOpenTote
		- 20100904@Lukas: get Bingo status, number game status
		- 20110311@Lukas: get racing game status (AU Horse, Greyhound, Harness)
		- 20110422@Lukas: get racing status in detail (each racing partner)
		- 20110623@Sophia: add username2
		- 20111124@Johnson: get P2P status
		- 20120201@Sophia: Get DisableLiveCasino, SyncLiveCasino for Live Casino
		- 20120817@Sophia: Get DisableVirtualSports
		- 20120926@Sophia: - Add parameter @DoubleCommLosing, get DoubleCommLosing
							- Ouput total records affects
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
		- 20160407@Winnie: VoidBridge - [Redmine: #55259 ]
		- 20160801@Elodie: NG2 Product - [Redmine: #60809]
		- 20160810@Winnie: #61733 add more bettype VIP Barcarat setting
		- 20170120@Elodie: Don't offer Massac(1507), Malta(1509) anymore [#70693]
		- 20161028@Winnie: Fishing world [Redmine's Ids: #65474]
		- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]	
		- 20170417@Winnie: Change to call the sp Acc_CheckShowProduct- [Redmine #72336]	
		- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
		- 20170801@Elodie: Add Keno Lottery Product - [Redmine #74313]
		- 20170620@Winnie: Apply color for closed accounts [RedmineID: #74494]
		- 20170808@Elodie: Lucky3 Product - [Redmine: #75521]
		- 20170925@Johnson: Add filter product un-sync for Casino,GD,Allbet,Macau [Redmine: #72973]
		- 20171001@Elodie: BullFighting Product - [Redmine: #81664]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20180529@Winnie: Alpha/EXT NAP - Super/Master/Agent/Member List: missing 6 new Keno bettypes in select SP [RedmineID: #96035]
		- 20180703@Elodie: Poker Games Product - [Redmine: #97675]
		- 20180830@Elodie: Add new bettype of Poker Games Product - [Redmine: #97675]
		- 20180918@Winnie: Esports Product - [Redmine: #101526]
		- 20190510@Elodie: Support search by nickname on customer list - [Redmine: #113044]
		- 20190724@Eden: add bettype 1525,1526 for Keno gametype - [Redmine: #116466]
		- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
		- 20191206@Eden: Add Virtual Games [Redmine: #122743]
		- 20200318@Elodie: Add Saba.club [Redmine: #130636]
		- 20200303@Tiara: Add SA Gaming Product [Redmine: #128058]
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
	----- Elodie @ 01 JUN 2015 -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)	

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK) WHERE IsDisabled = 0 AND IBCBetTypeID BETWEEN 1501 AND 1599
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK) WHERE IsDisabled = 0 AND IBCBetTypeID BETWEEN 1501 AND 1599
	END CATCH
	----- /Elodie @ 01 JUN 2015 -------------------

	DECLARE @RowCount int, @RowStart int, @RowEnd int
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	SET @Username = ISNULL(@Username, '')
	
	-- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT		
		,	@bitmapOrder_Esports		INT		
		,	@bitmapOrder_AllBet			INT
		,	@bitmapOrder_AllBetVIP		INT
		,	@bitmapOrder_VoidBridge		INT
		,	@bitmapOrder_Lottery		INT
		,	@bitmapOrder_NG2			INT
		,	@bitmapOrder_FishingWorld	INT
		,	@bitmapOrder_VS				INT
		,	@bitmapOrder_VG				INT
		,	@bitmapOrder_SabaClub		INT
		,	@bitmapOrder_SAGaming		INT 
		,	@bitmapOrder_SexyGaming		INT 
		,	@bitmapOrder_ION			INT 
		,	@bitmapOrder_BBIN			INT 
		,	@bitmapOrder_TableGames		INT 
		,	@bitmapOrder_GTCasino		INT
		,	@bitmapOrder_RNGWar			INT
		,	@bitmapOrder_WM				INT  
		,	@bitmapOrder_GDG			INT  
		,	@bitmapOrder_BG				INT 
		,	@bitmapOrder_SportsLottery	INT  

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
	SET @bitmapOrder_SexyGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 243 AND Bettype = 3101)
	SET @bitmapOrder_ION = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 225 AND Bettype = 5601)
	SET @bitmapOrder_BBIN = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 241 AND Bettype = 3300)
	SET @bitmapOrder_TableGames = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 222 AND Bettype = 4901)
	SET @bitmapOrder_GTCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 242 AND Bettype = 3201)
	SET @bitmapOrder_RNGWar = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 224 AND Bettype = 5500)
	SET @bitmapOrder_WM = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 233 AND Bettype = 3401)
	SET @bitmapOrder_GDG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 236 AND Bettype = 5701)
	SET @bitmapOrder_BG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 169 AND Bettype = 3501)
	SET @bitmapOrder_SportsLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 239 AND Bettype = 3611)
	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
    SELECT	@bitmapOrder_AllBetVIP = (SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE psp.Sporttype = 211 AND	psp.Bettype = 2402)
    
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
		,	@IsHidden_SexyGaming		INT = 1
		,	@IsHidden_ION				INT = 1
		,	@IsHidden_BBIN				INT = 1
		,	@IsHidden_TableGames		INT = 1
		,	@IsHidden_GTCasino			INT = 1
		,	@IsHidden_RNGWar			INT = 1
		,	@IsHidden_WM				INT = 1
		,	@IsHidden_GDG				INT = 1
		,	@IsHidden_BG				INT = 1
		,	@IsHidden_SportsLottery		INT = 1

    EXEC Acc_CheckShowProduct @ProductID = 16, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_MuayThai OUTPUT	
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 211, @IsHide = @IsHidden_AllBet OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 22, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 220, @IsHide = @IsHidden_Lottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 23, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_NG2 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 24, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_FishingWorld OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 16, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_Esports OUTPUT	

	EXEC Acc_CheckShowProduct @ProductID = 5, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VS OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 38, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_VG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 42, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_SabaClub OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 244, @IsHide = @IsHidden_SAGaming OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 243, @IsHide = @IsHidden_SexyGaming OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 242, @IsHide = @IsHidden_GTCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 225, @IsHide = @IsHidden_ION OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 241, @IsHide = @IsHidden_BBIN OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 222, @IsHide = @IsHidden_TableGames OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 224, @IsHide = @IsHidden_RNGWar OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 233, @IsHide = @IsHidden_WM OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 236, @IsHide = @IsHidden_GDG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @Sporttype = 239, @IsHide = @IsHidden_BG OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @SettingStatus = @SettingStatus, @Sporttype = 169, @IsHide = @IsHidden_SportsLottery OUTPUT
	
	CREATE TABLE #customer(custid INT primary key, RowNumber INT, adiscountMyanmarOdds DECIMAL (9,8), IsMyanmarOdds BIT)
							
	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL AND @DoubleCommLosing = 2
	BEGIN
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync = 0
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3				
			END	
			ELSE IF @ProductUnSync IN (6,12)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3	
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)	
			END
			ELSE IF @ProductUnSync IN (41,22)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
			END		
			
		END
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber 
			FROM (
					SELECT ci.custid ,ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ISNULL(ci.reject,0), ci.username) AS RowNumber 
					FROM customer c WITH (NOLOCK) 
						INNER JOIN custInfo ci WITH(NOLOCK) ON c.custid = ci.custid 
					WHERE c.srecommend= @SRecommend 
						AND c.roleid=3 
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END			
				) t 
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END
		ELSE IF @ProductUnSync IN (6,12)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber 
			FROM (
					SELECT ci.custid ,ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ISNULL(ci.reject,0), ci.username) AS RowNumber 
					FROM customer c WITH (NOLOCK) 
						INNER JOIN custInfo ci WITH(NOLOCK) ON c.custid = ci.custid 
					WHERE c.srecommend= @SRecommend 
						AND c.roleid=3 
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END			
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
				) t 
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END
		ELSE IF @ProductUnSync IN (41,22)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber 
			FROM (
					SELECT ci.custid ,ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ISNULL(ci.reject,0), ci.username) AS RowNumber 
					FROM customer c WITH (NOLOCK) 
						INNER JOIN custInfo ci WITH(NOLOCK) ON c.custid = ci.custid 
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid
					WHERE c.srecommend= @SRecommend 
						AND c.roleid=3 
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END			
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
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
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
			END
			ELSE IF	@ProductUnSync IN (6,12)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
			END
			ELSE IF	@ProductUnSync IN (41,22)
			BEGIN
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
			END
		END
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber
			FROM (
					SELECT c.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ISNULL(ci.reject,0), c.username) as RowNumber 
					FROM dbo.customer c WITH(NOLOCK)
						INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON c.custid = ci.custid 
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END 
		ELSE IF @ProductUnSync IN (6,12)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber
			FROM (
					SELECT c.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ISNULL(ci.reject,0), c.username) as RowNumber 
					FROM dbo.customer c WITH(NOLOCK)
						INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON c.custid = ci.custid 
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END
		ELSE IF @ProductUnSync IN (41,22)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT t.custid, RowNumber
			FROM (
					SELECT c.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ISNULL(ci.reject,0), c.username) as RowNumber 
					FROM dbo.customer c WITH(NOLOCK)
						INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON c.custid = ci.custid 
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend
		END	
	END
	ELSE
	BEGIN 
		
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync =0 
			BEGIN			
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 then 1 else 0 end  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND (ci.username LIKE '%' + @Username + '%' OR c.username2 LIKE '%' + @Username + '%')
					AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
			END
			ELSE IF @ProductUnSync IN (6,12) 
			BEGIN			
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 then 1 else 0 end  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND (ci.username LIKE '%' + @Username + '%' OR c.username2 LIKE '%' + @Username + '%')
					AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
			END
			ELSE IF @ProductUnSync IN (41,22)
			BEGIN			
				SELECT 
					@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 then 1 else 0 end  
				FROM dbo.Custinfo AS ci WITH (NOLOCK)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid
				WHERE ci.SRecommend = @SRecommend 
					AND ci.roleid=3
					AND (ci.username LIKE '%' + @Username + '%' OR c.username2 LIKE '%' + @Username + '%')
					AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
			END
		END
		
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT custid, RowNumber
			FROM (
					SELECT c.custid , ROW_NUMBER() OVER (ORDER BY c.enabled DESC, c.closed, ISNULL(c.reject,0), c.username) as RowNumber 
					FROM dbo.custinfo c WITH(NOLOCK) 
						INNER JOIN Customer cu WITH (NOLOCK) ON c.custid = cu.custid
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND (c.username LIKE '%' + @Username + '%' OR cu.username2 LIKE '%' + @Username + '%')
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END			
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend 			
		END
		ELSE IF @ProductUnSync IN (6,12)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT custid, RowNumber
			FROM (
					SELECT c.custid , ROW_NUMBER() OVER (ORDER BY c.enabled DESC, c.closed, ISNULL(c.reject,0), c.username) as RowNumber 
					FROM dbo.custinfo c WITH(NOLOCK) 
						INNER JOIN Customer cu WITH (NOLOCK) ON c.custid = cu.custid
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND (c.username LIKE '%' + @Username + '%' OR cu.username2 LIKE '%' + @Username + '%')
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END			
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend 			
		END
		ELSE IF @ProductUnSync IN (41,22)
		BEGIN
			INSERT INTO #customer (custid, RowNumber)
			SELECT custid, RowNumber
			FROM (
					SELECT c.custid , ROW_NUMBER() OVER (ORDER BY c.enabled DESC, c.closed, ISNULL(c.reject,0), c.username) as RowNumber 
					FROM dbo.custinfo c WITH(NOLOCK) 
						INNER JOIN Customer cu WITH (NOLOCK) ON c.custid = cu.custid
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON c.custid = cs.custid
					WHERE c.srecommend = @SRecommend 
						AND c.roleid=3
						AND (c.username LIKE '%' + @Username + '%' OR cu.username2 LIKE '%' + @Username + '%') 
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
						AND ISNULL(closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(closed, 0)) END
						AND ISNULL(reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(reject, 0))END			
						AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
				) t
			WHERE rownumber BETWEEN @rowstart AND @rowend 			
		END
	END
	
	-- MyanmarOdds
	DECLARE @IsMyanmarOdds BIT = 0	
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds(@srecommend)
	IF @IsMyanmarOdds = 1
	BEGIN
		UPDATE T
			SET adiscountMyanmarOdds = ac.CommRate, t.IsMyanmarOdds = @IsMyanmarOdds
		FROM #customer T
			JOIN AgentCommRate ac WITH (NOLOCK) ON T.custid = AC.CustId 
		WHERE ac.Sporttype = 1 AND ac.Bettype = 1		
	END
	
	-- get data for filtered customers
	
	;WITH customers AS
	(
		SELECT	c.custid, ci.currency, ci.roleid, autosuspend, reject, closed, MatchLimit, VirtualMultiplier, Enabled, 
				DisableCasino, SyncCasino, DisableOutright, DisableNumber,
				
				DoubleCommLosing,HideKeno, HideGoldDeluxe, DisableGoldDeluxe,
				-- For MuayThai
				ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
				CAST(CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideMuayThai,
				-- For Esports
				ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Esports),1) AS DisableEsports,
				CAST(CASE WHEN @IsHidden_Esports = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Esports),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideEsports,
				
				-- For AllBet
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBet)) AS DisableAllBet,
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_AllBetVIP)) AS DisableAllBetVIP,
				CAST(	CASE	WHEN	@IsHidden_AllBet = 0 
									--AND	sbhsc.IsHidden = 0
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
										WHERE	ciDownline.mrecommend = c.custid
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
				CAST(CASE	WHEN	@IsHidden_SAGaming = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_SAGaming), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSAGamingUpline,
				-- For Sexy Gaming
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SexyGaming)) AS DisableSexyGaming,
				CAST(	CASE	WHEN	@IsHidden_SexyGaming = 0 
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SexyGaming), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSexyGaming,
				CAST(CASE	WHEN	@IsHidden_SexyGaming = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_SexyGaming), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSexyGamingUpline,
				-- For GTCasino
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_GTCasino)) AS DisableGTCasino,
				CAST(	CASE	WHEN	@IsHidden_GTCasino = 0 
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_GTCasino), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideGTCasino,
				CAST(CASE	WHEN	@IsHidden_GTCasino = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_GTCasino), 1) = 0
						THEN 0 ELSE 1
						END AS BIT) AS HideGTCasinoUpline,
				-- For ION
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_ION)) AS DisableION,			
				CAST(	CASE	WHEN	@IsHidden_ION = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_ION), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideION,
				CAST(CASE	WHEN	@IsHidden_ION = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_ION), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideIONUpline,
				-- For BBIN
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_BBIN)) AS DisableBBIN,
				CAST(	CASE	WHEN	@IsHidden_BBIN = 0 
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_BBIN), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideBBIN,
				CAST(CASE	WHEN	@IsHidden_BBIN = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_BBIN), 1) = 0
						THEN 0 ELSE 1
						END AS BIT) AS HideBBINUpline,
				-- For Fishing World
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
										WHERE	ciDownline.mrecommend = c.custid
											AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_FishingWorld) = 0)
							THEN 0
						ELSE 1
				END AS SyncedFishingWorldDownline,
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
										WHERE	ciDownline.mrecommend = c.custid
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
				
				-- For VS
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VS)) AS DisableVirtualSports,			
				CAST(	CASE	WHEN	@IsHidden_VS = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VS), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideVirtualSports,
				CAST(CASE	WHEN	@IsHidden_VS = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VS), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideVirtualSportsUpline,
		
				-- For VG
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_VG)) AS DisableVirtualGames,			
				CAST(	CASE	WHEN	@IsHidden_VG = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VG), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideVirtualGames,
				CAST(CASE	WHEN	@IsHidden_VG = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VG), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideVirtualGamesUpline,
				-- For SabaClub
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SabaClub)) AS DisableSabaClub,			
				CAST(	CASE	WHEN	@IsHidden_SabaClub = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SabaClub), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSabaClub,
				CAST(CASE	WHEN	@IsHidden_SabaClub = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_SabaClub), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSabaClubUpline,
				-- For Table Games
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_TableGames)) AS DisableTableGames,			
				CAST(	CASE	WHEN	@IsHidden_TableGames = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_TableGames), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideTableGames,
				CAST(CASE	WHEN	@IsHidden_TableGames = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_TableGames), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideTableGamesUpline,

				-- For RNG War
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_RNGWar)) AS DisableRNGWar,			
				CAST(	CASE	WHEN	@IsHidden_RNGWar = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_RNGWar), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideRNGWar,
				CAST(CASE	WHEN	@IsHidden_RNGWar = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_RNGWar), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideRNGWarUpline,
				-- For WM
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_WM)) AS DisableWM,			
				CAST(	CASE	WHEN	@IsHidden_WM = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_WM), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideWM,
				CAST(CASE	WHEN	@IsHidden_WM = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_WM), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideWMUpline,		
				-- For GDG
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_GDG)) AS DisableGDG,			
				CAST(	CASE	WHEN	@IsHidden_GDG = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_GDG), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideGDG,
				CAST(CASE	WHEN	@IsHidden_GDG = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_GDG), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideGDGUpline,
				-- For BG
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_BG)) AS DisableBG,			
				CAST(	CASE	WHEN	@IsHidden_BG = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_BG), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideBG,
				CAST(CASE	WHEN	@IsHidden_BG = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_BG), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideBGUpline,
				-- For Sports Lottery
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_SportsLottery)) AS DisableSportsLottery,			
				CAST(	CASE	WHEN	@IsHidden_SportsLottery = 0 								
									AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_SportsLottery), 1) = 0 
									THEN 0
								ELSE 1 
						END AS BIT) AS HideSportsLottery,
				CAST(CASE	WHEN	@IsHidden_SportsLottery = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_SportsLottery), 1)=0
						THEN 0 ELSE 1
						END AS BIT) AS HideSportsLotteryUpline,		
				cm.IsInternal, cm.DisableAutoMPT,
				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate
		FROM dbo.Customer c WITH(NOLOCK)
			INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN dbo.CustMaster cm with(NOLOCK) on c.custid = cm.custid 
			LEFT JOIN dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 

			-- Check isHidden AllBet
			--OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(c.custid, @AllBet) AS sbhsc
		
			-- Upline Status
			INNER JOIN	dbo.CustProductStatus AS cpsUpline WITH (NOLOCK)
					ON	cpsUpline.CustID =	CASE	WHEN c.roleid = 1 THEN c.recommend
													WHEN c.roleid = 2 THEN c.mrecommend
													ELSE c.srecommend
											END
		   
		WHERE c.custid IN (SELECT custid FROM #customer)
	),
	custsetting AS
	(
		SELECT cs.custid,
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupa ELSE 0 END) groupa, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupb ELSE 0 END) groupb, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupc ELSE 0 END) groupc, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupd ELSE 0 END) groupd, 
			MAX(CASE WHEN cs.bettype = 4 and cs.sporttype=1 then cs.adiscount else 0 end) as discountcs,	
			MAX(CASE WHEN cs.bettype = 5 and cs.sporttype=1 then cs.adiscount else 0 end) as discount1x2
		FROM dbo.CustSetting cs WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM #customer)
			AND sporttype IN (1) AND bettype IN (1,4,5,20)
		GROUP BY cs.custid 
	),
	keno AS
	(
		SELECT	cg.CustID
				,MIN(CAST(cg.IsDisabled AS TINYINT)) as DisableKeno
		FROM dbo.CustGameType cg WITH(NOLOCK) 
			INNER JOIN @tmp_GameType g ON cg.GameTypeID = g.GameTypeID
		WHERE CustID IN (SELECT CustID FROM #customer)
		GROUP BY cg.CustID 
	)
	SELECT  ctm.enabled,
			ctm.closed, 
			ISNULL(ctm.reject,0) as suspended,	
			ISNULL(ctm.DisableOutright,0) as DisableOutright,
			ISNULL(ctm.DisableAutoMPT,0) as DisableAutoMPT,	
			
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
		
			-- For casino
			ctm.synccasino,
			ctm.disablecasino,
			
			ctm.isinternal,
			ctm.DisableNumber,
			ctm.DoubleCommLosing,

			ctm.HideKeno,
			ISNULL(DisableKeno,0) DisableKeno,
			ISNULL(ctm.HideGoldDeluxe,1) AS HideGoldDeluxe,
			ISNULL(ctm.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ctm.DisableMuayThai,
			ctm.HideMuayThai,
			ctm.DisableEsports,
			ctm.HideEsports,
		
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
			--VoidBridge
			ctm.DisableVoidBridge,
			ctm.HideVoidBridge,
			ctm.HideVoidBridgeUpline,
			ctm.SyncedVoidBridge,
			ctm.SyncedVoidBridgeUpline,
			ctm.SyncedVoidBridgeDownline,
			ctm.DisableNG2,
			ctm.HideNG2,
			ctm.HideNG2Upline,
			ctm.SyncedNG2,
			ctm.SyncedNG2Upline,
			ctm.DisableFishingWorld,
			ctm.HideFishingWorld,
			ctm.HideFishingWorldUpline,
			ctm.SyncedFishingWorld,
			ctm.SyncedFishingWorldUpline,
			ctm.SyncedFishingWorldDownline,
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
			--Table Games
			ctm.DisableTableGames,
			ctm.HideTableGames,
			ctm.HideTableGamesUpline,
			--RNG War
			ctm.DisableRNGWar,
			ctm.HideRNGWar,
			ctm.HideRNGWarUpline,
			-- MyanmarOdds
			ISNULL(t.IsMyanmarOdds,0) AS IsMyanmarOdds,
			ISNULL(t.adiscountMyanmarOdds,0) AS discountMyanmarOdds,
			
			--WM
			ctm.DisableWM,
			ctm.HideWM,
			ctm.HideWMUpline,

			--GDG
			ctm.DisableGDG,
			ctm.HideGDG,
			ctm.HideGDGUpline,
			--BG
			ctm.DisableBG,
			ctm.HideBG,
			ctm.HideBGUpline,
			--Sports Lottery
			ctm.DisableSportsLottery,
			ctm.HideSportsLottery,
			ctm.HideSportsLotteryUpline,
			
			ISNULL(cl.ClosedReason,0)  AS ClosedReason,
			RowNumber
			
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN custsetting cs WITH (NOLOCK) ON ctm.custid = cs.custid
		LEFT JOIN keno k ON ctm.custid = k.CustID	
		LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON t.custid=cl.Custid
	ORDER BY  t.RowNumber	
	
END
GO
