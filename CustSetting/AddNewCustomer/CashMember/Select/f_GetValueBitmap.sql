/*<info serverAlias="DBCUST-AgencyCashService" selecters="" viewers="" isFunction="1"></info>*/
ALTER FUNCTION [dbo].[f_GetValueBitmap](@bitOrder TINYINT,@Value TINYINT)
RETURNS TABLE
AS 
/*
	Created by:Elodie
	Date:20250525
	Task: get bit value
	DB: DBCUST/AgencyCashService
	
	Revisions:
		- 20250525@Elodie: initial sp [redmine: #223896]
	Parameter's Explanation:
*/
	RETURN(SELECT CASE WHEN @Value&power(2,@bitOrder-1) = power(2,@bitOrder-1) THEN 1 ELSE 0 END AS BitValue)

	