--/*<info serverAlias="DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB" selecters="wsv_xnap" viewers="" isFunction="1"></info>*/
ALTER FUNCTION dbo.f_CustSetting_SportBetTypeSettingMatrix ( @SettingStatus TINYINT )
RETURNS TABLE AS
/*      
	Created by: Helios      
	Date: 20240314      
	Task: Get data SportBetTypeSettingMatrix    
	DB: DBCUST-CustDB,DBAGE-bodb02,DBACC-bodb02,DBTXN-CustDB    
	Original:       
		         
	Revisions:      
	- 20240314@Helios: Unify Live RNG Casino [Redmine: #198960]
	- 20240521@Helios: Unify RNG Games [Redmine: #204358]

	Explanation's Param:      
	@SettingStatus: 0: Pro, 1: UAT      
		       
	Examples:    
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (3)
	SELECT * FROM f_CustSetting_SportBetTypeSettingMatrix_UAT4 (0) 
*/
RETURN

WITH CTE AS
		(
			-- 3:	Number Game
			SELECT RealProductId , ProductID , Sporttype , Bettype , isLicensee , isLive , Site
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)
			WHERE isDeleted = 0
			AND sbsm.isLicensee = 0
			AND sbsm.Site = 'ALL'
			AND sbsm.RealProductId = 3
			AND @SettingStatus >= 1

			UNION ALL

			-- 5: Virtual Sports  
			SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site  
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
			WHERE isDeleted = 0  
			AND sbsm.isLicensee = 0  
			AND sbsm.Site = 'ALL'  
			AND sbsm.ProductID = 5
			AND @SettingStatus >= 1  

			UNION ALL

			-- 8: RNG Keno 
			SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site  
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
			WHERE isDeleted = 0  
			AND sbsm.isLicensee = 0  
			AND sbsm.Site = 'ALL'  
			AND sbsm.RealProductId = 8
			AND @SettingStatus >= 1  

			UNION ALL

			-- 28: Lottery
			SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site  
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
			WHERE isDeleted = 0  
			AND sbsm.isLicensee = 0  
			AND sbsm.Site = 'ALL'  
			AND sbsm.RealProductId = 28
			AND @SettingStatus >= 1
			
			UNION ALL

			-- 40: Table Game
			SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site  
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
			WHERE isDeleted = 0  
			AND sbsm.isLicensee = 0  
			AND sbsm.Site = 'ALL'  
			AND sbsm.RealProductId = 40
			AND @SettingStatus >= 1

			UNION ALL

			-- 63: Sports Lottery
			SELECT RealProductId , ProductID , SportType , BetType , isLicensee , isLive , Site  
			FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
			WHERE isDeleted = 0  
			AND sbsm.isLicensee = 0  
			AND sbsm.Site = 'ALL'  
			AND sbsm.RealProductId = 63
			AND @SettingStatus >= 1
		)

 --SELECT DISTINCT SportType , BetType , isLicensee, Site, isLive FROM CTE
-- to get Product Non-Affected    
SELECT
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
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
RIGHT JOIN SportBettypeSettingMatrix sbsm WITH (NOLOCK) ON 
		c.Sporttype = sbsm.Sporttype
		AND c.Bettype = sbsm.Bettype
		AND c.isLicensee = sbsm.isLicensee
		AND c.isLive = sbsm.isLive
		AND c.Site = sbsm.Site
WHERE @SettingStatus >= 1
AND  c.SportType IS NULL



---- to include Product Change Affected    
UNION ALL

-- Number Games : 3
SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, CASE WHEN sbsm.SportType  IN (164,168)  THEN  161 ELSE sbsm.SportTypeRefBetSetting END AS SportTypeRefBetSetting
	, CASE WHEN sbsm.SportType  IN (164,168)  THEN  81 ELSE sbsm.BetTypeRefBetSetting END AS BetTypeRefBetSetting
	, sbsm.SporttypeRefWinlossLimit
	, sbsm.BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 3
AND sbsm.SportType  IN (161,164,168) 
AND sbsm.BetType <> 81
AND @SettingStatus >= 1

UNION ALL

SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, sbsm.SportTypeRefBetSetting
	, sbsm.BetTypeRefBetSetting
	, 9909 AS  SporttypeRefWinlossLimit
	, 3700 AS BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 3
AND sbsm.SportType  = 161 
AND sbsm.BetType = 81
AND @SettingStatus >= 1

UNION ALL

---- Virtual Sports : 5
SELECT 
	  sbsm.RealProductId
	, 44 AS ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, sbsm.SportTypeRefBetSetting
	, sbsm.BetTypeRefBetSetting
	, sbsm.SporttypeRefWinlossLimit
	, sbsm.BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.ProductID = 5
AND @SettingStatus >= 1

UNION ALL

SELECT TOP 1
	  sbsm.RealProductId
	, 44 AS ProductID
	, 9908 AS Sporttype
	, 1201 AS Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, 9908 AS SportTypeRefBetSetting
	, 1201 AS BetTypeRefBetSetting
	, 9908 AS  SporttypeRefWinlossLimit
	, 1201 AS  BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 5
AND @SettingStatus >= 1

UNION ALL

---- RNG Keno : 8
SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, 9919 AS SportTypeRefBetSetting
	, 1501 AS BetTypeRefBetSetting
	, sbsm.SporttypeRefWinlossLimit
	, sbsm.BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 8
AND @SettingStatus >= 1

UNION ALL

SELECT TOP 1
	  sbsm.RealProductId
	, sbsm.ProductID
	, 202 AS Sporttype
	, 1501 AS Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, 9919 AS SportTypeRefBetSetting
	, 1501 AS BetTypeRefBetSetting
	, 9909 AS SporttypeRefWinlossLimit
	, 3700 AS BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 8
AND @SettingStatus >= 1

UNION ALL

---- Lottery : 28
SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, 9919 AS SportTypeRefBetSetting
	, 1501 AS BetTypeRefBetSetting
	, SporttypeRefWinlossLimit
	, BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 28
AND @SettingStatus >= 1

--UNION ALL

--SELECT  TOP 1
--	  sbsm.RealProductId
--	, sbsm.ProductID
--	, 220 AS Sporttype
--	, 1024 AS Bettype
--	, sbsm.isLicensee
--	, sbsm.isLive
--	, sbsm.Site
--	, sbsm.isActive
--	, 9909 AS SportTypeRefPT
--	, 3700 AS BetTypeRefPT
--	, sbsm.SportTypeRefComm
--	, sbsm.BetTypeRefComm
--	, 9919 AS SportTypeRefBetSetting
--	, 1501 AS BetTypeRefBetSetting
--	, 9909 AS SporttypeRefWinlossLimit
--	, 3700 AS BettypeRefWinlossLimit
--	, sbsm.isDeleted
--FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
--WHERE isDeleted = 0  
--AND sbsm.isLicensee = 0  
--AND sbsm.Site = 'ALL'  
--AND sbsm.RealProductId = 28
--AND @SettingStatus >= 1

UNION ALL

---- Table Game : 40
SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, 9919 AS SportTypeRefBetSetting
	, 1501 AS BetTypeRefBetSetting
	, sbsm.SporttypeRefWinlossLimit
	, sbsm.BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 40
AND @SettingStatus >= 1


--UNION ALL

------ RNG Lottery : 44
--SELECT 
--	  44 AS RealProductId
--	, 44 AS ProductID
--	, 9909 AS Sporttype
--	, 3700 AS Bettype
--	, 0 AS isLicensee
--	, 0 AS isLive
--	, 'ALL' AS Site
--	, 1 AS isActive
--	, 9909 AS SportTypeRefPT
--	, 3700 AS BetTypeRefPT
--	, NULL AS SportTypeRefComm
--	, NULL AS BetTypeRefComm
--	, 9909 AS SportTypeRefBetSetting
--	, 3700 AS BetTypeRefBetSetting
--	, 9909 AS SporttypeRefWinlossLimit
--	, 3700 AS BettypeRefWinlossLimit
--	, 0 AS isDeleted
--WHERE @SettingStatus >= 1

UNION ALL

---- Sports Lottery : 63
SELECT 
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
	, sbsm.isLicensee
	, sbsm.isLive
	, sbsm.Site
	, sbsm.isActive
	, 9909 AS SportTypeRefPT
	, 3700 AS BetTypeRefPT
	, sbsm.SportTypeRefComm
	, sbsm.BetTypeRefComm
	, SportTypeRefBetSetting
	, BetTypeRefBetSetting
	, sbsm.SporttypeRefWinlossLimit
	, sbsm.BettypeRefWinlossLimit
	, sbsm.isDeleted
FROM SportBettypeSettingMatrix sbsm WITH (NOLOCK)  
WHERE isDeleted = 0  
AND sbsm.isLicensee = 0  
AND sbsm.Site = 'ALL'  
AND sbsm.RealProductId = 63
AND @SettingStatus >= 1


UNION ALL

-- Production Mode:      
SELECT
	  sbsm.RealProductId
	, sbsm.ProductID
	, sbsm.Sporttype
	, sbsm.Bettype
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
WHERE sbsm.isDeleted = 0
AND @SettingStatus = 0    
  
  
 
