/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_CloseInfoDetailSel]
	@custid INT,
	@IsAffected BIT,
	@DownlineRoleid TINYINT = 0,
	@PageSize INT = 50,
	@PageIndex INT = 0,
	@TotalRows INT = 0 OUTPUT
AS
/*
	Created by:Tina
	Date:2021-05-06
	Task: get list customers for close status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20210506@Tina: All Sites - Lock account & indirect close account [redmine: #148600]
	Parameter's Explanation:
		- @DownlineRoleid =0: show all downline
						  <> 0:	roleid of downline to retreive customer list	
		- @isAffected: = 1: downline list will change open
					   = 0: downline list will remain closed
*/
BEGIN
	SET NOCOUNT ON;
		
	CREATE TABLE #Result (roleid TINYINT,username VARCHAR(30))
	DECLARE @roleid TINYINT,
			@rowstart INT,
			@rowend INT
	
	SELECT @RowStart = @PageSize * @PageIndex + 1, @RowEnd = @RowStart + @PageSize - 1 	
	
	SELECT @roleid = roleid 
	FROM dbo.CustInfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @roleid = 4
	BEGIN
		;WITH t as(
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo 
		FROM dbo.CustInfo ci WITH(NOLOCK)
			INNER JOIN dbo.CustProductStatus cs WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newCloseInfo = 0) 
						OR (@isAffected = 0 AND newCloseInfo > 0) THEN 1 ELSE 0 END
			AND roleid = CASE WHEN @DownlineRoleid = 0 THEN roleid ELSE @DownlineRoleid END		
	END
	ELSE IF @roleid = 3
	BEGIN
		;WITH t as(
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo 
		FROM dbo.CustInfo ci WITH(NOLOCK)
			INNER JOIN dbo.CustProductStatus cs WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE mrecommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newCloseInfo = 0) 
						OR (@isAffected = 0 AND newCloseInfo > 0) THEN 1 ELSE 0 END
			AND roleid = CASE WHEN @DownlineRoleid = 0 THEN roleid ELSE @DownlineRoleid END
	END
	ELSE IF @roleid = 2
	BEGIN
		;WITH t as(
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,0,CloseInfo)) as newCloseInfo 
		FROM dbo.CustInfo ci WITH(NOLOCK)
			INNER JOIN dbo.CustProductStatus cs WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newCloseInfo = 0) 
						OR (@isAffected = 0 AND newCloseInfo > 0) THEN 1 ELSE 0 END
			AND roleid = CASE WHEN @DownlineRoleid = 0 THEN roleid ELSE @DownlineRoleid END
	END
	
	SELECT @TotalRows = COUNT(1)
	FROM #Result
	
	SELECT roleid, username
	FROM(
	SELECT ROW_NUMBER() OVER(ORDER by roleid desc, username) rn, *
	FROM #Result
	)t
	WHERE rn BETWEEN @RowStart AND @RowEnd
	
END	
GO