/*
	Created: Elodie
	Date: 20170801
	Task: Delete existing data of BetRadarVS
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

	SELECT DISTINCT custid 
	INTO #CustPT_Agent
	FROM CustPTSetting3rd_Agent cg WITH(NOLOCK)		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191

	SELECT DISTINCT custid 
	INTO #CustPT_Member
	FROM CustPTSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191

	SELECT DISTINCT cg.AgentID AS CustID
	INTO #CustPTGroup_Member
	FROM CustPTGroupSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191

	SELECT DISTINCT custid 
	INTO #CustBet_Agent
	FROM CustBetSetting3rd_Agent cg WITH(NOLOCK)		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199

	SELECT DISTINCT custid 
	INTO #CustBet_Member
	FROM CustBetSetting3rd_Member cg WITH(NOLOCK)		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199

	DELETE cg
	FROM CustPTSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustPT_Agent ci ON ci.custid = cg.CustID
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191
						
	DELETE cg
	FROM CustPTSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustPT_Member ci ON ci.custid = cg.CustID
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191
		
	DELETE cg
	FROM CustPTGroupSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)		
		INNER JOIN #CustPTGroup_Member ci ON ci.CustID = cg.AgentID
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191		
				
	DELETE cg
	FROM CustBetSetting3rd_Agent cg WITH(UPDLOCK,ROWLOCK)
		INNER JOIN #CustBet_Agent ci ON ci.custid = cg.CustID		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199

	DELETE cg
	FROM CustBetSetting3rd_Member cg WITH(UPDLOCK,ROWLOCK)
		INNER JOIN #CustBet_Member ci ON ci.custid = cg.CustID		
	WHERE SportType BETWEEN 180 AND 186 OR cg.SportType BETWEEN 190 AND 191 OR cg.SportType = 199

END	
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT REPLICATED SERVERS -----
--------------------------------------------------------------------------------------
EXEC Acc_DynamicCustSetting3rd_09 @target = 'REPLICATED'

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
EXEC Acc_DynamicCustSetting3rd_09 @target = 'DBCUST'
