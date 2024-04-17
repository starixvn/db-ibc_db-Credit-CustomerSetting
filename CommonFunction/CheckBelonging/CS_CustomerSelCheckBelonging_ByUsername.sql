/*<info serverAlias="DBCUST-CustDB, DBAGE-bodb02" executers="wsv_xnap,wsv_alp,wsv_alpv,wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE CS_CustomerSelCheckBelonging_ByUsername
	@SessionCustID INT, --uplineID	
	@username VARCHAR(30),
	@SubAccountID INT = 0,
	@custid INT = 0 OUTPUT,
	@roleid TINYINT = 0 OUTPUT --0: not belonged to
AS
/*
	Created: 20190715@Elodie
	Task: Check downline belonging by username for CN88
	DB: DBAGE/bodb02, DBCUST/CustDB
	Original: Age_CustomerSelCheckBelonging
	
	Revisions:
		- 20190715@Elodie: Initial SP [Redmine: #116825]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SessionRoleID TINYINT, @IsAllDownline BIT, @UplineId INT, @MainAccId INT

	SELECT	@SessionRoleID = roleid
	FROM custinfo WITH(NOLOCK)
	WHERE custID = @SessionCustID

	IF ISNULL(@sessionRoleid ,0) = 0 RETURN	

	SELECT	@custid = custid,
			@UplineId = CASE WHEN @SessionRoleID = 4 THEN mrecommend WHEN @SessionRoleID = 3 THEN recommend ELSE custid END
	FROM Customer WITH (NOLOCK) 
	WHERE username = @username

	IF ISNULL(@custid ,0) = 0 RETURN

	if @SubAccountID <> 0
	BEGIN
		SELECT @IsAllDownline = IsAllDownline, @MainAccId = custid
		FROM dbo.custSub WITH(NOLOCK) 
		WHERE subaccID = @SubAccountID

		IF NOT EXISTS (SELECT 1 FROM dbo.CS_SubAccManagement WITH (NOLOCK) WHERE SubAccId = @SubAccountID AND DownlineId = @UplineId) AND ISNULL(@IsAllDownline,0) = 0
			AND @MainAccId <> @custid
		BEGIN
			SELECT @custid = 0, @roleid = 0
			RETURN
		END
	END

	SELECT	@roleid = roleid, @username = username		
	FROM custinfo c WITH (NOLOCK)
	WHERE c.custid = @custid
		AND
		(c.srecommend = @SessionCustID or c.mrecommend = @SessionCustID
			OR c.recommend = @SessionCustID or c.custid = @SessionCustID
			OR @SessionRoleID >= 5)
	
	IF @@ROWCOUNT = 0
		SELECT @custid = 0, @roleid = 0

	SELECT @roleid = ISNULL(@roleid, 0)

END
GO
