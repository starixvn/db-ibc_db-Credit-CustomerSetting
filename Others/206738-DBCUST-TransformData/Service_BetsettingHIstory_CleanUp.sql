/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Service_BetsettingHistory_CleanUp] 
	@TableName		VARCHAR(200)
	,@BatchSize		INT
	,@rID			BIGINT
AS
/*
	 Created by: 20240628@Louisa
	 Task: Clean data in table betsetting_XX_History [Redmine:#204370]
	 DB: DBCUST-CustDB_History

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#204370]
		- 20240628@Louisa: transform historial data - 16 tables Deposite [Redmine:#207025]
*/

BEGIN
	DECLARE @DeleteDate		DATETIME
		,@rID_Deleted		BIGINT

	SET @DeleteDate = DATEADD(DAY,-3,GETDATE())
-------------------------------------------------------------
	IF @TableName = 'BetSetting_Member_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.BetSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.BetSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.BetSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'

		END	
	END

	IF @TableName = 'BetSetting_Agent_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.BetSetting_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.BetSetting_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.BetSetting_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END

	IF @TableName = 'BetSetting3rd_Member_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.BetSetting3rd_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.BetSetting3rd_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.BetSetting3rd_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	
	END

	IF @TableName = 'BetSetting3rd_Agent_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.BetSetting3rd_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.BetSetting3rd_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.BetSetting3rd_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END

-------------------------------------------------------------

	IF @TableName = 'Dep_CustBetSetting_Agent_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustBetSetting_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustBetSetting_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustBetSetting_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END

	IF @TableName = 'Dep_CustBetSetting_Member_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustBetSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustBetSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustBetSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
			
	IF @TableName = 'Dep_CustBetSettingGame_Agent_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustBetSettingGame_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustBetSettingGame_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustBetSettingGame_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
						
	IF @TableName = 'Dep_CustBetSettingGame_Member_History'		
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustBetSettingGame_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustBetSettingGame_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustBetSettingGame_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
						
	IF @TableName = 'Dep_CustBetSettingGameGroup_Member_History' 	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustBetSettingGameGroup_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustBetSettingGameGroup_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustBetSettingGameGroup_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
			
	IF @TableName = 'Dep_CustDiscountSetting_Agent_History'		
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustDiscountSetting_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustDiscountSetting_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustDiscountSetting_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END	
	
	IF @TableName = 'Dep_CustDiscountSetting_Member_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustDiscountSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustDiscountSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustDiscountSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END	
		
	IF @TableName = 'Dep_CustDiscountGroupSetting_Member_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustDiscountGroupSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustDiscountGroupSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustDiscountGroupSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END	
	
	IF @TableName = 'Dep_CustProductStatus_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustProductStatus_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustProductStatus_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustProductStatus_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
	
	IF @TableName = 'Dep_CustPTGroupSetting_Member_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustPTGroupSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustPTGroupSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustPTGroupSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
					
	IF @TableName = 'Dep_CustPTSetting_Member_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustPTSetting_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustPTSetting_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustPTSetting_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
			
	IF @TableName = 'Dep_CustPTSetting_Agent_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustPTSetting_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustPTSetting_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustPTSetting_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END			
	
	IF @TableName = 'Dep_CustSettingGame_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustSettingGame_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustSettingGame_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustSettingGame_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END			
			
	IF @TableName = 'Dep_CustSettingMode_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustSettingMode_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustSettingMode_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustSettingMode_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END			
			
	IF @TableName = 'Dep_CustStakeLevel_Agent_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustStakeLevel_Agent_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustStakeLevel_Agent_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustStakeLevel_Agent_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END						
					
	IF @TableName = 'Dep_CustStakeLevel_Member_History'	
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.Dep_CustStakeLevel_Member_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.Dep_CustStakeLevel_Member_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.Dep_CustStakeLevel_Member_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END		
					
	IF @TableName = 'VRCustLockStatus_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.VRCustLockStatus_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.VRCustLockStatus_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.VRCustLockStatus_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END

	IF @TableName = 'CustVirtualSetting_History'
	BEGIN
		SELECT @rID_Deleted = 0

		SELECT  @rID_Deleted = MAX(rID) 
		FROM dbo.CustVirtualSetting_History  WITH (NOLOCK) 
		WHERE UpdateTime < @DeleteDate AND rID < @rID
		
		IF ISNULL(@rID_Deleted,0) = 0
		RETURN

		WHILE EXISTS (SELECT 1 FROM dbo.CustVirtualSetting_History WITH (NOLOCK) WHERE rID <= @rID_Deleted) 
		BEGIN
			DELETE TOP (@BatchSize)
			FROM dbo.CustVirtualSetting_History WITH (UPDLOCK, ROWLOCK)
			WHERE rID <= @rID_Deleted

			WAITFOR DELAY '00:00:00.005'
		END	

	END
END
GO