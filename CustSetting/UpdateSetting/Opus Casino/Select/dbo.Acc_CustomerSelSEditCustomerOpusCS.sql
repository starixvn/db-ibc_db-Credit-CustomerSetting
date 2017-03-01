ALTER PROCEDURE [dbo].[Acc_CustomerSelSEditCustomerOpusCS]
	@custid INT
AS
	/*
		Created: Johnson
		Date: 2013-10-09
		DB: DBAGE/bodb02
		Task: Super get Opus casino's setting on member
		
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
			,@v163spositiontaking_1401 SMALLMONEY--s4
			,@v163spositiontaking_1401_min SMALLMONEY--n4
			,@v163mpositiontaking_1401 SMALLMONEY--m3
			,@isauto_v163spositiontaking_1401 BIT--i3
	
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
	
	--s4
	SELECT @v163spositiontaking_1401 = spositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = 163 AND bettype = 1401
	
	--n4
	SELECT @v163spositiontaking_1401_min = minpositiontaking
	FROM CustOverrideGame WITH(NOLOCK)	
	WHERE custid = @srecommend AND sporttype = 163 AND bettype = 1401
	
	--i3,m3
	SELECT @v163mpositiontaking_1401 = mpositiontaking, @isauto_v163spositiontaking_1401 = isautopositiontaking
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @mrecommend AND sporttype = 163 AND bettype = 1401 
	
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
		
		,cg.apositiontaking as v163apositiontaking_1401--a1
		,cg.mpositiontaking as v163mpositiontaking_1401--m1
		,cg.spositiontaking as v163spositiontaking_1401--s1
		,cg.autopositiontaking as auto_v163spositiontaking_1401_mem--i1
		,cg.isautopositiontaking as isauto_v163spositiontaking_1401_mem--u1
		
		,ISNULL(@isauto_v163spositiontaking_1401,0) as isauto_v163spositiontaking_1401--i3
		,ISNULL(@v163spositiontaking_1401,0) as auto_v163spositiontaking_1401_max--u1_max
		
		--s1_max= s4- m3
		,ISNULL(@v163spositiontaking_1401,0) - ISNULL(@v163mpositiontaking_1401,0) as v163spositiontaking_1401_max--s1_max
		-- s1_min 
		,CASE WHEN ISNULL(@v163spositiontaking_1401_min,0) - (mpositiontaking + apositiontaking) > 0 THEN ISNULL(@v163spositiontaking_1401_min,0) - (mpositiontaking + apositiontaking) ELSE 0 END v163spositiontaking_1401_min	
	FROM custinfo ci with(NOLOCK)
		INNER JOIN customer c WITH(NOLOCK) ON ci.custid = c.custid
		INNER JOIN custsettinggame cg WITH(NOLOCK) ON cg.custid = ci.custid AND cg.sporttype = 163 AND cg.bettype = 1401
	WHERE ci.custid = @custid	
	
	SELECT * FROM @CustGameType
	
END 

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelSEditCustomerOpusCS] TO [bodbDownlineNetView]
