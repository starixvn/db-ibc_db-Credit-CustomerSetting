/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_00]
	@CustId			INT,
    @RoleId			INT,
	@Limit_XML	VARCHAR(MAX) = NULL,
	@SettingType	SMALLINT = 6
AS
/*
    Created: 20160108@Elodie
    Task : Update SMA WinLossLimit 
    DB: DBCust/CustDB
    
    Revisions:
		- 20161011@Winnie:  Implement for Loss limit setting type [RedmineID: #65472]
		- 20220622@Elodie:  Run by batch [RedmineID: #174131]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
    Param's Explanation:
            
*/
BEGIN
	SET NOCOUNT ON;
    -- check existing tables

    IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN
	
	DECLARE @BatchNo INT = 5000, @SettingRow TINYINT
	CREATE TABLE #Agent(custid INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid INT)
	CREATE TABLE #MemberTmpBatch(custid INT)	

	IF @RoleId = 4
	BEGIN
		INSERT INTO #Agent(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE srecommend = @CustId AND roleid IN (2,3) AND Enabled = 1

		INSERT INTO #Member(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE srecommend = @CustId AND roleid = 1 AND Enabled = 1					
	END
	ELSE IF @RoleId = 3
	BEGIN
		INSERT INTO #Agent(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE mrecommend = @CustId AND roleid = 2 AND Enabled = 1	
			
		INSERT INTO #Member(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE mrecommend = @CustId AND roleid = 1 AND Enabled = 1
	END
	ELSE IF @RoleId = 2
	BEGIN
		INSERT INTO #Member(custid)
		SELECT custid
		FROM custInfo c WITH(NOLOCK) 
		WHERE recommend = @CustId AND roleid = 1 AND Enabled = 1
	END

	IF(@SettingType=12)
	BEGIN
		DECLARE @NewLimitTbl12 TABLE(
			SportType SMALLINT,
			BetType SMALLINT,	
			MaxLossLimit MONEY,
			IsAutoReset BIT
		)
		IF @Limit_XML IS NULL OR @Limit_XML='' RETURN

		--Parse XML	
		DECLARE @iDoc12 INT
		EXEC sp_xml_preparedocument @iDoc12 OUTPUT, @Limit_XML

		INSERT @NewLimitTbl12
		SELECT SportType,BetType,MaxLossLimit,IsAutoReset
		FROM OPENXML (@iDoc12, '/ROOT/Limit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MaxLossLimit MONEY, IsAutoReset BIT)		
		EXEC sp_xml_removedocument @iDoc12
		
		SELECT @SettingRow = COUNT(1) FROM @NewLimitTbl12
		IF @SettingRow = 0 RETURN

		SELECT @BatchNo = @BatchNo / @SettingRow

		WHILE 1 = 1
		BEGIN
			TRUNCATE TABLE #AgentTmpBatch
			DELETE TOP (@BatchNo) a
			OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
			FROM #Agent a

			IF @@ROWCOUNT = 0 
				BREAK;

			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN #AgentTmpBatch c WITH(NOLOCK) ON cwl.CustId = c.CustId
		END

		WHILE 1 = 1
		BEGIN
			TRUNCATE TABLE #MemberTmpBatch
			DELETE TOP (@BatchNo) a
			OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
			FROM #Member a

			IF @@ROWCOUNT = 0 
				BREAK;

			UPDATE cwl
			SET 
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl12 wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN #MemberTmpBatch c WITH(NOLOCK) ON cwl.CustId = c.CustId
		END		
	END
	ELSE IF(@SettingType IN (6,22))
	BEGIN
		DECLARE @NewLimitTbl TABLE(
			SportType SMALLINT,
			BetType SMALLINT,
			MaxWinLimit SMALLMONEY,
			MaxLossLimit MONEY,
			IsAutoReset BIT
		)
		
		IF @Limit_XML IS NULL OR @Limit_XML='' RETURN

		--Parse XML	
		DECLARE @iDoc INT
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @Limit_XML

		INSERT @NewLimitTbl
		SELECT SportType,BetType,MaxWinLimit,MaxLossLimit,IsAutoReset
		FROM OPENXML (@iDoc, '/ROOT/Limit',1) 
		WITH(SportType SMALLINT, BetType SMALLINT, MaxWinLimit SMALLMONEY, MaxLossLimit MONEY, IsAutoReset BIT)	
		
		EXEC sp_xml_removedocument @iDoc

		SELECT @SettingRow = COUNT(1) FROM @NewLimitTbl
		IF @SettingRow = 0 RETURN

		SELECT @BatchNo = @BatchNo / @SettingRow

		WHILE 1 = 1
		BEGIN
			TRUNCATE TABLE #AgentTmpBatch
			DELETE TOP (@BatchNo) a
			OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
			FROM #Agent a

			IF @@ROWCOUNT = 0 
				BREAK;

			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Agent cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN #AgentTmpBatch c WITH(NOLOCK) ON cwl.CustId = c.CustId
		END

		WHILE 1 = 1
		BEGIN
			TRUNCATE TABLE #MemberTmpBatch
			DELETE TOP (@BatchNo) a
			OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
			FROM #Member a

			IF @@ROWCOUNT = 0 
				BREAK;

			UPDATE cwl
			SET MaxWinLimit = CASE WHEN (wl.MaxWinLimit > 0 AND (cwl.MaxWinLimit = 0 OR cwl.MaxWinLimit > wl.MaxWinLimit)) 
									THEN wl.MaxWinLimit ELSE cwl.MaxWinLimit END,
				MaxLossLimit = CASE WHEN (wl.MaxLossLimit > 0 AND (cwl.MaxLossLimit = 0 OR cwl.MaxLossLimit > wl.MaxLossLimit)) 
									THEN wl.MaxLossLimit ELSE cwl.MaxLossLimit END,
				IsAutoReset = CASE WHEN wl.IsAutoReset = 0 
									THEN 0 ELSE cwl.IsAutoReset END			
			FROM dbo.CustWinLossLimit_Member cwl WITH (ROWLOCK, UPDLOCK)
				INNER JOIN @NewLimitTbl wl ON cwl.sporttype = wl.sporttype AND cwl.bettype = wl.bettype
				INNER JOIN #MemberTmpBatch c WITH(NOLOCK) ON cwl.CustId = c.CustId
		END
	END
END