/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustomerList_SuspendInfoSel]
	@custidList VARCHAR(MAX),
	@roleid TINYINT
AS
/*
	Created by: 20190409@Johnson	
	Task: suspend info for super list 
	DB: DBCUST/CustDB
	Original:
	
	Revisions:
		- 20190409@Johnson: initial sp [redmine:#105587]
	Parameter's Explanation:
		
*/	
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tblCust TABLE(custid INT)
		
	INSERT INTO @tblCust(custid)
	SELECT val 
	FROM dbo.strSplit(@custidList,',')
	
	IF @roleid = 4
	BEGIN
		;WITH tmp AS(
		SELECT ci.srecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(4,1,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend IN (SELECT custid FROM @tblCust)
			AND roleid < 4
		)
		SELECT c.custid, c.username, c.reject as suspended, t.roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t
			INNER JOIN custinfo c WITH(NOLOCK) ON t.srecommend = c.custid
		GROUP BY c.custid, c.username,c.reject, t.roleid
	END
	ELSE IF @roleid = 3
	BEGIN
		;WITH tmp AS(
		SELECT ci.mrecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(3,1,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend IN (SELECT custid FROM @tblCust)
			AND roleid < 3
		)
		SELECT c.custid, c.username, c.reject as suspended, t.roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t
			INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = t.mrecommend
		GROUP BY c.custid, c.username, c.reject, t.roleid
	END	
	ELSE IF @roleid = 2
	BEGIN
		;WITH tmp AS(
		SELECT ci.recommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(2,1,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend IN (SELECT custid FROM @tblCust)
			AND roleid = 1
		)
		SELECT c.custid, c.username, c.reject as suspended, t.roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t
			INNER JOIN custinfo c WITH(NOLOCK) ON c.custid = t.recommend
		GROUP BY c.custid, c.username, c.reject, t.roleid
	END
	ELSE IF @roleid = 1
	BEGIN		
		SELECT ci.custid, ci.username, ci.reject as suspended
		FROM custinfo ci WITH(NOLOCK)
		WHERE ci.custid IN (SELECT custid FROM @tblCust)	
	END	
END
GO



