/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelBySAg]
	@SRecommend int,
	@IsAgentSite bit = 0,
	@Username varchar(30)=null,
	@Enabled bit = null,
	@Closed bit=null,
	@Suspended bit=null,
	@PageSize int = 20000,
	@PageIndex int = 1,
	@TotalPages int = 1 output,
	@TotalItems int=0 output,
	@SettingStatus TINYINT = 0,
	@Locked BIT = NULL -- 1: Locked filter
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
		- 20210318@Winfred: HF Sports Lottery - Modify sportype BG [RedmineID: #151952]
		- 20210315@Tina: add PP Live Casino [RedmineID: #134041]
		- 20210426@Tina: Add VGaming [Redmine: #153938]
		- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210809@Winfred: add Bitcoin Betting  / not used HideUpline [RedmineID: #159039]
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
		- 20240405@Kelvin: Update View Master/Agent/Member list [RedmineID: #202877]

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

	DECLARE @SiteID INT , @Currency INT

	SELECT @Currency = ci.currency, @SiteID = s.siteid
	FROM customer ci WITH(NOLOCK) 
		INNER JOIN Site s WITH(NOLOCK) ON ci.site = s.site
	WHERE ci.custid = @SRecommend
	

	
	CREATE TABLE #customer(custid INT primary key, RowNumber INT, adiscountMyanmarOdds DECIMAL (9,8), IsMyanmarOdds BIT)
							
	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL AND @Locked IS NULL
	BEGIN
		IF @TotalPages = 0
		BEGIN			
			SELECT 
				@TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
			FROM dbo.Custinfo AS ci WITH (NOLOCK)
			WHERE ci.SRecommend = @SRecommend 
				AND ci.roleid=3				
		END					
			
		INSERT INTO #customer (custid, RowNumber)
		SELECT t.custid, RowNumber 
		FROM (
				SELECT ci.custid ,ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, ISNULL(cs.reject,0), ci.username) AS RowNumber 
				FROM custInfo ci WITH (NOLOCK) 
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs
				WHERE ci.srecommend= @SRecommend 
					AND ci.roleid=3 								
			) t 
		WHERE rownumber BETWEEN @rowstart AND @rowend				
	END
	ELSE IF @Username = ''
	BEGIN		
		IF @TotalPages = 0
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
			WHERE ci.SRecommend = @SRecommend 
				AND ci.roleid=3
				AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
				AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END							
				AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
		END
			
		INSERT INTO #customer (custid, RowNumber)
		SELECT t.custid, RowNumber
		FROM (
				SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber 
				FROM dbo.custinfo ci WITH(NOLOCK) 
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs
				WHERE ci.srecommend = @SRecommend 
					AND ci.roleid=3
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END
					AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			) t
		WHERE rownumber BETWEEN @rowstart AND @rowend
	END 				
	ELSE
	BEGIN 		
		IF @TotalPages = 0
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
			WHERE ci.SRecommend = @SRecommend 
				AND ci.roleid=3
				AND (ci.username LIKE '%' + @Username + '%' OR c.username2 LIKE '%' + @Username + '%')
				AND enabled = CASE WHEN coalesce(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
				AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
				AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
		END
			
		INSERT INTO #customer (custid, RowNumber)
		SELECT custid, RowNumber
		FROM (
				SELECT c.custid , ROW_NUMBER() OVER (ORDER BY c.enabled DESC, cs.closed, ISNULL(cs.reject,0), c.username) as RowNumber 
				FROM dbo.custinfo c WITH(NOLOCK) 
					INNER JOIN Customer cu WITH (NOLOCK) ON c.custid = cu.custid
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = c.custid
							) AS cs
				WHERE c.srecommend = @SRecommend 
					AND c.roleid=3
					AND (c.username LIKE '%' + @Username + '%' OR cu.username2 LIKE '%' + @Username + '%')
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND iSNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			) t
		WHERE rownumber BETWEEN @rowstart AND @rowend 			
	END

	-- get data for filtered customers	
	;WITH customers AS
	(
		SELECT	c.custid, ci.currency, ci.roleid, autosuspend, cps.reject, cps.closed, MatchLimit, VirtualMultiplier, Enabled, 				
				cm.IsInternal, cm.DisableAutoMPT,
				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate,ISNULL(cps.Locked,0) AS Locked 
		FROM dbo.Customer c WITH(NOLOCK)
			INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN dbo.CustMaster cm with(NOLOCK) on c.custid = cm.custid 
			CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked										
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
						 ) AS cps	  			
		WHERE c.custid IN (SELECT custid FROM #customer)
	),
	custsetting AS
	(
		SELECT cda.custid			
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 1 THEN cda.Discount END) AS groupa
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 3 THEN cda.Discount END) AS groupb
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 7 THEN cda.Discount END) AS groupc
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 8 THEN cda.Discount END) AS groupd
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 5 THEN cda.Discount END) AS discount1x2
			,MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 4 THEN cda.Discount END) AS discountcs			
		FROM dbo.CustDiscount3rd_Agent cda WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM #customer)
			AND cda.SportType IN (1)
		GROUP BY cda.custid 
	)	
	SELECT  ctm.enabled,
			ctm.closed, 
			ISNULL(ctm.reject,0) as suspended,	
			ctm.username, 
			ctm.custid, 
			ctm.roleid,
			ISNULL(ctm.ugroup, '') as ugroup , 
			ISNULL(ctm.firstname, '') as firstname , 
			ISNULL(ctm.lastname, '') as lastname, 
			ctm.username2,
			ISNULL(ctm.iplogin, '') as lastloginip,
			cs.groupa as groupa, 
			cs.groupb as groupb, 
			cs.groupc as groupc, 
			cs.groupd as groupd, 
			cs.discountcs discountcs,	
			cs.discount1x2 discount1x2,			
			ctm.currency,	
			ctm.matchlimit,
			ctm.virtualmultiplier-1 as VirtualMultiplier,
			ISNULL(cl.ClosedReason,0)  AS ClosedReason,
			ctm.Locked,
			RowNumber	
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN custsetting cs WITH (NOLOCK) ON ctm.custid = cs.custid
		LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON t.custid=cl.Custid
	ORDER BY  t.RowNumber	
	
	DROP TABLE #customer
END
GO
