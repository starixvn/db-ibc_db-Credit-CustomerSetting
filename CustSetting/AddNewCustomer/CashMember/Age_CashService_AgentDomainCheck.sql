/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_CashService, asv_CashService" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Age_CashService_AgentDomainCheck]
(
	@CustId INT,
	@Domain		VARCHAR(500),
	@IsValid	BIT = 0 OUTPUT
)
AS
/*
	Created: 20250424@Elodie
	Task: Check domain is invalid [#223896]
	DB: DBCUST.AgencyCashService
	
	Revisions:
		- 20241107@Elodie: Offer Cash service [redmine: #224778]  
		
	Parameter's Explanation:
	
*/	
BEGIN
    SET NOCOUNT ON 	
	SELECT @IsValid = 1
	FROM CashDomainManagement cd WITH (NOLOCK)
		INNER JOIN GlobCustDB.dbo.DomainManagement d WITH (NOLOCK) ON cd.DomainId = d.DomainID
	WHERE AgentId = @CustId AND d.OfferType = 1
		AND d.isDeleted = 0 AND d.Status = 3
		AND cd.SubDomainPrefix + '.' + d.Domain = @Domain
END
GO