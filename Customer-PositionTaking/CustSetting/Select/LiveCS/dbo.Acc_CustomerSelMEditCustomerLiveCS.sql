ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerLiveCS]
	@custid		INT
AS
/*
	Created: 20120111@Lukas
	Task: Master select edits live casino PT settings on member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20140307@Johnson: apply new m1_max is m3-a1 not apply range !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1) [Redmine:#12953] 
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @AgentID							INT,
			@MasterID							INT,
			@SuperID							INT,
			@roleid								TINYINT,			
			@v162mpositiontaking_1101_max		SMALLMONEY,
			@v162mpositiontaking_1101_min		SMALLMONEY,
			--@max_v162mpositiontaking_1101		SMALLMONEY,
			@max_v162spositiontaking_1101		SMALLMONEY,
			@isauto_v162mpositiontaking_1101	BIT,
			@DisableAutoMPT						BIT	

	SELECT	@AgentID = recommend,
			@MasterID = mrecommend,
			@SuperId = srecommend,
			@roleid	 = roleid
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid <> 1
		RETURN
	
	--get DisableAutoMPT
	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM custmaster WITH(NOLOCK)
	WHERE custid = @MasterID

	-- get is master auto on agent
	SELECT @isauto_v162mpositiontaking_1101 = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @AgentID AND sporttype = 162 AND bettype = 1101 
	
	SELECT @v162mpositiontaking_1101_max = mpositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @MasterID AND sporttype = 162 AND bettype = 1101

	SELECT @max_v162spositiontaking_1101 = spositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @SuperID AND sporttype = 162 AND bettype = 1101

	SELECT @v162mpositiontaking_1101_min = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @MasterID AND sporttype = 162 AND bettype = 1101
	
	/*
	--@max_v162mpositiontaking_1101 = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	SELECT @max_v162mpositiontaking_1101 = MAX(CASE WHEN NOT (cs.isautopositiontaking = 0 AND mcs.isautopositiontaking = 0) THEN mcs.mpositiontaking-cs.apositiontaking ELSE CASE WHEN mcs.mpositiontaking - cs.apositiontaking <= @max_v162spositiontaking_1101 - cs.spositiontaking - cs.apositiontaking THEN mcs.mpositiontaking - cs.apositiontaking ELSE @max_v162spositiontaking_1101 - cs.spositiontaking - cs.apositiontaking END END)
	FROM custsettingGame cs WITH(NOLOCK)
		INNER JOIN custinfo c WITH(NOLOCK) ON cs.custid = c.custid
		INNER JOIN custsettingGame mcs WITH(NOLOCK) ON c.mrecommend = mcs.custid AND cs.sporttype = mcs.sporttype AND cs.bettype = mcs.bettype
	WHERE cs.custid = @custid AND cs.sporttype = 162 AND cs.bettype = 1101
	*/	
	
	SELECT 	
		ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT,
		mpositiontaking AS v162mpositiontaking_1101,
		apositiontaking	AS V162apositiontaking_1101,
		autompositiontaking AS auto_v162mpositiontaking_1101_mem,
		isautompositiontaking AS isauto_v162mpositiontaking_1101_mem,
		@isauto_v162mpositiontaking_1101 AS isauto_v162mpositiontaking_1101,
		@v162mpositiontaking_1101_max AS auto_v162mpositiontaking_1101_max,
		
		--m1_max = m3 - a1
		@v162mpositiontaking_1101_max - apositiontaking AS v162mpositiontaking_1101_max,

		CASE WHEN @v162mpositiontaking_1101_min - apositiontaking < 0 THEN 0 ELSE @v162mpositiontaking_1101_min - apositiontaking END AS v162mpositiontaking_1101_min
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

END

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelMEditCustomerLiveCS] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerLiveCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerLiveCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerLiveCS] TO [bodbDownlineNetView]