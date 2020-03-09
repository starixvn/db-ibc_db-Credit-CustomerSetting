/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID					INT
				,	@AllowedCS				BIT = 0		OUTPUT
				,	@AllowedVS				BIT = 0		OUTPUT
				,	@AllowedLiveCasino		BIT = 0		OUTPUT
				,	@AllowedVoidBridge		BIT = 0		OUTPUT
				,	@AllowedNG2				BIT = 0		OUTPUT
				,	@AllowedFishingWorld	BIT = 0		OUTPUT
				,	@AllowedLottery			BIT = 0		OUTPUT
				,	@AllowedVirtualGames	BIT = 0		OUTPUT

				,	@AllowedSabaClub		BIT = 0		OUTPUT

AS
BEGIN
/*
Created by: 20090525@Simon
Task: Check the showed types. (Finance / Horse Racing / Casino)
DB: DBCUST/CustDB
Revisions:
	- 20090908@Shifu: Check Allow HR
	- 20100930@Ethan: Check Allow BI
	- 20120207@Johnson: Check allow live casino
	- 20120821@Dan: Check allow VS
	- 20150825@Helen: Colossus Bet - [Redmine: #41264]
	- 20151231@Helen: Cockfighting - [Redmine: #48133]
	- 20151231@Helen: Cockfighting - Fix bug [Redmine: #48133]
	- 20160114@Helen: Cricket - [Redmine: #50027]
	- 20160317@Billy: AllBet - [Redmine: #53718]
	- 20160407@Winnie: VoidBridge - [Redmine: #55532]
	- 20160801@Elodie: NG2 Product - [Redmine: #60809]
	- 20161024@Elodie: Move to DBCUST/CustDB
	- 20161115@Winnie: Fishing World - [Redmine: #62547]
	- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]	
	- 20170418@Winnie: Change to call the sp Acc_CheckShowProduct - [Redmine #72336]	
	- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
	- 20170801@Elodie: Add Keno Lottery Product - [Redmine #74313]
	- 20170808@Elodie: Lucky3 Product - [Redmine: #75521]
	- 20171001@Elodie: BullFighting Product - [Redmine: #81664]
	- 20180703@Elodie: Poker Games Product - [Redmine: #97675]
	- 20190104@Johnson: config Allbet to show if any bettype is allowed [Redmine: #106601]
	- 20190828@Eden: 3rd party products - Remove InActive Products Phase 2 [Redmine: #118699]
	- 20191206@Eden: Add Virtual Games [Redmine: #122743]
	- 20200318@Elodie: Add Saba.club [Redmine: #130636]
	- 20200303@Tiara: Add SA Gaming Product [Redmine: #128058]

*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit 
	Declare @srecommend int, @mrecommend int, @recommend int
	DECLARE @AllowedSAGaming BIT, @AllowedAllBet BIT 
	DECLARE	@IsHideAllBet			INT
		,	@IsHideVoidBridge		INT
		,	@IsHiddenLottery		INT 
		,	@IsHideNG2				INT
		,	@IsHideFishingWorld		INT
		,	@IsHideVS				INT
		,	@IsHideVG				INT
		,	@IsHideSaba				INT
		,	@IsHideSAGaming			INT

	DECLARE @bitOrderVB				INT 
		,	@bitOrderFW				INT 
		,	@bitOrderNG2			INT 
		,	@bitOrderLottery		INT 
		,   @bitOrderVS				INT
		,	@bitmapOrder_VG			INT
		,	@bitmapOrder_Saba		INT
		,	@bitmapOrder_SAGaming	INT 

	SET @bitOrderVB = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitOrderLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitOrderNG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitOrderFW = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitOrderVS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	SET @bitmapOrder_VG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 245 AND Bettype = 4601)
	SET @bitmapOrder_Saba = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 200 AND Bettype = 1611)
	SET @bitmapOrder_SAGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 244 AND Bettype = 3001)

	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend	
	from custinfo with (nolock) where CustID=@CustID
	
	--For FishingWorld
	EXEC Acc_CheckShowProduct @ProductID = 24, @IsHide = @IsHideFishingWorld OUTPUT
	SELECT	@AllowedFishingWorld =	CASE	WHEN @RoleID = 4 AND @IsHideFishingWorld = 0 THEN 1
										WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderFW) = 0
											AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitOrderFW) = 1
											AND @IsHideFishingWorld = 0 
											THEN 1
										ELSE 0
								END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	--For Lottery
	EXEC Acc_CheckShowProduct @ProductID = 28, @IsHide = @IsHiddenLottery OUTPUT
	SELECT	@AllowedLottery =	CASE	WHEN @RoleID = 4 AND @IsHiddenLottery = 0 THEN 1
										WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderLottery) = 0
											AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitOrderLottery) = 1
											AND @IsHiddenLottery = 0 
											THEN 1
										ELSE 0
								END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	--For VoidBridge
	EXEC Acc_CheckShowProduct @ProductID = 22, @IsHide = @IsHideVoidBridge OUTPUT
	SET @AllowedVoidBridge = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderVB) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 
										AND @IsHideVoidBridge = 0 THEN 1 ELSE 0 END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedCS=1
		SET @AllowedVS = 1
	END
	ELSE 
	BEGIN 
		-- Check if Replicate run slowly.
		If (@RoleID is null) 
		Begin 
			set @AllowedCS=0
			return
		End
		-- For Casino (Check Upline allowed Casino)
		if @RoleID=3
			Select @SyncCasino=SyncCasino  FROM custinfo with (nolock) where CustID=@srecommend	
		Else if @RoleID=2
			Select @SyncCasino=SyncCasino  from custinfo with (nolock) where CustID=@mrecommend	
		Else if @RoleID=1
			Select @SyncCasino=SyncCasino  from custinfo with (nolock) where CustID=@recommend		
		
		-- For Casino
		if @SyncCasino!=1
			set @AllowedCS=0
		else
			set @AllowedCS=1
					
	End

	-- For AllBet
	EXEC Acc_CheckShowProduct @ProductID = 41, @IsHide = @IsHideAllBet OUTPUT
	SELECT	@AllowedAllBet =	MAX(CASE	WHEN @RoleID = 4 AND @IsHideAllBet = 0 THEN 1
										WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) = 0
											AND dbo.f_GetProductStatus(cps.bitmapHasSynced, psp.bitmapOrder) = 1
											AND @IsHideAllBet = 0 
											THEN 1
										ELSE 0
								END)
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	CROSS JOIN	dbo.ProductStatusProfile AS psp WITH (NOLOCK)
	INNER JOIN	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
			ON	psd.SportType = psp.Sporttype
			AND	psd.BetType = psp.Bettype
			AND	psd.SettingType = 13
	WHERE	cps.CustID = @CustID
		AND	psd.ProductID = 41

	-- For SA Gaming
	EXEC Acc_CheckShowProduct @ProductID = 41, @IsHide = @IsHideSAGaming OUTPUT
	SELECT	@AllowedSAGaming =	MAX(CASE	WHEN @RoleID = 4 AND @IsHideSAGaming = 0 THEN 1
										WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, psp.bitmapOrder) = 0
											AND dbo.f_GetProductStatus(cps.bitmapHasSynced, psp.bitmapOrder) = 1
											AND @IsHideSAGaming = 0 
											THEN 1
										ELSE 0
								END)
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	CROSS JOIN	dbo.ProductStatusProfile AS psp WITH (NOLOCK)
	INNER JOIN	dbo.ProductSettingDetail AS psd WITH (NOLOCK)
			ON	psd.SportType = psp.Sporttype
			AND	psd.BetType = psp.Bettype
			AND	psd.SettingType = 13
	WHERE	cps.CustID = @CustID
		AND	psd.ProductID = 41
	--For Live Casino (Allbet + SA Gaming)
	SELECT @AllowedLiveCasino = CASE WHEN @AllowedAllBet = 1 OR @AllowedSAGaming = 1 THEN 1
									ELSE 0 END
	-- For NG2
	EXEC Acc_CheckShowProduct @ProductID = 23, @IsHide = @IsHideNG2 OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedNG2 =	CASE	WHEN @IsHideNG2 = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitOrderNG2)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedNG2 =	CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitOrderNG2)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitOrderNG2)) = 1
											AND @IsHideNG2 = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END

	-- For VS
	EXEC Acc_CheckShowProduct @ProductID = 5, @IsHide = @IsHideVS OUTPUT
	SELECT	@AllowedVS = CASE	WHEN @RoleID = 4 AND @IsHideVS = 0 THEN 1
								WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderVS) = 0 AND @IsHideVS = 0 THEN 1
								ELSE 0
						END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	-- For Virtual games
	EXEC Acc_CheckShowProduct @ProductID = 38, @IsHide = @IsHideVG OUTPUT
	SELECT	@AllowedVirtualGames = CASE	WHEN @RoleID = 4 AND @IsHideVG = 0 THEN 1
								WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitmapOrder_VG) = 0 AND @IsHideVG = 0 THEN 1
								ELSE 0
						END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	-- For Saba
	EXEC Acc_CheckShowProduct @ProductID = 42, @IsHide = @IsHideSaba OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedSabaClub =	CASE	WHEN @IsHideSaba = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Saba)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedSabaClub =	CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Saba)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_Saba)) = 1
											AND @IsHideSaba = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
END
GO