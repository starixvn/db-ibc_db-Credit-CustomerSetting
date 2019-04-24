/*<info serverAlias="DBLOG-bodb_CustomerLog" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.CS_CustSetting_LegacyReportSettingHistory_Sel
	@CustID INT,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@IsTest BIT = 0
AS
/*
	Created: 20181212@Elodie
	Task : Get PT info history to show on legency report
	DB: DBLOG/bodb_CustomerLog
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190405@Patrick: Support archive date range [Redmine: #111476]
		
	Param's Explanation:
				
	Example: 
		EXEC CS_CustSetting_LegacyReportSettingHistory_Sel @CustID = 34109850, @IsTest = 1, @FromDate = '2019-02-27 02:31:54.380', @ToDate = '2019-02-28 02:31:54.380'
*/

BEGIN
	SET NOCOUNT ON
	CREATE TABLE #Log (LogId BIGINT, LogDate DATETIME, NewValue XML, OldValue XML)
	
	--SELECT @ToDate = DATEADD(ss,86399,@ToDate)

	CREATE TABLE #__tempData (LogId BIGINT, ActionID INT, LogDate DATETIME, TrackingValue NVARCHAR(MAX), TrackingValue2 NVARCHAR(MAX))

	DECLARE @__archiveDate DATETIME
	SELECT @__archiveDate = DATEADD(DAY, 1, dbo.f_CustomerLog_GetArchiveDate())

	IF @FromDate >= @__archiveDate
	BEGIN
		INSERT INTO #__tempData(LogId, ActionID, LogDate, TrackingValue, TrackingValue2)
		SELECT LogId, ActionID, LogDate, ul.TrackingValue, ul.TrackingValue2
		FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
		WHERE ul.custid = @CustID
			AND ul.logdate >= @FromDate AND logdate < DATEADD(DAY, 1, @ToDate)
	END
	ELSE IF @ToDate < @__archiveDate
	BEGIN
		INSERT INTO #__tempData(LogId, ActionID, LogDate, TrackingValue, TrackingValue2)
		SELECT LogId, ActionID, LogDate, ul.TrackingValue, ul.TrackingValue2
		FROM bodb_CustomerLog_Archive.dbo.UserLog_RunSP ul WITH (NOLOCK)
		WHERE ul.custid = @CustID
			AND ul.logdate >= @FromDate AND logdate < DATEADD(DAY, 1, @ToDate)
	END
	ELSE
	BEGIN
		INSERT INTO #__tempData(LogId, ActionID, LogDate, TrackingValue, TrackingValue2)
		SELECT LogId, ActionID, LogDate, ul.TrackingValue, ul.TrackingValue2
		FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
		WHERE ul.custid = @CustID
			AND ul.logdate >= @__archiveDate AND logdate < DATEADD(DAY, 1, @ToDate)

		UNION ALL
		SELECT LogId, ActionID, LogDate, ul.TrackingValue, ul.TrackingValue2
		FROM bodb_CustomerLog_Archive.dbo.UserLog_RunSP ul WITH (NOLOCK)
		WHERE ul.custid = @CustID
			AND ul.logdate >= @FromDate AND logdate < @__archiveDate
	END

	INSERT INTO #Log (LogId, LogDate, NewValue, OldValue)
	SELECT ul.LogId, ul.LogDate, ul.TrackingValue, ul.TrackingValue2
	FROM dbo.LogAction l WITH (NOLOCK)
		INNER JOIN dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
		INNER JOIN #__tempData ul WITH (NOLOCK) ON l.ActionID = ul.ActionID
	WHERE l.SPName = 'CS_CustSetting_PTSetting_Upd' AND ld.Level = 2
		AND DATEADD(HOUR,7,DATEADD(DAY, (DATEDIFF(DAY, 0, DATEADD(HOUR, -7, LogDate)) / 7) * 7 + 7, 0)) BETWEEN @FromDate AND DATEADD(ss,86399,@ToDate)

	--SELECT * FROM #Log 

	SELECT LogId, LogDate
			, n.value('./@SportType','SMALLINT') AS SportType
			, n.value('./@BetType','SMALLINT') AS BetType
			, n.value('./@IsLive','BIT') AS IsLive									
			, n.value('./@ProductID','SMALLINT') AS ProductID
			, n.value('./@MasterPT','SMALLMONEY') AS MasterPT	
	INTO #NewData
	FROM #Log
		CROSS APPLY NewValue.nodes('//C') AS RECORDS(n)
	
	SELECT LogId, o.value('./@MasterPT','SMALLMONEY') AS MasterPT		
	INTO #OldData
	FROM #Log
		CROSS APPLY OldValue.nodes('//C') AS RECORDS(o)
	
	SELECT DATEADD(HOUR,7,DATEADD(DAY, (DATEDIFF(DAY, 0, DATEADD(HOUR, -7, n.LogDate)) / 7) * 7 + 7, 0)) AS EffectiveDate,
		n.SportType, n.BetType, n.ProductID, 
		n.MasterPT * 100 AS NewPT, o.MasterPT * 100 AS OldPT 
	FROM #NewData n 
		INNER JOIN #OldData o ON o.LogId = n.LogId
	WHERE n.MasterPT <> o.MasterPT

	DROP TABLE #Log
	DROP TABLE #__tempData
	DROP TABLE #OldData
	DROP TABLE #NewData	
	--DROP TABLE #SportBettypeFilter1
END
GO
