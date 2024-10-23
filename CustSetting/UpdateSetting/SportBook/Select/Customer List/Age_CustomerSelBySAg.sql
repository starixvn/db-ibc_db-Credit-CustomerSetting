/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelBySAg]
	@SRecommend int,
	@IsAgentSite bit = 0,
	@Username varchar(30)=null,
	@Enabled bit = null,
	@Closed bit=null,
	@Suspended bit=null,
	@DoubleCommLosing tinyint = 2,
	@PageSize int = 20000,
	@PageIndex int = 1,
	@TotalPages int = 1 output,
	@TotalItems int=0 output,
	@Locked BIT = NULL, -- 1: Locked filter
	@AutoTransfer TINYINT = 2
AS
/*
	Created by: [Winfred]  
	Date:[20200724]  
	Task: Master List smartphone  
	DB: DBCust/CustDB
	Original: magentsite/account\customerlist.asp
	
	Revisions:
		- 20200724@winfred: Remove Status games for customer list smartphone [redmine: #137130]
		- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
		- 20220921@Winfred:  Macau Game Setting Page - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
		- 20230602@Helios: Enhance stored procedure to prevent performance issue [Redmine: #189154]
		- 20230410@Bobby: AutoJob clear balance downlines [RedmineID: #182071]
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 
		- 20240917@Elodie: Tuning sp [redmine: #210892]
		- 20241022@Johnson: remove MyanmarOdds [redmine: #201396]
	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		- @AutoTransfer:
			0: Not Allowed Auto Transfer
			1: Allowed Auto Transfer
			2: All
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
	SET @bitmapOrder_VoidBridge = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SELECT	@bitmapOrder_AllBet =	(SELECT	psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
		  
	CREATE TABLE #customer(custid INT primary key, RowNumber INT)
							
	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL AND @DoubleCommLosing = 2 AND @Locked IS NULL
		AND @AutoTransfer = 2
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
				FROM custInfo ci WITH(NOLOCK)
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs 
				WHERE ci.srecommend= @SRecommend 
					AND ci.roleid=3 
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END			
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
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @SRecommend AND cbs.ToCustID = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
				AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
		
		END
		
		INSERT INTO #customer (custid, RowNumber)
		SELECT t.custid, RowNumber
		FROM (
				SELECT ci.custid, ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber 
				FROM dbo.custinfo ci WITH(NOLOCK) 
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @SRecommend AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
					AND DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN DoubleCommLosing ELSE @DoubleCommLosing END
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
					AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
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
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @SRecommend AND cbs.ToCustID = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
				AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
		END
		
		INSERT INTO #customer (custid, RowNumber)
		SELECT t.custid, RowNumber
		FROM (
				SELECT ci.custid , ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, ISNULL(cs.reject,0), ci.username) as RowNumber 
				FROM dbo.custinfo ci WITH(NOLOCK) 
					INNER JOIN Customer cu WITH (NOLOCK) ON ci.custid = cu.custid
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @SRecommend AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				WHERE ci.srecommend = @SRecommend 
					AND ci.roleid=3
					AND (ci.username LIKE '%' + @Username + '%' OR cu.username2 LIKE '%' + @Username + '%')
					AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END
					AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END
					AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END			
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
					AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
			) t
		WHERE rownumber BETWEEN @rowstart AND @rowend 			
		
	END
	
	-- get data for filtered customers
	;WITH customers AS
	(
		SELECT	c.custid, ci.currency, ci.roleid, autosuspend, cs.reject, cs.closed, MatchLimit, VirtualMultiplier, Enabled, 
				DisableOutright,DoubleCommLosing,cm.IsInternal, cm.DisableAutoMPT,
				c.username, c.ugroup, c.firstname, c.lastname, c.username2, c.phone, c.mobilephone, c.iplogin, c.creatdate, ISNULL(cs.Locked,0) AS Locked
		FROM dbo.Customer c WITH(NOLOCK)
			INNER JOIN dbo.custInfo ci WITH(NOLOCK) ON ci.custid = c.custid 
			INNER JOIN dbo.CustMaster cm with(NOLOCK) on c.custid = cm.custid 
		    CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = c.custid
								) AS cs
			
		WHERE c.custid IN (SELECT custid FROM #customer)
	),
	CustDiscountAgent AS
	(
		SELECT 
			cda.CustID
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 1 THEN cda.Discount END) AS 'GroupA'
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 3 THEN cda.Discount END) AS 'GroupB'
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 7 THEN cda.Discount END) AS 'GroupC'
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 8 THEN cda.Discount END) AS 'GroupD'
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 5 THEN cda.Discount END) AS '1X2'
		,	MAX(CASE WHEN cda.SportType = 1 AND cda.BetType = 4 THEN cda.Discount END) AS 'OthersComm'		
		FROM CustDiscount3rd_Agent cda WITH (NOLOCK)
		WHERE cda.custid IN (SELECT custid FROM #customer)
		AND cda.SportType IN (1,2)
		GROUP BY cda.CustID
	)
	SELECT      ctm.enabled,
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
			cda.GroupA AS groupa, 
			cda.GroupB AS groupb, 
			cda.GroupC AS groupc, 
			cda.GroupD AS groupd, 
			cda.OthersComm AS discountcs,	
			cda.[1X2] AS discount1x2,
								
			ctm.currency,	
			ctm.matchlimit,
			ctm.virtualmultiplier-1 as VirtualMultiplier,
			ctm.creatdate as createdate,
			ctm.isinternal,
			ctm.DoubleCommLosing,
			
			ISNULL(cl.ClosedReason,0)  AS ClosedReason,
			RowNumber,
			ctm.Locked,
			IIF(cbs.ToCustID > 0, 1, 0) AS IsAllowAutoTransfer
	FROM customers ctm 
		INNER JOIN #customer t ON ctm.custid = t.custid 
		LEFT JOIN CustDiscountAgent cda WITH (NOLOCK) ON ctm.custid = cda.custid
		LEFT JOIN CustLoginInfo cl WITH(NOLOCK) ON t.custid=cl.Custid
		LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @SRecommend AND cbs.ToCustID = ctm.custid	
	ORDER BY  t.RowNumber	
	
	DROP TABLE #customer
END
GO
