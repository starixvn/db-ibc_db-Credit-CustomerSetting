/*
	Created: 20170314@Helen
	Task: Check Status of DCS Products - [Redmine:N/A]
	
	Case 1: Super Disabled but Master Enabled
	Case 2: Master Disabled but Agent Enabled
	Case 1: Agent Disabled but Member Enabled
	
*/
SELECT *
INTO #ProductStatusProfile
FROM ProductStatusProfile PSP WITH (NOLOCK)

-------------PREPARATION: GET LIST SUPER/Master/Agent disabled FIRST----------------------------
CREATE TABLE #DCS_Super_Disabled (custID INT, bitmapOrder INT, IsDisabled BIT)
CREATE TABLE #DCS_Master_Disabled (custID INT, bitmapOrder INT, IsDisabled BIT)
CREATE TABLE #DCS_Agent_Disabled (custID INT, bitmapOrder INT, IsDisabled BIT)

INSERT INTO #DCS_Super_Disabled (custID,bitmapOrder,IsDisabled)
SELECT CPS.CustID,T.bitmapOrder,dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder)
FROM CustProductStatus CPS (NOLOCK)
	INNER JOIN custInfo CI (NOLOCK) ON CPS.CustID = CI.custid
	CROSS APPLY (SELECT bitmapOrder FROM #ProductStatusProfile)	AS T
WHERE CI.custid = 4 AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder) = 1
	AND ci.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND CI.Enabled = 1

INSERT INTO #DCS_Master_Disabled (custID,bitmapOrder,IsDisabled)
SELECT CPS.CustID,T.bitmapOrder,dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder)
FROM CustProductStatus CPS (NOLOCK)
	INNER JOIN custInfo CI (NOLOCK) ON CPS.CustID = CI.custid
	CROSS APPLY (SELECT bitmapOrder FROM #ProductStatusProfile)	AS T
WHERE CI.roleid = 3 AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder) = 1
	AND ci.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND CI.Enabled = 1
	
INSERT INTO #DCS_Agent_Disabled (custID,bitmapOrder,IsDisabled)
SELECT CPS.CustID,T.bitmapOrder,dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder)
FROM CustProductStatus CPS (NOLOCK)
	INNER JOIN custInfo CI (NOLOCK) ON CPS.CustID = CI.custid
	CROSS APPLY (SELECT bitmapOrder FROM #ProductStatusProfile)	AS T
WHERE CI.roleid = 2 AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,T.bitmapOrder) = 1
	AND ci.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND CI.Enabled = 1

----------------------------FINAL RESULT ------------------------------------
-- List of Master enable but super disabled
SELECT ci.custid AS MasterID,ci.srecommend, PSP.Sporttype,PSP.Bettype
FROM #DCS_Super_Disabled S
	INNER JOIN custInfo CI (NOLOCK) ON S.CustID = CI.srecommend AND CI.roleid = 3
	INNER JOIN CustProductStatus CPS WITH (NOLOCK) ON CI.custid = CPS.CustID 
	INNER JOIN #ProductStatusProfile PSP WITH (NOLOCK) ON S.bitmapOrder = PSP.bitmapOrder
WHERE CI.Enabled = 1
	AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,s.bitmapOrder) = 0

-- List of Agent enable but Master disabled
SELECT ci.custid AS AgentID, ci.mrecommend,ci.srecommend,PSP.Sporttype,PSP.Bettype
FROM #DCS_Master_Disabled m
	INNER JOIN custInfo CI (NOLOCK) ON m.CustID = CI.mrecommend AND CI.roleid = 2
	INNER JOIN CustProductStatus CPS WITH (NOLOCK) ON CI.custid = CPS.CustID 
	INNER JOIN #ProductStatusProfile PSP WITH (NOLOCK) ON M.bitmapOrder = PSP.bitmapOrder
WHERE CI.Enabled = 1
	AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,m.bitmapOrder) = 0
	
-- List of member enable but agent disabled
SELECT ci.custid AS MemberID,ci.recommend, ci.mrecommend,ci.srecommend, PSP.Sporttype,PSP.Bettype
FROM #DCS_Agent_Disabled a
	INNER JOIN custInfo CI (NOLOCK) ON a.CustID = CI.recommend AND CI.roleid = 1
	INNER JOIN CustProductStatus CPS WITH (NOLOCK) ON CI.custid = CPS.CustID 
	INNER JOIN #ProductStatusProfile PSP WITH (NOLOCK) ON A.bitmapOrder = PSP.bitmapOrder
WHERE CI.Enabled = 1
	AND dbo.f_GetProductStatus (cps.bitmapIsDisabled,a.bitmapOrder) = 0

/*

DROP TABLE #DCS_Agent_Disabled
DROP TABLE #DCS_Master_Disabled
DROP TABLE #DCS_Super_Disabled
DROP TABLE #ProductStatusProfile	

*/

	