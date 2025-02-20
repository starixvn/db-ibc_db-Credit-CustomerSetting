/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustPTGroupSetting3rd_Member_Select
(
	@TableName		VARCHAR(200)
	,@BatchSize		INT = 1000
	,@rID			INT
	,@TransformJson VARBINARY(MAX)  OUTPUT 
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20241227@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBCUST/CustDB_History

	 Revision:
		- 20241227@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'CustPTGroupSetting3rd_Member_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM CustPTGroupSetting3rd_Member_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'
	
	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID					AS 'rid'
										,AgentID			AS 'aid'
										,SportType			AS 's'
										,BetType			AS 'bt'
										,IsLive				AS 'live'
										,SuperPT			AS 'spt'
										,MasterPT			AS 'mpt'
										,AgentPT			AS 'apt'
										,IsAutoMasterPT		AS 'ism'
										,AutoMasterPT		AS 'aum'
										,IsAutoSuperPT		AS 'iss'	
										,AutoSuperPT		AS 'aus'
										,UpdateTime			AS 'ut'
								FROM CustPTGroupSetting3rd_Member_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END