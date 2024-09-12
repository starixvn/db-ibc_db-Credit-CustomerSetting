/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustProductStatus_Insert
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

			DECLARE @tmp_Dep_CustProductStatusH TABLE 
			(	
				rID					BIGINT NOT NULL
				,CustID				INT NOT NULL
				,bitmapIsHidden		BINARY(32)
				,bitmapIsDisabled	BINARY(32)
				,UpdateTime			DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustProductStatusH ( rID ,CustID ,bitmapIsHidden ,bitmapIsDisabled	,UpdateTime)
			SELECT rid ,cid, bih ,bid ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,bih	BINARY(32)
					,bid	BINARY(32)
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustProductStatusH

			INSERT INTO Dep_CustProductStatus_History ( rID ,CustID ,bitmapIsHidden ,bitmapIsDisabled ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,bitmapIsHidden ,bitmapIsDisabled ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustProductStatusH

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