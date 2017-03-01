/*
	Created: 20170104@Elodie
	Task: Correct Hidden field of Allbet
	DB: DBCUST/CustDB
*/
USE CustDB
GO

---- Starting DATA PREPARATION
SELECT custid
INTO #SuperList
FROM dbo.custInfo WITH (NOLOCK)
WHERE custid NOT IN (SELECT custid FROM dbo.Dep_CustSuper WITH (NOLOCK))
	AND roleid = 4

--Super level HideNormal <> HideVIP
SELECT cs.CustID, HideNormal.value AS HideNormal, HideVIP.value AS HideVIP, SyncedNormal.value AS SyncedNormal, SyncedVIP.value AS SyncedVIP, ISDisabledNormal.value AS ISDisabledNormal, ISDisabledVIP.value AS ISDisabledVIP
INTO #SuperStatus
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.custid
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,6)) AS SyncedNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,7)) AS SyncedVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,6)) AS ISDisabledNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,7)) AS ISDisabledVIP
WHERE ci.roleid = 4 AND HideNormal.value <> HideVIP.value
	AND ci.Enabled = 1
	
--Master level HideNormal <> HideVIP
SELECT cs.CustID, HideNormal.value AS HideNormal, HideVIP.value AS HideVIP, SyncedNormal.value AS SyncedNormal, SyncedVIP.value AS SyncedVIP, ISDisabledNormal.value AS ISDisabledNormal, ISDisabledVIP.value AS ISDisabledVIP
INTO #MasterStatus
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,6)) AS SyncedNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,7)) AS SyncedVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,6)) AS ISDisabledNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,7)) AS ISDisabledVIP
WHERE ci.roleid = 3 AND HideNormal.value <> HideVIP.value
	AND ci.Enabled = 1

--Agent level HideNormal <> HideVIP
SELECT cs.CustID, HideNormal.value AS HideNormal, HideVIP.value AS HideVIP, SyncedNormal.value AS SyncedNormal, SyncedVIP.value AS SyncedVIP, ISDisabledNormal.value AS ISDisabledNormal, ISDisabledVIP.value AS ISDisabledVIP
INTO #AgentStatus
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,6)) AS SyncedNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,7)) AS SyncedVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,6)) AS ISDisabledNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,7)) AS ISDisabledVIP
WHERE ci.roleid = 2 AND HideNormal.value <> HideVIP.value
	AND ci.Enabled = 1

--Member level HideNormal <> HideVIP
SELECT cs.CustID, HideNormal.value AS HideNormal, HideVIP.value AS HideVIP, SyncedNormal.value AS SyncedNormal, SyncedVIP.value AS SyncedVIP, ISDisabledNormal.value AS ISDisabledNormal, ISDisabledVIP.value AS ISDisabledVIP
INTO #MemberStatus
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,6)) AS SyncedNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapHasSynced,7)) AS SyncedVIP
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,6)) AS ISDisabledNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled,7)) AS ISDisabledVIP
WHERE ci.roleid = 1 AND HideNormal.value <> HideVIP.value
	AND ci.Enabled = 1

---- End DATA PREPARATION

--check data
DECLARE @RowCount INT

SELECT @RowCount = COUNT(1)
FROM #SuperStatus
WHERE SyncedNormal <> SyncedVIP

IF @RowCount <> 0
	PRINT 'SuperLevel: SyncedNormal <> SyncedVIP ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #MasterStatus
WHERE SyncedNormal <> SyncedVIP

IF @RowCount <> 0
	PRINT 'MasterLevel: SyncedNormal <> SyncedVIP ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #AgentStatus
WHERE SyncedNormal <> SyncedVIP

IF @RowCount <> 0
	PRINT 'AgentLevel: SyncedNormal <> SyncedVIP ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #MemberStatus
WHERE SyncedNormal <> SyncedVIP

IF @RowCount <> 0
	PRINT 'MemberLevel: SyncedNormal <> SyncedVIP ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #SuperStatus
WHERE (HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0)

IF @RowCount <> 0
	PRINT 'SuperLevel: HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0) ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #MasterStatus
WHERE (HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0)

IF @RowCount <> 0
	PRINT 'MasterLevel: HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0) ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #AgentStatus
WHERE (HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0)

IF @RowCount <> 0
	PRINT 'AgentLevel: HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0) ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

SELECT @RowCount = COUNT(1)
FROM #MemberStatus
WHERE (HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0)

IF @RowCount <> 0
	PRINT 'MemberLevel: HideNormal = 0 OR HideVIP = 0) AND (SyncedNormal = 0 OR SyncedVIP = 0) ' + CAST(@RowCount AS VARCHAR(10)) + ' affected rows'

--END check data

