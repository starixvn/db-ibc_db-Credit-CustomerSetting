ALTER PROCEDURE [dbo].[Acc_CustomerSelHREditMember_MAg]
	@CustID int
AS
/*
	Created by: Phuc
	Date: 2009-04-16
	Task: MASTER EDIT MEMBER FOR HR AT AGENT SITE 
	DB: DBCUST.CustDB 
	Original: Acc_CustomerSelEditCustomer_MAg
	
	Revisions:
		- 20090701@Phuc: remove dbo.IsAllowChangePositiontaking, auto master, disalbe auto MPT.
		- 20090714@ThoNguyen: Get status disable HR
		- 20090806@Phuc: remove check m1=min(m3-a2,m1)
		- 20091128@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
		- 20100414@Shifu: OpenTote Setting (maxpermatch, opentote status)
		- 20110122@Lukas: Add more partner ( AU Horse racing) & racing game (Harness, Greyhound) setting
		- 20110314@Johnson: remove @AgentID 
		- 20120504@Johnson: correct m1 max
		- 20140307@Johnson: fix bug m1_max =  m3-a1 not apply range !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1) [Redmine:#12953] 
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
*/
SET NOCOUNT ON

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
declare @mrecommend int, @DisableAutoMPT bit, @AgentID INT, @SuperID INT, @MasterID INT

select @mrecommend = mrecommend from custinfo with (NOLOCK) where custid = @custid
--Disable auto master PT
Select @DisableAutoMPT = DisableAutoMPT From CustMaster (nolock) Where CustID = @mrecommend


SELECT @AgentID = recommend, @SuperID = srecommend, @MasterID = mrecommend FROM custinfo WITH(NOLOCK) WHERE custid = @CustID

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Declare 
	@v151sp_31 smallmoney,
	@v151sp_32 smallmoney,
	@v151sp_41 smallmoney,
	@v151sp_42 smallmoney,
	@v151sp_51 smallmoney,
	@v151sp_52 smallmoney,
	@v152sp_41 smallmoney,
	@v152sp_42 smallmoney,
	@v152sp_51 smallmoney,
	@v152sp_52 smallmoney,
	@v153sp_51 smallmoney,
	@v153sp_52 smallmoney,
/*
	@max_v151mp_31 smallmoney,
	@max_v151mp_32 smallmoney,
	@max_v151mp_41 smallmoney,
	@max_v151mp_42 smallmoney,
	@max_v151mp_51 smallmoney,
	@max_v151mp_52 smallmoney,
	@max_v152mp_41 smallmoney,
	@max_v152mp_42 smallmoney,
	@max_v152mp_51 smallmoney,
	@max_v152mp_52 smallmoney,
	@max_v153mp_51 smallmoney,
	@max_v153mp_52 smallmoney,
*/
	--im2
	@isauto_v151mpositiontaking_31 bit ,
	@isauto_v151mpositiontaking_32 bit ,
	@isauto_v151mpositiontaking_41 bit ,
	@isauto_v151mpositiontaking_42 bit ,
	@isauto_v151mpositiontaking_51 bit ,
	@isauto_v151mpositiontaking_52 bit ,
	@isauto_v152mpositiontaking_41 bit ,
	@isauto_v152mpositiontaking_42 bit ,
	@isauto_v152mpositiontaking_51 bit ,
	@isauto_v152mpositiontaking_52 bit ,
	@isauto_v153mpositiontaking_51 bit ,
	@isauto_v153mpositiontaking_52 bit



--im2
Select 
	@isauto_v151mpositiontaking_31 = max(case when acs.bettype = 31 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v151mpositiontaking_32 = max(case when acs.bettype = 32 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v151mpositiontaking_41 = max(case when acs.bettype = 41 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v151mpositiontaking_42 = max(case when acs.bettype = 42 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v151mpositiontaking_51 = max(case when acs.bettype = 51 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v151mpositiontaking_52 = max(case when acs.bettype = 52 and acs.sporttype = 151 then acs.isautompositiontaking else 0 end),
	@isauto_v152mpositiontaking_41 = max(case when acs.bettype = 41 and acs.sporttype = 152 then acs.isautompositiontaking else 0 end),
	@isauto_v152mpositiontaking_42 = max(case when acs.bettype = 42 and acs.sporttype = 152 then acs.isautompositiontaking else 0 end),
	@isauto_v152mpositiontaking_51 = max(case when acs.bettype = 51 and acs.sporttype = 152 then acs.isautompositiontaking else 0 end),
	@isauto_v152mpositiontaking_52 = max(case when acs.bettype = 52 and acs.sporttype = 152 then acs.isautompositiontaking else 0 end),
	@isauto_v153mpositiontaking_51 = max(case when acs.bettype = 51 and acs.sporttype = 153 then acs.isautompositiontaking else 0 end),
	@isauto_v153mpositiontaking_52 = max(case when acs.bettype = 52 and acs.sporttype = 153 then acs.isautompositiontaking else 0 end)
From custinfo m with(nolock) 
inner join CustSetting3rd acs with(nolock) on m.recommend = acs.custid 
where m.custid = @AgentID AND acs.sporttype BETWEEN 151 AND 153


--@sp=s4
Select 
	@v151sp_31 = max(case when Scs.bettype = 31 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v151sp_32 = max(case when Scs.bettype = 32 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v151sp_41 = max(case when Scs.bettype = 41 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v151sp_42 = max(case when Scs.bettype = 42 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v151sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v151sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype = 151 then Scs.spositiontaking else 0 end),
	@v152sp_41 = max(case when Scs.bettype = 41 and Scs.sporttype = 152 then Scs.spositiontaking else 0 end),
	@v152sp_42 = max(case when Scs.bettype = 42 and Scs.sporttype = 152 then Scs.spositiontaking else 0 end),
	@v152sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype = 152 then Scs.spositiontaking else 0 end),
	@v152sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype = 152 then Scs.spositiontaking else 0 end),
	@v153sp_51 = max(case when Scs.bettype = 51 and Scs.sporttype = 153 then Scs.spositiontaking else 0 end),
	@v153sp_52 = max(case when Scs.bettype = 52 and Scs.sporttype = 153 then Scs.spositiontaking else 0 end)
From CustSetting3rd as Scs with (NOLOCK)
where scs.CustID = @SuperID --in (Select srecommend from custinfo with (NOLOCK) where CustID = @CustID) 
		AND Scs.sporttype BETWEEN 151 AND 153

Declare 
	@v151mapositiontaking_31_max smallmoney,
	@v151mapositiontaking_32_max smallmoney,
	@v151mapositiontaking_41_max smallmoney,
	@v151mapositiontaking_42_max smallmoney,
	@v151mapositiontaking_51_max smallmoney,
	@v151mapositiontaking_52_max smallmoney,
	@v152mapositiontaking_41_max smallmoney,
	@v152mapositiontaking_42_max smallmoney,
	@v152mapositiontaking_51_max smallmoney,
	@v152mapositiontaking_52_max smallmoney,
	@v153mapositiontaking_51_max smallmoney,
	@v153mapositiontaking_52_max smallmoney,
	--min
	@v151mapositiontaking_31_min smallmoney,
	@v151mapositiontaking_32_min smallmoney,
	@v151mapositiontaking_41_min smallmoney,
	@v151mapositiontaking_42_min smallmoney,
	@v151mapositiontaking_51_min smallmoney,
	@v151mapositiontaking_52_min smallmoney,
	@v152mapositiontaking_41_min smallmoney,
	@v152mapositiontaking_42_min smallmoney,
	@v152mapositiontaking_51_min smallmoney,
	@v152mapositiontaking_52_min smallmoney,
	@v153mapositiontaking_51_min smallmoney,
	@v153mapositiontaking_52_min smallmoney

Select
	--@mapos_max=min(m3,l3)
	@v151mapositiontaking_31_max = max(case when cs.bettype = 31 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v151mapositiontaking_32_max = max(case when cs.bettype = 32 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v151mapositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v151mapositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v151mapositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v151mapositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 151 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v152mapositiontaking_41_max = max(case when cs.bettype = 41 and cs.sporttype = 152 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v152mapositiontaking_42_max = max(case when cs.bettype = 42 and cs.sporttype = 152 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v152mapositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 152 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v152mapositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 152 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v153mapositiontaking_51_max = max(case when cs.bettype = 51 and cs.sporttype = 153 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	@v153mapositiontaking_52_max = max(case when cs.bettype = 52 and cs.sporttype = 153 then case when cs.mpositiontaking<co.maxpositiontaking then cs.mpositiontaking else co.maxpositiontaking end else 0 end),
	--@mapos_min=n3
	@v151mapositiontaking_31_min = max(case when co.bettype = 31 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v151mapositiontaking_32_min = max(case when co.bettype = 32 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v151mapositiontaking_41_min = max(case when co.bettype = 41 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v151mapositiontaking_42_min = max(case when co.bettype = 42 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v151mapositiontaking_51_min = max(case when co.bettype = 51 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v151mapositiontaking_52_min = max(case when co.bettype = 52 and cs.sporttype = 151 then co.minpositiontaking else 0 end),
	@v152mapositiontaking_41_min = max(case when co.bettype = 41 and cs.sporttype = 152 then co.minpositiontaking else 0 end),
	@v152mapositiontaking_42_min = max(case when co.bettype = 42 and cs.sporttype = 152 then co.minpositiontaking else 0 end),
	@v152mapositiontaking_51_min = max(case when co.bettype = 51 and cs.sporttype = 152 then co.minpositiontaking else 0 end),
	@v152mapositiontaking_52_min = max(case when co.bettype = 52 and cs.sporttype = 152 then co.minpositiontaking else 0 end),
	@v153mapositiontaking_51_min = max(case when co.bettype = 51 and cs.sporttype = 153 then co.minpositiontaking else 0 end),
	@v153mapositiontaking_52_min = max(case when co.bettype = 52 and cs.sporttype = 153 then co.minpositiontaking else 0 end)

From 
	CustSetting3rd as cs with (NOLOCK)
	LEFT JOIN CustOverride3rd as co with (NOLOCK) on cs.custid = co.custid and cs.sporttype=co.sporttype and cs.bettype=co.bettype
Where cs.CustID = @MasterID --in (Select mRecommend from custinfo with (NOLOCK) where CustID = @AgentID) 
			AND cs.sporttype BETWEEN 151 AND 153


/*
Select
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	@max_v151mp_31 = max(case when cs.bettype = 31 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_31-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_31-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v151mp_32 = max(case when cs.bettype = 32 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_32-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_32-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v151mp_41 = max(case when cs.bettype = 41 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_41-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_41-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v151mp_42 = max(case when cs.bettype = 42 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_42-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_42-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v151mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_51-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_51-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v151mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 151 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v151sp_52-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v151sp_52-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v152mp_41 = max(case when cs.bettype = 41 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v152sp_41-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v152sp_41-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v152mp_42 = max(case when cs.bettype = 42 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v152sp_42-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v152sp_42-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v152mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v152sp_51-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v152sp_51-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v152mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 152 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v152sp_52-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v152sp_52-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v153mp_51 = max(case when cs.bettype = 51 and cs.sporttype = 153 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v153sp_51-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v153sp_51-cs.spositiontaking-cs.apositiontaking end end else 0 end),
	@max_v153mp_52 = max(case when cs.bettype = 52 and cs.sporttype = 153 then case when not (cs.isautopositiontaking=0 and mcs.isautopositiontaking=0) then mcs.mpositiontaking-cs.apositiontaking else case when mcs.mpositiontaking-cs.apositiontaking<=@v153sp_52-cs.spositiontaking-cs.apositiontaking then  mcs.mpositiontaking-cs.apositiontaking else @v153sp_52-cs.spositiontaking-cs.apositiontaking end end else 0 end)
From CustSetting3rd as cs with (NOLOCK) 
	inner join custinfo as c with (nolock) on cs.custid = c.custid
	inner join CustSetting3rd as mcs with (nolock) on mcs.custid = c.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype =cs.bettype
where cs.custid = @custid and cs.sporttype BETWEEN 151 AND 153
*/

SELECT
	isnull(c.fax,'') as fax, 
	c.firstname, 
	c.lastname,
	isnull(c.mobilephone,'') as mobilephone,
	isnull(c.phone,'') as phone,
	c.username,  
	c.username2,  
	c.currency,
	ci.maxpermatch151 as v151maxpermatch_31, 
	ci.maxpermatch151_ot as v151maxpermatch_41,
	ci.maxpermatch151_au as v151maxpermatch_51,
	ci.maxpermatch152_uk as v152maxpermatch_41,
	ci.maxpermatch152_au as v152maxpermatch_51,
	ci.maxpermatch153_au as v153maxpermatch_51,
	ci.credit,
	ci.disablehorseracing as disable151_31,
	ci.disableopentote as disable151_41,
	ci.disable151_au  as disable151_51,
	ci.disable152_uk as disable152_41,
	ci.disable152_au as disable152_51,
	ci.disable153_au as disable153_51,
	isnull(@DisableAutoMPT,0) as DisableAutoMPT,
	isnull(max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_31_ag,
	isnull(max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_31,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_41_ag,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_41,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.discount else 0 end), 0) as v151discount_51_ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.playerdiscount else 0 end), 0) as v151discount_51,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.discount else 0 end), 0) as v152discount_41_ag,
	isnull(max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.playerdiscount else 0 end), 0) as v152discount_41,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.discount else 0 end), 0) as v152discount_51_ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.playerdiscount else 0 end), 0) as v152discount_51,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.discount else 0 end), 0) as v153discount_51_ag,
	isnull(max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.playerdiscount else 0 end), 0) as v153discount_51,

	max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_31, --minbet_31
	max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_31, --maxbet_31
	max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_41, --minbet_41
	max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_41, --maxbet_41
	max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.minbet else 0 end) as v151minbet_51,
	max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.maxbet else 0 end) as v151maxbet_51,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.minbet else 0 end) as v152minbet_41,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.maxbet else 0 end) as v152maxbet_41,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.minbet else 0 end) as v152minbet_51,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.maxbet else 0 end) as v152maxbet_51,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.minbet else 0 end) as v153minbet_51,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.maxbet else 0 end) as v153maxbet_51,

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
	
	/*
	--maxpos_1=min[@max_mp,min(m3,l3)-a1]
	--@max_mp = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	case when isnull(@max_v151mp_31, 0)  < @v151mapositiontaking_31_max - max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_31, 0)  else @v151mapositiontaking_31_max - max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_31_max,
	case when isnull(@max_v151mp_32, 0)  < @v151mapositiontaking_32_max - max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_32, 0)  else @v151mapositiontaking_32_max - max(case when cs.bettype = 32 and cs.sporttype = 151  then cs.apositiontaking else 0 end)  end as v151pos_32_max,
	case when isnull(@max_v151mp_41, 0)  < @v151mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_41, 0)  else @v151mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_41_max,
	case when isnull(@max_v151mp_42, 0)  < @v151mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_42, 0)  else @v151mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 151  then cs.apositiontaking else 0 end)  end as v151pos_42_max,
	case when isnull(@max_v151mp_51, 0)  < @v151mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_51, 0)  else @v151mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_51_max,
	case when isnull(@max_v151mp_52, 0)  < @v151mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  then isnull(@max_v151mp_52, 0)  else @v151mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 151  then cs.apositiontaking else 0 end)  end as v151pos_52_max,
	case when isnull(@max_v152mp_41, 0)  < @v152mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  then isnull(@max_v152mp_41, 0)  else @v152mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_41_max,
	case when isnull(@max_v152mp_42, 0)  < @v152mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  then isnull(@max_v152mp_42, 0)  else @v152mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 152  then cs.apositiontaking else 0 end)  end as v152pos_42_max,
	case when isnull(@max_v152mp_51, 0)  < @v152mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  then isnull(@max_v152mp_51, 0)  else @v152mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_51_max,
	case when isnull(@max_v152mp_52, 0)  < @v152mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  then isnull(@max_v152mp_52, 0)  else @v152mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 152  then cs.apositiontaking else 0 end)  end as v152pos_52_max,
	case when isnull(@max_v153mp_51, 0)  < @v153mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  then isnull(@max_v153mp_51, 0)  else @v153mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  end as v153pos_51_max,
	case when isnull(@max_v153mp_52, 0)  < @v153mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  then isnull(@max_v153mp_52, 0)  else @v153mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 153  then cs.apositiontaking else 0 end)  end as v153pos_52_max,
	*/
	
	--m1_max = (m3-a1)
	@v151mapositiontaking_31_max - max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  as v151pos_31_max,
	@v151mapositiontaking_32_max - max(case when cs.bettype = 32 and cs.sporttype = 151  then cs.apositiontaking else 0 end) as v151pos_32_max,
	@v151mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  as v151pos_41_max,
	@v151mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 151  then cs.apositiontaking else 0 end) as v151pos_42_max,
	@v151mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  as v151pos_51_max,
	@v151mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 151  then cs.apositiontaking else 0 end) as v151pos_52_max,
	@v152mapositiontaking_41_max - max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  as v152pos_41_max,
	@v152mapositiontaking_42_max - max(case when cs.bettype = 42 and cs.sporttype = 152  then cs.apositiontaking else 0 end) as v152pos_42_max,
	@v152mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  as v152pos_51_max,
	@v152mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 152  then cs.apositiontaking else 0 end) as v152pos_52_max,
	@v153mapositiontaking_51_max - max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  as v153pos_51_max,
	@v153mapositiontaking_52_max - max(case when cs.bettype = 52 and cs.sporttype = 153  then cs.apositiontaking else 0 end) as v153pos_52_max,
	------------------------------------------------------------------------------------------------------------------------------------
	case when @v151mapositiontaking_31_min - max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_31_min - max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_31_min,
	case when @v151mapositiontaking_32_min - max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_32_min - max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_32_min,
	case when @v151mapositiontaking_41_min - max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_41_min - max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_41_min,
	case when @v151mapositiontaking_42_min - max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_42_min - max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_42_min,
	case when @v151mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_51_min,
	case when @v151mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  <0 then 0 else @v151mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.apositiontaking else 0 end)  end as v151pos_52_min,
	case when @v152mapositiontaking_41_min - max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  <0 then 0 else @v152mapositiontaking_41_min - max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_41_min,
	case when @v152mapositiontaking_42_min - max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  <0 then 0 else @v152mapositiontaking_42_min - max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_42_min,
	case when @v152mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  <0 then 0 else @v152mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_51_min,
	case when @v152mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  <0 then 0 else @v152mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.apositiontaking else 0 end)  end as v152pos_52_min,
	case when @v153mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  <0 then 0 else @v153mapositiontaking_51_min - max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  end as v153pos_51_min,
	case when @v153mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  <0 then 0 else @v153mapositiontaking_52_min - max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.apositiontaking else 0 end)  end as v153pos_52_min,

	--im2
	@isauto_v151mpositiontaking_31 	as	isauto_v151mpositiontaking_31,
	@isauto_v151mpositiontaking_32 	as	isauto_v151mpositiontaking_32, 
	@isauto_v151mpositiontaking_41 	as	isauto_v151mpositiontaking_41,
	@isauto_v151mpositiontaking_42 	as	isauto_v151mpositiontaking_42,
	@isauto_v151mpositiontaking_51 	as	isauto_v151mpositiontaking_51,
	@isauto_v151mpositiontaking_52 	as	isauto_v151mpositiontaking_52,
	@isauto_v152mpositiontaking_41 	as	isauto_v152mpositiontaking_41,
	@isauto_v152mpositiontaking_42 	as	isauto_v152mpositiontaking_42,
	@isauto_v152mpositiontaking_51 	as	isauto_v152mpositiontaking_51,
	@isauto_v152mpositiontaking_52 	as	isauto_v152mpositiontaking_52,
	@isauto_v153mpositiontaking_51 	as	isauto_v153mpositiontaking_51,
	@isauto_v153mpositiontaking_52 	as	isauto_v153mpositiontaking_52,
	--im1
	max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_31,
	max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_32,
	max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_41,
	max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_42,	 
	max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.isautompositiontaking else 0 end) as isauto_v151mpositiontaking_mem_52,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_mem_41,
	max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_mem_42,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.isautompositiontaking else 0 end) as isauto_v152mpositiontaking_mem_52,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.isautompositiontaking else 0 end) as isauto_v153mpositiontaking_mem_52,
	--um1
	max(case when cs.bettype = 31 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_31,
	max(case when cs.bettype = 32 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_32,
	max(case when cs.bettype = 41 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_41,
	max(case when cs.bettype = 42 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_42,
	max(case when cs.bettype = 51 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 151 then cs.autompositiontaking else 0 end) as auto_v151mpositiontaking_mem_52,
	max(case when cs.bettype = 41 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_mem_41,
	max(case when cs.bettype = 42 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_mem_42,
	max(case when cs.bettype = 51 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 152 then cs.autompositiontaking else 0 end) as auto_v152mpositiontaking_mem_52,
	max(case when cs.bettype = 51 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_mem_51,
	max(case when cs.bettype = 52 and cs.sporttype = 153 then cs.autompositiontaking else 0 end) as auto_v153mpositiontaking_mem_52,
	--um1_max
	isnull(@v151mapositiontaking_31_max,0) as auto_v151mpositiontaking_mem_31_max,
	isnull(@v151mapositiontaking_32_max,0) as auto_v151mpositiontaking_mem_32_max,
	isnull(@v151mapositiontaking_41_max,0) as auto_v151mpositiontaking_mem_41_max,
	isnull(@v151mapositiontaking_42_max,0) as auto_v151mpositiontaking_mem_42_max,
	isnull(@v151mapositiontaking_51_max,0) as auto_v151mpositiontaking_mem_51_max,
	isnull(@v151mapositiontaking_52_max,0) as auto_v151mpositiontaking_mem_52_max,
	isnull(@v152mapositiontaking_41_max,0) as auto_v152mpositiontaking_mem_41_max,
	isnull(@v152mapositiontaking_42_max,0) as auto_v152mpositiontaking_mem_42_max,
	isnull(@v152mapositiontaking_51_max,0) as auto_v152mpositiontaking_mem_51_max,
	isnull(@v152mapositiontaking_52_max,0) as auto_v152mpositiontaking_mem_52_max,
	isnull(@v153mapositiontaking_51_max,0) as auto_v153mpositiontaking_mem_51_max,
	isnull(@v153mapositiontaking_52_max,0) as auto_v153mpositiontaking_mem_52_max
FROM 
	customer as C with (nolock) 
	INNER JOIN custinfo as ci with (NOLOCK) on c.custid  = ci.custid
	INNER JOIN CustSetting3rd as cs with (NOLOCK) on c.custid  = cs.custid
WHERE c.custid=@custId AND c.recommend=@agentId AND  cs.sporttype BETWEEN 151 AND 153
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
	ci.maxpermatch151_au,
	ci.maxpermatch152_uk,
	ci.maxpermatch152_au,
	ci.maxpermatch153_au,
	ci.credit,
	ci.disablehorseracing,
	ci.disableOpenTote,
	ci.disable151_au,
	ci.disable152_uk,
	ci.disable152_au,
	ci.disable153_au






GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_MAg] TO [bodbAdminNet]
 GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_MAg] TO [bodbExtAccNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_MAg] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerSelHREditMember_MAg] TO [bodbDownlineNetView]
GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelHREditMember_MAg] TO [vnteam]
GO 