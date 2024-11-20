/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustDiscount3rd_Agent_History_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241119@Louisa
	 Task:  Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#212684]
*/
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustDiscount3rd_AgentH TABLE 
			(	
				rID			BIGINT
				,UpdateTime	DATETIME
				,CustID		INT
				,SportType	SMALLINT
				,BetType	SMALLINT
				,Discount	DECIMAL
			)
		
			INSERT INTO @tmp_CustDiscount3rd_AgentH ( rID,UpdateTime,CustID	,SportType,BetType,Discount)
			SELECT  rid,ud ,cid  ,s ,bt ,dis
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,ud		DATETIME
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,dis	DECIMAL
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustDiscount3rd_AgentH

			INSERT INTO CustDiscount3rd_Agent_History ( rID,UpdateTime,CustID	,SportType,BetType ,Discount, SiteDBGroupID)
			SELECT  rid,ud ,cid  ,s ,bt ,dis, @SiteDBGroupID
			FROM @tmp_CustDiscount3rd_AgentH

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
