/*<info serverAlias="DBCUST-CustDB,DBACC-bodb02" selecters="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="1"></info>*/
ALTER FUNCTION f_DCS_PT_XMLParse(@DataXML	NVARCHAR(MAX)) 
RETURNS @SportBetTypeTbl TABLE (SportType SMALLINT
						, Bettype SMALLINT
						, IsLive BIT
						, IsAuto_New BIT
						, IsAuto_Old BIT
						, IsUpdAllMems BIT
						, UpdAllMems_Value SMALLMONEY
						, SuperPT SMALLMONEY
						, MasterPT SMALLMONEY
						, AgentPT SMALLMONEY
						, IsAutoMasterPT BIT
						, AutoMasterPT SMALLMONEY
						, IsAutoSuperPT BIT
						, AutoSuperPT SMALLMONEY
						, MinPT SMALLMONEY
						, MaxPT SMALLMONEY
						)
/*
    Created: Dominic
    Date: 20150901
    Task: Parse PT XML (Dynamic Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20201023@Eden: Adjust new pt for 789y [Redmine: #143764]

    Parameter's Explanation:
		- @DataXML
						<ROOT>
							<PT SportType="180" BetType="1201" IsLive="0" ... />
							<PT SportType="181" BetType="1202" IsLive="0" ... />
							<PT SportType="183" BetType="1203" IsLive="0" ... />
						</ROOT>
*/
BEGIN 
	DECLARE @XML XML =  @DataXML
	

	INSERT @SportBetTypeTbl
	SELECT r.value('./@SportType','SMALLINT')
			, r.value('./@BetType','SMALLINT')
			, r.value('./@IsLive','BIT')
			
			--AutoPT: Acc_DynamicCustSetting_05
			, r.value('./@IsAuto_New','BIT')
			, r.value('./@IsAuto_Old','BIT')
			, r.value('./@IsUpdAllMems','BIT')
			, r.value('./@UpdAllMems_Value','SMALLMONEY')
			
			--Setting
			, r.value('./@SuperPT','SMALLMONEY')
			, r.value('./@MasterPT','SMALLMONEY')
			, r.value('./@AgentPT','SMALLMONEY')
			, r.value('./@IsAutoMasterPT','BIT')
			, r.value('./@AutoMasterPT','SMALLMONEY')
			, r.value('./@IsAutoSuperPT','BIT')
			, r.value('./@AutoSuperPT','SMALLMONEY')
			, r.value('./@MinPT','SMALLMONEY')
			, r.value('./@MaxPT','SMALLMONEY')
	FROM @xml.nodes('//ROOT/PT') AS RECORDS(r)

 
	RETURN
END