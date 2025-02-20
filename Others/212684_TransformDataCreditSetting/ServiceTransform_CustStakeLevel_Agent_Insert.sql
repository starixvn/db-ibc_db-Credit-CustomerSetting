/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustStakeLevel_Agent_Insert
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

			DECLARE @tmp_CustStakeLevel_Agent TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL				
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL	
				,StakeLevelList	VARCHAR(200)
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustStakeLevel_Agent ( rID ,CustID, SportType, Bettype, StakeLevelList, UpdateTime)
			SELECT rid ,cid , s, bt, stl, ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT	
					,s		SMALLINT 
					,bt		SMALLINT
					,stl	VARCHAR(200)														
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustStakeLevel_Agent

			INSERT INTO CustStakeLevel_Agent_History ( rID ,CustID, SportType, Bettype, StakeLevelList, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID, SportType, Bettype, StakeLevelList, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustStakeLevel_Agent

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