ALTER PROCEDURE  [dbo].[Acc_CustomerSelHREditMember_SAg]
	@CustID int	
AS  

/*
	Created by: Phuc
	Date: 2009-05-20
	Task: SUPER EDIT MEMBER FOR HR AT AGENT SITE  
	DB: DBCUST.CustDB 
	Original: Acc_CustomerSelEditCustomer_SAg

	Revisions:
		- 20090626@ThoNguyen: Get value Super IsAuto on Master
		- 20090714@ThoNguyen: Get status disable HR
		- 20090804@Phuc: get max_s1 = min(s4,l4)-m3
		- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
		- 20100414@Shifu: OpenTote Setting (maxpermatch, opentote status)
		- 20110122@Lukas: Add more partner (AU Horse racing) & racing game (Greyhound, Harness)
		- 20110314@Lukas: remove paramter @AgentID 
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
SET NOCOUNT ON  
  
	Declare  
	 --min(s4,l4) 
	 @v151mspositiontaking_31_max smallmoney,  
	 @v151mspositiontaking_32_max smallmoney,  
	 @v151mspositiontaking_41_max smallmoney,  
	 @v151mspositiontaking_42_max smallmoney,  
	 @v151mspositiontaking_51_max smallmoney,  
	 @v151mspositiontaking_52_max smallmoney,
	 @v152mspositiontaking_41_max smallmoney,  
	 @v152mspositiontaking_42_max smallmoney,
	 @v152mspositiontaking_51_max smallmoney,  
	 @v152mspositiontaking_52_max smallmoney,
	 @v153mspositiontaking_51_max smallmoney,  
	 @v153mspositiontaking_52_max smallmoney,
	 --m3
	 @v151mpositiontaking_31 smallmoney,  
	 @v151mpositiontaking_32 smallmoney,  
	 @v151mpositiontaking_41 smallmoney,  
	 @v151mpositiontaking_42 smallmoney,  
	 @v151mpositiontaking_51 smallmoney,  
	 @v151mpositiontaking_52 smallmoney,  
	 @v152mpositiontaking_41 smallmoney,  
	 @v152mpositiontaking_42 smallmoney,  
	 @v152mpositiontaking_51 smallmoney,  
	 @v152mpositiontaking_52 smallmoney,  
	 @v153mpositiontaking_51 smallmoney,  
	 @v153mpositiontaking_52 smallmoney,  
	 --n4
	 @v151mspositiontaking_31_min smallmoney,  
	 @v151mspositiontaking_32_min smallmoney,  
	 @v151mspositiontaking_41_min smallmoney,  
	 @v151mspositiontaking_42_min smallmoney,  
	 @v151mspositiontaking_51_min smallmoney,  
	 @v151mspositiontaking_52_min smallmoney,  
	 @v152mspositiontaking_41_min smallmoney,  
	 @v152mspositiontaking_42_min smallmoney,  
	 @v152mspositiontaking_51_min smallmoney,  
	 @v152mspositiontaking_52_min smallmoney,  
	 @v153mspositiontaking_51_min smallmoney,  
	 @v153mspositiontaking_52_min smallmoney,  
	 --i3
	 @isauto_v151spositiontaking_31 bit ,
	 @isauto_v151spositiontaking_32 bit ,	
	 @isauto_v151spositiontaking_41 bit ,
	 @isauto_v151spositiontaking_42 bit ,
	 @isauto_v151spositiontaking_51 bit ,
	 @isauto_v151spositiontaking_52 bit ,
	 @isauto_v152spositiontaking_41 bit ,
	 @isauto_v152spositiontaking_42 bit ,
	 @isauto_v152spositiontaking_51 bit ,
	 @isauto_v152spositiontaking_52 bit ,
	 @isauto_v153spositiontaking_51 bit ,
	 @isauto_v153spositiontaking_52 bit ,
	 @AgentID INT,
	 @MasterID INT,
	 @SuperID INT,	
	 @Ssuspended BIT

SELECT @AgentID = recommend, @SuperID = srecommend, @MasterID = mrecommend FROM custinfo WITH(NOLOCK) WHERE custid = @CustID


 Select 
	@isauto_v151spositiontaking_31 = max(case when mcs.bettype = 31 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v151spositiontaking_32 = max(case when mcs.bettype = 32 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v151spositiontaking_41 = max(case when mcs.bettype = 41 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v151spositiontaking_42 = max(case when mcs.bettype = 42 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v151spositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v151spositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=151 then mcs.isautopositiontaking else 0 end),
	@isauto_v152spositiontaking_41 = max(case when mcs.bettype = 41 and mcs.sporttype=152 then mcs.isautopositiontaking else 0 end),
	@isauto_v152spositiontaking_42 = max(case when mcs.bettype = 42 and mcs.sporttype=152 then mcs.isautopositiontaking else 0 end),
	@isauto_v152spositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=152 then mcs.isautopositiontaking else 0 end),
	@isauto_v152spositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=152 then mcs.isautopositiontaking else 0 end),
	@isauto_v153spositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=153 then mcs.isautopositiontaking else 0 end),
	@isauto_v153spositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=153 then mcs.isautopositiontaking else 0 end),
	--m3
	@v151mpositiontaking_31 = max(case when mcs.bettype = 31 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v151mpositiontaking_32 = max(case when mcs.bettype = 32 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v151mpositiontaking_41 = max(case when mcs.bettype = 41 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v151mpositiontaking_42 = max(case when mcs.bettype = 42 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v151mpositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v151mpositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=151 then mcs.mpositiontaking else 0 end),
	@v152mpositiontaking_41 = max(case when mcs.bettype = 41 and mcs.sporttype=152 then mcs.mpositiontaking else 0 end),
	@v152mpositiontaking_42 = max(case when mcs.bettype = 42 and mcs.sporttype=152 then mcs.mpositiontaking else 0 end),
	@v152mpositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=152 then mcs.mpositiontaking else 0 end),
	@v152mpositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=152 then mcs.mpositiontaking else 0 end),
	@v153mpositiontaking_51 = max(case when mcs.bettype = 51 and mcs.sporttype=153 then mcs.mpositiontaking else 0 end),
	@v153mpositiontaking_52 = max(case when mcs.bettype = 52 and mcs.sporttype=153 then mcs.mpositiontaking else 0 end)
From CustSetting3rd mcs with (NOLOCK) 
where mcs.custid = @MasterID -- in (Select mrecommend from custinfo with (NOLOCK) where custid = @AgentID)
		and mcs.sporttype BETWEEN 151 AND 153
 

Select    
  
	 @v151mspositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v151mspositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v151mspositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v151mspositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v151mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v151mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 151 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v152mspositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype = 152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v152mspositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype = 152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v152mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v152mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 152 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v153mspositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 153 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 @v153mspositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 153 then case when cs.spositiontaking<co.maxpositiontaking then cs.spositiontaking else co.maxpositiontaking end else 0 end),  
	 --min  
	 @v151mspositiontaking_31_min = max(case when co.bettype = 31 and co.sporttype = 151 then co.minpositiontaking else 0 end),  
	 @v151mspositiontaking_32_min = max(case when co.bettype = 32 and co.sporttype = 151 then co.minpositiontaking else 0 end), 
	 @v151mspositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype = 151 then co.minpositiontaking else 0 end),  
	 @v151mspositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype = 151 then co.minpositiontaking else 0 end),  
	 @v151mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype = 151 then co.minpositiontaking else 0 end),  
	 @v151mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype = 151 then co.minpositiontaking else 0 end),
	 @v152mspositiontaking_41_min = max(case when co.bettype = 41 and co.sporttype = 152 then co.minpositiontaking else 0 end),  
	 @v152mspositiontaking_42_min = max(case when co.bettype = 42 and co.sporttype = 152 then co.minpositiontaking else 0 end),
	 @v152mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype = 152 then co.minpositiontaking else 0 end),  
	 @v152mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype = 152 then co.minpositiontaking else 0 end),
	 @v153mspositiontaking_51_min = max(case when co.bettype = 51 and co.sporttype = 153 then co.minpositiontaking else 0 end),  
	 @v153mspositiontaking_52_min = max(case when co.bettype = 52 and co.sporttype = 153 then co.minpositiontaking else 0 end)
From   
	 CustSetting3rd as cs with (NOLOCK)  
	 LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype  
Where cs.CustID = @SuperID --in (Select sRecommend from Customer with (NOLOCK) where CustID = @AgentID) 
		AND cs.sporttype BETWEEN 151 AND 153
  

SELECT  
	 isnull(c.fax,'') as fax, c.firstname, c.lastname,   
	 ci.maxpermatch151 as v151maxpermatch_31,   
	 ci.maxpermatch151_ot as v151maxpermatch_41, 
	 ci.maxpermatch151_AU as v151maxpermatch_51,
	 ci.maxpermatch152_UK as v152maxpermatch_41,
	 ci.maxpermatch152_AU as v152maxpermatch_51,
	 ci.maxpermatch153_AU as v153maxpermatch_51,	 
	 isnull(c.mobilephone,'') as mobilephone, 
	 isnull(c.phone,'') as phone, 
	 c.username,  
	 c.username2, 
	 c.currency,
	 ci.credit,  
	 ci.disablehorseracing as disable151_31,
	 ci.disableopentote as disable151_41,
	 ci.disable151_AU as disable151_51,
	 ci.disable152_UK as disable152_41,
	 ci.disable152_AU as disable152_51,
	 ci.disable153_AU as disable153_51,

	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_31,  
	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_31,  
	 
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_41,  
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_41, 

	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_51,  
	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_51,

	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.minbet else 0 end) as v152minbet_41,  
	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.maxbet else 0 end) as v152maxbet_41,
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.minbet else 0 end) as v152minbet_51,  
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.maxbet else 0 end) as v152maxbet_51,

	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.minbet else 0 end) as v153minbet_51,  
	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.maxbet else 0 end) as v153maxbet_51,
	 --comm for 151
	isnull(max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_31_Ag,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_41_Ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_51_Ag,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.discount else 0 end), 0) as v152discount_41_Ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.discount else 0 end), 0) as v152discount_51_Ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.discount else 0 end), 0) as v153discount_51_Ag,

	isnull(max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.adiscount else 0 end), 0) as v151discount_31_MAg,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.adiscount else 0 end), 0) as v151discount_41_MAg,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.adiscount else 0 end), 0) as v151discount_51_MAg,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.adiscount else 0 end), 0) as v152discount_41_MAg,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.adiscount else 0 end), 0) as v152discount_51_MAg,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.adiscount else 0 end), 0) as v153discount_51_MAg,

	isnull(max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_31,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_41,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_51,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.playerdiscount else 0 end), 0) as v152discount_41,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.playerdiscount else 0 end), 0) as v152discount_51,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.playerdiscount else 0 end), 0) as v153discount_51,
	 
	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_31,  
	 max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_32,  
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end) as v151apositiontaking_52,  
	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end) as v152apositiontaking_52,  
	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end) as v153apositiontaking_52,  

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

	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_31,  
	 max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_32,  
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.spositiontaking else 0 end) as v151spositiontaking_52,
	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_42,
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.spositiontaking else 0 end) as v152spositiontaking_52,
	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.spositiontaking else 0 end) as v153spositiontaking_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.spositiontaking else 0 end) as v153spositiontaking_52,
	 
     --s1_max=min(s4,l4)-m3
	 ISNULL(@v151mspositiontaking_31_max, 0) - ISNULL(@v151mpositiontaking_31,0) AS v151pos_31_max,  
	 ISNULL(@v151mspositiontaking_32_max, 0) - ISNULL(@v151mpositiontaking_32,0) AS v151pos_32_max,  
	 ISNULL(@v151mspositiontaking_41_max, 0) - ISNULL(@v151mpositiontaking_41,0) AS v151pos_41_max,  
	 ISNULL(@v151mspositiontaking_42_max, 0) - ISNULL(@v151mpositiontaking_42,0) AS v151pos_42_max,  
	 ISNULL(@v151mspositiontaking_51_max, 0) - ISNULL(@v151mpositiontaking_51,0) AS v151pos_51_max,
	 ISNULL(@v151mspositiontaking_52_max, 0) - ISNULL(@v151mpositiontaking_52,0) AS v151pos_52_max,
	 ISNULL(@v152mspositiontaking_41_max, 0) - ISNULL(@v152mpositiontaking_41,0) AS v152pos_41_max,
	 ISNULL(@v152mspositiontaking_42_max, 0) - ISNULL(@v152mpositiontaking_42,0) AS v152pos_42_max,
	 ISNULL(@v152mspositiontaking_51_max, 0) - ISNULL(@v152mpositiontaking_51,0) AS v152pos_51_max,
	 ISNULL(@v152mspositiontaking_52_max, 0) - ISNULL(@v152mpositiontaking_52,0) AS v152pos_52_max,
	 ISNULL(@v153mspositiontaking_51_max, 0) - ISNULL(@v153mpositiontaking_51,0) AS v153pos_51_max,
	 ISNULL(@v153mspositiontaking_52_max, 0) - ISNULL(@v153mpositiontaking_52,0) AS v153pos_52_max,

	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_31,  
	 max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_32,  
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.autopositiontaking else 0 end) as auto_v151spositiontaking_mem_52,  
	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_mem_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_mem_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.autopositiontaking else 0 end) as auto_v152spositiontaking_mem_52,  
	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.autopositiontaking else 0 end) as auto_v153spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.autopositiontaking else 0 end) as auto_v153spositiontaking_mem_52,  
	 
	 max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_31,  
	 max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_32,  
	 max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.isautopositiontaking else 0 end) as isauto_v151spositiontaking_mem_52,  
	 max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_mem_41,  
	 max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_mem_42,  
	 max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.isautopositiontaking else 0 end) as isauto_v152spositiontaking_mem_52,  
	 max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.isautopositiontaking else 0 end) as isauto_v153spositiontaking_mem_51,  
	 max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.isautopositiontaking else 0 end) as isauto_v153spositiontaking_mem_52,  
	 
	 @isauto_v151spositiontaking_31 as isauto_v151spositiontaking_31,
	 @isauto_v151spositiontaking_32 as isauto_v151spositiontaking_32,
	 @isauto_v151spositiontaking_41 as isauto_v151spositiontaking_41,
	 @isauto_v151spositiontaking_42 as isauto_v151spositiontaking_42,
	 @isauto_v151spositiontaking_51 as isauto_v151spositiontaking_51,
	 @isauto_v151spositiontaking_52 as isauto_v151spositiontaking_52,
	 @isauto_v152spositiontaking_41 as isauto_v152spositiontaking_41,
	 @isauto_v152spositiontaking_42 as isauto_v152spositiontaking_42,
	 @isauto_v152spositiontaking_51 as isauto_v152spositiontaking_51,
	 @isauto_v152spositiontaking_52 as isauto_v152spositiontaking_52,
	 @isauto_v153spositiontaking_51 as isauto_v153spositiontaking_51,
	 @isauto_v153spositiontaking_52 as isauto_v153spositiontaking_52,
	 
	 isnull(@v151mspositiontaking_31_max, 0) as auto_v151pos_31_max,  
	 isnull(@v151mspositiontaking_32_max, 0) as auto_v151pos_32_max,  
	 isnull(@v151mspositiontaking_41_max, 0) as auto_v151pos_41_max,  
	 isnull(@v151mspositiontaking_42_max, 0) as auto_v151pos_42_max,  
	 isnull(@v151mspositiontaking_51_max, 0) as auto_v151pos_51_max,  
	 isnull(@v151mspositiontaking_52_max, 0) as auto_v151pos_52_max, 
	 isnull(@v152mspositiontaking_41_max, 0) as auto_v152pos_41_max,  
	 isnull(@v152mspositiontaking_42_max, 0) as auto_v152pos_42_max, 
	 isnull(@v152mspositiontaking_51_max, 0) as auto_v152pos_51_max,  
	 isnull(@v152mspositiontaking_52_max, 0) as auto_v152pos_52_max, 
	 isnull(@v153mspositiontaking_51_max, 0) as auto_v153pos_51_max,  
	 isnull(@v153mspositiontaking_52_max, 0) as auto_v153pos_52_max, 
	  
	 case when isnull(@v151mspositiontaking_31_min, 0)-max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_31_min, 0)-max(case when cs.bettype = 31 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_31_min,  
	 case when isnull(@v151mspositiontaking_32_min, 0)-max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_32_min, 0)-max(case when cs.bettype = 32 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_32_min,
	 case when isnull(@v151mspositiontaking_41_min, 0)-max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_41_min, 0)-max(case when cs.bettype = 41 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_41_min,  
	 case when isnull(@v151mspositiontaking_42_min, 0)-max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_42_min, 0)-max(case when cs.bettype = 42 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_42_min,
	 case when isnull(@v151mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_51_min,  
	 case when isnull(@v151mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v151mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v151pos_52_min,
	 case when isnull(@v152mspositiontaking_41_min, 0)-max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v152mspositiontaking_41_min, 0)-max(case when cs.bettype = 41 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v152pos_41_min,  
	 case when isnull(@v152mspositiontaking_42_min, 0)-max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v152mspositiontaking_42_min, 0)-max(case when cs.bettype = 42 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v152pos_42_min,
	 case when isnull(@v152mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v152mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v152pos_51_min,  
	 case when isnull(@v152mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v152mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v152pos_52_min,
	 case when isnull(@v153mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v153mspositiontaking_51_min, 0)-max(case when cs.bettype = 51 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v153pos_51_min,  
	 case when isnull(@v153mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.mpositiontaking+cs.apositiontaking else 0 end) >0 then isnull(@v153mspositiontaking_52_min, 0)-max(case when cs.bettype = 52 then cs.mpositiontaking+cs.apositiontaking else 0 end) else 0 end as v153pos_52_min
FROM   
	 customer as C with (nolock)   
	 INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid  
	 INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid  = cs.custid   
WHERE c.custid=@custId AND c.recommend=@agentId AND cs.sporttype BETWEEN 151 AND 153
group by   
		c.fax, 
		c.firstname, 
		c.lastname, 
		c.mobilephone, 
		c.phone, 
		c.username,  
		c.username2,  
		c.currency,
		ci.maxpermatch151,  
		ci.maxpermatch151_ot,
		ci.credit,
		ci.disablehorseracing,  
		ci.disableopentote,
		ci.MaxPerMatch151_AU,
		ci.MaxPerMatch152_UK,
		ci.MaxPerMatch152_AU,
		ci.MaxPerMatch153_AU,
		ci.Disable151_AU,
		ci.Disable152_UK,
		ci.Disable152_AU,
		ci.Disable153_AU

		
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_SAg] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_SAg] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_SAg] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_SAg] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHREditMember_SAg] TO [vnteam]
