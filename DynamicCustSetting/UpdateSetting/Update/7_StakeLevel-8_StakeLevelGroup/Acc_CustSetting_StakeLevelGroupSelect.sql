/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" isFunction="0"></info>*/
ALTER PROCEDURE	dbo.Acc_CustSetting_StakeLevelGroupSelect
					@CustID			INT
				,	@ProductID		TINYINT
				, @SettingStatus TINYINT = 0
AS
/*
	Created: 20160329@Billy
	Task: Select customer's Stake Level Group Settings in DCS
	Database: DBCUST/CustDB
	Original:

    Revision:
        - 20180327@Vicky: add header infomation [Redmine: #90422]
		- 20200819@Elodie: Only show stake level setting if site and currency of customer is offered [Redmine: #137768]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20201112@Eden: Saba.club - Offer more stake levels for 789y market - add default sort [Redmine: #147941]
		- 20211213@Winfred: Support setting Buy Bonus for product RedmineID:#165393
    
	Param's Explanation:
		- @SettingStatus: 0: Pro, 1: UAT
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@SettingType					SMALLINT
		,	@Currency						TINYINT
		,	@Site							VARCHAR(10)
		,	@SiteID							INT
		,	@RoleID							TINYINT
		,	@srecommend						INT
		,	@mrecommend						INT
		,	@recommend						INT;

	CREATE TABLE	#SportBetTypeFilter (
						SportType			SMALLINT
					,	BetType				INT
					,	typedesc NVARCHAR(128)
					);

	CREATE TABLE	#CustStakeLevel (
						SportType			SMALLINT
					,	BetType				INT
					,	StakeLevelID		INT
					,	StakeLevelGroupID	INT
					,	isChecked			BIT
					,	typedesc			NVARCHAR(128)
					,	PRIMARY KEY CLUSTERED (SportType, BetType, StakeLevelID)
					);

	-- Stake Level Group Member Single Selection
	SELECT	@SettingType = 8;

	-- Select SportType & BetType of current ProductID
	INSERT INTO #SportBetTypeFilter
		(	SportType         , BetType)
	SELECT	fcssbtss.SportType, fcssbtss.Bettype
	FROM	dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID, @SettingType,@SettingStatus) AS fcssbtss;

	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@Site		= c.site
		,	@RoleID     = c.roleid
		,	@srecommend = c.srecommend
		,	@mrecommend = c.mrecommend
		,	@recommend  = c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID;

	SELECT @SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @Site

	DELETE sb		
	FROM #SportBetTypeFilter sb
		INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
	WHERE ssc.Currency = @Currency AND (ssc.SiteID = @SiteID OR ssc.SiteID = 0)
			
	DELETE sb		
	FROM #SportBetTypeFilter sb
		INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
	WHERE (ssc.Currency = @Currency OR ssc.Currency = 0 ) AND ssc.SiteID = @SiteID	

	UPDATE ts
	SET ts.typedesc=b.typedesc
	FROM #SportBetTypeFilter ts
		INNER JOIN bettype b WITH (NOLOCK) ON ts.Bettype=b.typeid

	-- Select available stake levels
	IF	@RoleID = 4
	BEGIN
		INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelGroupID, isChecked,typedesc)
		SELECT	sbtf.SportType, sbtf.BetType, sl.StakeLevelID, sl.GameGroupID   , 0 , typedesc
		FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
		INNER JOIN	#SportBetTypeFilter AS sbtf
				ON	sbtf.BetType = sl.GameTypeID
		WHERE	sl.ExchangeId = @Currency;
	END;
	ELSE IF	@RoleID IN (3, 2, 1)
	BEGIN
	    INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelGroupID, isChecked,typedesc)
		SELECT	csla.SportType,	csla.BetType, sl.StakeLevelID, sl.GameGroupID   , 0 , typedesc
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
		,	csl.typedesc
	FROM	#CustStakeLevel AS csl
		INNER JOIN GameGroup g WITH(NOLOCK)
			ON g.GameGroupID = csl.StakeLevelGroupID
	ORDER BY csl.SportType
		,	csl.BetType
		,   g.GroupName

	-- Cleanup
	DROP TABLE #CustStakeLevel;
	DROP TABLE #SportBetTypeFilter;
END;
GO
