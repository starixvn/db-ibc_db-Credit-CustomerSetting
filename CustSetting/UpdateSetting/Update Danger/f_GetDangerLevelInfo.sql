/*<info serverAlias="DBCUST-CUSTDB,DBLOG-bodb_CustomerLog" executers="" viewers="" isFunction="1" isNested="1"></info>*/
ALTER FUNCTION [dbo].[f_GetDangerLevelInfo]
	(@DangerLevel BIGINT)
RETURNS TABLE
AS
/*
	Created: 20211011@Johnson
	Task : Get danger level for saba sport
	DB: DBCUST/CUSTDB,DBLOG/bodb_CustomerLog
	
	Revisions:
		- 20211011@Johnson: initial sp [redmine:#161351]
	
	Parameter's Explanation:
		- bit 0->3 for soccer(15)
		- bit 4->7 for basketball(15*2^4=240)
		- bit 8 for manual soccer
		- bit 9 for manual basketball
*/	
RETURN
SELECT @DangerLevel&15 as soccer,
		(@DangerLevel&240)/16 as basketball,
		CASE WHEN @DangerLevel&POWER(2,8) > 0 THEN 1 ELSE 0 END as IsManualSoccer,
		CASE WHEN @DangerLevel&POWER(2,9) > 0 THEN 1 ELSE 0 END as IsManualBasketball
