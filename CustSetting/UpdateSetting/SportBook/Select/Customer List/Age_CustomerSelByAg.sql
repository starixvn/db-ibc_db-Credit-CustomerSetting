/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelByAg]  
	@UplineID int,		-- SMA Input
	@IsAgentSite bit = 0,  
	@Username varchar(30)=null,  
	@Enabled bit = null,  
	@Closed bit=null,  
	@Suspended bit=null,
	@DoubleCommLosing tinyint = 2,
	@PageSize int = 20000,  
	@PageIndex int = 1,  
	@TotalPages int = 1 output,
	@TotalItems int=0 OUTPUT,
	@Userid		INT=NULL,
	@Locked BIT = NULL, -- 1: Locked filter
	@AutoTransfer 	TINYINT = 2,
	@ServiceType	TINYINT = 2
AS 
BEGIN 
/*  
	Created by: [Winfred]  
	Date:[20200724]  
	Task: Member List smartphone 
	DB: DBCUST/CustDB
	Original: agentsite/account\customerlist.asp  : Acc_CustomerSelByAg

	Revisions: 		
		- 20200724@winfred: Remove Status games for customer list smartphone [redmine: #137130]
		- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
		- 20220816@Johnson: enhance sp [redmine: #176641]
		- 20220921@Winfred:  Macau Game Setting Page - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
		- 20230410@Bobby: AutoJob clear balance downlines [RedmineID: #182071]
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20240917@Elodie: Tuning sp [redmine: #210892]
		- 20241022@Johnson: remove MyanmarOdds [redmine: #201396]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]    
		- 20250707@Dave: Agency Cash Service - Customer Setting - Sprint 6 - Add filter for Member Type (@ServiceType) [Redmine: #232372]
		
	Explanation's Param:
		- @DoubleCommLosing:
			0: Not Allowed double comm
			1: Allowed double comm
			2: All
		- @AutoTransfer:
			0: Not Allowed Auto Transfer
			1: Allowed Auto Transfer
			2: All
		- @ServiceType:
			0: Credit Member
			1: Cash Member
			2: All

*/  
	  
	SET NOCOUNT ON  
	
		----- /Elodie @ 01 JUN 2015 -------------------
	DECLARE @RowCount int, @RowStart int, @RowEnd int  
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1   
	SET @Username = isnull(@Username, '')  
	
      DECLARE	@bitmapOrder_AllBet		INT
		,	@bitmapOrder_VoidBridge		INT 
	SET		@bitmapOrder_VoidBridge =	(SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SELECT	@bitmapOrder_AllBet	=	(SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
		  
	CREATE TABLE #memberList (custid int, rn int)

	CREATE TABLE #CollectDownline  (custid INT ,  DoubleCommLosing BIT , [Enabled] BIT , username NVARCHAR(50), PRIMARY KEY CLUSTERED  (custid))
	--Since the CustInfo table in the Select statement cannot use an index[recommend, mrecommend, srecommend], so data must be collected beforehand 
	INSERT INTO #CollectDownline (custid , DoubleCommLosing , [Enabled] , username)
	SELECT CustID , DoubleCommLosing , i.Enabled , i.username FROM custInfo i WITH (NOLOCK) WHERE i.recommend = @UplineID AND i.roleid = 1
	UNION ALL
	SELECT CustID , DoubleCommLosing , i.Enabled , i.username FROM custInfo i WITH (NOLOCK) WHERE i.mrecommend = @UplineID AND i.roleid = 1 AND i.recommend = -3
	UNION ALL
	SELECT CustID , DoubleCommLosing , i.Enabled , i.username FROM custInfo i WITH (NOLOCK) WHERE i.srecommend = @UplineID AND i.roleid = 1 AND i.recommend = -4

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL  AND @DoubleCommLosing =2 AND @Locked IS NULL
		AND @AutoTransfer = 2 /*default condition: get all */ AND @ServiceType = 2 /*get all*/
	BEGIN
		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = count(ci.custid),@TotalPages=@TotalItems/@PageSize + case when @TotalItems%@PageSize > 0 then 1 else 0 end  
			From #CollectDownline ci
		END
		
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM #CollectDownline ci
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
			) x
		WHERE rn between @rowstart and @rowend				
	END
	ELSE IF @Username = ''
	BEGIN
		IF @TotalPages = 0
		BEGIN
			SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
			FROM #CollectDownline ci
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @UplineID AND cbs.ToCustID = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				CROSS APPLY (SELECT TOP (1) ServiceType
									FROM dbo.vw_CustInfoExtra WITH(NOLOCK)
									WHERE CustID = ci.custid) AS v_csm
			WHERE enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
				AND isnull(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
				AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
				AND 1 = CASE 
							WHEN @ServiceType = 2 THEN 1
							WHEN ISNULL(v_csm.ServiceType, 0) = @ServiceType THEN 1
							ELSE 0 
						END
		END
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM #CollectDownline ci
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @UplineID AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					CROSS APPLY (SELECT TOP (1) ServiceType
									FROM dbo.vw_CustInfoExtra WITH(NOLOCK)
									WHERE CustID = ci.custid) AS v_csm
				WHERE enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
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
					AND 1 = CASE 
								WHEN @ServiceType = 2 THEN 1
								WHEN ISNULL(v_csm.ServiceType, 0) = @ServiceType THEN 1
								ELSE 0 
							END
			) x
		WHERE rn BETWEEN @rowstart AND @rowend
	END
	ELSE
	BEGIN	
		IF @TotalPages = 0  
		BEGIN
			SELECT @TotalItems = COUNT(ci.custid),@TotalPages=@TotalItems/@PageSize + CASE WHEN @TotalItems%@PageSize > 0 THEN 1 ELSE 0 END  
			FROM #CollectDownline ci
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @UplineID AND cbs.ToCustID = ci.custid
				INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
				CROSS APPLY (SELECT TOP (1) ServiceType
									FROM dbo.vw_CustInfoExtra WITH(NOLOCK)
									WHERE CustID = ci.custid) AS v_csm
			WHERE (ci.username LIKE '%' + @Username + '%' OR (@Userid = @UplineID AND c.username2 LIKE '%' + @Username + '%'))
				AND ISNULL(cs.closed,0) = CASE WHEN @suspended = 1 THEN 0 ELSE COALESCE(@closed, ISNULL(cs.closed, 0)) END  
				AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
				AND ISNULL(cs.reject,0) = CASE WHEN @Closed = 0 THEN 0 ELSE COALESCE(@suspended, ISNULL(cs.reject, 0))END     
				AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END	
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
				AND 1 = CASE 
						WHEN @ServiceType = 2 THEN 1
						WHEN ISNULL(v_csm.ServiceType, 0) = @ServiceType THEN 1
						ELSE 0 
					END
		END
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, cs.reject, ci.username) AS rn
				FROM #CollectDownline ci
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @UplineID AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
					CROSS APPLY (SELECT TOP (1) ServiceType
									FROM dbo.vw_CustInfoExtra WITH(NOLOCK)
									WHERE CustID = ci.custid) AS v_csm
				WHERE (ci.username LIKE '%' + @Username + '%' OR (@Userid = @UplineID AND c.username2 LIKE '%' + @Username + '%'))
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
					AND 1 = CASE 
								WHEN @ServiceType = 2 THEN 1
								WHEN ISNULL(v_csm.ServiceType, 0) = @ServiceType THEN 1
								ELSE 0 
							END
			) x
		WHERE rn BETWEEN @rowstart AND @rowend
	END
	
	CREATE TABLE #Result 
	(
			custid INT PRIMARY KEY
		,	rn INT
		,	discount DECIMAL(9,8)
		,	discountcs DECIMAL(9,8)
		,	discount1x2 DECIMAL(9,8)
		,	playerdiscount DECIMAL(9,8)
		,	playerdiscountcs DECIMAL(9,8)
		,	playerdiscount1x2 DECIMAL(9,8)		
	)
		
	INSERT INTO #Result(custid, rn, discount, discountcs, discount1x2, playerdiscount, playerdiscountcs, playerdiscount1x2)
	SELECT
		c.custid
	,	rn
	,	MAX(CASE 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 1 AND c1.recommend NOT IN (-3,-4)		THEN cdm.AgentDiscount 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 1 AND c1.recommend = -3			THEN cdm.MasterDiscount
			   WHEN cdm.SportType = 1 AND cdm.BetType = 1 AND c1.recommend = -4			THEN cdm.SuperDiscount
			   ELSE 0 END)	   AS discount
	
	,	MAX(CASE 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 4 AND c1.recommend NOT IN (-3,-4)		THEN cdm.AgentDiscount 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 4 AND c1.recommend = -3			THEN cdm.MasterDiscount
			   WHEN cdm.SportType = 1 AND cdm.BetType = 4 AND c1.recommend = -4			THEN cdm.SuperDiscount
			   ELSE 0 END)	   AS discountcs

	,	MAX(CASE 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 5 AND c1.recommend NOT IN (-3,-4)		THEN cdm.AgentDiscount 
			   WHEN cdm.SportType = 1 AND cdm.BetType = 5 AND c1.recommend = -3			THEN cdm.MasterDiscount
			   WHEN cdm.SportType = 1 AND cdm.BetType = 5 AND c1.recommend = -4			THEN cdm.SuperDiscount
			   ELSE 0 END)	   AS discount1x2
	     	   
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 1 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscount
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 4 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscountcs
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 5 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscount1x2	
	FROM #memberList c
	INNER JOIN Customer c1 WITH (NOLOCK) ON c.custid = c1.custid
	LEFT JOIN CustDiscount3rd_Member cdm WITH (NOLOCK) ON c.custid = cdm.CustID
	WHERE cdm.SportType IN (1,2)
	AND rn between @rowstart and @rowend
	GROUP BY c.CustID , rn 
	
	SELECT   
		ci.enabled, cps.closed, isnull(cps.reject,0) as suspended, isnull(ci.DisableOutright,0) as DisableOutright, ci.virtualmultiplier-1 as VirtualMultiplier,   
		c.username, c.custid, ci.roleid, c.ugroup as ugroup, IsNull(c.site,'') AS site,   
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
		ISNULL(cl.ClosedReason,0) AS ClosedReason,
		ISNULL(cps.Locked,0) AS Locked,
		IIF(cbs.ToCustID > 0, 1, 0) AS IsAllowAutoTransfer,
		ISNULL(v_csm.ServiceType, 0) AS ServiceType
	FROM #Result m  
		INNER JOIN customer c (nolock) on m.custid = c.custid  
		INNER JOIN Custinfo ci (nolock) on m.custid = ci.custid      
		CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cps
		CROSS APPLY (SELECT TOP (1) ServiceType
								FROM dbo.vw_CustInfoExtra WITH(NOLOCK)
								WHERE CustID = ci.custid) AS v_csm
		LEFT JOIN CustLoginInfo_Member cl WITH(NOLOCK) ON c.custid=cl.CustID
		LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @UplineID AND cbs.ToCustID = m.custid
	ORDER BY rn

	DROP TABLE #memberList
END
GO
