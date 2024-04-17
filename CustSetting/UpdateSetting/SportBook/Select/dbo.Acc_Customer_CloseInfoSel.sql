/*<info serverAlias="DBCUST-CustDB" executers="wsv_alp,wsv_nap,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_CloseInfoSel]
	@custid INT
AS
/*
	Created by:Tina
	Date:2021-05-07
	Task: get downlines close info status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20210507@Tina: Lock account & indirect close account [redmine: #148600]
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
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
	ELSE IF @roleid = 3
	BEGIN
		WITH t as(
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE mrecommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
	ELSE IF @roleid = 2
	BEGIN
		WITH t as(
		SELECT roleid, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend = @custid	
			AND ci.custid <> @custid
		)
		SELECT roleid, 
			SUM(CASE WHEN newCloseInfo > 0 THEN 1 ELSE 0 END) as cntUnchanged, 
			SUM(CASE WHEN newCloseInfo = 0 THEN 1 ELSE 0 END) as cntAffected
		FROM t
		GROUP BY roleid
	END
END
GO