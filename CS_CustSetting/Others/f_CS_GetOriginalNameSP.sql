/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetOriginalNameSP](@SPName VARCHAR(50)) 
RETURNS VARCHAR(50) 
/*
    Created: Elodie
    Date: 20181212
    Task: Get original SP name (CS Customer Setting)
    DB: DBCUST/CustDB
    Original versions:                
    Revision:
		- 20181212@Elodie: Initial SP [Redmine: #105338]
    Example:
		SELECT dbo.f_CS_GetOriginalNameSP('CS_CustSetting_CommBetSetting_Upd_xpre')
*/
AS
BEGIN
	SELECT @SPName = CASE	WHEN @SPName LIKE '%_xtest' THEN REPLACE(@SPName,'_xtest','') 
							WHEN @SPName LIKE '%_xpre' THEN REPLACE(@SPName,'_xpre','') 
							WHEN @SPName LIKE '%_UAT1' THEN REPLACE(@SPName,'_UAT1','') 
							WHEN @SPName LIKE '%_UAT2' THEN REPLACE(@SPName,'_UAT2','') 
							WHEN @SPName LIKE '%_UAT3' THEN REPLACE(@SPName,'_UAT3','') 
							WHEN @SPName LIKE '%_UAT4' THEN REPLACE(@SPName,'_UAT4','') ELSE @SPName END
	RETURN @SPName
END

