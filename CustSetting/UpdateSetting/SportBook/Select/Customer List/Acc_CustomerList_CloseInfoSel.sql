/*<info serverAlias="DBCust-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustomerList_CloseInfoSel]
	@custidList VARCHAR(MAX),
	@roleid TINYINT
AS
/*
	Created by: 20210510@Tina	
	Task: close info for super list 
	DB: DBCUST/CustDB
	Original:
	
	Revisions:
		- 20210510@Tina: Lock account & indirect close account [redmine: #148600]
		- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 
	Parameter's Explanation:
		
*/	
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tblCust TABLE(custid INT)
		
	INSERT INTO @tblCust(custid)
	SELECT value 
	FROM STRING_SPLIT(@custidList,',')
	WHERE value <> ''
	
	IF @roleid > 1
	BEGIN
		SELECT ci.custid, ci.username, CASE WHEN cps.CloseInfo > 0 THEN 1 ELSE 0 END closed
		FROM custinfo ci WITH(NOLOCK)
			JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
		WHERE ci.custid IN (SELECT custid FROM @tblCust)
		ORDER BY custid
	END
	
	IF @roleid = 4
	BEGIN
		;WITH tmp AS(
		SELECT ci.srecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(4,0,CloseInfo)) as newCloseInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend IN (SELECT custid FROM @tblCust)
			AND roleid < 4
		)
		SELECT srecommend custid, t.roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY srecommend, roleid
	END
	ELSE IF @roleid = 3
	BEGIN
		;WITH tmp AS(
		SELECT ci.mrecommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(3,0,CloseInfo)) as newCloseInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE mrecommend IN (SELECT custid FROM @tblCust)
			AND roleid < 3
		)
		SELECT mrecommend as custid, roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY mrecommend,roleid
	END	
	ELSE IF @roleid = 2
	BEGIN
		;WITH tmp AS(
		SELECT ci.recommend, roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(2,0,CloseInfo)) as newCloseInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend IN (SELECT custid FROM @tblCust)
			AND roleid = 1
		)
		SELECT recommend as custid, roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged,
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM tmp t			
		GROUP BY recommend, t.roleid
	END
	ELSE IF @roleid = 1
	BEGIN		
		SELECT ci.custid, ci.username, CASE WHEN cps.CloseInfo > 0 THEN 1 ELSE 0 END closed
		FROM custinfo ci WITH(NOLOCK)
			JOIN CustProductStatus cps WITH (NOLOCK) ON cps.CustID = ci.custid
		WHERE ci.custid IN (SELECT custid FROM @tblCust) 
	END	
END
GO



