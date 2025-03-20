/*<info serverAlias="DBGLOB-GlobCustDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE Acc_GameLaunchSel
   @isTest BIT = 0
AS
/*
    Created: 20221103@Elodie
    Task: select GameLaunchPerSite, GameLaunchPerCurrency
    DB: DBGLOB-GlobCustDB
    
    Revisions:
        - 20221103@Elodie: Initial SP [Redmine: #179269]
		- 20250224@Tacy: Move to GlobCustDB [RedmineID: #216870]
    Param's Explanation:

*/
BEGIN
    SET NOCOUNT ON     
    
    SELECT sbm.RealProductId AS  productid, gls.SportType, gls.BetType, s.site
    FROM GameLaunchPerSite gls WITH (NOLOCK)     
		INNER JOIN site s WITH (NOLOCK) ON gls.SiteID = s.siteid
        INNER JOIN dbo.SportBettypeSettingMatrix sbm WITH (NOLOCK) ON sbm.SportType = gls.SportType AND sbm.BetType = gls.BetType
																	AND sbm.islicensee=s.isLicensee and sbm.isActive=1
    WHERE gls.IsLaunched = 1 AND gls.isTest <= @isTest

	SELECT DISTINCT sbm.RealProductId AS productid, glc.SportType, glc.BetType, glc.Currency
    FROM GameLaunchPerCurrency glc WITH (NOLOCK)                 
        INNER JOIN dbo.SportBettypeSettingMatrix sbm WITH (NOLOCK) ON sbm.SportType = glc.SportType AND sbm.BetType = glc.BetType AND sbm.isActive=1
    WHERE glc.IsLaunched = 1 AND glc.isTest <= @isTest
END
GO
