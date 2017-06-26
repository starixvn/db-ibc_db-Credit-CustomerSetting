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
SELECT 487678890,1,0,0,0,'SD68SDXSSub03','120.136.26.18' UNION ALL
SELECT 481501030,0,1,0,0,'SD68SDXSSub06','103.239.55.53' UNION ALL
SELECT 486800540,0,1,0,0,'HPOWA77Sub38','46.101.45.172' UNION ALL
SELECT 486800570,1,0,0,0,'HPOWA77Sub38','46.101.45.172' UNION ALL
SELECT 484171226,0,1,0,0,'S69RDLB01Sub05','108.170.8.164' UNION ALL
SELECT 485222832,1,0,0,0,'S69RDLB01Sub04','103.45.253.3' UNION ALL
SELECT 487024884,0,1,0,0,'S69RDLB01Sub04','113.20.30.231' UNION ALL
SELECT 488131752,1,0,0,0,'S69RDLB01Sub04','113.20.30.231' UNION ALL
SELECT 480334931,0,1,0,0,'S69TBKK02Sub02','124.217.247.76' UNION ALL
SELECT 481227431,1,0,0,0,'S69TBKK02Sub02','203.90.242.146' UNION ALL
SELECT 482576740,0,1,0,0,'S69TBKK02Sub01','203.90.242.146' UNION ALL
SELECT 482814395,1,0,0,0,'S69TBKK02Sub02','203.90.242.146' UNION ALL
SELECT 487679594,0,1,0,0,'SD68SDXSSub03','120.136.26.18' UNION ALL
SELECT 482026393,1,0,1,1,'','115.164.51.217' UNION ALL
SELECT 482029933,0,0,1,0,'','115.164.51.217' UNION ALL
SELECT 482575457,1,0,1,1,'','115.132.103.184' UNION ALL
SELECT 482611332,0,0,1,0,'','115.132.103.184' UNION ALL
SELECT 482580877,1,0,1,1,'','115.132.103.184' UNION ALL
SELECT 482611337,0,0,1,0,'','115.132.103.184' 

-- 10 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID)
SELECT LogID, userid, ul.custid
FROM dbo.UserLog_RunSP ul WITH (NOLOCK)
	INNER JOIN bodb02.dbo.CustInfo ci WITH (NOLOCK) ON ul.custid = ci.custid
WHERE ActionID = 1161 AND TrackingValue IS NULL
	AND ci.currency <> 20 
	AND ul.custid IN (26016526,26197639,26102679,26205421,25985197,26054367,26035671,26031370,17258314,21245225)

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