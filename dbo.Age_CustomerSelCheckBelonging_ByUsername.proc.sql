ALTER PROCEDURE [dbo].[Age_CustomerSelCheckBelonging_ByUsername]
	@uplineID INT, --user who is logging
	@userName VARCHAR(30) = NULL, --userName to check belong
	@subAccountID INT = 0,
	@isActive BIT = 0 OUTPUT,
	@custID INT OUTPUT, -- return custID of @userName, -1 = not valid
	@isSubAcc BIT OUTPUT, -- return 1 if @userName is sub account
	@roleID INT = NULL OUTPUT
AS

/*
Created: 20100120@Ryan
Task : Check if username belong to @uplineID
DB: DBAGE/bodb02

Revisions:
    - 20100120@Kiwi: use function f_GetCustIDFromUsername to solve performance problem
    - 20120327@Dan: add roleid to output parameter
    - 20120731@Johnson: Expand length of param username
    - 20130121@Dan: change linked server DB06 to DBARC
    - 20130719@Elodie: Correct link server DBACC instead of DBARC
    - 20150226@Johnson: add sub-accountID and check user is active or not
    - 20161129@Helen: change @userName parameter (NVARCHAR(50) -> VARCHAR(30)) for performance issue - [Redmine:N/A]
    
Param's Explanation:
• @uplineID: user who is logging.
• @userName: userName to check belong.
• @custID: return custID of @userName. 
	-1 : not belong
*/
BEGIN

	SET NOCOUNT ON

	DECLARE @uplineRoleID TINYINT

	SELECT @uplineRoleID = roleID
	FROM CustInfo WITH (NOLOCK)
	WHERE custID = @uplineID

	DECLARE @SubAccID INT, @PrimaryID INT -- custid of primary account in custSub table
	SELECT @SubAccID = ISNULL(subaccid,0), @PrimaryID = custid FROM CustSub WITH (NOLOCK) WHERE username = @userName
	SELECT @isSubAcc = 0
	IF (@SubAccID > 0)
	BEGIN
		--Check SubAccount first
		SELECT @isSubAcc = 1
		SELECT @custID = @SubAccID
		
		--Check valid donwline by @ID
		--DECLARE @roleID INT
		SELECT @roleID = roleid
		FROM CustInfo WITH (NOLOCK)
		WHERE custid = @PrimaryID AND 
				(srecommend = @uplineid OR mrecommend = @uplineid OR recommend = @uplineid
				 OR custID = @uplineID OR @uplineRoleID >= 5)
		SELECT @roleID = ISNULL(@roleID, 0)
		IF (@roleID <= 0) --not valid
			SELECT @custID = -1
	END
	ELSE
	BEGIN
		--Check valid downline by @Username
		DECLARE @AccID INT
		Exec @AccID = DBACC.bodb02.dbo.f_GetCustIDFromUsername @username
		--Check valid downline by @Username
		SELECT @custID = custID, @roleID = roleid
		FROM CustInfo WITH (NOLOCK)
		WHERE custid = @AccID AND 
				(srecommend = @uplineid OR mrecommend = @uplineid OR recommend = @uplineid
				 OR custID = @uplineID OR @uplineRoleID >= 5)
				 
		SELECT @roleID = ISNULL(@roleID, 0)
		SELECT @custID = ISNULL(@custID, -1)
	END

	--check user do this action is active or not
	if @SubAccountID <> 0
	BEGIN
		SELECT @isActive = CASE WHEN closed = 0 THEN 1 ELSE 0 END 
		FROM dbo.custSub WITH(NOLOCK) 
		WHERE subaccID = @SubAccountID AND custid = @uplineID
	END
	ELSE 
	BEGIN
		SELECT @isActive = CASE WHEN closed = 1 OR Enabled = 0 THEN 0 ELSE 1 END
		FROM dbo.custinfo WITH(NOLOCK) 
		WHERE custid = @uplineID	
	END 

	SELECT @isActive = ISNULL(@isActive,0) 
END
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_ByUsername] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_ByUsername] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_ByUsername] TO [bodbDownlineNetView]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_ByUsername] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Age_CustomerSelCheckBelonging_ByUsername] TO [vnteam]
