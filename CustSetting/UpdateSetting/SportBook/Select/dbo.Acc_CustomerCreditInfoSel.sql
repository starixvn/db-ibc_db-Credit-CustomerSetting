/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerCreditInfoSel]
	@RefCust VARCHAR(50)
/*
	Created: 20230306@Johnson
	Task :  Get Credit available of new customer
	DB: DBCUST/CustDB
	Original: Acc_CustomerSelSAgentInfo/Acc_CustomerSelMAgentInfo
	
	Revisions:
		- 20230306@Johnson: get Credit available of new customer for clone account [redmine: #183697]
		- 20240401@Elodie: The max credit per member got wrong calculation when creating multi-account [Redmine: #203180]
		- 20250328@Elodie: Get info by username2 [Redmine: #197737]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]  
		- 20250627@Dave: Add AccumCredit of AllCashMember to AgentUsedCredit [Redmine: #231524]
*/	
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @roleid TINYINT, @custid INT,	
		@UplineID INT,
		@Credit MONEY = 0,
		@UplineCredit MONEY = 0,
		@Credit_AllDownlines MONEY = 0,
		@Credit_Max MONEY = 0,		
		@MaxCredit_Mem MONEY,
		@AccumCredit_AllCashMember MONEY = 0;

	SELECT @Credit = Credit,		
		@roleid = roleid,
		@UplineID = CASE WHEN roleid = 1 THEN recommend 
						WHEN roleid = 2 THEN mrecommend  
						WHEN roleid = 3 THEN srecommend END
	FROM custinfo WITH(NOLOCK)
	WHERE username = @RefCust
	
	IF @UplineID IS NULL
	BEGIN
		SELECT @custid = custid,		
			@roleid = roleid,
			@UplineID = CASE WHEN roleid = 1 THEN recommend 
							WHEN roleid = 2 THEN mrecommend  
							WHEN roleid = 3 THEN srecommend END
		FROM customer WITH(NOLOCK)
		WHERE username2 = @RefCust

		SELECT @Credit = Credit
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @custid
	END

	SELECT @UplineCredit = Credit 
	FROM  custinfo WITH(NOLOCK)
	WHERE custid = @UplineID
	
	IF @roleid = 3
	BEGIN
		SELECT @Credit_AllDownlines = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE srecommend = @UplineID 
			AND ((RoleID = 3) OR (RoleID = 1 AND ci.recommend = -4))
			
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
			AND ((RoleID = 2) OR (RoleID = 1 AND ci.recommend = -3))
		
		SELECT @Credit_Max = @UplineCredit - @Credit_AllDownlines	
	END
	ELSE IF @roleid = 1
	BEGIN				
		SELECT @Credit_AllDownlines = ISNULL(SUM(credit), 0) 
		FROM custinfo as ci WITH (NOLOCK) 
		WHERE recommend = @UplineID 
			AND RoleID = 1
		
		SELECT @AccumCredit_AllCashMember = ISNULL(SUM(AccumCreditReturn),0)
		FROM dbo.CashAccumCredit WITH (NOLOCK)
		WHERE recommend = @UplineID;

		SELECT @Credit_Max = @UplineCredit - @Credit_AllDownlines - @AccumCredit_AllCashMember;
		
		SELECT @MaxCredit_Mem = isnull(maxcredit,0) 
		FROM CustAgent WITH (NOLOCK) 
		WHERE CustID = @UplineID 							 	
	END
	
	SELECT @Credit Credit, @Credit_Max as Credit_Max, @MaxCredit_Mem AS MaxCredit_Mem
END