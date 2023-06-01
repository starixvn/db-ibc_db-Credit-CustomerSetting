/*<info serverAlias="DBCust-CustDB" selecters="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_LiteMode_CustSetting_SportBettypeFilterSelect(@GroupID TINYINT, @GroupType SMALLINT, @SubGroupID TINYINT =NULL, @CreationStatus TINYINT) 
RETURNS @SportBetTypeSetting TABLE (ProductID TINYINT, SportType SMALLINT, Bettype SMALLINT, IsLive BIT, IntervalValue DECIMAL(19,8),SubType TINYINT, Child_DisplayOrder INT)
/*
	Created by: 20230427@Johnson
	Task: Get sport-bettype by product group for Lite Mode
	DB: DBCust/CustDB
	
	Revisions:
		- 20230427@Johnson: Initial sp [redmine: #179159]
	Explanation's Param:
		@CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO
		
*/   
BEGIN 
	IF @CreationStatus IN (1,0)
	BEGIN
		INSERT @SportBetTypeSetting(ProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder)
		SELECT DISTINCT ProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder
		FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
	END
	ELSE IF @CreationStatus = 3
	BEGIN
		INSERT @SportBetTypeSetting(ProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder)
		SELECT DISTINCT ProductID, SportType,Bettype,IsLive,IntervalValue,SubType,Child_DisplayOrder
		FROM dbo.ProductSettingDetail_UAT WITH(NOLOCK)
		WHERE GroupID = @GroupID
			AND GroupType = @GroupType
			AND 1 = CASE WHEN @SubGroupID IS NULL OR @SubGroupID = SubGroupID THEN 1 ELSE 0 END
			AND CreationStatus <> 2
	END
	
	RETURN
END