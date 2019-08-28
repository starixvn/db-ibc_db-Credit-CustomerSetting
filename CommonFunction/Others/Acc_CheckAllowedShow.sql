/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID					INT
				,	@AllowedFI				BIT = 1		OUTPUT --unused
				,	@AllowedHR				BIT = 0		OUTPUT
				,	@AllowedCS				BIT = 0		OUTPUT
				--,	@AllowedBI				BIT = 0		OUTPUT
				--,	@AllowedLiveCS			BIT = 0		OUTPUT
				,	@AllowedVS				BIT = 0		OUTPUT
				,	@AllowedColossusbets	BIT = 0		OUTPUT
				,	@AllowedCockfighting	BIT = 0		OUTPUT
				,	@AllowedCricket			BIT = 0		OUTPUT
				,	@AllowedAllBet			BIT = 0		OUTPUT
				,	@AllowedVoidBridge		BIT = 0		OUTPUT
				,	@AllowedNG2				BIT = 0		OUTPUT
				,	@AllowedFishingWorld	BIT = 0		OUTPUT
				,	@AllowedLottery			BIT = 0		OUTPUT
				--,	@AllowedLucky3			BIT = 0		OUTPUT
				--,	@AllowedBullFighting	BIT = 0		OUTPUT
				--,	@AllowedPokerGames		BIT = 0		OUTPUT

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
*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit --, @SyncBingo bit, @DisableBingo bit, @SyncLiveCS BIT 
	Declare @srecommend int, @mrecommend int, @recommend int
	DECLARE	@IsHideCockfighting		INT
		,	@IsHideCricket			INT
		,	@IsHideAllBet			INT
		,	@IsHideVoidBridge		INT
		,	@IsHiddenLottery		INT 
		,	@IsHideNG2				INT
		--,	@IsHideLucky3			INT
		,	@IsHideFishingWorld		INT
		,	@IsHideVS				INT
		--,	@IsHideBullFighting		INT
		--,	@IsHidePokerGames		INT

	DECLARE @bitOrderVB				INT 
		--,	@bitOrderLucky3			INT 
		,	@bitOrderFW				INT 
		,	@bitOrderNG2			INT 
		,	@bitOrderLottery		INT 
		,	@bitOrderCF				INT 
		,	@bitOrderCriket			INT 
		,   @bitOrderVS				INT 
		--,   @bitOrderBF				INT 
		--,   @bitOrderPG				INT 

    SET @bitOrderCF = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 206 AND Bettype = 1003)
    SET @bitOrderCriket = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 50 AND Bettype = 501)
	SET @bitOrderVB = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 212 AND Bettype = 4001)
	SET @bitOrderLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitOrderNG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	--SET @bitOrderLucky3 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 160 AND Bettype = 1600)
	SET @bitOrderFW = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitOrderVS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	--SET @bitOrderBF = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 207 AND Bettype = 1004)
	--SET @bitOrderPG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 163 AND Bettype = 1401)

	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend
		, @AllowedColossusbets = CASE WHEN HideColossusBet = 0 THEN 1 ELSE 0 END		
	from custinfo with (nolock) where CustID=@CustID
	
	--For Cockfighting
	EXEC Acc_CheckShowProduct @ProductID = 19, @IsHide = @IsHideCockfighting OUTPUT
	SET @AllowedCockfighting = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderCF) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 
										AND @IsHideCockfighting = 0 THEN 1 ELSE 0 END
		
	----For Lucky3
	--EXEC Acc_CheckShowProduct @ProductID = 26, @IsHide = @IsHideLucky3 OUTPUT
	--SELECT	@AllowedLucky3 =	CASE	WHEN @RoleID = 4 AND @IsHideLucky3 = 0 THEN 1
	--									WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderLucky3) = 0
	--										AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitOrderLucky3) = 1
	--										AND @IsHideLucky3 = 0 
	--										THEN 1
	--									ELSE 0
	--							END
	--FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	--WHERE	cps.CustID = @CustID
	
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
	
	--For Cricket
	EXEC Acc_CheckShowProduct @ProductID = 20, @IsHide = @IsHideCricket OUTPUT
	IF @RoleID IN (2,3,4)
	BEGIN
		IF @IsHideCricket = 0 AND EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @CustID AND [Site] = 'IMBC')
			SET @AllowedCricket = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderCriket) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 THEN 1 ELSE 0 END
	END
	ELSE IF @RoleID = 1
	BEGIN
		IF @IsHideCricket = 0 AND EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE custid = @recommend AND [Site] = 'IMBC')
			SET @AllowedCricket = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderCriket) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 THEN 1 ELSE 0 END
	END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedCS=1
		--SET @AllowedBI=1
		--SET @AllowedLiveCS = 1
		SET @AllowedVS = 1
	END
	ELSE 
	BEGIN 
		-- Check if Replicate run slowly.
		If (@RoleID is null) 
		Begin 
			set @AllowedHR=0
			set @AllowedCS=0
			--set @AllowedBI=0
			--set @AllowedLiveCS = 0
			return
		End
		-- For Casino (Check Upline allowed Casino)
		if @RoleID=3
			Select @SyncCasino=SyncCasino /*, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino */ FROM custinfo with (nolock) where CustID=@srecommend	
		Else if @RoleID=2
			Select @SyncCasino=SyncCasino /*, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino */ from custinfo with (nolock) where CustID=@mrecommend	
		Else if @RoleID=1
			Select @SyncCasino=SyncCasino /*, @SyncBingo=SyncBingo, @DisableBingo = DisableBingo, @SyncLiveCS = SyncLiveCasino */ from custinfo with (nolock) where CustID=@recommend		
		
		-- For Casino
		if @SyncCasino!=1
			set @AllowedCS=0
		else
			set @AllowedCS=1
			
		---- For Bingo
		--if @SyncBingo!=1 
		--	set @AllowedBI=0
		--else
		--	set @AllowedBI=1
		
		---- For live casino
		--if @SyncLiveCS != 1
		--	set @AllowedLiveCS = 0
		--else
		--	set @AllowedLiveCS = 1				
	End

	-- For Horse Racing	
	Exec Acc_CheckHRAllowedCurrency @CurrencyID=@mCurrencyID, @Allowed= @AllowedHR OUTPUT

	-- For AllBet
	EXEC Acc_CheckShowProduct @ProductID = 21, @IsHide = @IsHideAllBet OUTPUT
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
		AND	psd.ProductID = 21
		
	---- For PokerGames
	--EXEC Acc_CheckShowProduct @ProductID = 33, @IsHide = @IsHidePokerGames OUTPUT
	--SELECT	@AllowedPokerGames =CASE	WHEN @RoleID = 4 AND @IsHidePokerGames = 0 THEN 1
	--									WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderPG) = 0
	--										AND @IsHidePokerGames = 0 
	--										THEN 1
	--									ELSE 0
	--							END
	--FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	--WHERE	cps.CustID = @CustID

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

	---- For BullFighting
	--EXEC Acc_CheckShowProduct @ProductID = 30, @IsHide = @IsHideBullFighting OUTPUT
	--SELECT	@AllowedBullFighting =	CASE	WHEN @RoleID = 4 AND @IsHideBullFighting = 0 THEN 1
	--									WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderBF) = 0
	--										AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitOrderBF) = 1
	--										AND @IsHideBullFighting = 0 
	--										THEN 1
	--									ELSE 0
	--							END
	--FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	--WHERE	cps.CustID = @CustID
END
GO