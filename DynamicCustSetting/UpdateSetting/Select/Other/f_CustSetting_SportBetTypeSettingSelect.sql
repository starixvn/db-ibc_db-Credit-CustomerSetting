/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID TINYINT, @SettingType SMALLINT, @SettingStatus TINYINT) 
RETURNS @SportBetTypeSetting TABLE (ProductID TINYINT, SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, RealProductId TINYINT, SubType TINYINT, Child_DisplayOrder INT)
/*
	Created by: Elodie
	Date: 20170317
	Task: Get setting of product
	DB: DBCust/CustDB, DBAGE/bodb02, DBACC/bodb02,DBTXN-CustDB
	Original: 
	
	Revisions:
		- 20170317@Elodie: Get setting of product
		- 20200403@Elodie: Get RealProductID [Redmine: #129440]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20240521@Helios: Unify RNG Games - Move from table ProductSettingDetail to ProductSettingProfile [Redmine: #204358]
	Explanation's Param:
		@SettingStatus: 0: Pro, 1: UAT
		
*/   
BEGIN 
	IF @SettingStatus IN (1,0)
	BEGIN
		INSERT @SportBetTypeSetting(ProductID, SportType,Bettype,IsLive, SettingType, RealProductId, SubType, Child_DisplayOrder)
		SELECT DISTINCT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId, SubType, Child_DisplayOrder 
		FROM dbo.ProductSettingProfile WITH(NOLOCK)
		WHERE (@ProductID IS NULL OR ProductID = @ProductID ) AND (@SettingType IS NULL OR SettingType = @SettingType) 
				AND SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END
	END
	ELSE IF @SettingStatus = 3
	BEGIN
		INSERT @SportBetTypeSetting(ProductID, SportType,Bettype,IsLive, SettingType, RealProductId, SubType, Child_DisplayOrder)
		SELECT DISTINCT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId, SubType, Child_DisplayOrder 
		FROM dbo.ProductSettingProfile_UAT WITH(NOLOCK)
		WHERE (@ProductID IS NULL OR ProductID = @ProductID ) AND (@SettingType IS NULL OR SettingType = @SettingType) 
			AND SettingStatus <> 2
	END
	
	RETURN
END
GO

