ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_00] 
	@custid int = 0,
	@recommend int = 0,
	@mrecommend int = 0,
	@srecommend int = 0,
	@sporttype		INT = 0, 
	@bettype		INT = 0,
	@updautomaster bit = 1,
	@updautosuper bit = 1,
	@mode varchar(20) =''--'horse' or 'number' or 'finance' or 'virtual-sports'
AS
/*
Created: 20131113@Johnson
Task : Correct PT after SMA update pt on member
DB: DBCUST/CustDB
Original: Acc_CustomerUpdMemberHR_MinPositiontaking, 
		Acc_CustomerUpdMember_MinPositiontaking, 
		Acc_CustomerUpdMemberFI_MinPositiontaking

Revisions:
	- 20140314@Elodie: Add Keno product [Redmine:#13326]
	- 20150424@Kathy: Add Gold Deluxe product [Redmine:#34486]
	- 20150610@Daniel: 
	    + Improve medthod check table existing in subscribers	
	    + Separate custDB to new server DBCUST

Param's Explanation:
* @mode:
    = 'horse': Horse racing
    = 'number': Number Game
     = 'finance': Financial betting
    = 'virtual-sports': Virtual Soccer
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
SET NOCOUNT ON

IF NOT(dbo.f_CheckRepTable('custinfo') = 1 
   AND dbo.f_CheckRepTable('CustSettingGame') = 1 
   AND dbo.f_CheckRepTable('CustOverrideGame') = 1 
   AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
   AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
   )
 RETURN

declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney

if @mode = 'horse'
BEGIN	    
	--check agent min/max
	--update a1=n2 when a1<n2
	Update cs 
		set cs.apositiontaking = aco.minpositiontaking,
			cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking<aco.minpositiontaking
		and cs.sporttype between 151 and 153


	--update a1=l2 when a1>l2
	Update CustSetting3rd with (ROWLOCK, UPDLOCK) set 
		apositiontaking = aco.maxpositiontaking
	from 
		CustSetting3rd as cs
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking>aco.maxpositiontaking
		and cs.sporttype between 151 and 153




	--Recal AUTO MPT 
	--Update m1=min(m3-a1,(im1?um1,um2))
	-----------------
	Update cs
		set mpositiontaking = 
			case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
				then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
			else  mcs.mpositiontaking-cs.apositiontaking end
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
	where
		c.custid = @custid
		and c.roleid = 1
		and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
		and cs.sporttype between 151 and 153
		
	-------------------



	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	Update cs
		set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
		and cs.sporttype between 151 and 153

	-----------------


	--update m1,a1 when a1+m1>l3
	--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	Update cs
		set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
			@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
		and cs.sporttype between 151 and 153

	-----------------

	--recal autopos
	Update cs
		set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
								(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	where
		cs.custid = @custid
		and c.roleid = 1
		and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
		and cs.sporttype between 151 and 153


	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	Update cs
		set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
		and cs.sporttype between 151 and 153


	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	Update cs
		set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
			spositiontaking = @spos,
			@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,
			@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
			@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
			@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
			@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
		and cs.sporttype between 151 and 153
	
	RETURN

END--end @mode = 'horse'
------------

if @mode = 'number'
BEGIN
	   
	--check agent min/max
	--update a1=n2 when a1<n2
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		custsetting3rd.apositiontaking = aco.minpositiontaking,
		custsetting3rd.mpositiontaking = case when custsetting3rd.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting3rd.mpositiontaking end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161  and  custsetting3rd.apositiontaking<aco.minpositiontaking

	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		alivepositiontaking = aco.minlivepositiontaking,
		custsetting3rd.mlivepositiontaking = case when custsetting3rd.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking-aco.minlivepositiontaking else custsetting3rd.mlivepositiontaking end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking<aco.minlivepositiontaking



	--update a1=l2 when a1>l2	
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		apositiontaking = aco.maxpositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking>aco.maxpositiontaking


	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		alivepositiontaking = aco.maxlivepositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking>aco.maxlivepositiontaking

	--Recal AUTO MPT 
	--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
	-------------------
	if @updautomaster = 1
	begin		
		Update custsetting3rd with (ROWLOCK, UPDLOCK) 
			set mpositiontaking =
				case when scs.mpositiontaking > mcs.mpositiontaking then 
					case when mcs.mpositiontaking-custsetting3rd.apositiontaking > (case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end)
					then (case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end)
					else  mcs.mpositiontaking-custsetting3rd.apositiontaking end
				else
					case when scs.mpositiontaking-custsetting3rd.apositiontaking > (case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end)
					then (case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end)
					else  scs.mpositiontaking-custsetting3rd.apositiontaking end
				end
		from
			custsetting3rd
			inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
			inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as scs with (NOLOCK) on scs.custid = c.srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
		where
			c.custid = @custid
			and c.roleid = 1
			and custsetting3rd.sporttype = 161
			and (acs.isautompositiontaking = 1 or custsetting3rd.isautompositiontaking = 1)
			
		Update custsetting3rd with (ROWLOCK, UPDLOCK) 
			set mlivepositiontaking =
				case when scs.mlivepositiontaking > mcs.mlivepositiontaking then
					case when mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking > (case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end)
						then (case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end)
					else  mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking end
				else
					case when scs.mlivepositiontaking-custsetting3rd.alivepositiontaking > (case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end)
						then (case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end)
					else  scs.mlivepositiontaking-custsetting3rd.alivepositiontaking end
				end
		from
			custsetting3rd
			inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
			inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as scs with (NOLOCK) on scs.custid = c.srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
		where
			c.custid = @custid
			and c.roleid = 1
			and custsetting3rd.sporttype = 161
			and custsetting3rd.bettype in (85, 86, 87,89,90)
			and (acs.isautolivempositiontaking = 1 or custsetting3rd.isautolivempositiontaking = 1)	
	end
	----------



	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		mpositiontaking = mco.minpositiontaking-custsetting3rd.apositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161  and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking<mco.minpositiontaking


	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		mlivepositiontaking = mco.minlivepositiontaking-custsetting3rd.alivepositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking<mco.minlivepositiontaking

	-------------------


	--update m1,a1 when a1+m1>l3
	--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161 and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
		@mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
		mlivepositiontaking = @mpos,
		@apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
		alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking
	-----------------------------------------------------------------------------------------------------------------------------------

	--recal autopos
	if @updautosuper = 1 
	begin
		Update custsetting3rd with (ROWLOCK, UPDLOCK) 
			set spositiontaking = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
									(case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
		from
			custsetting3rd
			inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
			inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
		where
			custsetting3rd.custid = @custid
			and c.roleid = 1
			and custsetting3rd.sporttype = 161
			and (custsetting3rd.isautopositiontaking=1 or mcs.isautopositiontaking=1)

		Update custsetting3rd with (ROWLOCK, UPDLOCK) 
			set slivepositiontaking = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
									(case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
		from
			custsetting3rd
			inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
			inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
			inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
		where
			custsetting3rd.custid = @custid
			and c.roleid = 1
			and custsetting3rd.sporttype = 161
			and custsetting3rd.bettype in (85,86,87,89,90)
			and (custsetting3rd.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	
	end

	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		spositiontaking = sco.minpositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161 and  custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking+custsetting3rd.spositiontaking<sco.minpositiontaking

	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		slivepositiontaking = sco.minlivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking+custsetting3rd.slivepositiontaking<sco.minlivepositiontaking


	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@spos = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking<0 then 0 else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end,
		spositiontaking = @spos,
		@mapos1 = case when @spos+custsetting3rd.mpositiontaking+custsetting3rd.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else custsetting3rd.mpositiontaking+custsetting3rd.apositiontaking end,
		@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
		@mpos = case when @mapos-custsetting3rd.apositiontaking<0 then 0 else @mapos-custsetting3rd.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when custsetting3rd.apositiontaking + @mpos>@mapos then @mapos-@mpos else custsetting3rd.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = 161 and custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@spos = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking<0 then 0 else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end,
		slivepositiontaking = @spos,
		@mapos1 = case when @spos+custsetting3rd.mlivepositiontaking+custsetting3rd.alivepositiontaking>scs.slivepositiontaking then scs.slivepositiontaking-@spos else custsetting3rd.mlivepositiontaking+custsetting3rd.alivepositiontaking end,
		@maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
		@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		@mapos = case when @mapos2<mco.minlivepositiontaking then mco.minlivepositiontaking else @mapos2 end,
		@mpos = case when @mapos-custsetting3rd.alivepositiontaking<0 then 0 else @mapos-custsetting3rd.alivepositiontaking end,
		mlivepositiontaking = @mpos,
		@apos = case when custsetting3rd.alivepositiontaking + @mpos>@mapos then @mapos-@mpos else custsetting3rd.alivepositiontaking end,
		alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

    RETURN
END
if @mode = 'virtual-sports'
BEGIN
	--check agent min/max
	--update a1=n2 when a1<n2
	Update cs 
	set cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking<aco.minpositiontaking
		and cs.sporttype = @sporttype
		and cs.bettype = @bettype

	--update a1=l2 when a1>l2
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	apositiontaking = aco.maxpositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.custid = @custid and custsetting3rd.sporttype = @sporttype and custsetting3rd.apositiontaking>aco.maxpositiontaking

	
	--Recal AUTO MPT 
	--Update m1=min(m4-a1,m3-a1,(im1?um1,um2))
	---------------
	Update cs
		set mpositiontaking = 
			case when scs.mpositiontaking > mcs.mpositiontaking then 
				case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				else  mcs.mpositiontaking-cs.apositiontaking end
			else
				case when scs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
				else  scs.mpositiontaking-cs.apositiontaking end
			end
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join custsetting3rd as scs with (NOLOCK) on scs.custid = c.srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
	where
		c.custid = @custid
		and c.roleid = 1
		and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	Update cs
		set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--update m1,a1 when a1+m1>l3
	--update m1=if(min(m3,l3)-a1<0,0,min(m3,l3)-a1)
	--update a1=if(a1+m1>min(m3,l3),min(m3,l3)-m1,a1)
	Update cs
		set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
			@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
		
	--recal autopos
	Update cs
		set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
								(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = @custid and cs.custid = c.custid and c.roleid = 1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
		and cs.sporttype = @sporttype and cs.bettype = @bettype
		
	
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	Update cs
		set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
		
	
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)	
	--@mapos2=min(@mapos1,m3)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	Update cs
		set @spos = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking<0 then 0 else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end,
			spositiontaking = @spos,
			@mapos1 = case when @spos+cs.mpositiontaking+cs.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else cs.mpositiontaking+cs.apositiontaking end,			
			@mapos2 = case when @mapos1 > mcs.mpositiontaking then mcs.mpositiontaking else @mapos1 end,
			@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
			@mpos = case when @mapos-cs.apositiontaking<0 then 0 else @mapos-cs.apositiontaking end,
			mpositiontaking = @mpos,
			@apos = case when cs.apositiontaking + @mpos>@mapos then @mapos-@mpos else cs.apositiontaking end,
			apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.custid = @custid and mb.roleid=1
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.custid = @custid 
		and cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
		
    RETURN	
END-- end mode = 'virtual-sports'
if @mode = 'LiveCasino'
BEGIN		
	DECLARE @UplineSyncLiveCS BIT
	
	SELECT @UplineSyncLiveCS = SyncLiveCasino FROM CustInfo WITH(NOLOCK) WHERE custid = @recommend 
	
	--check agent min/max
	--update a1=n2 when a1<n2
	UPDATE cs
	SET cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs	
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.apositiontaking < aco.minpositiontaking
	
	--Recal AUTO MPT 
	--Update m1=min(m3-a1,(im1?um1,um2))
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
				CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END ELSE mcs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
	
		
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = 162 AND mco.bettype = 1101
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype= 1101
	
	
	--update m1,a1 when a1+m1>m3
	--update m1=if(m3-a1<0,0,m3-a1)
	--update a1=if(a1+m1>m3,m3-m1,a1)
	UPDATE cs
	SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END	
	FROM CustSettingGame cs
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 		
		
	--recal autopos
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
										CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
								ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
		
		
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	UPDATE cs
	SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs
		INNER JOIN CustOverrideGame sco WITH (NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking  + cs.apositiontaking < sco.minpositiontaking
		
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	
	UPDATE cs
	SET @spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		cs.spositiontaking = @spos,
		@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		@mapos  = CASE WHEN @mapos > mco.minpositiontaking THEN @mapos ELSE mco.minpositiontaking END,		
		@mpos = CASE WHEN @mapos - cs.apositiontaking > 0 THEN @mapos - cs.apositiontaking ELSE 0 END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN @apos ELSE aco.minpositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE @UplineSyncLiveCS = 1 AND cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
	
    RETURN	
END--end mode = 'LiveCasino'

if @mode = 'Keno' OR @mode = 'GoldDeluxe'
BEGIN		
	--check agent min/max
	--update a1=n2 when a1<n2
	UPDATE cs
	SET cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs	with (ROWLOCK, UPDLOCK)
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
		AND cs.apositiontaking < aco.minpositiontaking
	
	--Recal AUTO MPT 
	--Update m1=min(m3-a1,(im1?um1,um2))
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
				CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END ELSE mcs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
		
	--check master min/max
	--update m1=n3-a1 if a1+m1<n3
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = @sporttype AND mco.bettype = @bettype
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype= @bettype
	
	--update m1,a1 when a1+m1>m3
	--update m1=if(m3-a1<0,0,m3-a1)
	--update a1=if(a1+m1>m3,m3-m1,a1)
	UPDATE cs
	SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END	
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 		
		
	--recal autopos
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
										CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
								ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype
		AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
		
	--check super min/max
	--update s1 when s1+m1+a1<n4 or s1+m1+a1>l4
	UPDATE cs
	SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustOverrideGame sco WITH (NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype = @bettype 
		AND cs.spositiontaking + cs.mpositiontaking  + cs.apositiontaking < sco.minpositiontaking
		
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	
	UPDATE cs
	SET @spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		cs.spositiontaking = @spos,
		@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		@mapos  = CASE WHEN @mapos > mco.minpositiontaking THEN @mapos ELSE mco.minpositiontaking END,		
		@mpos = CASE WHEN @mapos - cs.apositiontaking > 0 THEN @mapos - cs.apositiontaking ELSE 0 END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos > aco.minpositiontaking THEN @apos ELSE aco.minpositiontaking END
	FROM CustSettingGame cs with (ROWLOCK, UPDLOCK)
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE cs.custid = @custid AND cs.sporttype = @sporttype AND cs.bettype =  @bettype
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
	
    RETURN	
END--end mode = 'Keno', 'GoldDeluxe'