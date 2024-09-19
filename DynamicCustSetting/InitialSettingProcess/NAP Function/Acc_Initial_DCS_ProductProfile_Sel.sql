/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_ProductProfile_Sel]
AS
/*
	Created: 20211011@Eden
	Task : Get Product Profile maxtrix
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 
	- 20240520@Eden: Unify RNG Games [redmine: #204358]

	Parameter Definition

	Example: 
		EXEC [Acc_Initial_DCS_ProductProfile_Sel] 

	*/
BEGIN
	SET NOCOUNT ON

	SELECT cf.SettingType
		,cf.SportType
		,cf.BetType
		,cf.IsLive
		,cf.ProductID
		,SettingName = CASE WHEN cf.SettingType = 12 THEN 'Loss Limit' ELSE t.SettingName END
		,cf.MaxDiscount
		,cf.IntervalValue
	FROM  ProductSettingProfile cf WITH(NOLOCK)
		INNER JOIN ProductSettingType t WITH(NOLOCK) ON cf.SettingType = t.SettingType
		AND cf.SettingType NOT IN (2,9,16) --no need support copy data from difference tables with settingtype = 23
	WHERE cf.ProductID <> 1 
END
GO


