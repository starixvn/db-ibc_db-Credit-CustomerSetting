ALTER PROCEDURE [dbo].[Age_CustomerSelCheckBelonging_MultiCust]
	@SessionCustID INT, --uplineID	
	@subAccountID INT = 0,
	@isActive BIT = 1 OUTPUT,
	@custid VARCHAR(4000),
	@roleid TINYINT OUTPUT --0: not belonged to
AS
/*
Created:20111011@TOM
Task: check downline belonging
DB: DB053.bodb02
Original: [Age_CustomerSelCheckBelonging]
	
Revisions:
   - 20150225@Lukas: add subaccountID 
*/
SET NOCOUNT ON
DECLARE @tblCust TABLE (CustID INT )
DECLARE @Cust_UP INT, @Cust_DO INT

INSERT INTO @tblCust (CustID )
SELECT CONVERT(INT,val) FROM dbo.strSplit(@custid,'^') 

SELECT @Cust_DO = @@Rowcount ;	 

SELECT @Cust_UP = COUNT(c.CustID), @roleid  = c.roleid
FROM custInfo c WITH(NOLOCK)
INNER JOIN @tblCust tbl 
	ON c.custid = tbl.CustID
WHERE (c.srecommend = @SessionCustID
		OR c.mrecommend = @SessionCustID
		OR c.recommend = @SessionCustID 
		)
GROUP BY c.roleid

IF (@Cust_DO <> @Cust_UP) OR @Cust_UP IS NULL
	SET @roleid = 0

if @SubAccountID <> 0
BEGIN
	SELECT @isActive = CASE WHEN closed = 0 THEN 1 ELSE 0 END 
	FROM dbo.custSub WITH(NOLOCK) 
	WHERE subaccID = @SubAccountID AND custid = @SessionCustID
END
ELSE 
BEGIN
	SELECT @isActive = CASE WHEN closed = 1 OR Enabled = 0 THEN 0 ELSE 1 END
	FROM dbo.custinfo WITH(NOLOCK) 
	WHERE custid = @SessionCustID
END 

SELECT	@roleid = ISNULL(@roleid, 0),
		@isActive = ISNULL(@isActive,0)

GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_MultiCust] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_MultiCust] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_MultiCust] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Age_CustomerSelCheckBelonging_MultiCust] TO [bodbDownlineNetView]
GO
GRANT VIEW DEFINITION ON [dbo].[Age_CustomerSelCheckBelonging_MultiCust] TO [vnteam]