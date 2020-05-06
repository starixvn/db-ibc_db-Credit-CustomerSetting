/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount1_CloseAgentLine_GenScript]
AS
/*
	Created: Daniel@20151116
	Task: Archive Acc - Gen script batch run sp for stage 0 - close agent
	DB: DBACC/bodb02
	Original: DBA_ArchiveAccount0_CloseAgent_GenScript

	Revisions:
		20180222@Daniel: cloned & renamed from old sp DBA_ArchiveAccount0_CloseAgent_GenScript, get masterID for send message to masters
		20190218@Daniel: use permanent temp table bodb_report.dbo.tempCustID instead, the table need to be prepared outside, this avoid sp timeout when exec via linked server

		
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

if NOT EXISTS(SELECT 1 FROM dbo.SystemSettings WITH(NOLOCK) WHERE VValue = 'Stage 1 - Done' AND VName = 'aa_Stmt_Status')
BEGIN
	raisError ('Statement data for this stage not loaded yet!', 16, 1)
	RETURN

END


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

SELECT ag.custid, isnull(MemCount, 0) [Member Count]
INTO #tmpAg
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
	AND (ag.creatdate < DATEADD(mm, -3, GETDATE()))
	AND agci.closed = 0 
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
			creatdate >= DATEADD(mm, -3, GETDATE())
		)
		


SELECT sag.username Super
	,mag.username Master
	,ag.username Agent
	,[Member Count] MemCnt
	--,[Trans Count]
	,ag.custid recommend
FROM customer ag WITH (NOLOCK)
	INNER JOIN #tmpAg t WITH (NOLOCK) ON ag.custid = t.custid
	INNER JOIN customer mag WITH (NOLOCK) ON ag.mrecommend = mag.custid AND mag.roleid = 3
	INNER JOIN customer sag WITH (NOLOCK) ON ag.srecommend = sag.custid AND sag.roleid = 4
ORDER BY [Member Count] DESC

DROP TABLE #tmpAg
