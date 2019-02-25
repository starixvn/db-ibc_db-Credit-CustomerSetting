/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet" viewers="" isFunction="0"></info>*/

CREATE PROCEDURE CS_CustomerInsUserInfo_Rollback
	@CustID int
AS
/*
	Created: 20181212@Elodie
	Task : Rollback data for invalid insert
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
*/
BEGIN
	DECLARE @RoleID TINYINT 
	SELECT @RoleID = RoleID FROM CustInfo (NOLOCK) WHERE CustID = @CustID

	DELETE FROM custinfo WITH (ROWLOCK)  WHERE custid = @CustID
	DELETE FROM customer WITH (ROWLOCK)  WHERE CustID = @CustID

	IF @RoleID BETWEEN 2 AND 4
		DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 

	IF @RoleID = 4
		DELETE FROM CustSuper WITH (ROWLOCK) WHERE CustID = @CustID
	ELSE IF @RoleID = 3
		DELETE FROM CustMaster WITH (ROWLOCK) WHERE CustID = @CustID
	ELSE IF @RoleID = 2
		DELETE FROM CustAgent WITH (ROWLOCK) WHERE CustID = @CustID
END