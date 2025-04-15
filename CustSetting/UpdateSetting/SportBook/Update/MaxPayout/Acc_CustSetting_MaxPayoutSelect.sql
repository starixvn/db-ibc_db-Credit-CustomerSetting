/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_alpv,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutSelect] 
	  @CustID			INT
	, @GroupID			TINYINT	= 1
	, @GroupType		TINYINT	= 152
	, @SettingStatus		TINYINT	= 0
AS
/*
	Created: 20210518@Winfred
	Task : Get SMA Parlay Max Payout setting values of a Credit Sites
	DB: DBCUST/CustDB
	Original:

	Revision: 
		- 20210518@Winfred: Initial SP [RedmineID:#154104]
		- 20220617@Johnson: define temp table to avoid dump db [redmine:#174035]
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 

	Param's Explanation:
		- @GroupType:	152 - MaxPayout
		- @SettingStatus: 0: Pro, 1: UAT

	EXEC  [dbo].[Acc_CustSetting_MaxPayoutSelect]
		@CustId = 102596104,
		@GroupID = 1 ,
		@GroupType   = 152  ,
		@SettingStatus = 3
		
*/
BEGIN
	DECLARE	@CurrencyID		TINYINT,
			@RoleID		TINYINT,
			@SuperID		INT,
			@MasterID		INT,
			@AgentID		INT,
			@SiteID		INT
	
	DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)
		
	CREATE TABLE #ProductSettingProfile(
		ProductID		TINYINT,	
		SportType		SMALLINT,
		BetType		SMALLINT,
		Child_DisplayOrder TINYINT
	)

	-- Select customer's information
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
	INSERT INTO #ProductSettingProfile 	(ProductID , SportType , BetType , Child_DisplayOrder  )
	SELECT ProductID , SportType , Bettype , Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	IF @RoleID = 1 AND  @AgentID NOT IN (-4,-3) --Normal member
	BEGIN
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 AND aMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 AND aMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0 AND aMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0 AND aMp.ComboOver6 = 0 THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #ProductSettingProfile s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent aMp WITH (NOLOCK) ON s.SportType = aMp.sporttype AND s.BetType = aMp.bettype
		WHERE cs.custid = @SuperID  AND mMp.CustID = @MasterID AND aMp.CustID = @AgentID  
	END
	ELSE IF @RoleID = 2 OR ( @Roleid = 1 AND @AgentID = -3 )--Agent OR Master Direct Member
	BEGIN
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #ProductSettingProfile s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
		WHERE cs.custid = @SuperID  AND mMp.CustID = @MasterID 
	END
	ELSE IF @RoleID = 3 OR ( @Roleid = 1 AND @AgentID = -4 )--Master OR Super Direct Member
	BEGIN
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
				CASE WHEN cs.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
				CASE WHEN cs.Combo35 = 0 THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
				CASE WHEN cs.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN #ProductSettingProfile s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		WHERE cs.custid = @SuperID
	END
	
	IF @RoleID = 4
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,					
				Mps.SingleMatchParlay AS Upline_SingleMatchParlay,
				Mps.Combo2 AS Upline_Combo2,
				Mps.Combo35 AS Upline_Combo35,
				Mps.ComboOver6 AS Upline_ComboOver6,
				1 AS SingleMatchParlay_IsAllowUnlimit,
				1 AS Combo2_IsAllowUnlimit,
				1 AS Combo35_IsAllowUnlimit,
				1 AS ComboOver6_IsAllowUnlimit
		FROM #ProductSettingProfile ft 
			INNER JOIN dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			LEFT JOIN dbo.MaxPayoutGlobalSetting Mps ON Mps.SportType = bl.sporttype AND Mps.BetType = bl.bettype AND Mps.Currency = @CurrencyID
		WHERE bl.CustID = @CustID
		ORDER BY ft.Child_DisplayOrder
	ELSE IF @RoleID = 3
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,	
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 THEN 0
						ELSE sbl.SingleMatchParlay END AS Upline_SingleMatchParlay,  
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo2 END AS Upline_Combo2,
				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo35 END AS Upline_Combo35,
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.ComboOver6 END AS Upline_ComboOver6,
				bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
				bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
				bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
				bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit		
		FROM #ProductSettingProfile ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
		ORDER BY ft.Child_DisplayOrder
	ELSE IF @RoleID = 2
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,	
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES  (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
														(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS Upline_SingleMatchParlay,  

				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo2) FROM (VALUES  (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
														(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END)) AS t(Combo2)) END AS Upline_Combo2,  

				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END)) AS t(Combo35)) END AS Upline_Combo35,
						
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
															(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END)) AS t(ComboOver6)) END AS Upline_ComboOver6,	
				bu.SingleMatchParlay_IsAllowUnlimit AS SingleMatchParlay_IsAllowUnlimit,
				bu.Combo2_IsAllowUnlimit AS Combo2_IsAllowUnlimit,
				bu.Combo35_IsAllowUnlimit AS Combo35_IsAllowUnlimit,
				bu.ComboOver6_IsAllowUnlimit AS ComboOver6_IsAllowUnlimit							
		FROM #ProductSettingProfile ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID
		ORDER BY ft.Child_DisplayOrder
	ELSE IF @RoleID = 1 AND @AgentID NOT IN (-4,-3) --Normal member
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,
				
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
																(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END), 
																(CASE WHEN abl.SingleMatchParlay = 0 THEN NULL ELSE abl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS Upline_SingleMatchParlay, 
						 
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo2) FROM (VALUES (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
																(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END), 
																(CASE WHEN abl.Combo2 = 0 THEN NULL ELSE abl.Combo2 END)) AS t(Combo2)) END AS Upline_Combo2,  

				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END), 
																(CASE WHEN abl.Combo35 = 0 THEN NULL ELSE abl.Combo35 END)) AS t(Combo35)) END AS Upline_Combo35,
			
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
																	(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END), 
																	(CASE WHEN abl.ComboOver6 = 0 THEN NULL ELSE abl.ComboOver6 END)) AS t(ComboOver6)) END AS Upline_ComboOver6,		
				0 AS SingleMatchParlay_IsAllowUnlimit,
				0 AS Combo2_IsAllowUnlimit,
				0 AS Combo35_IsAllowUnlimit,
				0 AS ComboOver6_IsAllowUnlimit				
		FROM #ProductSettingProfile ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent abl WITH (NOLOCK) ON ft.SportType = abl.sporttype AND ft.BetType = abl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID AND abl.CustID = @AgentID
		ORDER BY ft.Child_DisplayOrder
	ELSE IF @RoleID = 1 AND @AgentID = -4 --Super Direct Member
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,	
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 THEN 0
						ELSE sbl.SingleMatchParlay END AS Upline_SingleMatchParlay,  
				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo2 END AS Upline_Combo2,
				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.Combo35 END AS Upline_Combo35,
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 THEN 0 
						ELSE sbl.ComboOver6 END AS Upline_ComboOver6,
				0 AS SingleMatchParlay_IsAllowUnlimit,
				0 AS Combo2_IsAllowUnlimit,
				0 AS Combo35_IsAllowUnlimit,
				0 AS ComboOver6_IsAllowUnlimit		
		FROM #ProductSettingProfile ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID
		ORDER BY ft.Child_DisplayOrder
	ELSE IF @RoleID = 1 AND @AgentID = -3 --Master Direct Member
		SELECT	ft.SportType,
				ft.BetType,
				bl.SingleMatchParlay,
				bl.Combo2,
				bl.Combo35,		
				bl.ComboOver6,	
				CASE	WHEN bu.SingleMatchParlay_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(SingleMatchParlay) FROM (VALUES  (CASE WHEN sbl.SingleMatchParlay = 0 THEN NULL ELSE sbl.SingleMatchParlay END), 
														(CASE WHEN mbl.SingleMatchParlay = 0 THEN NULL ELSE mbl.SingleMatchParlay END)) AS t(SingleMatchParlay)) END AS Upline_SingleMatchParlay,  

				CASE	WHEN bu.Combo2_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo2) FROM (VALUES  (CASE WHEN sbl.Combo2 = 0 THEN NULL ELSE sbl.Combo2 END), 
														(CASE WHEN mbl.Combo2 = 0 THEN NULL ELSE mbl.Combo2 END)) AS t(Combo2)) END AS Upline_Combo2,  

				CASE	WHEN bu.Combo35_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(Combo35) FROM (VALUES (CASE WHEN sbl.Combo35 = 0 THEN NULL ELSE sbl.Combo35 END), 
																(CASE WHEN mbl.Combo35 = 0 THEN NULL ELSE mbl.Combo35 END)) AS t(Combo35)) END AS Upline_Combo35,
						
				CASE	WHEN bu.ComboOver6_IsAllowUnlimit = 1 
						THEN 0
						ELSE (SELECT MIN(ComboOver6) FROM (VALUES (CASE WHEN sbl.ComboOver6 = 0 THEN NULL ELSE sbl.ComboOver6 END), 
															(CASE WHEN mbl.ComboOver6 = 0 THEN NULL ELSE mbl.ComboOver6 END)) AS t(ComboOver6)) END AS Upline_ComboOver6,	
				0 AS SingleMatchParlay_IsAllowUnlimit,
				0 AS Combo2_IsAllowUnlimit,
				0 AS Combo35_IsAllowUnlimit,
				0 AS ComboOver6_IsAllowUnlimit							
		FROM #ProductSettingProfile ft 
			INNER JOIN @MatchParlayUnlimit bu ON ft.SportType = bu.sporttype AND ft.BetType = bu.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Member bl WITH (NOLOCK) ON ft.SportType = bl.sporttype AND ft.BetType = bl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent sbl WITH (NOLOCK) ON ft.SportType = sbl.sporttype AND ft.BetType = sbl.bettype
			INNER JOIN dbo.CustMaxPayoutSetting_Agent mbl WITH (NOLOCK) ON ft.SportType = mbl.sporttype AND ft.BetType = mbl.bettype
		WHERE bl.CustID = @CustID AND sbl.CustID = @SuperID AND mbl.CustID = @MasterID
		ORDER BY ft.Child_DisplayOrder

	DROP TABLE #ProductSettingProfile
END

