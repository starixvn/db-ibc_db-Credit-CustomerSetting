/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpd_BetSetting_Checkdownline]
	@custid int,
	@RoleID TINYINT = NULL,
	@BetSettingXML VARCHAR(8000) = '',
	@IsAffected BIT = 0 OUTPUT,
	@IsAffected_DCS BIT = 0 OUTPUT,
	@SettingType TINYINT = 0
AS
/*
	Created: 20210802@Eden
	Task : Check downline bet setting whether affected or not
	DB: DBCUST/CUSTDB
	Original: Acc_CustomerUpdAgent_MinMaxBet

	Revisions:
		- 20210802@Eden: Max Payout Per Match [redmine: #158073]
		- 20230310@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20240418@Eden: HotFix - Master update Agent bet setting RNG Keno, but member bet setting still not updated [Redmine: #204104]
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	SET @IsAffected = 0
	SET @IsAffected_DCS = 0

	IF ISNULL(@BetSettingXML,'') = ''
		RETURN

	DECLARE @DocHandler INT	
	DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY, 
			MaxPayoutPerMatch MONEY
		);

	--Parse SB Bet Setting from XML
	EXEC sp_xml_preparedocument @DocHandler OUTPUT, @BetSettingXML

	INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
	SELECT SportType        
		,BetType          
		,MinBet           
		,MaxBet           
		,MaxPerMatch      
		,MaxPerNumber     
		,MaxPayoutPerMatch
	FROM OPENXML (@DocHandler, '/Root/Row',1) 
	WITH (
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY
	) AS Data

	EXEC sp_xml_removedocument @DocHandler

	IF @RoleID = 4
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID IN (2,3)
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected = 1
			GOTO CheckDCS;
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected = 1
			GOTO CheckDCS;
		END
		
	END
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 2
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected = 1
			GOTO CheckDCS;
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected = 1
			GOTO CheckDCS;
		END
		
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.recommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected = 1
			GOTO CheckDCS;
		END
		
	END

	CheckDCS:
	IF @Settingtype <> 23 -- no need to check on those table
		RETURN

	--> check table CustBetSetting3rd_Agent, CustBetSetting3rd_Member
	IF @RoleID = 4
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting3rd_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID IN (2,3)
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							)
				)
		BEGIN
			SET @IsAffected_DCS = 1
			RETURN
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							)
				)
		BEGIN
			SET @IsAffected_DCS = 1
			RETURN
		END
		
	END
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting3rd_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 2
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							)
				)
		BEGIN
			SET @IsAffected_DCS = 1
			RETURN
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
							)
				)
		BEGIN
			SET @IsAffected_DCS = 1
			RETURN
		END
		
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN CustBetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.recommend = @custid AND c.roleID = 1
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								)
				)
		BEGIN
			SET @IsAffected_DCS = 1
			RETURN
		END
		
	END
END
GO
