/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_SettingConfig_Sel]
AS
/*
	Created: 20211011@Eden
	Task : View Initial Setting config
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20211011@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]

	Parameter Definition

	Example: 
		EXEC [Acc_Initial_DCS_SettingConfig_Sel] 
	
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
	ORDER BY ConfigID DESC

	SELECT 1 AS StepID, 'Delete existing customer setting' AS StepName
	UNION ALL SELECT 2 AS StepID, 'Insert customer setting'
	UNION ALL SELECT 3 AS StepID, 'Enable status'
	UNION ALL SELECT 4 AS StepID, 'Insert setting for new customer'
	UNION ALL SELECT 5 AS StepID, 'Enable status for new customer'
	UNION ALL SELECT 6 AS StepID, 'Adjust setting'
	UNION ALL SELECT 7 AS StepID, 'Adjust status' 
	UNION ALL SELECT 8 AS StepID, 'Disable status headline'
END
GO


