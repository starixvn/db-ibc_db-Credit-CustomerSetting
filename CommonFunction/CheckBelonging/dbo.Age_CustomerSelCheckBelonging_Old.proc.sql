/****** Object:  StoredProcedure [dbo].[Age_CustomerSelCheckBelonging]    Script Date: 04/10/2008 10:02:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Age_CustomerSelCheckBelonging_Old]
	@SessionCustID int, --uplineID	
	@custid int = NULL,
	@transid bigint = NULL,
	@roleid tinyint OUTPUT --0: not belonged to
AS
SET NOCOUNT ON
Declare @SessionRoleID tinyint

if @SessionCustID is NULL --Not check
BEGIN
	select @roleid = roleid
	from customer c with (nolock)
	where c.custid = @custid
	RETURN
END

--check customer by transid/refno -----------------------------------------------
if @custid is NULL
	select @custid = custid from bodb_Archive.dbo.bettrans_bk with (nolock) where transid = @transid
if @custid is NULL
	select @custid = custid from bodb_Archive.dbo.bettrans_bk with (nolock) where refno = @transid		
--------------------------------------------------------------------------------


select @SessionRoleID = roleid
from customer with(nolock)
where custID = @SessionCustID

select @roleid = roleid
from customer c with (nolock)
where c.custid = @custid
	and
	(c.srecommend = @SessionCustID or c.mrecommend = @SessionCustID
		or c.recommend = @SessionCustID or c.custid = @SessionCustID
		OR @SessionRoleID >= 5)
	
select @roleid = isnull(@roleid, 0)


GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_Old] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_Old] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_Old] TO [bodbDownlineNetView]