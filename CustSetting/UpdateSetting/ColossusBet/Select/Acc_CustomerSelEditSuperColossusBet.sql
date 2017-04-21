/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperColossusBet]      
(
    @custid  INT      
)
AS      
/*  
    Created: Helen  
    Date: 20150821
    Task: Super: Getting data before updating in Update Colossus Bet Module - (Redmine: #41264) 
    DB: DBCUST / CustDB
    
    
	Revisions:
		- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
		
	Parameters Explanation
	
*/ 

BEGIN  
          
    SET NOCOUNT ON      
          
    DECLARE @Downlines BIT    = 1  
            ,@DisableDownlines BIT = 0  
            ,@DisableColossusBet BIT   
          
    IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.custinfo WITH (NOLOCK) WHERE srecommend = @CustID AND roleid = 3)  
        SET @Downlines = 0      
    ELSE IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo WITH(NOLOCK) WHERE srecommend = @custid AND DisableColossusBet = 1)  
        SET @DisableDownlines = 1  
          
    SELECT  @DisableColossusBet = DisableColossusBet  
    FROM    dbo.custInfo WITH(NOLOCK)  
    WHERE   custid = @custid  
          
     
    --Customer Info  
    SELECT    username  
            ,username2 AS nickname  
            ,firstname  
            ,lastname  
            ,phone  
            ,mobilephone  
            ,fax  
            ,0 AS DisableUpline  
            ,ISNULL(@DisableColossusBet,1) AS DisableColossusBet  
            ,@Downlines AS Downlines  
            ,@DisableDownlines AS DisableDownlines  
    FROM  dbo.Customer WITH (NOLOCK)  
    WHERE custID = @CustID             
           
     -- Commission 
     
     SELECT  cs.CommRate AS v204discount_18001
			, gs.Maxsdiscount AS v204discount_18001_max      
     FROM    AgentCommRate cs WITH (NOLOCK)  
		JOIN ProductGlobalSetting gs WITH (NOLOCK) ON gs.Sporttype =  cs.Sporttype AND CS.Bettype = GS.Bettype AND gs.IsDep = 0  
     WHERE custid = @custid 
			AND cs.sporttype = 204   
            AND cs.bettype = 18001      
            
    -- Cash In Share          
    SELECT  cs.CommRate AS v204discount_18002,      
            gs.Maxsdiscount AS v204discount_18002_max      
     FROM    AgentCommRate cs WITH (NOLOCK)  
		JOIN ProductGlobalSetting gs WITH (NOLOCK) ON gs.Sporttype =  cs.Sporttype AND CS.Bettype = GS.Bettype AND gs.IsDep = 0  
     WHERE custid = @custid   
            AND cs.sporttype = 204   
            AND cs.bettype = 18002      
     
	SET NOCOUNT OFF
          
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperColossusBet] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperColossusBet] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperColossusBet] TO [bodbExtAccNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustomerSelEditSuperColossusBet] TO bodbDownlineNetView