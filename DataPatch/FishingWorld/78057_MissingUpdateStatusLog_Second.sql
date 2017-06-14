/*
	Created: 20170614@Elodie
	Task: Generate log for SP Acc_CustSetting_DisableNewProductStatusUpd (ActionID = 1161)
	DB: DBLOG/bodb_CustomerLog
*/
USE bodb_CustomerLog
GO

DECLARE @ProductID		TINYINT = 24,
		@ProductName	VARCHAR(50) = 'Fishing World'

CREATE TABLE #LogTmp (LogID BIGINT, userID INT, CustID INT, IP VARCHAR(50),
						TrackingValue NVARCHAR(MAX), TrackingValue2 NVARCHAR(MAX), xmlNew XML, xmlOld XML,
						IsDisableBefore BIT, IsDisableAfter BIT, 
						IsDisableDownlineBefore BIT, IsDisableDownlineAfter BIT)

-- 3582 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID, IP,IsDisableBefore, IsDisableAfter, IsDisableDownlineBefore, IsDisableDownlineAfter)
SELECT LogID, userid, custid
FROM dbo.UserLog_RunSP WITH (NOLOCK)
WHERE ActionID = 1161 AND TrackingValue IS NULL

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

SELECT *
FROM #LogTmp

UPDATE lgTbl
SET lgTbl.TrackingValue = lg.TrackingValue,
	lgTbl.TrackingValue2 = lg.TrackingValue2
FROM dbo.UserLog_RunSP lgTbl WITH (ROWLOCK, UPDLOCK)
	INNER JOIN #LogTmp lg ON lg.LogID = lgTbl.logid AND lg.CustID = lgTbl.custid
WHERE ActionID = 1161 --AND lg.custid = 24624300

--DROP TABLE #LogTmp

--SELECT LogID, userID, CustID
--FROM UserLog_RunSP WITH (NOLOCK)
--WHERE userid = 11742728
--	AND ActionID = 1161
--	AND TrackingValue IS NULL