/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
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
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE dbo.tmpCustGroupLevelArchived

	DECLARE @query NVARCHAR(MAX) = ''
		, @ExecuteSQL NVARCHAR(MAX) = ''

	CREATE TABLE #tmpMaster (username VARCHAR(100), custid INT)
	CREATE TABLE #tmpSuper (username VARCHAR(100), custid INT)
	CREATE TABLE #Cust_ArchiveAcc_Exception (CustId INT)

	/*Get master from TmpCustArchived*/
	INSERT INTO #tmpMaster (username, custid)
	SELECT DISTINCT ag.username, ag.mrecommend
	FROM dbo.tmpCustArchived t WITH (NOLOCK)
		INNER JOIN Customer ag WITH (NOLOCK) ON ag.custid = t.recommend
	
	-- get all transid that not belong to any abnormal request
	SELECT  @query = N''		
	SELECT	@query = @query + N'SELECT custid FROM dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK)'
	SELECT	@ExecuteSQL = N'EXECUTE DBACC.bodb_report.dbo.sp_executesql @query'

	INSERT INTO #Cust_ArchiveAcc_Exception (CustID)
	EXECUTE	sys.sp_executesql @ExecuteSQL, N'@query NVARCHAR(MAX)', @query

	/*
		Count number of agents for each master
			- Count in TmpCustArchive
			- Count total in Custinfo, all conditions except for no tickets and no new member 
	*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT c.custid, c.roleid, @StageId
		,CASE WHEN mem.AgentCount = mem2.AgentCount THEN 'M1' ELSE 'M2' END AS GroupLevelName /*Match -> M1, Not Match -> M2*/
	FROM customer c WITH (NOLOCK)
		INNER JOIN #tmpMaster t ON t.custid = c.custid
		OUTER APPLY (
			SELECT COUNT(*) AgentCount
			FROM tmpCustArchived mem WITH (NOLOCK)
			WHERE mem.Master = t.username
		) mem
		OUTER APPLY (
			SELECT COUNT(*) AgentCount
			FROM customer ag WITH (NOLOCK)
				INNER JOIN [site] s WITH (NOLOCK) ON ag.site = s.site AND s.isLicensee = 0
				INNER JOIN CustAgent ca WITH (NOLOCK) ON ag.custid = ca.custid
				INNER JOIN custinfo agci WITH (NOLOCK) ON agci.custid = ag.custid
			WHERE ag.roleid = 2
				AND (ag.creatdate < DATEADD(mm, -3, GETDATE()))
				AND agci.closed = 0 
				AND agci.enabled = 1
				AND ca.isInternal = 0
				AND ag.srecommend NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH(NOLOCK))
				AND ag.custid NOT IN (SELECT custid FROM #Cust_ArchiveAcc_Exception) --change link server
				AND ag.mrecommend = t.custid
				AND agci.credit >= 0
		)mem2

	/*Detect S1, S2 from list M1*/
	INSERT INTO #tmpSuper (username, custid)
	SELECT DISTINCT username, srecommend
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN Customer c WITH (NOLOCK) ON c.custid = t.custid
	WHERE GroupLevelName = 'M1'

	
	INSERT INTO tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT c.custid, c.roleid, @StageId
		,CASE WHEN mem.AgentCount = mem2.AgentCount THEN 'S1' ELSE 'S2' END AS GroupLevelName /*Match -> S1, Not Match -> S2*/
	FROM customer c WITH (NOLOCK)
		INNER JOIN #tmpSuper t ON t.custid = c.custid
		OUTER APPLY (
			SELECT COUNT(*) AgentCount
			FROM tmpCustArchived mem WITH (NOLOCK)
			WHERE mem.Super = t.username
		) mem 
		OUTER APPLY (
			SELECT COUNT(*) AgentCount
			FROM customer ag WITH (NOLOCK)
				INNER JOIN [site] s WITH (NOLOCK) ON ag.site = s.site AND s.isLicensee = 0
				INNER JOIN CustAgent ca WITH (NOLOCK) ON ag.custid = ca.custid
				INNER JOIN custinfo agci WITH (NOLOCK) ON agci.custid = ag.custid
			WHERE ag.roleid = 2
				AND (ag.creatdate < DATEADD(mm, -3, GETDATE()))
				AND agci.closed = 0 
				AND agci.enabled = 1
				AND ca.isInternal = 0
				AND ag.srecommend NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH(NOLOCK))
				AND ag.custid NOT IN(SELECT custid FROM #Cust_ArchiveAcc_Exception)
				AND ag.srecommend = t.custid
				AND agci.credit >= 0
		)mem2

	/*Get list Super from list M2 into S3*/
	INSERT INTO dbo.tmpCustGroupLevelArchived (custid, Roleid, GroupLevelName, StageID)
	SELECT DISTINCT srecommend, c.roleid, 'S3', @StageId
	FROM dbo.tmpCustGroupLevelArchived t WITH (NOLOCK)
		INNER JOIN dbo.Customer c WITH (NOLOCK) ON c.custid =  t.custid
	WHERE GroupLevelName = 'M2'
		AND srecommend NOT IN (SELECT custid FROM #tmpSuper)

	DROP TABLE #tmpMaster
	DROP TABLE #tmpSuper
	DROP TABLE #Cust_ArchiveAcc_Exception

END
GO

