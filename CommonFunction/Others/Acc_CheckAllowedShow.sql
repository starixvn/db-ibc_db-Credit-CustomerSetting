/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID					INT
				,	@AllowedVS				BIT = 0		OUTPUT
				,	@AllowedLiveCasino		BIT = 0		OUTPUT
				,	@AllowedVoidBridge		BIT = 0		OUTPUT
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
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
	- 20221130@Tacy: Non-sports products - Remove GDG and Fishing World [RedmineID: #174511]
	- 20230519@Luke: YeeBet - Integrate new Live Casino product [Redmine: #186046]
	- 20230628@Tacy: NG2 - Remove Setting [Redmine: #189762]
	- 20230728@Eden: Simplify Live Casino Customer Setting [RedmineID: #189389]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit 
	Declare @srecommend int, @mrecommend int, @recommend int 
	DECLARE  @AllowedLottery BIT, @AllowedTableGames BIT, @AllowedRNGWar BIT
			,@AllowedVirtualGames2 BIT, @AllowedFGG BIT
			
	DECLARE	@IsHideVoidBridge		INT
		,	@IsHiddenLottery		INT 
		,	@IsHideVS				INT
		,	@IsHideVG				INT
		,	@IsHideVG2				INT
		,	@IsHideFGG				INT
		,	@IsHideSaba				INT
		,	@IsHideTableGames		INT
		,	@IsHideRNGWar			INT
		,	@IsHideVGamming			INT
		,	@IsHideBitcoin			INT
		,	@IsHideSabaCasino		INT
		,   @IsHiddenLiveCasino		INT = 1

	DECLARE @bitOrderVB				INT 
		,	@bitOrderLottery		INT 
		,   @bitOrderVS				INT
		,	@bitmapOrder_VG			INT
		,	@bitmapOrder_FGG		INT
		,	@bitmapOrder_Saba		INT
		,	@bitmapOrder_TableGames	INT 
		,	@bitmapOrder_RNGWar		INT 
		,	@bitmapOrder_VGaming	INT 
		,	@bitmapOrder_Bitcoin	INT  
		,   @bitmapOrder_SabaCasino INT
		,   @bitmapOrder_LiveCasino	INT

	SET @bitOrderVB = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SET @bitOrderLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1024)
	SET @bitOrderVS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9908 AND Bettype = 1201)
	SET @bitmapOrder_VG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 245 AND Bettype = 4601)
	SET @bitmapOrder_FGG = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 176 AND Bettype = 8201)
	SET @bitmapOrder_Saba = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 200 AND Bettype = 1611)
	SET @bitmapOrder_TableGames = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 222 AND Bettype = 4901)
	SET @bitmapOrder_RNGWar = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 224 AND Bettype = 5500)
	SET @bitmapOrder_VGaming = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 171 AND Bettype = 3801)
	SET @bitmapOrder_Bitcoin = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 175 AND Bettype = 7901)
	SET @bitmapOrder_SabaCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 208 AND Bettype = 2101)
	SET @bitmapOrder_LiveCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9911 AND Bettype = 2400)


	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend	
	from custinfo with (nolock) where CustID=@CustID
	
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
	EXEC Acc_CheckShowProduct @ProductID = 18, @IsHide = @IsHideVoidBridge OUTPUT, @SettingStatus = @SettingStatus
	SET @AllowedVoidBridge = CASE WHEN (SELECT dbo.f_GetProductStatus (bitmapIsHidden,@bitOrderVB) FROM CustProductStatus WITH (NOLOCK) WHERE CustID = @CustID) = 0 
										AND @IsHideVoidBridge = 0 THEN 1 ELSE 0 END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedVS = 1
	END

	-- For Live Casino
	EXEC Acc_CheckShowProduct @ProductID = 41, @SettingStatus = @SettingStatus, @IsHide = @IsHiddenLiveCasino OUTPUT
	IF @RoleID = 4
		SELECT	@AllowedLiveCasino =	CASE WHEN @IsHiddenLiveCasino = 0 
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)) = 0 THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@AllowedLiveCasino =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_LiveCasino)) = 1
											AND @IsHiddenLiveCasino = 0 
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