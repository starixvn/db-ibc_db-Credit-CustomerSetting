/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerIns_Check] 
	@CustId				INT = NULL,	
	@RoleID				TINYINT,
	@Credit				MONEY,
	@ProductID			TINYINT = 1,
	@PTSetting			VARCHAR(MAX) = NULL,
	@BetSetting			VARCHAR(MAX) = NULL,
	@CommSetting		VARCHAR(MAX) = NULL,
	@uGroup				VARCHAR(3) = NULL,
	@IsTest				BIT = 0,
	@ErrCode			INT	= 0 OUTPUT,
	@ErrSettingType 	TINYINT = 0 OUTPUT,
	@MsgType			INT	= 0 OUTPUT,
	@ErrMsg				VARCHAR(MAX) OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check CS Settings
	DB:  DBCUST/CustDB
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]

	Param's Explanation:
		@RoleID = 4:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
						</ROOT>
			@CommSetting: <ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
							<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
							...						
						</ROOT>
			@BetSetting: <ROOT>
							<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							...						
						</ROOT>
		@RoleID = 3:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" SuperPT="10"/>
						</ROOT>
			@CommSetting: <ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
							<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
							...						
						</ROOT>
			@BetSetting: <ROOT>
							<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							...						
						</ROOT>
		@RoleID = 2:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MasterPT="20" AgentPT = "50"/>
						</ROOT>
			@CommSetting: <ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
							<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
							<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
							...						
						</ROOT>
			@BetSetting: <ROOT>
							<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							...						
						</ROOT>
		@RoleID = 1:			
			@CommSetting: <ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" ValueId = "6"/>
							<Comm SportType="1" BetType="5" IsLive="0" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" ValueId = "21"/>	
							...						
						</ROOT>
			@BetSetting: <ROOT>
							<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
							...						
						</ROOT>
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Credit_AllDownline MONEY, @UplineCredit MONEY

	IF @Credit < 0
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="70025" Msg="Credit is out of range."></Root>'		    
		SELECT @ErrCode = 101, @ErrSettingType = 1, @MsgType = 100
	    RETURN
	END

	SELECT @UplineCredit = isnull(credit, 0) FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID
	
	IF @RoleId = 3	
	BEGIN
		SELECT @Credit_AllDownline = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where srecommend = @CustID and RoleID = @RoleId		
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT @Credit_AllDownline = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where mrecommend = @CustID and RoleID = @RoleId
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT @Credit_AllDownline = isnull(sum(credit), 0) from custinfo as ci with (NOLOCK) where recommend = @CustID and RoleID = @RoleId
	END

	IF @Credit > @UplineCredit - @Credit_AllDownline
	BEGIN
		SELECT @ErrMsg = '<Root MsgID="70024" Msg="Insufficient credit."></Root>'		    
		SELECT @ErrCode = 100, @ErrSettingType = 1, @MsgType = 100
	    RETURN
	END

	EXEC dbo.CS_CustomerIns_PTSetting_Check 
		@CustID = @CustID, 
	    @RoleID = @RoleID,
	    @ProductID = @ProductID, 
	    @PTSetting = @PTSetting,
	    @IsTest = @IsTest, 
	    @ErrCode = @ErrCode OUTPUT, 
		@MsgType = @MsgType OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrSettingType = 1
		RETURN
	END

	EXEC dbo.CS_CustomerIns_CommBetSetting_Check 
		@CustID = @CustID, 
	    @RoleID = @RoleID,
	    @ProductID = @ProductID, 
	    @BetSetting = @BetSetting,
		@CommSetting = @CommSetting,
		@uGroup = @uGroup,
	    @IsTest = @IsTest, 
	    @ErrCode = @ErrCode OUTPUT, 
		@MsgType = @MsgType OUTPUT,
	    @ErrMsg = @ErrMsg OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrSettingType = 2
		RETURN
	END

	
END
GO


