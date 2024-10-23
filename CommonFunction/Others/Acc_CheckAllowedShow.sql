/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CheckAllowedShow]
					@CustID				INT				
				,	@AllowedLiveRNGCasino		BIT = 0		OUTPUT
				,	@AllowedRNGGames			BIT = 0		OUTPUT
				,     @SettingStatus			TINYINT = 0
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
	- 20240521@Helios: Unify RNG Games [Redmine: #204358]  
	- 20241022@Johnson: remove bitcoin [redmine: #201396]
	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/

	SET NOCOUNT ON

	DECLARE
		@mCurrencyID INT
	    , @RoleID	 INT
	    , @SyncCasino	 BIT
	DECLARE
		@srecommend INT
	    , @mrecommend INT
	    , @recommend  INT
	DECLARE
		-- RNG Casino
		@Allowed_LiveCasino     BIT
	    , @Allowed_RNGCasino	BIT
	    , @Allowed_OtherRNGCasino BIT
	    
	      -- RNG Games
	    , @Allowed_RNGGames	 INT = 1 
	    , @Allowed_SportsLottery	 INT = 1 
	    , @Allowed_VirtualSport	 INT = 1 

	DECLARE	    
		--Live & RNG Casino
	     @IsHidden_LiveCasino	 INT = 1
	    , @IsHidden_RNGCasino	 INT = 1
	    , @IsHidden_OtherRNGCasino INT = 1
	      --RNG Games
	    , @IsHidden_RNGGames	 INT = 1 
	    , @IsHidden_SportsLottery	 INT = 1 
	    , @IsHidden_VirtualSport	 INT = 1 

	DECLARE	      
		--Live & RNG Casino
	     @bitmapOrder_LiveCasino	    INT
	    , @bitmapOrder_RNGCasino	    INT
	    , @bitmapOrder_OtherRNGCasino INT
	      --RNG Games
	    , @bitmapOrder_RNGGames	    INT = 1 
	    , @bitmapOrder_SportsLottery   INT = 1 
	    , @bitmapOrder_VirtualSport   INT = 1 

	--Live & RNG Casino
	SET @bitmapOrder_LiveCasino = 
	(
		SELECT bitmapOrder
		FROM ProductStatusProfile WITH (NOLOCK)
		WHERE Sporttype = 9911 AND Bettype = 2400
	)
	SET @bitmapOrder_RNGCasino = 
	(
		SELECT bitmapOrder
		FROM ProductStatusProfile WITH (NOLOCK)
		WHERE Sporttype = 9906 AND Bettype = 4001
	)
	SET @bitmapOrder_OtherRNGCasino = 
	(
		SELECT bitmapOrder
		FROM ProductStatusProfile WITH (NOLOCK)
		WHERE Sporttype = 9918 AND Bettype = 4601
	)

	--RNG Games
	SET @bitmapOrder_RNGGames = 
	(
		SELECT bitmapOrder
		FROM ProductStatusProfile WITH (NOLOCK)
		WHERE Sporttype = 9919 AND Bettype = 1501
	)
	SET @bitmapOrder_SportsLottery = 
	(
		SELECT bitmapOrder
		    FROM ProductStatusProfile WITH (NOLOCK)
			WHERE Sporttype = 169 AND Bettype = 3611
	)
	SET @bitmapOrder_VirtualSport = 
	(
		SELECT bitmapOrder
		    FROM ProductStatusProfile WITH (NOLOCK)
			WHERE Sporttype = 9908 AND Bettype = 1201
	)

	SELECT
		@mCurrencyID=Currency
	    , @RoleID     =RoleID
	    , @srecommend =srecommend
	    , @mrecommend =mrecommend
	    , @recommend  =recommend
	FROM custInfo WITH (NOLOCK)
	WHERE CustID=@CustID
	
	-- For Live & RNG Casino
	EXEC Acc_CheckShowProduct @ProductID     = 41
					, @Sporttype     = 9911
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_LiveCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID     = 53
					, @Sporttype     = 9906
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_RNGCasino OUTPUT
	EXEC Acc_CheckShowProduct @ProductID     = 53
					, @Sporttype     = 9918
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_OtherRNGCasino OUTPUT

	IF    @RoleID = 4
	BEGIN
		SELECT @Allowed_LiveCasino     =  CASE
								 WHEN @IsHidden_LiveCasino = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_LiveCasino )
									 ) = 0 THEN 1
								 ELSE 0
							    END
		    , @Allowed_RNGCasino	= CASE
								 WHEN @IsHidden_RNGCasino = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_RNGCasino )
									 ) = 0 THEN 1
								 ELSE 0
							   END
		    , @Allowed_OtherRNGCasino = CASE
								 WHEN @IsHidden_OtherRNGCasino = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_OtherRNGCasino )
									 ) = 0 THEN 1
								 ELSE 0
							 END

		FROM CustProductStatus AS cps WITH (NOLOCK)
		WHERE cps.CustID = @CustID
	END
	ELSE
	BEGIN
		SELECT @Allowed_LiveCasino     = CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_LiveCasino )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_LiveCasino )
									 ) = 1
									 AND @IsHidden_LiveCasino = 0 THEN 1
								 ELSE 0
							 END
		    , @Allowed_RNGCasino	= CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_RNGCasino )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_RNGCasino )
									 ) = 1
									 AND @IsHidden_RNGCasino = 0 THEN 1
								 ELSE 0
							 END
		    , @Allowed_OtherRNGCasino = CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_OtherRNGCasino )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_OtherRNGCasino )
									 ) = 1
									 AND @IsHidden_OtherRNGCasino = 0 THEN 1
								 ELSE 0
							 END
		FROM CustProductStatus AS cps WITH (NOLOCK)
		CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)
		WHERE cps.CustID = @CustID
		AND ups.CustID = CASE
						WHEN @RoleID = 3 THEN @srecommend
						WHEN @RoleID = 2 THEN @mrecommend
					ELSE @recommend
				END
	END

	SELECT @AllowedLiveRNGCasino =  CASE
						     WHEN @Allowed_LiveCasino = 1 OR @Allowed_RNGCasino = 1 OR @Allowed_OtherRNGCasino = 1 THEN 1
						     ELSE 0
					        END

	-- For RNG Games : DummyProductID - 44
	EXEC Acc_CheckShowProduct @ProductID     = 44		
					, @Sporttype     = 169		-- Sports Lottery
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_SportsLottery OUTPUT
	EXEC Acc_CheckShowProduct @ProductID     = 44		
					, @Sporttype     = 9919		-- RNG Games / Keno/Loterry
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_RNGGames OUTPUT
	EXEC Acc_CheckShowProduct @ProductID     = 44		
					, @Sporttype     = 9908		-- Virtual Sports
					, @SettingStatus = @SettingStatus
					, @IsHide	     = @IsHidden_VirtualSport OUTPUT
	
	
	IF    @RoleID = 4
	BEGIN
		SELECT @Allowed_SportsLottery     =  CASE
								 WHEN @IsHidden_SportsLottery = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_SportsLottery )
									 ) = 0 THEN 1
								 ELSE 0
							    END
		    , @Allowed_RNGGames	= CASE
								 WHEN @IsHidden_RNGGames = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_RNGGames )
									 ) = 0 THEN 1
								 ELSE 0
							   END
		    , @Allowed_VirtualSport = CASE
								 WHEN @IsHidden_VirtualSport = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_VirtualSport )
									 ) = 0 THEN 1
								 ELSE 0
							 END

		FROM CustProductStatus AS cps WITH (NOLOCK)
		WHERE cps.CustID = @CustID
	END
	ELSE
	BEGIN
		SELECT @Allowed_SportsLottery     = CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_SportsLottery )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_SportsLottery )
									 ) = 1 AND @IsHidden_SportsLottery = 0 THEN 1
								 ELSE 0
							 END
		    , @Allowed_RNGGames	= CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_RNGGames )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_RNGGames )
									 ) = 1 AND @IsHidden_RNGGames = 0 THEN 1
								 ELSE 0
							 END
		    , @Allowed_VirtualSport = CASE
								 WHEN
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( cps.bitmapIsHidden , @bitmapOrder_VirtualSport )
									 ) = 0
									 AND
									 (
										 SELECT value FROM dbo.f_CustSetting_ProductStatusSel ( ups.bitmapHasSynced , @bitmapOrder_VirtualSport )
									 ) = 1 AND @IsHidden_VirtualSport = 0 THEN 1
								 ELSE 0
							 END
		FROM CustProductStatus AS cps WITH (NOLOCK)
		CROSS JOIN CustProductStatus AS ups WITH (NOLOCK)
		WHERE cps.CustID = @CustID
		AND ups.CustID = CASE
						WHEN @RoleID = 3 THEN @srecommend
						WHEN @RoleID = 2 THEN @mrecommend
					ELSE @recommend
				END
	END

	SELECT @AllowedRNGGames =  CASE
						     WHEN @Allowed_SportsLottery = 1 OR @Allowed_RNGGames = 1 OR @Allowed_VirtualSport = 1 THEN 1
						     ELSE 0
					        END
END

GO