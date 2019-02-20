/*<info serverAlias="DBCUST-CUSTDB" executers="Dot_Member" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Dot_Member_CheckCustSetting_CN88
	@CustID INT,
	@Sporttype INT,
	@Bettype INT,
	@liveindicator BIT = 0,
	@isLicensee BIT = 0, --Identify deposit customer  
	@ActualRate FLOAT = -1, --Dot_Member_CustCreditInfo  
	@VirtualRate FLOAT = -1, --Dot_Member_CustCreditInfo  
	@Stake MONEY = -1, 
	@IsPhoneBetting BIT = 0, 
	@IsThirdParty BIT = 0
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

	Ex: EXEC Dot_Member_CheckCustSetting_CN88   
			@CustID = 34044216,   
			@Sporttype = 1,  
			@Bettype = 1,    
			@liveindicator = 0,      
			@ActualRate = 0.1,    
			@VirtualRate = 0.1,   
			@Stake = 100,      
			@IsPhoneBetting = 0,   
			@IsThirdParty = 0         
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @UserName NVARCHAR(30), @uGroup VARCHAR(3), @SuperID INT, @MasterID INT, @AgentID INT, @ProductID TINYINT
		, @apos SMALLMONEY, @mpos SMALLMONEY, @spos SMALLMONEY, @tpos SMALLMONEY, @IsEditablePT BIT	
		, @PlayerComm DECIMAL(9, 8), @AgentComm DECIMAL(9, 8), @MasterComm DECIMAL(9, 8), @SuperCommm DECIMAL(9, 8), @IsGroupComm BIT		
		, @MaxBet MONEY, @MaxPerEvent MONEY
		, @Stake_To_Company FLOAT, @Stake_To_Company_Autobookie FLOAT
		, @AutoSuspend BIT, @Currency INT, @Result VARCHAR(50), @Danger BIT, @DoubleCommLosing BIT

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

		SELECT TOP 1 @ProductID = ProductID FROM dbo.CS_ProductSettingDetail WITH (NOLOCK) WHERE SportType = @Sporttype	 
		SELECT @IsEditablePT = IsEditablePT FROM f_CS_GetEditablePTDate(@ProductID)

		--Get PT Mode
		SELECT @IsGroupComm = ISNULL(IsGroupComm,0)
		FROM dbo.CS_CustSettingMode WITH(NOLOCK)
		WHERE CustID = @CustID

		--PT
		IF @IsEditablePT = 1
		BEGIN
			SELECT	@apos = ISNULL(pt.AgentPT2,0) / 100.0,
					@mpos = ISNULL(pt.MasterPT2,0) / 100.0,
					@spos = CASE 
								WHEN @SuperID <= 100 THEN 0
								ELSE ISNULL(pt.SuperPT2,0) / 100.0
							END
			FROM f_CS_GetPTGroup_Member(@AgentID) pt
			WHERE pt.SportType = @Sporttype
				AND pt.BetType = @bettype
				AND pt.IsLive = @liveindicator
		END
		ELSE
		BEGIN
			SELECT	@apos = ISNULL(pt.AgentPT,0) / 100.0,
					@mpos = ISNULL(pt.MasterPT,0) / 100.0,
					@spos = CASE 
								WHEN @SuperID <= 100 THEN 0
								ELSE ISNULL(pt.SuperPT,0) / 100.0
							END
			FROM f_CS_GetPTGroup_Member(@AgentID) pt
			WHERE pt.SportType = @Sporttype
				AND pt.BetType = @bettype
				AND pt.IsLive = @liveindicator
		END

		--Commission
		IF @IsGroupComm = 0
		BEGIN
			--Group A,B,C,D
			SELECT @PlayerComm = ISNULL(PlayerDiscount, 0)
				, @AgentComm = ISNULL(AgentDiscount, 0)
				, @MasterComm = ISNULL(MasterDiscount, 0)
				, @SuperCommm = ISNULL(CASE 
											WHEN @SuperID <= 100 THEN MasterDiscount
											ELSE SuperDiscount
										END, 0)
			FROM f_CS_GetDiscount_Member(@CustID) comm
			WHERE comm.SportType = @Sporttype
				AND comm.BetType = @bettype
				AND comm.isLive = @liveindicator
		END
		ELSE
		BEGIN
			SELECT @uGroup = c.ugroup		
			FROM dbo.Customer c WITH (NOLOCK)
			WHERE custid = @custid	

			SELECT @PlayerComm = ISNULL(PlayerDiscount, 0)
				, @AgentComm = ISNULL(AgentDiscount, 0)
				, @MasterComm = ISNULL(MasterDiscount, 0)
				, @SuperCommm = ISNULL(CASE 
											WHEN @SuperID <= 100 THEN MasterDiscount
											ELSE SuperDiscount
										END, 0)
			FROM dbo.f_CS_GetGroupDiscount_Member(@AgentId) comm
			WHERE comm.SportType = @Sporttype
				AND comm.BetType = @bettype
				AND comm.isLive = @liveindicator
				AND comm.uGroup = @uGroup
		END
		
		--BetSetting
		SELECT @MaxBet = MaxBet, @MaxPerEvent = MaxPerEvent
		FROM dbo.CS_CustBetSetting_Member bs WITH (NOLOCK)
		WHERE bs.CustId = @CustID
			AND bs.SportType = @Sporttype
			AND bs.BetType = @bettype
			AND bs.IsLive = @liveindicator

		IF (@isPhoneBetting = 0 AND @isThirdParty = 0)
		BEGIN
			IF @stake > @Maxbet AND @stake >= 0
			BEGIN
				SET @result = 'stakeproblem'
			END
		END

		SELECT @VirtualRate =	CASE 
									WHEN @bettype NOT IN (1, 2, 3, 7, 8, 12) THEN @ActualRate
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
			, @MaxBet AS maxbet
			, @MaxPerEvent AS MaxPerEvent
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