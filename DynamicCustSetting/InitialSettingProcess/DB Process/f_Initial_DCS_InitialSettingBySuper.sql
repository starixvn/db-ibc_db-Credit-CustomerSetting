/*<info serverAlias="DBCust-CustDB,DBSIG-CustDB,DBACC-bodb02,dbext-bodb02,dbbof-bodb02,dbwh-bodb02" selecters="" viewers="" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[f_Initial_DCS_InitialSettingBySuper] (@Currency INT)
RETURNS TABLE 
AS
/*
	Created: 20241122@Elodie
	Database: DBCust-CustDB
	
	Revision:
		-20241122@Elodie : Initial function [Redmine: #214128]

	Param's Explanation:
	Ex: SELECT * FROM dbo.f_Initial_DCS_InitialSettingBySuper (20)
*/
RETURN 
(
	SELECT CustId
	FROM custinfo WITH (NOLOCK)
	WHERE currency = @Currency 
		AND custid = 1176070 -- Hardcode direct account to initial setting
)
GO
