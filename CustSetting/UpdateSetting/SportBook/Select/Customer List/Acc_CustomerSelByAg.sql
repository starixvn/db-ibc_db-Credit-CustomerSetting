/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelByAg]  
	@Recommend int,  
	@IsAgentSite bit = 0,  
	@Username varchar(30)=null,  
	@Enabled bit = null,  
	@Closed bit=null,  
	@Suspended bit=null,
	@PageSize int = 20000,  
	@PageIndex int = 1,  
	@TotalPages int = 1 output,
	@TotalItems int=0 OUTPUT,
	@Userid		INT=NULL,
	@SettingStatus TINYINT = 0,
	@Locked BIT = NULL -- 1: Locked filter 
AS 
BEGIN 
/*  
	Created by: []  
	Date:[]  
	Task: Member List   
	DB: DBCUST/CustDB
	Original: agentsite/account\customerlist.asp  

	Revisions:  
		- 20060222@[]: Remove refno   
		- 20080612@PhuongNguyen: Remove roleid and checking HR currency function  
		- 20090312@Lee: Return 2 more fields for casino  
		- 20090522@PhuongDao: Add 1x2 Commission   
		- 20090710@Phuc: unhide IP for TB currency.  
		- 20090807@Simon: Add a column "enabled" in Select and Order by it.  
		- 20090822@Phuc: paging.  
		- 20100531@Hanh: get one more field disableOpenTote  
		- 20100908@KhoaTrinh: get more Bingo status, number game status  
		- 20110115@Johnson: separate get setting from custsetting and custsetting3rd  
		- 20110311@Lukas: get racing game status (AU Horse, Greyhound, Harness)
		- 20110422@Lukas: get racing status in detail (each racing partner)
		- 20110623@Sophia: remove alias nickname of username2 
		- 20111124@Johnson: get P2P status
		- 20120201@Sophia: Get DisableLiveCasino, SyncLiveCasino for Live Casino
		- 20120817@Sophia: Get DisableVirtualSports
		- 20120926@Sophia:- Add parameter @DoubleCommLosing, get DoubleCommLosing
		- 20130814@Viet: enhance SP
		- 20131017@Kathy: Add HR Fixed Odds (154) [Redmine:#6505]
		- 20140116@Elodie: Hot fix to get information of disabled customer
						   Output total records affect
		- 20140407@Elodie: Add Keno product [Redmine:#13156]
		- 20150422@Elodie: Add Gold Deluxe product [Redmine:#11658]
		- 20150601@Elodie: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB, Use temp table for GameType table)
		- 20150825@Helen: Colossus Bet - [Redmine: #41264]
		- 20150904@Helen: commission setting for MO [Redmine #41470]
		- 20151028@Helen: Member Information to support Muay Thai  [Redmine: #45496]
		- 20151209@Helen: Member information for Cockfighting [Redmine: #48133]
		- 20160114@Helen: Cricket - [Redmine: #50027]
		- 20160127@Billy: Member information for AllBet - [Redmine: #51591]
		- 20160406@Dominic: HotFix Alpha-Customer List, Page Navigation is not shown If Filter Status/Double Comm <> "All" - [Redmine: #55457]
		- 20160407@Winnie: VoidBridge [Redmine's Ids: #55258]
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
		- 20180918@Winnie: Add new bettype of Esports  - [Redmine: #101526]
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
		- 20200428@Eden: HotFix_-_The_status_Virtual_game_show_grey_color [Redmine: #133328]
		- 20200504@Eden: ION Live casino [Redmine: #132323]		
		- 20200506@Tiara: Add RNG War Product [Redmine: 132018]
		- 20200713@Eden: Integrate 3 new bet types for Keno [Redmine: #137475]
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]		
		- 20200828@Winfred: Add WM Live casino [Redmine: #131589]
		- 20201124@Helen: Alpha - Master Agent List - Member level shows the Site and commission group in Group column [Redmine: #145963]
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
	  
	SET NOCOUNT ON  		

	DECLARE @SiteID INT , @Currency INT

	SELECT @Currency = ci.currency, @SiteID = s.siteid
	FROM customer ci WITH(NOLOCK) 
		INNER JOIN Site s WITH(NOLOCK) ON ci.site = s.site
	WHERE ci.custid = @Recommend
	
	DECLARE @RowCount int, @RowStart int, @RowEnd int  
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1   
	SET @Username = isnull(@Username, '')  
	  
	CREATE TABLE #memberList (custid int, rn int)

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL  AND @Locked IS NULL-- default condition: get all
	BEGIN
		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			From dbo.Custinfo ci WITH(nolock)   
			Where ci.Recommend = @recommend AND ci.roleid=1   		
		END
			
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM dbo.custInfo ci with(nolock)
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs
				WHERE Recommend = @Recommend  AND ci.RoleID = 1  				
			) x
		WHERE rn between @rowstart and @rowend		
	END
	ELSE IF @Username = ''
	BEGIN
		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
			FROM dbo.Custinfo ci WITH(nolock)   
				CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, bitmapHasSynced
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs	
			WHERE ci.Recommend = @recommend AND ci.roleid=1   
				AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
				AND isnull(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
		END
		
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM dbo.custInfo ci with(nolock)
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs	
				WHERE Recommend = @Recommend  
					AND ci.RoleID = 1 	
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			) x
		WHERE rn BETWEEN @rowstart AND @rowend
	END
	ELSE
	BEGIN	
		IF @TotalPages = 0  
		BEGIN
			SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
			FROM dbo.Custinfo ci WITH(NOLOCK)   
				INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs	
			WHERE ci.Recommend = @recommend   
				AND ci.roleid=1   
				AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
				AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
				AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)	
		END
	   
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, cs.reject, ci.username) AS rn
				FROM dbo.custInfo ci with(nolock)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cs	
				WHERE ci.Recommend = @Recommend  AND ci.RoleID = 1 	
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
			) x
		WHERE rn BETWEEN @rowstart AND @rowend
	END
	
	;WITH src AS (
		SELECT c.custid as custid
			,rn
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 1 THEN cdm.AgentDiscount ELSE 0 END)	   AS discount
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 4 THEN cdm.AgentDiscount ELSE 0 END)	   AS discountcs
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 5 THEN cdm.AgentDiscount ELSE 0 END)	   AS discount1x2
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 1 THEN cdm.PlayerDiscount ELSE 0 END)   AS playerdiscount
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 4 THEN cdm.PlayerDiscount ELSE 0 END)   AS playerdiscountcs
			,MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 5 THEN cdm.PlayerDiscount ELSE 0 END)   AS playerdiscount1x2							
		FROM #memberList c
			LEFT JOIN CustDiscount3rd_Member cdm with(nolock) 
				on c.custid = cdm.custid and cdm.SportType IN (1)
		WHERE rn between @rowstart and @rowend
		GROUP BY c.custid, rn
	)	
	
	SELECT   
		ci.enabled, cps.closed, isnull(cps.reject,0) as suspended, ci.virtualmultiplier-1 as VirtualMultiplier,   
		c.username, c.custid, ci.roleid, c.ugroup as ugroup, IsNull(c.site,'') AS site,   
		c.firstname, c.lastname, c.username2,   
		c.iplogin as lastloginip,  
		c.currency,  
		m.discount,  
		m.discountcs,  
		m.discount1x2,  		
		m.playerdiscount,  
		m.playerdiscountcs,  
		m.playerdiscount1x2,     		 					
		
		rn as RowNumber,
		ISNULL(cl.ClosedReason,0) AS ClosedReason,
		ISNULL(cps.Locked,0) AS Locked			
		FROM src m  
			INNER JOIN customer c (nolock) on m.custid = c.custid  
			INNER JOIN Custinfo ci (nolock) on m.custid = ci.custid 
			CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked										
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cps	     	  
			LEFT JOIN CustLoginInfo_Member cl WITH(NOLOCK) ON c.custid=cl.CustID		   
		ORDER BY rn

	DROP TABLE #memberList
END
