/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Acc_CustomerSelByMAg]
	@MRecommend int,
	@IsAgentSite bit = 0,	
	@Username varchar(30)=null,
	@Enabled bit = null,
	@Closed bit=null,
	@Suspended bit = null,
	@DoubleCommLosing tinyint = 2,
	@PageSize int = 20000,
	@PageIndex int = 1,
	@TotalPages int = 1 output,
	@TotalItems int=0 output,
	@Userid		INT=NULL
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
	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		
*/   
BEGIN

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
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	SET @Username = isnull(@Username, '')
	
	
	DECLARE @IsIMBC BIT = 0
	
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @MRecommend AND [Site] = 'IMBC')
		SET @IsIMBC = 1
		
	CREATE TABLE #customer(custid INT, RowNumber INT,discountMyanmarOdds DECIMAL (9,8),IsMyanmarOdds BIT,discountCricket DECIMAL (9,8))

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL AND @DoubleCommLosing = 2
	BEGIN
		IF @TotalPages = 0
			SELECT 
				@TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			FROM Custinfo as ci with (NOLOCK)			
			WHERE ci.MRecommend = @MRecommend and ci.roleid=2 
				
		INSERT INTO #customer (custid, RowNumber)
		SELECT custid, RowNumber 
		FROM (
				SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, isnull(ci.reject,0), ci.username) as RowNumber 
				FROM custinfo ci WITH(NOLOCK) 
				WHERE	MRecommend = @MRecommend and roleid=2 
										AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
			) t
		WHERE rownumber between @rowstart and @rowend
			
	END
	ELSE IF @Username = ''
	BEGIN
		IF @TotalPages = 0
			SELECT 
				@TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			FROM 
				Custinfo as ci with (NOLOCK)			
			WHERE 	
				ci.MRecommend = @MRecommend and ci.roleid=2 
				AND enabled = case when coalesce(@Closed,@Suspended) is not null then 1 else coalesce(@enabled, enabled) end
				AND isnull(ci.closed,0) = case when @suspended = 1 then 0 else coalesce(@closed, isnull(ci.closed, 0)) end			
				AND isnull(ci.reject,0) = case when @Closed = 0 then 0 else coalesce(@suspended, isnull(ci.reject, 0))end			
				and ci.DoubleCommLosing = case when @DoubleCommLosing = 2 then ci.DoubleCommLosing else @DoubleCommLosing end
				
		INSERT INTO #customer(custid, RowNumber)
		SELECT custid, RowNumber
		FROM (
				SELECT custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, isnull(ci.reject,0), ci.username) as RowNumber
				FROM custinfo ci with (NOLOCK) 
				WHERE MRecommend = @MRecommend and roleid=2 
					AND enabled = case when coalesce(@Closed,@Suspended) is not null then 1 else coalesce(@enabled, enabled) end
					AND isnull(closed,0) = case when @suspended = 1 then 0 else coalesce(@closed, isnull(closed, 0)) end
					AND isnull(reject,0) = case when @Closed = 0 then 0 else coalesce(@suspended, isnull(reject, 0))end	
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
			) t
		WHERE rownumber between @rowstart and @rowend		
	END
	ELSE
	BEGIN
		IF @TotalPages = 0
			SELECT 
				@TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			FROM 
				Custinfo as ci with (NOLOCK)
			WHERE 	
				ci.MRecommend = @MRecommend and ci.roleid=2 
				AND ci.username like '%' + @Username + '%'  
				AND enabled = case when coalesce(@Closed,@Suspended) is not null then 1 else coalesce(@enabled, enabled) end
				AND isnull(ci.closed,0) = case when @suspended = 1 then 0 else coalesce(@closed, isnull(ci.closed, 0)) end
				AND isnull(ci.reject,0) = case when @Closed = 0 then 0 else coalesce(@suspended, isnull(ci.reject, 0))end			
				and ci.DoubleCommLosing = case when @DoubleCommLosing = 2 then ci.DoubleCommLosing else @DoubleCommLosing end
			
		INSERT INTO #customer(custid,RowNumber)
		SELECT custid, RowNumber	
		FROM (
				SELECT custid,ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, isnull(ci.reject,0), ci.username) as RowNumber
				FROM custinfo ci WITH(NOLOCK) 
				WHERE MRecommend = @MRecommend and roleid=2 
					AND username like '%' + @Username + '%'  
					AND enabled = case when coalesce(@Closed,@Suspended) is not null then 1 else coalesce(@enabled, enabled) end
					AND isnull(closed,0) = case when @suspended = 1 then 0 else coalesce(@closed, isnull(closed, 0)) end
					AND isnull(reject,0) = case when @Closed = 0 then 0 else coalesce(@suspended, isnull(reject, 0))end			
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END		
			) t 
		WHERE rownumber between @rowstart and @rowend
		
	END
	
	IF EXISTS (SELECT 1 FROM #customer c JOIN Customer cm WITH (NOLOCK) ON CM.custid = C.custid AND cm.site = '766666')
	BEGIN
		UPDATE T
			SET discountMyanmarOdds = ac.CommRate
			, t.IsMyanmarOdds = 1
		FROM #customer T
			INNER JOIN AgentCommRate ac WITH (NOLOCK) ON T.custid = AC.CustId 
		WHERE Sporttype = 1 AND Bettype = 301			
		
		
	END
	
	IF @IsIMBC = 1
	BEGIN
		UPDATE T
			SET discountCricket = cda.Discount
		FROM #customer T
				INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON T.custid = cda.CustId 
		WHERE cda.Sporttype = 50 AND cda.Bettype = 501
			
	END
	
    -- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT
		,	@bitmapOrder_CockFighting	INT
		,	@bitmapOrder_Cricket		INT
		,	@bitmapOrder_AllBet			INT
		,	@bitmapOrder_AllBetVIP		INT
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
								
	SET	@bitmapOrder_AllBetVIP =	(
									SELECT	psp.bitmapOrder
									FROM	dbo.ProductStatusProfile AS psp WITH(NOLOCK)
									WHERE	psp.Sporttype = 211
										AND	psp.Bettype = 2402
								)
    
    DECLARE	@IsHidden_MuayThai			INT = 1
		,	@IsHidden_CockFighting		INT = 1
		,	@IsHidden_Cricket			INT = 1
		,	@IsHidden_AllBet			INT = 1
		,	@IsHidden_VoidBridge		INT = 1
		,	@IsHidden_NG2				INT = 1
		,	@IsHidden_FishingWorld		INT = 1

    EXEC Acc_CheckShowProduct @ProductID = 16, @IsHide = @IsHidden_MuayThai OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 19, @IsHide = @IsHidden_CockFighting OUTPUT	
	EXEC Acc_CheckShowProduct @ProductID = 21, @IsHide = @IsHidden_AllBet OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 22, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 23, @IsHide = @IsHidden_NG2 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 24, @IsHide = @IsHidden_FishingWorld OUTPUT

	IF @IsIMBC=0
		SELECT @IsHidden_Cricket=1
	ELSE	
		EXEC Acc_CheckShowProduct @ProductID = 20, @IsHide = @IsHidden_Cricket OUTPUT	

	-- get data for filtered customers	
	DECLARE @SearchQuery varchar(1024)
	DECLARE @tmp TABLE (siteid INT,site NVARCHAR(50), SpecialGroup TINYINT )
	DECLARE @tmpUserid VARCHAR(50)
	SELECT @tmpUserid=CAST(@Userid AS VARCHAR(50))
	SELECT @SearchQuery = 'SELECT * 
	FROM OPENQUERY(DBPOLICY, 
	''SELECT siteid , site,SpecialGroup FROM bodb02.dbo.f_GetDeniedSiteByUser( ''''' + @tmpUserid + ''''')'')'

	INSERT INTO  @tmp (siteid , site,SpecialGroup)
	EXECUTE(@SearchQuery)
	
	;WITH customers AS
	(
		SELECT	c.custid, ci.currency, ci.roleid, autosuspend, reject, closed, MatchLimit, VirtualMultiplier, Enabled, DisableHorseRacing,
				DisableFinancial, DisableCasino, SyncCasino, DisableOutright, DisableOpenTote, DisableBingo, DisableNumber, SyncBingo,
				disable151_au, disable152_uk, disable152_au, disable153_au , isAutoResetP2P, DisableP2P, DisableFunP2P, 
				DisableLiveCasino,SyncLiveCasino, DisableVirtualSports, DoubleCommLosing,HideKeno, HideGoldDeluxe, DisableGoldDeluxe,HideColossusBet,DisableColossusBet,cm.IsInternal,
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
										WHERE	ciDownline.recommend = c.custid
											AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_AllBet) = 0)
							THEN 0
						ELSE 1
				END AS SyncedAllBetDownline,
				
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
										WHERE	ciDownline.recommend = c.custid
											AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_FishingWorld) = 0)
							THEN 0
						ELSE 1
				END AS SyncedFishingWorldDownline,

				-- Cricket
				ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Cricket),1) AS DisableCricket,
				CAST(CASE WHEN @IsHidden_Cricket = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Cricket),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCricket,
				
				-- VoidBridge
				ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge),1) AS DisableVoidBridge,
				CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VoidBridge),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
				CAST(CASE	WHEN	@IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VoidBridge), 1)=0
				THEN 0 ELSE 1
				END AS BIT) AS HideVoidBridgeUpline,
				ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridge,
				ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridgeUpline,

				CASE	WHEN EXISTS	(	SELECT	TOP 1 1
										FROM		dbo.CustProductStatus AS cpsDownline WITH (NOLOCK)
										INNER JOIN	dbo.custInfo AS ciDownline WITH (NOLOCK)
												ON	ciDownline.custid = cpsDownline.CustID
										WHERE	ciDownline.recommend = c.custid
											AND	dbo.f_GetProductStatus(cpsDownline.bitmapHasSynced, @bitmapOrder_VoidBridge) = 0)
							THEN 0
						ELSE 1
				END AS SyncedVoidBridgeDownline,

				-- For NG2
				ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_NG2),1) AS DisableNG2,
				CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2,
				CAST(CASE WHEN @IsHidden_NG2 = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_NG2),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideNG2Upline,			
				ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2,
				ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_NG2), 0) AS SyncedNG2Upline,	

				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate
		FROM Customer c WITH(NOLOCK)
			INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN CustAgent cm with(NOLOCK) on c.custid = cm.custid 
			LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 

			-- Check isHidden AllBet
			--OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(c.custid, @AllBet) AS sbhsc
		
			-- Upline Status
			INNER JOIN	dbo.CustProductStatus AS cpsUpline WITH (NOLOCK)
					ON	cpsUpline.CustID =	CASE	WHEN c.roleid = 1 THEN c.recommend
													WHEN c.roleid = 2 THEN c.mrecommend
													ELSE c.srecommend
											END
		   
		WHERE c.custid IN (SELECT custid FROM #customer) AND (@Userid IS NULL OR (@Userid IS NOT NULL AND c.site NOT IN (SELECT site FROM @tmp )))
	),
	custsetting3rd AS
	(
		SELECT cs3.custid , cs3.discount discountnumber 
		FROM dbo.CustSetting3rd cs3 WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM #customer)
			AND sporttype = 161 AND bettype = 81 
	),
	custsetting AS
	(
		SELECT cs.custid,
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupa ELSE 0 END) groupa, --- need to indicate 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupb ELSE 0 END) groupb, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupc ELSE 0 END) groupc, 
			MAX(CASE WHEN cs.bettype = 1 AND cs.sporttype = 1 THEN cs.groupd ELSE 0 END) groupd, 
			MAX(case when cs.bettype = 4 and cs.sporttype=1 then cs.discount else 0 end) as discountcs,	
			MAX(case when cs.bettype = 5 and cs.sporttype=1 then cs.discount else 0 end) as discount1x2,				
			MAX(case when cs.bettype = 20 and cs.sporttype = 154 then cs.discount else 0 end) as discountHRFixedOdds
		FROM dbo.CustSetting cs WITH(NOLOCK) 
		WHERE custid IN (SELECT custid FROM #customer)
			AND sporttype IN (1,154) AND bettype IN (1,4,5,20)
		GROUP BY cs.custid 
	),
	keno AS
	(
		SELECT	cg.CustID
				,min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516) then cg.IsDisabled else 1 end) as DisableKeno
		FROM dbo.CustGameType cg WITH(NOLOCK) 
			INNER JOIN @tmp_GameType g ON cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516)		
		WHERE CustID IN (SELECT CustID FROM #customer)
		GROUP BY cg.CustID 
	)
	SELECT  ctm.enabled,
			ctm.closed, 
			isnull(ctm.reject,0) as suspended,	
			isnull(ctm.DisableOutright,0) as DisableOutright,			
			isnull( case when ctm.disablehorseracing = 0 
							or ctm.disableOpenTote = 0 
							or ctm.disable151_au = 0 
							or ctm.disable152_uk = 0
							or ctm.disable152_au = 0 
							or ctm.disable153_au = 0 then 0 else 1 end ,0) as Disable151,
			isnull(ctm.disablehorseracing,0) as disable151_31,
			isnull(ctm.disableOpenTote,0) as disable151_41,
			isnull(ctm.disable151_au,0) as disable151_51,
			isnull(ctm.disable152_uk,0) as disable152_41,
			isnull(ctm.disable152_au,0) as disable152_51,
			isnull(ctm.disable153_au,0) as disable153_51,
			isnull(ctm.disablefinancial,0) as DisableFI,
			ctm.username, 
			ctm.custid, 
			ctm.roleid,
			isnull(ctm.ugroup, '') as ugroup , 
			isnull(ctm.firstname, '') as firstname , 
			isnull(ctm.lastname, '') as lastname, 
			ctm.username2,
			isnull(ctm.phone, '') as phone,
			isnull(ctm.mobilephone, '') as mobilephone,
			isnull(ctm.iplogin, '') as lastloginip,
			cs.groupa as groupa, 
			cs.groupb as groupb, 
			cs.groupc as groupc, 
			cs.groupd as groupd, 
			discountcs discountcs,	
			discount1x2 discount1x2,	
			discountnumber discountnumber,
			discountHRFixedOdds discountHRFixedOdds,
			ctm.currency,	
			ctm.matchlimit,
			ctm.virtualmultiplier-1 as VirtualMultiplier,
			ctm.creatdate as createdate,
		
			-- For casino
			ctm.synccasino,
			ctm.disablecasino,
			
			ctm.isinternal,
			ctm.syncBingo,
			ctm.DisableNumber,
			ctm.DisableBingo,
			
			--For P2P
			ctm.isAutoResetP2P,
			ctm.DisableP2P,
			ctm.DisableFunP2P,
			
			-- For live casino
			ctm.DisableLiveCasino,
			ctm.SyncLiveCasino,
			
			-- For VirtualSports
			ctm.DisableVirtualSports,
			ctm.DoubleCommLosing,
  
			ctm.HideKeno,
			ISNULL(DisableKeno,0) DisableKeno,
			ISNULL(ctm.HideGoldDeluxe,1) AS HideGoldDeluxe,
			ISNULL(ctm.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
			ISNULL(ctm.HideColossusBet,1) AS HideColossusBet,
			ISNULL(ctm.DisableColossusBet,1) AS DisableColossusBet,
			
			ctm.DisableMuayThai,
			ctm.HideMuayThai,
			ctm.DisableCockFighting,
			ctm.HideCockFighting,
			ctm.DisableAllBet,
			ctm.DisableAllBetVIP,
			ctm.HideAllBet,
			ctm.HideAllBetUpline,
			ctm.SyncedAllBet,
			ctm.SyncedAllBetUpline,
			ctm.SyncedAllBetDownline,

			ISNULL(t.IsMyanmarOdds,0) AS IsMyanmarOdds,
			ISNULL(t.discountMyanmarOdds,0) AS discountMyanmarOdds,
			-- VoidBrigde
			ctm.DisableVoidBridge,
			ctm.HideVoidBridge,
			ctm.HideVoidBridgeUpline,
			ctm.SyncedVoidBridge,
			ctm.SyncedVoidBridgeUpline,
			ctm.SyncedVoidBridgeDownline,
			-- FishingWorld
			ctm.DisableFishingWorld,
			ctm.HideFishingWorld,
			ctm.HideFishingWorldUpline,
			ctm.SyncedFishingWorld,
			ctm.SyncedFishingWorldUpline,
			ctm.SyncedFishingWorldDownline,
			
			ctm.DisableNG2,
			ctm.HideNG2,
			ctm.HideNG2Upline,
			ctm.SyncedNG2,
			ctm.SyncedNG2Upline,

			--Cricket
			@IsIMBC AS IsIMBC,
			ctm.DisableCricket,
			ctm.HideCricket,
			ISNULL(t.discountCricket,0) AS discountCricket,
			RowNumber
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN custsetting cs WITH (NOLOCK) ON ctm.custid = cs.custid
		LEFT JOIN custsetting3rd cs3 WITH (NOLOCK) ON ctm.custid = cs3.custid 
		LEFT JOIN keno k ON ctm.custid = k.CustID	
		
	ORDER BY  t.RowNumber	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelByMAg] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelByMAg] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelByMAg] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelByMAg] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelByMAg] TO [vnteam] AS [dbo]