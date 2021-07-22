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
		- 20210510@Tina: Lock account & indirect close account [redmine: #148600]
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
	
	SELECT ci.custid, ci.username, roleid, 
		CASE WHEN cs.SuspendInfo > 0 THEN 1 ELSE 0 END AS suspended,
		ISNULL(cl.SuperStatus, 0) as SuspendBySuper,
		ISNULL(cl.MasterStatus, 0) as SuspendByMaster,
		ISNULL(cl.AgentStatus, 0) as SuspendByAgent,
		ISNULL(cl.MemberStatus, 0) as SuspendMember
	FROM dbo.CustProductStatus cs WITH(NOLOCK)
		CROSS APPLY (SELECT * FROM f_GetInfoStatus(cs.SuspendInfo)) AS cl
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.custid IN (@srecommend,@mrecommend,@recommend,@custid)	
	
END	
GO