/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerSelEditSuperGoldDeluxe]    
    @custid  INT    
AS    
 /*    
  Created: Kathy    
  Date: 20150424    
  Task: Company edits super's gold deluxe setting    
  DB: DBCUST.CustDB  
      
  Revisions:    
	- 20150612@Kathy: Move sp from DBAGE.bodb02 to DBCUST.CustDB [Redmine:#36216]
	- 20150721@Patrick: Add more winlimit section
	- 20170421@Helen: Enable Downline FishingWorld checkbox is ticked & disabled control although Member is disabled [RedmineID: #74421]
	- 20170921@Johnson: Fix the unsynchronized setting,fix @Downline status to show checkbox enable downline [Redmine: #72973]
							+@Downline = 1: has at least one customer has sync status
										=0 : all downlines not sync	
	- 20180109@Johnson: remove Downlines status for new direction [Redmine:#87328]	
	- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]								
  Parameters Explanations:    
       
 */    
BEGIN
        
    SET NOCOUNT ON    
        
    DECLARE @min_spositiontaking    SMALLMONEY    
            ,@DisableGoldDeluxe     BIT 
    
	SELECT    @DisableGoldDeluxe = DisableGoldDeluxe
    FROM    dbo.custInfo WITH(NOLOCK)
    WHERE    custid = @custid
        
    SELECT    @min_spositiontaking = minpositiontaking    
    FROM    dbo.CustOverrideGame WITH(NOLOCK)    
    WHERE    custid = @custid 
            AND sporttype = 255 
            AND bettype = 1701  
    
    --Customer Info
    SELECT   c.username
            ,c.username2 AS nickname
            ,c.firstname
            ,c.lastname
            ,c.phone
            ,c.mobilephone
            ,c.fax
            ,0                                	AS DisableUpline
            ,ISNULL(@DisableGoldDeluxe,1)		AS DisableGoldDeluxe  
			,ISNULL(NULLIF(c.site,''), ag.site) AS Site          
    FROM    dbo.Customer c WITH (NOLOCK)
		LEFT JOIN dbo.Customer ag WITH (NOLOCK) ON c.recommend = ag.custid
    WHERE   c.custID = @CustID           
         
     --PT & commission
     SELECT    ISNULL(@min_spositiontaking,0)    AS v255spositiontaking_1701_min,    
            gs.MaxPositiontaking            AS v255spositiontaking_1701_max,    
            cs.spositiontaking                AS v255spositiontaking_1701,    
            cs.sdiscount                    AS v255sdiscount_1701,    
            gs.Maxsdiscount                    AS v255sdicount_1701_max    
     FROM    dbo.CustSettingGame cs WITH(NOLOCK)
     INNER JOIN dbo.ProductGlobalSetting gs WITH (NOLOCK)
        ON    gs.Sporttype =  cs.Sporttype 
            AND gs.IsDep = 0
     WHERE custid = @custid 
            AND cs.sporttype = 255 
            AND cs.bettype = 1701    
            
    -- bet setting
    EXEC dbo.Acc_CustomerSelStakeLevelGoldDeluxe
        @custid        = @custid
        ,@UplineId    = @custid

	--Winlimit section
	EXEC dbo.Acc_CustomerWinLimitSelEdit @CustId = @CustId
		, @SportType = 255
		, @BetType = 1701
        
END
GO