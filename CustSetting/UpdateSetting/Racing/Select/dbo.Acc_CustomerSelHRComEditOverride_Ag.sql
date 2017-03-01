
ALTER PROCEDURE [dbo].[Acc_CustomerSelHRComEditOverride_Ag]
	@CustID int, --AgentID
	@MRecommend int = 0 --to check PT change date, in case "Master Edits Agent" only
AS

/*
Created by: Phuc
Date: 2009-05-21 
Task :	Company Edits Agent for HR 
		Master Edits Agent for HR
DB: DBCUST.CustDB
Orginal: Acc_CustomerSelComEditOverride_Ag
Revisions:
	- 20100422@Shifu: get currency
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).	
	- 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
	- 20110309@Lukas: get custid
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: agent ID
*/

SET NOCOUNT ON

select 
	@CustID as custid, c.firstname, c.lastname, c.roleid, c.username, c.currency, isnull(c.phone,'') as phone, isnull(c.mobilephone,'') as mobilephone, isnull(c.fax,'') as fax,
	
	---------------------------------------------------------------------
	-- get min(a2,l3) to check n2 <= min(a2,l3)	
	--v151
	max(case when cs.bettype = 31 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_31,
	max(case when cs.bettype = 32 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_32,
	max(case when cs.bettype = 41 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_41,
	max(case when cs.bettype = 42 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_42,
	max(case when cs.bettype = 51 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 151 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v151apositiontaking_52,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v152apositiontaking_41,
	max(case when cs.bettype = 42 and cs.sporttype = 152 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v152apositiontaking_42,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v152apositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 152 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v152apositiontaking_52,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v153apositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 153 then case when cs.apositiontaking<mco.maxpositiontaking then cs.apositiontaking else mco.maxpositiontaking end else 0 end) as v153apositiontaking_52,
	---------------------------------------------------------------------
	-- get n2
	--v151
	max(case when aco.bettype = 31 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_31_min,
	max(case when aco.bettype = 32 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_32_min,
	max(case when aco.bettype = 41 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_41_min,
	max(case when aco.bettype = 42 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_42_min,
	max(case when aco.bettype = 51 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_51_min,
	max(case when aco.bettype = 52 and aco.sporttype = 151 then aco.minpositiontaking else 0 end) as v151apositiontaking_52_min,
	max(case when aco.bettype = 41 and aco.sporttype = 152 then aco.minpositiontaking else 0 end) as v152apositiontaking_41_min,
	max(case when aco.bettype = 42 and aco.sporttype = 152 then aco.minpositiontaking else 0 end) as v152apositiontaking_42_min,
	max(case when aco.bettype = 51 and aco.sporttype = 152 then aco.minpositiontaking else 0 end) as v152apositiontaking_51_min,
	max(case when aco.bettype = 52 and aco.sporttype = 152 then aco.minpositiontaking else 0 end) as v152apositiontaking_52_min,
	max(case when aco.bettype = 51 and aco.sporttype = 153 then aco.minpositiontaking else 0 end) as v153apositiontaking_51_min,
	max(case when aco.bettype = 52 and aco.sporttype = 153 then aco.minpositiontaking else 0 end) as v153apositiontaking_52_min,
	---------------------------------------------------------------------
	-- get l2
	--v151
	max(case when aco.bettype = 31 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_31_max,	
	max(case when aco.bettype = 32 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_32_max,
	max(case when aco.bettype = 41 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_41_max,	
	max(case when aco.bettype = 42 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_42_max,
	max(case when aco.bettype = 51 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_51_max,	
	max(case when aco.bettype = 52 and aco.sporttype = 151 then aco.maxpositiontaking else 0 end) as v151apositiontaking_52_max,
	max(case when aco.bettype = 41 and aco.sporttype = 152 then aco.maxpositiontaking else 0 end) as v152apositiontaking_41_max,	
	max(case when aco.bettype = 42 and aco.sporttype = 152 then aco.maxpositiontaking else 0 end) as v152apositiontaking_42_max,
	max(case when aco.bettype = 51 and aco.sporttype = 152 then aco.maxpositiontaking else 0 end) as v152apositiontaking_51_max,	
	max(case when aco.bettype = 52 and aco.sporttype = 152 then aco.maxpositiontaking else 0 end) as v152apositiontaking_52_max,
	max(case when aco.bettype = 51 and aco.sporttype = 153 then aco.maxpositiontaking else 0 end) as v153apositiontaking_51_max,	
	max(case when aco.bettype = 52 and aco.sporttype = 153 then aco.maxpositiontaking else 0 end) as v153apositiontaking_52_max
	---------------------------------------------------------------------
from 
	customer as c with (nolock)
	INNER JOIN custSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custOverride3rd as aco with (NOLOCK) on aco.custid = cs.custid and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	INNER JOIN custOverride3rd as mco with (NOLOCK) on mco.custid = c.mrecommend and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype	
where 
	c.roleid=2 and c.custid=@CustID AND aco.sporttype BETWEEN 151 AND 153
group by 
	c.firstname, c.lastname, c.roleid, c.username, c.currency, c.phone, c.mobilephone, c.fax

	
	
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_Ag] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_Ag] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_Ag] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_Ag] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRComEditOverride_Ag] TO vnteam


