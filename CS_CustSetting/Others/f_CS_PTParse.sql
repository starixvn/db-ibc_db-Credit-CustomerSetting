/*<info serverAlias="DBCUST-CUSTDB" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION f_CS_PTParse(@DataXML XML) 
RETURNS TABLE 
/*
    Created: Elodie
    Date: 20181212
    Task: Parse PT XML (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]

    Parameter's Explanation:
		- @DataXML
						<ROOT>
							<PT SportType="180" BetType="1201" IsLive="0" ... />
							<PT SportType="181" BetType="1202" IsLive="0" ... />
							<PT SportType="183" BetType="1203" IsLive="0" ... />
						</ROOT>
*/
RETURN
	SELECT r.value('./@SportType','SMALLINT') AS SportType
			, r.value('./@BetType','SMALLINT') AS BetType
			, r.value('./@IsLive','BIT') AS IsLive									
			, r.value('./@SuperPT','SMALLINT') AS SuperPT
			, r.value('./@MasterPT','SMALLINT') AS MasterPT
			, r.value('./@AgentPT','SMALLINT') AS AgentPT
			, r.value('./@MinPT','SMALLINT') AS MinPT
			, r.value('./@MaxPT','SMALLINT') AS MaxPT
	FROM @DataXML.nodes('//ROOT/PT') AS RECORDS(r)
