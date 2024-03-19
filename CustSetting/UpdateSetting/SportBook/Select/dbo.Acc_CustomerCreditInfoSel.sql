/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerCreditInfoSel]
	@RefCust NVARCHAR(50)
/*
	Created: 20230306@Johnson
	Task :  Get Credit available of new customer
	DB: DBCUST/CustDB
	Original: Acc_CustomerSelSAgentInfo/Acc_CustomerSelMAgentInfo
	
	Revisions:
		- 20230306@Johnson: get Credit available of new customer for clone account [redmine: #183697]
*/	
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleid TINYINT,		
		@UplineID INT,
		@Credit MONEY = 0,
		@UplineCredit MONEY = 0,
		@Credit_AllDownlines MONEY = 0,
		@Credit_Max MONEY = 0		
		
	SELECT @Credit = Credit,		
		@roleid = roleid,
		@UplineID = CASE WHEN roleid = 1 THEN recommend 
						WHEN roleid = 2 THEN mrecommend  
						WHEN roleid = 3 THEN srecommend END
	FROM custinfo WITH(NOLOCK)
	WHERE username = @RefCust
	
	SELECT @UplineCredit = Credit 
	FROM  custinfo WITH(NOLOCK)
	WHERE custid = @UplineID
	
	IF @roleid = 3
	BEGIN
		SELECT @Credit_AllDownlines = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE srecommend = @UplineID 
			AND RoleID = 3
			
		IF @UplineID <= 100
		BEGIN
			--Set unlimited for dummy super
			SELECT @Credit_Max = 10000000000
		END
		ELSE
		BEGIN
			SELECT @Credit_Max = @UplineCredit - @Credit_AllDownlines
		END	
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT @Credit_AllDownlines = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE mrecommend = @UplineID 
			AND RoleID = 2
		
		SELECT @Credit_Max = @UplineCredit - @Credit_AllDownlines	
	END
	ELSE IF @roleid = 1
	BEGIN
		DECLARE @MaxCredit_Mem MONEY 
		
		SELECT @Credit_AllDownlines = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE recommend = @UplineID 
			AND RoleID = 1
		
		SELECT @Credit_Max = @UplineCredit - @Credit_AllDownlines	
		
		SELECT @MaxCredit_Mem = isnull(maxcredit,0) 
		FROM CustAgent WITH (NOLOCK) 
		WHERE CustID = @UplineID 
		
		SELECT @Credit_Max = CASE WHEN @MaxCredit_Mem = 0 THEN @Credit_Max 
								WHEN @MaxCredit_Mem > @Credit_Max THEN @Credit_Max
							 ELSE @MaxCredit_Mem END 							 	
	END
	
	SELECT @Credit Credit, @Credit_Max as Credit_Max
END