ALTER PROCEDURE [dbo].[Age_CustomerSelCheckBelonging]
	@SessionCustID int, --uplineID	
	@custid int = NULL,
	@SubAccountID INT = 0,
	@isActive BIT = 1 OUTPUT,
	@transid bigint = NULL,
	@username varchar(30) = '' OUTPUT,
	@roleid tinyint = 0 OUTPUT --0: not belonged to
AS
/*
Created:
Task: check downline belonging
DB: DBAGE/bodb02, DBTXN/CustDB
Original: 
	
Revisions:
	- 20130121@Dan: change linked server DB06 to DBARC
	- 20131108@Elodie: Splitting bodb02 into CustDB (call bettrans, bettrans14 by link database in DBTXN)
    - 20140303@Johnson: fix bug check session's roleid 
	- 20150225@Lukas: add subaccountID 
*/
SET NOCOUNT ON
Declare @SessionRoleID tinyint

if @SessionCustID is NULL --Not check
BEGIN
	select @roleid = roleid
	from custinfo c with (nolock)
	where c.custid = @custid
	RETURN
END

--check customer by transid/refno -----------------------------------------------
if @custid is NULL
	select @custid = custid from bodb02.dbo.bettrans with (nolock) where transid = @transid

if @custid is NULL
	select @custid = custid from bodb02.dbo.bettrans14 with (nolock) where transid = @transid

if @custid is NULL
	select @custid = custid from DBARC.bodb_archive.dbo.Bettrans_bk with (nolock) where transid = @transid

--------------------------------------------------------------------------------


select	@SessionRoleID = roleid,
		@isActive = CASE WHEN closed = 1 OR Enabled = 0 THEN 0 ELSE 1 END
from custinfo with(nolock)
where custID = @SessionCustID

IF ISNULL(@sessionRoleid ,0) = 0 RETURN

select	@roleid = roleid, @username = username		
from custinfo c with (nolock)
where c.custid = @custid
	and
	(c.srecommend = @SessionCustID or c.mrecommend = @SessionCustID
		or c.recommend = @SessionCustID or c.custid = @SessionCustID
		OR @SessionRoleID >= 5)

if @SubAccountID <> 0
BEGIN
	SELECT @isActive = CASE WHEN closed = 0 THEN 1 ELSE 0 END 
	FROM dbo.custSub WITH(NOLOCK) 
	WHERE subaccID = @SubAccountID AND custid = @SessionCustID
END

select	@roleid = isnull(@roleid, 0), 
		@isActive = ISNULL(@isActive,0


GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Age_CustomerSelCheckBelonging] TO [vnteam]