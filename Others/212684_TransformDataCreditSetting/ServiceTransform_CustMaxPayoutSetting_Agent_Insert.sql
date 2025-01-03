/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustMaxPayoutSetting_Agent_Insert
(
	@TableName		VARCHAR(200)
	,@TransformJson VARBINARY(MAX)
	,@SiteDBGroupID SMALLINT
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241227@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBTP-bodb_CustHistory

	 Revision:
		- 20241227@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @MaxID BIGINT

			DECLARE @tmp_CustMaxPayoutSetting_Agent TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,SingleMatchParlay	MONEY NOT NULL
				,Combo2		MONEY NOT NULL
				,Combo35	MONEY NOT NULL
				,ComboOver6	MONEY NOT NULL				
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustMaxPayoutSetting_Agent ( rID, CustID, SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6 ,UpdateTime)
			SELECT rid ,cid ,s ,bt ,smp ,cb2 ,cb35 ,cb6 ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,smp	MONEY
					,cb2	MONEY
					,cb35	MONEY	
					,cb6	MONEY
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustMaxPayoutSetting_Agent

			INSERT INTO CustMaxPayoutSetting_Agent_History ( rID ,CustID, SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6, UpdateTime, SiteDBGroupID)
			SELECT  rID, CustID, SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustMaxPayoutSetting_Agent

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