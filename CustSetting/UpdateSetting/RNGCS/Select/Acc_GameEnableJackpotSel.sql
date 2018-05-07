/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_GameEnableJackpotSel]
    @custid INT, --member
    @isTest BIT = 0
AS
/*
    Created: 20180206@Vicky
    Task: select Progressive Jackpot list
    DB: DBCUST.CustDB
    
    Revisions:
        - 20180507@Vicky: Remove hardcode to show JP for UUS acc [Redmine: #89952]
    
    Param's Explanation:
        - @custid: Member & SMA

*/
BEGIN
    SET NOCOUNT ON
    
    DECLARE @var_siteid INT, @var_curr INT

    SELECT @var_curr = c.currency, @var_siteid = s.siteid
    FROM customer c WITH (NOLOCK)
        LEFT JOIN  customer ca WITH (NOLOCK) ON c.recommend = ca.custid
        INNER JOIN [site] s    WITH (NOLOCK) ON s.[site]    = (CASE WHEN c.roleid = 1 THEN ca.[site] ELSE c.[site] END)
    WHERE c.custid = @custid
    
    SELECT sbm.productid, gls.SportType, gls.BetType
    FROM GameLaunchPerCurrency glc
        INNER JOIN GameLaunchPerSite gls                   ON gls.SportType = glc.SportType AND gls.BetType = glc.BetType
        INNER JOIN DBAGE.bodb02.dbo.SportBettypeMatrix sbm ON sbm.SportType = glc.SportType AND sbm.BetType = glc.BetType
    WHERE   glc.IsLaunched = 1 
            AND gls.IsLaunched = 1
            AND glc.currency = @var_curr
            AND gls.siteID = @var_siteid
            AND glc.isTest <= @isTest
            AND gls.isTest <= @isTest

END
GO
