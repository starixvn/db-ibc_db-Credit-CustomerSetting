/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsUserInfo_Rollback]
	@CustID int
AS
/*
	Created: 20240605@Eden
	Task : Rollback Credit Customer Setting for New accounts when failed 
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
		
	Param's Explanation:

	Examples:
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = xxx 
*/
BEGIN
	DECLARE @RoleID tinyint
	SELECT @RoleID = RoleID FROM customer (nolock) WHERE CustID = @CustID

	DELETE FROM custinfo WITH (ROWLOCK)  WHERE custid = @CustID
	DELETE FROM customer WITH (ROWLOCK)  WHERE CustID = @CustID

	IF @RoleID BETWEEN 2 AND 4
		DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	ELSE IF @RoleID = 1
		DELETE FROM CustLoginInfo_Member WITH (ROWLOCK) WHERE CustID = @CustID 

	IF @RoleID = 4
		DELETE FROM CustSuper WITH (ROWLOCK)  WHERE CustID = @CustID
	ELSE IF @RoleID = 3
		DELETE FROM CustMaster WITH (ROWLOCK)  WHERE CustID = @CustID
	ELSE IF @RoleID = 2
		DELETE FROM CustAgent WITH (ROWLOCK)  WHERE CustID = @CustID
END
GO
