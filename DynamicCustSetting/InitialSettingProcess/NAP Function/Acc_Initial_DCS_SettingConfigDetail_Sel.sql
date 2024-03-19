/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfigDetail_Sel]
	@ConfigID INT
AS
/*
	Created: 20211011@Eden
	Task : View Initial Setting config detail
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 

	Parameter Definition

	Example: 
		EXEC [Acc_Initial_DCS_SettingConfigDetail_Sel] 
			@ConfigID = 18
	
	Mapping site : DBAGE.bodb02..Acc_SiteSel_Credit
	Mapping Currency : DBAGE.bodb02..Acc_ExchangeCurrencySel
	*/
BEGIN
	SET NOCOUNT ON

	SELECT ConfigID
		,ProductID
		,SportTypeList
		,BetTypeList
		,Site
		,Currency
		,StartTime
		,EndTime
		,IsTest
		,Status
		,CurrentStep
		,ProcessedStep
		,Remark
	FROM  Initial_ProductConfig cf WITH(NOLOCK)
	WHERE ConfigID = @ConfigID

	SELECT cf.ConfigID
		,cf.SportType
		,cf.BetType
		,cf.IsLive
		,cf.SettingType
		,cf.IsDefault
		,cf.CopyFromSportType
		,cf.CopyFromBetType
		,cf.DefaultValueSuper
		,cf.DefaultValueMaster
		,cf.DefaultValueAgent
		,cf.DefaultValueMember
		,SpecialRequirement = CASE WHEN t.SettingName = 'Product Status' 
									THEN (SELECT STUFF(
													REPLACE(
														REPLACE((	SELECT c.username AS 'XMLHeadlineList'
																	FROM STRING_SPLIT(cf.SpecialRequirement,',') t
																		INNER JOIN CustInfo c(NOLOCK) ON t.value = c.custid
																	ORDER BY c.custid
																	FOR XML PATH('')
															),'<XMLHeadlineList>',','),'</XMLHeadlineList>', ''),1,1,'')) 
								ELSE cf.SpecialRequirement
								END
		,SettingName = CASE WHEN cf.SettingType = 12 THEN 'Loss Limit' ELSE t.SettingName END
	FROM  Initial_ProductConfig_Detail cf WITH(NOLOCK)
		INNER JOIN ProductSettingType t WITH(NOLOCK) ON cf.SettingType = t.SettingType
	WHERE ConfigID = @ConfigID
	OPTION (MAXRECURSION 0)
END
GO


