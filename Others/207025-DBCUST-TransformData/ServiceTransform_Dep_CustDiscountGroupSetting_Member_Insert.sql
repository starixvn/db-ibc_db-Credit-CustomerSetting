/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustDiscountGroupSetting_Member_Insert
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

			DECLARE @tmp_Dep_CustDiscountGroupSetting_MemberH TABLE 
			(	
				rID					BIGINT NOT NULL
				,AgentID			INT NOT NULL
				,SportType			SMALLINT NOT NULL
				,BetType			SMALLINT NOT NULL
				,PlayerDiscount		DECIMAL(9,8)
				,AgentDiscount		DECIMAL(9,8)
				,MasterDiscount		DECIMAL(9,8)
				,SuperDiscount		DECIMAL(9,8)
				,UpdateTime			DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustDiscountGroupSetting_MemberH 
			( 
				rID ,AgentID ,SportType ,BetType 
				,PlayerDiscount	,AgentDiscount	,MasterDiscount	,SuperDiscount	,UpdateTime
			)
			SELECT rid ,cid ,s ,bt ,pdis ,adis ,mdis ,sdis	,ut		
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
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustDiscountGroupSetting_MemberH

			INSERT INTO Dep_CustDiscountGroupSetting_Member_History 
			( 
				rID ,AgentID ,SportType ,BetType 
				,PlayerDiscount	,AgentDiscount	,MasterDiscount	,SuperDiscount
				,UpdateTime, SiteDBGroupID
			)
			SELECT  rID ,AgentID ,SportType ,BetType  
					,PlayerDiscount	,AgentDiscount	,MasterDiscount	,SuperDiscount
					,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustDiscountGroupSetting_MemberH

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