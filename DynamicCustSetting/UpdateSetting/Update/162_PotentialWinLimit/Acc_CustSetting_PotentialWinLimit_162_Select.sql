/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_PotentialWinLimit_162_Select] 
	@CustID INT,
    @SettingStatus TINYINT = 0    
AS
/*
    Created by: 20250509@Johnson	
    Task: Select Potential Win Limit for create member
    DB: DBCUST.CustDB
    
    Revisions:
        - 20250509@Johnson: initial sp [redmine: #226060]
        - 20250731@Johnson: Include Parlay for Potential Win Limit [RedmineID: #233805]
        
    Parameter's explaination:
*/  
BEGIN
    SET NOCOUNT ON
    DECLARE @SettingType INT = 30,
            @siteid SMALLINT=0,
	        @currency SMALLINT=0
            
    DECLARE @tblSportBettype TABLE
    (
        Sporttype SMALLINT, Bettype INT        
    )

    SELECT @siteid = s.siteid, 
        @currency = c.currency
    FROM customer c WITH(NOLOCK)
        INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site   
    WHERE custid = @CustID


    INSERT INTO @tblSportBettype(Sporttype, Bettype)
    SELECT Sporttype, Bettype
    FROM dbo.f_CustSetting_ProductProfileSel (@SettingType,@SettingStatus,@SiteID,@Currency)  
   
    SELECT cs.Sporttype, cs.Bettype, PotentialWinLimit WinLimit, IsAutoReset, dbo.f_CustPotentialWinLimit_GetOfferOption(cs.OfferOption, 1) IncludeParlay
    FROM dbo.CustPotentialWinLimit cs WITH(NOLOCK)
        INNER JOIN @tblSportBettype t ON cs.Sporttype = t.Sporttype AND cs.Bettype = t.Bettype
    WHERE CustID = @CustID    
END