ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_MinPositiontaking]
	@custid		INT,
	@srecommend INT	
AS
	/*
		Created: Johnson
		Date: 06Jan2011
		Task: Admin/Super edit min live casino positiontaking on master 
		DB: DBTrans.BODB02
		
		Revisions:
			- 20120402@Lukas: fix bug- wrong m1 when calculate new value
		Parameters Explanation:
			
	*/ 
SET NOCOUNT ON

DECLARE @mpos SMALLMONEY, @apos SMALLMONEY, @spos SMALLMONEY, @mapos1 SMALLMONEY, @mapos2 SMALLMONEY, @mapos SMALLMONEY


--check agent min/max
--a1=max(a1,n2)
UPDATE cs
SET cs.apositiontaking = aco.minpositiontaking,
	cs.mpositiontaking = CASE WHEN cs.mpositiontaking + aco.minpositiontaking > mcs.mpositiontaking THEN mcs.mpositiontaking - aco.minpositiontaking ELSE cs.mpositiontaking END
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	INNER JOIN CustOverride aco WITH(NOLOCK) ON aco.custid = ci.recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101
	AND cs.apositiontaking < aco.minpositiontaking

--Recal AUTO MPT m1=min(m3-a1,u2)
UPDATE cs
SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking - cs.apositiontaking > CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END 
							THEN CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END  
						ELSE mcs.mpositiontaking - cs.apositiontaking END
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = ci.recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101 
	AND (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) 

----------------------------------------------------------------------------
--check master min/max
--m1=n3-a1
UPDATE cs
SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = @custid AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101 
	AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking 
	
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
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @custid AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101
	AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)


----------------------------------------------------------------------------
--check super min/max when a1+m1+s1<n4
-- s1=n4-m1-a1
UPDATE cs
SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = @srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
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
FROM CustSettingGame cs
	INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
	INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = @srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
	INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = ci.recommend AND aco.sporttype = cs.sporttype AND aco.bettype = cs.bettype
WHERE ci.mrecommend = @custid AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
	AND cs.sporttype = 162 AND cs.bettype = 1101 
	AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking





GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterLiveCS_MinPositiontaking] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_MinPositiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_MinPositiontaking] TO [bodbDownlineNet]