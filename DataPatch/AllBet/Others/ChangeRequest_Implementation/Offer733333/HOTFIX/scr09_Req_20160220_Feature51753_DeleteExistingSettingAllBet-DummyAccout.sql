/*
	Created: Helen
	Date: 20160225
	Task: Delete existing All Bet settings for dummy account under batch 2
	DB: DBCust/CustDB
*/
 
 -- BEGIN STEP 1: DEPLOY THIS SP @DBCUST.CustDB ------
------------------------------------------------------
 
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbcust only
	
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN
	
	CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
	CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
	CREATE TABLE #Cust_tmp(CustID INT PRIMARY KEY CLUSTERED,	roleid TINYINT	)

	INSERT INTO #DirectMaster (CustID,roleid)
	SELECT custid, roleid
	FROM Customer with(nolock)
	WHERE SITE IN ('733333','222223')
		AND custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		AND srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		AND roleid=3 AND srecommend IN (2,3,5,12,13)
	
	--- get direct agent
	INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
	SELECT custid, mrecommend,roleid
	FROM Customer WITH(NOLOCK)
	WHERE site in ('733333','222223')
		and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
		and roleid=2 AND srecommend IN (2,3,5,12,13)
		
	INSERT INTO #Cust_tmp (CustID,roleid)
	
	SELECT CI.CustID,CI.roleid -- Direct Master 
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
	
	UNION ALL
	
	SELECT CI.CustID,CI.roleid -- Direct Agent
	FROM custInfo CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.recommend = D.CustID 
	UNION ALL	
	
	SELECT DISTINCT CI.CustID,CI.roleid -- Master of direct agent
	FROM Customer CI WITH (NOLOCK)
		INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
	WHERE CI.roleid = 3 and ci.custid <> 4300 -- under this master having direct agent of 7555555
		
	--- PT
	DELETE cg
	FROM CustPTSetting3rd_Agent cg 
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE SportType = 211 
							
	DELETE cg
	FROM CustPTSetting3rd_Member cg 
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE CG.SportType = 211 
	
	
	DELETE cg
	FROM CustPTGroupSetting3rd_Member cg
		INNER JOIN #Cust_tmp CI (NOLOCK) ON CI.custid = CG.AgentID 
	WHERE CG.SportType = 211 
	
	-- Comm		
	DELETE cg
	FROM CustDiscount3rd_Agent cg 
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE SportType = 211 

	DELETE cg
	FROM CustDiscount3rd_Member cg 		
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE CG.SportType = 211 
	
	-- Winloss - limit
	DELETE cg
	FROM CustWinLossLimit_Agent cg 		
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE SportType = 211 

	DELETE cg
	FROM CustWinLossLimit_Member cg 		
		INNER JOIN #Cust_tmp tmp (NOLOCK) ON tmp.custid = cg.custid
	WHERE CG.SportType = 211 
END	
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_DynamicCustSetting3rd_09 @target = 'REPLICATED'


-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_DynamicCustSetting3rd_09 @target = 'DBCUST'