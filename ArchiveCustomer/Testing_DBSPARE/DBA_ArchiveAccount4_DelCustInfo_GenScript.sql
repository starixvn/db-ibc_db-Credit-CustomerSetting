/*<info serverAlias="DBSPARE-custdb" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount4_DelCustInfo_GenScript]
AS
/*
	Created: 20160117@Daniel
	Task: Archive Acc - Gen script batch run sp for stage 3 - delete cust info (7 months)
	DB: DBACC/bodb02
	Original:

	Revisions:
		- 20180320@Daniel: rename SP to count stage from 1 => No. 4 for this stage
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
	
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

if NOT EXISTS(SELECT 1 FROM dbo.SystemSettings WITH(NOLOCK) WHERE VValue = 'Stage 4 - Done' AND VName = 'aa_Stmt_Status')
BEGIN
	raisError ('Statement data for this stage not loaded yet!', 16, 1)
	RETURN

END

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

UNION  SELECT	1584511	--SMON
UNION  SELECT	17131340	--	RG2
UNION  SELECT	20505414	--	HG81
UNION  SELECT	31381376	--	L1
UNION  SELECT	31890071	--	RG33
UNION  SELECT	32506252	--	RG37
UNION  SELECT	32546605	--	AMH5
UNION  SELECT	34176539	--	KW19
UNION  SELECT	39428597	--	RG81
UNION  SELECT	40906204	--	RG83
UNION  SELECT	859594	--	S99H
UNION  SELECT	2953285	--	HPV
UNION  SELECT	5044097	--	HPMM
UNION  SELECT	18119949	--	A3
UNION  SELECT	25256329	--	S99BE
UNION  SELECT	26979533	--	B60T
UNION  SELECT	28182257	--	JYZ
UNION  SELECT	28969062	--	B59T
UNION  SELECT	1687347	--	S222TH
UNION  SELECT	29680156	--	B62T
UNION  SELECT	39583203	--	B70T
UNION  SELECT	39583632	--	B65T
UNION  SELECT	1528414	--	B6T
UNION  SELECT	1538175	--	B14T
UNION  SELECT	20060537	--	SSD72
UNION  SELECT	16731414	--	CG34
UNION  SELECT	31556024	--	QZ9Q
UNION  SELECT	21127993	--	DT25
UNION  SELECT	2198456	--	TV71
UNION  SELECT	5362687	--	BC9
UNION  SELECT	25174645	--	TVA9C
UNION  SELECT	22765105	--	MBO
UNION  SELECT	5453438	--	K9
UNION  SELECT	9735627	--	S6KW
UNION  SELECT	24400636--	S68H
UNION  SELECT 	14182461--	supertest3 
UNION  SELECT 	1176070	--	SuperTest1

DECLARE @DDiff DATETIME

SELECT @DDiff = DATEADD(mm, -7, GETDATE())

SELECT @DDiff = DATEADD(week, -2, @DDiff)

INSERT INTO bodb_report.dbo.tempCustID
SELECT custid
FROM bodb02.dbo.bettrans with (NOLOCK)
WHERE bettype <> 20000 AND custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bodb02.dbo.translog with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bodb02.dbo.bettransRNG with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bodb02.dbo.bettransLC with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)

--update exception list
EXEC dbo.DBA_ArchiveAccount_UpdateException


--Get cust from s3
SELECT ag.recommend custid, isnull(MemCount, 0) [Member Count], isnull(TransCount, 0) [Trans Count]
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
	LEFT JOIN (
		SELECT recommend
			,COUNT(*) TransCount
		FROM bettrans b WITH (NOLOCK)
		WHERE custid <> recommend
		GROUP BY recommend
		) b ON b.recommend = agci.custid	
	LEFT JOIN #Super_Exception se ON se.srecommend = agci.srecommend
WHERE ag.isFinished = 1
	AND isnull(MemCount, 0) > 0 AND isnull(TransCount, 0) = 0
	AND agci.enabled = 0
	AND ag.recommend NOT IN(SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
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
			creatdate >= @DDiff
		)
	AND se.srecommend IS NULL
	


--Get more other cust based on s4 condition
INSERT INTO #tmpAg
SELECT ag.custid, isnull(MemCount, 0) [Member Count], isnull(TransCount, 0) [Trans Count]
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
	LEFT JOIN (
		SELECT recommend
			,COUNT(*) TransCount
		FROM bettrans b WITH (NOLOCK)
		WHERE custid <> recommend
		GROUP BY recommend
		) b ON b.recommend = agci.custid	
	LEFT JOIN #Super_Exception se ON se.srecommend = agci.srecommend
WHERE ag.roleid = 2
	AND isnull(MemCount, 0) > 0 AND isnull(TransCount, 0) = 0
	AND (ag.creatdate < @DDiff)
	AND agci.enabled = 0
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
			creatdate >= @DDiff
		)
	AND agci.custid NOT IN (SELECT recommend FROM bodb_report.dbo.tmpCustArchived)
	AND se.srecommend IS NULL
	
		

SELECT sag.username Super
	,mag.username Master
	,ag.username Agent
	,[Member Count] MemCnt
	--,[Trans Count]
	,ag.custid recommend
	--,'Exec [DBA_ArchiveAccount3_DelCustInfo] ''' + ag.username +''' WAITFOR DELAY ''000:00:00.200''' SPCommand
FROM customer ag WITH (NOLOCK)
	INNER JOIN #tmpAg t WITH (NOLOCK) ON ag.custid = t.custid
	INNER JOIN customer mag WITH (NOLOCK) ON ag.mrecommend = mag.custid AND mag.roleid = 3
	INNER JOIN customer sag WITH (NOLOCK) ON ag.srecommend = sag.custid AND sag.roleid = 4
ORDER BY [Member Count] DESC

DROP TABLE #tmpAg
DROP TABLE #Super_Exception
