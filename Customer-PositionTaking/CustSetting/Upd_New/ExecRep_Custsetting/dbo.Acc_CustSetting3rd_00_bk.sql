 set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

ALTER PROCEDURE [dbo].[Acc_CustSetting3rd_00] @srecommend int,
	@mode varchar(20) = 'horse' --'horse' or 'number' or 'finance' or 'virtual-sports'
AS
--@Source Control
/*
Created: 20090520@Phuc
Task : Update PT at member level when edit n4(HR)
DB: DBTRANS.bodb02
Original: Acc_CustomerUpdSuperHR_MinPositiontaking, Acc_CustomerUpdSuper_MinPositiontaking, Acc_CustomerUpdSuperFI_MinPositiontaking

Revisions for Acc_CustomerUpdSuperHR_MinPositiontaking,:
	- 20090626@Phuc: auto master PT on member level.
    - 20090716@Phuc: Remove update s1 = min(u,s1) cause of recal autos already do it.
					 Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
	- 20091201@Kiwi: Move custsetting & custoverride to the separated tables (CustSetting3rd & CustOverride3rd).
	- 20110126@Lukas: add Greyhound & Harness racing game
	- 20111028@Thien: convert to ExecRep SP

Revisions for Acc_CustomerUpdSuper_MinPositiontaking:
    - 20080923@Phuc Recal: auto master postiontaking
    - 20090626@Phuc: auto master PT on member level. 
    - 20090716@Phuc: Remove update s1 = min(u,s1) cause of recal autos already do it.
					 Remove connection to custoveride table cause of l4=s4(correct data when s1+m1+a1>s4)
	- 20100904@Henry: Add new sporttype (161: numbergame)
	- 20110728@Johnson: - remove bettype dead ball over/under of number game
						- add more bettype for nubmer game Warrior,  Next combo and Number Group
	- 20111028@Thien: convert to ExecRep SP
	- 20111029@Thien: merge Acc_CustomerUpdSuperHR_MinPositiontaking, Acc_CustomerUpdSuperFI_MinPositiontaking
	                        and Acc_CustomerUpdSuper_MinPositiontaking to put
	                    into execRep, for Horse racing and Number Game and finance
	- 20120803@Dan: add virtual soccer sport type	
	- 20121203@Scott: add virtual Tennis sport type                    
	- 20130222@Johnson: add virtual horse racing setting(sporttype: 181)
	- 20131031@Lukas: add Live casino
	
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

DECLARE @IsExistTables tinyint
SET @IsExistTables = 0

IF @mode = 'LiveCasino'
BEGIN	
	SELECT @IsExistTables = COUNT(*) 
	FROM dbo.sysobjects
	WHERE	name IN ('custinfo','CustSettingGame', 'CustOverrideGame')
			AND xtype = 'U'
END
ELSE
BEGIN
	SELECT @IsExistTables = COUNT(*) 
	FROM dbo.sysobjects
	WHERE	name IN ('custinfo','CustSetting3rd', 'CustOverride3rd')
			AND xtype = 'U'
END

IF @IsExistTables <> 3 
	RETURN

declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxspos smallmoney, @maxmapos smallmoney

if @mode = 'horse'
BEGIN

    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
	    and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype between 151 and 153


    ----------------------------------------------------------------------------
    --check agent min
    --a1=max(a1,n2)
    Update cs 
	    set apositiontaking = aco.minpositiontaking,
		    cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking<aco.minpositiontaking
	    and cs.sporttype between 151 and 153

    ----------------------------------------------------------------------------
    --check agent max
    --a1=min(a1,l2)
    Update cs 
	    set apositiontaking = aco.maxpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking>aco.maxpositiontaking
	    and cs.sporttype between 151 and 153
    ----------------------------------------------------------------------------


    --Recal AUTO MPT m1=min(m3-a1,u2)
    -------------------------------------------------------------------------------------
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
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
	    and cs.sporttype between 151 and 153

    	
    -------------------------------------------------------------------------------------


    --check master min
    --m1=max(m1,n3-a1)
    Update cs
	    set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
	    and cs.sporttype between 151 and 153

    ----------------------------------------------------------------------------
    --check master max
    Update cs
	    set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
	    and cs.sporttype between 151 and 153

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
	    and cs.sporttype between 151 and 153

    ----------------------------------------------------------------------------

    --check super min
    --s1=max(n4-m1-a1,s1)
    Update cs
	    set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
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
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype between 151 and 153
	
    RETURN
    
END
------------

if @mode = 'number'
BEGIN
    Declare @_srecommend int
    select @_srecommend = @srecommend

    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    
    --v161
    update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.isautopositiontaking=0 and mcs.isautopositiontaking=0 and scs.spositiontaking - mcs.mpositiontaking<custsetting3rd.spositiontaking


    update custsetting3rd with (ROWLOCK, UPDLOCK) set custsetting3rd.slivepositiontaking = scs.slivepositiontaking - mcs.mlivepositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend = @_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90)
	    and custsetting3rd.isautolivepositiontaking=0 and mcs.isautolivepositiontaking=0 and scs.slivepositiontaking - mcs.mlivepositiontaking<custsetting3rd.slivepositiontaking	
    	
    ----------------------------------------------------------------------------
    --check agent min
    --a1=max(a1,n2)    
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    apositiontaking = aco.minpositiontaking,
	    custsetting3rd.mpositiontaking = case when custsetting3rd.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else custsetting3rd.mpositiontaking end
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and  custsetting3rd.apositiontaking<aco.minpositiontaking

    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    alivepositiontaking = aco.minlivepositiontaking,
	    custsetting3rd.mlivepositiontaking = case when custsetting3rd.mlivepositiontaking + aco.minlivepositiontaking > mcs.mlivepositiontaking then mcs.mlivepositiontaking-aco.minlivepositiontaking else custsetting3rd.mlivepositiontaking end
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking<aco.minlivepositiontaking


    ----------------------------------------------------------------------------
    --check agent max
    --a1=min(a1,l2)    
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    apositiontaking = aco.maxpositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and roleid=1
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking>aco.maxpositiontaking

    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    alivepositiontaking = aco.maxlivepositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking>aco.maxlivepositiontaking

    ----------------------------------------------------------------------------


    --Recal AUTO MPT m1=min(m3-a1,u2)
    -------------------------------------------------------------------------------------
   
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) 
	    set mpositiontaking = 
			    case when mcs.mpositiontaking-custsetting3rd.apositiontaking > case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end
				    then case when custsetting3rd.isautompositiontaking = 1 then custsetting3rd.autompositiontaking else acs.autompositiontaking end
			    else  mcs.mpositiontaking-custsetting3rd.apositiontaking end
    from
	    custsetting3rd
	    inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
    where
	    c.srecommend = @_srecommend
	    and c.roleid = 1
	    and custsetting3rd.sporttype = 161
	    and custsetting3rd.bettype in (81,83,86,88)
	    and (acs.isautompositiontaking = 1 or custsetting3rd.isautompositiontaking = 1)
    		
    Update custsetting3rd with (ROWLOCK, UPDLOCK) 
	    set mlivepositiontaking =
		    case when mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking > case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end
			    then case when custsetting3rd.isautolivempositiontaking = 1 then custsetting3rd.autolivempositiontaking else acs.autolivempositiontaking end
		    else  mcs.mlivepositiontaking-custsetting3rd.alivepositiontaking end
    from
	    custsetting3rd
	    inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsetting3rd.sporttype and acs.bettype=custsetting3rd.bettype
    where
	    c.srecommend = @_srecommend
	    and c.roleid = 1
	    and custsetting3rd.sporttype = 161
	    and custsetting3rd.bettype in (85,86,87,89,90)
	    and (acs.isautolivempositiontaking = 1 or custsetting3rd.isautolivempositiontaking = 1)	
    	
    -------------------------------------------------------------------------------------


    --check master min
    --m1=max(m1,n3-a1)
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    mpositiontaking = mco.minpositiontaking-custsetting3rd.apositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking<mco.minpositiontaking

    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    mlivepositiontaking = mco.minlivepositiontaking-custsetting3rd.alivepositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking<mco.minlivepositiontaking


    ----------------------------------------------------------------------------
    --check master max   
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
	    @mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
	    mpositiontaking = @mpos,
	    @apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
	    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    @maxmapos = case when mcs.mlivepositiontaking>mco.maxlivepositiontaking then mco.maxlivepositiontaking else mcs.mlivepositiontaking end,
	    @mpos = case when @maxmapos-custsetting3rd.alivepositiontaking<0 then 0 else @maxmapos-custsetting3rd.alivepositiontaking end,
	    mlivepositiontaking = @mpos,
	    @apos = case when custsetting3rd.alivepositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.alivepositiontaking end,
	    alivepositiontaking = case when @apos<aco.minlivepositiontaking then aco.minlivepositiontaking else @apos end
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>mco.maxlivepositiontaking

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --recal autopos   
    	
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK)
	    set spositiontaking = case when scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking >
							    (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) then (case when custsetting3rd.isautopositiontaking=1 then custsetting3rd.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking end 
    from
	    custsetting3rd
	    inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where
	    c.srecommend = @_srecommend
	    and c.roleid = 1
	    and custsetting3rd.sporttype = 161
	    and custsetting3rd.bettype in (81,83,89,88)
	    and (custsetting3rd.isautopositiontaking=1 or mcs.isautopositiontaking=1)

    Update custsetting3rd with (ROWLOCK, UPDLOCK)
	    set slivepositiontaking = case when scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking >
							    (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) then (case when custsetting3rd.isautolivepositiontaking=1 then custsetting3rd.autolivepositiontaking else mcs.autolivepositiontaking end) else scs.slivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking end 
    from
	    custsetting3rd
	    inner join custinfo as c with (NOLOCK) on custsetting3rd.custid = c.custid
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
    where
	    c.srecommend = @_srecommend
	    and c.roleid = 1
	    and custsetting3rd.sporttype = 161
	    and custsetting3rd.bettype in (85,86,87,89,90)
	    and (custsetting3rd.isautolivepositiontaking=1 or mcs.isautolivepositiontaking=1)	
    	
    ----------------------------------------------------------------------------

    --check super min
    --s1=max(n4-m1-a1,s1)    
    --v161
    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    spositiontaking = sco.minpositiontaking-custsetting3rd.mpositiontaking-custsetting3rd.apositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @_srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype = 161 and  custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking+custsetting3rd.spositiontaking<sco.minpositiontaking

    Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
	    slivepositiontaking = sco.minlivepositiontaking-custsetting3rd.mlivepositiontaking-custsetting3rd.alivepositiontaking
    from 
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custoverride3rd as sco with (NOLOCK) on sco.custid = @_srecommend  and sco.sporttype=custsetting3rd.sporttype and sco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking+custsetting3rd.slivepositiontaking<sco.minlivepositiontaking

    ----------------------------------------------------------------------------


    --update s1,m1,a1 in case s1+m1+a1>s4
    --s1=max(0,s4-m1-a1)
    --@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
    --@maxmapos=min(m3,l3)
    --@mapos2=min(@mapos1,@maxmapos)
    --@mapos=max(@mapos2,n3)
    --m1=max(0,@mapos-a1)
    --a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
    --v161
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
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where 
	    custsetting3rd.sporttype = 161 and custsetting3rd.bettype in (81,83,86,88) and custsetting3rd.spositiontaking+custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>scs.spositiontaking

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
	    custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.srecommend=@_srecommend and mb.roleid=1
	    inner join custsetting3rd as scs with (NOLOCK) on scs.custid = @_srecommend  and scs.sporttype=custsetting3rd.sporttype and scs.bettype=custsetting3rd.bettype
	    inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	    inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
    where custsetting3rd.sporttype=161 and custsetting3rd.bettype in (85,86,87,89,90) and custsetting3rd.slivepositiontaking+custsetting3rd.alivepositiontaking+custsetting3rd.mlivepositiontaking>scs.slivepositiontaking

    RETURN
END

if @mode = 'finance'
BEGIN
    ----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
	    and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype = 201


    ----------------------------------------------------------------------------
    --check agent min
    --a1=max(a1,n2)
    Update cs 
	    set apositiontaking = aco.minpositiontaking,
		    cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking<aco.minpositiontaking
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------
    --check agent max
    --a1=min(a1,l2)
    Update cs
	    set apositiontaking = aco.maxpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking>aco.maxpositiontaking
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------


    --Recal AUTO MPT m1=min(m3-a1,um2)
    -------------------------------------------------------------------------------------
    Update cs 
	    set mpositiontaking = 
		    case when mcs.mpositiontaking-cs.apositiontaking > (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
		    then (case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end)
		    else  mcs.mpositiontaking-cs.apositiontaking end
    from
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
	    inner join custinfo as c with (NOLOCK) on cs.custid = c.custid
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
    where
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
	    and cs.sporttype = 201

    	
    -------------------------------------------------------------------------------------


    --check master min
    --m1=max(m1,n3-a1)
    Update cs
	    set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------
    --check master max
    Update cs 
	    set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------

    --check super min
    --s1=max(n4-m1-a1,s1)
    Update cs
	    set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
	    and cs.sporttype = 201

    ----------------------------------------------------------------------------

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
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype = 201
    	
    RETURN
END
if @mode = 'virtual-sports'
BEGIN
	----------------------------------------------------------------------------
    --s1=min(s1,s4-m3) if i=0
    update cs
	    set cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend = @srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
    where cs.isautopositiontaking=0 and mcs.isautopositiontaking=0 
	    and scs.spositiontaking - mcs.mpositiontaking<cs.spositiontaking
	    and cs.sporttype in(180, 181, 186)

    ----------------------------------------------------------------------------
    --check agent min
    --a1=max(a1,n2)
    Update cs 
	    set apositiontaking = aco.minpositiontaking,
		    cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking<aco.minpositiontaking
	    and cs.sporttype in(180, 181, 186)

    ----------------------------------------------------------------------------
    --check agent max
    --a1=min(a1,l2)
    Update cs 
	    set apositiontaking = aco.maxpositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and roleid=1
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking>aco.maxpositiontaking
	    and cs.sporttype in(180, 181, 186)
    ----------------------------------------------------------------------------


    --Recal AUTO MPT m1=min(m3-a1,u2)
    -------------------------------------------------------------------------------------
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
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
	    and cs.sporttype in(180, 181, 186)

    	
    -------------------------------------------------------------------------------------


    --check master min
    --m1=max(m1,n3-a1)
    Update cs
	    set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
	    and cs.sporttype in(180, 181, 186)

    ----------------------------------------------------------------------------
    --check master max
    Update cs
	    set @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		    @mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
		    mpositiontaking = @mpos,
		    @apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
		    apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
	    and cs.sporttype in(180, 181, 186)

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	    c.srecommend = @srecommend
	    and c.roleid = 1
	    and (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
	    and cs.sporttype in(180, 181, 186)

    ----------------------------------------------------------------------------

    --check super min
    --s1=max(n4-m1-a1,s1)
    Update cs
	    set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
    from 
	    CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
    where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
	    and cs.sporttype in(180, 181, 186)


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
	    inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.srecommend=@srecommend and mb.roleid=1
	    inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	    inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = mb.mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
	    inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = mb.mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	    inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
    where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
	    and cs.sporttype in(180, 181, 186)
	
    RETURN	
END
if @mode = 'LiveCasino'
BEGIN		
	----------------------------------------------------------------------------
	--s1=min(s1,s4-m3) if i=0 & syncLC = 1
	UPDATE cs
	SET cs.spositiontaking = scs.spositiontaking - mcs.mpositiontaking
	FROM CustSettingGame cs 
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
	INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
	WHERE ci.srecommend = @srecommend AND roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (mcs.isautopositiontaking = 0 OR cs.isautopositiontaking = 0) AND scs.spositiontaking - mcs.mpositiontaking < cs.spositiontaking
		

	----------------------------------------------------------------------------
	--check agent min
	--a1=max(a1,n2)
	--m1=min(m3-n2,m1)
	UPDATE cs
	SET cs.apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.apositiontaking < aco.minpositiontaking


	--Recal AUTO MPT m1=min(m3-a1,u2)
	-------------------------------------------------------------------------------------
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
					THEN CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END
					ELSE mcs.mpositiontaking - cs.apositiontaking END		
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
		
		
	--check master min
	--m1=max(m1,n3-a1)
	UPDATE cs
	SET cs.mpositiontaking =CASE WHEN cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking THEN mco.minpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 


	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--recal autopos
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END THEN
								CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END 
								ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)
		
	----------------------------------------------------------------------------

	--check super min
	--s1=max(n4-m1-a1,s1)
	UPDATE cs
	SET 
		spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	FROM 
		CustSettingGame cs
		INNER JOIN CustInfo as ci with (NOLOCK) on cs.custid = ci.custid
		INNER JOIN CustOverrideGame as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking


	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	UPDATE cs
	SET	@spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking <0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		cs.spositiontaking = @spos,
		@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		@mapos  = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
		@mpos   = CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
		cs.mpositiontaking = @mpos ,
		@apos   = CASE WHEN @mpos + cs.apositiontaking > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.apositiontaking + cs.mpositiontaking + cs.spositiontaking > scs.spositiontaking

    RETURN	
END



