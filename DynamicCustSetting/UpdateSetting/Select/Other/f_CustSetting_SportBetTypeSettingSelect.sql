/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID TINYINT, @SettingType SMALLINT, @SettingStatus TINYINT) 
RETURNS @SportBetTypeSetting TABLE (ProductID TINYINT, SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
/*
	Created by: Elodie
	Date: 20170317
	Task: Get setting of product
	DB: DBCust/CustDB, DBAGE/bodb02, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20170317@Elodie: Get setting of product
		- 20200403@Elodie: Get RealProductID [Redmine: #129440]
		- 20201009@Tina: Add new para @SettingStatus [Redmine: #143077]
	Explanation's Param:
		
*/   
BEGIN 
	INSERT @SportBetTypeSetting
	SELECT DISTINCT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId FROM dbo.ProductSettingDetail WITH(NOLOCK)
	WHERE (@ProductID IS NULL OR ProductID = @ProductID ) AND (@SettingType IS NULL OR SettingType = @SettingType) 
			AND SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
	
	RETURN
END
GO

