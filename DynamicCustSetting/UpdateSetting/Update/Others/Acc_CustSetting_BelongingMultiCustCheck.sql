ALTER PROCEDURE [dbo].[Acc_CustSetting_BelongingMultiCustCheck]
	@SessionCustID INT, --uplineID	
	@custid VARCHAR(4000),
	@SpecialChar CHAR(1)=',',
	@roleid TINYINT OUTPUT --0: not belonged to
AS
/*
Created:20150108@Dominic
Task: check downline belonging
DB: DBCUST/CustDB
Original: [Age_CustomerSelCheckBelonging_MultiCust]
	
Revisions:
   
*/
SET NOCOUNT ON
DECLARE @tblCust TABLE (CustID INT )
DECLARE @Cust_UP INT, @Cust_DO INT
Declare @SessionRoleID TINYINT 

select @SessionRoleID = roleid
from custinfo with(nolock)  
where custID = @SessionCustID  
  
IF ISNULL(@sessionRoleid ,0) = 0 RETURN 

--Parse CustID List
DECLARE @XML XML
SET @XML = N'<root><r>' + REPLACE(@custid, ',', '</r><r>') + '</r></root>'
INSERT INTO @tblCust (CustID )
SELECT r.value('.','INT')
FROM @xml.nodes('//root/r') AS RECORDS(r)

SELECT @Cust_DO = @@Rowcount ;	 

SELECT @Cust_UP = COUNT(c.CustID), @roleid  = c.roleid
FROM custInfo c WITH(NOLOCK)
INNER JOIN @tblCust tbl 
	ON c.custid = tbl.CustID
WHERE (c.srecommend = @SessionCustID
		OR c.mrecommend = @SessionCustID
		OR c.recommend = @SessionCustID 
		OR @SessionRoleID >= 5
		)
GROUP BY c.roleid

IF (@Cust_DO <> @Cust_UP) OR @Cust_UP IS NULL
	SET @roleid = 0

SELECT @roleid = ISNULL(@roleid, 0)

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BelongingMultiCustCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BelongingMultiCustCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_BelongingMultiCustCheck] TO [bodbExtAccNet]