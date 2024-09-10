/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_VRCustLockStatus_Select
(
	@TableName		VARCHAR(200)
	,@BatchSize		INT = 1000
	,@rID			BIGINT
	,@TransformJson VARBINARY(MAX) OUTPUT 
	,@ErrorCode		INT = 0 OUTPUT
	,@ErrorMessage	VARCHAR(MAX) = '' OUTPUT
)
AS
/*
	 Created by: 20240628@Louisa
	 Task: init [Redmine:#204370]
	 DB: DBCUST-CustDB_History

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#204370]
*/
BEGIN
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'VRCustLockStatus_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM VRCustLockStatus_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'

	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID			AS 'rid'
										,CustID		AS 'cid'
										,Type		AS 't'
										,UpdateTime	AS 'ut'
										,IsLocked	AS 'il'
								FROM VRCustLockStatus_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END
GO