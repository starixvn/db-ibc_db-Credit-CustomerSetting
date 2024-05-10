/*<info serverAlias="DBAGE-bodb02,DBACC-bodb02" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_Product (@SettingStatus TINYINT)
RETURNS TABLE  
AS
/*  
	Created by: Helios  
	Date: 20240314  
	Task: Get data Product
	DB: DBAGE/bodb02, DBACC-bodb02
	Original:   
			
	Revisions:  
		- 20240314@Helios: Unify Live RNG Casino [Redmine: #198960]
	Explanation's Param:  
		@SettingStatus: 0: Pro, 1: UAT  
	Examples:
		SELECT * FROM f_CustSetting_Product (0)
		SELECT * FROM f_CustSetting_Product (3) where ProductID IN (70,50,38,66,41,64,6,42)
	
*/
RETURN

	-- Production Mode:
	SELECT ProductID
		,ProductName
		,Description
		,ProductPrefix
		,Enabled
		,BalanceType
		,SubProductBalanceType
		,GroupType
		,CasinoType
		,IsOfferPlayForFun
		,EndOfSupportDate
		,VendorID
		,OrderNo
		,Environment
	FROM Products p WITH (NOLOCK)
	WHERE p.Enabled=1
		AND @SettingStatus = 0
	