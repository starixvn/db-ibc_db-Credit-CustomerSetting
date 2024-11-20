/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustDiscount3rd_Agent_Select
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
	 Created by: 20241119@Louisa
	 Task:  sync data from DBCUST-CustDB_History to DBTP-bodb_CustHistory [Redmine:#212684]
	 DB: DBCUST-CustDB_History

	 Revision:
		- 20240628@Louisa: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON

	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'CustDiscount3rd_Agent_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	
	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM CustDiscount3rd_Agent_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'

	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID					AS 'rid'
										UpdateTime			AS 'ud'
										CustID				AS 'cid'
										SportType			AS 's'
										BetType				AS 'bt'
										Discount			AS 'dis'
								FROM CustDiscount3rd_Agent_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))

END
GO