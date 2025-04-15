/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_12]
	@CustId			INT,
      @RoleId			INT,
	@XML				VARCHAR(MAX) = NULL,
	@GroupType			SMALLINT = 0 ,
	@Mode				VARCHAR(50) = 'SB_BetSetting'
AS
/*
    Created: 20210518@Winfred
    Task : Update Parlay Max Payout 
    DB: DBCust/CustDB
    
    Revisions:
		- 20210518@Winfred: Update Parlay Max Payout for SMA  [RedmineID:#154104]
		- 20210813@Eden: Enhance - Update Parlay Max Payout for downlines by batch  [RedmineID:#160135]
		- 20210816@Eden: Max Payout Per Match [redmine: #158073]
		- 20220516@Tacy: Insert history of member bet setting: Number Game, Happy5 [RedmineID: #170739]
		- 20220716@Tacy: HotFix - Error when update big line NG/Happy5/Keno bet setting [RedmineID: #175836]
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20241205@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]  

    Param's Explanation:
            
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustList	VARCHAR(MAX),
			@ErrMsg		NVARCHAR(MAX)

	DECLARE @Batch_Num INT, @SportbettypeCount INT
	DECLARE @iDoc INT
	CREATE TABLE #Agent(custid int, RoleID INT)
	CREATE TABLE #Member(custid INT)
	CREATE TABLE #AgentTmpBatch(custid int)
	CREATE TABLE #MemberTmpBatch(custid INT)

	CREATE TABLE #History_BetSetting(
				CustID		INT,
				SportType   SMALLINT, 
				BetType     SMALLINT, 
				MaxBet      MONEY, 
				MaxPerMatch	MONEY, 
				UpdateTime	DATETIME
			)
	
    -- Update MaxPayout Call From Acc_CustSetting_MaxPayoutUpd
	IF (@GroupType = 152)
	BEGIN
		IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
		)
		RETURN;
		
		DECLARE @NewMaxPayoutTbl TABLE (
				  SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)
		IF @XML IS NULL OR @XML='' RETURN
		
		--Parse XML	
		EXEC sp_xml_preparedocument @iDoc OUTPUT
			, @XML

		INSERT @NewMaxPayoutTbl (SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
		FROM OPENXML(@iDoc, '/ROOT/MaxPayoutLimit', 1) WITH (
				SportType			SMALLINT
				, BetType			SMALLINT
				, SingleMatchParlay	MONEY
				, Combo2			MONEY
				, Combo35			MONEY
				, ComboOver6		MONEY
				)

		EXEC sp_xml_removedocument @iDoc

		SELECT @SportbettypeCount = COUNT(1) FROM CustMaxPayoutSetting_Agent WITH(NOLOCK) WHERE CustID = @CustId

		IF @SportbettypeCount = 0
			SET @SportbettypeCount = 1

		SET @Batch_Num = 2000/@SportbettypeCount

		IF @RoleId = 4
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid IN(2,3)	
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid = 1					
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 2	
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE mrecommend = @CustId AND roleid = 1
		END
		ELSE IF @RoleId = 2
		BEGIN
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE recommend = @CustId AND roleid = 1
		END

		IF @RoleId = 4
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 3

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
					, RepUpdateTime = dbo.f_GetDateTime2()									
				FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #AgentTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
						) 
			END
		END

		IF @RoleId IN (3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #AgentTmpBatch
				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #AgentTmpBatch(custid)
				FROM #Agent a
				WHERE a.RoleID = 2

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
					, RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.CustMaxPayoutSetting_Agent mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #AgentTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay = 0 OR mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 = 0 OR mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 = 0 OR mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 = 0 OR mps.ComboOver6 > tmp.ComboOver6)) 
						) 
			END
		END

		IF @RoleId IN (2,3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #MemberTmpBatch
				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;

				UPDATE mps
				SET mps.SingleMatchParlay	 = CASE WHEN (tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay > tmp.SingleMatchParlay)) 
														THEN tmp.SingleMatchParlay ELSE mps.SingleMatchParlay END
					, mps.Combo2		= CASE WHEN (tmp.Combo2 > 0 AND (mps.Combo2 > tmp.Combo2)) 
														THEN tmp.Combo2 ELSE mps.Combo2 END
					, mps.Combo35	= CASE WHEN (tmp.Combo35 > 0 AND (mps.Combo35 > tmp.Combo35)) 
														THEN tmp.Combo35 ELSE mps.Combo35 END
					, mps.ComboOver6	= CASE WHEN (tmp.ComboOver6 > 0 AND (mps.ComboOver6 > tmp.ComboOver6)) 
														THEN tmp.ComboOver6 ELSE mps.ComboOver6 END
					, RepUpdateTime = dbo.f_GetDateTime2()									
				FROM dbo.CustMaxPayoutSetting_Member mps WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewMaxPayoutTbl tmp ON tmp.SportType = mps.sporttype AND tmp.BetType = mps.bettype
					INNER JOIN #MemberTmpBatch c ON mps.CustId = c.CustId
				WHERE (	(tmp.SingleMatchParlay > 0 AND (mps.SingleMatchParlay > tmp.SingleMatchParlay))
							OR (tmp.Combo2 > 0 AND (mps.Combo2 > tmp.Combo2)) 
							OR (tmp.Combo35 > 0 AND (mps.Combo35 > tmp.Combo35))
							OR (tmp.ComboOver6 > 0 AND (mps.ComboOver6 > tmp.ComboOver6)) 
						) 
			END
		END
	END

	DROP TABLE #Agent
	DROP TABLE #AgentTmpBatch
	DROP TABLE #Member
	DROP TABLE #MemberTmpBatch
	DROP TABLE #History_BetSetting
END