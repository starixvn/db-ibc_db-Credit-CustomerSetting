SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_DCSSettingCopyInsert] 
	@CustID				INT		= 0
	, @ExistingCustID	INT		= 0
	, @ErrCode			INT		= 0		OUTPUT
AS
/*
	Created: 20150928@Dominic
	Task : Copy Insert Settings of an existing S/M/A Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	
	Revision

	*/
BEGIN
	IF @ExistingCustID = 0 RETURN
	
	SELECT @ErrCode = 0
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustPTSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
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
			   ,[MaxPT]
			FROM [dbo].[CustPTSetting3rd_Agent] WITH(NOLOCK)
			WHERE CustID = @ExistingCustID
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 1
		
		DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID
		
		RETURN
	END CATCH
	
	/********************************************* Bet Limit : SettingType = 2 ****************************************/
	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustBetSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
		INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
		SELECT		@CustID
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch]
		FROM [dbo].[CustBetSetting3rd_Agent]
		WHERE CustID = @ExistingCustID
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 2
		
		DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
		DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
		
		RETURN
	END CATCH
	
	/********************************************* Commision : SettingType = 3 ****************************************/
	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
		INSERT INTO [dbo].[CustDiscount3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[Discount])
		SELECT		@CustID
				   ,[SportType]
				   ,[BetType]
				   ,[Discount]
		FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK)
		WHERE CustID = @ExistingCustID
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 3
		
		DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
		DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
		DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		
		RETURN
	END CATCH
	/********************************************* Product Status: SettingType = 4 ************************************/
	--Get sporttype/Bettype for this setting type
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM [dbo].[CustProductStatus] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
		BEGIN
			INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced )
			SELECT @CustID,cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced
			FROM [dbo].[CustProductStatus] cs WITH(NOLOCK)
			WHERE CustID = @ExistingCustID
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 4
		
		DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
		DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID	
		DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		DELETE FROM CustProductStatus WHERE CustID = @CustID
		
		RETURN
	END CATCH

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DCSSettingInsert] TO [bodbExtAccNet]