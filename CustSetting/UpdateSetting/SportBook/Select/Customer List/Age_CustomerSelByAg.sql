/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerSelByAg]  
	@Recommend int,  
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
	@AutoTransfer TINYINT = 2
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
	  
	SET NOCOUNT ON  
	
		----- /Elodie @ 01 JUN 2015 -------------------
	DECLARE @RowCount int, @RowStart int, @RowEnd int  
	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1   
	SET @Username = isnull(@Username, '')  
	
      DECLARE	@bitmapOrder_AllBet		INT
		,	@bitmapOrder_VoidBridge		INT 
	SET		@bitmapOrder_VoidBridge =	(SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SELECT	@bitmapOrder_AllBet	=	(SELECT psp.bitmapOrder FROM dbo.ProductStatusProfile AS psp WITH(NOLOCK) WHERE	psp.Sporttype = 211 AND	psp.Bettype = 2401)
		  
	CREATE TABLE #memberList (custid int, rn int,playerdiscountMyanmarOdds DECIMAL (9,8), adiscountMyanmarOdds DECIMAL (9,8))

	IF @Username = '' AND @Enabled IS NULL AND @Closed IS NULL AND @Suspended IS NULL  AND @DoubleCommLosing =2 AND @Locked IS NULL 
		AND @AutoTransfer = 2 -- default condition: get all
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
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM dbo.custInfo ci with(nolock)
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @Recommend AND cbs.ToCustID = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
										, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
										, Locked
									FROM dbo.CustProductStatus  WITH(NOLOCK)
									WHERE CustID = ci.custid
								) AS cs
			WHERE ci.Recommend = @recommend AND ci.roleid=1   
				AND enabled = CASE WHEN COALESCE(@Closed,@Suspended) IS NOT NULL THEN 1 ELSE COALESCE(@enabled, enabled) END  
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
		END
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled desc, cs.closed, cs.reject, ci.username) as rn
				FROM dbo.custInfo ci with(nolock)
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @Recommend AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
					AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1 
							WHEN @AutoTransfer = 2 THEN 1
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
			FROM dbo.Custinfo ci WITH(NOLOCK)
				LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @Recommend AND cbs.ToCustID = ci.custid
				INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
				CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
				AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END	
				AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
				AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1
							WHEN @AutoTransfer = 2 THEN 1
							ELSE 0 
						END
		END
		INSERT INTO #memberList (custid, rn)
		SELECT custid, rn
		FROM (
				SELECT ci.custid,
					ROW_NUMBER() OVER (ORDER BY ci.enabled DESC, cs.closed, cs.reject, ci.username) AS rn
				FROM dbo.custInfo ci with(nolock)
					INNER JOIN Customer c WITH (NOLOCK) ON c.custid = ci.custid
					LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @Recommend AND cbs.ToCustID = ci.custid
					CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
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
					AND ci.DoubleCommLosing = CASE WHEN @DoubleCommLosing = 2 THEN ci.DoubleCommLosing ELSE @DoubleCommLosing END
					AND ISNULL(cs.Locked,0) >= ISNULL(@Locked,0)
					AND 1 = CASE 
							WHEN @AutoTransfer = 0 AND cbs.ToCustID IS NULL THEN 1 
							WHEN @AutoTransfer = 1 AND cbs.ToCustID > 0 THEN  1
							WHEN @AutoTransfer = 2 THEN 1
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
		,	playerdiscountMyanmarOdds DECIMAL (9,8)
		,	adiscountMyanmarOdds DECIMAL (9,8) 
	)
	
	
	INSERT INTO #Result(custid, rn, discount, discountcs, discount1x2, playerdiscount, playerdiscountcs, playerdiscount1x2, playerdiscountMyanmarOdds, adiscountMyanmarOdds)
	SELECT
		c.custid
	,	rn
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 1 THEN cdm.AgentDiscount ELSE 0 END)	   AS discount
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 4 THEN cdm.AgentDiscount ELSE 0 END)	   AS discountcs
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 5 THEN cdm.AgentDiscount ELSE 0 END)	   AS discount1x2
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 1 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscount
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 4 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscountcs
	,	MAX(CASE WHEN cdm.SportType = 1 AND cdm.BetType = 5 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscount1x2
	,	MAX(CASE WHEN cdm.SportType = 2 AND cdm.BetType = 1 THEN cdm.PlayerDiscount ELSE 0 END)	   AS playerdiscountMyanmarOdds
	,	MAX(CASE WHEN cdm.SportType = 2 AND cdm.BetType = 1 THEN cdm.AgentDiscount ELSE 0 END)	   AS adiscountMyanmarOdds
	FROM #memberList c
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
		-- MyanmarOdds
		CASE WHEN ISNULL(m.playerdiscountMyanmarOdds,0) = 0 THEN 0 ELSE 1 END AS IsMyanmarOdds,
		ISNULL(m.playerdiscountMyanmarOdds,0) playerdiscountMyanmarOdds,
		ISNULL(m.adiscountMyanmarOdds,0) adiscountMyanmarOdds,
		ci.DoubleCommLosing,
		rn as RowNumber,
		ISNULL(cl.ClosedReason,0) AS ClosedReason,
		ISNULL(cps.Locked,0) AS Locked,
		IIF(cbs.ToCustID > 0, 1, 0) AS IsAllowAutoTransfer
	FROM #Result m  
		INNER JOIN customer c (nolock) on m.custid = c.custid  
		INNER JOIN Custinfo ci (nolock) on m.custid = ci.custid      
		CROSS APPLY  (SELECT TOP (1) CASE WHEN CloseInfo > 0 THEN 1 ELSE 0 END AS closed
									, CASE WHEN SuspendInfo > 0 THEN 1 ELSE 0 END AS reject
									, Locked
								FROM dbo.CustProductStatus  WITH(NOLOCK)
								WHERE CustID = ci.custid
							) AS cps
		LEFT JOIN CustLoginInfo_Member cl WITH(NOLOCK) ON c.custid=cl.CustID
		LEFT JOIN dbo.Age_ClearBalanceCust_Setting cbs WITH(NOLOCK) ON cbs.FromCustID = @Recommend AND cbs.ToCustID = m.custid					
	ORDER BY rn

	DROP TABLE #memberList
END
GO
