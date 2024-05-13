/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID					INT
				,	@AllowedVS				BIT = 0		OUTPUT
				,	@AllowedRNGLottery		BIT = 0		OUTPUT
				,	@AllowedBitcoin			BIT = 0		OUTPUT
				,	@AllowedLiveRNGCasino	BIT = 0		OUTPUT
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
	- 20240318@Eden: Unify Live RNG Casino [Redmine: #198960]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/

	SET NOCOUNT ON

	Declare @mCurrencyID int, @RoleID int, @SyncCasino bit 
	Declare @srecommend int, @mrecommend int, @recommend int 
	DECLARE @AllowedLottery BIT, @AllowedTableGames BIT
	DECLARE	@Allowed_LiveCasino	BIT, @Allowed_RNGCasino BIT, @Allowed_OtherRNGCasino BIT 
			
	DECLARE	@IsHiddenLottery		INT 
		,	@IsHideVS				INT
		,	@IsHideTableGames		INT
		,	@IsHideBitcoin			INT
		--Live & RNG Casino
		,   @IsHidden_LiveCasino	INT = 1
		,   @IsHidden_RNGCasino		INT = 1
		,   @IsHidden_OtherRNGCasino INT = 1

	DECLARE @bitOrderLottery		INT 
		,   @bitOrderVS				INT
		,	@bitmapOrder_TableGames	INT 
		,	@bitmapOrder_Bitcoin	INT 
		--Live & RNG Casino
		,   @bitmapOrder_LiveCasino	INT
		,   @bitmapOrder_RNGCasino	INT
		,	@bitmapOrder_OtherRNGCasino	INT 

	SET @bitOrderLottery = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 220 AND Bettype = 1024)
	SET @bitOrderVS = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9908 AND Bettype = 1201)
	SET @bitmapOrder_TableGames = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 222 AND Bettype = 4901)
	SET @bitmapOrder_Bitcoin = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 175 AND Bettype = 7901)
	--Live & RNG Casino
	SET @bitmapOrder_LiveCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9911 AND Bettype = 2400)
	SET @bitmapOrder_RNGCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9906 AND Bettype = 4001)
	SET @bitmapOrder_OtherRNGCasino = (SELECT bitmapOrder FROM ProductStatusProfile WITH (NOLOCK) WHERE Sporttype = 9918 AND Bettype = 4601)


	Select @mCurrencyID=Currency, @RoleID=RoleID, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend	
	from custinfo with (nolock) where CustID=@CustID
	
	--For RNGLottery
	EXEC Acc_CheckShowProduct @ProductID = 44, @sportType = 220, @SettingStatus = @SettingStatus, @IsHide = @IsHiddenLottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 44, @sportType = 222, @SettingStatus = @SettingStatus, @IsHide = @IsHideTableGames OUTPUT
	SELECT	@AllowedLottery =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitOrderLottery)) = 0
											AND @IsHiddenLottery = 0 
											THEN 1
										ELSE 0 END,
			@AllowedTableGames =CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_TableGames)) = 0
											AND @IsHideTableGames = 0 
											THEN 1
										ELSE 0 END
	FROM	CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

	--For RNGLottery (Lottery + TableGames + RNG War)
	SELECT @AllowedRNGLottery = CASE WHEN @AllowedLottery = 1 OR @AllowedTableGames = 1 THEN 1 ELSE 0 END
	
	If @RoleID=4
	BEGIN	
		SET @AllowedVS = 1
	END

	-- For VS
	EXEC Acc_CheckShowProduct @ProductID = 5, @SettingStatus = @SettingStatus, @IsHide = @IsHideVS OUTPUT
	SELECT	@AllowedVS = CASE	WHEN @RoleID = 4 AND @IsHideVS = 0 THEN 1
								WHEN dbo.f_GetProductStatus(cps.bitmapIsHidden, @bitOrderVS) = 0 AND @IsHideVS = 0 THEN 1
								ELSE 0
						END
	FROM	dbo.CustProductStatus AS cps WITH (NOLOCK)
	WHERE	cps.CustID = @CustID

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


	-- For Live & RNG Casino
	EXEC Acc_CheckShowProduct @ProductID = 41, @sportType = 9911, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_LiveCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 53, @sportType = 9906, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_RNGCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID = 53, @sportType = 9918, @SettingStatus = @SettingStatus, @IsHide = @IsHidden_OtherRNGCasino OUTPUT
	IF @RoleID = 4
		SELECT	@Allowed_LiveCasino =	CASE WHEN @IsHidden_LiveCasino = 0 
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)) = 0 THEN 1
										ELSE 0 END,
				@Allowed_RNGCasino =	CASE WHEN @IsHidden_RNGCasino = 0 
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_RNGCasino)) = 0 THEN 1
										ELSE 0 END,
				@Allowed_OtherRNGCasino =	CASE WHEN @IsHidden_OtherRNGCasino = 0 
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_OtherRNGCasino)) = 0 THEN 1
										ELSE 0 END

		FROM	CustProductStatus AS cps WITH (NOLOCK)
		WHERE	cps.CustID = @CustID
	ELSE 
		SELECT	@Allowed_LiveCasino =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_LiveCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_LiveCasino)) = 1
											AND @IsHidden_LiveCasino = 0 
											THEN 1
										ELSE 0 END,
				@Allowed_RNGCasino =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_RNGCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_RNGCasino)) = 1
											AND @IsHidden_RNGCasino = 0 
											THEN 1
										ELSE 0 END,
				@Allowed_OtherRNGCasino =	CASE WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cps.bitmapIsHidden, @bitmapOrder_OtherRNGCasino)) = 0
											AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(ups.bitmapHasSynced, @bitmapOrder_OtherRNGCasino)) = 1
											AND @IsHidden_OtherRNGCasino = 0 
											THEN 1
										ELSE 0 END
		FROM	CustProductStatus AS cps WITH (NOLOCK)
			CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)	
		WHERE	cps.CustID = @CustID
			AND ups.CustID = CASE	WHEN @RoleID = 3 THEN @srecommend
									WHEN @RoleID = 2 THEN @mrecommend
									ELSE @recommend END

	SELECT @AllowedLiveRNGCasino = CASE WHEN @Allowed_LiveCasino = 1 OR @Allowed_RNGCasino = 1 OR @Allowed_OtherRNGCasino = 1  THEN 1 ELSE 0 END
							
END
GO