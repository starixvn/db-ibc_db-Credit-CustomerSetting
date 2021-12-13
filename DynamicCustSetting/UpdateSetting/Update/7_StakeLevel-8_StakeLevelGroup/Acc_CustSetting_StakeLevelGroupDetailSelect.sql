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
		- 20200414@Elodie: Offer XocDia for 789y site only [Redmine: #131283]
		- 20200420@Elodie: Offer 3DGame for 789y site only [Redmine: #132254]
		- 20200506@Elodie: Offer HILO for 789y site only [Redmine: #133597]
		- 20200819@Elodie: Only show stake level setting if site and currency of customer is offered [Redmine: #137768]
		- 20201029@Winfred: Move offer for 789y site to SportNonOfferedSiteCurrency   [Redmine: #141926]
		- 20211213@Winfred: Support setting Buy Bonus for product RedmineID:#165393

	Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON

	DECLARE	@TotalRows		INT
	DECLARE	@UplineID		INT
		,	@ExchangeID		INT
		,	@Site			VARCHAR(10)
		,	@SiteID			INT
		,	@RoleID			TINYINT

	DECLARE	@StakeLevelList	TABLE (StakeLevelID	INT, GameTypeID INT, typedesc NVARCHAR(128))

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
	
	SELECT @SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @Site

	IF	@UplineID = -1
	BEGIN
	    INSERT INTO	@StakeLevelList (StakeLevelID, GameTypeID)
	    SELECT sl.StakeLevelID, sl.GameTypeID
		FROM dbo.GameGroup AS gg WITH (NOLOCK)
			INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.GameGroupID = gg.GameGroupID
		WHERE	gg.RefSportType = @SportType
			AND	sl.ExchangeId = @ExchangeID
			AND	gg.IsDeposit = 0

		DELETE sb		
		FROM @StakeLevelList sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.GameTypeID = ssc.Bettype
		WHERE ssc.Currency = @ExchangeID AND (ssc.SiteID = @SiteID OR ssc.SiteID = 0)
			
		DELETE sb		
		FROM @StakeLevelList sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.GameTypeID = ssc.Bettype
		WHERE (ssc.Currency = @ExchangeID OR ssc.Currency = 0 ) AND ssc.SiteID = @SiteID	

	END
	ELSE
	BEGIN
	    INSERT INTO	@StakeLevelList (StakeLevelID, GameTypeID)
	    SELECT	CAST(ss.val AS INT), Bettype
		FROM	dbo.CustStakeLevel_Agent AS csla WITH (NOLOCK)
		CROSS APPLY	dbo.strSplit(csla.StakeLevelList, ',') AS ss
		WHERE	csla.CustID = @UplineID
			AND	csla.SportType = @SportType
	END

	UPDATE ts
	SET ts.typedesc=b.typedesc
	FROM @StakeLevelList ts
		INNER JOIN DBAGE.bodb02.dbo.bettype b WITH (NOLOCK) ON ts.GameTypeID=b.typeid

	SELECT	@NoOfRows = COUNT(DISTINCT sd.GameTypeID)
		,	@TotalRows = COUNT(1)
	FROM		@StakeLevelList AS sll
		INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.StakeLevelID = sll.StakeLevelID
		INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK) ON gg.GameGroupID = sl.GameGroupID
		INNER JOIN	dbo.StakeLevelGroupDetail AS sd WITH (NOLOCK) ON sd.StakeLevelID = sl.StakeLevelID
	WHERE NOT EXISTS(SELECT 1 FROM SportNonOfferedSiteCurrency cso 
					 WHERE cso.SportType = gg.RefSportType AND cso.BetType = sd.GameTypeID AND cso.Currency = @ExchangeID AND (cso.SiteID = @SiteID OR cso.SiteID = 0)) 	
	AND NOT EXISTS(SELECT 1 FROM SportNonOfferedSiteCurrency cso 
					 WHERE cso.SportType = gg.RefSportType AND cso.BetType = sd.GameTypeID AND (cso.Currency = @ExchangeID OR cso.Currency = 0 ) AND cso.SiteID = @SiteID) 

	SELECT	TOP(CASE WHEN @ShowAll = 1 THEN @TotalRows ELSE CASE WHEN @NoOfRows = 0 THEN 0 ELSE @TotalRows / @NoOfRows * 10 END END) 
			gg.RefSportType							SportType
		,	sd.GameTypeID							BetType
		,	gg.GameGroupID							StakeLevelGroupID
		,	sd.MinLabel + N' - ' + sd.MaxLabel	StakeLevel
		,	Sll.typedesc
	FROM		@StakeLevelList AS sll
		INNER JOIN	dbo.StakeLevel AS sl WITH (NOLOCK) ON sl.StakeLevelID = sll.StakeLevelID
		INNER JOIN	dbo.GameGroup AS gg WITH (NOLOCK) ON gg.GameGroupID = sl.GameGroupID
		INNER JOIN	dbo.StakeLevelGroupDetail AS sd WITH (NOLOCK) ON sd.StakeLevelID = sl.StakeLevelID
	WHERE NOT EXISTS(SELECT 1 FROM SportNonOfferedSiteCurrency cso 
					 WHERE cso.SportType = gg.RefSportType AND cso.BetType = sd.GameTypeID AND cso.Currency = @ExchangeID AND (cso.SiteID = @SiteID OR cso.SiteID = 0)) 	
	AND NOT EXISTS(SELECT 1 FROM SportNonOfferedSiteCurrency cso 
					 WHERE cso.SportType = gg.RefSportType AND cso.BetType = sd.GameTypeID AND (cso.Currency = @ExchangeID OR cso.Currency = 0 ) AND cso.SiteID = @SiteID) 
	ORDER BY	SportType, BetType, StakeLevelGroupID

END
GO
