/*<info serverAlias="DBCUST-AgencyCashService" executers="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	[dbo].[f_CustPotentialWinLimit_GenerateOfferOption] (
					@OfferOption		TINYINT
				,	@bitmapOrder		TINYINT
				,	@NewValue   		BIT
				)  
 RETURNS TINYINT
 AS  
/*  
	Created:	20250731@Johnson
	DB:			DBCUST/AgencyCashService  
	Original:	Generate Offer Option for Potential Win Limit [RedmineID: #233805]

	Revision:
		- 20250731@Johnson: init function [RedmineID: #233805]
	Param's Explanation:
*/  
BEGIN
    RETURN (CASE WHEN @NewValue = 1 THEN (@OfferOption | POWER(2, @bitmapOrder-1))
            ELSE (@OfferOption & ~POWER(2, @bitmapOrder-1)) END)	
END