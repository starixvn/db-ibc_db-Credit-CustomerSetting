/*
	Created: 20170614@Elodie
	Task: Generate log for SP Acc_CustSetting_DisableNewProductStatusUpd (ActionID = 1161)
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO

CREATE TABLE #LogTmp (LogID BIGINT, userID INT, CustID INT, IP VARCHAR(50), LogDate DATETIME, LogDate_Login DATETIME,
						TrackingValue NVARCHAR(MAX), TrackingValue2 NVARCHAR(MAX), xmlNew XML, xmlOld XML,
						IsDisableBefore BIT, IsDisableAfter BIT, 
						IsDisableDownlineBefore BIT, IsDisableDownlineAfter BIT)

CREATE TABLE #InputTmp (LogID BIGINT, IsDisableBefore BIT, IsDisableAfter BIT, IsDisableDownlineBefore BIT, IsDisableDownlineAfter BIT)

INSERT INTO #InputTmp (LogID, IsDisableBefore, IsDisableAfter, IsDisableDownlineBefore, IsDisableDownlineAfter)
SELECT 481953589,0,1,0,1 UNION ALL
SELECT 481978877,0,1,0,1 UNION ALL
SELECT 483599057,0,1,0,1 UNION ALL
SELECT 485558069,1,0,1,0 

-- 127 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID, LogDate)
SELECT LogID, userid, ul.custid, logdate
FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
	INNER JOIN bodb02.dbo.CustInfo ci WITH (NOLOCK) ON ul.custid = ci.custid
WHERE ActionID = 1161 AND TrackingValue IS NULL
	AND ci.currency <> 20 AND ci.roleid = 2
	AND ul.custid NOT IN (26031370) --Exclude agent who have over one log

UPDATE l
SET l.LogDate_Login = a.LogDate
FROM #LogTmp l
	CROSS APPLY (SELECT MAX(LogDate) LogDate FROM dbo.UserLog_Login ul WITH (NOLOCK) WHERE l.userID = ul.UserID AND l.LogDate > ul.LogDate AND ul.ActionID IN (1310,1303,1306)) AS a

UPDATE l
SET IP = lg.IP
FROM #LogTmp l
	INNER JOIN dbo.UserLog_Login lg WITH (NOLOCK) ON l.userID = lg.UserID AND l.LogDate_Login = lg.LogDate AND ActionID IN (1310,1303,1306)

UPDATE l
SET l.IsDisableBefore = tmp.IsDisableBefore,
	l.IsDisableAfter = tmp.IsDisableAfter,
	l.IsDisableDownlineBefore = tmp.IsDisableDownlineBefore,
	l.IsDisableDownlineAfter = tmp.IsDisableDownlineAfter
FROM #LogTmp l
	INNER JOIN #InputTmp tmp ON l.LogID = tmp.LogID

DECLARE @ProductID		TINYINT = 24,
		@ProductName	VARCHAR(50) = 'Fishing World'

UPDATE lg
SET xmlOld =  (
					SELECT	@ProductID						AS '@ProductID',
							@ProductName					AS '@ProductName',
							CustID							AS '@CustID',
							UserID							AS '@UserID',
							''								AS '@SubAccName',
							IP								AS '@IP',
							(
								SELECT	@ProductID			AS '@ProductID',
										IsDisableBefore			AS '@IsDisabled',
										IsDisableDownlineBefore	AS '@IsDisabledDownline'
								FROM #LogTmp lg2
								WHERE lg2.LogID = lg.LogID
								FOR XML PATH('ProductStatus'),
								TYPE
							)
					FROM #LogTmp lg1
					WHERE lg1.LogID = lg.LogID
					FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
					TYPE
				)
		,xmlNew =  (
					SELECT	@ProductID						AS '@ProductID',
							@ProductName					AS '@ProductName',
							CustID							AS '@CustID',
							UserID							AS '@UserID',
							''								AS '@SubAccName',
							IP								AS '@IP',
							(
								SELECT	@ProductID					AS '@ProductID',
										IsDisableAfter				AS '@IsDisabled',
										IsDisableDownlineAfter		AS '@IsDisabledDownline'
								FROM #LogTmp lg2
								WHERE lg2.LogID = lg.LogID
								FOR XML PATH('ProductStatus'),
								TYPE
							)
					FROM #LogTmp lg1
					WHERE lg1.LogID = lg.LogID
					FOR XML PATH('Acc_CustSetting_DisableNewProductStatusUpd'),
					TYPE
				)
FROM #LogTmp lg

UPDATE lg
SET TrackingValue2 = REPLACE(CONVERT(VARCHAR(MAX), xmlOld), '" />', '"/"'),
	TrackingValue = REPLACE(CONVERT(VARCHAR(MAX), xmlNew), '" />', '"/"')
FROM #LogTmp lg

UPDATE lgTbl
SET lgTbl.TrackingValue = lg.TrackingValue,
	lgTbl.TrackingValue2 = lg.TrackingValue2
FROM dbo.UserLog_RunSP lgTbl WITH (ROWLOCK, UPDLOCK)
	INNER JOIN #LogTmp lg ON lg.LogID = lgTbl.logid AND lg.CustID = lgTbl.custid
WHERE ActionID = 1161 --AND lg.custid = 24624300

--DROP TABLE #LogTmp

--SELECT * FROM #LogTmp

--SELECT LogID, userID, CustID
--FROM UserLog_RunSP WITH (NOLOCK)
--WHERE userid = 11742728
--	AND ActionID = 1161
--	AND TrackingValue IS NULL