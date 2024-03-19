/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
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
			- 20180109@Johnson: remove downlines status for new direction[Redmine:#87328]	
			- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]														
		Parameters Explanation
	*/
BEGIN
	SET NOCOUNT ON
		
	DECLARE	@min_mpositiontaking	SMALLMONEY
			,@max_spositiontaking	SMALLMONEY
			,@max_adiscount			SMALLMONEY
			,@DisableAutoMPT		BIT
			,@DisableGoldDeluxe		BIT
			,@DisableUpline			BIT = 0
			
	--Disable auto master PT
	SELECT	@DisableAutoMPT = DisableAutoMPT 
	FROM	dbo.CustMaster WITH(NOLOCK) 
	WHERE	CustID = @custid
			
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
	SELECT	 c.username
			,c.username2 AS nickname
			,c.firstname
			,c.lastname
			,c.phone
			,c.mobilephone
			,c.fax
			,ISNULL(@DisableUpline,1) 		AS DisableUpline
			,ISNULL(@DisableGoldDeluxe,1)	AS DisableGoldDeluxe
			,ISNULL(NULLIF(c.site,''), ag.site) AS Site			
	FROM	dbo.Customer c WITH (NOLOCK)
		LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
	WHERE	c.custID = @CustID   	  
	
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