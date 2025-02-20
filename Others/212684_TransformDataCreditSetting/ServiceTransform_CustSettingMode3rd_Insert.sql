/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustSettingMode3rd_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20250102@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20250102@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustSettingMode3rd TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID	INT NOT NULL				
				,IsGrouped	BIT NOT NULL						
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustSettingMode3rd ( rID ,CustID, IsGrouped, UpdateTime)
			SELECT rid ,cid , isg, ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT					
					,isg	BIT										
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustSettingMode3rd

			INSERT INTO CustSettingMode3rd_History ( rID ,CustID, IsGrouped, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID, IsGrouped, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustSettingMode3rd

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