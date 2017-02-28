ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgent_MaxPositiontaking]
	@recommend int
AS

/*
Created: 20081009@Phuc
Task : update PT at member when master update agent.
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdAgent_MaxPositiontaking

Revisions:
	- 20090630@Phuc: auto master PT on member level.
	- 20101005@Lukas: add checking number game setting
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	
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
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.apositiontaking < aco.minpositiontaking 

--Live(min)
update cs 
	set alivepositiontaking = aco.minlivepositiontaking 
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.sporttype=1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking < aco.minlivepositiontaking 

--Nonlive(max)
update cs 
	set apositiontaking = aco.maxpositiontaking 
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.apositiontaking > aco.maxpositiontaking 

--Live(max)
update cs 
	set alivepositiontaking = aco.maxlivepositiontaking 
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride aco with(nolock) on aco.custid = @recommend and aco.sporttype = cs.sporttype and aco.bettype = cs.bettype 
where cs.sporttype=1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking > aco.maxlivepositiontaking 

 --- number game
-- non-live (min)
update cs3
set cs3.apositiontaking = aco3.minpositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.apositiontaking < aco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

-- live (min)
update cs3
set cs3.alivepositiontaking = aco3.minlivepositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking < aco3.minlivepositiontaking

-- non-live(max)
update cs3
set cs3.apositiontaking = aco3.maxpositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.roleid = 1 and mb.recommend = @recommend
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) and cs3.apositiontaking > aco3.maxpositiontaking

-- live(max)
update cs3
set cs3.alivepositiontaking = aco3.maxlivepositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd aco3 with(nolock) on aco3.custid = @recommend and aco3.sporttype = cs3.sporttype and aco3.bettype = cs3.bettype
where cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking > aco3.maxlivepositiontaking
-------------------------------------------------------------------------------------------------------------------------------------------------  

--Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
--Nonlive
update cs 
	set mpositiontaking = macs.mpositiontaking - cs.apositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custsetting macs with(nolock) on macs.custid = mb.mrecommend and macs.sporttype = cs.sporttype and macs.bettype = cs.bettype 
where cs.apositiontaking + cs.mpositiontaking > macs.mpositiontaking 
--Live
update cs 
	set mlivepositiontaking = macs.mlivepositiontaking - cs.alivepositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custsetting macs with(nolock) on macs.custid = mb.mrecommend and macs.sporttype = cs.sporttype and macs.bettype = cs.bettype 
where cs.sporttype=1 and cs.bettype in (1,3,7,8) and cs.alivepositiontaking + cs.mlivepositiontaking > macs.mlivepositiontaking 


-- number game
-- non-live
update cs3
set mpositiontaking = macs3.mpositiontaking - cs3.apositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
where cs3.apositiontaking + cs3.mpositiontaking > macs3.mpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

-- live
update cs3
set mlivepositiontaking = macs3.mlivepositiontaking - cs3.alivepositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custsetting3rd macs3 with(nolock) on macs3.custid = mb.mrecommend and macs3.sporttype = cs3.sporttype and macs3.bettype = cs3.bettype
where cs3.alivepositiontaking + cs3.mlivepositiontaking > macs3.mlivepositiontaking and cs3.sporttype = 161 and cs3.bettype in (85,86,87,89,90) 

--Recal u2
--Recal AUTO MPT m1=min(m3-a1,u2)
-------------------------------------------------------------------------------------------------------------------------------------------------  
--Nonlive
Update custsetting with (ROWLOCK, UPDLOCK) 
	set mpositiontaking = 
		case when mcs.mpositiontaking-custsetting.apositiontaking > case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end
			then case when custsetting.isautompositiontaking = 1 then custsetting.autompositiontaking else acs.autompositiontaking end
		else  mcs.mpositiontaking-custsetting.apositiontaking end
from
	custsetting
	inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as acs with (NOLOCK) on acs.custid = mb.recommend and acs.sporttype=custsetting.sporttype and acs.bettype=custsetting.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1
	and (acs.isautompositiontaking = 1 or custsetting.isautompositiontaking = 1)
--Live	
Update custsetting with (ROWLOCK, UPDLOCK) 
	set mlivepositiontaking =
		case when mcs.mlivepositiontaking-custsetting.alivepositiontaking > case when custsetting.isautolivempositiontaking = 1 then custsetting.autolivempositiontaking else acs.autolivempositiontaking end
			then case when custsetting.isautolivempositiontaking = 1 then custsetting.autolivempositiontaking else acs.autolivempositiontaking end
		else  mcs.mlivepositiontaking-custsetting.alivepositiontaking end
from
	custsetting
	inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as acs with (NOLOCK) on acs.custid = mb.recommend and acs.sporttype=custsetting.sporttype and acs.bettype=custsetting.bettype
where custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8)
	and mb.recommend = @recommend
	and mb.roleid = 1
	and (acs.isautolivempositiontaking = 1 or custsetting.isautolivempositiontaking = 1)

--- number game 
-- non-live
Update cs3 with (ROWLOCK, UPDLOCK) 
	set cs3.mpositiontaking = 
		case when mcs3.mpositiontaking-cs3.apositiontaking > case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
			then case when cs3.isautompositiontaking = 1 then cs3.autompositiontaking else acs3.autompositiontaking end
		else  mcs3.mpositiontaking-cs3.apositiontaking end
from
	custsetting3rd cs3
	inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
	inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1	
	and (acs3.isautompositiontaking = 1 or cs3.isautompositiontaking = 1)
	and cs3.sporttype = 161
	and cs3.bettype in (81,83,86,88) 

-- live
Update cs3 with (ROWLOCK, UPDLOCK) 
	set mlivepositiontaking =
		case when mcs3.mlivepositiontaking-cs3.alivepositiontaking > case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
			then case when cs3.isautolivempositiontaking = 1 then cs3.autolivempositiontaking else acs3.autolivempositiontaking end
		else  mcs3.mlivepositiontaking-cs3.alivepositiontaking end
from
	custsetting3rd cs3
	inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
	inner join custsetting3rd as acs3 with (NOLOCK) on acs3.custid = mb.recommend and acs3.sporttype=cs3.sporttype and acs3.bettype=cs3.bettype
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90)
	and mb.recommend = @recommend
	and mb.roleid = 1
	and (acs3.isautolivempositiontaking = 1 or cs3.isautolivempositiontaking = 1)
-------------------------------------------------------------------------------------------------------------------------------------------------  


-------------------------------------------------------------------------------------------------------------------------------------------------  
--Check min max n3<=m1+a1<=l3 => modify m1
--Nonlive(min)
update cs
	set cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking

--Live(min)
update cs
	set cs.mlivepositiontaking = mco.minlivepositiontaking - cs.alivepositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.sporttype=1 and cs.bettype in (1,3,7,8) and cs.mlivepositiontaking + cs.alivepositiontaking < mco.minlivepositiontaking
--Nonlive(max)
update cs
	set cs.mpositiontaking = mco.maxpositiontaking - cs.apositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.mpositiontaking + cs.apositiontaking > mco.maxpositiontaking

--Live(max)
update cs
	set cs.mlivepositiontaking = mco.maxlivepositiontaking - cs.alivepositiontaking
from custsetting cs with(rowlock,updlock) inner join custinfo mb with(nolock) on cs.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride mco with(nolock) on mco.custid = mb.mrecommend and cs.sporttype = mco.sporttype and cs.bettype = mco.bettype 
where cs.sporttype=1 and cs.bettype in (1,3,7,8) and cs.mlivepositiontaking + cs.alivepositiontaking > mco.maxlivepositiontaking

-- number game
-- non-live
update cs3
set cs3.mpositiontaking = mco3.minpositiontaking - cs3.apositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype
where cs3.mpositiontaking + cs3.apositiontaking < mco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88) 

--Live(min)
update cs3
	set cs3.mlivepositiontaking = mco3.minlivepositiontaking - cs3.alivepositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking < mco3.minlivepositiontaking

--Nonlive(max)
update cs3
	set cs3.mpositiontaking = mco3.maxpositiontaking - cs3.apositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
where cs3.mpositiontaking + cs3.apositiontaking > mco3.maxpositiontaking and cs3.sporttype = 161  and cs3.bettype in (81,83,86,88)

--Live(max)
update cs3
	set cs3.mlivepositiontaking = mco3.maxlivepositiontaking - cs3.alivepositiontaking
from custsetting3rd cs3 with(rowlock,updlock) inner join custinfo mb with(nolock) on cs3.custid = mb.custid and mb.recommend = @recommend and mb.roleid = 1
	inner join custoverride3rd mco3 with(nolock) on mco3.custid = mb.mrecommend and cs3.sporttype = mco3.sporttype and cs3.bettype = mco3.bettype 
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.mlivepositiontaking + cs3.alivepositiontaking > mco3.maxlivepositiontaking

-------------------------------------------------------------------------------------------------------------------------------------------------  


-------------------------------------------------------------------------------------------------------------------------------------------------  
--Recal u3,u1
-- s1=min(s4-m1-a1,u)
--Nonlive
Update custsetting with (ROWLOCK, UPDLOCK) 
	set spositiontaking = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking >
							(case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end 
from
	custsetting
	inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = mb.srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1
	and (custsetting.isautopositiontaking=1 or mcs.isautopositiontaking=1)

--Live
Update custsetting with (ROWLOCK, UPDLOCK) 
	set slivepositiontaking = case when scs.slivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking >
							(case when custsetting.isautolivepositiontaking=1 then custsetting.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting.isautolivepositiontaking=1 then custsetting.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking end 
from
	custsetting
	inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid 
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = mb.srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8) 
	and mb.recommend = @recommend 
	and mb.roleid = 1
	and (custsetting.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)

-- number game
--Nonlive
Update cs3 with (ROWLOCK, UPDLOCK) 
	set spositiontaking = case when scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking >
							(case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) then (case when cs3.isautopositiontaking=1 then cs3.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-cs3.mpositiontaking-cs3.apositiontaking end 
from
	custsetting3rd cs3
	inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
where
	mb.recommend = @recommend
	and mb.roleid = 1
	and (cs3.isautopositiontaking=1 or mcs3.isautopositiontaking=1)
	and cs3.sporttype = 161
	and cs3.bettype in (81,83,86,88)
	
--Live
Update cs3 with (ROWLOCK, UPDLOCK) 
	set slivepositiontaking = case when scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking >
							(case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when cs3.isautolivepositiontaking=1 then cs3.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking end 
from
	custsetting3rd cs3
	inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid 
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = mb.mrecommend and mcs3.sporttype=cs3.sporttype and mcs3.bettype=cs3.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = mb.srecommend and scs3.sporttype=cs3.sporttype and scs3.bettype=cs3.bettype
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) 
	and mb.recommend = @recommend 
	and mb.roleid = 1
	and (cs3.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)
-------------------------------------------------------------------------------------------------------------------------------------------------  

	
-------------------------------------------------------------------------------------------------------------------------------------------------  
--check super min/max when a1+m1+s1<n4
-- s1=n4-m1-a1
--Nonlive(min)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco.minpositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.apositiontaking+custsetting.mpositiontaking+custsetting.spositiontaking<sco.minpositiontaking

--Live(min)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	slivepositiontaking = sco.minlivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8) and custsetting.alivepositiontaking+custsetting.mlivepositiontaking+custsetting.slivepositiontaking<sco.minlivepositiontaking

--Nonlive(max)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco.maxpositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.apositiontaking+custsetting.mpositiontaking+custsetting.spositiontaking>sco.maxpositiontaking

--Live(max)
Update custsetting with (ROWLOCK, UPDLOCK) set 
	slivepositiontaking = sco.maxlivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking
from 
	custsetting inner join custinfo as mb with (NOLOCK) on custsetting.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride as sco with (NOLOCK) on sco.custid = mb.srecommend  and sco.sporttype=custsetting.sporttype and sco.bettype=custsetting.bettype
where custsetting.sporttype=1 and custsetting.bettype in (1,3,7,8) and custsetting.alivepositiontaking+custsetting.mlivepositiontaking+custsetting.slivepositiontaking>sco.maxlivepositiontaking

-- number game
--Nonlive(min)
Update cs3 with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco3.minpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
from 
	custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
where cs3.apositiontaking + cs3.mpositiontaking + cs3.spositiontaking<sco3.minpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

--Live(min)
Update cs3 with (ROWLOCK, UPDLOCK) set 
	slivepositiontaking = sco3.minlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
from 
	custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking<sco3.minlivepositiontaking

--Nonlive(max)
Update cs3 with (ROWLOCK, UPDLOCK) set 
	spositiontaking = sco3.maxpositiontaking-cs3.mpositiontaking-cs3.apositiontaking
from 
	custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
where cs3.apositiontaking+cs3.mpositiontaking+cs3.spositiontaking>sco3.maxpositiontaking and cs3.sporttype = 161 and cs3.bettype in (81,83,86,88)

--Live(max)
Update cs3 with (ROWLOCK, UPDLOCK) set 
	slivepositiontaking = sco3.maxlivepositiontaking-cs3.mlivepositiontaking-cs3.alivepositiontaking
from 
	custsetting3rd cs3 inner join custinfo as mb with (NOLOCK) on cs3.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1
	inner join custoverride3rd as sco3 with (NOLOCK) on sco3.custid = mb.srecommend  and sco3.sporttype=cs3.sporttype and sco3.bettype=cs3.bettype
where cs3.sporttype=161 and cs3.bettype in (85,86,87,89,90) and cs3.alivepositiontaking+cs3.mlivepositiontaking+cs3.slivepositiontaking>sco3.maxlivepositiontaking

-------------------------------------------------------------------------------------------------------------------------------------------------


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MaxPositiontaking] TO [bodbAdminNet]
Go