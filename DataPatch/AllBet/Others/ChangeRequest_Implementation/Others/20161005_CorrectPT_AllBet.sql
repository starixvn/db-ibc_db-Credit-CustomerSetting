CREATE TABLE #supers (custid int)

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND ci.site in ('733333','222223')
		AND ci.custid <> 72
	)
	OR ci.custid IN 
		(
			-- dummy account
			2,3,5,12,13
			-- cross site
			/* 
			1. super no, master yes, agent yes(1266057,900371,4204225,674248,877004,6032879)
			2. Super yes, master yes, agent no: 796555, 5005322		
			*/
			,1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322 
		)

UPDATE cs
	SET MasterPT = SuperPT, AgentPT = SuperPT
FROM CustPTSetting3rd_Agent cs WITH (ROWLOCK,UPDLOCK)
INNER JOIN #supers ci WITH (NOLOCK) ON cs.CustID = ci.custid
WHERE SportType = 211 
