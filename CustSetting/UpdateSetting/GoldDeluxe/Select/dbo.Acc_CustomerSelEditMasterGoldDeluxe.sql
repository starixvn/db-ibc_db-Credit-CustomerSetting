/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="vnteam" isFunction="0"></info>*/
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
			- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
			- 20170921@Johnson: Fix the unsynchronized setting,fix @Downline status to show checkbox enable downline [Redmine: #72973]
							+@Downline = 1: has at least one customer has sync status
										=0 : all downlines not sync	
		Parameters Explanation
	*/
BEGIN
	SET NOCOUNT ON
		
	DECLARE	@min_mpositiontaking	SMALLMONEY
			,@max_spositiontaking	SMALLMONEY
			,@max_adiscount			SMALLMONEY
			,@DisableAutoMPT		BIT
			,@Downlines				BIT	= 0
			,@DisableDownlines		BIT = 0
			,@DisableGoldDeluxe		BIT
			,@DisableUpline			BIT = 0
			
	--Disable auto master PT
	SELECT	@DisableAutoMPT = DisableAutoMPT 
	FROM	dbo.CustMaster WITH(NOLOCK) 
	WHERE	CustID = @custid
			
	IF EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE mrecommend = @CustID AND HideGoldDeluxe = 0 AND custid <> @custid)
		SET @Downlines = 1	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE mrecommend = @custid AND DisableGoldDeluxe = 1)
		SET @DisableDownlines = 1
		
	SELECT	@DisableGoldDeluxe = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @custid
	
	SELECT	@DisableUpline = DisableGoldDeluxe
	FROM	dbo.custInfo WITH(NOLOCK)
	WHERE	custid = @srecommend

	SELECT	@min_mpositiontaking = minpositiontaking
	FROM	dbo.CustOverrideGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

	SELECT	@max_spositiontaking = spositiontaking
			,@max_adiscount = sdiscount
	FROM	dbo.CustSettingGame cs WITH(NOLOCK)
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
	FROM	dbo.CustsettingGame WITH(NOLOCK)
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