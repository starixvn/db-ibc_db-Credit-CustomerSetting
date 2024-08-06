/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" IsNested = "1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_02]
	@custid INT =0,
	@ExistingCustid INT = 0,
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT,
	@SettingStatus TINYINT = 0
AS
/*
	Created: Johnson
	Date: 20131106
	Task: Apply execrep when insert into custsetting/custsetting3rd
	DB: DBCUST/custDB
	
	Revisions:
		- 20140303@Patrick	: Add more sport: 202 for Keno
		- 20150427@Kathy: Add Gold Deluxe product [Redmine:#34486] 
	     
	    - 20150610@Daniel: 
		  + Separate custDB to new server DBCUST: 
		  + Improve medthod check table existing in subscribers			
		- 20141217@Dominic: Add logic for new customer setting structure - Redmine Feature #26274			  
		- 20151016@Elodie: Add new product Colossus Bet and Myanmar Odds [Redmine: #41264, 41470]
		- 20151119@Dominic: Fix bug when inserting setting into DCS structure Redmine Feature #26274
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190826@Eden: 3rd party products - Remove InActive Products Phase 2  [Redmine: #118699]
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20210518@Winfred: Add new Parlay Max Payout [RedmineID:#154104]
		- 20210802@Eden: Max Payout Per Match [redmine: #158073]
		- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240628@Johnson: scale out DBCUST [redmine: #199915]
	Parameter's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/ 
BEGIN
	SET NOCOUNT ON

    IF (dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1 		  
		  AND dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1			 
		  AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1	
	   )
	BEGIN	

		DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency SMALLINT
		DECLARE @RoleID TINYINT ,@SuperID INT, @MasterID INT

		SELECT @RoleID = roleid , @SuperID = srecommend , @MasterID = mrecommend
			,@_Site = Site, @_Currency = currency 
		FROM dbo.Customer WITH(NOLOCK) 
		WHERE CustID = @CustID

		SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

		CREATE TABLE #SportBettype_SB(	
			[SettingType] [smallint],
			[SportType] [smallint],
			[BetType] [smallint],
			[IsLive] [bit]
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
		)
	
		INSERT INTO #SportBettype_SB(SportType,BetType,SettingType,IsLive)
		SELECT SportType,BetType,SettingType,IsLive
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@_SiteID,@_Currency)
		WHERE SettingType IN (25,27,28)

		--PT
		INSERT INTO [dbo].[CustPTSetting3rd_Agent]
			([CustID]
			,[SportType]
			,[BetType]
			,[IsLive]
			,[SuperPT]
			,[MasterPT]
			,[AgentPT]
			,[IsAutoMasterPT]
			,[AutoMasterPT]
			,[IsAutoSuperPT]
			,[AutoSuperPT]
			,[MinPT]
			,[MaxPT])
		SELECT 
			@CustID
			,cs.SportType
			,cs.BetType
			,cs.IsLive
			,[SuperPT]
			,[MasterPT]
			,[AgentPT]
			,[IsAutoMasterPT]
			,[AutoMasterPT]
			,[IsAutoSuperPT]
			,[AutoSuperPT]
			,[MinPT]
			,100 --[MaxPT]
		FROM [dbo].[CustPTSetting3rd_Agent] cs WITH(NOLOCK)
			INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.IsLive = cs.IsLive AND ps.SettingType = 28
		WHERE CustID = @ExistingCustID 	

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 28
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.[CustPTSetting3rd_Agent] WITH(ROWLOCK) WHERE CustID = @CustID
			RETURN
		END	

		--Comm
		INSERT INTO [dbo].[CustDiscount3rd_Agent]
					([CustID]
					,[SportType]
					,[BetType]
					,[Discount])
		SELECT		@CustID
					,cs.SportType
					,cs.BetType
					,cs.[Discount]
		FROM [dbo].[CustDiscount3rd_Agent] cs WITH(NOLOCK)
			INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.SettingType = 25
		WHERE CustID = @ExistingCustID 

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 25
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.[CustPTSetting3rd_Agent] WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM dbo.[CustDiscount3rd_Agent] WITH(ROWLOCK) WHERE CustID = @CustID
			RETURN
		END	

		-- Parlay Max Payout
		IF @RoleID  = 4 
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					cs.SingleMatchParlay,
					cs.Combo2,
					cs.Combo35,
					cs.ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs  WITH(NOLOCK)
				INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.SettingType = 27
			WHERE cs.CustID  = @ExistingCustid
		END
		ELSE IF @RoleID  = 3
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					CASE WHEN cs.SingleMatchParlay > upl.SingleMatchParlay  AND upl.SingleMatchParlay > 0 THEN upl.SingleMatchParlay ELSE cs.SingleMatchParlay END AS SingleMatchParlay,
					CASE WHEN cs.Combo2 > upl.Combo2  AND upl.Combo2 > 0 THEN upl.Combo2 ELSE cs.Combo2 END AS Combo2,
					CASE WHEN cs.Combo35 > upl.Combo35  AND upl.Combo35 > 0 THEN upl.Combo35 ELSE cs.Combo35 END AS Combo35,
					CASE WHEN cs.ComboOver6 > upl.ComboOver6  AND upl.ComboOver6 > 0 THEN upl.ComboOver6 ELSE cs.ComboOver6 END AS ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
				INNER JOIN dbo.CustMaxPayoutSetting_Agent upl WITH (NOLOCK) ON cs.SportType = upl.SportType AND cs.BetType = upl.BetType
				INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.SettingType = 27
			WHERE cs.CustID  = @ExistingCustid  AND Upl.CustID = @SuperID
		END
		ELSE IF @RoleID  = 2
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					CASE WHEN cs.SingleMatchParlay > upl.SingleMatchParlay  AND upl.SingleMatchParlay > 0 THEN upl.SingleMatchParlay ELSE cs.SingleMatchParlay END AS SingleMatchParlay,
					CASE WHEN cs.Combo2 > upl.Combo2  AND upl.Combo2 > 0 THEN upl.Combo2 ELSE cs.Combo2 END AS Combo2,
					CASE WHEN cs.Combo35 > upl.Combo35  AND upl.Combo35 > 0 THEN upl.Combo35 ELSE cs.Combo35 END AS Combo35,
					CASE WHEN cs.ComboOver6 > upl.ComboOver6  AND upl.ComboOver6 > 0 THEN upl.ComboOver6 ELSE cs.ComboOver6 END AS ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
				INNER JOIN dbo.CustMaxPayoutSetting_Agent upl WITH (NOLOCK) ON cs.SportType = upl.SportType AND cs.BetType = upl.BetType
				INNER JOIN #SportBettype_SB ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.SettingType = 27
			WHERE cs.CustID  = @ExistingCustid  AND Upl.CustID = @MasterID
		END
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 27
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.[CustPTSetting3rd_Agent] WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM dbo.[CustDiscount3rd_Agent] WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM dbo.CustMaxPayoutSetting_Agent WITH(ROWLOCK) WHERE CustID = @CustID
			RETURN
		END	
	END

	DECLARE @DCSErrCode INT = 0
	
	/*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
	EXEC dbo.Acc_DynamicCustomerInfo_02
			  @CustID			= @CustID
			, @ExistingCustid	= @ExistingCustid
			, @SettingStatus    = @SettingStatus
			, @ErrCode			= @DCSErrCode OUTPUT
			
	IF @DCSErrCode <> 0 
	BEGIN
		--Error Occurs
		SELECT @ErrCode = 911

		-- ROLLBACK MANUALLY
		IF(dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1)		DELETE CustDiscount3rd_Agent WITH (ROWLOCK) WHERE custid =  @CustID
		IF(dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1)		DELETE dbo.CustPTSetting3rd_Agent WITH(ROWLOCK) WHERE custid = @CustID 
		IF(dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1)	DELETE CustMaxPayoutSetting_Agent WITH (ROWLOCK) WHERE custId  = @CustID		
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
END
GO
