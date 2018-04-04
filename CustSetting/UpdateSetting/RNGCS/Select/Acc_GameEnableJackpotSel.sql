/*<info serverAlias="DBCUST-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_GameEnableJackpotSel]
    @custid INT, --member
    @checkSync BIT = 1,
    @isTest BIT = 0
AS
/*
	Created: 20180206@Vicky
	Task: select Progressive Jackpot list
	DB: DBCUST.CustDB
	Original:

*/
BEGIN
    SET NOCOUNT ON
    
    DECLARE @var_siteid INT, @var_curr INT, @var_casino_sync BIT

    SELECT @var_curr = c.currency, @var_siteid = s.siteid, @var_casino_sync = ci.SyncCasino
    FROM customer c WITH (NOLOCK)
        LEFT JOIN  customer ca WITH (NOLOCK) ON c.recommend = ca.custid
        INNER JOIN custInfo ci WITH (NOLOCK) ON c.custid = ci.custid
        INNER JOIN [site]   s  WITH (NOLOCK) ON s.[site] = (CASE WHEN c.roleid = 1 THEN ca.[site] ELSE c.[site] END)
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
            --check sync casino
            AND (@checkSync = 0 OR (gls.SportType <> 208 OR @var_casino_sync = 1))

END
GO
