/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID					INT
				,	@AllowedVS				BIT = 0		OUTPUT
				,	@AllowedLiveCasino		BIT = 0		OUTPUT
				,	@AllowedVoidBridge		BIT = 0		OUTPUT
				,	@AllowedNG2				BIT = 0		OUTPUT
				,	@AllowedFishingWorld	BIT = 0		OUTPUT
				,	@AllowedRNGLottery		BIT = 0		OUTPUT
				,	@AllowedVirtualGames	BIT = 0		OUTPUT
				,	@AllowedSabaClub		BIT = 0		OUTPUT
				,	@AllowedVGaming			BIT = 0		OUTPUT
				,	@AllowedBitcoin			BIT = 0		OUTPUT
				,	@AllowedSabaCasino		BIT = 0		OUTPUT
				,   @SettingStatus          TINYINT = 0

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
	- 20200321@Tiara: Add Sexy Gaming Product [Redmine: #130678]
	- 20200406@Elodie: Add BBIN Product [Redmine: #131363]
	- 20200403@Elodie: Add Table Games Product [Redmine: #129440]
	- 20200421@Elodie: Add GTCasino Product [Redmine: #130689]
	- 20200504@Eden: ION Live casino [Redmine: #132323]
	- 20200506@Tiara: Add RNG War Product [Redmine: 132018]
	- 20201012@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20210426@Tina: Add VGaming [Redmine: #153938]
	- 20210809@Winfred: add Bitcoin Betting [RedmineID: #159039]
	- 20220211@Johnson: add FGG under Virtual Games - change productID to 64 [RedmineID: #165684]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20220921@Winfred:  Macau Game Setting Page - Rename the setting page into RNG Slot and hide all bet limit setting [Redmine: #174513]
	
	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit 
	Declare @srecommend int, @mrecommend int, @recommend int 
	DECLARE @AllowedSAGaming BIT, @AllowedAllBet BIT, @AllowedSexyGaming BIT, @AllowedGTCasino BIT, @AllowedBBIN BIT, @AllowedLottery BIT, @AllowedTableGames BIT, @AllowedRNGWar BIT, @AllowedION BIT
			,@AllowedVirtualGames2 BIT, @AllowedFGG BIT
			
	DECLARE	@IsHideAllBet			INT
		,	@IsHideVoidBridge		INT
		,	@IsHiddenLottery		INT 
		,	@IsHideNG2				INT
		,	@IsHideFishingWorld		INT
		,	@IsHideVS				INT
		,	@IsHideVG				INT
		,	@IsHideVG2				INT
		,	@IsHideFGG				INT
		,	@IsHideSaba				INT
		,	@IsHideSAGaming			INT
		,	@IsHideSexyGaming		INT
		,	@IsHide_ION				INT = 1
		,	@IsHideBBIN				INT
		,	@IsHideTableGames		INT
		,	@IsHideGTCasino			INT
		,	@IsHideRNGWar			INT
		,	@IsHideVGamming			INT
		,	@IsHideBitcoin			INT
		,	@IsHideSabaCasino		INT

	DECLARE @bitmapOrder_Allbet		INT
		,	@bitOrderVB				INT 
		,	@bitOrderFW				INT 
		,	@bitOrderNG2			INT 
		,	@bitOrderLottery		INT 
		,   @bitOrderVS				INT
		,	@bitmapOrder_VG			INT
		,	@bitmapOrder_FGG		INT
		,	@bitmapOrder_Saba		INT
		,	@bitmapOrder_SAGaming	INT
		,	@bitmapOrder_SexyGaming	INT 
		,	@bitmapOrder_ION		INT 
		,	@bitmapOrder_BBIN		INT 
		,	@bitmapOrder_TableGames	INT 
		,	@bitmapOrder_GTCasino	INT 
		,	@bitmapOrder_RNGWar		INT 
		,	@bitmapOrder_VGaming	INT 
		,	@bitmapOrder_Bitcoin	INT  
		,   @bitmapOrder_SabaCasino INT

	SET @bitmapOrder_Allbet = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 211 AND Bettype = 2401)
	SET @bitOrderVB = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SET @bitOrderLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1021)
	SET @bitOrderNG2 = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 213 AND Bettype = 2501)
	SET @bitOrderFW = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 219 AND Bettype = 1011)
	SET @bitOrderVS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 180 AND Bettype = 1201)
	SET @bitmapOrder_VG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 245 AND Bettype = 4601)
	SET @bitmapOrder_FGG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 176 AND Bettype = 8201)
	SET @bitmapOrder_Saba = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 200 AND Bettype = 1611)
	SET @bitmapOrder_SAGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 244 AND Bettype = 3001)
	SET @bitmapOrder_SexyGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 243 AND Bettype = 3101)
	SET @bitmapOrder_ION = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 225 AND Bettype = 5601)
	SET @bitmapOrder_BBIN = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 241 AND Bettype = 3300)
	SET @bitmapOrder_TableGames = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 222 AND Bettype = 4901)
	SET @bitmapOrder_GTCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 242 AND Bettype = 3201)
	SET @bitmapOrder_RNGWar = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 224 AND Bettype = 5500)
	SET @bitmapOrder_VGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 171 AND Bettype = 3801)
	SET @bitmapOrder_Bitcoin = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 175 AND Bettype = 7901)
	SET @bitmapOrder_SabaCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 208 AND Bettype = 2101)

	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend	
	from custinfo with (nolock) where CustID=@CustID
	
	--For FishingWorld
	EXEC Acc_CheckShowProduct @ProductID = 24, @SettingStatus = @SettingStatus, @IsHide = @IsHideFishingWorld OUTPUT
	SELECT	@AllowedFishingWorld =	CASE	WHEN @RoleID = 4 AND @IsHideFishingWorld = 0 THEN 1
										WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderFW) = 0
											AND dbo.f_GetProductStatus(cps.bitmapHasSynced, @bitOrderFW) = 1
											AND @IsHideFishingWorld = 0 
											THEN 1
										ELSE 0
								END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	--For RNGLottery
	EXEC Acc_CheckShowProduct @ProductID = 44, @sportType = 220, @SettingStatus = @SettingStatus, @IsHide = @IsHiddenLottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @sportType = 222, @SettingStatus = @SettingStatus, @IsHide = @IsHideTableGames OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @sportType = 224, @SettingStatus = @SettingStatus, @IsHide = @IsHideRNGWar OUTPUT
	SELECT	@AllowedLottery =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitOrderLottery)) = 0
											AND @IsHiddenLottery = 0 
											THEN 1
										ELSE 0 END,
			@AllowedTableGames =CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_TableGames)) = 0
											AND @IsHideTableGames = 0 
											THEN 1
										ELSE 0 END,
			@AllowedRNGWar =CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_RNGWar)) = 0
											AND @IsHideRNGWar = 0 
											THEN 1
										ELSE 0 END
	FROM	CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	--For RNGLottery (Lottery + TableGames + RNG War)
	SELECT @AllowedRNGLottery = CASE WHEN @AllowedLottery = 1 OR @AllowedTableGames = 1  OR @AllowedRNGWar = 1 THEN 1 ELSE 0 END

	--For VoidBridge
	EXEC Acc_CheckShowProduct @ProductID = 53, @IsHide = @IsHideVoidBridge OUTPUT, @SettingStatus = @SettingStatus
	SET @AllowedVoidBridge = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderVB) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 
										AND @IsHideVoidBridge = 0 THEN 1 ELSE 0 END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedVS = 1
	END

	-- For AllBet
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 211, @SettingStatus = @SettingStatus, @IsHide = @IsHideAllBet OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedAllBet =	CASE	WHEN @IsHideAllBet = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_AllBet)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedAllBet =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_AllBet)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_AllBet)) = 1
											AND @IsHideAllBet = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
	-- For SA Gaming
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 244, @SettingStatus = @SettingStatus, @IsHide = @IsHideSAGaming OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedSAGaming =	CASE	WHEN @IsHideSAGaming = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SAGaming)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedSAGaming =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SAGaming)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_SAGaming)) = 1
											AND @IsHideSAGaming = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
	-- For Sexy Gaming
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 243, @SettingStatus = @SettingStatus, @IsHide = @IsHideSexyGaming OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 242, @SettingStatus = @SettingStatus, @IsHide = @IsHideGTCasino OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedSexyGaming =	CASE WHEN @IsHideSexyGaming = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SexyGaming)) = 0 THEN 1
										ELSE 0 END,
				@AllowedGTCasino =	CASE WHEN @IsHideGTCasino = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_GTCasino)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedSexyGaming =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SexyGaming)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_SexyGaming)) = 1
											AND @IsHideSexyGaming = 0 
											THEN 1
										ELSE 0 END,
				@AllowedGTCasino =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_GTCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_GTCasino)) = 1
											AND @IsHideGTCasino = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
	
	-- For ION
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 243, @SettingStatus = @SettingStatus, @IsHide = @IsHide_ION OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedION =	CASE WHEN @IsHide_ION = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_ION)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedION =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_ION)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_ION)) = 1
											AND @IsHide_ION = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
	-- For BBIN
	EXEC Acc_CheckShowProduct @ProductID = 41, @Sporttype = 241, @SettingStatus = @SettingStatus, @IsHide = @IsHideBBIN OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedBBIN =	CASE WHEN @IsHideBBIN = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_BBIN)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedBBIN =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_BBIN)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_BBIN)) = 1
											AND @IsHideBBIN = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END

	--For Live Casino (Allbet + SA Gaming + SexyGaming + BBIN + GTCasino + ION)
	SELECT @AllowedLiveCasino = CASE WHEN @AllowedAllBet = 1 OR @AllowedSAGaming = 1 OR @AllowedSexyGaming = 1 OR @AllowedBBIN = 1 OR @AllowedGTCasino = 1 OR @AllowedION = 1 THEN 1
								ELSE 0 END
	-- For NG2
	EXEC Acc_CheckShowProduct @ProductID = 23, @SettingStatus = @SettingStatus, @IsHide = @IsHideNG2 OUTPUT
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
	EXEC Acc_CheckShowProduct @ProductID = 5, @SettingStatus = @SettingStatus, @IsHide = @IsHideVS OUTPUT
	SELECT	@AllowedVS = CASE	WHEN @RoleID = 4 AND @IsHideVS = 0 THEN 1
								WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderVS) = 0 AND @IsHideVS = 0 THEN 1
								ELSE 0
						END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	-- For Virtual games
	EXEC Acc_CheckShowProduct @ProductID = 64, @sportType = 245, @SettingStatus = @SettingStatus, @IsHide = @IsHideVG2 OUTPUT
	SELECT	@AllowedVirtualGames2 = CASE WHEN @IsHideVG2 = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VG)) = 0 THEN 1
								ELSE 0 END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID
	
	--For FGG
	EXEC Acc_CheckShowProduct @ProductID = 64, @sportType = 176, @SettingStatus = @SettingStatus, @IsHide = @IsHideFGG OUTPUT
	SELECT	@AllowedFGG = CASE WHEN @IsHideFGG = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_FGG)) = 0 THEN 1
								ELSE 0 END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID
	
	--For Virtual Games (Virtual Games + FGG)
	SELECT @AllowedVirtualGames = CASE WHEN @AllowedFGG = 1 OR @AllowedVirtualGames2 = 1 THEN 1
								ELSE 0 END
								
	-- For Saba
	EXEC Acc_CheckShowProduct @ProductID = 42, @SettingStatus = @SettingStatus, @IsHide = @IsHideSaba OUTPUT
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

	-- For VGaming
	EXEC Acc_CheckShowProduct @ProductID = 66, @SettingStatus = @SettingStatus, @IsHide = @IsHideVGamming OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedVGaming =	CASE	WHEN @IsHideVGamming = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VGaming)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedVGaming =	CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_VGaming)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_VGaming)) = 1
											AND @IsHideVGamming = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END
	-- For Bitcoin
	EXEC Acc_CheckShowProduct @ProductID = 69, @SettingStatus = @SettingStatus, @IsHide = @IsHideBitcoin OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedBitcoin =	CASE	WHEN @IsHideBitcoin = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Bitcoin)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedBitcoin =	CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_Bitcoin)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_Bitcoin)) = 1
											AND @IsHideBitcoin = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END		
									
	-- For Saba Casino
	EXEC Acc_CheckShowProduct @ProductID = 6, @SettingStatus = @SettingStatus, @IsHide = @IsHideSabaCasino OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedSabaCasino =	CASE	WHEN @IsHideSabaCasino = 0 AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SabaCasino)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedSabaCasino =	CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_SabaCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_SabaCasino)) = 1
											AND @IsHideSabaCasino = 0 
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