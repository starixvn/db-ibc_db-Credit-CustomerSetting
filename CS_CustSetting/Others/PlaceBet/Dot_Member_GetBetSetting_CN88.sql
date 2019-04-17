/*<info serverAlias="DBCUST-CUSTDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Dot_Member_GetBetSetting_CN88
	@CustID INT,
	@IsTest	BIT = 0
AS  
/*  
	Created: Elodie  
	Date: 20190220
	Task: Get bet setting of CN88's customer
	DB: DBCUST/CustDB  
	Original versions:   
          
	Revision:  
		- 20181212@Elodie: Initial SP [Redmine:#105338]      
		                           
	Parameter's Explanation:    
     
	Ex:    EXEC Dot_Member_GetBetSetting_CN88 @CustID = 34044216				
  
*/
BEGIN  
	SET NOCOUNT ON    
	
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(NULL, 2, @IsTest) t

	SELECT  bs.SportType, bs.BetType, bs.IsLive,
			ISNULL(bs.MaxPerEvent, 0) AS MaxPerEvent,
			ISNULL(bs.MaxBet, 0) AS MaxBet
	FROM dbo.CS_CustBetSetting_Member bs WITH (NOLOCK)
		INNER JOIN #SportBettypeFilter2 ft ON ft.SportType = bs.SportType AND ft.Bettype = bs.BetType AND ft.IsLive = bs.IsLive
	WHERE bs.custid = @CustID	
	ORDER BY bs.SportType, bs.BetType, bs.IsLive		
 
END
