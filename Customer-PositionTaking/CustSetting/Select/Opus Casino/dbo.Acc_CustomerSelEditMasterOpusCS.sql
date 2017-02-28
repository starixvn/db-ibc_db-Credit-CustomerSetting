ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterOpusCS]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2013-10-07
		DB: DBAGE/bodb02
		Task: Get master Opus casino's setting 
		
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
		StakeLevelList VARCHAR(100),
		UplineStakeLevelList VARCHAR(100),
		isUpdated BIT DEFAULT (0)
	)
	
	DECLARE @min_spositiontaking	SMALLMONEY
			,@DisableOpusCasinoDownlines BIT
			,@StakeLevelList VARCHAR(100)
			,@UplineStakeLevelList VARCHAR(100)
			,@GameTypeID INT
			,@IBCBetTypeID INT
			,@srecommend INT
			,@DisableAutoMPT BIT
			,@UplineMaxTransferOpusCasino MONEY
	
	SELECT @srecommend = srecommend FROM custinfo WITH(NOLOCK) WHERE custid =@custid
	
	INSERT INTO @GameType (GameTypeID,StakeLevelList,UplineStakeLevelList)
	SELECT cg.GameTypeID, cg.StakeLevelList, upline.StakeLevelList
	FROM CustGameType cg WITH(NOLOCK)
		INNER JOIN CustGameType upline WITH(NOLOCK) ON cg.GameTypeID = upline.GameTypeID
	WHERE cg.custid = @custid AND upline.custid = @srecommend
	
	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @GameType
		SET isUpdated = 1
			,@GameTypeID = GameTypeID
			,@StakeLevelList = StakeLevelList
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
				WHERE	 CHARINDEX('"' + convert(varchar(20),StakeLevelID) + '"','"' + replace(@StakeLevelList,',','","') + '"',0) > 0  
		) B ON A.StakeLevelID = B.StakeLevelID
		ORDER BY A.MinStake
	END
	
	SELECT top 1 @DisableOpusCasinoDownlines = isnull(DisableOpusCasino,0)
	FROM custinfo WITH(NOLOCK)
	WHERE mrecommend = @custid AND roleid < 3 AND DisableOpusCasino = 1
		
	SELECT @UplineMaxTransferOpusCasino = MaxTransferOpusCasino
	FROM CustInfo WITH(NOLOCK)
	WHERE custid = @srecommend
	
	--Disable auto master PT
	SELECT @DisableAutoMPT = DisableAutoMPT 
	FROM CustMaster (nolock) 
	WHERE CustID = @custid
	
	SELECT @min_spositiontaking = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 163 AND bettype = 1401
	
	
	SELECT c.username
		,c.username2
		,c.firstname
		,c.lastname
		,c.phone 
		,c.mobilephone
		,c.fax
		,ci.DisableOpusCasino
		,CASE WHEN ci.DisableOpusCasino = 1 THEN 1 ELSE @DisableOpusCasinoDownlines END as DisableOpusCasinoDownlines
		,ci.isAutoResetOpusCasino
		,ci.MaxTransferOpusCasino
		,isnull(@UplineMaxTransferOpusCasino,0) as MaxTransferOpusCasino_max
		,@min_spositiontaking as v163spositiontaking_1401_min--n3
		,cg.spositiontaking as v163spositiontaking_1401--s3
		,cg.mpositiontaking as v163mpositiontaking_1401--m3
		,cg.isautopositiontaking as isauto_v163spositiontaking_1401--i3
		,cg.autopositiontaking as auto_v163spositiontaking_1401--u3
		,cg.adiscount as v163discount_1401--g3		
		,scg.sdiscount as v163dicount_1401_max--g3_max
		,scg.spositiontaking as v163spositiontaking_1401_max--s3_max
		,scg.spositiontaking as auto_v163spositiontaking_1401_max--u3_max	
	FROM custinfo ci with(NOLOCK)
		INNER JOIN customer c WITH(NOLOCK) ON ci.custid = c.custid
		INNER JOIN custsettinggame cg WITH(NOLOCK) ON cg.custid = ci.custid AND cg.sporttype = 163 AND cg.bettype = 1401
		INNER JOIN CustSettinggame scg WITH(NOLOCK) ON scg.custid = @srecommend AND scg.sporttype = 163 AND scg.bettype = 1401
	WHERE ci.custid = @custid
	
	SELECT * FROM @CustGameType
END 



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterOpusCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterOpusCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterOpusCS] TO [bodbDownlineNetView]