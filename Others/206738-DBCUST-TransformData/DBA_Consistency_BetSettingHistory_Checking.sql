/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE DBA_Consistency_BetSettingHistory_Checking
(
	@TableName			VARCHAR(200)
	,@LastRID			BIGINT
	,@CheckingTime		INT		--minutes
	,@ErrCode			INT				= 0		OUTPUT
	,@ErrMsg			VARCHAR(MAX)	= ''	OUTPUT
	,@SampleData		VARCHAR(MAX)	= ''	OUTPUT
)
AS
/*
	 Created by: 20240628@Louisa
	 Task: Monitor sync data from CustDB_History to DBTP slowly [Redmine:#204370]
	 DB: DBCUST-CustDB_History

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#204370]
		- 20240628@Louisa: transform historial data - 16 tables Deposite [Redmine:#207025]
		- 20240812@Louisa: Virtual Rate tables [Redmine:#207029]
*/
BEGIN
	
	SET NOCOUNT ON

	DECLARE @UpdateTime		DATETIME	
			,@CurrentTime	DATETIME	 = GETDATE()
			,@ServerName	VARCHAR(100) = @@SERVERNAME
			,@DBName		VARCHAR(50)  = DB_NAME()
	
	IF @TableName = 'BetSetting_Member_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM BetSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
	
	IF @TableName = 'BetSetting_Agent_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM BetSetting_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'BetSetting3rd_Member_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM BetSetting3rd_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )


	IF @TableName = 'BetSetting3rd_Agent_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM BetSetting3rd_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'VRCustLockStatus_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM VRCustLockStatus_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'CustVirtualSetting_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM CustVirtualSetting_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	--------------------------------------------------------------------------------
	IF @TableName = 'Dep_CustBetSetting_Agent_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustBetSetting_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustBetSetting_Member_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustBetSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustBetSettingGame_Agent_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustBetSettingGame_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustBetSettingGame_Member_History'		
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustBetSettingGame_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustBetSettingGameGroup_Member_History' 	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
					FROM Dep_CustBetSettingGameGroup_Member_History WITH (NOLOCK) 
					WHERE rID> @LastRID
					ORDER BY rID )
	
	IF @TableName = 'Dep_CustDiscountSetting_Agent_History'		
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustDiscountSetting_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustDiscountSetting_Member_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustDiscountSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
	
	IF @TableName = 'Dep_CustDiscountGroupSetting_Member_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustDiscountGroupSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustProductStatus_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustProductStatus_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustPTGroupSetting_Member_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustPTGroupSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
				
	IF @TableName = 'Dep_CustPTSetting_Member_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustPTSetting_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
		
	IF @TableName = 'Dep_CustPTSetting_Agent_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustPTSetting_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	IF @TableName = 'Dep_CustSettingGame_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustSettingGame_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
		
	IF @TableName = 'Dep_CustSettingMode_History'
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustSettingMode_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
		
	IF @TableName = 'Dep_CustStakeLevel_Agent_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustStakeLevel_Agent_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )
				
	IF @TableName = 'Dep_CustStakeLevel_Member_History'	
	SET @UpdateTime = ( SELECT TOP(1) UpdateTime 
						FROM Dep_CustStakeLevel_Member_History WITH (NOLOCK) 
						WHERE rID> @LastRID
						ORDER BY rID )

	--------------------------------------------------------------------------------

	IF @UpdateTime IS NOT NULL AND DATEDIFF(MINUTE, @UpdateTime, @CurrentTime) > @CheckingTime
	BEGIN
		SELECT @ErrCode = 100
				,@ErrMsg = @ServerName + '.' +@DBName + 'dbo.' +@TableName + ' synchronize to DBTP is slowly or pending over ' + CAST( @CheckingTime AS VARCHAR(2) ) + ' minutes(s).'
				,@SampleData = 'SELECT TOP(100) rID, CustID FROM dbo.' + @TableName+ ' WITH(NOLOCK) WHERE UpdateTime >= ' + CONVERT(VARCHAR(50), @UpdateTime, 120)
	END
 
END
GO