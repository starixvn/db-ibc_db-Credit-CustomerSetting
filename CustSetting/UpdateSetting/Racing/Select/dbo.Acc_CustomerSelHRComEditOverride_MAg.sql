ALTER PROCEDURE [dbo].[Acc_CustomerSelHRComEditOverride_MAg]
	@CustID int --MasterID
AS
/*
Created by: Phuc
Task :	Company Edits Master for HR 
		Super Edit Master
DB: DBCUST.CustDB
Orginal: Acc_CustomerSelComEditOverride_MAg
Revisions:
	- 20100422@Shifu: Get currency
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).	
	- 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
	- 20110309@Lukas: get custid
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: master ID
*/
SET NOCOUNT ON

select 
	@CustID as custid, c.firstname, c.lastname, c.roleid, c.username, c.currency,
	isnull(c.phone,'') as phone, isnull(c.mobilephone,'') as mobilephone, isnull(c.fax,'') as fax,
	
	---------------------------------------------------------------------
	-- get m3 to check n3 <= m3	
	--v151
	max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_31,
	max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_32,
	max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_41,
	max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_42,
	max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.mpositiontaking else 0 end) as v151mpositiontaking_52,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_41,
	max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_42,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.mpositiontaking else 0 end) as v152mpositiontaking_52,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_51,
	max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.mpositiontaking else 0 end) as v153mpositiontaking_52,
	---------------------------------------------------------------------
	-- get n3
	--v151
	max(case when mco.bettype = 31 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_31_min,
	max(case when mco.bettype = 32 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_32_min,
	max(case when mco.bettype = 41 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_41_min,
	max(case when mco.bettype = 42 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_42_min,
	max(case when mco.bettype = 51 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_51_min,
	max(case when mco.bettype = 52 and mco.sporttype = 151 then mco.minpositiontaking else 0 end) as v151mpositiontaking_52_min,
	max(case when mco.bettype = 41 and mco.sporttype = 152 then mco.minpositiontaking else 0 end) as v152mpositiontaking_41_min,
	max(case when mco.bettype = 42 and mco.sporttype = 152 then mco.minpositiontaking else 0 end) as v152mpositiontaking_42_min,
	max(case when mco.bettype = 51 and mco.sporttype = 152 then mco.minpositiontaking else 0 end) as v152mpositiontaking_51_min,
	max(case when mco.bettype = 52 and mco.sporttype = 152 then mco.minpositiontaking else 0 end) as v152mpositiontaking_52_min,
	max(case when mco.bettype = 51 and mco.sporttype = 153 then mco.minpositiontaking else 0 end) as v153mpositiontaking_51_min,
	max(case when mco.bettype = 52 and mco.sporttype = 153 then mco.minpositiontaking else 0 end) as v153mpositiontaking_52_min,
	---------------------------------------------------------------------
	-- get l3
	--v151
	max(case when mco.bettype = 31 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_31_max,	
	max(case when mco.bettype = 32 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_32_max,
	max(case when mco.bettype = 41 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_41_max,	
	max(case when mco.bettype = 42 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_42_max,
	max(case when mco.bettype = 51 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_51_max,	
	max(case when mco.bettype = 52 and mco.sporttype = 151 then mco.maxpositiontaking else 0 end) as v151mpositiontaking_52_max,
	max(case when mco.bettype = 41 and mco.sporttype = 152 then mco.maxpositiontaking else 0 end) as v152mpositiontaking_41_max,	
	max(case when mco.bettype = 42 and mco.sporttype = 152 then mco.maxpositiontaking else 0 end) as v152mpositiontaking_42_max,
	max(case when mco.bettype = 51 and mco.sporttype = 152 then mco.maxpositiontaking else 0 end) as v152mpositiontaking_51_max,	
	max(case when mco.bettype = 52 and mco.sporttype = 152 then mco.maxpositiontaking else 0 end) as v152mpositiontaking_52_max,
	max(case when mco.bettype = 51 and mco.sporttype = 153 then mco.maxpositiontaking else 0 end) as v153mpositiontaking_51_max,	
	max(case when mco.bettype = 52 and mco.sporttype = 153 then mco.maxpositiontaking else 0 end) as v153mpositiontaking_52_max

	---------------------------------------------------------------------
from 
	customer as c with (nolock)
	INNER JOIN custSetting3rd as cs with (NOLOCK) on c.custid = cs.custid
	INNER JOIN custOverride3rd as mco with (NOLOCK) on mco.custid = cs.custid and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype	
where 
	c.roleid=3 and c.custid=@CustID AND mco.sporttype BETWEEN 151 AND 153
group by 
	c.firstname, c.lastname, c.roleid, c.username, c.currency, c.phone, c.mobilephone, c.fax




GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_MAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_MAg] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_MAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_MAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRComEditOverride_MAg] TO vnteam