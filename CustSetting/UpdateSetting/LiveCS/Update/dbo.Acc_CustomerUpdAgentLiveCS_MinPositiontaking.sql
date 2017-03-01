

ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_MinPositiontaking]
	@custid		INT,
	@mrecommend	int	
AS
/*
	Created: 20120117@Lukas
	Task: Admin/Master edit min live casino positiontaking on agent
	DB: DBTrans.BODB02
	
	Revisions:
	
	Parameters Explanation:
*/ 
BEGIN
	SET NOCOUNT ON

	declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney, @maxmapos smallmoney

	DECLARE @recommend INT,
			@srecommend INT

	SELECT	@recommend = custid,
			@srecommend = srecommend
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid

	--check agent min/max
	-- Update a1 when a1<n2
	-- a1=n2
	Update csg with(ROWLOCK, UPDLOCK) 
	set 
		apositiontaking = aco.minpositiontaking,
		mpositiontaking = case when csg.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking then mcs.mpositiontaking-aco.minpositiontaking else csg.mpositiontaking end
	from custsettingGame csg 
		inner join custinfo as mb with (NOLOCK) on csg.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
		inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=csg.sporttype and mcs.bettype=csg.bettype
		inner join custoverridegame as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=csg.sporttype and aco.bettype=csg.bettype
	where csg.apositiontaking < aco.minpositiontaking
		AND csg.sporttype = 162 AND csg.bettype = 1101


	--Recal AUTO MPT 
	--Update m1=min(m3-a1,u2)
	-------------------------------------------------------------------------------------
	Update custsettingGame with (ROWLOCK, UPDLOCK) 
	set mpositiontaking = 
			case when mcs.mpositiontaking-custsettingGame.apositiontaking > case when custsettingGame.isautompositiontaking = 1 then custsettingGame.autompositiontaking else acs.autompositiontaking end
				then case when custsettingGame.isautompositiontaking = 1 then custsettingGame.autompositiontaking else acs.autompositiontaking end
			else  mcs.mpositiontaking-custsettingGame.apositiontaking end
	from
		custsettingGame
		inner join custinfo as c with (NOLOCK) on custsettingGame.custid = c.custid
		inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
		inner join custsettingGame as acs with (NOLOCK) on acs.custid = c.recommend and acs.sporttype=custsettingGame.sporttype and acs.bettype=custsettingGame.bettype
	where
		c.recommend = @recommend
		and c.roleid = 1 and c.SyncLiveCasino = 1
	and (acs.isautompositiontaking = 1 or custsettingGame.isautompositiontaking = 1)


	--check master min/max
	-- Update m1 when m1+a1<n3
	-- m1=n3-a1
	Update custsettingGame with (ROWLOCK, UPDLOCK) set 
		mpositiontaking = mco.minpositiontaking-custsettingGame.apositiontaking
	from 
		custsettingGame 
		inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
		inner join custoverrideGame as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsettingGame.sporttype and mco.bettype=custsettingGame.bettype
	where custsettingGame.apositiontaking+custsettingGame.mpositiontaking<mco.minpositiontaking

	

	--s1=min(s4-m1-a1,u)
	--recal autopos
	Update custsettingGame with (ROWLOCK, UPDLOCK) 
		set spositiontaking = case when scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking >
								(case when custsettingGame.isautopositiontaking=1 then custsettingGame.autopositiontaking else mcs.autopositiontaking end) then (case when custsettingGame.isautopositiontaking=1 then custsettingGame.autopositiontaking else mcs.autopositiontaking end) else scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking end 
	from
		custsettingGame
		inner join custinfo as c with (NOLOCK) on custsettingGame.custid = c.custid
		inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = c.mrecommend and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
		inner join custsettingGame as scs with (NOLOCK) on scs.custid = @srecommend and scs.sporttype=custsettingGame.sporttype and scs.bettype=custsettingGame.bettype
	where
		c.recommend = @recommend
		and c.roleid = 1 and c.SyncLiveCasino = 1
		and (custsettingGame.isautopositiontaking=1 or mcs.isautopositiontaking=1)

	--check super min/max
	--Update s1 when s1+m1+a1<n4
	--s1=n4-m1-a1 
	Update custsettingGame with (ROWLOCK, UPDLOCK) set 
		spositiontaking = sco.minpositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking
	from 
		custsettingGame inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
		inner join custoverrideGame as sco with (NOLOCK) on sco.custid = @srecommend  and sco.sporttype=custsettingGame.sporttype and sco.bettype=custsettingGame.bettype
	where custsettingGame.apositiontaking+custsettingGame.mpositiontaking+custsettingGame.spositiontaking<sco.minpositiontaking


	--update s1,m1,a1 in case s1+m1+a1>s4
	--s1=max(0,s4-m1-a1)
	--@mapos1=iif(s1_new+m1+a1>s4,s4-s1_new,m1+a1)
	--@maxmapos=min(m3,l3)
	--@mapos2=min(@mapos1,@maxmapos)
	--@mapos=max(@mapos2,n3)
	--m1=max(0,@mapos-a1)
	--a1=iif(m1_new+a1>@mapos,@mapos-m1_new,a1)
	Update custsettingGame with (ROWLOCK, UPDLOCK) set 
		@spos = case when scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking<0 then 0 else scs.spositiontaking-custsettingGame.mpositiontaking-custsettingGame.apositiontaking end,
		spositiontaking = @spos,
		@mapos1 = case when @spos+custsettingGame.mpositiontaking+custsettingGame.apositiontaking>scs.spositiontaking then scs.spositiontaking-@spos else custsettingGame.mpositiontaking+custsettingGame.apositiontaking end,
		--@maxmapos = case when mcs.mpositiontaking>mco.maxpositiontaking then mco.maxpositiontaking else mcs.mpositiontaking end,
		@mapos2 = case when @mapos1>@maxmapos then @maxmapos else @mapos1 end,
		@mapos = case when @mapos2<mco.minpositiontaking then mco.minpositiontaking else @mapos2 end,
		@mpos = case when @mapos-custsettingGame.apositiontaking<0 then 0 else @mapos-custsettingGame.apositiontaking end,
		mpositiontaking = @mpos,
		@apos = case when custsettingGame.apositiontaking + @mpos>@mapos then @mapos-@mpos else custsettingGame.apositiontaking end,
		apositiontaking = case when @apos<aco.minpositiontaking then aco.minpositiontaking else @apos end
	from 
		custsettingGame inner join custinfo as mb with (NOLOCK) on custsettingGame.custid = mb.custid and mb.recommend=@recommend and mb.roleid=1 and mb.SyncLiveCasino = 1
		inner join custsettingGame as scs with (NOLOCK) on scs.custid = @srecommend  and scs.sporttype=custsettingGame.sporttype and scs.bettype=custsettingGame.bettype
		inner join custsettingGame as mcs with (NOLOCK) on mcs.custid = @mrecommend  and mcs.sporttype=custsettingGame.sporttype and mcs.bettype=custsettingGame.bettype
		inner join custoverrideGame as mco with (NOLOCK) on mco.custid = @mrecommend  and mco.sporttype=custsettingGame.sporttype and mco.bettype=custsettingGame.bettype
		inner join custoverrideGame as aco with (NOLOCK) on aco.custid = @recommend  and aco.sporttype=custsettingGame.sporttype and aco.bettype=custsettingGame.bettype
	where custsettingGame.spositiontaking+custsettingGame.apositiontaking+custsettingGame.mpositiontaking>scs.spositiontaking


END



GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentLiveCS_MinPositiontaking] TO [vnteam]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_MinPositiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_MinPositiontaking] TO [bodbDownlineNet]