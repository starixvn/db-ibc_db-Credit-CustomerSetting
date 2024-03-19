/*<info serverAlias="DBCUST-CUSTDB" executers="bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_ProblemAccountLimitDownlineCheck]
	@custid INT,
	@isAllowed BIT = 1 OUTPUT
AS
/*
	Created: 20210224@Johnson
	Task :  check limit downline for problem account
	DB: DBCUST/CustDB
	Original:  
	Revisions:
		- 20210224@Johnson: initial sp [Redmine: #131758]		
*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @roleid INT,
		@srecommend INT,
		@mrecommend INT,
		@today DATE,
		@cntDownlines INT = 0
	
	SET @isAllowed = 1
	
	SELECT @roleid = roleid,
		@srecommend = srecommend,
		@mrecommend = mrecommend
	FROM custinfo WITH(NOLOCK) 
	WHERE custid = @custid
	
	IF EXISTS(SELECT 1 FROM ProblemAccountLimitDownline WITH(NOLOCK) WHERE custid IN(@srecommend,@mrecommend,@custid))
	BEGIN
		SELECT @today = GETDATE()
		
		IF @roleid = 4
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer WITH(NOLOCK) 
			WHERE srecommend = @custid
				AND roleid = 3
				AND creatdate >= @today
		END
		ELSE IF @roleid = 3
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer WITH(NOLOCK) 
			WHERE mrecommend = @custid
				AND creatdate >= @today
				AND roleid = 2
		END
		ELSE IF @roleid = 2
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer WITH(NOLOCK) 
			WHERE recommend = @custid
				AND creatdate >= @today
				AND roleid = 1
		END
		
		IF (@roleid IN (3,4) AND @cntDownlines >= 3) 
			OR (@roleid = 2 AND @cntDownlines >=5)
		SELECT @isAllowed = 0
	END
END