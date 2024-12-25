/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount3_GenScript]
AS
/*
	Created: 20160117@Daniel
	Task: Archive Acc - Gen script batch run sp for stage 3 - Clear members balance under disable agents & delete cust setting (7 months)
	DB: DBACC/bodb02
	Original:

	Revisions:
		- 20180305@Daniel: clone from old SP: DBA_ArchiveAccount2_GenScript
			+ rename SP to count stage from 1 => No. 3 for this stage
		- 20200505@Max: Archiving credit accounts process for Master & Agent levels [Redmine: #130032]
		- 20200807@Helen: Remove hardcode supers (allow negative given credit for members) since fixed already in Alpha Site [Redmine: #130032]
		- 20200911@Helen: Archive member & agent & master, disable super, reduce credit of master, super - Phase 2 - [Redmine:130032]
		- 20210302@Eden: Just process Agent on stage 3 when they processed successfully on stage 2  [RedmineID: #149262]
		- 20210825@Eden: Exclude Direct Masters/Agents/Members from Archiving Credit Account process (Stage 3 and Stage 4) [RedmineID: #160690]
		- 20211209@Eden: Split transfer out of bettrans [RedmineID: #162264]
		- 20220505@Eden: Exclude internal usage account from Archiving credit accounts process [#RM:172372]
		- 20240905@Eden : Scale out DBCUST [redmine: #210077]
		- 20241225@Eden: Archiving for Reward Wallet [RedmineID: #215534]
		
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

if NOT EXISTS(SELECT 1 FROM dbo.SystemSettings WITH(NOLOCK) WHERE VValue = 'Stage 3 - Done' AND VName = 'aa_Stmt_Status')
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
UNION
SELECT custid
FROM SabaWalletTicket with (NOLOCK) WHERE custid NOT IN(select custid from bodb_report.dbo.tempCustID)
	AND WinlostDate >= CONVERT(DATE,DATEADD(mm,-2,GETDATE()))

--update exception list
EXEC dbo.DBA_ArchiveAccount_UpdateException

SELECT ag.custid, isnull(MemCount, 0) [Member Count]
--, isnull(TransCount, 0) [Trans Count]
INTO #tmpAg
FROM customer ag WITH (NOLOCK)
	INNER JOIN bodb_report.dbo.tmpCustArchived tmp WITH (NOLOCK) ON ag.custid = tmp.recommend AND tmp.IsFinished = 1 AND (ISNULL(tmp.ErrMsg,'') = '' OR tmp.ErrMsg LIKE '%archived%')
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
	--LEFT JOIN (
	--	SELECT recommend
	--		,COUNT(*) TransCount
	--	FROM bettrans b WITH (NOLOCK)
	--	WHERE custid <> recommend
	--	GROUP BY recommend
	--	) b ON b.recommend = agci.custid
WHERE ag.roleid = 2
	--AND isnull(MemCount, 0) > 0-- AND isnull(TransCount, 0) > 0
	AND (ag.creatdate < DATEADD(mm, -7, GETDATE()))
	AND agci.enabled = 0
	AND ca.isInternal = 0
	AND ag.srecommend NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH(NOLOCK))
	AND ag.srecommend NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND ag.mrecommend NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND ag.custid NOT IN (SELECT custid FROM bodb_report.dbo.Task_Cust_ArchiveAcc_Exception WITH(NOLOCK))
	AND ag.custid NOT IN(SELECT recommend FROM #Exclude_Agents)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM bodb_report.dbo.tempCustID tc
		INNER JOIN custinfo ci WITH (NOLOCK) ON tc.custid = ci.custid
		--WHERE ci.roleid = 1
		)
	AND agci.custid NOT IN (
		SELECT DISTINCT recommend
		FROM customer c WITH (NOLOCK)
		WHERE roleid IN(1,2)
			AND creatdate >= DATEADD(mm, -7, GETDATE())
		)
	
SELECT sag.username Super
	,mag.username Master
	,ag.username Agent
	,[Member Count] MemCnt
	/*,[Trans Count]
	,'Exec DBA_ArchiveAccount2_ClearBalance ''' + ag.username +''' WAITFOR DELAY ''000:00:00.200''' SPCommand
	,'Exec DBA_ArchiveAccount2_DelCustSetting ''' + ag.username +''' WAITFOR DELAY ''000:00:00.200'' ;GO' SPCommand2*/
	,ag.custid recommend
FROM customer ag WITH (NOLOCK)
	INNER JOIN #tmpAg t WITH (NOLOCK) ON ag.custid = t.custid
	INNER JOIN customer mag WITH (NOLOCK) ON ag.mrecommend = mag.custid AND mag.roleid = 3
	INNER JOIN customer sag WITH (NOLOCK) ON ag.srecommend = sag.custid AND sag.roleid = 4
ORDER BY [Member Count] DESC

DROP TABLE #tmpAg
DROP TABLE #Exclude_Agents