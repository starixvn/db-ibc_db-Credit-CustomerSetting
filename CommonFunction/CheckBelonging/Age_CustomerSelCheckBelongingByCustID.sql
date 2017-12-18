USE [CustDB]
GO

ALTER PROCEDURE [dbo].[Age_CustomerSelCheckBelongingByCustID]
	@SessionCustID int, --uplineID	
	@custid int = NULL,
	@SubAccountID INT = 0,
	@isActive BIT = 1 OUTPUT,
	@username varchar(30) = '' OUTPUT,
	@roleid tinyint = 0 OUTPUT --0: not belonged to
AS
/*
	Created: Elodie
	Task: check downline belonging by custid
	DB: DBCUST/CustDB
	Original: Age_CustomerSelCheckBelonging
	
	Revisions:
		
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
		@isActive = ISNULL(@isActive,0)