ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentVS_MaxPositiontaking]
	@recommend int
AS
/*
Created: 20120808@Dan
Task : update PT at member when master update agent(Virtual soccer)
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdAgent_MaxPositiontaking
Revisons:
	- 20121203@Scott: add virtual tennis sport type
	- 20130222@Johnson: add virtual horse racing setting (sporttype: 181)
Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON
-------------------------------------------------------------------------------------------------------------------------------------------------  
--Check min max a1: n2<=a1<=l2 => modify a1
--Nonlive(min)

update cs 
	set apositiontaking = aco.minpositiontaking 
from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.apositiontaking < aco.minpositiontaking 
	and cs.sporttype in(180, 181, 186)


--Nonlive(max)
update cs 
	set apositiontaking = aco.maxpositiontaking 
from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join CustOverride3rd aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.apositiontaking > aco.maxpositiontaking 
	and cs.sporttype in(180, 181, 186)

-------------------------------------------------------------------------------------------------------------------------------------------------  

--Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
--Nonlive
update cs 
	set mpositiontaking = macs.mpositiontaking - cs.apositiontaking
from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join CustSetting3rd macs with(nolock) on macs.custid = mb.mrecommend and macs.sporttype = cs.sporttype and macs.bettype = cs.bettype 
where cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
	and cs.sporttype in(180, 181, 186)


--Recal um2
--Recal AUTO MPT m1=min(m3-a1,um2)
-------------------------------------------------------------------------------------------------------------------------------------------------  
--Nonlive
Update cs
	set mpositiontaking = 
		case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
			then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
		else  mcs.mpositiontaking-cs.apositiontaking end
from
	CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
	inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = mb.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1
	and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
	and cs.sporttype in(180, 181, 186)

-------------------------------------------------------------------------------------------------------------------------------------------------  


-------------------------------------------------------------------------------------------------------------------------------------------------  
--Check min max n3<=m1+a1<=l3 => modify m1
--Nonlive(min)
update cs
	set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
	and cs.sporttype in(180, 181, 186)

--Nonlive(max)
update cs
	set cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
from CustSetting3rd cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join CustOverride3rd mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking
	and cs.sporttype in(180, 181, 186)

-------------------------------------------------------------------------------------------------------------------------------------------------  


-------------------------------------------------------------------------------------------------------------------------------------------------  
--Recal u3,u1
-- s1=min(s4-m1-a1,u)
--Nonlive
Update cs
	set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
							(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
from
	CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid
	inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = mb.srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1
	and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
	and cs.sporttype in(180, 181, 186)

-------------------------------------------------------------------------------------------------------------------------------------------------  

	
-------------------------------------------------------------------------------------------------------------------------------------------------  
--check super min/max when a1+m1+s1<n4
-- s1=n4-m1-a1
--Nonlive(min)
Update cs
	set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
from 
	CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
	and cs.sporttype in(180, 181, 186)

--Nonlive(max)
Update cs
	set spositiontaking = sco.maxpositiontaking-cs.mpositiontaking-cs.apositiontaking
from 
	CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking>sco.maxpositiontaking
	and cs.sporttype in(180, 181, 186)

-------------------------------------------------------------------------------------------------------------------------------------------------  

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_MaxPositiontaking] TO [bodbAdminNet]
Go
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentVS_MaxPositiontaking] TO vnteam
Go
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentVS_MaxPositiontaking] TO [bodbExtAccNet]

