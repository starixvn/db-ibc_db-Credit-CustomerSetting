/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" isFunction="0"></info>*/

ALTER PROCEDURE	dbo.Acc_CustSetting_StakeLevelSelect
					@CustID			INT
				,	@ProductID		TINYINT
				,   @SettingType	SMALLINT --20200414@Tiara
AS
/*
	Created: 20160121@Billy
	Task: Select customer's Stake Level Settings in DCS
	Database: DBCUST/CustDB
	Original:
	
	Revisions:
		- 20160812@Helen: NAP - Bet Limit - Stake level does not order by Max then Min Stake [Redmine: 62429]
		- 20180327@Vicky: add header infomation [Redmine: #90422]
		- 20200407@Elodie: Sort by sport, bettype, stakelevelID [Redmine: #131363]
		- 20200414@Tiara: Add input param Setting type, add MaxChoice column [Redmine: #131171]
		- 20200610@Elodie: Don't show stake level of super don't offer the product [Redmine: #135510]
	Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@Currency					TINYINT
		,	@RoleID						TINYINT
		,	@srecommend					INT
		,	@mrecommend					INT
		,	@recommend					INT

	CREATE TABLE	#SportBetTypeFilter (
						SportType		SMALLINT
					,	BetType			INT
					,	MaxChoice		TINYINT
					);

	CREATE TABLE	#CustStakeLevel (
						SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelID	INT
					,	StakeLevelName	NVARCHAR(100)
					,	isChecked		BIT
					)


	-- Select SportType & BetType of current ProductID
	INSERT INTO #SportBetTypeFilter
		(	SportType         , BetType)
	SELECT	fcssbtss.SportType, fcssbtss.Bettype
	FROM	dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID, @SettingType) AS fcssbtss;

	UPDATE S
	SET S.MaxChoice = CASE WHEN @SettingType = 17 THEN P.MaxChoice ELSE 0 END --MaxChoice = 0: unlimit selected stake level
	FROM #SportBetTypeFilter S WITH (ROWLOCK,UPDLOCK)
	INNER JOIN ProductSettingDetail P WITH (NOLOCK) ON P.SportType = S.SportType AND P.BetType = S.BetType
	-- Select customer's information
	SELECT	@Currency   = c.currency
		,	@RoleID     = c.roleid
		,	@srecommend = c.srecommend
		,	@mrecommend = c.mrecommend
		,	@recommend  = c.recommend
	FROM	dbo.Customer AS c WITH(NOLOCK)
	WHERE	c.custid = @CustID

	-- Select available stake levels
	IF	@RoleID = 4
	BEGIN
		INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelName                  , isChecked)
		SELECT	sbtf.SportType, sbtf.BetType, sl.StakeLevelID, sl.MinLabel + N' - ' + sl.MaxLabel, 0
		FROM		dbo.StakeLevel AS sl WITH(NOLOCK)
			INNER JOIN	#SportBetTypeFilter AS sbtf ON	sbtf.BetType = sl.GameTypeID
			INNER JOIN CustStakeLevel_Agent cs ON sbtf.SportType = cs.SportType AND sbtf.BetType = cs.BetType
		WHERE	sl.ExchangeId = @Currency AND cs.custid = @CustID
		ORDER BY sbtf.SportType, sbtf.BetType, sl.MaxStake,sl.MinStake	
		
		
	END
	ELSE IF	@RoleID IN (3, 2, 1)
	BEGIN
	
	    INSERT INTO	#CustStakeLevel
			(	SportType     , BetType     , StakeLevelID   , StakeLevelName                  , isChecked)
		SELECT	csla.SportType,	csla.BetType, sl.StakeLevelID, sl.MinLabel + N' - ' + sl.MaxLabel, 0
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
								END
		ORDER BY csla.SportType, csla.BetType, sl.MaxStake,sl.MinStake	
		
									
	END

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
				AND	ccsl.StakeLevelID = csl.StakeLevelID
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
				AND	ccsl.StakeLevelID = csl.StakeLevelID
	END;

	-- View result
	SELECT DISTINCT	csl.SportType
		,	csl.BetType
		,	csl.StakeLevelID
		,	csl.StakeLevelName
		,	csl.isChecked
		, ISNULL(S.MaxChoice,'') AS MaxChoice
	FROM	#CustStakeLevel AS csl WITH (NOLOCK)
		INNER JOIN #SportBetTypeFilter S WITH (NOLOCK) ON S.SportType = CSL.SportType AND S.BetType = CSL.BetType

	-- Cleanup
	DROP TABLE #CustStakeLevel
	DROP TABLE #SportBetTypeFilter
END

