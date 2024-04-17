/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_SuspendInfoSel]
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
	
	DECLARE @roleid TINYINT
	
	SELECT @roleid = roleid 
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid = 4
	BEGIN
		WITH t as(
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,SuspendInfo)) as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
	ELSE IF @roleid = 3
	BEGIN
		WITH t as(
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,SuspendInfo)) as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE mrecommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
	ELSE IF @roleid = 2
	BEGIN
		WITH t as(
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,SuspendInfo)) as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newSuspendInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newSuspendInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
END
GO