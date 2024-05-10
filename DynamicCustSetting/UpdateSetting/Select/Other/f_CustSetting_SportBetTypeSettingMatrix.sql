/*<info serverAlias="DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="wsv_xnap" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_SportBetTypeSettingMatrix ( @SettingStatus TINYINT )
RETURNS TABLE AS
/*      
	Created by: Helios      
	Date: 20240314      
	Task: Get data SportBetTypeSettingMatrix    
	DB: DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB    
	Original:       
		         
	Revisions:      
	- 20240314@Helios: Unify Live RNG Casino [Redmine: #198960]    
	Explanation's Param:      
	@SettingStatus: 0: Pro, 1: UAT      
		       
	Examples:    
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (3)
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (0) 
*/
	RETURN

	-- Production Mode:    
	SELECT
		  sbsm.RealProductId
		, sbsm.ProductID
		, sbsm.SportType
		, sbsm.BetType
		, sbsm.isLicensee
		, sbsm.isLive
		, sbsm.Site
		, sbsm.isActive
		, sbsm.SportTypeRefPT
		, sbsm.BetTypeRefPT
		, sbsm.SportTypeRefComm
		, sbsm.BetTypeRefComm
		, sbsm.SportTypeRefBetSetting
		, sbsm.BetTypeRefBetSetting
		, sbsm.SporttypeRefWinlossLimit
		, sbsm.BettypeRefWinlossLimit
		, sbsm.isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE @SettingStatus = 0  