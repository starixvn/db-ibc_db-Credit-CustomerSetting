/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus TINYINT)  
RETURNS TABLE
AS
/*
	Created:	20221121@Eden
	Database:	DBCust/CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB
	
	Revision:
		- 20221121@Eden: Init function [RedmineID: #180640]
		- 20240521@Helios: Unify RNG Games - Move from table ProductSettingDetail to ProductSettingProfile [Redmine: #204358] 
		- 20251027@Eden: Adjust Live Casino PT & Commission [Redmine: #242260]

	Param's Explanation:
	SELECT * FROM dbo.f_CustSetting_ProductSettingDetailSel(3)
*/
RETURN
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType
	FROM dbo.ProductSettingProfile WITH(NOLOCK)
	WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1 ELSE 0 END 
		AND SettingStatus <> 2
	UNION
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType
	FROM dbo.ProductSettingProfile_UAT WITH(NOLOCK)
	WHERE @SettingStatus = 3
		AND SettingStatus <> 2
GO