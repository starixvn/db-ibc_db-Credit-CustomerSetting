/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
--CREATE PROCEDURE Acc_CustVirtualMultiplier_ViewLog 
DECLARE
	@Username NVARCHAR(100) = 'member01'
	, @SportType INT = 43
	, @IncludingUpline BIT = 1
	, @StartLogTime DATETIME = '2019-07-28 21:47:42.723'
	, @EndLogTime DATETIME = '2019-07-28 22:46:35.203'
	, @ErrCode TINYINT --OUT
	, @ErrMsg NVARCHAR(200) --OUT
--AS
/*
	Creator : Dominic
	Date : 2019-07-25
	Task :  Log Function for New Virtual Rate Setting  [Redmind: #114830]
	DB: DBLOG/bodb_CustomerLog
	Revisions:
		- 20190725@Dominic: First commit
	Parameter:

	
*/
--BEGIN
	DECLARE @CustID INT
	DECLARE @LogTrackingValue2 VARCHAR(MAX)
	DECLARE @LogDocHandler INT	
	DECLARE @LogID BIGINT

	CREATE TABLE #VRLineCustID (CustID INT)
	CREATE TABLE #VRCustLog(LogID BIGINT
							, [CustID] INT
							, [TrackingValue2] varchar(max)
							, [LogTime] DATETIME
							, [UserID] INT
							, IsExec BIT)

	CREATE CLUSTERED INDEX IX_LogID ON #VRCustLog(LogID)
	
	CREATE TABLE #Data (
			LogID BIGINT
			, IsNew BIT --IsNew
			, VRLeagueGroupID SMALLINT --VRLeagueGroupID
			, VRBetTypeGroupID SMALLINT --VRBetTypeGroupID
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, FollowingValueLive SMALLMONEY --FollowingValueLive
			, FollowingCustIDLive INT --FollowingCustID
			, FollowingLevelIDLive INT --FollowingLevelID
			, FollowingValueNonLive SMALLMONEY --FollowingValueNonLive
			, FollowingCustIDNonLive INT --FollowingCustID
			, FollowingLevelIDNonLive INT --FollowingLevelID
			, SortOrder SMALLINT
	)

	CREATE CLUSTERED INDEX IX_LogID ON #Data(LogID)

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

	IF @IncludingUpline = 1
	BEGIN
		INSERT INTO #VRLineCustID(CustID)
		SELECT CustID
		FROM (
			SELECT upv.Val CustID
			FROM (
				SELECT custid,recommend,mrecommend,srecommend,0 [Global]
				FROM bodb02.dbo.Customer (NOLOCK)
				WHERE CustID=@CustID
			) t
			UNPIVOT
			(
				Val
				FOR col IN (custid,recommend,mrecommend,srecommend,[Global])
			) upv
		) tmp
		GROUP BY CustID
	END
	ELSE
	BEGIN
		INSERT INTO #VRLineCustID(CustID)
		SELECT @CustID
	END
	
	INSERT INTO #VRCustLog(LogID, CustID, TrackingValue2, IsExec, UserID, LogTime)
	SELECT LogID, CustID, dbo.DecompressString(TrackingValue2), 0, UserID, LogTime
	FROM VRCustLog (NOLOCK)
	WHERE CustID IN (SELECT CustID FROM #VRLineCustID) 
		AND LogTime BETWEEN @StartLogTime AND @EndLogTime
		AND SportType = @SportType
	
	

	--SELECT @LogTrackingValue2 = TrackingValue2
	--,CAST(CAST(TrackingValue2 AS XML).value('(/Root/@actualrate)[1]', 'nvarchar(max)') AS FLOAT) 
	--FROM #VRCustLog

	WHILE(1=1)
	BEGIN
		UPDATE TOP (1) #VRCustLog
		SET IsExec = 1
			, @LogID = LogID
			, @LogTrackingValue2 = TrackingValue2
		WHERE IsExec = 0 

		IF @@ROWCOUNT = 0
			BREAK

		EXEC sp_xml_preparedocument @LogDocHandler OUTPUT, @LogTrackingValue2

		--Insert data into temporary table after parsing
		INSERT INTO #Data(LogID 
						, IsNew
						, VRLeagueGroupID
						, VRBetTypeGroupID
						, BetType
						, LevelID
						, FollowingValueLive
						, FollowingCustIDLive
						, FollowingLevelIDLive
						, FollowingValueNonLive
						, FollowingCustIDNonLive
						, FollowingLevelIDNonLive
						, SortOrder
			)
		SELECT @LogID LogID
				, tmp.IsNew
				, tmp.VRLeagueGroupID
				, tmp.VRBetTypeGroupID
				, tmp.BetType
				, tmp.LevelID
				, tmp.FollowingValueLive
				, tmp.FollowingCustIDLive
				, tmp.FollowingLevelIDLive
				, tmp.FollowingValueNonLive
				, tmp.FollowingCustIDNonLive
				, tmp.FollowingLevelIDNonLive
				, tmp.SortOrder
		FROM OPENXML (@LogDocHandler, '/Root/r',1) 
		WITH (
			IsNew BIT --IsNew
			, VRLeagueGroupID SMALLINT --VRLeagueGroupID
			, VRBetTypeGroupID SMALLINT --VRBetTypeGroupID
			, BetType SMALLINT --BetType
			, LevelID INT --LevelID
			, ValueLive SMALLMONEY --ValueLive
			, FollowingValueLive SMALLMONEY --FollowingValueLive
			, FollowingCustIDLive INT --FollowingCustID
			, FollowingLevelIDLive INT --FollowingLevelID
			, ValueNonLive SMALLMONEY --ValueNonLive
			, FollowingValueNonLive SMALLMONEY --FollowingValueNonLive
			, FollowingCustIDNonLive INT --FollowingCustID
			, FollowingLevelIDNonLive INT --FollowingLevelID
			, SortOrder SMALLINT
		) AS tmp

		EXEC sp_xml_removedocument @LogDocHandler
	END


	SELECT m.LogID, m.LogTime UpdateTime, u.username UpdateBy
		, @SportType SportType
		, d.LevelID
		, d.VRLeagueGroupID
		, d.VRBetTypeGroupID
		, d.BetType
		, d.IsNew
		, d.FollowingValueLive Live_FollowingValue
		, CASE 
				WHEN d.FollowingCustIDLive = 0 THEN 'Global'
				WHEN d.FollowingCustIDLive = @CustID THEN NULL
				WHEN cl.roleid = 4 THEN 'Super'
				WHEN cl.roleid = 3 THEN 'Master'
				WHEN cl.roleid = 2 THEN 'Agent'
			END Live_FollowingRole
	FROM #VRCustLog m
		INNER JOIN #Data d ON m.LogID = d.LogID
		INNER JOIN bodb02..Customer u (NOLOCK) ON u.custid = m.UserID
		LEFT JOIN bodb02..Customer cl (NOLOCK) ON cl.custid = d.FollowingCustIDLive
		LEFT JOIN bodb02..Customer cnl (NOLOCK) ON cnl.custid = d.FollowingValueNonLive
	ORDER BY m.LogID, d.SortOrder, IsNew


	DROP TABLE #VRCustLog
	DROP TABLE #VRLineCustID
	DROP TABLE #Data
	
--END
