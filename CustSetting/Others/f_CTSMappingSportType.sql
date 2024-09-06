/*<info serverAlias="DBCust-CustDB,DBSIG-CustDB,DBACC-bodb02,dbext-bodb02,dbbof-bodb02,dbwh-bodb02" selecters="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[f_CTSMappingSportType] (	@SportType SMALLINT )
RETURNS TABLE 
AS
/*
	Created: 20240904@Winfred
	Database: DBCust-CustDB
	
	Revision:
		-20240904@Winfred : Update SportID of CustomerClassSetting Feature name[redmine: #210321]

	Param's Explanation:
	Ex:
	 SELECT * FROM dbo.f_CTSMappingSportType (145)
*/
RETURN 
(
	SELECT @SportType AS SportCTS, CAST(CASE WHEN @SportType = 145 THEN 9901	 --Saba Soccer
											 WHEN @SportType = 912 THEN 9902	 --Saba Basketball
											 WHEN @SportType = 107 THEN 9921	 --Parlay
											 ELSE @SportType END AS SMALLINT) AS SportType
)
GO
