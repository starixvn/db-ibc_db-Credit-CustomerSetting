ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_02]
	@custid INT =0,
	@ExistingCustid INT = 0,
	@Language VARCHAR(3) = 'E',
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(500) = '' OUTPUT
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
	Parameter's Explanation:
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
		
		--Insert Into P2P Setting
		IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1)
			INSERT INTO  dbo.P2PGameSetting WITH(ROWLOCK)
				(custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5)
			SELECT @custId,bettype,StakeLevel1,StakeLevel2,StakeLevel3,StakeLevel4,StakeLevel5	
			FROM dbo.P2PGameSetting WITH(NOLOCK)
			WHERE custid=@ExistingCustid	

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 111
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
						
			RETURN
		END

		--insert P2PGroupComm
		IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) 
			INSERT INTO dbo.P2PGroupComm WITH(ROWLOCK)
			(custId,groupID,sdiscount,adiscount,discount,playerdiscount)
			SELECT @custid,groupID,sdiscount,adiscount,discount,playerdiscount
			FROM dbo.P2PGroupComm
			WHERE custid  = @ExistingCustid  

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 112
				
			-- ROLLBACK MANUALLY			
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID
			
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

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 113
				
			-- ROLLBACK MANUALLY				
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
			IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID

			RETURN
		END

		--- insert into Custoverridegame
		INSERT INTO Custoverridegame(CustID, Bettype, Sporttype, minpositiontaking)
		SELECT @CustID, Bettype, Sporttype, minpositiontaking
		FROM Custoverridegame WITH(NOLOCK)
		WHERE custid = @ExistingCustid

		if @@error <> 0
		BEGIN

			--Error occur
			SELECT @ErrCode = 114
				
			-- ROLLBACK MANUALLY		
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
			IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
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
			IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
			IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
				
			RETURN
		END
		--End Keno

		--Colossus Bet, Myanmar Odds
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
			WHERE CustId = @ExistingCustid AND Sporttype <> 1 AND Bettype <> 301 

		IF @@ERROR <> 0
		BEGIN
			--Error Occurs
			SELECT @ErrCode = 157
				
			-- ROLLBACK MANUALLY
			DELETE FROM dbo.CustSetting WITH(ROWLOCK) WHERE CustID = @CustID
			DELETE FROM custsetting3rd WITH (ROWLOCK) WHERE custid =  @CustID		
			DELETE FROM custoverride WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custoverride3rd WITH (ROWLOCK) WHERE custid =  @CustID
			IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
			IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
			DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
			DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
			DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 

			RETURN
		END
	END

	DECLARE @DCSErrCode INT = 0
	
	/*DOMINIC-CUSTOMER SETTING RENOVATION-START*/
				EXEC dbo.Acc_DynamicCustomerInfo_02
			@CustID				= @CustID
			, @ExistingCustid	= @ExistingCustid
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
		IF(dbo.f_CheckRepTable('P2PGAMESETTING') = 1) DELETE FROM P2PGameSetting WITH (ROWLOCK) WHERE custid =  @CustID					
		IF(dbo.f_CheckRepTable('P2PGroupComm') = 1) DELETE FROM P2PGroupComm WITH (ROWLOCK) WHERE custid =  @CustID
		IF(dbo.f_CheckRepTable('custsettingGame') = 1) DELETE FROM custsettingGame with (ROWLOCK) where custid = @CustID
		IF(dbo.f_CheckRepTable('CustGameType') = 1) DELETE dbo.CustGameType WITH(ROWLOCK) WHERE custid = @custid 
		IF(dbo.f_CheckRepTable('AgentCommRate') = 1) DELETE dbo.AgentCommRate WITH(ROWLOCK) WHERE custid = @CustID 
	END
	/*DOMINIC-CUSTOMER SETTING RENOVATION-END*/
END
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerInfo_Execrep_02] TO [vnteam] AS [dbo]