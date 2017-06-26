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
SELECT 480779862,0,1,0,0,'','121.127.16.91' UNION ALL
SELECT 481422919,0,0,1,0,'','61.7.141.42' UNION ALL
SELECT 480923491,0,0,1,0,'','113.23.28.115' UNION ALL
SELECT 481527262,0,0,1,0,'SD68SDSub15','103.239.55.53' UNION ALL
SELECT 480639276,0,0,1,0,'','183.80.19.208' UNION ALL
SELECT 488122056,0,0,1,0,'','175.100.87.112' UNION ALL
SELECT 484364869,0,0,1,0,'','110.159.105.20' UNION ALL
SELECT 480815209,0,0,1,0,'','103.14.250.67' UNION ALL
SELECT 480815066,0,0,1,0,'','103.14.250.67' UNION ALL
SELECT 486893618,0,0,1,0,'','223.206.233.249' UNION ALL
SELECT 481076342,0,0,1,0,'','110.74.205.179' UNION ALL
SELECT 481076227,0,0,1,0,'','110.74.205.179' UNION ALL
SELECT 481076426,0,0,1,0,'','110.74.205.179' UNION ALL
SELECT 481072793,0,0,1,0,'','110.74.205.179' UNION ALL
SELECT 486097345,0,0,1,0,'','103.253.113.122' UNION ALL
SELECT 481077573,0,0,1,0,'','110.74.205.179' UNION ALL
SELECT 481080012,0,0,1,0,'','43.252.18.126' 

-- 17 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID)
SELECT LogID, userid, ul.custid
FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
	INNER JOIN bodb02.dbo.CustInfo ci WITH (NOLOCK) ON ul.custid = ci.custid
WHERE ActionID = 1161 AND TrackingValue IS NULL
	AND ci.currency <> 20 AND ci.roleid = 2
	AND ul.custid NOT IN (26031370) --Exclude agent who have over one log

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