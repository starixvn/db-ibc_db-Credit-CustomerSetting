/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_BetSetting3rd_CheckAffectedDownline]
	@custid int,
	@RoleID TINYINT = NULL,
	@JsonData VARCHAR(8000) = '',
	@IsAffected_NG BIT = 0 OUTPUT,
	@IsAffected_DCS BIT = 0 OUTPUT
AS
/*
	Created: 20240520@Eden
	Task : Check downline bet setting whether affected or not
	DB: DBCUST/CUSTDB

	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]
	Param's Explanation:
*/
BEGIN
	SET NOCOUNT ON

	SET @IsAffected_NG = 0 -- Notify agents if Number Game bet setting is affected
	SET @IsAffected_DCS = 0

	IF ISNULL(@JsonData,'') = ''
		RETURN

	DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY
		);

	INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
	SELECT SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber
	FROM OPENJSON(@JsonData) WITH (
			SportType smallint  '$.SportType',
			BetType smallint  '$.BetType',
			MinBet MONEY  '$.MinBet',
			MaxBet MONEY  '$.MaxBet',
			MaxPerMatch MONEY  '$.MPM',
			MaxPerNumber MONEY  '$.MaxPerNumber'
		)

	IF @RoleID = 4
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID IN (2,3) AND t.SportType = 161
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected_NG = 1
			GOTO CheckDCS;
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.srecommend = @custid AND c.roleID = 1 AND t.SportType = 161
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected_NG = 1
			GOTO CheckDCS;
		END
		
	END
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 2 AND t.SportType = 161
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected_NG = 1
			GOTO CheckDCS;
		END

		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.mrecommend = @custid AND c.roleID = 1 AND t.SportType = 161
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected_NG = 1
			GOTO CheckDCS;
		END
		
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
							ON t.SportType = a.SportType AND t.BetType = a.BetType
						INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
					WHERE c.recommend = @custid AND c.roleID = 1 AND t.SportType = 161
						AND c.enabled = 1
						AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
								OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
								OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				)
		BEGIN
			SET @IsAffected_NG = 1
			GOTO CheckDCS;
		END
		
	END

	CheckDCS:
	IF @IsAffected_NG = 1
	BEGIN
		SET @IsAffected_DCS = 1 -- correct downline and write log
		RETURN
	END

	--> check table BetSetting3rd_Agent, BetSetting3rd_Member
	IF @RoleID = 4
	BEGIN
		IF EXISTS(
					SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
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
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
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
						INNER JOIN BetSetting3rd_Agent a WITH(NOLOCK)
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
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
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
						INNER JOIN BetSetting3rd_Member a WITH(NOLOCK)
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
