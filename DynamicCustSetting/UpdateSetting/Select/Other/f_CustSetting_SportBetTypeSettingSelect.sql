/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="1"></info>*/
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
		- 20200427@Tiara: Allbet/GD multiple stakelevels for member [#131171]
	Explanation's Param:
		
*/   
BEGIN 
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
			AND SportType NOT IN (211,243,244)
	UNION ALL
	--Allbet
	SELECT DISTINCT 41,211, 2401, 0, @SettingType, 21
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IN (1,3,6,17,13) 
	UNION ALL
	--SA Gaming
	SELECT DISTINCT 41,244, 3001, 0, @SettingType, 39 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IN (1,3,6,17,13) 
	UNION ALL
	--Sexy Gaming
	SELECT DISTINCT 41,243, 3101, 0, @SettingType, 45 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IN (1,3,6,17,13) 
	UNION ALL
	--Allbet
	SELECT DISTINCT 41,211, 2401, 0, 1, 21 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,211, 2401, 0, 3, 21 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL		
	SELECT DISTINCT 41,211, 2401, 0, 13, 21 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL		
	SELECT DISTINCT 41,211, 2401, 0, 6, 21 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL	
	SELECT DISTINCT 41,211, 2401, 0, 17, 21 
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL		
	--SA Gaming
	SELECT DISTINCT 41,244, 3001, 0, 1, 39
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,244, 3001, 0, 3, 39
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,244, 3001, 0, 13, 39
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,244, 3001, 0, 6, 39
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,244, 3001, 0, 17, 39
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	 --Sexy Gaming
	SELECT DISTINCT 41,243, 3101, 0, 1, 45
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,243, 3101, 0, 3, 45
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,243, 3101, 0, 13, 45
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,243, 3101, 0, 6, 45
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL
	UNION ALL
	SELECT DISTINCT 41,243, 3101, 0, 17, 45
	WHERE (@ProductID IS NULL OR @ProductID = 41) AND @SettingType IS NULL

	RETURN
END
GO

