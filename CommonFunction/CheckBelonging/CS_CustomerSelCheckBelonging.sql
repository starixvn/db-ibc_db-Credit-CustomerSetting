/*<info serverAlias="DBCUST-CustDB, DBAGE-bodb02" executers="bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerSelCheckBelonging]
	@SessionCustID INT, --uplineID	
	@custid INT = NULL,
	@SubAccountID INT = 0,
	@transid BIGINT = NULL,
	@isActive BIT = 1 OUTPUT,
	@username VARCHAR(30) = '' OUTPUT,
	@roleid TINYINT = 0 OUTPUT --0: not belonged to
AS
/*
	Created: 20190715@Elodie
	Task: Check downline belonging for CN88
	DB: DBAGE/bodb02, DBCUST/CustDB
	Original: Age_CustomerSelCheckBelonging
	
	Revisions:
		- 20190715@Elodie: initial SP [Redmine: #116825]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @SessionRoleID TINYINT, @IsAllDownline BIT

	IF @SessionCustID IS NULL --Not check
	BEGIN
		SELECT @roleid = roleid
		FROM custinfo c WITH (NOLOCK)
		WHERE c.custid = @custid
		
		RETURN
	END

	--check customer by transid/refno -----------------------------------------------
	IF @transid IS NOT NULL
	BEGIN
		IF @custid IS NULL
			SELECT @custid = custid FROM bodb02.dbo.bettrans WITH (NOLOCK) WHERE transid = @transid

		IF @custid is NULL
			SELECT @custid = custid FROM bodb02.dbo.bettrans14 WITH (NOLOCK) WHERE transid = @transid

		IF @custid is NULL
			SELECT @custid = custid FROM DBARC.bodb_archive.dbo.Bettrans_bk WITH (NOLOCK) WHERE transid = @transid
	END
	--------------------------------------------------------------------------------

	SELECT	@SessionRoleID = roleid,
			@isActive = CASE WHEN closed = 1 OR Enabled = 0 THEN 0 ELSE 1 END
	FROM custinfo WITH(NOLOCK)
	WHERE custID = @SessionCustID

	IF ISNULL(@sessionRoleid ,0) = 0 RETURN

	SELECT	@roleid = roleid, @username = username		
	FROM custinfo c WITH (NOLOCK)
	WHERE c.custid = @custid
		AND
		(c.srecommend = @SessionCustID or c.mrecommend = @SessionCustID
			OR c.recommend = @SessionCustID or c.custid = @SessionCustID
			OR @SessionRoleID >= 5)

	if @SubAccountID <> 0
	BEGIN
		SELECT @isActive = CASE WHEN closed = 0 THEN 1 ELSE 0 END, @IsAllDownline = IsAllDownline
		FROM dbo.custSub WITH(NOLOCK) 
		WHERE subaccID = @SubAccountID AND custid = @SessionCustID

		IF NOT EXISTS (SELECT 1 FROM dbo.CS_SubAccManagement WITH (NOLOCK) WHERE SubAccId = @SubAccountID AND DownlineId = @custid) AND ISNULL(@IsAllDownline,0) = 0
			SELECT @roleid = 0
	END

	SELECT	@roleid = ISNULL(@roleid, 0), 
			@isActive = ISNULL(@isActive,0)

END
