/*<info serverAlias="DBCust-CustDB,DBACC-bodb02" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CS_SportBetTypeSettingSelect(@ProductID TINYINT, @SettingType SMALLINT, @isTest BIT) 
RETURNS TABLE 
/*
	Created by: Elodie
	Date: 20181212
	Task: Get setting of product
	DB: DBCust/CustDB, DBAGE/bodb02, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20181212@Elodie: Initial SP [Redmine: #105338]

	Explanation's Param:
		
*/   
RETURN 
	SELECT DISTINCT ProductID, SportType,Bettype,IsLive, SettingType FROM dbo.CS_ProductSettingDetail WITH(NOLOCK)
	WHERE (@ProductID IS NULL OR ProductID = @ProductID ) AND (@SettingType IS NULL OR SettingType = @SettingType) 
		AND SettingStatus <= @isTest
GO

