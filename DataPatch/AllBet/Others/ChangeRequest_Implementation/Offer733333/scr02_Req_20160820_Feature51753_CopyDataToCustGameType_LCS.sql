/*
	Created: Helen
	Date: 20160824
	Task: prepare data for tmpCustGameType
	DB: DBCUST/06/TP/MNL.bodb02	
*/ 

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'CustGameType_LCS' and type = 'u')
    DROP TABLE CustGameType_LCS
GO  

CREATE TABLE CustGameType_LCS(CustID INT PRIMARY KEY, StakeLevelList_LC VARCHAR(100))

GO


CREATE TABLE #supers (custid int)

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND ci.site in ('733333','222223')
		AND ci.custid <> 72)
		OR ci.custid IN 
		(
			-- dummy account
			2,3,5,12,13
			-- cross site
			,1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322 
		)
		
		
INSERT INTO CustGameType_LCS (CustID,StakeLevelList_LC)
SELECT C.Custid, CGT.StakeLevelList
FROM tmpCustGameType_LCS CGT WITH (NOLOCK)
	INNER JOIN Customer C (NOLOCK) ON CGT.CustID = C.custid 
	INNER JOIN #supers s (nolock) on c.srecommend = s.custid	

DROP TABLE #supers

