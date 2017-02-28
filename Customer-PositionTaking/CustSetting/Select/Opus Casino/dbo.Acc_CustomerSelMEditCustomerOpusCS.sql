ALTER PROCEDURE [dbo].[Acc_CustomerSelMEditCustomerOpusCS]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2013-10-09
		DB: DBAGE/bodb02
		Task: Master get Opus casino's setting on member
		
		Revisions:
		
		Parameter's Explanation:
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @CustGameType TABLE (
		GameTypeID INT,
		IBCBetType INT,
		StakeLevelName VARCHAR(100),
		isChecked BIT
	)
			
	DECLARE @GameType TABLE(
		GameTypeID INT,
		StakeLevelID VARCHAR(100),
		UplineStakeLevelList VARCHAR(100),
		isUpdated BIT DEFAULT (0)
	)
	
	DECLARE @StakeLevelID VARCHAR(20)
			,@UplineStakeLevelList VARCHAR(100)
			,@GameTypeID INT
			,@IBCBetTypeID INT
			,@srecommend INT
			,@mrecommend INT
			,@recommend INT
			,@UplineMaxTransferOpusCasino MONEY
			,@v163mpositiontaking_1401_max SMALLMONEY--m3
			,@v163mpositiontaking_1401_min SMALLMONEY--n3
			,@max_v163mpositiontaking_1401 SMALLMONEY--m1_max
			,@max_v163spositiontaking_1401 SMALLMONEY--s4
			,@isauto_v163mpositiontaking_1401 BIT--im2
			,@DisableAutoMPT BIT	
	
	SELECT @srecommend = srecommend	,@mrecommend = mrecommend ,@recommend = recommend
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @custid
	
	INSERT INTO @GameType (GameTypeID,StakeLevelID,UplineStakeLevelList)
	SELECT cg.GameTypeID, cg.StakeLevelList, upline.StakeLevelList
	FROM CustGameType cg WITH(NOLOCK)
		INNER JOIN CustGameType upline WITH(NOLOCK) ON cg.GameTypeID = upline.GameTypeID
	WHERE cg.custid = @custid AND upline.custid = @recommend
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @GameType
		SET isUpdated = 1
			,@GameTypeID = GameTypeID
			,@StakeLevelID = StakeLevelID
			,@UplineStakeLevelList = UplineStakeLevelList
		WHERE isUpdated = 0
	
		IF @@ROWCOUNT =0
			break;
			
		SELECT @IBCBetTypeID = IBCBetTypeID 
		FROM GameType WITH(NOLOCK)
		WHERE GameTypeID = @GameTypeID
		
		INSERT INTO @CustGameType (GameTypeID, IBCBetType, StakeLevelName, isChecked)
		SELECT @GameTypeID, @IBCBetTypeID, A.MinLabel + '-' + A.MaxLabel , CASE WHEN B.StakeLevelID IS NULL THEN 0 ELSE 1 END
		FROM
		 (
				SELECT	StakeLevelID,MinLabel,MaxLabel,MinStake 
				FROM	dbo.StakeLevel WITH (NOLOCK) 
				WHERE	 CHARINDEX('"' + convert(varchar(20),StakeLevelID) + '"','"' + replace(@UplineStakeLevelList,',','","') + '"',0) > 0  
		) A LEFT JOIN 	
		 (
				SELECT	StakeLevelID 
				FROM	dbo.StakeLevel WITH (NOLOCK) 
				WHERE	 convert(varchar(20),StakeLevelID) = @StakeLevelID
		) B ON A.StakeLevelID = B.StakeLevelID
		ORDER BY A.MinStake	
	END	
	
	SELECT @UplineMaxTransferOpusCasino = MaxTransferOpusCasino
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @recommend
	
	--get DisableAutoMPT
	SELECT @DisableAutoMPT = DisableAutoMPT
	FROM custmaster WITH(NOLOCK)
	WHERE custid = @mrecommend
	
	--im2
	SELECT @isauto_v163mpositiontaking_1401 = isautompositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 163 AND bettype = 1401 
	
	--m3
	SELECT @v163mpositiontaking_1401_max = mpositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 163 AND bettype = 1401		
	
	--s4
	SELECT @max_v162spositiontaking_1101 = spositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 163 AND bettype = 1401	
	
	--n3			
	SELECT @v163mpositiontaking_1401_min = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 163 AND bettype = 1401	
	
	--m1_max = !(i=0)?(m3-a1):min(m3-a1,s4-s1-a1)
	SELECT @max_v163mpositiontaking_1401 = MAX(CASE WHEN NOT (cs.isautopositiontaking = 0 AND mcs.isautopositiontaking = 0) THEN mcs.mpositiontaking-cs.apositiontaking ELSE CASE WHEN mcs.mpositiontaking - cs.apositiontaking <= @max_v163spositiontaking_1401 - cs.spositiontaking - cs.apositiontaking THEN mcs.mpositiontaking - cs.apositiontaking ELSE @max_v163spositiontaking_1401 - cs.spositiontaking - cs.apositiontaking END END)
	FROM custsettingGame cs WITH(NOLOCK)		
		INNER JOIN custsettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND cs.sporttype = mcs.sporttype AND cs.bettype = mcs.bettype
	WHERE cs.custid = @custid AND cs.sporttype = 163 AND cs.bettype = 1401
	
	SELECT
		c.username
		,c.username2
		,c.firstname
		,c.lastname
		,c.phone 
		,c.mobilephone
		,c.fax		
		,ci.isAutoResetOpusCasino
		,ci.MaxTransferOpusCasino
		,isnull(@UplineMaxTransferOpusCasino,0) as MaxTransferOpusCasino_max
		,ISNULL(@DisableAutoMPT,0) AS DisableAutoMPT
		
		,cg.mpositiontaking as v163mpositiontaking_1401--m1
		,cg.apositiontaking as v163apositiontaking_1401--a1
		,cg.isautompositiontaking as isauto_v163mpositiontaking_1401_mem--im1
		,cg.autompositiontaking as auto_v163mpositiontaking_1401_mem--um1
		
		,@isauto_v163mpositiontaking_1401 AS isauto_v163mpositiontaking_1401--im3
		,@v163mpositiontaking_1401_max AS auto_v163mpositiontaking_1401_max--um1_max
		,@max_v163mpositiontaking_1401 AS v163mpositiontaking_1401_max--m1_max
		,CASE WHEN @v163mpositiontaking_1401_min - apositiontaking < 0 THEN 0 ELSE @v163mpositiontaking_1401_min - apositiontaking END AS v163mpositiontaking_1401_min--m1_min	
	FROM custinfo ci with(NOLOCK)
		INNER JOIN customer c WITH(NOLOCK) ON ci.custid = c.custid
		INNER JOIN custsettinggame cg WITH(NOLOCK) ON cg.custid = ci.custid AND cg.sporttype = 163 AND cg.bettype = 1401
	WHERE ci.custid = @custid	
	
	SELECT * FROM @CustGameType
						
END 

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerOpusCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerOpusCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelMEditCustomerOpusCS] TO [bodbDownlineNetView]