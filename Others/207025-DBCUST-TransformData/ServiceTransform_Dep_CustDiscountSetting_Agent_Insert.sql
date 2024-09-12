/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustDiscountSetting_Agent_Insert
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

			DECLARE @tmp_Dep_CustDiscountSetting_AgentH TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,Discount	DECIMAL(9,8) NOT NULL
				,UpdateTime	DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustDiscountSetting_AgentH ( rID ,CustID ,SportType ,BetType ,Discount ,UpdateTime)
			SELECT rid ,cid ,s ,bt ,dis ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,dis	DECIMAL(9,8)
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustDiscountSetting_AgentH

			INSERT INTO Dep_CustDiscountSetting_Agent_History ( rID ,CustID ,SportType ,BetType ,Discount ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,SportType ,BetType ,Discount ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustDiscountSetting_AgentH

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