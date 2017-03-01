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
			
	DELETE cg
	FROM CustPTSetting3rd_Agent cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet
						
	DELETE cg
	FROM CustPTSetting3rd_Member cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72		
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE CG.SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet
	
		
	DELETE cg
	FROM CustPTGroupSetting3rd_Member cg
		INNER JOIN Customer CI (NOLOCK) ON CI.custid = CG.AgentID AND CI.srecommend <> 72		 
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = Ci.srecommend
	WHERE CG.SportType = 211 AND (Super.site IN ('733333','222223') OR ci.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet
			
	DELETE cg
	FROM CustDiscount3rd_Agent cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72		
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet

	DELETE cg
	FROM CustDiscount3rd_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72				
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE CG.SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet
	
	DELETE cg
	FROM CustWinLossLimit_Agent cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72		
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet

	DELETE cg
	FROM CustWinLossLimit_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72		
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE CG.SportType = 211 AND (Super.site IN ('733333','222223') OR c.srecommend IN (3,5,12)) --Dummy account (2,13) run setting Allbet
	
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