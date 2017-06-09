/*
	Created: 20170609@Elodie
	Task: Generate log of adminut1 (custid = 11742728)for SP Acc_CustSetting_DisableNewProductStatusUpd (ActionID = 1161)
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

-- 33 affected rows
INSERT INTO #LogTmp (LogID, userID, CustID, IP,IsDisableBefore, IsDisableAfter, IsDisableDownlineBefore, IsDisableDownlineAfter)
VALUES (488059941,11742728,24624300,'27.67.2.93',1,0,1,0),
		(487695133,11742728,26072536,'27.67.9.69',1,0,1,0),
		(487696200,11742728,26072541,'27.67.9.69',1,0,1,0),
		(482683373,11742728,19294581,'36.37.234.96',1,0,1,0),
		(482230117,11742728,19346110,'36.37.233.156',1,0,1,0),
		(482684873,11742728,21596584,'36.37.234.96',1,0,1,0),
		(484134072,11742728,21986214,'36.37.232.115',1,0,1,0),
		(485214874,11742728,22017053,'36.37.239.79',1,0,1,0),
		(486422586,11742728,22017057,'27.67.20.159',1,0,1,0),
		(485573944,11742728,22818855,'36.37.239.79',1,0,1,0),
		(480309570,11742728,24568913,'36.37.235.92',1,0,1,0),
		(480576954,11742728,25943478,'36.37.206.85',1,0,1,0),
		(480578843,11742728,25943484,'36.37.206.85',1,0,1,0),
		(480580411,11742728,25943490,'36.37.206.85',1,0,1,0),
		(483210309,11742728,26072192,'36.37.232.115',1,0,1,0),
		(483213294,11742728,26072516,'36.37.232.115',1,0,1,0),
		(483214655,11742728,26072522,'36.37.232.115',1,0,1,0),
		(486120160,11742728,26072529,'36.37.239.79',1,0,1,0),
		(486121369,11742728,26072530,'36.37.239.79',1,0,1,0),
		(484604202,11742728,26072552,'36.37.232.115',1,0,1,0),
		(483423068,11742728,26077315,'36.37.232.115',1,0,1,0),
		(485280391,11742728,26077334,'36.37.239.79',1,0,1,0),
		(485473392,11742728,26077337,'36.37.239.79',1,0,1,0),
		(485498034,11742728,26077338,'36.37.235.250',1,0,1,0),
		(485507889,11742728,26077339,'36.37.239.79',1,0,1,0),
		(484608781,11742728,26118248,'36.37.232.115',1,0,1,0),
		(485003242,11742728,26118278,'36.37.239.79',1,0,1,0),
		(486156429,11742728,26118281,'36.37.239.79',1,0,1,0),
		(486379463,11742728,26118284,'27.67.24.55',1,0,1,0),
		(486380247,11742728,26118287,'27.67.24.55',1,0,1,0),
		(485900561,11742728,26164667,'36.37.239.79',1,0,1,0),
		(485902063,11742728,26164786,'36.37.239.79',1,0,1,0),
		(486378457,11742728,26183686,'27.67.24.55',1,0,1,0)

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