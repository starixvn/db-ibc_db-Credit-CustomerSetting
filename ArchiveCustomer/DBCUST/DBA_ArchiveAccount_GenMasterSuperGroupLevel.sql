/*<info serverAlias="DBCUST-CustDB,DBTXN-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_GenMasterSuperGroupLevel]
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
		
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE dbo.tmpCustGroupLevelArchived

	DECLARE @query NVARCHAR(MAX) = ''
		, @ExecuteSQL NVARCHAR(MAX) = ''

	CREATE TABLE #tmpMaster (username VARCHAR(100), custid INT)
	CREATE TABLE #tmpSuper (custid INT, MasterArchivedCount INT)
	CREATE TABLE #tmpMaster_DetectM0 (custid INT, srecommend INT)
	
	/*Get master from TmpCustArchived*/
	INSERT INTO #tmpMaster (username, custid)
	SELECT DISTINCT m.username, ag.mrecommend
	FROM dbo.tmpCustArchived t WITH (NOLOCK)
		INNER JOIN dbo.Customer ag WITH (NOLOCK) ON ag.custid = t.recommend
		INNER JOIN dbo.Customer m WITH (NOLOCK) ON m.custid = ag.mrecommend
	WHERE ISNULL(t.ErrMsg,'') = ''

	/*
		Count number of agents for each master
			- Count in TmpCustArchive
			- Count total in Custinfo, all conditions except for no tickets and no new member 
	*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT c.custid, c.roleid
		,CASE WHEN mem.AgentCount = mem2.AgentCount THEN 'M1' ELSE 'M2' END AS GroupLevelName /*Match -> M1, Not Match -> M2*/
		,@StageId
	FROM customer c WITH (NOLOCK)
		INNER JOIN #tmpMaster t ON t.custid = c.custid
		OUTER APPLY (
			SELECT COUNT(1) AgentCount
			FROM tmpCustArchived mem WITH (NOLOCK)
			WHERE mem.Master = t.username
		) mem
		OUTER APPLY (
			SELECT COUNT(1) AgentCount
			FROM customer ag WITH (NOLOCK)
			WHERE ag.roleid = 2
				AND ag.mrecommend = t.custid
		)mem2

	/*Detect S1, S2 from list M1*/
	INSERT INTO #tmpSuper (custid, MasterArchivedCount)
	SELECT c.srecommend, ISNULL(COUNT(t.custid),0)
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN dbo.Customer c WITH (NOLOCK) ON c.custid = t.custid
	WHERE GroupLevelName = 'M1'
	GROUP BY c.srecommend
	
	DECLARE @DDiff DATETIME
	SELECT @DDiff = DATEADD(mm, -7, GETDATE())
	SELECT @DDiff = DATEADD(week, -2, @DDiff)

	INSERT INTO #tmpMaster_DetectM0 (custid,srecommend)
	SELECT c.custid,s.custid 
	FROM #tmpSuper s
		INNER JOIN dbo.customer c WITH (NOLOCK) ON s.custid = c.srecommend
		OUTER APPLY (SELECT TOP 1 1 AS MO_total
					FROM dbo.customer c1 WITH (NOLOCK)
					WHERE c.custid = c1.mrecommend AND c1.roleid = 1
						
					) AS M0
	WHERE c.roleid = 3 AND M0.MO_total IS NULL 
		AND 1 = CASE WHEN @StageId = 1 AND c.creatdate < DATEADD(mm, -3, GETDATE()) THEN 1
						 WHEN @StageId = 2 AND c.creatdate < DATEADD(mm, - 4, GETDATE()) THEN 1
						 WHEN @StageId = 3 AND c.creatdate < DATEADD(mm, -7, GETDATE()) THEN 1
						 WHEN @StageId = 4 AND c.creatdate < @DDiff THEN 1
						 ELSE 0
					END	 
	
	INSERT INTO tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT c.custid, c.roleid
		,CASE WHEN m.MasterCount = (ISNULL(t.MasterArchivedCount,0) + ISNULL(m0.MasterCount_M0,0)) THEN 'S1' ELSE 'S2' END AS GroupLevelName /*Match -> S1, Not Match -> S2*/
		,@StageId
	FROM customer c WITH (NOLOCK)
		INNER JOIN #tmpSuper t ON t.custid = c.custid
		OUTER APPLY (
			SELECT COUNT(1) MasterCount
			FROM customer WITH (NOLOCK)
			WHERE roleid = 3
				AND srecommend = t.custid
		)m
	   OUTER APPLY (
			SELECT COUNT(1) MasterCount_M0
			FROM #tmpMaster_DetectM0 t1 WITH (NOLOCK)
			WHERE t1.srecommend = t.custid
		)m0		
	
	/*Get list Super from list M2 into S3*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT srecommend, 4, 'S3', @StageId
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN dbo.Customer c WITH (NOLOCK) ON c.custid =  t.custid
	WHERE GroupLevelName = 'M2'
		AND srecommend NOT IN (SELECT custid FROM #tmpSuper)
	-- Remove A0 (tmpCustArchived) if NOT M1
	DELETE t
	FROM tmpCustArchived t WITH (NOLOCK)
		INNER JOIN dbo.customer c WITH (NOLOCK) ON t.Master = c.username
		INNER JOIN tmpCustGroupLevelArchived ar WITH (NOLOCK) ON ar.custid = c.custid 
		OUTER APPLY (
			SELECT COUNT(1) MemCount
			FROM custinfo ci WITH (NOLOCK)
			WHERE ci.roleid = 1 AND ci.recommend = t.recommend
			)AS tmp
	WHERE ISNULL(tmp.MemCount,0) = 0 AND ar.GroupLevelName NOT IN ('M1')
	
	-- INSERT M0 IF S1
	INSERT INTO tmpCustGroupLevelArchived (custid, roleid, GroupLevelName, StageID)
	SELECT t.custid, 3, 'M0',@StageId
	FROM #tmpMaster_DetectM0 t	
		INNER JOIN dbo.tmpCustGroupLevelArchived a WITH (NOLOCK) ON t.srecommend = a.custid 
	WHERE a.roleid = 4 AND a.GroupLevelName = 'S1'	
	
	-- Master have no downline, its Super not in list processing
	CREATE TABLE #Super_Exception (srecommend INT)
	INSERT INTO #Super_Exception (srecommend)
	SELECT DISTINCT ci.srecommend		
	FROM CustGroupHeadline gl (nolock)		
		INNER JOIN Customer ci (nolock) ON gl.CustID = ci.custid		
	WHERE GroupID > 0 and ci.roleid in (1,2,3,4)
	UNION
	SELECT DISTINCT ag.custid
	FROM phonebettingCustomerList p WITH(NOLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON p.username = c.username
		INNER JOIN custinfo ag WITH(NOLOCK) ON ag.custid = c.srecommend
	
	INSERT INTO tmpCustGroupLevelArchived (custid, roleid, GroupLevelName, StageID)	
	SELECT ma.custid, 3, 'M0', @StageId
	FROM customer ma WITH (NOLOCK)
		INNER JOIN custinfo agci WITH (NOLOCK) ON agci.custid = ma.custid
		OUTER APPLY (
			SELECT TOP 1 recommend
			FROM custinfo mem WITH (NOLOCK)
			WHERE roleid = 2 AND mem.mrecommend = ma.custid
			) AS Downline
		LEFT JOIN #Super_Exception se ON se.srecommend = ma.srecommend
		LEFT JOIN #tmpSuper st ON st.custid = ma.srecommend
		LEFT JOIN tmpCustGroupLevelArchived ar WITH (NOLOCK) ON ar.custid = ma.custid
	WHERE ma.roleid = 3
		AND Downline.recommend IS NULL
		AND st.custid IS NULL
		AND ma.srecommend NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH(NOLOCK))
		AND se.srecommend IS NULL
		AND ar.custid IS NULL
		AND 1 = CASE WHEN @StageId = 1 AND ma.creatdate < DATEADD(mm, -3, GETDATE()) THEN 1
						 WHEN @StageId = 2 AND ma.creatdate < DATEADD(mm, - 4, GETDATE()) THEN 1
						 WHEN @StageId = 3 AND ma.creatdate < DATEADD(mm, -7, GETDATE()) THEN 1
						 WHEN @StageId = 4 AND ma.creatdate < @DDiff THEN 1
						 ELSE 0
					END	
					
					 
	DROP TABLE #tmpMaster
	DROP TABLE #tmpSuper
	DROP TABLE #tmpMaster_DetectM0
	DROP TABLE #Super_Exception
	
END
GO

