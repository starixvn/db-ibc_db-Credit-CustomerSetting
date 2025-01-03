/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustStakeLevel_Member_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20250103@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20250103@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustStakeLevel_Member TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL				
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL	
				,StakeLevelList	VARCHAR(200)
				,LastUpdated DATETIME
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustStakeLevel_Member ( rID ,CustID, SportType, Bettype, StakeLevelList, LastUpdated, UpdateTime)
			SELECT rid ,cid , s, bt, stl, lu, ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT	
					,s		SMALLINT 
					,bt		SMALLINT
					,stl	VARCHAR(200)
					,lu		DATETIME
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustStakeLevel_Member

			INSERT INTO CustStakeLevel_Member_History ( rID ,CustID, SportType, Bettype, StakeLevelList, LastUpdated, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID, SportType, Bettype, StakeLevelList, LastUpdated, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustStakeLevel_Member

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