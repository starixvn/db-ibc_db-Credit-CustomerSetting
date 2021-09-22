/*<info serverAlias="DBBACKUP2-custdb,DBBACKUP2-CustDB_DBTRANS" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/  
CREATE PROCEDURE [DBA_ArchiveAccount_GenMasterSuperGroupLevel]
(
	@StageId	TINYINT
)
AS
/*
	Created: 20200505@Max
	Task : Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
	DB:  DBCUST/CustDB
	Original:
	Revision:
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20200911@Helen: Fix stage 1 - M0 - [Redmine:130032]
		- 20201231@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20210302@Eden: Just process SMA(s) stage 2, 3, 4 when they processed stage 1  [RedmineID: #149262]
		- 20210617@Eden: Enhance the archiving account process on Stage 4 [RedmineID: #157123]
		- 20210524@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210825@Eden: Exclude Direct Masters/Agents/Members from Archiving Credit Account process (Stage 3 and Stage 4) [RedmineID: #160690]
		
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON
	
	-- simulate run date based on test data version
	declare @currentDate smalldatetime 
	select @currentDate = VValue from bodb02.dbo.Systemsettings with (nolock) where VName = 'aa_TestDate'		

	TRUNCATE TABLE dbo.tmpCustGroupLevelArchived

	DECLARE @query NVARCHAR(MAX) = ''
		, @ExecuteSQL NVARCHAR(MAX) = ''

	CREATE TABLE #tmpMaster (username VARCHAR(100), custid INT)
	CREATE TABLE #tmpSuper (custid INT, MasterArchivedCount INT)
	CREATE TABLE #tmpMaster_DetectM0 (custid INT, srecommend INT)
	CREATE TABLE #tmpSuper_M0 (custID INT)
	
	/*Get master from TmpCustArchived*/
	INSERT INTO #tmpMaster (username, custid)
	SELECT DISTINCT m.username, ag.mrecommend
	FROM dbo.tmpCustArchived t WITH (NOLOCK)
		INNER JOIN custdb.dbo.custinfo ag WITH (NOLOCK) ON ag.custid = t.recommend
		INNER JOIN custdb.dbo.custinfo m WITH (NOLOCK) ON m.custid = ag.mrecommend
	WHERE ISNULL(t.ErrMsg,'') = '' OR t.ErrMsg LIKE '%archived%'
		
	/*
		Count number of agents for each master
			- Count in TmpCustArchive
			- Count total in Custinfo, all conditions except for no tickets and no new member 
	*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT c.custid, c.roleid
		,CASE WHEN mem.AgentCount = mem2.AgentCount AND rules.isValid = 1
				 THEN 'M1' ELSE 'M2' END AS GroupLevelName /*Match -> M1, Not Match -> M2*/
		,@StageId
	FROM custdb.dbo.custinfo c WITH (NOLOCK)
		INNER JOIN #tmpMaster t ON t.custid = c.custid
		INNER JOIN custdb.dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = c.custid
		OUTER APPLY (
			SELECT COUNT(1) AgentCount
			FROM tmpCustArchived mem WITH (NOLOCK)
			WHERE mem.Master = t.username AND (ISNULL(ErrMsg,'') = '' OR ErrMsg LIKE '%archived%')
		) mem
		OUTER APPLY (
			SELECT COUNT(1) AgentCount
			FROM custdb.dbo.customer ag WITH (NOLOCK)
			WHERE ag.roleid = 2
				AND ag.mrecommend = t.custid
		)mem2
		OUTER APPLY (SELECT  CASE 
								WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
								WHEN @StageId IN (3,4) AND c.enabled = 1 THEN 0			 
								ELSE 1
							END AS isValid
					)rules
				
	/*Detect S1, S2 from list M1*/
	INSERT INTO #tmpSuper (custid, MasterArchivedCount)
	SELECT c.srecommend, ISNULL(COUNT(t.custid),0)
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN custdb.dbo.customer c WITH (NOLOCK) ON c.custid = t.custid
	WHERE GroupLevelName = 'M1'
	GROUP BY c.srecommend
	
	DECLARE @DDiff DATETIME
	SELECT @DDiff = DATEADD(mm, -7, @currentdate)
	SELECT @DDiff = DATEADD(week, -2, @DDiff)

	INSERT INTO #tmpMaster_DetectM0 (custid,srecommend)
	SELECT c.custid,s.custid 
	FROM #tmpSuper s
		INNER JOIN custdb.dbo.customer c WITH (NOLOCK) ON s.custid = c.srecommend
		INNER JOIN custdb.dbo.custinfo ci WITH (NOLOCK) ON ci.custid = c.custid
		INNER JOIN CUSTDB.dbo.CustMaster cm WITH (NOLOCK) ON cm.custid = c.custid 
		INNER JOIN CustDB.dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid 
		LEFT JOIN #tmpMaster ma ON ma.custid = c.custid
		OUTER APPLY (SELECT TOP 1 1 AS MO_total
					FROM custdb.dbo.customer c1 WITH (NOLOCK)
					WHERE c.custid = c1.mrecommend AND c1.roleid = 2
						
					) AS M0
	WHERE c.roleid = 3 AND M0.MO_total IS NULL
		AND ma.custid IS NULL 
		AND cm.IsInternal = 0
		AND s.custid NOT IN (SELECT custid FROM custdb.dbo.Dep_CustSuper WITH(NOLOCK))
		AND 1 = CASE WHEN @StageId = 1 AND c.creatdate < DATEADD(mm, -3, @currentdate) THEN 1
						 WHEN @StageId = 2 AND c.creatdate < DATEADD(mm, - 4, @currentdate) THEN 1
						 WHEN @StageId = 3 AND c.creatdate < DATEADD(mm, -7, @currentdate) THEN 1
						 WHEN @StageId = 4 AND c.creatdate < @DDiff THEN 1
						 ELSE 0
					END	
		AND 1 = CASE WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
					 WHEN @StageId IN (3,4) AND ci.enabled = 1 THEN 0			 
				ELSE 1 END
		AND c.username NOT LIKE 'IBC%'
		AND c.username NOT IN ('M527','SA-RMB001','MBRM')		
	
	-- Insert S1, S2	
	INSERT INTO tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT c.custid, c.roleid
		,CASE WHEN rules.isValid = 1 AND m.MasterCount = (ISNULL(t.MasterArchivedCount,0) + ISNULL(m0.MasterCount_M0,0)) THEN 'S1' ELSE 'S2' END AS GroupLevelName /*Match -> S1, Not Match -> S2*/
		,@StageId
	FROM custdb.dbo.custinfo c WITH (NOLOCK)
		INNER JOIN #tmpSuper t ON t.custid = c.custid
		INNER JOIN custdb.dbo.CustProductStatus cps WITH (NOLOCK) ON c.custid = cps.CustID
		OUTER APPLY (
			SELECT COUNT(1) MasterCount
			FROM custdb.dbo.custinfo WITH (NOLOCK)
			WHERE roleid = 3
				AND srecommend = t.custid
		)m
	   OUTER APPLY (
			SELECT COUNT(1) MasterCount_M0
			FROM #tmpMaster_DetectM0 t1 WITH (NOLOCK)
			WHERE t1.srecommend = t.custid
		)m0
		OUTER APPLY (SELECT  CASE 
								WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
								WHEN @StageId IN (3,4) AND c.enabled = 1 THEN 0			 
								ELSE 1
							END AS isValid
					)rules		
	
	/*Get list Super from list M2 into S3*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT srecommend, 4, 'S3', @StageId
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN custdb.dbo.customer c WITH (NOLOCK) ON c.custid =  t.custid
	WHERE GroupLevelName = 'M2'
		AND srecommend NOT IN (SELECT custid FROM #tmpSuper)
	-- Remove A0 (tmpCustArchived) if NOT M1
	DELETE t
	FROM tmpCustArchived t WITH (NOLOCK)
		INNER JOIN custdb.dbo.customer c WITH (NOLOCK) ON t.Master = c.username
		INNER JOIN tmpCustGroupLevelArchived ar WITH (NOLOCK) ON ar.custid = c.custid 
		OUTER APPLY (
			SELECT COUNT(1) MemCount
			FROM custdb.dbo.custinfo ci WITH (NOLOCK)
			WHERE ci.roleid = 1 AND ci.recommend = t.recommend
			)AS tmp
	WHERE ISNULL(tmp.MemCount,0) = 0 AND ar.GroupLevelName NOT IN ('M1')
	
	-- INSERT M0 IF S1
	INSERT INTO tmpCustGroupLevelArchived (custid, roleid, GroupLevelName, StageID)
	SELECT t.custid, 3, 'M0',@StageId
	FROM #tmpMaster_DetectM0 t	
		INNER JOIN dbo.tmpCustGroupLevelArchived a WITH (NOLOCK) ON t.srecommend = a.custid 
		INNER JOIN custDB.dbo.custinfo ci WITH (NOLOCK) ON t.custid = ci.custid
		INNER JOIN custdb.dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
	WHERE a.roleid = 4 AND a.GroupLevelName = 'S1'	
		AND 1 = CASE WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
					 WHEN @StageId IN (3,4) AND ci.enabled = 1 THEN 0
					ELSE 1 
				END
						
	-- Master have no downline, its Super not in list processing
	-- Insert M0 - Master have no downline, its Super not in list processing
	CREATE TABLE #Super_Exception (srecommend INT PRIMARY KEY)

	INSERT INTO #Super_Exception (srecommend)
	SELECT ci.srecommend		
	FROM CUSTDB.dbo.CustGroupHeadline gl WITH(NOLOCK)		
		INNER JOIN custdb.dbo.Customer ci WITH(NOLOCK) ON gl.CustID = ci.custid		
	WHERE GroupID > 0 and ci.roleid in (1,2,3,4)
	UNION
	SELECT ag.custid
	FROM CUSTDB.dbo.phonebettingCustomerList p WITH(NOLOCK)
		INNER JOIN custdb.dbo.custinfo c WITH(NOLOCK) ON p.username = c.username
		INNER JOIN custdb.dbo.custinfo ag WITH(NOLOCK) ON ag.custid = c.srecommend

	--Exclude SuperID: 44671646
	INSERT INTO #Super_Exception(srecommend)
	SELECT t.custid
	FROM (VALUES(44671646)) AS t(custID)
	WHERE NOT EXISTS( SELECT 1 FROM #Super_Exception WHERE srecommend = t.custID)
	
	INSERT INTO tmpCustGroupLevelArchived (custid, roleid, GroupLevelName, StageID)	
	SELECT ma.custid, 3, 'M0', @StageId
	FROM custdb.dbo.customer ma WITH (NOLOCK)
		INNER JOIN custdb.dbo.custinfo agci WITH (NOLOCK) ON agci.custid = ma.custid
		INNER JOIN custdb.dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = agci.custid
		INNER JOIN CUSTDB.dbo.CustMaster cm WITH (NOLOCK) ON cm.custid = ma.custid 
		OUTER APPLY (
			SELECT TOP 1 recommend
			FROM custdb.dbo.custinfo mem WITH (NOLOCK)
			WHERE roleid = 2 AND mem.mrecommend = ma.custid
			) AS Downline
		LEFT JOIN #Super_Exception se ON se.srecommend = ma.srecommend
		LEFT JOIN #tmpSuper st ON st.custid = ma.srecommend
		LEFT JOIN tmpCustGroupLevelArchived ar WITH (NOLOCK) ON ar.custid = ma.custid
	WHERE ma.roleid = 3
		AND Downline.recommend IS NULL
		AND st.custid IS NULL
		AND ma.srecommend NOT IN (SELECT custid FROM custdb.dbo.Dep_CustSuper WITH(NOLOCK))
		AND se.srecommend IS NULL
		AND ar.custid IS NULL
		AND 1 = CASE WHEN @StageId = 1 AND ma.creatdate < DATEADD(mm, -3, @currentdate) THEN 1
						 WHEN @StageId = 2 AND ma.creatdate < DATEADD(mm, - 4, @currentdate) THEN 1
						 WHEN @StageId = 3 AND ma.creatdate < DATEADD(mm, -7, @currentdate) THEN 1
						 WHEN @StageId = 4 AND ma.creatdate < @DDiff THEN 1
						 ELSE 0
					END
		AND ma.currency NOT IN (20, 72)	
		AND cm.IsInternal = 0
		AND ma.site <> 'cn88'		
		AND 1 = CASE WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
					 WHEN @StageId IN (3,4) AND agci.enabled = 1 THEN 0
					ELSE 1 
				END			
		
	-- Insert S1 - Master have no downline, its Super not in list processing 
	INSERT INTO #tmpSuper_M0 (custID)
	SELECT DISTINCT c.srecommend
	FROM tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN custdb.dbo.customer c WITH (NOLOCK) ON t.custid = c.custid 
		INNER JOIN custdb.dbo.customer super WITH (NOLOCK) ON super.custid = c.srecommend
		INNER JOIN CUSTDB.dbo.CustSuper cm WITH (NOLOCK) ON cm.custid = c.srecommend
		LEFT JOIN #Super_Exception se ON se.srecommend = c.custid
		LEFT JOIN tmpCustGroupLevelArchived ts WITH (NOLOCK) ON ts.custid = c.srecommend
	WHERE t.Roleid = 3 AND t.GroupLevelName = 'M0' 
		AND ts.custid IS NULL
		AND cm.IsInternal = 0
		AND se.srecommend IS NULL
		AND c.srecommend NOT IN (SELECT custid FROM custdb.dbo.Dep_CustSuper WITH(NOLOCK))
		AND c.currency NOT IN (20, 72)	
		AND c.site <> 'cn88'
		AND super.roleid = 4	
		AND super.username NOT LIKE '3rdSuper%'
		AND super.username NOT IN ('STAFF', 'SA-UUS', 'LC-RM', 'U3S',
			'OPS-RM', 'OPS-RMB', 'OPS-HKK', 'OPS-THB', 'OPS-IDD', 'OPS-US$', 'OPS-GBP'--CSD request internal use @20180424
		)
		AND super.username NOT LIKE 'SuperTest%'
		AND super.username NOT LIKE 'STEST%'
		AND super.username NOT LIKE 'SIBC%'
		AND super.username NOT LIKE '%ACCSuper%'
		
	INSERT INTO tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT t.custid, 4
		,'S1' GroupLevelName 
		,@StageId
	FROM #tmpSuper_M0 t WITH (NOLOCK)
		INNER JOIN custdb.dbo.custInfo ci WITH (NOLOCK) ON ci.custid = t.custID
		INNER JOIN custdb.dbo.CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
		LEFT JOIN tmpCustGroupLevelArchived ar_s WITH (NOLOCK) ON ar_s.custid = t.custID
		OUTER APPLY (
			SELECT COUNT(1) MasterCount
			FROM custdb.dbo.customer WITH (NOLOCK)
			WHERE roleid = 3
				AND srecommend = t.custid
		)m1
		OUTER APPLY (
			SELECT COUNT(1) MasterCount
			FROM tmpCustGroupLevelArchived ar WITH (NOLOCK)
				INNER JOIN custdb.dbo.customer ci WITH (NOLOCK) ON ci.custid = ar.custid
			WHERE ci.roleid = 3
				AND ci.srecommend = t.custid
				AND ar.GroupLevelName = 'M0'
		)m2
			
	WHERE m1.MasterCount = m2.MasterCount
		AND ar_s.custid IS NULL
		AND 1 = CASE 
					--WHEN @StageId = 1 AND ci.closed = 1 THEN 0
					WHEN @StageId = 2 AND cps.CloseInfo = 0 THEN 0 
					 WHEN @StageId IN (3,4) AND ci.enabled = 1 THEN 0
					ELSE 1 
				END	
	-- Remove M0 if super <> S1
	DELETE t
	FROM tmpCustGroupLevelArchived t
		 INNER JOIN custdb.dbo.custinfo c WITH (NOLOCK) ON t.custid = c.custid
		 LEFT JOIN tmpCustGroupLevelArchived t1 WITH (NOLOCK) ON t1.custid = c.srecommend
	WHERE  t.Roleid = 3 AND t.GroupLevelName = 'M0' AND (t1.GroupLevelName <> 'S1' OR t1.GroupLevelName IS NULL)

	CREATE TABLE #M0NotInPreviousStage(CustID INT, srecommend INT)
	CREATE TABLE #Cust_ArchiveAccount_Master(CustID INT, StageID TINYINT)

	IF OBJECT_ID (N'Cust_ArchiveAccount', N'U') IS NOT NULL --check table is existing ?
	BEGIN
		INSERT INTO #Cust_ArchiveAccount_Master(CustID,StageID)
		SELECT CUSTID,StageID FROM CUSTDB.dbo.Cust_ArchiveAccount WITH(NOLOCK) WHERE roleid = 3
	END
	ELSE
	BEGIN
		INSERT INTO #Cust_ArchiveAccount_Master(CustID,StageID)
		SELECT CUSTID,StageID
		FROM CUSTDB.dbo.Cust_ArchiveAccount WITH(NOLOCK) 
		WHERE roleid = 3
	END

	--> Get M0 list who were not processed on Stage 1 yet
	IF @StageId <> 1
	BEGIN
		INSERT INTO #M0NotInPreviousStage(CustID,srecommend)
		SELECT ar.custid,ci.srecommend
		FROM dbo.tmpCustGroupLevelArchived ar WITH (NOLOCK)
			INNER JOIN custdb.dbo.custinfo ci WITH (NOLOCK)  ON ar.custid = ci.custid
			LEFT JOIN #Cust_ArchiveAccount_Master c WITH(NOLOCK) ON ar.custid = c.CustID AND c.StageID >= @StageId - 1
		WHERE ar.GroupLevelName = 'M0'
			AND c.CustID IS NULL

		IF EXISTS( SELECT TOP 1 1 FROM #M0NotInPreviousStage)
		BEGIN
			--Update S1(s)-->S2(s) if M0(s) were not processed on previous Stage yet
			UPDATE ar 
			SET ar.GroupLevelName = 'S2'
			FROM #M0NotInPreviousStage t
				INNER JOIN tmpCustGroupLevelArchived ar WITH(ROWLOCK) ON ar.custid = t.srecommend
		
			--Delete M0(s) if they were not processed on on previous Stage yet
			DELETE ar
			FROM #M0NotInPreviousStage t
				INNER JOIN tmpCustGroupLevelArchived ar WITH(ROWLOCK) ON ar.custid = t.CustID
		END
	END

	--Exlude dirrect Master from S3, S4
	CREATE TABLE #DirectMaster(CustID INT, srecommend INT)
	IF @StageId IN (3,4)
	BEGIN
		IF OBJECT_ID (N'CustDirectAccount', N'U') IS NOT NULL --check table is existing ?
		BEGIN
			INSERT INTO #DirectMaster(CustID,srecommend)
			SELECT d.CustID,ci.srecommend
			FROM custdb.dbo.CustDirectAccount d WITH(NOLOCK)
				INNER JOIN custdb.dbo.custinfo ci WITH(NOLOCK) ON d.CustID = ci.custid
			WHERE ci.roleid = 3
		END
		ELSE
		BEGIN
			INSERT INTO #DirectMaster(CustID,srecommend)
			SELECT d.CustID,ci.srecommend
			FROM CUSTDB.dbo.CustDirectAccount d WITH(NOLOCK)
				INNER JOIN custdb.dbo.custinfo ci WITH(NOLOCK) ON d.CustID = ci.custid
			WHERE ci.roleid = 3
		END

		--Update GroupLevelName = 'S2' if their downlines is direct master
		UPDATE ar 
		SET ar.GroupLevelName = 'S2'
		FROM #DirectMaster t
			INNER JOIN tmpCustGroupLevelArchived ar WITH(ROWLOCK) ON ar.custid = t.srecommend
		
		--Delete M0,M1
		DELETE ar
		FROM #DirectMaster t
			INNER JOIN tmpCustGroupLevelArchived ar WITH(ROWLOCK) ON ar.custid = t.CustID
	END
					 
	DROP TABLE #tmpMaster
	DROP TABLE #tmpSuper
	DROP TABLE #tmpMaster_DetectM0
	DROP TABLE #Super_Exception
	DROP TABLE #tmpSuper_M0
	DROP TABLE #M0NotInPreviousStage
	DROP TABLE #Cust_ArchiveAccount_Master
	DROP TABLE #DirectMaster
	
END
GO


