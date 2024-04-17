/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_CloseInfoMatrixSel]
	@username VARCHAR(30)
AS
/*
	Created by:Tina
	Date:2021-06-03
	Task: get downlines closed info status
	DB: DBCUST/CustDB
	Original: Acc_Customer_SuspendInfoMatrixSel

	Revisions:
		- 20210603@Tina: Lock account & indirect close account [redmine: #148600]
	Parameter's Explanation:

	EXEC Acc_Customer_CloseInfoMatrixSel @username='SuperTest1'
*/
BEGIN
	SET NOCOUNT ON;
	DECLARE @tblCust TABLE(CustID INT, RoleID TINYINT, Closed BIT, UserName VARCHAR(30),ClosedBySuper BIT,ClosedByMaster BIT, ClosedByAgent BIT, SuspendMember BIT)	
	
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
		CASE WHEN cs.CloseInfo > 0 THEN 1 ELSE 0 END AS closed,
		ISNULL(cl.SuperStatus, 0) as ClosedBySuper,
		ISNULL(cl.MasterStatus, 0) as ClosedByMaster,
		ISNULL(cl.AgentStatus, 0) as ClosedByAgent,
		ISNULL(cl.MemberStatus, 0) as ClosedMember
	FROM dbo.CustProductStatus cs WITH(NOLOCK)
		CROSS APPLY (SELECT * FROM f_GetInfoStatus(cs.CloseInfo)) AS cl
		INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
	WHERE ci.custid IN (@srecommend,@mrecommend,@recommend,@custid)	
	
END	
GO