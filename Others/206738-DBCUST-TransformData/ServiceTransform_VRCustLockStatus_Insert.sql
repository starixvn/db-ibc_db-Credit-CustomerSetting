/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_VRCustLockStatus_Insert
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
			DECLARE @tmpVRCustLockStatusH TABLE 
			(	rID			BIGINT NOT NULL					
				,CustID		INT NOT NULL
				,Type		TINYINT NOT NULL
				,UpdateTime	DATETIME NOT NULL
				,IsLocked	BIT NOT NULL
			)
		
			INSERT INTO @tmpVRCustLockStatusH ( rID ,CustID ,Type ,UpdateTime ,IsLocked)
			SELECT rid ,cid ,t, ut, il	
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,t		TINYINT
					,ut		DATETIME
					,il		BIT
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmpVRCustLockStatusH

			INSERT INTO VRCustLockStatus_History (rID ,CustID ,Type ,UpdateTime,IsLocked, SiteDBGroupID)
			SELECT  rID ,CustID ,Type ,UpdateTime ,IsLocked ,@SiteDBGroupID
			FROM @tmpVRCustLockStatusH

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