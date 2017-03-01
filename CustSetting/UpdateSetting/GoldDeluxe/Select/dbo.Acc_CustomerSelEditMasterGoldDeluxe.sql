use CustDB
go
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditMasterGoldDeluxe]
	@custid INT,
	@srecommend INT
AS
	/*
		Created: Kathy
		Date: 20150424
		Task: Super edits master's Gold Deluxe setting
		DB: DBCUST.CustDB
		
		Revisions:
			- 20150612@Kathy: Move sp from DBAGE.bodb02 to DBCUST.CustDB [Redmine:#36216]
			- 20150721@Patrick: Add more winlimit section
		
		Parameters Explanation
	*/
BEGIN
	SET NOCOUNT ON
		
	DECLARE	@min_mpositiontaking	SMALLMONEY
			,@max_spositiontaking	SMALLMONEY
			,@max_adiscount			SMALLMONEY
			,@DisableAutoMPT		BIT
			,@Downlines				BIT	= 1
			,@DisableDownlines		BIT = 0
			,@DisableGoldDeluxe		BIT
			,@DisableUpline			BIT = 0
			
	--Disable auto master PT
	SELECT	@DisableAutoMPT = DisableAutoMPT 
	FROM	CustMaster WITH(NOLOCK) 
	WHERE	CustID = @custid
			
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND roleid = 2)
		SET @Downlines = 0	-- dont have any downlines
	ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND roleid = 2 AND DisableGoldDeluxe = 1)
		SET @DisableDownlines = 1
		
	SELECT	@DisableGoldDeluxe = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @srecommend

	SELECT	@min_mpositiontaking = minpositiontaking
	FROM	CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

	SELECT	@max_spositiontaking = spositiontaking
			,@max_adiscount = sdiscount
	FROM	CustSettingGame cs WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 255 
			AND bettype = 1701

	--Customer Info
	SELECT	username
			,username2 AS nickname
			,firstname
			,lastname
			,phone
			,mobilephone
			,fax
			,ISNULL(@DisableUpline,1) 		AS DisableUpline
			,ISNULL(@DisableGoldDeluxe,1)	AS DisableGoldDeluxe
			,@Downlines						AS Downlines
			,@DisableDownlines				AS DisableDownlines
	FROM	dbo.Customer WITH (NOLOCK)
	WHERE	custID = @CustID   	  
	
	 --PT & commission
	SELECT	ISNULL(@DisableAutoMPT,0)		AS DisableAutoMPT, 
			isautopositiontaking			AS isauto_v255spositiontaking_1701, --i3
			autopositiontaking				AS auto_v255spostiontaking_1701,--u3
			spositiontaking					AS v255spositiontaking_1701,--s3
			mpositiontaking					AS v255mpositiontaking_1701,--m3	
			adiscount						AS v255discount_1701,--g3
			ISNULL(@max_adiscount,0)		AS v255discount_1701_max,--g3_max
			ISNULL(@max_spositiontaking,0)	AS v255spositiontaking_1701_max,--s4
			ISNULL(@min_mpositiontaking,0)	AS  v255mpositiontaking_1701_min,--n3	
			ISNULL(@max_spositiontaking,0)	AS auto_v255spositiontaking_1701_max--u3_max	
	FROM	CustsettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701
	
	-- bet setting
		EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
		@custid		= @custid
		,@UplineId	= @srecommend
	
	--Winlimit section
	EXEC dbo.Acc_CustomerWinLimitSelEdit @CustId = @CustId
		, @SportType = 255
		, @BetType = 1701
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterGoldDeluxe] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterGoldDeluxe] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterGoldDeluxe] TO [bodbDownlineNetView] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditMasterGoldDeluxe] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerSelEditMasterGoldDeluxe] TO [vnteam] AS [dbo]