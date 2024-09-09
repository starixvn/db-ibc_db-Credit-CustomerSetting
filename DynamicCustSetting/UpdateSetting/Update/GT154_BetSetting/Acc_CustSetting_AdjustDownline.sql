/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_CustSetting_AdjustDownline 
	@CustId	INT = NULL,
	@RoleId	INT = NULL,
	@JsonData VARCHAR(MAX) = NULL,
	@Mode VARCHAR(30) = 'BetSetting'
AS
/*
	Created: 20240520@Eden
	Task : Adjust setting for downlines
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		
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

	IF ISNULL(@JsonData,'') = ''
		RETURN

	IF @Mode = 'BetSetting'
	BEGIN
		DECLARE @NewMaxBet MONEY, @NewMaxPerNumber MONEY, @NewMaxPerMatch MONEY, @NewMinBet MONEY
		DECLARE @BetSetting TABLE(
				SportType         SMALLINT, 
				BetType           SMALLINT, 
				MinBet            MONEY, 
				MaxBet            MONEY, 
				MaxPerMatch       MONEY, 
				MaxPerNumber      MONEY
			);

		DECLARE @BetSetting_CustBatch TABLE(
				CustID			  INT,
				SportType         SMALLINT, 
				BetType           SMALLINT, 
				MinBet            MONEY, 
				MaxBet            MONEY, 
				MaxPerMatch       MONEY, 
				MaxPerNumber      MONEY
			);

		INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber
		FROM OPENJSON(@JsonData) WITH (
				SportType smallint  '$.SportType',
				BetType smallint  '$.BetType',
				MinBet MONEY  '$.MinBet',
				MaxBet MONEY  '$.MaxBet',
				MaxPerMatch MONEY  '$.MPM',
				MaxPerNumber MONEY  '$.MaxPerNumber'
			)

		SELECT @SportbettypeCount = COUNT(1) FROM @BetSetting

		IF @SportbettypeCount = 0
			RETURN

		SET @Batch_Num = 5000/@SportbettypeCount

		IF @RoleId = 4
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid IN(2,3) AND Enabled = 1
			
			INSERT INTO #Member(custid)
			SELECT custid
			FROM custInfo c WITH(NOLOCK) 
			WHERE srecommend = @CustId AND roleid = 1 AND Enabled = 1					
		END
		ELSE IF @RoleId = 3
		BEGIN
			INSERT INTO #Agent(custid,RoleID)
			SELECT custid,roleid
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

		--downline_maxbet = min (downline_maxbet, @NEW_MAXBET,@NEW_MAXPERMATCH,@NEW_MAXPERBALL)
		--downline_maxpermatch = min (downline_maxpermatch, @NEW_MAXPERMATCH)
		--downline_maxperball = min (downline_maxperball, @NEW_MAXPERBALL,@NEW_MAXPERMATCH)
		--downline_minbet = min (downline_minbet, @NEW_MAXBET)

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

				DELETE FROM @BetSetting_CustBatch

				INSERT INTO @BetSetting_CustBatch(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
				SELECT c.custid, b.SportType,b.BetType,b.MinBet,b.MaxBet,b.MaxPerMatch,b.MaxPerNumber
				FROM @BetSetting b
					CROSS JOIN #AgentTmpBatch c

				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					--
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting3rd_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting_CustBatch new 
						ON b.sporttype = new.sporttype AND b.bettype = new.bettype AND b.CustID= new.CustID 
				WHERE ( 
						(b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0)
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

				DELETE FROM @BetSetting_CustBatch

				INSERT INTO @BetSetting_CustBatch(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
				SELECT c.custid, b.SportType,b.BetType,b.MinBet,b.MaxBet,b.MaxPerMatch,b.MaxPerNumber
				FROM @BetSetting b
					CROSS JOIN #AgentTmpBatch c

				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					--
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.RepUpdateTime = dbo.f_GetDateTime2()
				FROM dbo.BetSetting3rd_Agent b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting_CustBatch new 
						ON b.sporttype = new.sporttype AND b.bettype = new.bettype AND b.CustID= new.CustID 
				WHERE(
						(b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0)
					)
			END
		END

		IF @RoleId IN (2,3,4)
		BEGIN
			WHILE 1 = 1
			BEGIN
				TRUNCATE TABLE #History_BetSetting
				TRUNCATE TABLE #MemberTmpBatch

				DELETE TOP (@Batch_Num) a
				OUTPUT deleted.custid INTO #MemberTmpBatch(custid)
				FROM #Member a

				IF @@ROWCOUNT = 0 
					BREAK;

				DELETE FROM @BetSetting_CustBatch

				INSERT INTO @BetSetting_CustBatch(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
				SELECT c.custid, b.SportType,b.BetType,b.MinBet,b.MaxBet,b.MaxPerMatch,b.MaxPerNumber
				FROM @BetSetting b
					CROSS JOIN #MemberTmpBatch c
				
				UPDATE b
				SET @NewMaxBet = CASE WHEN (b.MaxBet > new.MaxBet AND new.MaxBet > 0) THEN new.MaxBet ELSE b.MaxBet END,
					@NewMaxPerNumber = CASE WHEN (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0) THEN new.MaxPerNumber ELSE b.MaxPerNumber END,
					@NewMaxPerMatch = CASE WHEN (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0) THEN new.MaxPerMatch ELSE b.MaxPerMatch END,
					--
					@NewMaxPerNumber = CASE WHEN @NewMaxPerNumber > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxPerNumber END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerMatch THEN @NewMaxPerMatch ELSE @NewMaxBet END,
					@NewMaxBet = CASE WHEN @NewMaxBet > @NewMaxPerNumber AND @NewMaxPerNumber > 0 THEN @NewMaxPerNumber ELSE @NewMaxBet END,
					--
					b.MinBet = CASE WHEN @NewMaxBet < b.MinBet THEN @NewMaxBet ELSE b.MinBet END,
					b.MaxBet = @NewMaxBet,
					b.MaxPerMatch = @NewMaxPerMatch,
					b.MaxPerNumber = @NewMaxPerNumber,
					b.RepUpdateTime = dbo.f_GetDateTime2()
				OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
					INTO #History_BetSetting(CustID,SportType,BetType,MaxBet,MaxPerMatch,UpdateTime)
				FROM dbo.BetSetting3rd_Member b WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @BetSetting_CustBatch new 
						ON b.sporttype = new.sporttype AND b.bettype = new.bettype AND b.CustID= new.CustID 
				WHERE (		   
						(b.MaxBet > new.MaxBet AND new.MaxBet > 0)
						OR (b.MaxPerMatch > new.MaxPerMatch AND new.MaxPerMatch > 0)
						OR (b.MaxPerNumber > new.MaxPerNumber AND new.MaxPerNumber > 0)
					)		
			END
		END
	END
END