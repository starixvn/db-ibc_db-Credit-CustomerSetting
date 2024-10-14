/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsSetting_Rollback] 
	  @CustID INT,
	  @RoleID TINYINT 
AS
/*
	Created: 20240605@Eden
	Task : Rollback Customer Setting for New accounts when failed
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		- 20240701@Winfred: Scale Out DBCUST - Apply In-house Replication for Virtual Rate Setting  [redmine: #207029]
		
	Param's Explanation:

	Examples:
		EXEC Acc_CustomerInsSetting_Rollback @CustID = xxx ,@RoleID = 2
	*/
BEGIN
	SET NOCOUNT ON
	
	--Inhouse Tables
	--DELETE FROM VRCustLockStatus WITH(ROWLOCK) WHERE custid = @CustID
	--DELETE FROM CustVirtualSetting WITH(ROWLOCK) WHERE custId = @CustID
	--DELETE FROM VRCustSetting	WITH (ROWLOCK) WHERE CustID = @CustID
	--DELETE FROM VRSettingManualUpdAcc WITH (ROWLOCK) WHERE CustID = @CustID

	DELETE c
	OUTPUT deleted.custid, deleted.seqNo, [dbo].[f_GetDateTime2]() 
	INTO CustVirtualSetting_Del_Inhouse(custid,seqNo,RepUpdateTime)
	FROM CustVirtualSetting c WITH(ROWLOCK) 
	WHERE CustID = @CustID

	DELETE c
	OUTPUT deleted.custid, deleted.Type, [dbo].[f_GetDateTime2]() 
	INTO VRCustLockStatus_Del_Inhouse(custid,Type,RepUpdateTime)
	FROM VRCustLockStatus c WITH(ROWLOCK) 
	WHERE CustID = @CustID

	DELETE c
	OUTPUT deleted.custid, deleted.LevelID, [dbo].[f_GetDateTime2]() 
	INTO VRCustSetting_Del_Inhouse(custid,LevelID,RepUpdateTime)
	FROM VRCustSetting c WITH(ROWLOCK) 
	WHERE CustID = @CustID

	DELETE c
	OUTPUT deleted.custid, deleted.SportType, [dbo].[f_GetDateTime2]() 
	INTO VRSettingManualUpdAcc_Del_Inhouse(custid,SportType,RepUpdateTime)
	FROM VRSettingManualUpdAcc c WITH(ROWLOCK) 
	WHERE CustID = @CustID

	DELETE FROM CustLimitPTSetting			WITH (ROWLOCK) WHERE CustID = @CustID
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
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, SYSDATETIME() 
		INTO BetSetting3rd_Agent_Del(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting3rd_Agent c WITH(ROWLOCK) 
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
		OUTPUT deleted.CustID, deleted.Sporttype, deleted.BetType, SYSDATETIME() 
		INTO BetSetting3rd_Member_Del(CustID,Sporttype,Bettype,RepUpdateTime)
		FROM BetSetting3rd_Member c WITH(ROWLOCK) 
		WHERE CustID = @CustID
	END
END