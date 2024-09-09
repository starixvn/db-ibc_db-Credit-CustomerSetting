/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerInsSetting_Rollback 
	  @CustID INT,
	  @RoleID TINYINT 
AS
/*
	Created: 20240605@Eden
	Task : Rollback Credit Customer Setting for New accounts when failed 
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		
	Param's Explanation:

	Examples:
		EXEC Acc_CustomerInsSetting_Rollback @CustID = xxx ,@RoleID = 2
	*/
BEGIN
	SET NOCOUNT ON
	
	DELETE FROM VRCustSetting				WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM VRSettingManualUpdAcc		WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM VRCustLockStatus			WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM CustVirtualSetting			WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM CustLimitPTSetting			WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM SuspiciousCust				WITH (ROWLOCK) WHERE CustID = @CustID
	DELETE FROM CustProductStatus			WITH (ROWLOCK) WHERE CustID = @CustID

	IF @RoleID IN (2,3,4)
	BEGIN			
		DELETE FROM CustPTSetting3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID					
		DELETE FROM CustDiscount3rd_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustWinLossLimit_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustStakeLevel_Agent		WITH (ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaxPayoutSetting_Agent	WITH (ROWLOCK) WHERE CustID = @CustID

		--Inhouse Tables
		DELETE c
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
		INTO BetSetting3rd_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting3rd_Agent c WITH(ROWLOCK) 
		WHERE CustID = @CustID

		DELETE c
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
		INTO BetSetting_Agent_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting_Agent c WITH(ROWLOCK) 
		WHERE CustID = @CustID
	END
	ELSE IF @RoleID = 1
	BEGIN
		DELETE FROM CustSettingMode3rd			WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustQRCode					WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustPTSetting3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustBetSetting3rd_Member	WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustDiscount3rd_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustWinLossLimit_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustStakeLevel_Member		WITH(ROWLOCK) WHERE CustID = @CustID
		DELETE FROM CustMaxPayoutSetting_Member WITH(ROWLOCK) WHERE CustID = @CustID

		--Inhouse Tables
		DELETE c
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
		INTO BetSetting3rd_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting3rd_Member c WITH(ROWLOCK) 
		WHERE CustID = @CustID


		DELETE c
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, dbo.f_GetDateTime2() 
		INTO BetSetting_Member_Del_Inhouse(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting_Member c WITH(ROWLOCK) 
		WHERE CustID = @CustID
	END
END