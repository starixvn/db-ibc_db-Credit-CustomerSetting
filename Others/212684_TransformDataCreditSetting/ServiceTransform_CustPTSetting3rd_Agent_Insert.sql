/*<info serverAlias="DBHIS-bodb_CustHistory" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustPTSetting3rd_Agent_Insert
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

			DECLARE @tmp_CustPTSetting3rd_Agent TABLE 
			(	
				rID			BIGINT NOT NULL
				,CustID	INT NOT NULL
				,SportType	SMALLINT NOT NULL
				,BetType	SMALLINT NOT NULL
				,IsLive		BIT NOT NULL
				,SuperPT	SMALLMONEY NOT NULL
				,MasterPT	SMALLMONEY NOT NULL
				,AgentPT	SMALLMONEY NOT NULL
				,IsAutoMasterPT	BIT NOT NULL
				,AutoMasterPT	SMALLMONEY NOT NULL
				,IsAutoSuperPT	BIT NOT NULL
				,AutoSuperPT	SMALLMONEY NOT NULL		
				,MinPT		SMALLMONEY NOT NULL	
				,MaxPT		SMALLMONEY NOT NULL	
				,UpdateTime DATETIME
			)
		
			INSERT INTO @tmp_CustPTSetting3rd_Agent ( rID ,CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT, MinPT, MaxPT ,UpdateTime)
			SELECT rid ,cid ,s ,bt , live, spt, mpt, apt, ism, aum, iss, aus, minpt, maxpt ,ut		
			FROM  OPENJSON (  CAST( DECOMPRESS(@TransformJson) AS NVARCHAR(MAX)) )
			WITH (	rid		BIGINT
					,cid	INT
					,s		SMALLINT
					,bt		SMALLINT
					,live	BIT
					,spt	SMALLMONEY
					,mpt	SMALLMONEY
					,apt	SMALLMONEY
					,ism	BIT
					,aum	SMALLMONEY
					,iss	BIT
					,aus 	SMALLMONEY
					,minpt 	SMALLMONEY
					,maxpt 	SMALLMONEY
					,ut		DATETIME
					)
				
			SELECT @MaxID = MAX(rID) FROM @tmp_CustPTSetting3rd_Agent

			INSERT INTO CustPTSetting3rd_Agent_History ( rID ,CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT, MinPT, MaxPT, UpdateTime, SiteDBGroupID)
			SELECT  rID ,CustID, SportType, BetType, IsLive, SuperPT, MasterPT, AgentPT, IsAutoMasterPT, AutoMasterPT, IsAutoSuperPT, AutoSuperPT, MinPT, MaxPT, UpdateTime, @SiteDBGroupID
			FROM @tmp_CustPTSetting3rd_Agent

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