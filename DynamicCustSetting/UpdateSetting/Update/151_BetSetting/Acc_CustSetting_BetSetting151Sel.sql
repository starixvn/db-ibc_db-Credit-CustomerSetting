/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_BetSetting151Sel] 
	  @CustID			INT
	, @GroupID			TINYINT	= 1
	, @GroupType		TINYINT	= 151
	, @SettingStatus		TINYINT	= 0
AS
/*
	Created: 20231019@Helios
	Task : Get SMA Bet setting values of a SportsBook
	DB: DBCUST/CustDB
	Original:

	Revisions: 
		- 20231019@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]

	Param's Explanation:
		- @GroupType:	151 - Discount
		- @SettingStatus: 0: Pro, 1: UAT
		
	EXEC  [dbo].[Acc_CustSetting_BetSetting151Sel_UAT2]
	    @CustId = 102596104,
	    @GroupID = 1 ,
	    @GroupType   = 151  ,
	    @SettingStatus = 3
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE	@Currency		TINYINT,
			@RoleID		TINYINT,
			@SuperID		INT,
			@MasterID		INT,
			@AgentID		INT,
			@CurrencyID		INT,
			@SiteID		INT

	CREATE TABLE #ProductSettingProfile(
		ProductID		TINYINT,	
		SportType		SMALLINT,
		BetType		SMALLINT,
		MaxDiscount		DECIMAL(19,8),
		IntervalValue	DECIMAL(19,8),
		SubType		TINYINT,
		Child_DisplayOrder TINYINT
	)

	----------------------------------------------------------------

	SELECT	
			@RoleID		= c.roleid,
			@SuperID		= c.srecommend,
			@MasterID		= c.mrecommend,
			@AgentID		= c.recommend,
			@siteid		= s.siteid,
			@CurrencyID		= c.currency
	FROM	Customer c WITH (NOLOCK)
			INNER JOIN Site s WITH (NOLOCK) ON s.site = c.site
	WHERE	c.custID = @CustID 

	-- Collect Product Setting Profile
	INSERT INTO #ProductSettingProfile 	(ProductID , SportType , BetType , MaxDiscount , IntervalValue , SubType , Child_DisplayOrder )
	SELECT ProductID , SportType , Bettype , MaxDiscount , IntervalValue  , SubType , Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)	
	

	IF @RoleID = 4
		BEGIN
			SELECT	psp.SportType,
					psp.BetType,
					bl.MinBet,
					bl.MaxBet,
					bl.MaxPerMatch		AS MaxPerMatch,
					--0				AS MaxPerMatchMin,
					bl.MaxPayoutPerMatch	AS MaxPayoutPerMatch
			FROM #ProductSettingProfile psp
				INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON psp.SportType = bl.sporttype AND psp.BetType = bl.bettype
			WHERE bl.CustID = @CustID
			ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType
		END
	ELSE IF @RoleID = 3
		BEGIN
			SELECT
					psp.SportType,
					psp.BetType,
					bl.MinBet,
					bl.MaxBet,
					bl.MaxPerMatch				AS MaxPerMatch,
					bl.MaxPayoutPerMatch			AS MaxPayoutPerMatch,
					sbl.MinBet					AS MinBetMin,
					sbl.MaxBet					AS MaxBetMax,
					--0						AS MaxPerMatchMin,
					sbl.MaxPerMatch				AS MaxPerMatchMax,
					sbl.MaxPayoutPerMatch			AS MaxPayoutPerMatchMax
			FROM #ProductSettingProfile psp
				INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON psp.SportType = bl.sporttype AND psp.BetType = bl.bettype
				INNER JOIN dbo.CustBetSetting_Agent sbl WITH (NOLOCK) ON psp.SportType = sbl.sporttype AND psp.BetType = sbl.bettype
			WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
			ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType
		END
	ELSE IF @RoleID = 2
		SELECT
				    psp.SportType
				  , psp.BetType
				  , bl.MinBet
				  , bl.MaxBet
				  , bl.MaxPerMatch	 AS MaxPerMatch
				  , bl.MaxPayoutPerMatch AS MaxPayoutPerMatch
				  , (
					    SELECT MAX ( t.MinBet )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MinBet = 0
										    THEN NULL
									    ELSE Sbl.MinBet
								    END) , (
										CASE
											WHEN Mbl.MinBet = 0
												THEN NULL
											ELSE Mbl.MinBet
										END)) AS t (MinBet)
				    )				 AS MinBetMin
				  , (
					    SELECT MIN ( t.MaxBet )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxBet = 0
										    THEN NULL
									    ELSE Sbl.MaxBet
								    END) , (
										CASE
											WHEN Mbl.MaxBet = 0
												THEN NULL
											ELSE Mbl.MaxBet
										END)) AS t (MaxBet)
				    )				 AS MaxBetMax
				  ,
				    --0																					AS MaxPerMatchMin,
				    (
					    SELECT MIN ( t.MaxPerMatch )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxPerMatch = 0
										    THEN NULL
									    ELSE Sbl.MaxPerMatch
								    END) , (
										CASE
											WHEN Mbl.MaxPerMatch = 0
												THEN NULL
											ELSE Mbl.MaxPerMatch
										END)) AS t (MaxPerMatch)
				    )				 AS MaxPerMatchMax
				  , (
					    SELECT MIN ( t.MaxPayoutPerMatch )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxPayoutPerMatch = 0
										    THEN NULL
									    ELSE Sbl.MaxPayoutPerMatch
								    END) , (
										CASE
											WHEN Mbl.MaxPayoutPerMatch = 0
												THEN NULL
											ELSE Mbl.MaxPayoutPerMatch
										END)) AS t (MaxPayoutPerMatch)
				    )				 AS MaxPayoutPerMatchMax
		FROM #ProductSettingProfile psp
			INNER JOIN dbo.CustBetSetting_Agent bl WITH (NOLOCK) ON psp.SportType = bl.sporttype AND psp.BetType = bl.bettype
			INNER JOIN dbo.CustBetSetting_Agent Sbl WITH (NOLOCK) ON psp.SportType = Sbl.sporttype AND psp.BetType = Sbl.bettype
			INNER JOIN dbo.CustBetSetting_Agent Mbl WITH (NOLOCK) ON psp.SportType = Mbl.sporttype AND psp.BetType = Mbl.bettype
		WHERE bl.CustID = @CustID AND Sbl.CustID = @SuperID AND Mbl.CustID = @MasterID
		ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType
	ELSE IF @RoleID = 1
		SELECT	
				    psp.SportType
				  , psp.BetType
				  , cbsm.MinBet
				  , cbsm.MaxBet
				  , cbsm.MaxPerMatch	   AS MaxPerMatch
				  , cbsm.MaxPayoutPerMatch AS MaxPayoutPerMatch
				  , (
					    SELECT MAX ( t.MinBet )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MinBet = 0
										    THEN NULL
									    ELSE Sbl.MinBet
								    END) , (
										CASE
											WHEN Mbl.MinBet = 0
												THEN NULL
											ELSE Mbl.MinBet
										END) , (
											  CASE
												  WHEN Abl.MinBet = 0
													  THEN NULL
												  ELSE Abl.MinBet
											  END)) AS t (MinBet)
				    )				   AS MinBetMin
				  , (
					    SELECT MIN ( t.MaxBet )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxBet = 0
										    THEN NULL
									    ELSE Sbl.MaxBet
								    END) , (
										CASE
											WHEN Mbl.MaxBet = 0
												THEN NULL
											ELSE Mbl.MaxBet
										END) , (
											  CASE
												  WHEN Abl.MaxBet = 0
													  THEN NULL
												  ELSE Abl.MaxBet
											  END)) AS t (MaxBet)
				    )				   AS MaxBetMax
				  ,
				    --0																									AS MaxPerMatchMin,
				    (
					    SELECT MIN ( t.MaxPerMatch )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxPerMatch = 0
										    THEN NULL
									    ELSE Sbl.MaxPerMatch
								    END) , (
										CASE
											WHEN Mbl.MaxPerMatch = 0
												THEN NULL
											ELSE Mbl.MaxPerMatch
										END) , (
											  CASE
												  WHEN Abl.MaxPerMatch = 0
													  THEN NULL
												  ELSE Abl.MaxPerMatch
											  END)) AS t (MaxPerMatch)
				    )				   AS MaxPerMatchMax
				  , (
					    SELECT MIN ( t.MaxPayoutPerMatch )
						  FROM (VALUES (
								    CASE
									    WHEN Sbl.MaxPayoutPerMatch = 0
										    THEN NULL
									    ELSE Sbl.MaxPayoutPerMatch
								    END) , (
										CASE
											WHEN Mbl.MaxPayoutPerMatch = 0
												THEN NULL
											ELSE Mbl.MaxPayoutPerMatch
										END) , (
											  CASE
												  WHEN Abl.MaxPayoutPerMatch = 0
													  THEN NULL
												  ELSE Abl.MaxPayoutPerMatch
											  END)) AS t (MaxPayoutPerMatch)
				    )				   AS MaxPayoutPerMatchMax
		FROM #ProductSettingProfile psp
			INNER JOIN dbo.CustBetSetting_Member cbsm WITH (NOLOCK) ON psp.SportType = cbsm.sporttype AND psp.BetType = cbsm.bettype
			INNER JOIN dbo.CustBetSetting_Agent Sbl WITH (NOLOCK) ON psp.SportType = Sbl.sporttype AND psp.BetType = Sbl.bettype
			INNER JOIN dbo.CustBetSetting_Agent Mbl WITH (NOLOCK) ON psp.SportType = Mbl.sporttype AND psp.BetType = Mbl.bettype
			INNER JOIN dbo.CustBetSetting_Agent Abl WITH (NOLOCK) ON psp.SportType = Abl.sporttype AND psp.BetType = Abl.bettype
		WHERE cbsm.CustID = @CustID AND Sbl.CustID = @SuperID AND Mbl.CustID = @MasterID AND Abl.CustID = @AgentID
		ORDER BY psp.Child_DisplayOrder , psp.SportType , psp.BetType
	DROP TABLE #ProductSettingProfile
END
GO