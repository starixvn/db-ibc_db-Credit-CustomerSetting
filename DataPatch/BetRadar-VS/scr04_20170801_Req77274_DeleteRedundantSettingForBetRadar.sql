/*
	Created: Elodie
	Task: Delete redundant setting
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
USE CustDB
GO

DECLARE @MaxCustID INT
	
SELECT @MaxCustID = xxx
	
CREATE TABLE #supers (custid int)

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
			AND ci.username NOT LIKE '3rdSuper%'
			AND cs.isinternal = 0
			AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
			AND s.islicensee = 0

DELETE cg
FROM CustPTSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN Customer c WITH (NOLOCK) ON cg.CustID = c.custid
	INNER JOIN #supers s ON c.srecommend = s.custid	
WHERE (SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191)
	AND cg.custid > @maxcustID
						
DELETE cg
FROM CustPTSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
	INNER JOIN Customer c WITH (NOLOCK) ON cg.CustID = c.custid
	INNER JOIN #supers s ON c.srecommend = s.custid	
WHERE (SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191)
	AND cg.custid > @maxcustID
		
DELETE cg
FROM CustPTGroupSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN Customer c WITH (NOLOCK) ON cg.AgentID = c.custid
	INNER JOIN #supers s ON c.srecommend = s.custid		
WHERE (SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191)
	AND c.custid > @maxcustID
				
DELETE cg
FROM CustBetSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)	
	INNER JOIN Customer c WITH (NOLOCK) ON cg.CustID = c.custid
	INNER JOIN #supers s ON c.srecommend = s.custid		
WHERE (SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199)
	AND cg.custid > @maxcustID

DELETE cg
FROM CustBetSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)
	INNER JOIN Customer c WITH (NOLOCK) ON cg.CustID = c.custid
	INNER JOIN #supers s ON c.srecommend = s.custid			
WHERE (SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199)
	AND cg.custid > @maxcustID

	