/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_BetSetting3rd_Agent_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
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

			DECLARE @tmpBetSetting3rd_AgentH TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,MinBet		MONEY NULL
				,MaxBet		MONEY NULL
				,MaxPerMatch MONEY NULL
				,MaxPerNumber MONEY NULL
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmpBetSetting3rd_AgentH ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,MaxPerNumber ,UpdateTime)
			SELECT rid ,cid ,s ,bt ,mb ,mxb ,mpm ,mpn ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,mb		MONEY
					,mxb	MONEY
					,mpm	MONEY
					,mpn	MONEY
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmpBetSetting3rd_AgentH

			INSERT INTO BetSetting3rd_Agent_History ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,MaxPerNumber ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,MaxPerNumber ,UpdateTime, @SiteDBGroupID
			FROM @tmpBetSetting3rd_AgentH

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