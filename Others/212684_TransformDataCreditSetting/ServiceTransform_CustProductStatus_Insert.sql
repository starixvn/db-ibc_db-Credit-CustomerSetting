/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustProductStatus_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241227@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20241227@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustProductStatus TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,bitmapHasSynced	BINARY(32) NOT NULL
				,bitmapIsHidden	BINARY(32) NOT NULL
				,bitmapIsDisabled	BINARY(32) NOT NULL
				,SuspendInfo TINYINT
				,Locked	TINYINT
				,CloseInfo	TINYINT			
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustProductStatus ( rID, CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, Locked, CloseInfo ,UpdateTime)
			SELECT rid ,cid ,bsync ,bhidden ,bdis ,sus ,lck ,clo ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,bsync	BINARY(32)
					,bhidden BINARY(32)
					,bdis	BINARY(32)
					,sus	TINYINT
					,lck	TINYINT	
					,clo	TINYINT
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustProductStatus

			INSERT INTO CustProductStatus_History ( rID ,CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, Locked, CloseInfo, UpdateTime, SiteDBGroupID)
			SELECT  rID, CustID, bitmapHasSynced, bitmapIsHidden, bitmapIsDisabled, SuspendInfo, Locked, CloseInfo,UpdateTime, @SiteDBGroupID
			FROM @tmp_CustProductStatus

			UPDATE Dest_ServiceTransform
			SET rID = @MaxID,
				UpdateTime = GETDATE()
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