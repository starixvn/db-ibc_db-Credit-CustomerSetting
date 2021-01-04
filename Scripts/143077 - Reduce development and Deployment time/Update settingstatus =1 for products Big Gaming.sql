/*
	Created by: Tina
	Date: 20210104
	Task: Reduce development and Deployment time while integrating new DCS products [RedmineID: #143077]
	Server: DBCUST
	Database: CustDB
*/
GO
UPDATE D SET D.SettingStatus = 1
FROM ProductSettingDetail D WITH (ROWLOCK)
WHERE SportType = 239 and BetType = 3501

GO

