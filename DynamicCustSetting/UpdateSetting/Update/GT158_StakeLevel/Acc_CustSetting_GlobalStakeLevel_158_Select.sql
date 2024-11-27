/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" isFunction="0"></info>*/
ALTER PROCEDURE	dbo.Acc_CustSetting_GlobalStakeLevel_158_Select
	  @Currency			INT
	, @Site				VARCHAR(30)
	, @GroupID			TINYINT = 3
	, @GroupType		SMALLINT = 158
	, @SettingStatus	TINYINT = 0
AS
/*
	Created: 20241010@Tacy
	Task: Select global Stake Level Settings
	Database: DBCUST/CustDB
	Original:
	
	Revisions:
		- 20241010@Tacy: NAP & Ext - Manage super settings [redmine: #206291]

	Param's Explanation:
		- @SettingStatus: 0: Pro, 1,3: UAT

	Example:
		EXEC Acc_CustSetting_GlobalStakeLevel_158_Select
			@Currency = 20,
			@Site = 'BEST-ODDS',
			@GroupID = 3,
			@GroupType  = 158,
			@SettingStatus = 3

*/
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE	#GlobalStakeLevel (
						SportType		SMALLINT
					,	BetType			INT
					,	StakeLevelID	INT
					,	StakeLevelName	NVARCHAR(100)
					,	isChecked		BIT	DEFAULT(1)
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

	DECLARE @SiteID INT
	
	SELECT @SiteID=ISNULL(siteid,0)
	FROM Site s WITH (NOLOCK)
	WHERE site=@Site

	INSERT INTO #ProductSettingDetail(SportType,BetType,IsLive,ProductID,SettingLevel,MaxChoice,Child_DisplayOrder,SettingType)
	SELECT SportType,BetType,IsLive,ProductID,SettingLevel,ISNULL(MaxChoice,0),Child_DisplayOrder,SettingType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	DELETE sb		
	FROM #ProductSettingDetail sb
		INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
	WHERE ssc.Currency = @Currency AND (ssc.SiteID = @SiteID OR ssc.SiteID = 0)
			
	DELETE sb		
	FROM #ProductSettingDetail sb
		INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
	WHERE (ssc.Currency = @Currency OR ssc.Currency = 0 ) AND ssc.SiteID = @SiteID		

	-- Select available stake levels
	INSERT INTO	#GlobalStakeLevel (SportType, BetType, StakeLevelID, StakeLevelName ,MaxStake)
	SELECT sbtf.SportType, sbtf.BetType, sl.StakeLevelID, sl.MinLabel + N' - ' + sl.MaxLabel  ,sl.MaxStake
	FROM dbo.StakeLevel AS sl WITH(NOLOCK)
		INNER JOIN	#ProductSettingDetail AS sbtf ON sbtf.BetType = sl.GameTypeID
	WHERE sl.ExchangeId=@Currency
	ORDER BY sbtf.SportType, sbtf.BetType, sl.MaxStake,sl.MinStake	

	SELECT gsl.SportType
		,gsl.BetType
		,gsl.StakeLevelID
		,gsl.StakeLevelName
		,gsl.isChecked
		,S.MaxChoice
		,s.ProductID
		,CAST(CASE WHEN s.SettingType = 17 THEN 1 ELSE 0 END AS BIT) IsMultipleChoice
	FROM #GlobalStakeLevel AS gsl WITH (NOLOCK)
		INNER JOIN #ProductSettingDetail S WITH (NOLOCK) ON S.SportType = gsl.SportType AND S.BetType = gsl.BetType
	ORDER BY s.Child_DisplayOrder,gsl.SportType, gsl.BetType,gsl.MaxStake

	-- Cleanup
	DROP TABLE #GlobalStakeLevel
	DROP TABLE #ProductSettingDetail
END

