/*<info serverAlias="DBCUST-CUSTDB" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="" isFunction="1"></info>*/

ALTEr FUNCTION f_CS_CommParse(@DataXML XML) 
RETURNS TABLE 
/*
    Created: Elodie
    Date: 20181212
    Task: Parse Comm XML (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]
    Parameter's Explanation:
		- @DataXML
						<ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
							<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
							...						
						</ROOT>
*/
RETURN
	SELECT r.value('./@SportType','SMALLINT') AS SportType
			, r.value('./@BetType','SMALLINT') AS BetType
			, r.value('./@IsLive','BIT') AS IsLive									
			, r.value('./@GroupId','SMALLINT') AS GroupId
			, r.value('./@ValueId','TINYINT') AS ValueId
	FROM @DataXML.nodes('//ROOT/Comm') AS RECORDS(r)
