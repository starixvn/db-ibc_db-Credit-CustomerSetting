/*
	Created: 20170801@Elodie
	Task: Update product profile for BetRadar VS and Inspired VS
	DB: DBCUST/CustDB
*/

USE CustDB
GO

UPDATE ps
SET ps.SettingStatus = 0
FROM dbo.ProductSettingDetail ps WITH(ROWLOCK,UPDLOCK)
WHERE ProductID = 5