/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Dep_CustProductStatus_Select
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
	 Created by: 20240628@Louisa
	 Task: Deposite - sync data from DBCUST-CustDB_History to DBTP-bodb_CustHistory [Redmine:#207025]
	 DB: DBCUST-CustDB_History

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#207025]
*/
BEGIN
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'Dep_CustProductStatus_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM Dep_CustProductStatus_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'

	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID					AS 'rid'
										,CustID				AS 'cid'
										,bitmapIsHidden		AS 'bih'
										,bitmapIsDisabled	AS 'bid'
										,UpdateTime			AS 'ut'
								FROM Dep_CustProductStatus_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END
GO