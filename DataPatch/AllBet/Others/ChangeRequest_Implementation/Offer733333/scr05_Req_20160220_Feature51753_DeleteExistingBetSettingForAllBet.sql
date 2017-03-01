/*
	Created: Helen
	Date: 20161003
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
	
	IF dbo.f_CheckRepTable('CustStakeLevel_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustStakeLevel_Member') = 0 RETURN
			
	DELETE cg
	FROM CustStakeLevel_Agent cg 
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE CG.SportType = 211 
			AND (Super.site IN ('733333','222223') 
				OR c.srecommend IN (3,5,12) --Dummy account (2,13) run setting Allbet
				OR c.srecommend IN (1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322)
				) 

	DELETE cg
	FROM CustStakeLevel_Member cg 		
		INNER JOIN Customer C (NOLOCK) ON C.custid = CG.CustID AND C.srecommend <> 72
		INNER JOIN Customer Super (NOLOCK) ON Super.custid = C.srecommend
	WHERE CG.SportType = 211 
		AND (Super.site IN ('733333','222223') 
			OR c.srecommend IN (3,5,12)
			OR c.srecommend IN (1266057,913628,877004,900371,4204225,6032879,896708,796555,5005322)
			) --Dummy account (2,13) run setting Allbet
	 
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