/*<info serverAlias="DBCust-CustDB" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(@CreationStatus TINYINT)  
RETURNS TABLE
AS
/*
	Created: 20230523@Johnson
	DB: DBCust/CustDB
	Task: Get product setting detail for LiteMode
	
	Revision:
		- 20230523@Johnson: Init function [RedmineID: #179159]

	Param's Explanation:
	SELECT * FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(3)
*/
RETURN
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType, CreationStatus
	FROM dbo.ProductSettingDetail WITH(NOLOCK)
	WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1
								WHEN @CreationStatus = 0 THEN 0
								ELSE NULL END 
		AND CreationStatus <> 2
	UNION ALL
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType, CreationStatus
	FROM dbo.ProductSettingDetail_UAT WITH(NOLOCK)
	WHERE @CreationStatus = 3
		AND CreationStatus <> 2
GO