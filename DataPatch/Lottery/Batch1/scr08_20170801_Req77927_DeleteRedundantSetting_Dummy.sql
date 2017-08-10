/*
	Created: Elodie
	Task: Delete redundant setting
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
USE CustDB
GO

PRINT N'Step 8: Start on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.';  

DECLARE @MaxCustID INT
	
SELECT @MaxCustID = xxx
	
CREATE TABLE #OfferedSite (site VARCHAR(10))
INSERT INTO #OfferedSite (site)
VALUES  ('755555'), ('Indo'), ('KORIBC'), ('733333'), ('222223'), ('222225'), ('222227')

CREATE TABLE #DummySupers (custid int)

INSERT INTO #DummySupers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid IN (2,3,4,5,12,13,15) -- dummy account
				          
CREATE TABLE #MemberTemp
(
	CustID INT PRIMARY KEY CLUSTERED
)

CREATE TABLE #SMATemp
(
	CustID INT PRIMARY KEY CLUSTERED,
	roleid TINYINT
)
	
CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT)			
--- get direct master
INSERT INTO #DirectMaster (CustID,roleid)
SELECT ci.custid, ci.roleid
FROM Customer ci with(nolock)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
	AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	AND ci.roleid=3 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND c.Enabled=1
		
--- get direct agent
INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
SELECT ci.custid, ci.mrecommend,ci.roleid
FROM Customer ci WITH(NOLOCK)
INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
	AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	and ci.roleid = 2 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND c.Enabled=1

INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
SELECT c.custid, c.recommend,c.mrecommend,c.roleid
FROM Customer c WITH(NOLOCK)
INNER JOIN Customer ca (nolock) on c.recommend=ca.custid 
INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid=c.custid
WHERE EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ca.site)
	AND EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
	AND c.roleid=1 AND ci.srecommend IN (SELECT custid FROM #DummySupers)
	AND ci.Enabled=1

----------- For SMA  -----------
INSERT INTO #SMATemp (CustID,RoleID)
-----------------------Master--------------------------------------
SELECT d.CustID, 3 -- Direct Master 
FROM #DirectMaster d 
WHERE d.CustID > @MaxCustID	
UNION 
SELECT DISTINCT d.mrecommend, 3 -- Master of direct agent
FROM #DirectAgent d
WHERE d.mrecommend > @MaxCustID
UNION 
SELECT DISTINCT d.mrecommend, 3 -- Master of direct member
FROM #DirectMember D 	
WHERE d.mrecommend > @MaxCustID
UNION 
-----------------------Agent--------------------------------------
SELECT ci.CustID,2 -- Agent of direct master
FROM custInfo ci WITH (NOLOCK)
	INNER JOIN #DirectMaster D ON ci.mrecommend = d.CustID 
WHERE ci.roleid = 2 AND ci.Enabled=1 AND ci.custid > @maxcustid 
UNION
SELECT DISTINCT d.recommend, 2 -- agent of direct member
FROM #DirectMember D 	
WHERE d.recommend > @MaxCustID
UNION 
SELECT d.CustID, 2 -- Direct Agent
FROM #DirectAgent D
WHERE d.CustID > @MaxCustID	
	 	
---------- For members ---------
INSERT INTO #MemberTemp (CustID)
SELECT  ci.custid -- member of direct master
FROM Custinfo ci WITH (NOLOCK)
	INNER JOIN #DirectMaster m ON ci.mrecommend = m.CustID
WHERE ci.roleid = 1	AND ci.custid > @maxcustid AND ci.Enabled = 1 			
UNION ALL -- member of direct agent
SELECT  ci.custid
FROM Custinfo ci WITH (NOLOCK)
	INNER JOIN #DirectAgent a ON ci.recommend = a.CustID
WHERE ci.roleid = 1 AND ci.custid > @maxcustid AND ci.Enabled = 1 			
-- Direct member		
UNION ALL
SELECT ci.custid
FROM #DirectMember ci
WHERE ci.CustID > @MaxCustID	

DELETE cg
FROM CustPTSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN #SMATemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220
						
DELETE cg
FROM CustPTSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
	INNER JOIN #MemberTemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220
		
DELETE cg
FROM CustPTGroupSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN #SMATemp c WITH (NOLOCK) ON cg.AgentID = c.custid
WHERE SportType = 220
				
DELETE cg
FROM CustBetSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN #SMATemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220

DELETE cg
FROM CustBetSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)
	INNER JOIN #MemberTemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220

DELETE cg
FROM CustWinLossLimit_Agent cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN #SMATemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220

DELETE cg
FROM CustWinLossLimit_Member cg WITH(UPDLOCK,ROWLOCK)
	INNER JOIN #MemberTemp c WITH (NOLOCK) ON cg.CustID = c.custid
WHERE SportType = 220

PRINT N'Step 8: End on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.'; 