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

CREATE TABLE #CustListHideNormal (CustID INT)
CREATE TABLE #CustListHideVIP (CustID INT)

--Super level HideNormal.value = 1 AND HideVIP.value = 0
INSERT INTO #CustListHideNormal (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.custid
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 4 AND HideNormal.value = 1 AND HideVIP.value = 0
	AND ci.Enabled = 1
	
--Master level HideNormal.value = 1 AND HideVIP.value = 0
INSERT INTO #CustListHideNormal (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 3 AND HideNormal.value = 1 AND HideVIP.value = 0
	AND ci.Enabled = 1

--Agent level HideNormal.value = 1 AND HideVIP.value = 0
INSERT INTO #CustListHideNormal (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 2 AND HideNormal.value = 1 AND HideVIP.value = 0
	AND ci.Enabled = 1

--Member level HideNormal.value = 1 AND HideVIP.value = 0
INSERT INTO #CustListHideNormal (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 1 AND HideNormal.value = 1 AND HideVIP.value = 0
	AND ci.Enabled = 1

--Super level HideNormal.value = 0 AND HideVIP.value = 1
INSERT INTO #CustListHideVIP (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.custid
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 4 AND HideNormal.value = 0 AND HideVIP.value = 1
	AND ci.Enabled = 1
	
--Master level HideNormal.value = 0 AND HideVIP.value = 1
INSERT INTO #CustListHideVIP (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 3 AND HideNormal.value = 0 AND HideVIP.value = 1
	AND ci.Enabled = 1

--Agent level HideNormal.value = 0 AND HideVIP.value = 1
INSERT INTO #CustListHideVIP (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 2 AND HideNormal.value = 0 AND HideVIP.value = 1
	AND ci.Enabled = 1

--Member level HideNormal.value = 0 AND HideVIP.value = 1
INSERT INTO #CustListHideVIP (CustID)
SELECT cs.CustID
FROM dbo.CustProductStatus cs WITH (NOLOCK)
	INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.CustID
	INNER JOIN #SuperList s ON s.custid = ci.srecommend
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,6)) AS HideNormal
	CROSS APPLY (SELECT * FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden,7)) AS HideVIP
WHERE ci.roleid = 1 AND HideNormal.value = 0 AND HideVIP.value = 1
	AND ci.Enabled = 1
---- End DATA PREPARATION

--1 affected row
UPDATE cs
SET cs.bitmapIsHidden = dbo.f_GenerateProductStatus(bitmapIsHidden, 6, 0) 
FROM dbo.CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
	INNER JOIN #CustListHideNormal tmp ON tmp.CustID = cs.CustID

--286 affected rows
UPDATE cs
SET cs.bitmapIsHidden = dbo.f_GenerateProductStatus(bitmapIsHidden, 7, 0) 
FROM dbo.CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
	INNER JOIN #CustListHideVIP tmp ON tmp.CustID = cs.CustID

--END check data

