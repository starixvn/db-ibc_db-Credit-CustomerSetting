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
	
	IF @roleid > 1
	BEGIN
		SELECT custid, username, reject as suspended
		FROM custinfo ci WITH(NOLOCK)
		WHERE custid IN (SELECT custid FROM @tblCust)
		ORDER BY custid
	END
	
	IF @roleid = 4
	BEGIN
		;WITH tmp AS(
		SELECT ci.srecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(4,0,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend IN (SELECT custid FROM @tblCust)
			AND roleid < 4
		)
		SELECT srecommend custid, t.roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY srecommend, roleid
	END
	ELSE IF @roleid = 3
	BEGIN
		;WITH tmp AS(
		SELECT ci.mrecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(3,0,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE mrecommend IN (SELECT custid FROM @tblCust)
			AND roleid < 3
		)
		SELECT mrecommend as custid, roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY mrecommend,roleid
	END	
	ELSE IF @roleid = 2
	BEGIN
		;WITH tmp AS(
		SELECT ci.recommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(2,0,SuspendInfo)) as newSuspendInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend IN (SELECT custid FROM @tblCust)
			AND roleid = 1
		)
		SELECT recommend as custid, roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY recommend, t.roleid
	END
	ELSE IF @roleid = 1
	BEGIN		
		SELECT ci.custid, ci.username, ci.reject as suspended
		FROM custinfo ci WITH(NOLOCK)
		WHERE ci.custid IN (SELECT custid FROM @tblCust)	
	END	
END
GO



