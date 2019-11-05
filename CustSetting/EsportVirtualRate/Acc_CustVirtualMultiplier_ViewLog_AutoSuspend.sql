/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustVirtualMultiplier_ViewLog_AutoSuspend 
	@Username NVARCHAR(100)
	, @SportType INT
	, @StartLogTime DATETIME
	, @EndLogTime DATETIME
	, @ErrCode TINYINT OUT
	, @ErrMsg NVARCHAR(200) OUT
AS
/*
	Creator : Eden
	Date : 2019-11-01
	Task :  Log Function for New Virtual Rate Setting Autosuspend [Redmind: #121876]
	DB: DBLOG/bodb_CustomerLog
	Revisions:
		- 20191101@Eden: First commit [Redmind: #121876]
	Parameter:

	
*/
BEGIN
	DECLARE @CustID INT
	DECLARE @LogTrackingValue1 VARCHAR(MAX)
	DECLARE @LogTrackingValue2 VARCHAR(MAX)
	DECLARE @LogDocHandler1 INT, @LogDocHandler2 INT	
	DECLARE @LogID BIGINT, @LogTime	DATETIME
	DECLARE @ActionID INT = 809

	CREATE TABLE #VRLineCustID (CustID INT)
	CREATE TABLE #VRCustLogAutoSuspend(LogID BIGINT
							, [CustID] INT
							, [TrackingValue1] varchar(max)
							, [TrackingValue2] varchar(max)
							, [LogTime] DATETIME
							, [UserID] INT
							, CurrencyRate FLOAT
							, IsExec BIT)

	CREATE CLUSTERED INDEX IX_LogID ON #VRCustLogAutoSuspend(LogID)
	
	CREATE TABLE #DataOld (
			  LogID BIGINT
			, Logtime DATETIME
			, VRLeagueGroup NVARCHAR(200)
			, VRBetTypeGroup NVARCHAR(200)
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, IsLiveAutoSuspend BIT 
			, IsNonLiveAutoSuspend INT 
			, SortOrder SMALLINT
	)
	CREATE TABLE #DataNew (
			  LogID BIGINT
			, Logtime DATETIME
			, VRLeagueGroup NVARCHAR(200)
			, VRBetTypeGroup NVARCHAR(200)
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, IsLiveAutoSuspend BIT 
			, IsNonLiveAutoSuspend INT 
			, SortOrder SMALLINT
	)

	CREATE CLUSTERED INDEX IX_LogID2 ON #DataOld(LogID)
	CREATE CLUSTERED INDEX IX_LogID1 ON #DataNew(LogID)

	SELECT @CustID = CustID
	FROM bodb02.dbo.Customer c(NOLOCK)
	WHERE username = @Username
		AND roleid IN (1,2,3,4)

	IF @CustID IS NULL
	BEGIN
		SELECT @ErrCode = 1
		SELECT @ErrMsg = 'This username is not valid.'
		RETURN
	END
	
	INSERT INTO #VRCustLogAutoSuspend(LogID, CustID, TrackingValue1, TrackingValue2, IsExec, UserID, LogTime)
	SELECT LogID, CustID, dbo.DecompressString(TrackingValue1),dbo.DecompressString(TrackingValue2), 0, UserID, LogTime
	FROM VRCustLog (NOLOCK)
	WHERE LogTime >= @StartLogTime AND LogTime < DATEADD(DAY,1,@EndLogTime)
		AND SportType = @SportType
		AND ActionID = @ActionID 
	
	
	UPDATE #VRCustLogAutoSuspend
	SET CurrencyRate = CAST(CAST(TrackingValue2 AS XML).value('(/Root/@actualrate)[1]', 'nvarchar(100)') AS FLOAT) 


	WHILE(1=1)
	BEGIN
		UPDATE TOP (1) #VRCustLogAutoSuspend
		SET IsExec = 1
			, @LogID = LogID
			, @LogTime = LogTime
			, @LogTrackingValue1 = TrackingValue1
			, @LogTrackingValue2 = TrackingValue2
		WHERE IsExec = 0 
		IF @@ROWCOUNT = 0
			BREAK

		EXEC sp_xml_preparedocument @LogDocHandler1 OUTPUT, @LogTrackingValue1
		EXEC sp_xml_preparedocument @LogDocHandler2 OUTPUT, @LogTrackingValue2

		--Insert data into temporary table after parsing
		INSERT INTO #DataNew(LogID 
						, Logtime
						, VRLeagueGroup
						, VRBetTypeGroup
						, BetType
						, LevelID
						, IsLiveAutoSuspend
						, IsNonLiveAutoSuspend
						, SortOrder
			)
		SELECT	@LogID LogID
				, @LogTime AS Logtime
				, tmp.VRLeagueGroup
				, tmp.VRBetTypeGroup
				, tmp.BetType
				, tmp.LevelID
				, tmp.IsLiveAutoSuspend
				, tmp.IsNonLiveAutoSuspend
				, MIN(tmp.SortOrder)
		FROM OPENXML (@LogDocHandler1, '/Root/r',1) 
		WITH (
			  VRLeagueGroup NVARCHAR(200)
			, VRBetTypeGroup NVARCHAR(200)
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, IsLiveAutoSuspend BIT 
			, IsNonLiveAutoSuspend INT 
			, SortOrder SMALLINT
		) AS tmp
		GROUP BY tmp.VRLeagueGroup
				, tmp.VRBetTypeGroup
				, tmp.BetType
				, tmp.LevelID
				, tmp.IsLiveAutoSuspend
				, tmp.IsNonLiveAutoSuspend

		INSERT INTO #DataOld(LogID 
						, Logtime
						, VRLeagueGroup
						, VRBetTypeGroup
						, BetType
						, LevelID
						, IsLiveAutoSuspend
						, IsNonLiveAutoSuspend
						, SortOrder
			)
		SELECT	@LogID LogID
				, @LogTime AS Logtime
				, tmp.VRLeagueGroup
				, tmp.VRBetTypeGroup
				, tmp.BetType
				, tmp.LevelID
				, tmp.IsLiveAutoSuspend
				, tmp.IsNonLiveAutoSuspend
				, MIN(tmp.SortOrder)
		FROM OPENXML (@LogDocHandler2, '/Root/r',1) 
		WITH (
			  VRLeagueGroup NVARCHAR(200)
			, VRBetTypeGroup NVARCHAR(200)
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, IsLiveAutoSuspend BIT 
			, IsNonLiveAutoSuspend INT 
			, SortOrder SMALLINT
		) AS tmp
		GROUP BY tmp.VRLeagueGroup
				, tmp.VRBetTypeGroup
				, tmp.BetType
				, tmp.LevelID
				, tmp.IsLiveAutoSuspend
				, tmp.IsNonLiveAutoSuspend
		
		EXEC sp_xml_removedocument @LogDocHandler1
		EXEC sp_xml_removedocument @LogDocHandler2
	END
	
	
	SELECT d1.LogID, 
		   d1.Logtime,
		   d1.LevelID,
		   d1.VRLeagueGroup, 
		   d1.VRBetTypeGroup, 
		   d1.BetType, 
		   d1.IsLiveAutoSuspend AS IsLiveAutoSuspendNew, 
		   d2.IsLiveAutoSuspend AS IsLiveAutoSuspendOld, 
		   d1.IsNonLiveAutoSuspend AS IsNonLiveAutoSuspendNew, 
		   d2.IsNonLiveAutoSuspend AS IsNonLiveAutoSuspendOld
	FROM #DataNew d1
		 INNER JOIN #DataOld d2
		   ON d1.LevelID = d2.LevelID
		   AND d1.LogID = d2.LogID
	ORDER BY D1.LogID DESC, d1.SortOrder

	DROP TABLE #VRCustLogAutoSuspend
	DROP TABLE #VRLineCustID
	DROP TABLE #DataOld
	DROP TABLE #DataNew	
END
