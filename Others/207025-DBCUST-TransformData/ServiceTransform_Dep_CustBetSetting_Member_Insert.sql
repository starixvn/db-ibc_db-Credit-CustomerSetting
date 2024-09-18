/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustBetSetting_Member_Insert
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

			DECLARE @tmp_Dep_CustBetSetting_MemberH TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,MinBet		MONEY NULL
				,MaxBet		MONEY NULL
				,MaxPerMatch MONEY NULL
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustBetSetting_MemberH ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,UpdateTime)
			SELECT rid ,cid ,s ,bt ,mb ,mxb ,mpm ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,mb		MONEY
					,mxb	MONEY
					,mpm	MONEY
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustBetSetting_MemberH

			INSERT INTO Dep_CustBetSetting_Member_History ( rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID ,SportType ,BetType ,MinBet ,MaxBet ,MaxPerMatch ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustBetSetting_MemberH

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