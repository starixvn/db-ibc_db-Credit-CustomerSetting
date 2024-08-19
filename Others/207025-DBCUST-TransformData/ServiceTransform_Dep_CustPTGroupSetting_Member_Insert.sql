/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustPTGroupSetting_Member_Insert
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

			DECLARE @tmp_Dep_CustPTGroupSetting_MemberH TABLE 
			(	
				rID			BIGINT NOT NULL
				,AgentID	INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,IsLive		BIT NOT NULL
				,SuperPT	SMALLMONEY
				,MasterPT	SMALLMONEY
				,AgentPT	SMALLMONEY
				,UpdateTime	DATETIME
			)
		
			INSERT INTO @tmp_Dep_CustPTGroupSetting_MemberH ( rID ,AgentID ,SportType	,BetType ,IsLive ,SuperPT ,MasterPT	,AgentPT ,UpdateTime)
			SELECT rid ,aid ,s ,bt ,il ,spt ,mpt ,apt ,ut	
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,aid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,il		BIT
					,spt	SMALLMONEY
					,mpt	SMALLMONEY
					,apt	SMALLMONEY
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_Dep_CustPTGroupSetting_MemberH

			INSERT INTO Dep_CustPTGroupSetting_Member_History ( rID ,AgentID ,SportType	,BetType ,IsLive ,SuperPT ,MasterPT	,AgentPT ,UpdateTime, SiteDBGroupID )
			SELECT  rID ,AgentID ,SportType	,BetType ,IsLive ,SuperPT ,MasterPT	,AgentPT ,UpdateTime, @SiteDBGroupID
			FROM @tmp_Dep_CustPTGroupSetting_MemberH

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