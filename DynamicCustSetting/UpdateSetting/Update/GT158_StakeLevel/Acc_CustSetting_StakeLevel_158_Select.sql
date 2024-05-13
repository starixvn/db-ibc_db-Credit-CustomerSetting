/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" isFunction="0"></info>*/
ALTER PROCEDURE	dbo.Acc_CustSetting_StakeLevel_158_Select
	  @CustID			INT
	, @GroupID			TINYINT = 3
	, @GroupType		SMALLINT = 158
	, @SettingStatus	TINYINT = 0
	AS
/*
	Created: 20240215@Eden
	Task: Select customer's Stake Level Settings
	Database: DBCUST/CustDB
	Original:
	
	Revisions:
		- 20240215@Eden: Unify Live Casino & RNG slot/RNG Casino [Redmine: #198960]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1,3: UAT

	Example:
		EXEC Acc_CustSetting_StakeLevel_158_Select
			@CustID = 28529050,
			@GroupID = 3,
			@GroupType  = 158,
			@SettingStatus = 3

*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@Currency	TINYINT
		,	@RoleID		TINYINT
		,	@srecommend	INT
		,	@mrecommend	INT
		,	@recommend	INT
		,   @SiteID		SMALLINT
	
	SELECT   @siteID = s.siteID
			,@Currency	= c.currency
			,@RoleID     = c.roleid
			,@srecommend = c.srecommend
			,@mrecommend = c.mrecommend
			,@recommend  = c.recommend
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE	#CustStakeLevel (
						SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelID	INT
					,	StakeLevelName	NVARCHAR(100)
					,	isChecked		BIT	 
					,	MaxStake		DECIMAL(19,8)
					)

	CREATE TABLE #ProductSettingDetail(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		MaxChoice	tinyint,
		Child_DisplayOrder INT,
		SettingType smallint
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,IsLive,ProductID,SettingLevel,MaxChoice,Child_DisplayOrder,SettingType)
	SELECT SportType,BetType,IsLive,ProductID,SettingLevel,ISNULL(MaxChoice,0),Child_DisplayOrder,SettingType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	-- Select available stake levels
	IF	@RoleID = 4
	BEGIN
		INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelName                  , isChecked ,MaxStake)
		SELECT	sbtf.SportType, sbtf.BetType, sl.StakeLevelID, sl.MinLabel + N' - ' + sl.MaxLabel, 0  ,sl.MaxStake
		FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
			INNER JOIN	#ProductSettingDetail AS sbtf ON	sbtf.BetType = sl.GameTypeID
			INNER JOIN CustStakeLevel_Agent cs ON sbtf.SportType = cs.SportType AND sbtf.BetType = cs.BetType
		WHERE	sl.ExchangeId = @Currency AND cs.custid = @CustID
		ORDER BY sbtf.SportType, sbtf.BetType, sl.MaxStake,sl.MinStake	
	
	END
	ELSE IF	@RoleID IN (3, 2, 1)
	BEGIN
	
	    INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelName                  , isChecked ,MaxStake)
		SELECT	csla.SportType,	csla.BetType, sl.StakeLevelID, sl.MinLabel + N' - ' + sl.MaxLabel, 0  ,sl.MaxStake
		FROM		dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
		INNER JOIN	#ProductSettingDetail AS sbtf
				ON	sbtf.SportType = csla.SportType
				AND	sbtf.BetType = csla.BetType
		CROSS APPLY	STRING_SPLIT(ISNULL(csla.StakeLevelList, ''), ',') AS ss
		INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
				ON	sl.GameTypeID = sbtf.BetType
				AND	sl.StakeLevelID = CAST(ss.value AS INT)
		WHERE	csla.CustID =	CASE	WHEN @RoleID = 3 THEN @srecommend
										WHEN @RoleID = 2 THEN @mrecommend
										WHEN @RoleID = 1 THEN @recommend
								END
		ORDER BY csla.SportType, csla.BetType, sl.MaxStake,sl.MinStake							
	END

	-- Select checked stake levels
	IF	@RoleID IN (4, 3, 2)
	BEGIN
		WITH ccsl AS (
			SELECT csla.SportType, csla.BetType, CAST(ss.value AS INT) AS StakeLevelID
			FROM		dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
			CROSS APPLY	STRING_SPLIT(ISNULL(csla.StakeLevelList, ''), ',') AS ss
			WHERE	csla.CustID = @CustID
		)
	    UPDATE	csl
		SET		csl.isChecked = 1
		FROM	#CustStakeLevel AS csl
		INNER JOIN	ccsl
				ON	ccsl.SportType = csl.SportType
				AND	ccsl.BetType = csl.BetType
				AND	ccsl.StakeLevelID = csl.StakeLevelID
	END;
	ELSE IF @RoleID = 1
	BEGIN
		WITH ccsl AS (
			SELECT cslm.SportType, cslm.BetType, CAST(ss.value AS INT) AS StakeLevelID
			FROM		dbo.CustStakeLevel_Member AS cslm WITH(NOLOCK)
			CROSS APPLY	STRING_SPLIT(ISNULL(cslm.StakeLevelList, ''), ',') AS ss
			WHERE	cslm.CustID = @CustID
		)
	    UPDATE	csl
		SET		csl.isChecked = 1
		FROM	#CustStakeLevel AS csl
		INNER JOIN	ccsl
				ON	ccsl.SportType = csl.SportType
				AND	ccsl.BetType = csl.BetType
				AND	ccsl.StakeLevelID = csl.StakeLevelID
	END;

	-- View result
	SELECT csl.SportType
		,csl.BetType
		,csl.StakeLevelID
		,csl.StakeLevelName
		,csl.isChecked
		,S.MaxChoice
		,s.ProductID
		,CAST(CASE WHEN s.SettingType = 17 THEN 1 ELSE 0 END AS BIT) IsMultipleChoice
	FROM	#CustStakeLevel AS csl WITH (NOLOCK)
		INNER JOIN #ProductSettingDetail S WITH (NOLOCK) ON S.SportType = CSL.SportType AND S.BetType = CSL.BetType
	ORDER BY s.Child_DisplayOrder,csl.SportType, csl.BetType,csl.MaxStake

	-- Cleanup
	DROP TABLE #CustStakeLevel
	DROP TABLE #ProductSettingDetail
END

