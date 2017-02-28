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
	Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON;

	DECLARE	@TotalRows		INT

	DECLARE	@UplineID		INT
		,	@ExchangeID		INT

	DECLARE	@StakeLevelList	TABLE (
								StakeLevelID	INT
							)

	SELECT	@UplineID =	CASE	WHEN ci.roleid = 1 THEN ci.recommend
								WHEN ci.roleid = 2 THEN ci.mrecommend
								WHEN ci.roleid = 3 THEN ci.srecommend
								ELSE -1
						END
		,	@ExchangeID = ci.currency
	FROM	dbo.custInfo AS ci WITH (NOLOCK)
	WHERE	ci.custid = @CustID

	IF	@UplineID = -1
	BEGIN
	    INSERT INTO	@StakeLevelList (
						StakeLevelID
					)
	    SELECT	sl.StakeLevelID
		FROM		dbo.GameGroup AS gg WITH (NOLOCK)
		INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
				ON	sl.GameGroupID = gg.GameGroupID
		WHERE	gg.RefSportType = @SportType
			AND	sl.ExchangeId = @ExchangeID
			AND	gg.IsDeposit = 0
	END
	ELSE
	BEGIN
	    INSERT INTO	@StakeLevelList (
						StakeLevelID
					)
	    SELECT	CAST(ss.val AS INT)
		FROM	dbo.CustStakeLevel_Agent AS csla WITH (NOLOCK)
		CROSS APPLY	dbo.strSplit(csla.StakeLevelList, ',') AS ss
		WHERE	csla.CustID = @UplineID
			AND	csla.SportType = @SportType
	END

	SELECT	@NoOfRows = COUNT(DISTINCT slgd.GameTypeID)
		,	@TotalRows = COUNT(1)
	FROM		@StakeLevelList AS sll
	INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
			ON	sl.StakeLevelID = sll.StakeLevelID
	INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK)
			ON	gg.GameGroupID = sl.GameGroupID
	INNER JOIN	dbo.StakeLevelGroupDetail AS slgd WITH (NOLOCK)
			ON	slgd.StakeLevelID = sl.StakeLevelID
	
	SELECT	TOP(CASE WHEN @ShowAll = 1 THEN @TotalRows ELSE CASE WHEN @NoOfRows = 0 THEN 0 ELSE @TotalRows / @NoOfRows * 10 END END) 
			gg.RefSportType							SportType
		,	slgd.GameTypeID							BetType
		,	gg.GameGroupID							StakeLevelGroupID
		,	slgd.MinLabel + N' - ' + slgd.MaxLabel	StakeLevel
	FROM		@StakeLevelList AS sll
	INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK)
			ON	sl.StakeLevelID = sll.StakeLevelID
	INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK)
			ON	gg.GameGroupID = sl.GameGroupID
	INNER JOIN	dbo.StakeLevelGroupDetail AS slgd WITH (NOLOCK)
			ON	slgd.StakeLevelID = sl.StakeLevelID
	ORDER BY	SportType, BetType, StakeLevelGroupID

END
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupDetailSelect TO bodbAdminNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupDetailSelect TO bodbDownlineNet;
GO
GRANT EXECUTE ON dbo.Acc_CustSetting_StakeLevelGroupDetailSelect TO bodbExtAccNet;