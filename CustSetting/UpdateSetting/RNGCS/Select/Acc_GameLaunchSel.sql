/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE Acc_GameLaunchSel
   @isTest BIT = 0
AS
/*
    Created: 20221103@Elodie
    Task: select GameLaunchPerSite, GameLaunchPerCurrency
    DB: DBCUST.CustDB
    
    Revisions:
        - 20221103@Elodie: Initial SP [Redmine: #179269]
    
    Param's Explanation:

*/
BEGIN
    SET NOCOUNT ON     
    
    SELECT sbm.productid, gls.SportType, gls.BetType, gls.SiteID
    FROM GameLaunchPerSite gls                   
        INNER JOIN DBAGE.bodb02.dbo.SportBettypeMatrix sbm ON sbm.SportType = gls.SportType AND sbm.BetType = gls.BetType
    WHERE gls.IsLaunched = 1 AND gls.isTest <= @isTest

	 SELECT sbm.productid, glc.SportType, glc.BetType, glc.Currency
    FROM GameLaunchPerCurrency glc                 
        INNER JOIN DBAGE.bodb02.dbo.SportBettypeMatrix sbm ON sbm.SportType = glc.SportType AND sbm.BetType = glc.BetType
    WHERE glc.IsLaunched = 1 AND glc.isTest <= @isTest
END
GO
