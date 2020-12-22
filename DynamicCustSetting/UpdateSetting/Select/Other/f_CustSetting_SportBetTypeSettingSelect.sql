/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID TINYINT, @SettingType SMALLINT) 
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
	Explanation's Param:
		
*/   
BEGIN 
	IF dbo.f_CheckRepTable('ProductSettingDetail') = 0
		RETURN

	DECLARE @isTest BIT,@SQL NVARCHAR(100) = OBJECT_NAME(@@PROCID)

	IF  (@SQL like '%_xtest%' 
			OR  @SQL like '%_xpre%' 
			OR  @SQL like '%_uat1%'
			OR  @SQL like '%_uat2%'
			OR  @SQL like '%_uat3%'
			OR  @SQL like '%_uat4%')
	BEGIN
		SELECT @isTest = 1
	END
	ELSE
	BEGIN
		SELECT @isTest = 0
	END
	
	INSERT @SportBetTypeSetting
	SELECT DISTINCT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId FROM dbo.ProductSettingDetail WITH(NOLOCK)
	WHERE (@ProductID IS NULL OR ProductID = @ProductID ) AND (@SettingType IS NULL OR SettingType = @SettingType) 
			AND SettingStatus <= CASE WHEN @isTest = 1 THEN 1 ELSE 0 END
	
	RETURN
END
GO

