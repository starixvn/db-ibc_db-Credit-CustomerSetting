/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_Task_CustSetting_SyncPT	
AS
/*
	Created: 20181212@Elodie
	Task : Sync PT
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
			
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @Batch INT = 3000, @MinID INT, @MaxID INT
	CREATE TABLE #UpdatedSMA (ID INT IDENTITY(1,1), CustID INT PRIMARY KEY CLUSTERED)
	CREATE TABLE #UpdatedMem (ID INT IDENTITY(1,1), CustID INT PRIMARY KEY CLUSTERED)

	CREATE NONCLUSTERED INDEX IX_UpdatedSMA_ID ON #UpdatedSMA(ID)
	CREATE NONCLUSTERED INDEX IX_UpdatedMem_ID ON #UpdatedMem(ID)

	INSERT INTO #UpdatedSMA (CustID)
	SELECT CustID
	FROM dbo.CS_CustPTSetting_Agent cs WITH (NOLOCK)
	WHERE cs.MinPT <> cs.MinPT2
		OR cs.MaxPT <> cs.MaxPT2
		OR cs.SuperPT <> cs.SuperPT2
		OR cs.MasterPT <> cs.MasterPT2
		OR cs.AgentPT <> cs.AgentPT2

	INSERT INTO #UpdatedMem (CustID)
	SELECT cs.AgentId
	FROM dbo.CS_CustPTGroupSetting_Member cs WITH (NOLOCK)
	WHERE cs.SuperPT <> cs.SuperPT2
		OR cs.MasterPT <> cs.MasterPT2
		OR cs.AgentPT <> cs.AgentPT2

	--------------Sync CS_CustPTSetting_Agent----------------
	SELECT @MinID = 1, @MaxID = @Batch
	WHILE (1=1)
	BEGIN
		UPDATE cs
		SET cs.MinPT2 = cs.MinPT,
			cs.MaxPT2 = cs.MaxPT,
			cs.SuperPT2 = cs.SuperPT,
			cs.MasterPT2 = cs.MasterPT,
			cs.AgentPT2 = cs.AgentPT		
		FROM dbo.CS_CustPTSetting_Agent cs WITH (ROWLOCK)
			INNER JOIN #UpdatedSMA sma ON sma.CustID = cs.CustId
		WHERE sma.ID BETWEEN @MinID AND @MaxID

		IF @@ROWCOUNT = 0 BREAK

		SELECT @MinID = @MaxID + 1
		SELECT @MaxID = @MaxID + @Batch
	END

	--------------Sync CS_CustPTGroupSetting_Member----------------
	SELECT @MinID = 1, @MaxID = @Batch
	WHILE (1=1)
	BEGIN
		UPDATE cs
		SET cs.SuperPT2 = cs.SuperPT,
			cs.MasterPT2 = cs.MasterPT,
			cs.AgentPT2 = cs.AgentPT		
		FROM dbo.CS_CustPTGroupSetting_Member cs WITH (ROWLOCK)
			INNER JOIN #UpdatedMem mem ON mem.CustId = cs.AgentId
		WHERE mem.ID BETWEEN @MinID AND @MaxID

		IF @@ROWCOUNT = 0 BREAK

		SELECT @MinID = @MaxID + 1
		SELECT @MaxID = @MaxID + @Batch
	END

	DROP TABLE #UpdatedMem
	DROP TABLE #UpdatedSMA
END
GO
