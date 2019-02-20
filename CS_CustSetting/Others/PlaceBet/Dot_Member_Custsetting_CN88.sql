/*<info serverAlias="DBCUST-CUSTDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Dot_Member_Custsetting_CN88
	@CustID   INT,  
	@Sporttype  INT,  
	@Bettype  INT,  
	@liveindicator BIT = 0,  
	@isLicensee  BIT = 0  
AS  
/*  
	Created: Elodie  
	Date: 20190220
	Task: Get player's setting when user place bet for CN88 site
	DB: DBCUST/CustDB  
	Original versions:   
          
	Revision:  
		- 20181212@Elodie: Initial SP [Redmine:#105338]      
		                           
	Parameter's Explanation:    
     
	Ex:    EXEC Dot_Member_Custsetting_CN88  
				@CustID = 34044216,   
				@Sporttype = 1,  
				@Bettype = 1,    
				@liveindicator = 0    
  
*/
BEGIN  
	SET NOCOUNT ON    
	DECLARE	@apositiontaking SMALLMONEY, @mpositiontaking SMALLMONEY, @spositiontaking SMALLMONEY,
			@MaxPerEvent MONEY, @MaxBet MONEY,
			@SuperID INT, @MasterID INT, @AgentID INT

	IF @isLicensee = 0  
	BEGIN    
		SELECT @SuperID = ISNULL(srecommend, 0), @MasterID = ISNULL(mrecommend, 0), @AgentID = ISNULL(recommend, 0)
		FROM custinfo WITH (NOLOCK)
		WHERE custid = @CustID
			
		SELECT @apositiontaking = ISNULL(pt.AgentPT,0) / 100.0
			, @mpositiontaking = ISNULL(pt.MasterPT,0) / 100.0
			, @spositiontaking = CASE 
									WHEN @SuperID <= 100 THEN 0 
									ELSE ISNULL(pt.SuperPT,0) / 100.0
								END
		FROM f_CS_GetPTGroup_Member(@AgentID) pt
		WHERE pt.SportType = @Sporttype 
			AND pt.BetType = @bettype
			AND pt.IsLive = @liveindicator
   
	--Bet Limit
	SELECT  @MaxPerEvent = ISNULL(bs.MaxPerEvent, 0), 
			@MaxBet = ISNULL(bs.MaxBet, 0)
	FROM dbo.CS_CustBetSetting_Member bs WITH (NOLOCK)
	WHERE bs.custid = @CustID
		AND bs.SportType = @Sporttype
		AND bs.BetType = @bettype
		AND bs.IsLive = @liveindicator
		
	END  
 
	SELECT	@apositiontaking apositiontaking, @mpositiontaking mpositiontaking, @spositiontaking spositiontaking,
			@MaxPerEvent MaxPerEvent,@MaxBet MaxBet
END
