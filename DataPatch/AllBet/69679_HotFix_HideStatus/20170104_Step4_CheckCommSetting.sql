/*
	Created: 20170104@Elodie
	Task: Check Comm rule of AllBet
	DB: DBCUST/CustDB
*/
USE CustDB
GO

DROP TABLE #MemberComm
DROP TABLE #AgentComm
DROP TABLE #MasterComm
DROP TABLE #SuperComm
DROP TABLE #CheckCommResult_Credit

CREATE TABLE #CheckCommResult_Credit(
	[RuleId] [smallint] NULL,
	[SportType] [smallint] NULL,
	[BetType] [smallint] NULL,
	[CustIdA] [int] NULL,
	[CustIdB] [int] NULL,
	[ValueA] [smallmoney] NULL,
	[ValueB] [smallmoney] NULL,
	[CreatedDate] [datetime] NULL
)

GO
ALTER TABLE #CheckCommResult_Credit ADD  CONSTRAINT [DF_CheckCommRule_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
	
CREATE TABLE #supers (custid int)
	
INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH(NOLOCK)
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE (ci.roleid = 4  
	AND ci.username NOT LIKE '3rdSuper%'
	AND cs.isinternal = 0
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND s.islicensee = 0)

DECLARE @SportType SMALLINT = 211
	
SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.SuperDiscount, cs.MasterDiscount, cs.AgentDiscount, cs.PlayerDiscount
INTO #MemberComm
FROM CheckCustDB.dbo.CustInfo ci
	INNER JOIN CheckCustDB.dbo.CustDiscount3rd_Member cs WITH (NOLOCK) ON ci.CustID = cs.CustID
	INNER JOIN CheckCustDB.dbo.CustProductStatus stt WITH (NOLOCK) ON ci.CustID = stt.CustID
	LEFT JOIN CheckCustDB.dbo.ProductStatusProfile prf WITH(NOLOCK) ON prf.Sporttype = cs.sporttype AND prf.bettype = cs.bettype
WHERE ci.srecommend IN (SELECT Custid FROM #supers)
		AND ci.roleid = 1  
		AND ci.Enabled = 1      
		AND ci.Currency NOT IN (20,27,28)     
		AND cs.SportType = CASE WHEN @SportType = 0 then cs.SportType  ELSE @SportType END 
		AND (
				ISNULL(bitmapOrder,0) < 5 --From VB onwards
				OR 
				CASE substring(bitmapHasSynced, 1+((bitmapOrder-1)/8), 1) & POWER(2, (bitmapOrder-1)%8) WHEN 0 THEN 0 ELSE 1 END = 1		 
			)
	
SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.Discount
INTO #AgentComm
FROM CheckCustDB.dbo.CustInfo ci
	INNER JOIN CheckCustDB.dbo.CustDiscount3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
	INNER JOIN CheckCustDB.dbo.CustProductStatus stt WITH (NOLOCK) ON ci.CustID = stt.CustID
	LEFT JOIN CheckCustDB.dbo.ProductStatusProfile prf WITH(NOLOCK) ON prf.Sporttype = cs.sporttype AND prf.bettype = cs.bettype
WHERE ci.srecommend IN (SELECT Custid FROM #supers)
		AND ci.roleid = 2  
		AND ci.Enabled = 1      
		AND ci.Currency NOT IN (20,27,28)     
		AND cs.SportType = CASE WHEN @SportType = 0 then cs.SportType  ELSE @SportType END 
		AND (
				ISNULL(bitmapOrder,0) < 5 --From VB onwards
				OR 
				CASE substring(bitmapHasSynced, 1+((bitmapOrder-1)/8), 1) & POWER(2, (bitmapOrder-1)%8) WHEN 0 THEN 0 ELSE 1 END = 1		 
			)
			
SELECT cs.CustID,ci.recommend,ci.mrecommend,ci.srecommend, cs.SportType,cs.BetType,cs.Discount
INTO #MasterComm
FROM CheckCustDB.dbo.CustInfo ci
	INNER JOIN CheckCustDB.dbo.CustDiscount3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
	INNER JOIN CheckCustDB.dbo.CustProductStatus stt WITH (NOLOCK) ON ci.CustID = stt.CustID
	LEFT JOIN CheckCustDB.dbo.ProductStatusProfile prf WITH(NOLOCK) ON prf.Sporttype = cs.sporttype AND prf.bettype = cs.bettype
WHERE ci.srecommend IN (SELECT Custid FROM #supers)
		AND ci.roleid = 3  
		AND ci.Enabled = 1      
		AND ci.Currency NOT IN (20,27,28)     
		AND cs.SportType = CASE WHEN @SportType = 0 then cs.SportType  ELSE @SportType END 
		AND (
				ISNULL(bitmapOrder,0) < 5 --From VB onwards
				OR 
				CASE substring(bitmapHasSynced, 1+((bitmapOrder-1)/8), 1) & POWER(2, (bitmapOrder-1)%8) WHEN 0 THEN 0 ELSE 1 END = 1		 
			)
	
SELECT cs.CustID, cs.SportType,cs.BetType,cs.Discount
INTO #SuperComm
FROM CheckCustDB.dbo.CustInfo ci
	INNER JOIN CheckCustDB.dbo.CustDiscount3rd_Agent cs WITH (NOLOCK) ON ci.CustID = cs.CustID
	INNER JOIN CheckCustDB.dbo.CustProductStatus stt WITH (NOLOCK) ON ci.CustID = stt.CustID
	LEFT JOIN CheckCustDB.dbo.ProductStatusProfile prf WITH(NOLOCK) ON prf.Sporttype = cs.sporttype AND prf.bettype = cs.bettype
WHERE ci.srecommend IN (SELECT Custid FROM #supers)
		AND ci.roleid = 4  
		AND ci.Enabled = 1      
		AND ci.Currency NOT IN (20,27,28)     
		AND cs.SportType = CASE WHEN @SportType = 0 then cs.SportType  ELSE @SportType END 
		AND (
				ISNULL(bitmapOrder,0) < 5 --From VB onwards
				OR 
				CASE substring(bitmapHasSynced, 1+((bitmapOrder-1)/8), 1) & POWER(2, (bitmapOrder-1)%8) WHEN 0 THEN 0 ELSE 1 END = 1		 
			)
			
-- End of DATA PREPARATION				
	
-- Starting check Comm Rule
DECLARE @RuleId SMALLINT = 0

---- 36. Super''s Discount < Master''s Discount
IF @RuleId IN (0,36)  
BEGIN  
	----PRINT '36. Super''s Discount < Master''s Discount'  
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)   
	SELECT 36 AS RuleId, css.BetType, css.SportType, css.CustId, csm.CustId, css.Discount, csm.Discount  
	FROM #SuperComm css 
		INNER JOIN #MasterComm csm ON csm.BetType = css.BetType AND csm.SportType = css.SportType AND csm.srecommend = css.custid
	WHERE css.Discount < csm.Discount
		
END  

----37. Master''s Discount < Agent''s Discount
IF @RuleId IN (0,37)  
BEGIN  
	----PRINT '37. Master''s Discount < Agent''s Discount'
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)  
	SELECT 37 AS RuleId, csa.BetType, csa.SportType, csm.CustId, csa.CustId, csm.Discount, csa.Discount  
	FROM #AgentComm csa
		INNER JOIN #MasterComm csm ON csm.BetType = csa.BetType AND csm.SportType = csa.SportType AND csa.mrecommend = csm.CustID
	WHERE csm.Discount < csa.Discount
		
END  

----38. Agent''s Discount < Player''s Discount
IF @RuleId IN (0,38)  
BEGIN   
	----PRINT '38. Agent''s Discount < Player''s Discount'
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)  
	SELECT 38 AS RuleId, csa.BetType, csa.SportType, csa.CustId, csmem.CustId, csa.Discount, csmem.PlayerDiscount
	FROM #AgentComm csa
		INNER JOIN #MemberComm csmem ON csmem.BetType = csa.BetType AND csmem.SportType = csa.SportType AND csmem.recommend = csa.CustID
	WHERE csa.Discount < csmem.PlayerDiscount

END  

----39. SuperDiscount < MasterDiscount on member level
IF @RuleId IN (0,39)  
BEGIN  
	----PRINT '39. SuperDiscount < MasterDiscount on member level'
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)  
	SELECT 39 as RuleId, csmem.BetType, csmem.SportType, csmem.CustId, csmem.CustId, csmem.SuperDiscount, csmem.MasterDiscount
	FROM #MemberComm csmem
	WHERE csmem.SuperDiscount < csmem.MasterDiscount
END  
	
----40. MasterDiscount < AgentDiscount on member level
IF @RuleId IN (0,40)  
BEGIN   
	----PRINT '40. MasterDiscount < AgentDiscount on member level'
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)  
	SELECT 40 as RuleId, csmem.BetType, csmem.SportType, csmem.CustId, csmem.CustId, csmem.MasterDiscount, csmem.AgentDiscount
	FROM #MemberComm csmem
	WHERE csmem.MasterDiscount < csmem.AgentDiscount

END  

----41. AgentDiscount < PlayerDiscount on member level
IF @RuleId IN (0,41)  
BEGIN   
	----PRINT '41. AgentDiscount < PlayerDiscount on member level'
	INSERT INTO CheckCommResult_Credit (RuleId, BetType, SportType, CustIdA, CustIdB, ValueA, ValueB)  
	SELECT 41 as RuleId, csmem.BetType, csmem.SportType, csmem.CustId, csmem.CustId, csmem.AgentDiscount, csmem.PlayerDiscount
	FROM #MemberComm csmem
	WHERE csmem.AgentDiscount < csmem.PlayerDiscount
END    
	

SELECT ca.username AS UsernameA, ca.roleid AS roleidA, cb.username AS UsernameB, cb.roleid AS roleidB, cs.* 
FROM #CheckCommResult_Credit cs
	INNER JOIN CustInfo ca WITH (NOLOCK) ON cs.custidA = ca.custid
	INNER JOIN CustInfo cb WITH (NOLOCK) ON cs.custidB = cb.custid	
--WHERE ruleid BETWEEN 1 AND 29
ORDER BY ruleid	

