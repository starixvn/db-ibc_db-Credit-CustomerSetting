/*<info serverAlias="DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="wsv_xnap" viewers="" isFunction="1"></info>*/
CREATE FUNCTION dbo.f_CustSetting_SportBetTypeSettingMatrix ( @SettingStatus TINYINT )
RETURNS TABLE AS
/*      
	Created by: Helios      
	Date: 20240314      
	Task: Get data SportBetTypeSettingMatrix    
	DB: DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB    
	Original:       
		         
	Revisions:      
	- 20240314@Helios: Unify Live RNG Casino [Redmine: #198960]    
	Explanation's Param:      
	@SettingStatus: 0: Pro, 1: UAT      
		       
	Examples:    
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (3)
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (0) 
*/
	RETURN

	-- UAT Mode:    
	-- to exclude Product Affected  
	WITH CTE AS
	(
		-- Saba Casino (6)    

		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 6
			AND
			@SettingStatus >= 1

		UNION ALL

		-- Saba Games (42)    

		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 42
			AND
			@SettingStatus >= 1

		UNION ALL

		-- FGG (70)  

		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 70
			AND
			@SettingStatus >= 1

		UNION ALL

		-- Virtual Games (38)
		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 38
			AND
			@SettingStatus >= 1

		UNION ALL

		-- Funky Games (50)
		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 50
			AND
			@SettingStatus >= 1

		UNION ALL

		-- VGaming (66)
		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 66
			AND
			@SettingStatus >= 1

		UNION ALL

		-- RNG Slot (18)
		SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.ProductID = 18
			AND
			@SettingStatus >= 1
	)

	-- to get Product Non-Affected  
	SELECT
		sbsm.RealProductId
		, sbsm.ProductID
		, sbsm.SportType
		, sbsm.BetType
		, sbsm.isLicensee
		, sbsm.isLive
		, sbsm.Site
		, sbsm.isActive
		, sbsm.SportTypeRefPT
		, sbsm.BetTypeRefPT
		, sbsm.SportTypeRefComm
		, sbsm.BetTypeRefComm
		, sbsm.SportTypeRefBetSetting
		, sbsm.BetTypeRefBetSetting
		, sbsm.SporttypeRefWinlossLimit
		, sbsm.BettypeRefWinlossLimit
		, sbsm.isDeleted
	FROM CTE c
	RIGHT JOIN SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			ON c.SportType = sbsm.SportType
			AND c.BetType = sbsm.BetType 
			AND c.isLicensee = sbsm.isLicensee
			AND c.isLive = sbsm.isLive
			AND c.Site = sbsm.Site
	WHERE c.SportType IS NULL
	AND @SettingStatus >= 1

	-- to include Product Change Affected  
	UNION ALL

	-- FGG (70) : RealProductID - Real SportType - Real BetType : Change DummyProductID , SportTypeRefPT , BetTypeRefPT , SporttypeRefWinlossLimit , BettypeRefWinlossLimit
	SELECT
		  RealProductId
		, 41   AS ProductID
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9911 AS SportTypeRefPT
		, 2400 AS BetTypeRefPT
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, 9911 AS SporttypeRefWinlossLimit
		, 2400 AS BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 70 
	AND sbsm.SportType = 176 
	AND sbsm.BetType = 8201 
	AND @SettingStatus >= 1

	UNION ALL

	-- FGG (70)  : RealProductID - (SportType - BetType PlaceBet) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT  
		  RealProductId
		, 41   AS ProductID     
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9911 AS SportTypeRefPT
		, 2400 AS BetTypeRefPT
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit   
		, BettypeRefWinlossLimit  
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 70
	AND sbsm.SportType = 176
	AND sbsm.BetType <> 8201
	AND @SettingStatus >= 1

	--UNION ALL

	---- Saba Casino (6) : RealProductID - Real SportType - Real BetType : Change DummyProductID , SportTypeRefPT , BetTypeRefPT , SporttypeRefWinlossLimit , BettypeRefWinlossLimit
	--SELECT
	--	  RealProductId
	--	, 53   AS ProductID
	--	, SportType
	--	, BetType
	--	, isLicensee
	--	, isLive
	--	, Site
	--	, isActive
	--	, 9918 AS SportTypeRefPT
	--	, 4601 AS BetTypeRefPT
	--	, SportTypeRefComm
	--	, BetTypeRefComm
	--	, SportTypeRefBetSetting
	--	, BetTypeRefBetSetting
	--	, 9918 AS SporttypeRefWinlossLimit
	--	, 4601 AS BettypeRefWinlossLimit
	--	, isDeleted
	--FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	--WHERE sbsm.isLicensee = 0
	--AND sbsm.Site = 'ALL'
	--AND sbsm.RealProductId = 6
	--AND sbsm.SportType = 208
	--AND sbsm.BetType = 2101
	--AND @SettingStatus >= 1

	UNION ALL

	-- Saba Casino (6) : RealProductID - (SportType - BetType PlaceBet) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT
		  RealProductId
		, 53   AS ProductID     -- Changed  
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9918 AS SportTypeRefPT
		, 4601 AS BetTypeRefPT
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit
		, BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 6
	--AND (
	--	sbsm.SportType = 208 AND sbsm.BetType <> 2101
	--	OR
	--	sbsm.SportType <> 208 
	--     )
	AND @SettingStatus >= 1

	UNION ALL

	-- Saba Games (42) : RealProductID - (SportType - BetType PlaceBet) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT
		  RealProductId
		, 53   AS ProductID     -- Changed  
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9918 AS SportTypeRefPT
		, 4601 AS BetTypeRefPT
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit
		, BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 42
	--AND (
	--	sbsm.SportType = 208 AND sbsm.BetType <> 2101
	--	OR
	--	sbsm.SportType <> 208 
	--     )
	AND @SettingStatus >= 1


	--UNION ALL

	---- Funky Games (50) : RealProductID - Real SportType - Real BetType : Change DummyProductID , SportTypeRefPT , BetTypeRefPT , SporttypeRefWinlossLimit , BettypeRefWinlossLimit
	--SELECT
	--	  RealProductId
	--	, 53   AS ProductID 
	--	, SportType
	--	, BetType
	--	, isLicensee
	--	, isLive
	--	, Site
	--	, isActive
	--	, 9906 AS SportTypeRefPT
	--	, 4001 AS BetTypeRefPT
	--	, SportTypeRefComm
	--	, BetTypeRefComm
	--	, SportTypeRefBetSetting
	--	, BetTypeRefBetSetting
	--	, 9906 AS SporttypeRefWinlossLimit
	--	, 4001 AS BettypeRefWinlossLimit
	--	, isDeleted
	--FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	--WHERE sbsm.isLicensee = 0
	--AND sbsm.Site = 'ALL'
	--AND sbsm.RealProductId = 50
	--AND sbsm.SportType = 224
	--AND sbsm.BetType = 5500
	--AND @SettingStatus >= 1

	UNION ALL

	-- Funky Games (50) : RealProductID - (SportType - BetType PlaceBet) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT
		  RealProductId
		, 53   AS ProductID
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9906 AS SportTypeRefPT
		, 4001 AS BetTypeRefPT 
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, NULL AS SporttypeRefWinlossLimit
		, NULL AS BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 50
	--AND sbsm.SportType = 224
	--AND sbsm.BetType <> 5500
	AND @SettingStatus >= 1

	UNION ALL

	-- Virtual Games (38) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT
		  RealProductId
		, 53   AS ProductID    -- Changed  
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9918 AS SportTypeRefPT   -- Changed  
		, 4601 AS BetTypeRefPT   -- Changed  
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit
		, BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 38
	AND @SettingStatus >= 1


	UNION ALL

	-- Dummy Product RNG Slot (18) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	-- Affted RealProductID:  Macau Games (22), PP (32), Arcadia Gaming (34), SG (36), PG Soft (55),  Joker (56), MaxGame (60), Habanero (61),  CG (62), AdvantPlay (67), AdvantPlay Mini (68), SEAL Entertainment (72), MG-RNG (73), Jili (75), UU Slots (78), Yolo Play (84)  
	SELECT
		  RealProductId
		, 53   AS ProductID    -- Changed  
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9906 AS SportTypeRefPT   -- Changed  
		, 4001 AS BetTypeRefPT   -- Changed  
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit
		, BettypeRefWinlossLimit
		, sbsm.isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.ProductID = 18
	AND @SettingStatus >= 1

	UNION ALL

	-- Vgaming (66) : RealProductID - (SportType - BetType PlaceBet) : Change DummyProductID , SportTypeRefPT , BetTypeRefPT
	SELECT
		  RealProductId
		, 53   AS ProductID    -- Changed  
		, SportType
		, BetType
		, isLicensee
		, isLive
		, Site
		, isActive
		, 9918 AS SportTypeRefPT   -- Changed  
		, 4601 AS BetTypeRefPT   -- Changed  
		, SportTypeRefComm
		, BetTypeRefComm
		, SportTypeRefBetSetting
		, BetTypeRefBetSetting
		, SporttypeRefWinlossLimit
		, BettypeRefWinlossLimit
		, isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE sbsm.isLicensee = 0
	AND sbsm.Site = 'ALL'
	AND sbsm.RealProductId = 66
	AND @SettingStatus >= 1


	UNION ALL

	-- Vgaming (66) : Initial New Real Sport Type - BetType
	SELECT
		  66    AS RealProductId
		, 53    AS ProductID
		, 171   AS SportType
		, 3801  AS BetType
		, 0	    AS isLicensee
		, 0	    AS isLive
		, 'ALL'   AS Site
		, 1	    AS isActive
		, 9918  AS SportTypeRefPT
		, 4601  AS BetTypeRefPT
		, NULL  AS SportTypeRefComm
		, NULL  AS BetTypeRefComm
		, NULL  AS SportTypeRefBetSetting
		, NULL  AS BetTypeRefBetSetting
		, NULL  AS SporttypeRefWinlossLimit
		, NULL  AS BettypeRefWinlossLimit
		, 0	    AS isDeleted
	WHERE @SettingStatus >= 1

	UNION ALL

	-- SabaGames (42) : Initial New Real Sport Type - BetType
	SELECT
		  42    AS RealProductId
		, 53    AS ProductID
		, 200   AS SportType
		, 1611  AS BetType
		, 0	    AS isLicensee
		, 0	    AS isLive
		, 'ALL'   AS Site
		, 1	    AS isActive
		, 9918  AS SportTypeRefPT
		, 4601  AS BetTypeRefPT
		, NULL  AS SportTypeRefComm
		, NULL  AS BetTypeRefComm
		, NULL  AS SportTypeRefBetSetting
		, NULL  AS BetTypeRefBetSetting
		, NULL  AS SporttypeRefWinlossLimit
		, NULL  AS BettypeRefWinlossLimit
		, 0	    AS isDeleted
	WHERE @SettingStatus >= 1

	UNION ALL

	-- SABA xD (86) : Initial New Real Sport Type - BetType
	SELECT
		  86    AS RealProductId
		, 53    AS ProductID
		, 240   AS SportType
		, 10801  AS BetType
		, 0	    AS isLicensee
		, 0	    AS isLive
		, 'ALL'   AS Site
		, 1	    AS isActive
		, 9918  AS SportTypeRefPT
		, 4601  AS BetTypeRefPT
		, NULL  AS SportTypeRefComm
		, NULL  AS BetTypeRefComm
		, NULL  AS SportTypeRefBetSetting
		, NULL  AS BetTypeRefBetSetting
		, NULL  AS SporttypeRefWinlossLimit
		, NULL  AS BettypeRefWinlossLimit
		, 0	    AS isDeleted
	WHERE @SettingStatus >= 1


	UNION ALL

	-- RNG Casino  (53)  
	SELECT
		  53    AS RealProductId
		, 53    AS ProductID
		, 9906  AS SportType
		, 4001  AS BetType
		, 0	    AS isLicensee
		, 0	    AS isLive
		, 'All'   AS Site
		, 0	    AS isActive
		, 9906  AS SportTypeRefPT
		, 4001  AS BetTypeRefPT
		, 9906  AS SportTypeRefComm
		, 4001  AS BetTypeRefComm
		, 9906  AS SportTypeRefBetSetting
		, 4001  AS BetTypeRefBetSetting
		, 9906  AS SporttypeRefWinlossLimit
		, 4001  AS BettypeRefWinlossLimit
		, 0	    AS isDeleted
	WHERE @SettingStatus >= 1

	UNION ALL

	--Other RNG Casino  (53)  
	SELECT
		  53    AS RealProductId
		, 53    AS ProductID
		, 9918  AS SportType
		, 4601  AS BetType
		, 0	    AS isLicensee
		, 0	    AS isLive
		, 'All'   AS Site
		, 0	    AS isActive
		, 9918  AS SportTypeRefPT
		, 4601  AS BetTypeRefPT
		, 9918  AS SportTypeRefComm
		, 4601  AS BetTypeRefComm
		, 9918  AS SportTypeRefBetSetting
		, 4601  AS BetTypeRefBetSetting
		, 9918  AS SporttypeRefWinlossLimit
		, 4601  AS BettypeRefWinlossLimit
		, 0	    AS isDeleted
	WHERE @SettingStatus >= 1

	UNION ALL



	-- Production Mode:    
	SELECT
		  sbsm.RealProductId
		, sbsm.ProductID
		, sbsm.SportType
		, sbsm.BetType
		, sbsm.isLicensee
		, sbsm.isLive
		, sbsm.Site
		, sbsm.isActive
		, sbsm.SportTypeRefPT
		, sbsm.BetTypeRefPT
		, sbsm.SportTypeRefComm
		, sbsm.BetTypeRefComm
		, sbsm.SportTypeRefBetSetting
		, sbsm.BetTypeRefBetSetting
		, sbsm.SporttypeRefWinlossLimit
		, sbsm.BettypeRefWinlossLimit
		, sbsm.isDeleted
	FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
	WHERE @SettingStatus = 0  