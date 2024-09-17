/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustVirtualSetting_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID	SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20240628@Louisa
	 Task: init [Redmine:#204370]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#204370]
*/
BEGIN
	SET XACT_ABORT ON

	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT
			DECLARE @tmpCustVirtualSettingH TABLE 
			(	rID				BIGINT NOT NULL
				,UpdateTime		DATETIME NOT NULL	
				,custid			INT NOT NULL
				,seqNo			TINYINT NOT NULL
				,bitmapVirtual	BINARY(64) NOT NULL
			)
		
			INSERT INTO @tmpCustVirtualSettingH ( rID ,UpdateTime ,custid ,seqNo ,bitmapVirtual)
			SELECT rid ,ut ,cid ,sq ,bv
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,ut 	DATETIME
					,cid 	INT
					,sq 	TINYINT
					,bv		BINARY(64)
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmpCustVirtualSettingH

			INSERT INTO CustVirtualSetting_History ( rID ,UpdateTime ,custid ,seqNo	,bitmapVirtual ,SiteDBGroupID)
			SELECT rID ,UpdateTime ,custid ,seqNo ,bitmapVirtual, @SiteDBGroupID
			FROM @tmpCustVirtualSettingH

			UPDATE Dest_ServiceTransform 
			SET rID = @MaxID
			WHERE TableName = @TableName
				AND SiteDBGroupID  = @SiteDBGroupID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

		SET @ErrorCode = @@ERROR
		SET @ErrorMessage = ERROR_MESSAGE()

		ROLLBACK TRANSACTION
	END CATCH


END
GO