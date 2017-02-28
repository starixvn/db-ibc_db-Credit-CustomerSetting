 ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterVS_MaxPositiontaking]
	@sporttype	INT,
	@bettype	INT,
	@srecommend	INT,
	@mrecommend INT
 AS
	/*
		Created: Johnson
		Date: 2012-08-15
		Task: Update PT setting on member when edit master pt setting
		DB: DBTrans.BODB02
		
		Revisions:
		
		Parameter's Explanation:
	*/
SET NOCOUNT ON 
-----------------------
	--Update all agent and member accounts
	DECLARE @mpos SMALLMONEY, 
			@apos SMALLMONEY, 
			@spos SMALLMONEY, 
			@mapos1 SMALLMONEY, 
			@mapos2 SMALLMONEY, 
			@mapos SMALLMONEY,
			@maxmapos SMALLMONEY
			
	--Recal AUTO MPT m1=min(m3-a1,u2)
	UPDATE cs 
		set mpositiontaking = 
			case when mcs.mpositiontaking-cs.apositiontaking > case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
				then case when cs.isautompositiontaking = 1 then cs.autompositiontaking else acs.autompositiontaking end
			else  mcs.mpositiontaking-cs.apositiontaking end
	from
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
		inner join custinfo as c with (NOLOCK) on cs.custid = c.custid and c.mrecommend = @mrecommend and c.roleid =1 
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustSetting3rd as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=cs.sporttype and acs.bettype=cs.bettype
	where cs.sporttype = @sporttype
		and cs.bettype = @bettype
		and (acs.isautompositiontaking = 1 or cs.isautompositiontaking = 1)
		 
		
	--check master min/max
	--m1=n3-a1
	Update cs
		set mpositiontaking = mco.minpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK) 
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
	where cs.apositiontaking+cs.mpositiontaking<mco.minpositiontaking
		and cs.sporttype = @sporttype 
		and cs.bettype = @bettype
	
	-- Update m1,a1 when m1+a1>l3
	-- m1=min(m3,l3)-a1
	UPDATE cs
	SET @maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mpos = case when @maxmapos-cs.apositiontaking<0 then 0 else @maxmapos-cs.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when cs.apositiontaking + @mpos>@maxmapos then @maxmapos-@mpos else cs.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	FROM 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	WHERE cs.apositiontaking+cs.mpositiontaking>mco.maxpositiontaking
		and cs.sporttype = @sporttype AND cs.bettype = @bettype		
	
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
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	--check super min/max when a1+m1+s1<n4
	-- s1=n4-m1-a1
	Update cs
		set spositiontaking = sco.minpositiontaking-cs.mpositiontaking-cs.apositiontaking
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
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
			@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
			@mapos = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
			@mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
			cs.mpositiontaking = @mpos,
			@apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
			cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
	from 
		CustSetting3rd as cs with (ROWLOCK, UPDLOCK)
		inner join custinfo as mb with (NOLOCK) on cs.custid = mb.custid and mb.mrecommend=@mrecommend and mb.roleid=1
		inner join CustSetting3rd as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=cs.sporttype and scs.bettype=cs.bettype
		inner join CustSetting3rd as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=cs.sporttype and mcs.bettype=cs.bettype
		inner join CustOverride3rd as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=cs.sporttype and mco.bettype=cs.bettype
		inner join CustOverride3rd as aco with (NOLOCK) on aco.custid = mb.recommend  and aco.sporttype=cs.sporttype and aco.bettype=cs.bettype
	where cs.spositiontaking+cs.apositiontaking+cs.mpositiontaking>scs.spositiontaking
		and cs.sporttype = @sporttype and cs.bettype = @bettype
	
	
	
	
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterVS_MaxPositiontaking] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MaxPositiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MaxPositiontaking] TO [bodbDownlineNet] 
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MaxPositiontaking] TO [bodbExtAccNet]