/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount2_DisableAgentLine_GenScript]
AS
/*
	Created by: Daniel
	Date: 2018-03-06
	Task: Archive Acc (New) - sp generate run list for stage 2 - backup data & disable+clear credit of whole agent line 
	DB: DBACC/bodb02
	Original: DBA_ArchiveAccount1_DisableAgentLine_GenScript

	Revisions:
		20180305@Daniel: clone fro old SP:
		 + Rename sp for stage No 2- start from 1 instead of 0

	20190327@Daniel: Add custom scan start date and use permanent preloaded tempCustID table

		
	Param's Explanation:
*/
IF (1 = 0)-- dummy code to trick ssis load result set
BEGIN 
	SELECT CONVERT(varchar(30), NULL) Super
	,CONVERT(varchar(30), NULL) Master
	,CONVERT(varchar(30), NULL) Agent
	,CONVERT(int, NULL) MemCnt
	,CONVERT(int, NULL) recommend
END

SET NOCOUNT ON

if NOT EXISTS(SELECT 1 FROM dbo.SystemSettings WITH(NOLOCK) WHERE VValue = 'Stage 2 - Done' AND VName = 'aa_Stmt_Status')
BEGIN
	raisError ('Statement data for this stage not loaded yet!', 16, 1)
	RETURN

END

DECLARE @startdate smalldatetime
SET @startdate = DATEADD(mm, - 4, GETDATE())

INSERT INTO bodb_report.dbo.tempCustID
SELECT custid
FROM bettrans with (NOLOCK)
WHERE bettype <> 20000 AND custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM translog with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bettransRNG with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bettransLC with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)


--update exception list
EXEC dbo.DBA_ArchiveAccount_UpdateException

--Get cust from s1
SELECT ag.recommend custid, isnull(MemCount, 0) [Member Count]
INTO #tmpAg
FROM bodb_report.dbo.tmpCustArchived ag WITH (NOLOCK)
	INNER JOIN custinfo agci WITH (NOLOCK) ON agci.custid = ag.recommend
	LEFT JOIN (
		SELECT recommend
			,COUNT(*) MemCount
		FROM custinfo mem WITH (NOLOCK)
		WHERE roleid = 1
		GROUP BY recommend
		) mem ON mem.recommend = agci.custid
WHERE ag.isFinished = 1
	AND isnull(MemCount, 0) > 0
	AND agci.closed = 1
	AND agci.enabled = 1
	AND ag.recommend NOT IN(SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM bodb_report.dbo.tempCustID tc
		INNER JOIN custinfo ci WITH (NOLOCK) ON tc.custid = ci.custid
		)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM customer c WITH (NOLOCK)
		WHERE --roleid = 1 AND
			creatdate >= @startdate
		)

--Get more other cust based on s2 condition
INSERT INTO #tmpAg
SELECT ag.custid, isnull(MemCount, 0) [Member Count]
FROM customer ag WITH (NOLOCK)
	INNER JOIN [site] s WITH (NOLOCK) ON ag.site = s.site AND s.isLicensee = 0
	INNER JOIN CustAgent ca WITH (NOLOCK) ON ag.custid = ca.custid
	INNER JOIN custinfo agci WITH (NOLOCK) ON agci.custid = ag.custid
	LEFT JOIN (
		SELECT recommend
			,COUNT(*) MemCount
		FROM custinfo mem WITH (NOLOCK)
		WHERE roleid = 1
		GROUP BY recommend
		) mem ON mem.recommend = agci.custid
WHERE ag.roleid = 2
	AND isnull(MemCount, 0) > 0
	AND (ag.creatdate < @startdate)
	AND agci.closed = 1
	AND agci.enabled = 1
	AND ca.isInternal = 0
	AND ag.srecommend NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH(NOLOCK))
	AND ag.custid NOT IN(SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM bodb_report.dbo.tempCustID tc
		INNER JOIN custinfo ci WITH (NOLOCK) ON tc.custid = ci.custid
		--WHERE ci.roleid = 1
		)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM customer c WITH (NOLOCK)
		WHERE --roleid = 1 AND
			creatdate >= @startdate
		)
	AND agci.custid NOT IN (SELECT recommend FROM bodb_report.dbo.tmpCustArchived)
		

SELECT sag.username Super
	,mag.username Master
	,ag.username Agent
	,[Member Count] MemCnt
	,ag.custid recommend
FROM customer ag WITH (NOLOCK)
	INNER JOIN #tmpAg t WITH (NOLOCK) ON ag.custid = t.custid
	INNER JOIN customer mag WITH (NOLOCK) ON ag.mrecommend = mag.custid AND mag.roleid = 3
	INNER JOIN customer sag WITH (NOLOCK) ON ag.srecommend = sag.custid AND sag.roleid = 4
ORDER BY [Member Count] DESC

DROP TABLE #tmpAg





