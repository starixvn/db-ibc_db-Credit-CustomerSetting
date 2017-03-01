ALTER PROCEDURE [dbo].[Acc_CustomerSelHRComEditOverride_SAg]
	@CustID int --SuperID
AS

/*
Created by: Phuc
Task : Company Edits Super for HR 
DB: DBCUST.CustDB
Orginal: Acc_CustomerSelComEditOverride_SAg

Revisions:
	- 20100422@Shifu: Get currency
	- 20090917@Kiwi: Remove select data for l4.
	- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20110124@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
	- 20110309@Lukas: get custid
	- 20110310@Johnson: remove custsetting3rd because s4 = l4
	- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
Param's Explanation:
• @CustID: super ID
*/

SET NOCOUNT ON

SELECT 
	@CustID as custid, c.firstname, c.lastname, c.roleid, c.username, c.currency,
	isnull(c.phone,'') as phone, isnull(c.mobilephone,'') as mobilephone, isnull(c.fax,'') as fax,
	
	----- get l4 -----------
	max (case when sco.bettype = 31 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_31_max,
	max (case when sco.bettype = 32 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_32_max,
	max (case when sco.bettype = 41 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_41_max,
	max (case when sco.bettype = 42 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_42_max,
	max (case when sco.bettype = 51 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_51_max,
	max (case when sco.bettype = 52 and sco.sporttype = 151 then sco.maxpositiontaking else 0 end ) as v151spositiontaking_52_max,
	max (case when sco.bettype = 41 and sco.sporttype = 152 then sco.maxpositiontaking else 0 end ) as v152spositiontaking_41_max,
	max (case when sco.bettype = 42 and sco.sporttype = 152 then sco.maxpositiontaking else 0 end ) as v152spositiontaking_42_max,
	max (case when sco.bettype = 51 and sco.sporttype = 152 then sco.maxpositiontaking else 0 end ) as v152spositiontaking_51_max,
	max (case when sco.bettype = 52 and sco.sporttype = 152 then sco.maxpositiontaking else 0 end ) as v152spositiontaking_52_max,
	max (case when sco.bettype = 51 and sco.sporttype = 153 then sco.maxpositiontaking else 0 end ) as v153spositiontaking_51_max,
	max (case when sco.bettype = 52 and sco.sporttype = 153 then sco.maxpositiontaking else 0 end ) as v153spositiontaking_52_max,
		
	------- get n4-----------------------------------------
	MAX(case when sco.bettype = 31 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_31_min,
	MAX(case when sco.bettype = 32 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_32_min,
	MAX(case when sco.bettype = 41 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_41_min,
	MAX(case when sco.bettype = 42 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_42_min,
	MAX(case when sco.bettype = 51 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_51_min,
	MAX(case when sco.bettype = 52 and sco.sporttype = 151 then sco.minpositiontaking else 0 END) as v151spositiontaking_52_min,
	MAX(case when sco.bettype = 41 and sco.sporttype = 152 then sco.minpositiontaking else 0 END) as v152spositiontaking_41_min,
	MAX(case when sco.bettype = 42 and sco.sporttype = 152 then sco.minpositiontaking else 0 END) as v152spositiontaking_42_min,
	MAX(case when sco.bettype = 51 and sco.sporttype = 152 then sco.minpositiontaking else 0 END) as v152spositiontaking_51_min,
	MAX(case when sco.bettype = 52 and sco.sporttype = 152 then sco.minpositiontaking else 0 END) as v152spositiontaking_52_min,
	MAX(case when sco.bettype = 51 and sco.sporttype = 153 then sco.minpositiontaking else 0 END) as v153spositiontaking_51_min,
	MAX(case when sco.bettype = 52 and sco.sporttype = 153 then sco.minpositiontaking else 0 END) as v153spositiontaking_52_min

from 
	customer as c with (nolock)	
	INNER JOIN custOverride3rd as sco with (NOLOCK) on sco.custid = c.custid 
where 
	c.roleid=4 and c.custid=@CustID AND sco.sporttype between 151 and 153
group by 
	c.firstname, c.lastname, c.roleid, c.username, c.currency, c.phone, c.mobilephone, c.fax





GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_SAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_SAg] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHRComEditOverride_SAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHRComEditOverride_SAg] TO vnteam
