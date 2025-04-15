/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].Age_CustomerCheckExist_DirectMember
	@UplineCustID	INT,
	@Username		VARCHAR(30) = ''
AS
/*
	Created: 20241107@Eden		
	Task: Check exist super/master direct member under this upline
	DB:  DBCUST-CustDB
		
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Parameter's Explanation:		
		@UplineCustID: Super/MasterID
		@Username: custinfo.username
	
	Examples:
	EXEC CustDB..Age_CustomerCheckExist_DirectMember 
		@UplineCustID = 179806625,
		@Username = 'EdenTestS10000001'
	*/ 
BEGIN	
	SET NOCOUNT ON
	DECLARE @UplineRoleID TINYINT
	SELECT @UplineRoleID = RoleID FROM custinfo WITH(NOLOCK) WHERE custid = @UplineCustID

	IF @UplineRoleID = 4
	BEGIN
		SELECT c.username,c.custid,ci.Enabled  
		FROM customer c WITH (NOLOCK)  
			INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
		WHERE c.roleid = 1  
			AND c.recommend = -4  
			AND c.srecommend = @UplineCustID  
			AND (c.username = @Username  OR c.username2 = @Username )
	END
	ELSE IF @UplineRoleID = 3
	BEGIN
		SELECT c.username,c.custid,ci.Enabled  
		FROM customer c WITH (NOLOCK)  
			INNER JOIN custinfo ci WITH(NOLOCK) ON c.custid = ci.custid
		WHERE c.roleid = 1  
			AND c.recommend = -3  
			AND c.mrecommend = @UplineCustID  
			AND (c.username = @Username  OR c.username2 = @Username )
	END
END
GO