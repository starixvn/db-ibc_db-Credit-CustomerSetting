/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustDiscount3rd_Member_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241224@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20241224@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustDiscount3rd_Member TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,PlayerDiscount DECIMAL(9,8) NULL
				,AgentDiscount DECIMAL(9,8) NULL
				,MasterDiscount DECIMAL(9,8) NULL
				,SuperDiscount	DECIMAL(9,8) NULL				
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustDiscount3rd_Member ( rID ,CustID ,SportType ,BetType , PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount ,UpdateTime)
			SELECT rid ,cid ,s ,bt ,pdis ,adis ,mdis ,sdis ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,pdis	DECIMAL(9,8)					
					,adis	DECIMAL(9,8)					
					,mdis	DECIMAL(9,8)					
					,sdis	DECIMAL(9,8)					
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustDiscount3rd_Member

			INSERT INTO CustDiscount3rd_Member_History ( rID ,CustID ,SportType ,BetType , PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,SportType ,BetType ,PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount ,UpdateTime, @SiteDBGroupID
			FROM @tmp_CustDiscount3rd_Member

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