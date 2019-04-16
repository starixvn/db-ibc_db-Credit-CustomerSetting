/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_SuspendInfoMaxtrixSel]
	@custid INT
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
			@recommend INT
	
	SELECT @roleid = roleid,
		@srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend
	FROM custInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	SELECT ci.custid, ci.username, roleid, c.reject as suspended,
		dbo.f_GetSuspendInfoStatus(4,SuspendInfo) as SuspendBySuper,
		dbo.f_GetSuspendInfoStatus(3,SuspendInfo) as SuspendByMaster,
		dbo.f_GetSuspendInfoStatus(2,SuspendInfo) as SuspendByAgent,
		dbo.f_GetSuspendInfoStatus(1,SuspendInfo) as SuspendMember
	FROM dbo.CustProductStatus cs WITH(NOLOCK)
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.custid IN (@srecommend,@mrecommend,@recommend,@custid)	
	
END	
GO