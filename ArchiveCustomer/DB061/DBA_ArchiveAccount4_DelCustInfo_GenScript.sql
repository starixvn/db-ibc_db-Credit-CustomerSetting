/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount4_DelCustInfo_GenScript]
AS
/*
	Created: 20160117@Daniel
	Task: Archive Acc - Gen script batch run sp for stage 3 - delete cust info (7 months)
	DB: DBACC/bodb02
	Original:

	Revisions:
		- 20180320@Daniel: rename SP to count stage from 1 => No. 4 for this stage
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
		- 20200807@Helen: Remove hardcode supers (allow negative given credit for members) since fixed already in Alpha Site [Redmine: #130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20201210@Eden: Alpha Site | Implement Dormant Account List [RedmineID: #144903]
		- 20210128@Winfred: Check exists bettype 20000 in bettrans [RedmineID: #149262]
		- 20210225@Winfred: Check exists bettype 20000 and matchid = 0 ( use clustered index ) in bettrans [RedmineID: #149262]
		- 20210302@Eden: Just process Agent on stage 4 when they processed successfully on stage 3  [RedmineID: #149262]
		- 20210825@Eden: Exclude Direct Masters/Agents/Members from Archiving Credit Account process (Stage 3 and Stage 4) [RedmineID: #160690]
		- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
		- 20220505@Eden: Exclude internal usage account from Archiving credit accounts process [#RM:172372]
		- 20240905@Eden : Scale out DBCUST [redmine: #210077]

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

CREATE TABLE #Exclude_Agents(recommend INT PRIMARY KEY)

--Exclude Direct and Dummy agents
INSERT INTO #Exclude_Agents(recommend)
SELECT DISTINCT ci.recommend
FROM CustDirectAccount d WITH(NOLOCK)
	INNER JOIN custinfo ci WITH(NOLOCK) ON d.CustID = ci.custid
WHERE ci.roleid IN (1,2)

DECLARE @DDiff DATETIME

SELECT @DDiff = DATEADD(mm, -7, GETDATE())

SELECT @DDiff = DATEADD(week, -2, @DDiff)

INSERT INTO bodb_report.dbo.tempCustID
SELECT custid
FROM transfer with (NOLOCK)
WHERE bettype <> 20000 AND custid NOT IN(select custid from bodb_report.dbo.tempCustID)
UNION
SELECT custid
FROM bettrans with (NOLOCK)
WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
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


--Get cust from s3
SELECT ag.recommend custid, isnull(MemCount, 0) [Member Count]
--, isnull(TransCount, 0) [Trans Count]
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
	--LEFT JOIN (
	--	SELECT recommend
	--		,COUNT(*) TransCount
	--	FROM bettrans b WITH (NOLOCK)
	--	WHERE custid <> recommend
	--	GROUP BY recommend
	--	) b ON b.recommend = agci.custid	
WHERE ag.isFinished = 1
	--AND isnull(MemCount, 0) > 0 
	--AND isnull(TransCount, 0) = 0
	AND agci.enabled = 0
	AND agci.srecommend NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND agci.mrecommend NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND agci.custid NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND ag.recommend NOT IN(SELECT recommend FROM #Exclude_Agents)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM bodb_report.dbo.tempCustID tc
		INNER JOIN custinfo ci WITH (NOLOCK) ON tc.custid = ci.custid
		--WHERE ci.roleid = 1
		)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM customer c WITH (NOLOCK)
		WHERE  roleid IN (1,2)
			AND creatdate >= @DDiff
		)
	AND ag.IsFinished = 1 AND (ISNULL(ag.ErrMsg,'') = '' OR ag.ErrMsg LIKE '%archived%')

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
	LEFT JOIN  dbo.transfer bt WITH(NOLOCK) ON ag.custid = bt.custid  AND bt.bettype = 20000
WHERE bt.custid IS NULL	
ORDER BY [Member Count] DESC

DROP TABLE #tmpAg
DROP TABLE #Exclude_Agents