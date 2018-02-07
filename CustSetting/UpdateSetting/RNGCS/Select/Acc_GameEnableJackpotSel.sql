/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_GameEnableJackpotSel]
    @custid INT
AS
/*
Created: 20180206@Vicky
Task: select Progressive Jackpot list
DB: DBCUST.CustDB
Original:

*/
BEGIN
    SET NOCOUNT ON
    
    SELECT sm.SportType, gls.SportType, gls.BetType
    FROM customer c
        INNER JOIN GameLaunchPerCurrency glc ON glc.currency = c.currency
        INNER JOIN GameLaunchPerSite gls     ON gls.SportType = glc.SportType AND gls.BetType = glc.BetType
        INNER JOIN DBAGE.bodb02.dbo.SportBettypeMatrix sm ON sm.SportType = glc.SportType AND sm.BetType = glc.BetType
    WHERE   c.custid = @custid 
            AND glc.IsLaunched = 1 
            AND gls.IsLaunched = 1
            AND gls.site = (CASE WHEN c.site IS NOT NULL 
                            THEN c.site 
                            ELSE (SELECT cs.[site] 
                                  FROM customer cs 
                                  WHERE cs.custid = c.recommend) 
                            END)

END
GO
