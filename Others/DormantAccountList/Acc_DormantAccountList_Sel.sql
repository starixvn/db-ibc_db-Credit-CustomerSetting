/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DormantAccountList_Sel] (
	 @CustID			INT = 0
	,@FilterUsername	VARCHAR(30) = NULL
	,@FilterRoleID		TINYINT = NULL
	,@FilterStatusID	TINYINT = 0
	,@PageSize			INT = 50
	,@PageIndex			INT = 1
	,@TotalItems		INT = 0 OUTPUT
)
AS
/*
	Created: 20201201@Eden
	Task : get the dormant downline accounts which are being processed by the archive account process.
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20201201@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]

	Parameter Definition
		-@FilterStatusID:
			0 = All
			3 = Closed
			4 = Disabled

		-@FilterRoleID (Level)
			0 - All 
			3 - Master
			2 - Agent 
			1 - Member

	Example: 
	DECLARE @TotalItems	INT 
	EXEC Acc_DormantAccountList_Sel 
		@CustId = 46773164,
		--@FilterUsername  = 'EdentestS10M11',
		@FilterRoleID    = 0,
		@FilterStatusID	= 0,
		@PageSize	= 50,
		@PageIndex	= 1,
		@TotalItems = @TotalItems OUTPUT
	SELECT @TotalItems
	
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @RowCount int, @RowStart int, @RowEnd int

	SELECT @PageIndex = @PageIndex - 1, @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 

	DECLARE @LoginRoleID TINYINT
	SELECT @LoginRoleID = roleid FROM custinfo WITH(NOLOCK) WHERE custid = @CustID

	CREATE TABLE #Cust_ArchiveAccount(
		 CustID                 INT, 
		 Username               VARCHAR(30), 
		 RoleID                 TINYINT, 
		 StatusID               TINYINT, 
		 StageID				TINYINT, 
		 ToBeClearedGivenCredit MONEY, 
		 ClearedGivenCredit     MONEY, 
		 lastlogged             DATETIME,
		 ClosedDate             DATETIME, 
		 DisabledDate           DATETIME, 
		 SettingDeletedDate      DATETIME, 
		 IsWarningTicket		BIT,
		 RowNumber              INT PRIMARY KEY CLUSTERED
	);
	
	CREATE TABLE #Exclude(
		recommend  INT, 
		mrecommend INT
	);
	CREATE NONCLUSTERED INDEX ix_TmpExclude_recommend ON #Exclude(recommend)
	CREATE NONCLUSTERED INDEX ix_TmpExclude_mrecommend ON #Exclude(mrecommend)

	CREATE TABLE #Warning(
		mrecommend INT, 
		recommend  INT
	);
	CREATE NONCLUSTERED INDEX ix_TmpWarning_recommend ON #Exclude(recommend)
	CREATE NONCLUSTERED INDEX ix_TmpWarning_mrecommend ON #Exclude(mrecommend)

	IF @LoginRoleID = 4
	BEGIN
		INSERT INTO #Exclude(recommend,mrecommend)
		SELECT a.recommend,a.mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
		WHERE a.srecommend = @CustID AND a.RoleID IN(2,3,4)
			AND a.closed = 0
		UNION
		SELECT a.custid,MAX(a.mrecommend) as mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN custInfo dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.srecommend = @CustID 
			AND a.roleid = 2
		GROUP BY a.custid
		HAVING COUNT(dl.custid) > MAX(c.TotalDownline)
		UNION
		SELECT 0,a.custid
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN custInfo dl WITH(NOLOCK) 
				ON dl.mrecommend = a.custid AND dl.roleid IN (1,2)
		WHERE a.srecommend = @CustID
			AND a.roleid = 3 
		GROUP BY a.custid
		HAVING COUNT(dl.custid) > MAX(c.TotalDownline)

		INSERT INTO #Warning(recommend,mrecommend)
		SELECT DISTINCT a.custid,a.mrecommend
		FROM Customer a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN Customer dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.srecommend = @CustID 
			AND a.roleid = 2
			AND dl.lastlogged > c.ClosedDate

		INSERT INTO #Cust_ArchiveAccount(
			 CustID                
			,Username              
			,RoleID              
			,StatusID              
			,StageID          
			,ToBeClearedGivenCredit
			,ClearedGivenCredit    
			,lastlogged                    
			,ClosedDate            
			,DisabledDate          
			,SettingDeletedDate
			,IsWarningTicket     
			,RowNumber
		)     
		SELECT bc.CustID,
			   ci.Username, 
			   ci.roleID,
			   CASE WHEN ci.Enabled = 0 THEN 4
					ELSE 3
			   END AS StatusID,
			   bc.StageID,
			   CASE WHEN bc.StageID = 1 THEN ci.credit
					--ELSE 0 
			   END AS ToBeClearedGivenCredit,
			   CASE WHEN bc.StageID <> 1 THEN bc.ReducedCredit
					--ELSE 0 
			   END AS ClearedGivenCredit,
			   c.lastlogged,
			   bc.ClosedDate,
			   bc.DisabledDate,
			   bc.SettingDeletedDate,
			   IsWarningTicket = CASE WHEN w.recommend IS NOT NULL THEN 1 
									  WHEN wm.mrecommend IS NOT NULL THEN 1
									ELSE 0 END,
			   RowNumber = ROW_NUMBER() OVER ( ORDER BY bc.StageID, ci.Username)
		FROM Cust_ArchiveAccount bc WITH(NOLOCK)
			 INNER JOIN custInfo ci WITH(NOLOCK) ON bc.CustID = ci.custid
			 INNER JOIN Customer c WITH(NOLOCK) ON bc.custid = c.custid
			 LEFT JOIN #Warning w ON ci.recommend = w.recommend
			 LEFT JOIN #Warning wm ON ci.custid = wm.mrecommend
		WHERE c.username LIKE CASE WHEN ISNULL(@FilterUsername,'') <> ''  THEN '%' + @FilterUsername + '%'  ELSE c.username END
			  AND ci.roleid = CASE WHEN ISNULL(@FilterRoleID,0) <> 0 THEN @FilterRoleID ELSE ci.roleid END 
			  AND ci.Enabled = CASE WHEN ISNULL(@FilterStatusID,0) = 0 THEN ci.Enabled 
									WHEN @FilterStatusID = 3 THEN 1
									WHEN @FilterStatusID = 4 THEN 0
								END 
			  AND bc.srecommend = @CustID
			  AND NOT EXISTS( SELECT 1 FROM #Exclude WHERE ci.recommend = recommend AND ci.roleid IN (1,2))
			  AND NOT EXISTS( SELECT 1 FROM #Exclude WHERE ci.custid = mrecommend)
			  AND ci.custid <> @CustID
	END
	IF @LoginRoleID = 3
	BEGIN
		INSERT INTO #Exclude(recommend,mrecommend)
		SELECT a.recommend,a.mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
		WHERE a.mrecommend = @CustID AND a.RoleID IN(2,3)
			AND a.closed = 0
		UNION
		SELECT a.custid,MAX(a.mrecommend) as mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN custInfo dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.mrecommend = @CustID 
			AND a.roleid = 2
		GROUP BY a.custid
		HAVING COUNT(dl.custid) > MAX(c.TotalDownline)

		INSERT INTO #Warning(recommend,mrecommend)
		SELECT DISTINCT a.custid,a.mrecommend
		FROM Customer a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN Customer dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.mrecommend = @CustID 
			AND a.roleid = 2
			AND dl.lastlogged > c.ClosedDate

		INSERT INTO #Cust_ArchiveAccount(
			 CustID                
			,Username              
			,RoleID              
			,StatusID              
			,StageID          
			,ToBeClearedGivenCredit
			,ClearedGivenCredit    
			,lastlogged                    
			,ClosedDate            
			,DisabledDate          
			,SettingDeletedDate
			,IsWarningTicket     
			,RowNumber
		)     
		SELECT bc.CustID,
			   ci.Username, 
			   ci.roleID,
			   CASE WHEN ci.Enabled = 0 THEN 4
					ELSE 3
			   END AS StatusID,
			   bc.StageID,
			   CASE WHEN bc.StageID = 1 THEN ci.credit
					--ELSE 0 
			   END AS ToBeClearedGivenCredit,
			   CASE WHEN bc.StageID <> 1 THEN bc.ReducedCredit
					--ELSE 0 
			   END AS ClearedGivenCredit,
			   c.lastlogged,
			   bc.ClosedDate,
			   bc.DisabledDate,
			   bc.SettingDeletedDate,
			   IsWarningTicket = CASE WHEN w.recommend IS NOT NULL THEN 1 
									ELSE 0 END,
			   RowNumber = ROW_NUMBER() OVER ( ORDER BY bc.StageID, ci.Username)
		FROM Cust_ArchiveAccount bc WITH(NOLOCK)
			 INNER JOIN custInfo ci WITH(NOLOCK) ON bc.CustID = ci.custid
			 INNER JOIN Customer c WITH(NOLOCK) ON bc.custid = c.custid
			 LEFT JOIN #Warning w ON ci.recommend = w.recommend
		WHERE c.username LIKE CASE WHEN ISNULL(@FilterUsername,'') <> ''  THEN '%' + @FilterUsername + '%'  ELSE c.username END
			  AND ci.roleid = CASE WHEN ISNULL(@FilterRoleID,0) <> 0 THEN @FilterRoleID ELSE ci.roleid END 
			  AND ci.Enabled = CASE WHEN ISNULL(@FilterStatusID,0) = 0 THEN ci.Enabled 
									WHEN @FilterStatusID = 3 THEN 1
									WHEN @FilterStatusID = 4 THEN 0
								END 
			  AND bc.mrecommend = @CustID
			  AND NOT EXISTS( SELECT 1 FROM #Exclude WHERE ci.recommend = recommend  AND ci.roleid IN (1,2))
			  AND ci.custid <> @CustID
	END
	/*
	IF @LoginRoleID = 2
	BEGIN
		INSERT INTO #Exclude(recommend,mrecommend)
		SELECT a.recommend,a.mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
		WHERE a.CustID = @CustID
			AND a.closed = 0
		UNION
		SELECT a.custid,MAX(a.mrecommend) as mrecommend
		FROM custInfo a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN custInfo dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.recommend = @CustID 
			AND a.roleid = 2
		GROUP BY a.custid
		HAVING COUNT(dl.custid) > MAX(c.TotalDownline)

		INSERT INTO #Warning(recommend,mrecommend)
		SELECT DISTINCT a.custid,a.mrecommend
		FROM Customer a WITH(NOLOCK) 
			INNER JOIN Cust_ArchiveAccount c WITH(NOLOCK) 
				ON a.custid = c.CustID
			INNER JOIN Customer dl WITH(NOLOCK) 
				ON dl.recommend = a.custid AND dl.roleid = 1
		WHERE a.recommend = @CustID 
			AND a.roleid = 2
			AND dl.lastlogged > c.ClosedDate

		INSERT INTO #Cust_ArchiveAccount(
			 CustID                
			,Username              
			,RoleID              
			,StatusID              
			,StageID          
			,ToBeClearedGivenCredit
			,ClearedGivenCredit    
			,lastlogged                    
			,ClosedDate            
			,DisabledDate          
			,SettingDeletedDate
			,IsWarningTicket     
			,RowNumber
		)     
		SELECT bc.CustID,
			   ci.Username, 
			   ci.roleID,
			   CASE WHEN ci.Enabled = 0 THEN 4
					ELSE 3
			   END AS StatusID,
			   bc.StageID,
			   CASE WHEN bc.StageID = 1 THEN ci.credit
					--ELSE 0 
			   END AS ToBeClearedGivenCredit,
			   CASE WHEN bc.StageID <> 1 THEN bc.ReducedCredit
					--ELSE 0 
			   END AS ClearedGivenCredit,
			   c.lastlogged,
			   bc.ClosedDate,
			   bc.DisabledDate,
			   bc.SettingDeletedDate,
			   IsWarningTicket = CASE WHEN w.recommend IS NOT NULL THEN 1 
									ELSE 0 END,
			   RowNumber = ROW_NUMBER() OVER ( ORDER BY bc.StageID, ci.Username)
		FROM Cust_ArchiveAccount bc WITH(NOLOCK)
			 INNER JOIN custInfo ci WITH(NOLOCK) ON bc.CustID = ci.custid
			 INNER JOIN Customer c WITH(NOLOCK) ON bc.custid = c.custid
			 LEFT JOIN #Warning w ON ci.recommend = w.recommend
		WHERE c.username LIKE CASE WHEN ISNULL(@FilterUsername,'') <> ''  THEN '%' + @FilterUsername + '%'  ELSE c.username END
			  AND ci.roleid = CASE WHEN ISNULL(@FilterRoleID,0) <> 0 THEN @FilterRoleID ELSE ci.roleid END 
			  AND ci.Enabled = CASE WHEN ISNULL(@FilterStatusID,0) = 0 THEN ci.Enabled 
									WHEN @FilterStatusID = 3 THEN 1
									WHEN @FilterStatusID = 4 THEN 0
								END 
			  AND bc.recommend = @CustID
			  AND NOT EXISTS( SELECT 1 FROM #Exclude WHERE ci.recommend = recommend AND ci.roleid IN (1,2))
			  AND ci.custid <> @CustID
	END
	*/
	
	SELECT @TotalItems = COUNT(1) 
	FROM #Cust_ArchiveAccount

	SELECT  CustID                
		,Username              
		,RoleID              
		,StatusID              
		,StageID          
		,ToBeClearedGivenCredit
		,ClearedGivenCredit    
		,lastlogged                    
		,ClosedDate            
		,DisabledDate          
		,SettingDeletedDate
		,IsWarningTicket     
		,RowNumber 
	FROM #Cust_ArchiveAccount
	WHERE RowNumber BETWEEN @rowstart AND @rowend 		

	--get yesterday balance
	DECLARE @CustIdList VARCHAR(MAX) = ''

	IF @TotalItems = 0
	BEGIN
		SELECT 0 AS CustId, CAST(0 AS MONEY) AS	YesterdayTotalBalance WHERE 1 <> 1
		RETURN
	END

	SELECT @CustIdList = @CustIdList + ',' + CONVERT(varchar,CustID)
	FROM  #Cust_ArchiveAccount
	WHERE RowNumber BETWEEN @rowstart AND @rowend 	

	SELECT @CustIdList = STUFF(@CustIdList,1,1,'')

	EXEC DBAGE.bodb02.dbo.Acc_CustomerSelBalanceInfo @CustIdList = @CustIdList
	
END
GO


