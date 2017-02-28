ALTER PROCEDURE [dbo].[Dot_Member_Custsetting_DCS]  
 @CustID   INT,  
 @Sporttype  INT,  
 @Bettype  INT,  
 @liveindicator BIT = 0,  
 @isLicensee  BIT = 0  
AS  
/*  
 Created: Elodie  
 Date: 20150901  
 Task: Get player's setting when user place bet  
 DB: DBCUST/CustDB  
 Original versions:   
          
 Revision:  
                                   
 Parameter's Explanation:        
 Ex:  EXEC Dot_Member_Custsetting_DCS  
   @CustID = 14425599,   
   @Sporttype = 122,  
   @Bettype = 30002,    
   @liveindicator = 0,      
  
*/  
BEGIN  
 SET NOCOUNT ON    
 DECLARE @apositiontaking SMALLMONEY, @mpositiontaking SMALLMONEY, @spositiontaking SMALLMONEY,
			@minbet MONEY, @maxbet MONEY, @IsGrouped BIT
			,@SuperID INT
			, @MasterID INT
			, @AgentID INT
 IF @isLicensee = 0  
 BEGIN    
		SELECT @SuperID = ISNULL(srecommend, 0)
			, @MasterID = ISNULL(mrecommend, 0)
			, @AgentID = ISNULL(recommend, 0)
		FROM custinfo WITH (NOLOCK)
		WHERE custid = @custid
		
		--Get PT Mode
		SELECT @IsGrouped = ISNULL(IsGrouped,0)
		FROM dbo.CustSettingMode3rd WITH(NOLOCK)
		WHERE CustID = @CustID
		
		--PT
		IF @IsGrouped = 0
		BEGIN		
			SELECT @apositiontaking = ISNULL(pt.AgentPT,0) / 100.0
				, @mpositiontaking = ISNULL(pt.MasterPT,0) / 100.0
				, @spositiontaking = CASE 
					WHEN @SuperID <= 100
						THEN 0
					ELSE ISNULL(pt.SuperPT,0) / 100.0
					END
			FROM dbo.CustPTSetting3rd_Member pt WITH (NOLOCK)	
			WHERE pt.custid = @custid
				AND pt.BetType = @bettype
				AND pt.SportType = @Sporttype
				AND pt.IsLive = CASE WHEN @Sporttype IN (44) THEN pt.IsLive ELSE @liveindicator END
		END	
		ELSE
		BEGIN		
			SELECT @apositiontaking = ISNULL(pt.AgentPT,0) / 100.0
				, @mpositiontaking = ISNULL(pt.MasterPT,0) / 100.0
				, @spositiontaking = CASE 
					WHEN @SuperID <= 100
						THEN 0
					ELSE ISNULL(pt.SuperPT,0) / 100.0
					END
			FROM dbo.CustPTGroupSetting3rd_Member pt WITH (NOLOCK)	
			WHERE pt.AgentID = @AgentID
				AND pt.BetType = @bettype
				AND pt.SportType = @Sporttype
				AND pt.IsLive = CASE WHEN @Sporttype IN (44) THEN pt.IsLive ELSE @liveindicator END
		END
   
   --Bet Limit
	IF @Sporttype = 44
	BEGIN
		SELECT  @MinBet = ISNULL(minbet, 0)
			, @Maxbet = ISNULL(maxbet, 0)
		FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
		WHERE bs.custid = @custid
			AND bs.BetType = 3
			AND bs.SportType = @Sporttype
	END
   
   
 END  
 ELSE   
 BEGIN  
		IF @sporttype = 44
			SELECT @bettype = 3
			
		SELECT  
			@apositiontaking = IsNull (apositiontaking,0),   
			@mpositiontaking = IsNull (mpositiontaking,0),  
			@spositiontaking = ISNULL (spositiontaking,0),  
			@minbet = IsNull(minbet,0),  
			@maxbet = IsNull(maxbet,0) 
	   FROM dbo.Dep_CustSetting (nolock)  
	   WHERE custid =@custid    
			AND bettype=@bettype   
			AND sporttype=@sporttype  

 END  
 
	SELECT @apositiontaking apositiontaking,@mpositiontaking mpositiontaking
			,@spositiontaking spositiontaking,@minbet minbet,@maxbet maxbet
END
GO
GRANT EXECUTE ON [dbo].[Dot_Member_Custsetting_DCS] TO [Dot_Member] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Dot_Member_Custsetting_DCS] TO [vnteam] AS [dbo]