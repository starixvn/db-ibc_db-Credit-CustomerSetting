
ALTER PROCEDURE [dbo].[Acc_CustomerSelSuperLiveCS_Commission]
(
	@username	VARCHAR(30),
	@ErrCode	INT				= 0 OUTPUT,
	@ErrMsg		NVARCHAR(200)	= '' OUTPUT
)
AS
/*
	Created: 20130226@Lukas
	Task: verify super username & get Live Casino commission
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150612@Elodie: Get user info directly
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
	
*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @CustID		INT,
			@RoleID		TINYINT,
			@Currency	INT	

	--EXEC [DBACC].[bodb02].[dbo].[Acc_CustomerSelInfoByUsername]
	--	@UserName = @username,
	--	@CustID  = @CustID OUTPUT,
	--	@RoleID  = @RoleID OUTPUT,
	--	@Currency = @Currency OUTPUT

	SELECT @CustID = CustID, @RoleID = roleid, @Currency = currency 
	FROM custinfo WITH(NOLOCK)
	WHERE UserName = @UserName

	IF @custid IS NULL OR @RoleID <> 4
	BEGIN
		SELECT	@ErrCode = 101,
				@ErrMsg = 'Invalid username!'
		RETURN
	END
	
	SELECT custid, sdiscount
	FROM custsettinggame WITH(NOLOCK)
	WHERE custid = @custid
	
END



GO
GRANT EXECUTE ON Acc_CustomerSelSuperLiveCS_Commission TO bodbAdminNet
GO
GRANT VIEW DEFINITION ON Acc_CustomerSelSuperLiveCS_Commission TO vnteam

