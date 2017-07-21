/*	
	Creator: Elodie
	Date: 20170801
	Task: Copy permission Lottery from Keno for Ext Group
	DB: DBEAS/bodb_EAS
*/
USE bodb_EAS
GO

CREATE TABLE #GroupExt (GroupID INT)
CREATE TABLE #PermissionMapping (PermissionFrom SMALLINT, PermissionTo SMALLINT)

INSERT INTO #GroupExt (GroupID)
SELECT GroupID
FROM dbo.eaGroup WITH(NOLOCK)
WHERE GroupName IN ('ACCYEN'
					,'ACCYEN789'
					,'ACCYEN889'
					,'ACCYEN668'
					,'ACCNTD'
					,'ACCIRR'
					,'ACCUSD'
					,'ACCUT'
					,'ACCYEN888'
					,'ACCUT2'
					,'ACCUSDOTH')


INSERT INTO #PermissionMapping (PermissionFrom, PermissionTo)
SELECT 82, 104 --Keno ==> Edit NG2 Setting
UNION ALL SELECT 85, 105 --Keno Bet Setting ==> Edit NG2 Betting Limit
UNION ALL SELECT 81, 103 --Enable Keno ==> Enable NG2 Status

--SIT
--SELECT 82, 102 --Keno ==> Edit NG2 Setting
--UNION ALL SELECT 85, 103 --Keno Bet Setting ==> Edit NG2 Betting Limit
--UNION ALL SELECT 81, 101 --Enable Keno ==> Enable NG2 Status

UPDATE gpt
SET gpt.Policy = gpf.Policy
--SELECT *
FROM eaGroupPolicy gpf WITH (NOLOCK)
	INNER JOIN eaGroupPolicy gpt WITH (NOLOCK) ON gpt.GroupID = gpf.GroupID
	INNER JOIN #GroupExt g ON g.GroupID = gpf.GroupID
	INNER JOIN #PermissionMapping p ON gpf.FuncID = p.PermissionFrom AND gpt.FuncID = p.PermissionTo

UPDATE upt
SET upt.Policy = upf.Policy
--SELECT *
FROM eaUserPolicy upf WITH (NOLOCK)
	INNER JOIN eaUserPolicy upt WITH (NOLOCK) ON upt.UserID = upf.UserID
	INNER JOIN dbo.eaUserInfo u WITH (NOLOCK) ON u.UserID = upf.UserID
	INNER JOIN #GroupExt g ON u.GroupID = g.GroupID
	INNER JOIN #PermissionMapping p ON upf.FuncID = p.PermissionFrom AND upt.FuncID = p.PermissionTo

DROP TABLE #GroupExt
DROP TABLE #PermissionMapping