/*<info serverAlias="DBGLOB-GlobCustDB" selecters="wsv_nap, wsv_alp, wsv_xnap, wsv_alpv" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus TINYINT)  
RETURNS TABLE
AS
/*
	Created:	20221121@Eden
	Database:	DBCust/CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB,DBGLOB-GlobCustDB
	
	Revision:
		- 20221121@Eden: Init function [RedmineID: #180640]
		- 20240521@Helios: Unify RNG Games - Move from table ProductSettingDetail to ProductSettingProfile [Redmine: #204358] 
		- 20250224@Tacy: Deploy on GlobCustDB [RedmineID: #216870]
	Param's Explanation:
	SELECT * FROM dbo.f_CustSetting_ProductSettingDetailSel(3)
*/
RETURN
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType
	FROM CustDB.dbo.ProductSettingProfile WITH(NOLOCK)
	WHERE SettingStatus <= CASE WHEN @SettingStatus = 1 THEN 1
								WHEN @SettingStatus = 0 THEN 0
								ELSE NULL END 
		AND SettingStatus <> 2
	UNION ALL
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder, SubType
	FROM CustDB.dbo.ProductSettingProfile_UAT WITH(NOLOCK)
	WHERE @SettingStatus = 3
		AND SettingStatus <> 2
GO