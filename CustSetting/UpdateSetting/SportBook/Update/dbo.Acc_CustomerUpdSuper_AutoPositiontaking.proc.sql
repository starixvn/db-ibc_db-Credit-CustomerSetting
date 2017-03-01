ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_AutoPositiontaking]
	@srecommend int
AS
--@Source Control
/*
Created: 2008@Thien
Task : Recalculate s1 when update s4
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdAutoPositiontaking_Com

Revision: 
	- 20101012@Jamie: Modify Number Game 

Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

--u = (i3 or i1)?(u3 or u1)
--s1 = min(s4-m1-a1, u)
Update custsetting
	set spositiontaking = case when scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking >
							(case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting.isautopositiontaking=1 then custsetting.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting.mpositiontaking-custsetting.apositiontaking end 
from
	custsetting
	inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and (custsetting.isautopositiontaking=1 or mcs.isautopositiontaking=1)
	
--v161
 
Update custsetting3rd 
	set spositiontaking = case when scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
							(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs3.autopositiontaking end) else scs3.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
from
	custsetting3rd 
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and (custsetting3rd.isautopositiontaking=1 or mcs3.isautopositiontaking=1)


Update custsetting
	set slivepositiontaking = case when scs.slivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking >
							(case when custsetting.isautolivepositiontaking=1 then custsetting.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting.isautolivepositiontaking=1 then custsetting.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting.mlivepositiontaking-custsetting.alivepositiontaking end 
from
	custsetting
	inner join custinfo as c with (NOLOCK) on custsetting.custid = c.custid
	inner join custsetting as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting.sporttype and mcs.bettype=custsetting.bettype
	inner join custsetting as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting.sporttype and scs.bettype=custsetting.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and (custsetting.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)
	
	
--v161 
Update custsetting3rd
	set slivepositiontaking = case when scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
							(case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs3.autolivepositiontaking end) else scs3.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
from
	custsetting3rd
	inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	inner join custsetting3rd as mcs3 with (NOLOCK) on mcs3.custid = c.mrecommend and mcs3.sporttype=custsetting3rd.sporttype and mcs3.bettype=custsetting3rd.bettype
	inner join custsetting3rd as scs3 with (NOLOCK) on scs3.custid = @srecommend and scs3.sporttype=custsetting3rd.sporttype and scs3.bettype=custsetting3rd.bettype
where
	c.srecommend = @srecommend
	and c.roleid = 1
	and (custsetting3rd.isautolivepositiontaking=1 or mcs3.isautolivepositiontaking=1)

--Thien20081119: No need to run this SP
--exec Acc_CustomerUpdSuper_MinMaxPositiontaking @srecommend


GO
GRANT EXECUTE ON [dbo].Acc_CustomerUpdSuper_AutoPositiontaking TO [bodbAdminNet]
GO
GRANT VIEW DEFINITION ON [dbo].Acc_CustomerUpdSuper_AutoPositiontaking TO [vnteam]
GO
