/*
	Created: Elodie
	Date: 20170801
	Task: Delete existing data of Lottery
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
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN				

	SELECT DISTINCT custid 
	INTO #CustPT_Agent
	FROM CustPTSetting3rd_Agent cg WITH(NOLOCK)		
	WHERE SportType = 220
						
	SELECT DISTINCT custid 
	INTO #CustPT_Member
	FROM CustPTSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType = 220
		
	SELECT DISTINCT cg.AgentID AS CustID
	INTO #CustPTGroup_Member
	FROM CustPTGroupSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType = 220
				
	SELECT DISTINCT custid 
	INTO #CustBet_Agent
	FROM CustBetSetting3rd_Agent cg WITH(NOLOCK)		
	WHERE SportType = 220

	SELECT DISTINCT custid 
	INTO #CustBet_Member
	FROM CustBetSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType = 220

	SELECT DISTINCT custid 
	INTO #CustWinLoss_Agent
	FROM dbo.CustWinLossLimit_Agent cg WITH(NOLOCK)		
	WHERE SportType = 220

	SELECT DISTINCT custid 
	INTO #CustWinLoss_Member
	FROM dbo.CustWinLossLimit_Member cg WITH(NOLOCK)		
	WHERE SportType = 220

	DELETE cg
	FROM CustPTSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustPT_Agent ci ON ci.custid = cg.CustID
	WHERE SportType = 220
						
	DELETE cg
	FROM CustPTSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustPT_Member ci ON ci.custid = cg.CustID
	WHERE SportType = 220
		
	DELETE cg
	FROM CustPTGroupSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)	
		INNER JOIN #CustPTGroup_Member ci ON ci.CustID = cg.AgentID	
	WHERE SportType = 220
				
	DELETE cg
	FROM CustBetSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)
		INNER JOIN #CustBet_Agent ci ON ci.custid = cg.CustID			
	WHERE SportType = 220

	DELETE cg
	FROM CustBetSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustBet_Member ci ON ci.custid = cg.CustID	
	WHERE SportType = 220

	DELETE cg
	FROM dbo.CustWinLossLimit_Agent cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustWinLoss_Agent ci ON ci.custid = cg.CustID	
	WHERE SportType = 220

	DELETE cg
	FROM dbo.CustWinLossLimit_Member cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustWinLoss_Member ci ON ci.custid = cg.CustID	
	WHERE SportType = 220

END	
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_DynamicCustSetting3rd_09 @target = 'REPLICATED'


-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
PRINT N'Step 1: Start on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.'

EXEC dbo.Acc_DynamicCustSetting3rd_09 @target = 'DBCUST'

PRINT N'Step 1: End on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.'

