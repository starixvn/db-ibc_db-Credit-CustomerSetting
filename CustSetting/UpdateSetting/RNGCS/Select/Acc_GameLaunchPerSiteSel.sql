/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE Acc_GameLaunchPerSiteSel
   @isTest BIT = 0
AS
/*
    Created: 20221103@Elodie
    Task: select GameLaunchPerSite
    DB: DBCUST.CustDB
    
    Revisions:
        - 20221103@Elodie: Initial SP [Redmine: #179269]
    
    Param's Explanation:

*/
BEGIN
    SET NOCOUNT ON     
    
    SELECT sbm.productid, gls.SportType, gls.BetType
    FROM GameLaunchPerSite gls                   
        INNER JOIN DBAGE.bodb02.dbo.SportBettypeMatrix sbm ON sbm.SportType = gls.SportType AND sbm.BetType = gls.BetType
    WHERE gls.IsLaunched = 1 AND gls.isTest <= @isTest
END
GO
