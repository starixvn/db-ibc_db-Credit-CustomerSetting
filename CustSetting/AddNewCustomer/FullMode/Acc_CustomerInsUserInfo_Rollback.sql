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
		- 20241121@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20250220@July: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]

	Param's Explanation:

	Examples:
		EXEC Acc_CustomerInsUserInfo_Rollback @CustID = xxx 
*/
BEGIN
	DECLARE @RoleID tinyint
	SELECT @RoleID = RoleID FROM customer (nolock) WHERE CustID = @CustID

	DELETE c
	OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
	INTO custinfo_Del_InHouse(CustID,RepUpdateTime)
	FROM custinfo c WITH (ROWLOCK)  
	WHERE custid = @CustID
	
	DELETE c
	OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
	INTO customer_Del_InHouse(CustID,RepUpdateTime)
	FROM customer c WITH (ROWLOCK)  
	WHERE CustID = @CustID

	IF @RoleID BETWEEN 2 AND 4
		DELETE FROM CustLoginInfo WITH (ROWLOCK) WHERE CustID = @CustID 
	ELSE IF @RoleID = 1
		DELETE FROM CustLoginInfo_Member WITH (ROWLOCK) WHERE CustID = @CustID 

	IF @RoleID = 4
		DELETE c
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustSuper_Del_InHouse(CustID,RepUpdateTime)
		FROM CustSuper c WITH (ROWLOCK)  
		WHERE CustID = @CustID
	ELSE IF @RoleID = 3
		DELETE c 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustMaster_Del_InHouse(CustID,RepUpdateTime)
		FROM CustMaster c WITH (ROWLOCK)  
		WHERE CustID = @CustID
	ELSE IF @RoleID = 2
		DELETE c 
		OUTPUT DELETED.CustID, dbo.f_GetDateTime2()
		INTO CustAgent_Del_InHouse(CustID,RepUpdateTime)
		FROM CustAgent c WITH (ROWLOCK)  
		WHERE CustID = @CustID
END
GO
