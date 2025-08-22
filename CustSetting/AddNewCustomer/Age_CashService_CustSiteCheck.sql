/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv,asv_CashService"  viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE dbo.Age_CashService_CustSiteCheck
	@Site			NVARCHAR(50),
    @IsOffered      TINYINT OUTPUT
AS 
/* 
	Created By: Dave
	Created Date: 2025-08-21
	Description: Agency Cash Service - Check if Site is offered Cash Service [Redmine #236597]
	DB: DBCust.CUSTDB
	
	Revisions:
		- 20250821@Dave: Performance: SQL issue - SPs LimitCreatedAccount[Redmine: #236597]

	Param:
		exec Age_CashService_CustSiteCheck	@Site =  '222227' 

*/  
BEGIN
	SET NOCOUNT ON;
	     
	SELECT @IsOffered  = 0;

	IF EXISTS (	SELECT TOP(1) 1
        FROM GlobCustDB.dbo.Site s WITH (NOLOCK)
        INNER JOIN AgencyCashService.dbo.CashBankConfig csc WITH (NOLOCK) ON s.siteid = csc.SiteId
        WHERE s.Site = @Site)
	BEGIN
		SET @IsOffered = 1;
	END

END
