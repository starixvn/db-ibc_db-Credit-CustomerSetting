/*
	Created: 20170614@Elodie
	Task: Generate log for SP Acc_CustSetting_DisableNewProductStatusUpd (ActionID = 1161)
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO

CREATE TABLE #LogTmp (LogID BIGINT, userID INT, SubAcc VARCHAR(30), CustID INT, IP VARCHAR(50),
						TrackingValue NVARCHAR(MAX), TrackingValue2 NVARCHAR(MAX), xmlNew XML, xmlOld XML,
						IsDisableBefore BIT, IsDisableAfter BIT, 
						IsDisableDownlineBefore BIT, IsDisableDownlineAfter BIT)

CREATE TABLE #InputTmp (LogID BIGINT, IsDisableBefore BIT, IsDisableAfter BIT, IsDisableDownlineBefore BIT, IsDisableDownlineAfter BIT, SubAcc VARCHAR(30), IP VARCHAR(50))

INSERT INTO #InputTmp (LogID, IsDisableBefore, IsDisableAfter, IsDisableDownlineBefore, IsDisableDownlineAfter, SubAcc, IP)
SELECT 481953589,0,1,1,1,'','121.127.16.91' UNION ALL
SELECT 481978877,0,1,1,1,'','121.127.16.91' UNION ALL
SELECT 483599057,0,1,0,1,'','36.37.232.115' UNION ALL
SELECT 485558069,0,1,0,1,'','121.127.16.91' 

-- 4 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID)
SELECT LogID, userid, ul.custid
FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
	INNER JOIN bodb02.dbo.CustInfo ci WITH (NOLOCK) ON ul.custid = ci.custid
WHERE ActionID = 1161 AND TrackingValue IS NULL
	AND ci.currency <> 20 AND ci.roleid = 4

UPDATE l
SET l.IsDisableBefore = tmp.IsDisableBefore,
	l.IsDisableAfter = tmp.IsDisableAfter,
	l.IsDisableDownlineBefore = tmp.IsDisableDownlineBefore,
	l.IsDisableDownlineAfter = tmp.IsDisableDownlineAfter,
	l.SubAcc = tmp.SubAcc,
	l.IP = tmp.IP
FROM #LogTmp l
	INNER JOIN #InputTmp tmp ON l.LogID = tmp.LogID

DECLARE @ProductID		TINYINT = 24,
		@ProductName	VARCHAR(50) = 'Fishing World'

UPDATE lg
SET xmlOld =  (
					SELECT	@ProductID						AS '@ProductID',
							@ProductName					AS '@ProductName',
							lg1.CustID						AS '@CustID',
							UserID							AS '@UserID',
							lg1.SubAcc						AS '@SubAccName',
							IP								AS '@IP',
							(
								SELECT	@ProductID				AS '@ProductID',
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
							lg1.CustID						AS '@CustID',
							UserID							AS '@UserID',
							lg1.SubAcc						AS '@SubAccName',
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