 ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_MaxPositiontaking]
	@recommend	INT
AS
	/*
		Created: Johnson
		Date: 20120214
		DB: DBTrans.BODB02
		Task: Update member's setting when update agent's setting 
		
		Revisions:
		
		Parameters Explanation:
		
	*/
SET NOCOUNT ON

	UPDATE cs
	SET cs.apositiontaking = aco.minpositiontaking
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame aco WITH(NOLOCK) ON aco.custid = @recommend AND cs.sporttype = aco.sporttype AND cs.bettype = aco.bettype
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.apositiontaking < aco.minpositiontaking 
	
	--Check m1+a1: m1+a1>m3 => modify m1 set m1=m3-a1
	UPDATE cs
	SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking 

	--Recal um2
	--Recal AUTO MPT m1=min(m3-a1,um2)
	UPDATE cs
	SET cs.mpositiontaking = CASE WHEN mcs.mpositiontaking-cs.apositiontaking > (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
			THEN (CASE WHEN cs.isautompositiontaking = 1 THEN cs.autompositiontaking ELSE acs.autompositiontaking END)
		ELSE  mcs.mpositiontaking-cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND (cs.isautompositiontaking = 1 OR acs.isautompositiontaking = 1)
	
	--Check min max n3<=m1+a1<=m3 => modify m1
	UPDATE cs
	SET cs.mpositiontaking = mco.minpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame mco WITH(NOLOCK) ON mco.custid = ci.mrecommend AND mco.sporttype = cs.sporttype AND mco.bettype = cs.bettype
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.mpositiontaking + cs.apositiontaking < mco.minpositiontaking
	
	UPDATE cs
	SET cs.mpositiontaking = mcs.mpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs
		INNER JOIN custInfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.mpositiontaking + cs.apositiontaking > mcs.mpositiontaking
	
	--Recal u3,u1
	-- s1=min(s4-m1-a1,u)
	UPDATE cs
	SET cs.spositiontaking = CASE WHEN scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking > (CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END) THEN
						CASE WHEN cs.isautopositiontaking = 1 THEN cs.autopositiontaking ELSE mcs.autopositiontaking END  ELSE
						scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking END
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = ci.mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype		 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1			
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND (cs.isautopositiontaking = 1 OR mcs.isautopositiontaking = 1)

	--check super min/max when a1+m1+s1<n4
	-- s1=n4-m1-a1
	UPDATE cs
	SET cs.spositiontaking = sco.minpositiontaking - cs.mpositiontaking - cs.apositiontaking 
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustOverrideGame sco WITH(NOLOCK) ON sco.custid = ci.srecommend AND sco.sporttype = cs.sporttype AND sco.bettype = cs.bettype 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking < sco.minpositiontaking
	
	--check a1+m1+s1 > s4
	UPDATE cs
	SET cs.spositiontaking = scs.spositiontaking - cs.mpositiontaking - cs.apositiontaking
	FROM CustSettingGame cs
		INNER JOIN CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid 
		INNER JOIN CustSettingGame scs WITH(NOLOCK) ON scs.custid = ci.srecommend AND scs.sporttype = cs.sporttype AND scs.bettype = cs.bettype 
	WHERE ci.recommend = @recommend AND ci.roleid = 1 AND ci.SyncLiveCasino = 1
		AND cs.sporttype = 162 AND cs.bettype = 1101 
		AND cs.spositiontaking + cs.mpositiontaking + cs.apositiontaking > scs.spositiontaking
	
	
	

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentLiveCS_MaxPositiontaking] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_MaxPositiontaking] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_MaxPositiontaking] TO [bodbDownlineNet]
