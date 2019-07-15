/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION f_CS_GetEditablePTDate(@ProductID TINYINT) 
RETURNS TABLE 
/*
    Created: Elodie
    Date: 20181212
    Task: Get date which user can edit PT setting (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]
    Example:
		SELECT * FROM f_CS_GetEditablePTDate(1)
*/
RETURN
	--DECLARE @NextDayID INT  = 0 -- 0=Mon, 1=Tue, 2 = Wed, ..., 5=Sat, 6=Sun
	--SELECT DATEADD(HOUR,7,DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID))

	SELECT DATEADD(HOUR,7,DATEADD(DAY, (DATEDIFF(DAY, 0, DATEADD(HOUR, -7, GETDATE())) / 7) * 7 + 7, 0)) AS EffectiveDate, 
		CASE WHEN GETDATE() BETWEEN DATEADD(DAY, (DATEDIFF(DAY, 0, DATEADD(HOUR, -7, GETDATE())) / 7) * 7 + 7, 0)- 1 AND DATEADD(HOUR,7,DATEADD(DAY, (DATEDIFF(DAY, 0, DATEADD(HOUR, -7, GETDATE())) / 7) * 7 + 7, 0)) THEN 1 ELSE 0 END IsEditablePT		
		--1 AS IsEditablePT
	WHERE @ProductID = 1
