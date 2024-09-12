/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustSettingMode_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20240723@Louisa
	 Task: Deposit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#207025]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#207025]
*/
BEGIN
	SET XACT_ABORT ON

	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_Dep_CustSettingModeH TABLE 
			(	
				rID					 BIGINT NOT NULL
				,CustID				 INT NOT NULL
				,IsGroupedPT		 BIT
				,IsGroupedComm		 BIT
				,IsGroupedBetLimit	 BIT
				,IsGroupedStakeLevel BIT
				,UpdateTime			 DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustSettingModeH ( rID ,CustID ,IsGroupedPT ,IsGroupedComm	,IsGroupedBetLimit	,IsGroupedStakeLevel ,UpdateTime)
			SELECT rid ,cid ,igpt ,igc ,igbl ,igsl ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,igpt	BIT
					,igc	BIT
					,igbl	BIT
					,igsl	BIT
					,ut		DATETIME
				)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustSettingModeH

			INSERT INTO Dep_CustSettingMode_History ( rID ,CustID ,IsGroupedPT ,IsGroupedComm	,IsGroupedBetLimit	,IsGroupedStakeLevel ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,IsGroupedPT ,IsGroupedComm	,IsGroupedBetLimit	,IsGroupedStakeLevel ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustSettingModeH

			UPDATE Dest_ServiceTransform
			SET rID = @MaxID
			WHERE TableName = @TableName
				AND SiteDBGroupID = @SiteDBGroupID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR
		SET @ErrorMessage = ERROR_MESSAGE()

		ROLLBACK TRANSACTION
		RETURN
	END CATCH


END
GO