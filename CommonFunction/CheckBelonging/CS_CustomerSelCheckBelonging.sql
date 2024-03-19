/*<info serverAlias="DBCUST-CustDB, DBAGE-bodb02" executers="bodbExtAccNet,wsv_xnap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE CS_CustomerSelCheckBelonging
	@SessionCustID INT, --uplineID	
	@custid INT = NULL,
	@SubAccountID INT = 0,
	@username VARCHAR(30) = '' OUTPUT,
	@roleid TINYINT = 0 OUTPUT --0: not belonged to
AS
/*
	Created: 20190715@Elodie
	Task: Check downline belonging for CN88
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

	SELECT @UplineId = CASE WHEN @SessionRoleID = 4 THEN mrecommend WHEN @SessionRoleID = 3 THEN recommend ELSE custid END
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @custid

	if @SubAccountID <> 0
	BEGIN
		SELECT @IsAllDownline = IsAllDownline, @MainAccId = custid
		FROM dbo.custSub WITH(NOLOCK) 
		WHERE subaccID = @SubAccountID

		IF NOT EXISTS (SELECT 1 FROM dbo.CS_SubAccManagement WITH (NOLOCK) WHERE SubAccId = @SubAccountID AND DownlineId = @UplineId) AND ISNULL(@IsAllDownline,0) = 0
			AND @MainAccId <> @custid
			RETURN
	END

	SELECT	@roleid = roleid, @username = username		
	FROM custinfo c WITH (NOLOCK)
	WHERE c.custid = @custid
		AND
		(c.srecommend = @SessionCustID or c.mrecommend = @SessionCustID
			OR c.recommend = @SessionCustID or c.custid = @SessionCustID
			OR @SessionRoleID >= 5)

	SELECT @roleid = ISNULL(@roleid, 0)
END
GO
