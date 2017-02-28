ALTER PROCEDURE	dbo.Acc_CustSetting_StakeLevelGroupSelect
					@CustID			INT
				,	@ProductID		TINYINT
AS
/*
	Created: 20160329@Billy
	Task: Select customer's Stake Level Group Settings in DCS
	Database: DBCUST/CustDB
	Original:

	Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@SettingType					SMALLINT
		,	@Currency						TINYINT
		,	@RoleID							TINYINT
		,	@srecommend						INT
		,	@mrecommend						INT
		,	@recommend						INT;

	CREATE TABLE	#SportBetTypeFilter (
						SportType			SMALLINT
					,	BetType				INT
					);

	CREATE TABLE	#CustStakeLevel (
						SportType			SMALLINT
					,	BetType				INT
					,	StakeLevelID		INT
					,	StakeLevelGroupID	INT
					,	isChecked			BIT
					,	PRIMARY KEY CLUSTERED (SportType, BetType, StakeLevelID)
					);

	-- Stake Level Group Member Single Selection
	SELECT	@SettingType = 8;

	-- Select SportType & BetType of current ProductID
	INSERT INTO #SportBetTypeFilter
		(	SportType         , BetType)
	SELECT	fcssbtss.SportType, fcssbtss.Bettype
	FROM	dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID, @SettingType) AS fcssbtss;

	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@srecommend = c.srecommend
		,	@mrecommend = c.mrecommend
		,	@recommend  = c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID;

	-- Select available stake levels
	IF	@RoleID = 4
	BEGIN
		INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelGroupID, isChecked)
		SELECT	sbtf.SportType, sbtf.BetType, sl.StakeLevelID, sl.GameGroupID   , 0
		FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
		INNER JOIN	#SportBetTypeFilter AS sbtf
				ON	sbtf.BetType = sl.GameTypeID
		WHERE	sl.ExchangeId = @Currency;
	END;
	ELSE IF	@RoleID IN (3, 2, 1)
	BEGIN
	    INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelGroupID, isChecked)
		SELECT	csla.SportType,	csla.BetType, sl.StakeLevelID, sl.GameGroupID   , 0
		FROM		dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
		INNER JOIN	#SportBetTypeFilter AS sbtf
				ON	sbtf.SportType = csla.SportType
				AND	sbtf.BetType = csla.BetType
		CROSS APPLY	dbo.strSplit(ISNULL(csla.StakeLevelList, ''), ',') AS ss
		INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
				ON	sl.GameTypeID = sbtf.BetType
				AND	sl.StakeLevelID = CAST(ss.val AS INT)
		WHERE	csla.CustID =	CASE	WHEN @RoleID = 3 THEN @srecommend
										WHEN @RoleID = 2 THEN @mrecommend
										WHEN @RoleID = 1 THEN @recommend
								END;
	END;

	-- Select checked stake levels
	IF	@RoleID IN (4, 3, 2)
	BEGIN
		WITH ccsl AS (
			SELECT csla.SportType, csla.BetType, CAST(ss.val AS INT) AS StakeLevelID
			FROM		dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
			CROSS APPLY	dbo.strSplit(ISNULL(csla.StakeLevelList, ''), ',') AS ss
			WHERE	csla.CustID = @CustID
		)
	    UPDATE	csl
		SET		csl.isChecked = 1
		FROM	#CustStakeLevel AS csl
		INNER JOIN	ccsl
				ON	ccsl.SportType = csl.SportType
				AND	ccsl.BetType = csl.BetType
				AND	ccsl.StakeLevelID = csl.StakeLevelID;
	END;
	ELSE IF @RoleID = 1
	BEGIN
		WITH ccsl AS (
			SELECT cslm.SportType, cslm.BetType, CAST(ss.val AS INT) AS StakeLevelID
			FROM		dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)
			CROSS APPLY	dbo.strSplit(ISNULL(cslm.StakeLevelList, ''), ',') AS ss
			WHERE	cslm.CustID = @CustID
		)
	    UPDATE	csl
		SET		csl.isChecked = 1
		FROM	#CustStakeLevel AS csl
		INNER JOIN	ccsl
				ON	ccsl.SportType = csl.SportType
				AND	ccsl.BetType = csl.BetType
				AND	ccsl.StakeLevelID = csl.StakeLevelID;
	END;

	-- View result
	SELECT	csl.SportType
		,	csl.BetType
		,	csl.StakeLevelID
		,	csl.StakeLevelGroupID
		,	csl.isChecked
	FROM	#CustStakeLevel AS csl;

	-- Cleanup
	DROP TABLE #CustStakeLevel;
	DROP TABLE #SportBetTypeFilter;
END;
GO

GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupSelect TO bodbAdminNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupSelect TO bodbDownlineNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupSelect TO bodbExtAccNet;