/*<info serverAlias="DBCUST-CustDB" selecters="" viewers="" isFunction="1"></info>*/  
CREATE FUNCTION dbo.f_CustSetting_GetOfferPTLimit (@SportType INT , @BetType INT)  
RETURNS BIT  
AS  
/*    
 Created by: Helios    
 Date: 2024/04/24    
 Task: Get data Offer Limit PT : Just offer for RNG Casino 
 DB: DBCUST-CustDB  
 Original:     
     
 Revisions:    
  - 20240314@Helios: Unify Live RNG Casino [Redmine: #198960]
 Explanation's Param:     
 Examples:  
    
 SELECT * FROM f_CustSetting_GetSportOfferPTLimit()  
*/  
BEGIN
	DECLARE @IsOffer BIT


	IF (@Sporttype = 9906 AND @Bettype = 4001) ----OR (@Sporttype = 9918 AND @Bettype = 4601) 
	BEGIN
		SELECT @IsOffer = 1
		RETURN @IsOffer

	END
	
	SET @IsOffer = 0
	RETURN @IsOffer
END
	