/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustBetSettingGame_Agent_Insert
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
	 DB: DBTP-bodb02

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#207025]
*/
BEGIN
	SET XACT_ABORT ON

	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_Dep_CustBetSettingGame_AgentH TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,MinBet		MONEY NULL
				,MaxBet		MONEY NULL
				,MaxPerMatch MONEY NULL
				,MaxPerNumber MONEY NULL
				,MaxPayoutPerMatch MONEY NULL
				,IsInserted	BIT NULL
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustBetSettingGame_AgentH ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch,MaxPerNumber ,MaxPayoutPerMatch,IsInserted,UpdateTime)
			SELECT rid ,cid ,s ,bt ,mb ,mxb ,mpm , mpn, mppm, ii, ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,mb		MONEY
					,mxb	MONEY
					,mpm	MONEY
					,mpn	MONEY
					,mppm	MONEY
					,ii		BIT
					,ut		DATETIME


					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustBetSettingGame_AgentH

			INSERT INTO Dep_CustBetSettingGame_Agent_History ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch,MaxPerNumber ,MaxPayoutPerMatch,IsInserted ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch,MaxPerNumber ,MaxPayoutPerMatch,IsInserted ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustBetSettingGame_AgentH

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