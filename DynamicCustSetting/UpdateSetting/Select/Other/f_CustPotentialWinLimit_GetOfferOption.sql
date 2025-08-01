/*<info serverAlias="DBCUST-AgencyCashService,DBSIC-AgencyCashService" executers="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION	[dbo].[f_CustPotentialWinLimit_GetOfferOption] (
					@OfferOption		TINYINT
				,	@bitmapOrder		TINYINT				
				)  
 RETURNS BIT
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
    RETURN (@OfferOption & POWER(2, @bitmapOrder-1))	
END