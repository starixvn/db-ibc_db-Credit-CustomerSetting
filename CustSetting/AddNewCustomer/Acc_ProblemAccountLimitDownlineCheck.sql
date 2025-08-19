/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_ProblemAccountLimitDownlineCheck]
	@custid INT,
	@isAllowed BIT = 1 OUTPUT,
	@IsDirectMember BIT = 0
AS
/*
	Created: 20210224@Johnson
	Task :  check limit downline for problem account
	DB: DBCUST/CustDB
	Original:  
	Revisions:
		- 20210224@Johnson: initial sp [Redmine: #131758]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
		- 20250730@Dave: Exclude cash members from the agent's total member count [Redmine: #235266]

	@IsDirectMember : Default = 0  , But UI create new Direct Member values = 1
*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @roleid INT,
		@srecommend INT,
		@mrecommend INT,
		@today DATE,
		@cntDownlines INT = 0,
		@cntDownlines_DirectMember INT = 0
	
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
			IF @IsDirectMember = 0 
			BEGIN
				SELECT @cntDownlines = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE srecommend = @custid
					AND roleid = 3
					AND creatdate >= @today
			END
			ELSE
			BEGIN
				SELECT @cntDownlines_DirectMember = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE srecommend = @custid
					AND recommend = -4
					AND roleid = 1
					AND creatdate >= @today
			END	
		END
		ELSE IF @roleid = 3
		BEGIN
			IF @IsDirectMember = 0
			BEGIN
				SELECT @cntDownlines = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE mrecommend = @custid
					AND creatdate >= @today
					AND roleid = 2
			END
			ELSE
			BEGIN
				SELECT @cntDownlines_DirectMember = COUNT(1) 
				FROM customer WITH(NOLOCK) 
				WHERE mrecommend = @custid
					AND recommend = -3
					AND roleid = 1
					AND creatdate >= @today
			END
		END
		ELSE IF @roleid = 2
		BEGIN
			SELECT @cntDownlines = COUNT(1) 
			FROM customer AS c WITH(NOLOCK) 
				CROSS APPLY (SELECT TOP 1 ServiceType
					FROM vw_CustInfoExtra WITH (NOLOCK)
					WHERE custid = c.custid) ci
			WHERE c.recommend = @custid
				AND c.creatdate >= @today
				AND c.roleid = 1
				AND ci.ServiceType = 0; /* Exclude Cash Service Members */
		END
		
		IF (@roleid IN (3,4) AND @cntDownlines >= 3 AND @IsDirectMember = 0) 
			OR (@roleid IN (3,4) AND @cntDownlines_DirectMember >=5 AND @IsDirectMember = 1) 
			OR (@roleid = 2 AND @cntDownlines >=5)
		SELECT @isAllowed = 0
	END
END