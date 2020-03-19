/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" isFunction="0"></info>*/
ALTER PROCEDURE	[dbo].[Acc_CustSetting_StakeLevelGroupDetailSelect]
					@CustID				INT				
				,	@SportType			SMALLINT
				,	@ShowAll			BIT			= 0
				,	@NoOfRows			INT			= NULL		OUTPUT
AS
/*
	Created:	20160330@Billy
	Task:		Select Stake Level Group Detail Settings in DCS - [Redmine: #54994]
	Database:	DBCUST/CustDB
	Original:

	Revision:
		- 20161005@Elodie: Update LastUpdated field - [Redmine: #54994]
		- 20200314@Elodie: Offer Midas Game for 789y site only [Redmine: #129032]

	Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON

	DECLARE	@TotalRows		INT
	DECLARE	@UplineID		INT
		,	@ExchangeID		INT
		,	@Site			VARCHAR(10)
		,	@RoleID			TINYINT

	DECLARE	@StakeLevelList	TABLE (StakeLevelID	INT)

	SELECT	@UplineID =	CASE	WHEN c.roleid = 1 THEN c.recommend
								WHEN c.roleid = 2 THEN c.mrecommend
								WHEN c.roleid = 3 THEN c.srecommend
								ELSE -1
						END
		,	@ExchangeID = c.currency
		,	@Site = c.site
		,	@RoleID = c.roleid
	FROM	dbo.customer AS c WITH (NOLOCK)
	WHERE	c.custid = @CustID

	IF @RoleID = 1
	BEGIN
		SELECT	@Site = c.site
		FROM	dbo.customer AS c WITH (NOLOCK)
		WHERE	c.custid = @UplineID
	END

	IF	@UplineID = -1
	BEGIN
	    INSERT INTO	@StakeLevelList (StakeLevelID)
	    SELECT sl.StakeLevelID
		FROM dbo.GameGroup AS gg WITH (NOLOCK)
			INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.GameGroupID = gg.GameGroupID
		WHERE	gg.RefSportType = @SportType
			AND	sl.ExchangeId = @ExchangeID
			AND	gg.IsDeposit = 0
	END
	ELSE
	BEGIN
	    INSERT INTO	@StakeLevelList (StakeLevelID)
	    SELECT	CAST(ss.val AS INT)
		FROM	dbo.CustStakeLevel_Agent AS csla WITH (NOLOCK)
		CROSS APPLY	dbo.strSplit(csla.StakeLevelList, ',') AS ss
		WHERE	csla.CustID = @UplineID
			AND	csla.SportType = @SportType
	END

	SELECT	@NoOfRows = COUNT(DISTINCT sd.GameTypeID)
		,	@TotalRows = COUNT(1)
	FROM		@StakeLevelList AS sll
		INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.StakeLevelID = sll.StakeLevelID
		INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK) ON gg.GameGroupID = sl.GameGroupID
		INNER JOIN	dbo.StakeLevelGroupDetail AS sd WITH (NOLOCK) ON sd.StakeLevelID = sl.StakeLevelID
	WHERE 1 = CASE WHEN (sd.GameTypeID = 1902 AND (@Site = '789y' OR (@Site = 'BEST-ODDS' AND @ExchangeID = 20))) OR sd.GameTypeID <> 1902 THEN 1 ELSE 0 END 

	SELECT	TOP(CASE WHEN @ShowAll = 1 THEN @TotalRows ELSE CASE WHEN @NoOfRows = 0 THEN 0 ELSE @TotalRows / @NoOfRows * 10 END END) 
			gg.RefSportType							SportType
		,	sd.GameTypeID							BetType
		,	gg.GameGroupID							StakeLevelGroupID
		,	sd.MinLabel + N' - ' + sd.MaxLabel	StakeLevel
	FROM		@StakeLevelList AS sll
		INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.StakeLevelID = sll.StakeLevelID
		INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK) ON gg.GameGroupID = sl.GameGroupID
		INNER JOIN	dbo.StakeLevelGroupDetail AS sd WITH (NOLOCK) ON sd.StakeLevelID = sl.StakeLevelID
	WHERE 1 = CASE WHEN (sd.GameTypeID = 1902 AND (@Site = '789y' OR (@Site = 'BEST-ODDS' AND @ExchangeID = 20))) OR sd.GameTypeID <> 1902 THEN 1 ELSE 0 END 
	ORDER BY	SportType, BetType, StakeLevelGroupID

END
GO
