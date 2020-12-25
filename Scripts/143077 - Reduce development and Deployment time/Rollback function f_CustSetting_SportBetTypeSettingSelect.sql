/*
	Created by: Tina
	Date: 20201224
	Task: Reduce development and Deployment time while integrating new DCS products [RedmineID: #143077]
	Server: DB04Admin1,DB04Admin2,DB05,DB052,DB053,DB054,DB055,DB05BK1,DB061,DB06C2\DB06,DBTP
	Database: bodb02
*/
GO
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

