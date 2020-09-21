/*

	Task: Manual run for some accounts before running all - Archive Phase 1
	Created: Helen@20200921
	Database: DBCUST/CustDB
*/
USE CustDB
GO
DECLARE @status varchar(200)
DECLARE @agent varchar(50)
	, @ErrMsg VARCHAR(150), @msg VARCHAR(100)
CREATE TABLE #ReduceCredit (CustId INT, ReduceCredit MONEY DEFAULT(0), IsFinished BIT DEFAULT(0))

DECLARE @agent_tmp varchar(50)
SET @agent_tmp = 'XXXX'
DECLARE @srecommend INT
			, @mrecommend INT
			, @ReduceCredit MONEY = 0
			, @OldCredit MONEY = 0
			, @LogData VARCHAR(500)
			, @custid INT
			, @NewCredit MONEY = 0
			, @username NVARCHAR(MAX)
			, @recommend INT

INSERT INTO #ReduceCredit (CustId)
SELECT DISTINCT c.custid
FROM dbo.tmpCustArchived t WITH (NOLOCK)
	INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.username= t.Master
WHERE t.IsFinished = 0
	AND c.roleid = 3
	AND t.Agent = @agent_tmp

UNION ALL
SELECT DISTINCT c.custid
FROM dbo.tmpCustArchived t WITH (NOLOCK)
	INNER JOIN dbo.custInfo c WITH (NOLOCK) ON c.username= t.Super
WHERE t.IsFinished = 0
	AND c.roleid = 4
	AND t.Agent = @agent_tmp

WHILE(1=1)
BEGIN
	SELECT @ErrMsg = ''
	SELECT TOP 1 @agent = Agent, @recommend = recommend FROM tmpCustArchived WHERE IsFinished = 0 AND Agent = @agent_tmp
		
	IF (@@ROWCOUNT = 0) BREAK

	EXEC dbo.DBA_ArchiveAccount2_DisableAgentLine @AccName = @agent, @ErrMsg = @ErrMsg OUTPUT, @srecommend = @srecommend OUTPUT, @mrecommend = @mrecommend OUTPUT, @ReduceCredit = @ReduceCredit OUTPUT

	UPDATE tmpCustArchived 
	SET ErrMsg = @ErrMsg, IsFinished = 1
	WHERE Agent = @agent

	IF @ErrMsg = ''
	BEGIN
		UPDATE #ReduceCredit
		SET ReduceCredit = ReduceCredit + @ReduceCredit
		WHERE CustId IN (@srecommend, @mrecommend)

		--Writelog clear given credit for Agent
		SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@agent, SPACE(1))  

		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @recommend,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END TRY
		BEGIN CATCH
			SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @recommend,
				@Doing = @LogData,
				@OldValue = @ReduceCredit,
				@NewValue = 0,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END CATCH
	END

	SET @msg = 'Done agent ' + @agent + CHAR(13)
	RAISERROR(@msg, 0, 0) WITH NOWAIT	
	
	WAITFOR DELAY '00:00:00.120'
	--IF (@ErrMsg <> '') BREAK
END

--Reduce SMA Credit
IF EXISTS (SELECT TOP(1) 1 FROM #ReduceCredit WHERE ReduceCredit <> 0)
BEGIN
	WHILE(1=1)
	BEGIN
		UPDATE TOP (1) t
		SET t.IsFinished = 1
			, @custid = t.CustId
			, @ReduceCredit = t.ReduceCredit
		FROM #ReduceCredit t
		WHERE IsFinished = 0
			AND ReduceCredit <> 0

		IF @@ROWCOUNT = 0 
			BREAK
	
		SELECT	@username = username,
				@OldCredit = Credit
		FROM	dbo.custInfo WITH (NOLOCK)
		WHERE	custid = @custid

		SET @NewCredit = @OldCredit - @ReduceCredit

		UPDATE c
		SET c.credit = @NewCredit
		FROM dbo.custInfo c WITH (ROWLOCK, UPDLOCK)
		WHERE c.custid = @custid	

		--Writelog
		SELECT  @LogData = 'Update Credits for SMA Account '+ COALESCE(@username, SPACE(1))  

		BEGIN TRY
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @OldCredit,
				@NewValue = @NewCredit,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END TRY
		BEGIN CATCH
			SELECT @LogData = @LogData + ' ErrMsg:' + ERROR_MESSAGE()

			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_Credit
				@UserID = 360418,
				@CustID = @CustID,
				@Doing = @LogData,
				@OldValue = @OldCredit,
				@NewValue = @NewCredit,
				@IP = '100.100.100.100',
				@ActionID = 1222
		END CATCH
	END
END