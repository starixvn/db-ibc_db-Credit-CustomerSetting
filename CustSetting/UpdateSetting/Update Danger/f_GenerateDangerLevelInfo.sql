/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[f_GenerateDangerLevelInfo]
	(@DangerLevel BIGINT,
	@soccer TINYINT,
	@Basketball TINYINT,
	@UpdateSoccer BIT,
	@UpdateBasketball BIT)
RETURNS BIGINT	
AS
/*
	Created: 20211012@Johnson
	Task : Generate danger level for saba sport
	DB: DBCUST/CUSTDB
	
	Revisions:
		- 20211012@Johnson: initial sp [redmine:#161351]
	
	Parameter's Explanation:
		- bit 0->3 for soccer(15)
		- bit 4->7 for basketball(15*2^4=240)
		- bit 8 for manual soccer
		- bit 9 for manual basketball
		- 1008 = set ON for all bits from 4->9
		- 783 = set ON for all bits soccer & bit 8,9
*/	
BEGIN
RETURN(
SELECT CASE WHEN @UpdateBasketball = 1 THEN 
		((CASE WHEN @updateSoccer = 1 THEN (@DangerLevel&1008)|@soccer ELSE @DangerLevel END)&783)|(@Basketball*16)
		ELSE CASE WHEN @updateSoccer = 1 THEN (@DangerLevel&1008)|@soccer ELSE @DangerLevel END
		END
	)
END		