/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION f_CS_BetSettingParse(@DataXML XML) 
RETURNS TABLE 
/*
    Created: Elodie
    Date: 20181212
    Task: Parse BetSetting XML (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]
    Parameter's Explanation:
		- @DataXML
						<ROOT>
							<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							...						
						</ROOT>
*/
RETURN
	SELECT r.value('./@SportType','SMALLINT') AS SportType
			, r.value('./@BetType','SMALLINT') AS BetType
			, r.value('./@IsLive','BIT') AS IsLive									
			, r.value('./@MaxBet','MONEY') AS MaxBet
			, r.value('./@MaxPerEvent','MONEY') AS MaxPerEvent
	FROM @DataXML.nodes('//ROOT/BetSetting') AS RECORDS(r)
