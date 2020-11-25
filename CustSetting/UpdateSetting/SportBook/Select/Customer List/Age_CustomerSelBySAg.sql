/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelBySAg]
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
	@TotalItems int=0 output
AS
/*
	Created by: [Winfred]  
	Date:[20200724]  
	Task: Master List smartphone  
	DB: DBCust/CustDB
	Original: magentsite/account\customerlist.asp
	
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
BEGIN 
	SET NOCOUNT ON
	----- /Elodie @ 01 JUN 2015 -------------------

	DECLARE @RowCount int, @RowStart int, @RowEnd int
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 
	SET @Username = ISNULL(@Username, '')
	-- For DCS Product
    DECLARE	@bitmapOrder_AllBet			INT
		,	@bitmapOrder_VoidBridge		INT 
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
		  
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
				DisableOutright,DoubleCommLosing,cm.IsInternal, cm.DisableAutoMPT,
				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate
		FROM dbo.Customer c WITH(NOLOCK)
			INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN dbo.CustMaster cm with(NOLOCK) on c.custid = cm.custid 
		   
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
			-- MyanmarOdds
			ISNULL(t.IsMyanmarOdds,0) AS IsMyanmarOdds,
			ISNULL(t.adiscountMyanmarOdds,0) AS discountMyanmarOdds,	
					
			ctm.currency,	
			ctm.matchlimit,
			ctm.virtualmultiplier-1 as VirtualMultiplier,
			ctm.creatdate as createdate,
			ctm.isinternal,
			ctm.DoubleCommLosing,
			
			ISNULL(cl.ClosedReason,0)  AS ClosedReason,
			RowNumber
			
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN custsetting cs WITH (NOLOCK) ON ctm.custid = cs.custid
		LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON t.custid=cl.Custid
	ORDER BY  t.RowNumber	
	
END
GO
