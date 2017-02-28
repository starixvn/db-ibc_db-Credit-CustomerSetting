ALTER PROCEDURE [dbo].[Dot_Member_CheckCustSetting_DCS] @CustID INT
	, @Sporttype INT
	, @Bettype INT
	, @liveindicator BIT = 0
	, @isLicensee BIT = 0
	, ----Identify deposit customer  
	@ActualRate FLOAT = -1
	, --Dot_Member_CustCreditInfo  
	@VirtualRate FLOAT = -1
	, --Dot_Member_CustCreditInfo  
	@Stake MONEY = -1
	, @IsPhoneBetting BIT = 0
	, @IsThirdParty BIT = 0
AS
/*  
 Created: Elodie  
 Date: 20150901  
 Task: Get player's setting when user place bet  
 DB: DBCUST/CustDB  
 Original versions:   
          
 Revision:  
                                   
 Parameter's Explanation:        
 Ex:    EXEC Dot_Member_CheckCustSetting_DCS   
   @CustID = 14425599,   
   @Sporttype = 122,  
   @Bettype = 30002,    
   @liveindicator = 0,      
   @ActualRate = 0.1,    
   @VirtualRate = 0.1,   
   @Stake = 100,      
   @IsPhoneBetting = 0,   
   @IsThirdParty = 0   
    
  
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserName NVARCHAR(30)
		, @apos SMALLMONEY
		, @mpos SMALLMONEY
		, @spos SMALLMONEY
		, @tpos SMALLMONEY
		, @MinBet MONEY
		, @MaxBet MONEY
		, @MaxperMatch MONEY
		, @Stake_To_Company FLOAT
		, @Stake_To_Company_Autobookie FLOAT
		, @PlayerComm DECIMAL(9, 8)
		, @AgentComm DECIMAL(9, 8)
		, @MasterComm DECIMAL(9, 8)
		, @SuperCommm DECIMAL(9, 8)
		, @SuperID INT
		, @MasterID INT
		, @AgentID INT
		, @AutoSuspend BIT
		, @Currency INT
		, @Result VARCHAR(50)
		, @Danger BIT
		, @DoubleCommLosing BIT
		, @IsGrouped BIT

	IF @isLicensee = 0
	BEGIN
		SELECT @UserName = username
			, @AutoSuspend = ISNULL(AutoSuspend2, 0)
			, @Currency = currency
			, @SuperID = ISNULL(srecommend, 0)
			, @MasterID = ISNULL(mrecommend, 0)
			, @AgentID = ISNULL(recommend, 0)
			, @Danger = ISNULL(dangercust, 0)
			, @DoubleCommLosing = DoubleCommLosing
		FROM custinfo WITH (NOLOCK)
		WHERE custid = @custid

		--Get PT Mode
		SELECT @IsGrouped = ISNULL(IsGrouped,0)
		FROM dbo.CustSettingMode3rd WITH(NOLOCK)
		WHERE CustID = @CustID
		
		--PT
		IF @IsGrouped = 0
		BEGIN		
			SELECT @apos = ISNULL(pt.AgentPT,0) / 100.0
				, @mpos = ISNULL(pt.MasterPT,0) / 100.0
				, @spos = CASE 
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
			SELECT @apos = ISNULL(pt.AgentPT,0) / 100.0
				, @mpos = ISNULL(pt.MasterPT,0) / 100.0
				, @spos = CASE 
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
		
		--Commission
		IF @Sporttype = 44
		BEGIN
			--Group A,B,C,D
			SELECT @PlayerComm = ISNULL(PlayerDiscount, 0)
				, @AgentComm = ISNULL(discount, 0)
				, @MasterComm = ISNULL(adiscount, 0)
				, @SuperCommm = ISNULL(CASE 
						WHEN @SuperID <= 100
							THEN adiscount
						ELSE sdiscount
						END, 0)
			FROM dbo.custsetting com WITH(NOLOCK)
			WHERE com.custid = @custid
				AND com.BetType = 1
				AND com.SportType = 1
		END
		ELSE
		BEGIN
			SELECT @PlayerComm = ISNULL(PlayerDiscount, 0)
				, @AgentComm = ISNULL(AgentDiscount, 0)
				, @MasterComm = ISNULL(MasterDiscount, 0)
				, @SuperCommm = ISNULL(CASE 
						WHEN @SuperID <= 100
							THEN MasterDiscount
						ELSE SuperDiscount
						END, 0)
			FROM dbo.CustDiscount3rd_Member com WITH(NOLOCK)
			WHERE com.custid = @custid
				AND com.BetType = @bettype
				AND com.SportType = @Sporttype
		END
		
		
		--Bet Limit
		IF @Sporttype = 44
		BEGIN
			SELECT  @MinBet = ISNULL(minbet, 0)
				, @Maxbet = ISNULL(maxbet, 0)
				, @MaxperMatch = ISNULL(MaxPerMatch, 0)
			FROM dbo.CustBetSetting3rd_Member bs WITH (NOLOCK)
			WHERE bs.custid = @custid
				AND bs.BetType = 3
				AND bs.SportType = @Sporttype
		END
			
		IF (
				@@rowcount = 0
				OR @@error <> 0
				)
		BEGIN
			SET @result = 'userinfonotfound'
		END
		ELSE
		BEGIN
			IF (
					@isPhoneBetting = 0
					AND @isThirdParty = 0
					)
			BEGIN
				IF @bettype = 10
					SET @MinBet = @MinBet / 4
				ELSE IF @bettype NOT IN (1, 3, 7, 8)
					SET @MinBet = @MinBet / 3

				IF (@stake > @Maxbet
					OR @stake < @MinBet) AND @stake >= 0
				BEGIN
					SET @result = 'stakeproblem'
				END
			END
		END

		-- 2009-4-5(Michael): Virtual Currency to apply only to these bettype  1,3,7,8,5,15,20 (Vivi)  
		-- 20110702@Thien: add back filter to NOT apply virtualrate for licensees' tickets  
		-- 2011-09-28@Viet: apply virtual rate for BA deposit customers.  
		-- 2011-10-15@Joe&Thien: add back the virtual rate for deposit tickets  
		-- 2013-08-29@TWJoe(DBTRANS):requirement from Viet: from OP, only HDP, OU, OE, 1st HDP, 1st OU, 1st OE need to apply Virtual Rate.  
		SELECT @VirtualRate = CASE 
				WHEN @bettype NOT IN (1, 2, 3, 7, 8, 12)
					THEN @ActualRate
				ELSE @virtualrate * @ActualRate
				END
			, @tpos = @apos + @mpos + @spos

		IF (@tpos > 95)
		BEGIN
			SET @result = 'positiontakingproblem'
		END

		-- 2011-10-15@Joe&Thien: exclusion the virtual rate for Autobookie function only  
		SET @Stake_To_Company_Autobookie = @Stake * (1 - @tpos) * @ActualRate
		SET @Stake_To_Company = @Stake * (1 - @tpos) * @virtualrate

		SELECT @username AS username
			, @apos AS apos
			, @mpos AS mpos
			, @spos AS spos
			, @tpos AS tpos
			, @MinBet AS minbet
			, @MaxBet AS maxbet
			, @MaxperMatch AS maxpermatch
			, @PlayerComm AS playerdiscount
			, @AgentComm AS adiscount
			, @MasterComm AS mdiscount
			, @SuperCommm AS sdiscount
			, @Stake_To_Company AS stake_to_company
			, @Stake_To_Company_Autobookie AS stake_to_company_autobookie
			, @Bettype AS CustSettingBettype
			, @Sporttype AS CustSettingSporttype
			, @VirtualRate AS virtualrate
			, @AutoSuspend AS autosuspend
			, @SuperID AS srecommend
			, @MasterID AS mrecommend
			, @AgentID AS recommend
			, @currency AS currency
			, IsNull(@result, '') AS result
			, @actualrate AS actualrate
			, @danger AS danger
			, @DoubleCommLosing AS DoubleCommLosing
	END
	ELSE
	BEGIN
		SELECT @UserName = username
			, @AutoSuspend = ISNULL(AutoSuspend2, 0)
			, @Currency = currency
			, @SuperID = ISNULL(srecommend, 0)
			, @MasterID = ISNULL(mrecommend, 0)
			, @AgentID = ISNULL(recommend, 0)
			, @Danger = ISNULL(dangercust, 0)
			, @DoubleCommLosing = DoubleCommLosing
		FROM custinfo WITH (NOLOCK)
		WHERE custid = @custid
		
		--Bet Limit
		SELECT  @MaxperMatch = MaxPerMatch44
		FROM dbo.custInfo WITH(NOLOCK)
		WHERE custid = @custid
		
		
		IF @sporttype = 44
			SELECT @bettype = 3
				
		SELECT  
			@apos = IsNull (apositiontaking,0),   
			@mpos = IsNull (mpositiontaking,0),  
			@spos = ISNULL (spositiontaking,0),  
			@minbet = IsNull(minbet,0),  
			@maxbet = IsNull(maxbet,0),  
			@PlayerComm = IsNull(playerdiscount,0),  
			@AgentComm = IsNull(discount,0),  
			@MasterComm = IsNull(adiscount,0),  
			@SuperCommm = IsNull(sdiscount,0)  
	   FROM dbo.Dep_CustSetting (nolock)  
	   WHERE custid =@custid    
		AND bettype=@bettype   
		AND sporttype=@sporttype   
		
		IF (
				@@rowcount = 0
				OR @@error <> 0
				)
		BEGIN
			SET @result = 'userinfonotfound'
		END
		ELSE
		BEGIN
			IF (
					@isPhoneBetting = 0
					AND @isThirdParty = 0
					)
			BEGIN
				IF @bettype = 10
					SET @MinBet = @MinBet / 4
				ELSE IF @bettype NOT IN (1, 3, 7, 8)
					SET @MinBet = @MinBet / 3

				IF (@stake > @Maxbet
					OR @stake < @MinBet) AND @stake >= 0
				BEGIN
					SET @result = 'stakeproblem'
				END
			END
		END

		SELECT @VirtualRate = CASE 
				WHEN @bettype NOT IN (1, 2, 3, 7, 8, 12)
					THEN @ActualRate
				ELSE @virtualrate * @ActualRate
				END
			, @tpos = @apos + @mpos + @spos

		IF (@tpos > 95)
		BEGIN
			SET @result = 'positiontakingproblem'
		END
		
		SET @Stake_To_Company_Autobookie = @Stake * (1 - @tpos) * @ActualRate
		SET @Stake_To_Company = @Stake * (1 - @tpos) * @virtualrate

		SELECT @username AS username
			, @apos AS apos
			, @mpos AS mpos
			, @spos AS spos
			, @tpos AS tpos
			, @MinBet AS minbet
			, @MaxBet AS maxbet
			, @MaxperMatch AS maxpermatch
			, @PlayerComm AS playerdiscount
			, @AgentComm AS adiscount
			, @MasterComm AS mdiscount
			, @SuperCommm AS sdiscount
			, @Stake_To_Company AS stake_to_company
			, @Stake_To_Company_Autobookie AS stake_to_company_autobookie
			, @Bettype AS CustSettingBettype
			, @Sporttype AS CustSettingSporttype
			, @VirtualRate AS virtualrate
			, @AutoSuspend AS autosuspend
			, @SuperID AS srecommend
			, @MasterID AS mrecommend
			, @AgentID AS recommend
			, @currency AS currency
			, IsNull(@result, '') AS result
			, @actualrate AS actualrate
			, @danger AS danger
			, @DoubleCommLosing AS DoubleCommLosing
	END
END
GO
GRANT EXECUTE ON [dbo].[Dot_Member_CheckCustSetting_DCS] TO [Dot_Member] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Dot_Member_CheckCustSetting_DCS] TO [vnteam] AS [dbo]