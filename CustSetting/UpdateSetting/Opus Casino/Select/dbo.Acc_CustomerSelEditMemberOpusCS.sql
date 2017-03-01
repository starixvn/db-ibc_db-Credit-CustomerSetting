ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMemberOpusCS]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2013-10-08
		DB: DBAGE/bodb02
		Task: Agent get Opus casino's setting on member
		
		Revision:
		
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
	
	DECLARE @min_spositiontaking	SMALLMONEY			
			,@StakeLevelID VARCHAR(20)
			,@UplineStakeLevelList VARCHAR(100)
			,@GameTypeID INT
			,@IBCBetTypeID INT
			,@srecommend INT
			,@mrecommend INT
			,@recommend INT
			,@UplineMaxTransferOpusCasino MONEY
			,@v163apositiontaking_1401_max SMALLMONEY
			,@v163apositiontaking_1401_min SMALLMONEY
			,@v163discount_1401 SMALLMONEY
			,@v163spt_1401 SMALLMONEY
			,@v163apt_1401 SMALLMONEY			
			
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
	
	--a2
	SELECT	@v163apositiontaking_1401_max = apositiontaking,
			@v163discount_1401 = discount
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 163 AND bettype = 1401
	
	--n2
	SELECT @v163apositiontaking_1401_min = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 163 AND bettype = 1401
	
	--s4
	SELECT	@v163spt_1401 = spositiontaking
	FROM custsettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 163 AND bettype = 1401
	
	--max_a1=iif(im=1,a2,iif(i1|i3,m3-m1,min(m3-m1,s4-m1-s1)
	SELECT @v163apt_1401 = CASE WHEN (acs.isautompositiontaking = 1 OR cs.isautompositiontaking = 1) THEN acs.apositiontaking 
									ELSE CASE WHEN NOT (cs.isautopositiontaking=0 AND mcs.isautopositiontaking=0 ) THEN mcs.mpositiontaking-cs.mpositiontaking 
												ELSE CASE WHEN mcs.mpositiontaking-cs.mpositiontaking<= @v163spt_1401-cs.spositiontaking-cs.mpositiontaking then  mcs.mpositiontaking-cs.mpositiontaking else @v163spt_1401-cs.spositiontaking-cs.mpositiontaking END
											END
										 END 
	FROM CustSettingGame cs WITH(NOLOCK)
		INNER JOIN CustSettingGame mcs WITH(NOLOCK) ON mcs.custid = @mrecommend AND mcs.sporttype = cs.sporttype AND mcs.bettype = cs.bettype 
		INNER JOIN CustSettingGame acs WITH(NOLOCK) ON acs.custid = @recommend AND acs.sporttype = cs.sporttype AND acs.bettype = cs.bettype 
	WHERE cs.custid = @custid AND cs.sporttype = 163 AND cs.bettype = 1401
	
	SELECT @v163apositiontaking_1401_max = CASE WHEN @v163apositiontaking_1401_max <= @v163apt_1401 THEN @v163apositiontaking_1401_max ELSE @v163apt_1401 END
	
	
	SELECT
		c.username
		,c.username2
		,c.firstname
		,c.lastname
		,c.phone 
		,c.mobilephone
		,c.fax
		,ci.DisableOpusCasino
		,ci.isAutoResetOpusCasino
		,ci.MaxTransferOpusCasino
		,isnull(@UplineMaxTransferOpusCasino,0) as MaxTransferOpusCasino_max
		,cg.apositiontaking as v163apositiontaking_1401
		,@v163apositiontaking_1401_max as v163apositiontaking_1401_max
		,@v163apositiontaking_1401_min as v163apositiontaking_1401_min
		,cg.playerdiscount as v163playerdiscount_1401
		,@v163discount_1401 as v163playerdiscount_1401_max
	FROM custinfo ci with(NOLOCK)
		INNER JOIN customer c WITH(NOLOCK) ON ci.custid = c.custid
		INNER JOIN custsettinggame cg WITH(NOLOCK) ON cg.custid = ci.custid AND cg.sporttype = 163 AND cg.bettype = 1401
	WHERE ci.custid = @custid
	
	SELECT * FROM @CustGameType
END 


GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberOpusCS] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberOpusCS] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMemberOpusCS] TO [bodbDownlineNetView]