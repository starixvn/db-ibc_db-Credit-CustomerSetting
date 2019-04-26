/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_SuspendInfoMatrixSel]
	@username VARCHAR(30)
AS
/*
	Created by:Johnson
	Date:2019-04-08
	Task: get downlines suspend info status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20190408@Johnson: initial sp [redmine: #105587]
	Parameter's Explanation:
*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @tblCust TABLE(custid INT, roleid TINYINT, reject BIT, username VARCHAR(30),SuspendBySuper BIT,SuspendByMaster BIT, SuspendByAgent BIT, SuspendMember BIT)	
	
	DECLARE @roleid TINYINT, 
			@srecommend INT, 
			@mrecommend INT, 
			@recommend INT,
			@custid INT
	
	SELECT @roleid = roleid,
		@srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend,
		@custid = custid
	FROM custInfo WITH(NOLOCK)
	WHERE username = @username
	
	SELECT ci.custid, ci.username, roleid, ci.reject as suspended,
		(SELECT suspendInfo FROM dbo.f_GetSuspendInfoStatus(4,SuspendInfo)) as SuspendBySuper,
		(SELECT suspendInfo FROM dbo.f_GetSuspendInfoStatus(3,SuspendInfo)) as SuspendByMaster,
		(SELECT suspendInfo FROM dbo.f_GetSuspendInfoStatus(2,SuspendInfo)) as SuspendByAgent,
		(SELECT suspendInfo FROM dbo.f_GetSuspendInfoStatus(1,SuspendInfo)) as SuspendMember
	FROM dbo.CustProductStatus cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.custid IN (@srecommend,@mrecommend,@recommend,@custid)	
	
END	
GO