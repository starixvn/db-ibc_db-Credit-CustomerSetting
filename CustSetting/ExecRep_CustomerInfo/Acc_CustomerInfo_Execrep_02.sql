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
	Parameter's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/ 
BEGIN
	SET NOCOUNT ON

     IF (dbo.f_CheckRepTable('CustSetting') = 1 
		  AND dbo.f_CheckRepTable('CustOverride') = 1 
		  AND dbo.f_CheckRepTable('CustSetting3rd') = 1 
		  AND dbo.f_CheckRepTable('CustOverride3rd') = 1 
		  AND dbo.f_CheckRepTable('CustSettingGame') = 1 
		  AND dbo.f_CheckRepTable('CustOverrideGame') = 1
		  AND dbo.f_CheckRepTable('CustGameType') = 1		 
		  AND dbo.f_CheckRepTable('AgentCommRate') = 1		 
	   )
	BEGIN	
		-- insert custSetting info
		INSERT INTO dbo.custSetting
		SELECT
			@Custid
			,bettype
			,sporttype
			,apositiontaking
			,mpositiontaking
			,spositiontaking
			,alivepositiontaking
			,mlivepositiontaking
			,slivepositiontaking
			,playerdiscount
			,discount
			,adiscount
			,sdiscount
			,groupa
			,groupb
			,groupc
			,groupd
			,groupe
			,groupf
			,minbet
			,maxbet
			,autopositiontaking
			,autolivepositiontaking
			,isautopositiontaking
			,isautolivepositiontaking
			,autompositiontaking
			,autolivempositiontaking
			,isautompositiontaking
			,isautolivempositiontaking	
		FROM dbo.custSetting WITH(NOLOCK)
		WHERE custid=@ExistingCustid
		AND Sporttype NOT IN(151,152,153,154,162,252,253,201)

		IF @@error <> 0
		BEGIN 	
			SELECT @ErrCode = 107
			RETURN				
		END
		
		-- insert custSetting3rd info
		INSERT INTO dbo.CustSetting3rd
		SELECT
			@Custid
			,bettype
			,sporttype
			,apositiontaking
			,mpositiontaking
			,spositiontaking
			,playerdiscount
			,discount
			,adiscount
			,sdiscount
			,minbet
			,maxbet
			,autopositiontaking
			,isautopositiontaking
			,autompositiontaking
			,isautompositiontaking
			,alivepositiontaking
			,mlivepositiontaking
			,slivepositiontaking
			,autolivepositiontaking
			,isautolivepositiontaking
			,autolivempositiontaking
			,isautolivempositiontaking
		FROM dbo.CustSetting3rd WITH(NOLOCK)
		WHERE custid=@ExistingCustid
		AND Sporttype NOT IN(151,152,153,154,162,252,253,201)

		IF @@error <> 0
		BEGIN 	
			SELECT @ErrCode = 108
						
			-- ROLLBACK MANUALLY	
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			RETURN
		END	
		
		-- insert custoverride info
		INSERT INTO [dbo].[custoverride]
			([custid], 
			[bettype], 
			[sporttype], 
			minpositiontaking, 
			maxpositiontaking, 
			minlivepositiontaking, 
			maxlivepositiontaking)
		SELECT @Custid, 
			bettype, 
			sporttype, 
			minpositiontaking, 
			maxpositiontaking, 
			minlivepositiontaking, 
			maxlivepositiontaking
		FROM dbo.custOverride WITH(NOLOCK)
		WHERE custid=@ExistingCustid
				AND Sporttype NOT IN(151,152,153,154,162,252,253,201)

		if @@error <> 0
		BEGIN
			--Error occur
			SELECT @ErrCode = 109
				
			-- ROLLBACK MANUALLY	
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID				
			
			RETURN
		END	
		
		-- insert custoverride3rd info
		INSERT INTO [dbo].[custoverride3rd]
			([custid], 
			[bettype], 
			[sporttype], 
			minpositiontaking, 
			maxpositiontaking, 
			minlivepositiontaking, 
			maxlivepositiontaking)
		SELECT @Custid, 
			bettype, 
			sporttype, 
			minpositiontaking, 
			maxpositiontaking, 
			minlivepositiontaking, 
			maxlivepositiontaking
		FROM dbo.custOverride3rd WITH(NOLOCK)
		WHERE custid=@ExistingCustid
				AND Sporttype NOT IN(151,152,153,154,162,252,253,201)
		IF @@error <> 0
		BEGIN
			--Error occur
			SELECT @ErrCode = 110
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			
			RETURN
		END
	
		
		--- insert into CustSettingGame
		INSERT INTO custsettingGame
			(CustID, 
			Bettype, 
			Sporttype, 
			apositiontaking, 
			mpositiontaking, 
			spositiontaking, 
			playerdiscount, 
			discount, 
			adiscount, 
			sdiscount, 
			autopositiontaking, 
			isautopositiontaking, 
			autompositiontaking, 
			isautompositiontaking)
		SELECT 
			@custid, 
			Bettype, 
			Sporttype, 
			apositiontaking, 
			mpositiontaking, 
			spositiontaking, 
			playerdiscount, 
			discount, 
			adiscount, 
			sdiscount, 
			autopositiontaking, 
			isautopositiontaking, 
			autompositiontaking, 
			isautompositiontaking
		FROM custsettingGame WITH(NOLOCK)
		WHERE custid = @ExistingCustid
				AND Sporttype NOT IN(151,152,153,154,162,252,253,201)
		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 113
				
			-- ROLLBACK MANUALLY				
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			
			RETURN
		END

		--- insert into Custoverridegame
		INSERT INTO Custoverridegame(CustID, Bettype, Sporttype, minpositiontaking)
		SELECT @CustID, Bettype, Sporttype, minpositiontaking
		FROM Custoverridegame WITH(NOLOCK)
		WHERE custid = @ExistingCustid
			AND Sporttype NOT IN(151,152,153,154,162,252,253,201)

		if @@error <> 0
		BEGIN
			--Error occur
			SELECT @ErrCode = 114
				
			-- ROLLBACK MANUALLY		
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID

			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
						
			RETURN
		END	

		--Keno, Gold Deluxe
		INSERT INTO dbo.CustGameType(GameTypeID, Custid, MinBet, MaxBet, MaxPerGameType, IsDisabled, StakeLevelList)
		SELECT	GameTypeID, @CustID, MinBet, MaxBet, MaxPerGameType, IsDisabled, StakeLevelList
		FROM	dbo.CustGameType WITH(NOLOCK)
		WHERE	Custid = @ExistingCustid
				
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 156
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
				
			RETURN
		END
		--End Keno
		
		-- Myanmar Odds
		DECLARE @IsMyanmarOdds BIT = 0
		SET @IsMyanmarOdds = dbo.fn_IsMyanmarOdds (@ExistingCustid)

		IF @IsMyanmarOdds = 1
			INSERT INTO dbo.AgentCommRate (CustID,SportType,BetType,CommRate) 
			SELECT @custid, SportType, Bettype, CommRate
			FROM AgentCommRate WITH (NOLOCK)
			WHERE CustId = @ExistingCustid
		ELSE
		INSERT INTO dbo.AgentCommRate (CustID,SportType,BetType,CommRate) 
		SELECT @custid, SportType, Bettype, CommRate
		FROM AgentCommRate WITH (NOLOCK)
		WHERE CustId = @ExistingCustid AND Sporttype <> 1 AND Bettype <> 1 

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 157
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 

			RETURN
		END	
		
		-- Parlay Max Payout
		DECLARE @RoleID TINYINT ,@SuperID INT, @MasterID INT, @AgentID INT
		SELECT @RoleID = roleid , @SuperID = srecommend , @MasterID = mrecommend , @AgentID = recommend
		FROM Customer WITH (NOLOCK) WHERE custid = @CustID	
		
		IF @RoleID  = 4 
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					cs.SingleMatchParlay,
					cs.Combo2,
					cs.Combo35,
					cs.ComboOver6
			FROM dbo.CustMaxPayoutSetting_Agent cs  WITH(NOLOCK)
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
			WHERE cs.CustID  = @ExistingCustid  AND Upl.CustID = @MasterID
		END
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 157
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 
			DELETE dbo.CustMaxPayoutSetting_Agent WITH(ROWLOCK) WHERE custid = @CustID 
			RETURN
		END	
		
		IF @RoleID  = 1
		BEGIN
			INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
			SELECT @custid , cs.SportType, cs.BetType, 
					CASE WHEN cs.SingleMatchParlay > upl.SingleMatchParlay  AND upl.SingleMatchParlay > 0 THEN upl.SingleMatchParlay ELSE cs.SingleMatchParlay END AS SingleMatchParlay,
					CASE WHEN cs.Combo2 > upl.Combo2  AND upl.Combo2 > 0 THEN upl.Combo2 ELSE cs.Combo2 END AS Combo2,
					CASE WHEN cs.Combo35 > upl.Combo35  AND upl.Combo35 > 0 THEN upl.Combo35 ELSE cs.Combo35 END AS Combo35,
					CASE WHEN cs.ComboOver6 > upl.ComboOver6  AND upl.ComboOver6 > 0 THEN upl.ComboOver6 ELSE cs.ComboOver6 END AS ComboOver6
			FROM dbo.CustMaxPayoutSetting_Member cs WITH (NOLOCK)
			INNER JOIN dbo.CustMaxPayoutSetting_Agent upl WITH (NOLOCK) ON cs.SportType = upl.SportType AND cs.BetType = upl.BetType
			WHERE cs.CustID  = @ExistingCustid  AND Upl.CustID = @AgentID
		END
		
		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 157
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 
			DELETE dbo.CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE custid = @CustID 
			RETURN
		END	
	END

	DECLARE @DCSErrCode INT = 0
	
	/*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
				EXEC dbo.Acc_DynamicCustomerInfo_02
			@CustID				= @CustID
			, @ExistingCustid	= @ExistingCustid
			, @SettingStatus    = @SettingStatus
			, @ErrCode			= @DCSErrCode OUTPUT
			
	IF @DCSErrCode <> 0 
	BEGIN
		--Error Occurs
		SELECT @ErrCode = 911
		
		-- ROLLBACK MANUALLY
		IF(dbo.f_CheckRepTable('CustSetting') = 1) DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
		IF(dbo.f_CheckRepTable('custsetting3rd') = 1) DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
		IF(dbo.f_CheckRepTable('custoverride') = 1) DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
		IF(dbo.f_CheckRepTable('custoverride3rd') = 1) DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
	
		IF(dbo.f_CheckRepTable('custsettingGame') = 1) DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		IF(dbo.f_CheckRepTable('CustGameType') = 1) DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
		IF(dbo.f_CheckRepTable('AgentCommRate') = 1) DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
END
GO
