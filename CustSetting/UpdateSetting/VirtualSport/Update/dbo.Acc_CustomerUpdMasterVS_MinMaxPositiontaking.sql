ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterVS_MinMaxPositiontaking] 
	@sporttype	INT,
	@bettype	INT,	
	@mrecommend	INT,
	@srecommend INT
AS
	/*
		Created: Johnson
		Date: 2012-08-15
		Task: Admin/Super edit min positiontaking for virtual sports on master 
		DB: DBTrans.BODB02
		
		Revisions:
		
		Parameter's Explanation:
	*/
SET NOCOUNT ON
------------------------
	DECLARE @mpos SMALLMONEY, 
			@apos SMALLMONEY, 
			@spos SMALLMONEY, 
			@mapos1 SMALLMONEY, 
			@mapos2 SMALLMONEY, 
			@mapos SMALLMONEY,
			@maxmapos SMALLMONEY
	
	--check agent min/max
	--a1=max(a1,n2)
	Update cs
	set apositiontaking = aco.minpositiontaking,
		cs.mpositiontaking = case when cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else cs.mpositiontaking end
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.apositiontaking<aco.minpositiontaking
		and cs.sporttype =@sporttype and cs.bettype = @bettype
		
	----------------------------------------------------------------------------
	--a1=min(a1,l2) 
	Update custsetting3rd with (ROWLOCK, UPDLOCK) 
	set 
		apositiontaking = aco.maxpositiontaking
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.sporttype = @sporttype and  custsetting3rd.apositiontaking>aco.maxpositiontaking
	
	----------------------------------------------------------------------------
	-- Update m2,a2 when m2+a2>l3
	-- m2=max(min(m3,l3)-a2,0)
	-- a2=min(min(m3,l3)-m2,a2,n2)
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.sporttype = @sporttype and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking
	
	--um2=min(m3,l3) if um2>l3
	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		autompositiontaking = @maxmapos
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=2
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
	where custsetting3rd.sporttype = @sporttype and custsetting3rd.isautompositiontaking = 1 and custsetting3rd.autompositiontaking > mco.maxpositiontaking


	--Recal AUTO MPT m1=min(m3-a1,u2)
	Update cs
	set mpositiontaking = 
		case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
			then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
		else  mcs.mpositiontaking-cs.apositiontaking end
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid = 1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
	where (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
		and cs.sporttype  = @sporttype and cs.bettype = @bettype
	
	--check master min/max
	--m1=n3-a1
	Update cs
		set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
		and cs.sporttype  = @sporttype and cs.bettype = @bettype
	
	----------------------------------------------------------------------------
	-- Update m1,a1 when m1+a1>l3
	-- m1=min(m3,l3)-a1

	Update custsetting3rd with (ROWLOCK, UPDLOCK) set 
		@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mpos = case when @maxmapos-custsetting3rd.apositiontaking<0 then 0 else @maxmapos-custsetting3rd.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when custsetting3rd.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else custsetting3rd.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		custsetting3rd inner join custinfo as mb with (NOLOCK) on custsetting3rd.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join custsetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsetting3rd.sporttype and mcs.bettype=custsetting3rd.bettype
		inner join custoverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsetting3rd.sporttype and mco.bettype=custsetting3rd.bettype
		inner join custoverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=custsetting3rd.sporttype and aco.bettype=custsetting3rd.bettype
	where custsetting3rd.sporttype = @sporttype and custsetting3rd.apositiontaking+custsetting3rd.mpositiontaking>mco.maxpositiontaking

		
	--recal autopos
	-- s1=min(s4-m1-a1,u)
	Update cs 
		set spositiontaking = case when scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking >
								(case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) then (case when cs.isautopositiontaking=1 then cs.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-cs.mpositiontaking-cs.apositiontaking end 
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid = 1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
	where (cs.isautopositiontaking=1 or mcs.isautopositiontaking=1)
		and cs.sporttype  = @sporttype and cs.bettype = @bettype
	
	--check super min/max when a1+m1+s1<n4
	-- s1=n4-m1-a1
	Update cs
		set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustOverride3rd as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=cs.sporttype and sco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking+cs.spositiontaking<sco.minpositiontaking
		and cs.sporttype  = @sporttype and cs.bettype = @bettype
	
	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)	
	--@mapos2=min(@mapos1,m3)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	UPDATE cs
	SET 
		@spos = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END,
		cs.spositiontaking = @spos,
		@mapos1 = CASE WHEN @spos + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 < mcs.mpositiontaking THEN @mapos1 ELSE mcs.mpositiontaking END,
		@mapos  = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
		@mpos   = CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos   = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
	FROM CustSetting3rd cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid AND ci.mrecommend = @mrecommend AND ci.roleid = 1
		INNER JOIN CustSetting3rd scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
		INNER JOIN CustSetting3rd mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverride3rd mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
		INNER JOIN CustOverride3rd aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE  cs.sporttype = @sporttype AND cs.bettype = @bettype
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
	
		
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxPositiontaking]  TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxPositiontaking]  TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxPositiontaking]  TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxPositiontaking]  TO [bodbExtAccNet]