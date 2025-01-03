/*<info serverAlias="DBCBAK-CustDB_History" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE ServiceTransform_Customer_Select
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
	 Created by: 20241226@Johnson
	 Task: Credit - Transform data from DBCUST/CustDB_History to DBTP/bodb_CustHistory  [Redmine:#212684]
	 DB: DBCUST/CustDB_History

	 Revision:
		- 20241226@Johnson: Initial [Redmine:#212684]
*/
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID(@TableName) IS NULL OR @TableName <> 'Customer_History'
	BEGIN
		SELECT @ErrorCode = 100
			 ,@ErrorMessage = 'Objects is not exists!'
		RETURN;
	END

	DECLARE @MaxrID BIGINT
	SELECT @MaxrID = MAX(rID) FROM Customer_History WITH(NOLOCK)

	WAITFOR DELAY '00:00:00.005'
	
	SELECT @TransformJson = COMPRESS(( SELECT TOP(@BatchSize)
									   [rID]
									  ,[updatetime]
									  ,[custid]
									  ,[firstname]
									  ,[lastname]
									  ,[address]
									  ,[postal]
									  ,[city]
									  ,[state]
									  ,[country]
									  ,[phone]
									  ,[mobilephone]
									  ,[fax]
									  ,[email]
									  ,[birthday]
									  ,[refcode1]
									  ,[refcode2]
									  ,[remark]
									  ,[creatdate]
									  ,[creator]
									  ,[username]
									  ,[currency]
									  ,[userpwd]
									  ,[lastlogged]
									  ,[pwdexpiry]
									  ,[roleid]
									  ,[mrecommend]
									  ,[recommend]
									  ,[ugroup]
									  ,[logincount]
									  ,[on_sessionid]
									  ,[site]
									  ,[iplogin]
									  ,[important]
									  ,[srecommend]
									  ,[username2]		
								FROM Customer_History WITH(NOLOCK)
								WHERE rID > @rID 
									AND rID <= @MaxrID
								ORDER BY rID
								FOR JSON PATH
								,INCLUDE_NULL_VALUES
							))
END