/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_BlockNewCust_Check]
	@Site NVARCHAR(50) = '',
	@BlockNewCust BIT = 0 OUTPUT , 
	@UnblockTime VARCHAR(50) = '' OUTPUT
AS
/*
Created: 20200407@Eden
Task :  check Block new cust
DB: DBCUST/CustDB
Original:  
Revisions:
    - 20200407@Eden: Block to add new customer by site [Redmine: #131758]
*/
BEGIN
	SELECT @BlockNewCust = BlockNewCust, @UnblockTime = UnblockTime FROM dbo.[Site_BlockNewCust] WITH (NOLOCK) WHERE site = @Site
END
GO