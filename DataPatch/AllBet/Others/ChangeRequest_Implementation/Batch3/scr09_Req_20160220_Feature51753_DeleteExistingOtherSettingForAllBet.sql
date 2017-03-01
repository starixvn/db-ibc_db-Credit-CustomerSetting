/*
	Created: Elodie
	Date: 20160225
	Task: Delete existing All Bet settings
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
	
	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0 RETURN
	
	CREATE TABLE #supers (custid INT PRIMARY KEY, currency INT)
	INSERT INTO #supers(custid,currency)
	SELECT custid, currency
	FROM Customer ci WITH(NOLOCK)
	WHERE (ci.roleid = 4 	
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		-- Production
		AND (ci.site IN ('BEST-ODDS' ,'789y' ,'XYZBET' ,'611111' ,'722222' ,'222225' ,'222227' ,'033333' ,'ispo' ,'766666' ,'7aa666') OR ci.currency = 20)
		AND ci.custid <> 72
		AND ci.custid NOT IN (2,3,4,5,12,13,15)-- dummy account
		)	
		-- CROSS-SITE
		OR ci.custid IN (1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322)
				
	DELETE cg
	FROM CustPTSetting3rd_Agent cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE SportType = 211 
						
	DELETE cg
	FROM CustPTSetting3rd_Member cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE CG.SportType = 211 
	
		
	DELETE cg
	FROM CustPTGroupSetting3rd_Member cg
		INNER JOIN Customer CI (NOLOCK) ON CI.custid = CG.AgentID 
		INNER JOIN #supers S ON S.custid = CI.srecommend
	WHERE CG.SportType = 211 
			
	DELETE cg
	FROM CustDiscount3rd_Agent cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE SportType = 211 

	DELETE cg
	FROM CustDiscount3rd_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE CG.SportType = 211 
	
	DELETE cg
	FROM CustWinLossLimit_Agent cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE SportType = 211 

	DELETE cg
	FROM CustWinLossLimit_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE CG.SportType = 211 
	
	DELETE cg
	FROM CustStakeLevel_Agent cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
	WHERE SportType = 211 

	DELETE cg
	FROM CustStakeLevel_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID 
		INNER JOIN #supers S ON S.custid = C.srecommend
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