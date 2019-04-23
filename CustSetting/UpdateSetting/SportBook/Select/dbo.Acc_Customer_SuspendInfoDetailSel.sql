/*<info serverAlias="DBCUST-CustDB" executers="bodbDownlineNet,bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Customer_SuspendInfoDetailSel]
	@custid INT,
	@IsAffected BIT,
	@DownlineRoleid TINYINT,
	@PageSize INT = 50,
	@PageIndex INT = 0,
	@TotalRows INT = 0 OUTPUT
AS
/*
	Created by:Johnson
	Date:2019-04-08
	Task: get list customers for suspend status
	DB: DBCUST/CustDB
	
	Revisions:
		- 20190408@Johnson: initial sp [redmine: #105587]
	Parameter's Explanation:
		- @DownlineRoleid =0: show all downline
						  <> 0:	roleid of downline to retreive customer list	
		- @isAffected: = 1: downline list will change unsuspend
					   = 0: downline list will remain suspended
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
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,1,SuspendInfo))as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newSuspendInfo > 0) 
						OR (@isAffected = 0 AND newSuspendInfo = 0) THEN 1 ELSE 0 END
			AND roleid = CASE WHEN @DownlineRoleid = 0 THEN roleid ELSE @DownlineRoleid END		
	END
	ELSE IF @roleid = 3
	BEGIN
		;WITH t as(
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,1,SuspendInfo)) as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE srecommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newSuspendInfo > 0) 
						OR (@isAffected = 0 AND newSuspendInfo = 0) THEN 1 ELSE 0 END
			AND roleid = CASE WHEN @DownlineRoleid = 0 THEN roleid ELSE @DownlineRoleid END
	END
	ELSE IF @roleid = 2
	BEGIN
		;WITH t as(
		SELECT roleid, username, (SELECT suspendInfo FROM dbo.f_GenerateSuspendInfo(@roleid,1,SuspendInfo)) as newSuspendInfo 
		FROM dbo.CustProductStatus cs WITH(NOLOCK)
			INNER JOIN dbo.CustInfo ci WITH(NOLOCK) ON cs.custid = ci.custid
		WHERE recommend = @custid	
			AND ci.custid <> @custid
		)
		INSERT INTO #Result(roleid,username)
		SELECT roleid, username 			
		FROM t
		WHERE 1 = CASE WHEN (@isAffected = 1 AND newSuspendInfo > 0) 
						OR (@isAffected = 0 AND newSuspendInfo = 0) THEN 1 ELSE 0 END
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