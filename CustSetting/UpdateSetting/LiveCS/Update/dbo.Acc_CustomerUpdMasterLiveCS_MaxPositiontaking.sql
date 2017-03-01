ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_MaxPositiontaking] 
	@srecommend	INT,
	@mrecommend INT
AS
	/*
		Created: Johnson
		Date: 2012-02-10
		Task: Update PT setting on member when edit master pt setting
		DB: DBTrans.BODB02
		
		Revisions:
		
		Parameters Explanation:
	*/
SET NOCOUNT ON 

	--Update all agent and member accounts
	declare @mpos smallmoney, @apos smallmoney, @spos smallmoney, @mapos1 smallmoney, @mapos2 smallmoney, @mapos smallmoney,@maxmapos smallmoney

	--Recal AUTO MPT m1=min(m3-a1,u2)
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END THEN
										CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
										ELSE mcs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)

	----------------------------------------------------------------------------
	--check master min/max
	--m1=n3-a1
	UPDATE cs
	SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking 
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		 AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking

	----------------------------------------------------------------------------
	-- Update m1,a1 when m1+a1>m3
	-- m1=m3-a1
	UPDATE cs
	SET @mpos = CASE WHEN mcs.mpositiontaking - cs.apositiontaking < 0 THEN 0 ELSE mcs.mpositiontaking - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN cs.apositiontaking + @mpos > mcs.mpositiontaking THEN mcs.mpositiontaking - @mpos ELSE cs.apositiontaking END ,
		cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END 
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking		
	
		
	----------------------------------------------------------------------------
	--recal autopos
	-- s1=min(s4-m1-a1,u)
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
								THEN CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END
								ELSE scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END 
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND (mcs.isautopositiontaking = 1 OR cs.isautopositiontaking = 1)
	
	
	----------------------------------------------------------------------------
	--check super min/max when a1+m1+s1<n4
	-- s1=n4-m1-a1
	UPDATE cs
	SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking 
			

		
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
		@mapos1 = CASE WHEN cs.mpositiontaking + cs.apositiontaking + @spos > scs.spositiontaking THEN scs.spositiontaking - @spos ELSE cs.mpositiontaking + cs.apositiontaking END,
		@mapos2 = CASE WHEN @mapos1 > mcs.mpositiontaking THEN mcs.mpositiontaking ELSE @mapos1 END,
		@mapos = CASE WHEN @mapos2 < mco.minpositiontaking THEN mco.minpositiontaking ELSE @mapos2 END,
		@mpos =  CASE WHEN @mapos - cs.apositiontaking < 0 THEN 0 ELSE @mapos - cs.apositiontaking END,
		cs.mpositiontaking = @mpos,
		@apos = CASE WHEN cs.apositiontaking + @mpos > @mapos THEN @mapos - @mpos ELSE cs.apositiontaking END,
		cs.apositiontaking = CASE WHEN @apos < aco.minpositiontaking THEN aco.minpositiontaking ELSE @apos END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
	WHERE ci.mrecommend = @mrecommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking 
	
	
	
	
	



GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterLiveCS_MaxPositiontaking] TO [vnteam]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_MaxPositiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_MaxPositiontaking] TO [bodbDownlineNet]
