/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO 

ALTER PROCEDURE [dbo].[Acc_CustomerSelByAg]  
	@Recommend int,  
	@IsAgentSite bit = 0,  
	@Username varchar(30)=null,  
	@Enabled bit = null,  
	@Closed bit=null,  
	@Suspended bit=null,
	@DoubleCommLosing tinyint = 2,
	@ProductUnSync TINYINT=0,--0: not filter
	@PageSize int = 20000,  
	@PageIndex int = 1,  
	@TotalPages int = 1 output,
	@TotalItems int=0 output  
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
	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		- @ProductUnSync:
			0: not filter by product
			6: casino,12: GD, 21: Allbet, 22: Macau Games
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

	DECLARE @IsMyanmarOdds BIT = 0
	SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@recommend)
	
	DECLARE @IsIMBC BIT = 0
	
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @Recommend AND [Site] = 'IMBC')
		SET @IsIMBC = 1
	   
	-- For DCS Product
    DECLARE	@bitmapOrder_MuayThai		INT 
		
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
    
    SET @bitmapOrder_MuayThai = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 44 AND Bettype = 3)
    
    SET @bitmapOrder_Cricket = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 50 AND Bettype = 501)
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitmapOrder_Lottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitmapOrder_NG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitmapOrder_Lucky3 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 160 AND Bettype = 1600)
	SET @bitmapOrder_FishingWorld = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitmapOrder_VS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	SET @bitmapOrder_BullFighting = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 207 AND Bettype = 1004)

    
	SELECT	@bitmapOrder_AllBet =	(
										SELECT	psp.bitmapOrder
										FROM	dbo.ProductStatusProfile AS psp WITH(NOLOCK)
										WHERE	psp.Sporttype = 211
											AND	psp.Bettype = 2401
									)
    SELECT	@bitmapOrder_AllBetVIP =	(
										SELECT	psp.bitmapOrder
										FROM	dbo.ProductStatusProfile AS psp WITH(NOLOCK)
										WHERE	psp.Sporttype = 211
											AND	psp.Bettype = 2402
									)
    
    DECLARE	@IsHidden_MuayThai		INT = 1
	
		,	@IsHidden_Cricket		INT = 1
		,	@IsHidden_AllBet		INT = 1
		,	@IsHidden_VoidBridge	INT = 1
		,	@IsHidden_Lottery		INT = 1
		,	@IsHidden_NG2			INT = 1
		,	@IsHidden_Lucky3		INT = 1    
		,	@IsHidden_FishingWorld	INT = 1 
		,	@IsHidden_VS			INT = 1
		,	@IsHidden_BullFighting	INT = 1

	EXEC Acc_CheckShowProduct @ProductID = 16, @IsHide = @IsHidden_MuayThai OUTPUT

	EXEC Acc_CheckShowProduct @ProductID = 21, @IsHide = @IsHidden_AllBet OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 22, @IsHide = @IsHidden_VoidBridge OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 28, @IsHide = @IsHidden_Lottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 23, @IsHide = @IsHidden_NG2 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 26, @IsHide = @IsHidden_Lucky3 OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 24, @IsHide = @IsHidden_FishingWorld OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 30, @IsHide = @IsHidden_BullFighting OUTPUT

	IF @IsIMBC=0
		SELECT @IsHidden_Cricket=1
	ELSE	
		EXEC Acc_CheckShowProduct @ProductID = 20, @IsHide = @IsHidden_Cricket OUTPUT	

	EXEC Acc_CheckShowProduct @ProductID = 5, @IsHide = @IsHidden_VS OUTPUT

	DECLARE @RowCount int, @RowStart int, @RowEnd int  
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1   
	SET @Username = isnull(@Username, '')  
	  
	CREATE TABLE #memberList (custid int, rn int,playerdiscountMyanmarOdds DECIMAL (9,8), playerdiscountCricket DECIMAL (9,8),discountCricket DECIMAL (9,8))

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL  AND @DoubleCommLosing =2 -- default condition: get all
	BEGIN
		IF @ProductUnSync =0
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
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ci.reject, ci.username) as rn
					FROM dbo.custInfo ci with(nolock)
					WHERE Recommend = @Recommend  AND ci.RoleID = 1  				
				) x
			WHERE rn between @rowstart and @rowend		
		END
		ELSE IF @ProductUnSync IN (6,12)--get unsync casino/GD product
		BEGIN
			IF @TotalPages = 0
			BEGIN
				SELECT @TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
				From dbo.Custinfo ci WITH(nolock)   
				Where ci.Recommend = @recommend 
					AND ci.roleid=1 
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)					
			END
			
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ci.reject, ci.username) as rn
					FROM dbo.custInfo ci with(nolock)
					WHERE Recommend = @Recommend  
						AND ci.RoleID = 1  
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)	
				) x
			WHERE rn between @rowstart and @rowend
		END
		ELSE IF @ProductUnSync IN (21,22)
		BEGIN
			IF @TotalPages = 0
			BEGIN
				SELECT @TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
				From dbo.Custinfo ci WITH(nolock)   
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				Where ci.Recommend = @recommend 
					AND ci.roleid=1  
					AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)	
			END
			
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ci.reject, ci.username) as rn
					FROM dbo.custInfo ci with(nolock)
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
					WHERE Recommend = @Recommend  
						AND ci.RoleID = 1
						AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)		
				) x
			WHERE rn between @rowstart and @rowend	
		END
	END
	ELSE IF @Username = ''
	BEGIN
		IF @TotalPages = 0
		BEGIN
			IF @ProductUnSync = 0
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
				WHERE ci.Recommend = @recommend AND ci.roleid=1   
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND isnull(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
			END
			ELSE IF @ProductUnSync IN (6,12)--unsync for GD/Casino
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
				WHERE ci.Recommend = @recommend AND ci.roleid=1   
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND isnull(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
			END
			ELSE IF @ProductUnSync IN (21,22)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.Recommend = @recommend AND ci.roleid=1   
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND isnull(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
			END
		END
		
		IF @ProductUnSync = 0 --not filter by un-sync products
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled desc, ci.closed, ci.reject, ci.username) as rn
					FROM dbo.custInfo ci with(nolock)
					WHERE Recommend = @Recommend  
						AND ci.RoleID = 1 	
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END
		ELSE IF @ProductUnSync IN (6,12)--unsync casino/GD
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) as rn
					FROM dbo.custInfo ci WITH(NOLOCK)
					WHERE Recommend = @Recommend  
						AND ci.RoleID = 1 	
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
				) x
			WHERE rn BETWEEN @rowstart AND @rowend			
		END
		ELSE IF @ProductUnSync IN (21,22)
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci WITH(NOLOCK)
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
					WHERE Recommend = @Recommend  
						AND ci.RoleID = 1 	
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END
	END
	ELSE
	BEGIN	
		IF @TotalPages = 0  
		BEGIN
			IF @ProductUnSync = 0 
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND ci.username LIKE '%' + @Username + '%'    
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
			END	
			ELSE IF @ProductUnSync IN (6,12)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND ci.username LIKE '%' + @Username + '%'    
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
			END	
			ELSE IF @ProductUnSync IN (21,22)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND ci.username LIKE '%' + @Username + '%'    
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
					AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
			END	
		END
	   
		IF @ProductUnSync = 0
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
					WHERE Recommend = @Recommend  AND ci.RoleID = 1 	
						AND ci.username LIKE '%' + @Username + '%'    
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END
		ELSE IF @ProductUnSync IN (6,12)
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
					WHERE Recommend = @Recommend  AND ci.RoleID = 1 	
						AND ci.username LIKE '%' + @Username + '%'    
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END	
		ELSE IF @ProductUnSync IN (21,22)	
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
					WHERE Recommend = @Recommend  AND ci.RoleID = 1 	
						AND ci.username LIKE '%' + @Username + '%'    
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 21 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END
	END

	-- For Myanmar Odds
	IF @IsMyanmarOdds = 1
	BEGIN
		UPDATE T
			SET playerdiscountMyanmarOdds = ac.playerdiscount
		FROM #memberList T
			INNER JOIN CustCommRate ac WITH (NOLOCK) ON T.custid = AC.CustId 
		WHERE ac.Sporttype = 1 AND ac.Bettype = 301	
	
	END
	IF @IsIMBC = 1
	BEGIN
		UPDATE T
			SET playerdiscountCricket = ac.playerdiscount, discountCricket = ac.AgentDiscount
		FROM #memberList T
			INNER JOIN CustDiscount3rd_Member ac WITH (NOLOCK) ON T.custid = AC.CustId 
		WHERE ac.Sporttype = 50 AND ac.Bettype = 501	
		
		
	END
	;WITH src AS (
		SELECT c.custid as custid
			,rn
			,max(case when cs.sporttype = 1 and cs.bettype = 1 then cs.discount else 0 end) as discount
			,max(case when cs.sporttype = 1 and cs.bettype = 4 then cs.discount else 0 end) as discountcs
			,max(case when cs.sporttype = 1 and cs.bettype = 5 then cs.discount else 0 end) as discount1x2
			,max(case when cs3.sporttype = 161 and cs3.bettype = 81 then cs3.discount else 0 end) as discountnumber			

			,max(case when cs.sporttype = 1 and cs.bettype = 1 then cs.playerdiscount else 0 end) as playerdiscount
			,max(case when cs.sporttype = 1 and cs.bettype = 4 then cs.playerdiscount else 0 end) as playerdiscountcs
			,max(case when cs.sporttype = 1 and cs.bettype = 5 then cs.playerdiscount else 0 end) as playerdiscount1x2
			,max(case when cs3.sporttype = 161 and cs3.bettype = 81 then cs3.playerdiscount else 0 end) as playerdiscountnumber			

			,min(case when g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524) then cg.IsDisabled else 1 end) as DisableKeno
			,ISNULL(C.playerdiscountMyanmarOdds,0) AS playerdiscountMyanmarOdds
			,ISNULL(C.playerdiscountCricket,0) AS playerdiscountCricket
			,ISNULL(C.discountCricket,0) AS discountCricket
		FROM #memberList c
			LEFT JOIN CustSetting cs with(nolock) 
				on c.custid = cs.custid and ((cs.sporttype = 1 and cs.bettype in (1,4,5)) )
			LEFT JOIN CustSetting3rd cs3 with(nolock) on c.custid = cs3.custid and cs3.sporttype = 161 and cs3.bettype = 81
			LEFT JOIN CustGameType cg with(nolock) on c.custid = cg.custid
			LEFT JOIN @tmp_GameType g on cg.GameTypeID = g.GameTypeID and g.IBCBetTypeID in (1501,1503,1504,1505,1508,1511,1513,1514,1515,1516,1517,1519,1520,1521,1522,1524)
		WHERE rn between @rowstart and @rowend
		GROUP BY c.custid, rn,c.playerdiscountMyanmarOdds,C.playerdiscountCricket,C.discountCricket
	)
	
	
	SELECT   
		ci.enabled, ci.closed, isnull(ci.reject,0) as suspended, isnull(ci.DisableOutright,0) as DisableOutright, ci.virtualmultiplier-1 as VirtualMultiplier,   
		c.username, c.custid, ci.roleid, ISNULL(c.site,'') + c.ugroup as ugroup, IsNull(c.site,'') AS site,   
		c.firstname, c.lastname, c.username2,   
		c.iplogin as lastloginip,  
		c.creatdate as createdate, c.currency,  
		discount,  
		discountcs,  
		discount1x2,  
		discountnumber,  		
		playerdiscount,  
		playerdiscountcs,  
		playerdiscount1x2,   
		playerdiscountnumber,  		
		-- For casino  
		ci.synccasino,  
		ci.disablecasino,  
		ci.DisableNumber,  
		-- For VirtualSports
		--ci.DisableVirtualSports,	
		ci.DoubleCommLosing,
		
	
		ci.HideKeno,
		ISNULL(m.DisableKeno,0) AS DisableKeno,	
		ISNULL(ci.DisableGoldDeluxe,1) AS DisableGoldDeluxe,
		ISNULL(ci.HideGoldDeluxe,1) AS HideGoldDeluxe,
		ISNULL(ci.DisableColossusBet,1) AS DisableColossusBet,
		ISNULL(ci.HideColossusBet,1) AS HideColossusBet,
		
		ISNULL(@IsMyanmarOdds,0) AS IsMyanmarOdds,
		ISNULL(m.playerdiscountMyanmarOdds,0) playerdiscountMyanmarOdds,
		-- For MuayThai
		ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_MuayThai),1) AS DisableMuayThai,
		CAST(CASE WHEN @IsHidden_MuayThai = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_MuayThai),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideMuayThai,

		-- For VoidBridge
		ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_VoidBridge),1) AS DisableVoidBridge,
		CAST(CASE WHEN @IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VoidBridge),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideVoidBridge,
		CAST(CASE	WHEN	@IsHidden_VoidBridge = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_VoidBridge), 1)=0
				THEN 0 ELSE 1
				END AS BIT) AS HideVoidBridgeUpline,
		ISNULL(dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridge,
		ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapHasSynced, @bitmapOrder_VoidBridge), 0) AS SyncedVoidBridgeUpline,
		1 AS SyncedVoidBridgeDownline,

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
		1 AS SyncedAllBetDownline,

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

		-- For Cricket
		@IsIMBC AS IsIMBC,
		ISNULL(m.playerdiscountCricket,0) AS playerdiscountCricket,
		ISNULL(m.discountCricket,0) AS discountCricket,
		
		ISNULL(dbo.f_GetProductStatus(cps.bitmapIsDisabled, @bitmapOrder_Cricket),1) AS DisableCricket,
		CAST(CASE WHEN @IsHidden_Cricket = 0 AND ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_Cricket),1) = 0 THEN 0 ELSE 1 END AS BIT) AS HideCricket,
		
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
		1 AS SyncedFishingWorldDownline,
		rn as RowNumber,
		ISNULL(cl.ClosedReason,0) AS ClosedReason,
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

		-- For BullFighting
		(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsDisabled, @bitmapOrder_BullFighting)) AS DisableBullFighting,		
		CAST(	CASE	WHEN	@IsHidden_BullFighting = 0 						
							AND	ISNULL(dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_BullFighting), 1) = 0 
							THEN 0
						ELSE 1 
				END AS BIT) AS HideBullFighting,
		CAST(CASE	WHEN	@IsHidden_BullFighting = 0 AND ISNULL(dbo.f_GetProductStatus(cpsUpline.bitmapIsHidden, @bitmapOrder_BullFighting), 1)=0
				THEN 0 ELSE 1
				END AS BIT) AS HideBullFightingUpline
	FROM src m  
		INNER JOIN customer c (nolock) on m.custid = c.custid  
		INNER JOIN Custinfo ci (nolock) on m.custid = ci.custid      	  
		LEFT JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
		LEFT JOIN CustLoginInfo_Member cl WITH(NOLOCK) ON c.custid=cl.CustID
		-- Check isHidden AllBet
		--OUTER APPLY	dbo.f_CustSetting_SportBetTypeHiddenBySiteCurrency(c.custid, @AllBet) AS sbhsc
		
		-- Upline Status
		INNER JOIN	dbo.CustProductStatus AS cpsUpline WITH (NOLOCK)
				ON	cpsUpline.CustID =	CASE	WHEN c.roleid = 1 THEN c.recommend
												WHEN c.roleid = 2 THEN c.mrecommend
												ELSE c.srecommend
										END
		   
	ORDER BY rn

	DROP TABLE #memberList
END
GO
