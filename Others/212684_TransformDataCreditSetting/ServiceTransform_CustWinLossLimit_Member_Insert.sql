/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustWinLossLimit_Member_Insert
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

			DECLARE @tmp_CustWinLossLimit_Member TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID		INT NOT NULL				
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL	
				,MaxWinLimit	MONEY
				,MaxLossLimit	MONEY
				,IsAutoReset	BIT
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustWinLossLimit_Member ( rID ,CustID, SportType, Bettype, MaxWinLimit, MaxLossLimit, IsAutoReset, UpdateTime)
			SELECT rid ,cid , s, bt, maxw, maxl, isa, ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT	
					,s		SMALLINT 
					,bt		SMALLINT
					,maxw	MONEY
					,maxl	MONEY
					,isa	BIT
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustWinLossLimit_Member

			INSERT INTO CustWinLossLimit_Member_History ( rID ,CustID, SportType, Bettype, MaxWinLimit, MaxLossLimit, IsAutoReset, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID, SportType, Bettype, MaxWinLimit, MaxLossLimit, IsAutoReset, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustWinLossLimit_Member

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