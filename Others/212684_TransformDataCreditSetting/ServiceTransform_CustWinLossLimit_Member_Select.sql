/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_CustWinLossLimit_Member_Select
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
	 Created by: 20250103@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBCUST/CustDB_History

	 Revision:
		- 20250103@Johnson: Initial [Redmine:#212684]
		- 20250703@Dave: Customer Setting - Reset Banlace WinLimit for Cash Member [Redmine: #232054]
*/
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'CustWinLossLimit_Member_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM CustWinLossLimit_Member_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'
	
	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
										rID					AS 'rid'
										,CustID				AS 'cid'
										,SportType			AS 's'
										,BetType			AS 'bt'
										,MaxWinLimit		AS 'maxw'
										,MaxLossLimit		AS 'maxl'
										,IsAutoReset		AS 'isa'	
										,RestedDate			AS 'rd'	
										,UpdateTime			AS 'ut'
								FROM CustWinLossLimit_Member_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END