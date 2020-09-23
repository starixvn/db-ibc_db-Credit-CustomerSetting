/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelByAg]  
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
	@TotalItems int=0 OUTPUT,
	@Userid		INT=NULL 
AS 
BEGIN 
/*  
	Created by: [Winfred]  
	Date:[20200724]  
	Task: Member List smartphone 
	DB: DBCUST/CustDB
	Original: agentsite/account\customerlist.asp  

	Revisions: 		
		- 20200724@winfred: Remove Status games for customer list smartphone [redmine: #137130]
		
	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		- @ProductUnSync:
			0: not filter by product
			6: casino,12: GD, 41: Allbet + SA Gaming, 22: Macau Games
*/  
	  
	SET NOCOUNT ON  
	
	----- /Elodie @ 01 JUN 2015 -------------------
	DECLARE @RowCount int, @RowStart int, @RowEnd int  
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1   
	SET @Username = isnull(@Username, '')  
	 
	-- For DCS Product
    DECLARE	@bitmapOrder_AllBet			INT
		,	@bitmapOrder_VoidBridge		INT 
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
		  
	CREATE TABLE #memberList (custid int, rn int)

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
		ELSE IF @ProductUnSync IN (41,22)
		BEGIN
			IF @TotalPages = 0
			BEGIN
				SELECT @TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
				From dbo.Custinfo ci WITH(nolock)   
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				Where ci.Recommend = @recommend 
					AND ci.roleid=1  
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
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
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
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
			ELSE IF @ProductUnSync IN (41,22)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.Recommend = @recommend AND ci.roleid=1   
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND isnull(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
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
		ELSE IF @ProductUnSync IN (41,22)
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
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
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
				FROM dbo.Custinfo ci WITH(NOLOCK)   
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
			END	
			ELSE IF @ProductUnSync IN (6,12)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
					AND 1 = (CASE WHEN (@ProductUnSync =6 AND SyncCasino = 0) 
										OR (@ProductUnSync = 12 AND HideGoldDeluxe = 1) THEN 1 ELSE 0 END
							)
			END
			ELSE IF @ProductUnSync IN (41,22)
			BEGIN
				SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
				FROM dbo.Custinfo ci WITH(nolock)   
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
				WHERE ci.Recommend = @recommend   
					AND ci.roleid=1   
					AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
					AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
					AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END					 
					AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
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
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
						INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					WHERE ci.Recommend = @Recommend  AND ci.RoleID = 1 	
						AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
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
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
						INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					WHERE ci.Recommend = @Recommend  AND ci.RoleID = 1 	
						AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
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
		ELSE IF @ProductUnSync IN (41,22)	
		BEGIN
			INSERT INTO #memberList (custid, rn)
			SELECT custid, rn
			FROM (
					SELECT ci.custid,
						ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, ci.closed, ci.reject, ci.username) AS rn
					FROM dbo.custInfo ci with(nolock)
						INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
						INNER JOIN dbo.CustProductStatus cs WITH (NOLOCK) ON ci.custid = cs.custid					
					WHERE ci.Recommend = @Recommend  AND ci.RoleID = 1 	
						AND (ci.username LIKE '%' + @Username + '%' OR (@Userid = @recommend AND c.username2 LIKE '%' + @Username + '%'))
						AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
						AND ISNULL(ci.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(ci.closed, 0)) END  
						AND ISNULL(ci.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(ci.reject, 0))END     
						AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
						AND 1 =(CASE WHEN (@ProductUnSync = 41 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_AllBet) = 0)
									OR (@ProductUnSync = 22 AND dbo.f_GetProductStatus(cs.bitmapHasSynced,@bitmapOrder_VoidBridge) = 0)
								THEN 1 ELSE 0 END	
							)
				) x
			WHERE rn BETWEEN @rowstart AND @rowend
		END
	END

	;WITH src AS (
		SELECT c.custid as custid
			,rn
			,max(case when cs.sporttype = 1 and cs.bettype = 1 then cs.discount else 0 end) as discount
			,max(case when cs.sporttype = 1 and cs.bettype = 4 then cs.discount else 0 end) as discountcs
			,max(case when cs.sporttype = 1 and cs.bettype = 5 then cs.discount else 0 end) as discount1x2	

			,max(case when cs.sporttype = 1 and cs.bettype = 1 then cs.playerdiscount else 0 end) as playerdiscount
			,max(case when cs.sporttype = 1 and cs.bettype = 4 then cs.playerdiscount else 0 end) as playerdiscountcs
			,max(case when cs.sporttype = 1 and cs.bettype = 5 then cs.playerdiscount else 0 end) as playerdiscount1x2		
		FROM #memberList c
			LEFT JOIN CustSetting cs with(nolock) 
				on c.custid = cs.custid and ((cs.sporttype = 1 and cs.bettype in (1,4,5)) )
			LEFT JOIN CustSetting3rd cs3 with(nolock) on c.custid = cs3.custid and cs3.sporttype = 161 and cs3.bettype = 81
			LEFT JOIN CustGameType cg with(nolock) on c.custid = cg.custid
		WHERE rn between @rowstart and @rowend
		GROUP BY c.custid, rn
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
		playerdiscount,  
		playerdiscountcs,  
		playerdiscount1x2, 
		ci.DoubleCommLosing,
		rn as RowNumber,
		ISNULL(cl.ClosedReason,0) AS ClosedReason
		FROM src m  
			INNER JOIN customer c (nolock) on m.custid = c.custid  
			INNER JOIN Custinfo ci (nolock) on m.custid = ci.custid      	  
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
