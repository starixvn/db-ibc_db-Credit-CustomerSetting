/*<info serverAlias="DBCust-CustDB" executers="svc_tig,Dot_Intg" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Dot_Member_ProductStatusList_DCS]
	@CustID INT,
	@IsTest BIT = 0
AS
/*
	Created: 20160810@Elodie
	Task : Get product status setting of customer
	DB: DBCUST/CustDB
	Original:
	Revisions:  
	Param's Explanation:
		- 20161222@Elodie: Set IsLaunched = 0 if IsHidden = 1
		- 20170309@Elodie: Add new setting type 13
		- 20170630@Elodie: Add code to control CANSEE for BetRadarVS
		- 20180212@Vicky: Add code to control CANSEE for Basketball [RedmineID: #89284]
		- 20180412@Vicky: Add code to control CANSEE for PP Game [RedmineID: #90422]
		- 20181123@Winnie: VS Betradar 3 - Virtual Soccer Asian Cup [RedmineID: #104809]
		- 20200317@Tiara: Betradar Virtual Sport - Phase 4 - New sporttype 196 [RedmineID: #105411]
		- 20200408@Tiara: Betradar Virtual Sport - Phase 4 - New sporttype 197 [RedmineID: #132040]
		- 20210512@Eden: MaxGame - Support can-see [RedmineID: #154951]
		- 20210810@Elodie: Add NOLOCK [RedmineID: #159964]
		- 20220627@Eden: Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20220830@Tacy: Add code to control CANSEE for SEAL Entertainment [RedmineID: #176209]
		- 20221222@Winfred: Update Cansee for RNG SLOT [RedmineID: #181929]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230728@Eden: Simplify Live Casino Customer Setting [RedmineID: #189389]
		- 20240307@Luke: Show Product Status [Redmine: #202011]
		- 20240312@Elodie: Enhance SP [Redmine:#199517]
		- 20240316@Eden: Unify Live RNG Casino [Redmine: #198960] 
		- 20240626@Eden: Tuning SP [Redmine: #207072]   
		- 20240702@Eden: Hotfix - wrong Other RNG Casino status [Redmine: #207072] 
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20240912@Virgil: Add ON Casino to Live Casino [Redmine: #210025] 

	Example: EXEC Dot_Member_ProductStatusList_DCS @CustID = 1176092, @IsTest = 0
*/
BEGIN
	DECLARE @SiteID INT, @Currency TINYINT, @IsLaunched BIT
	SET @IsLaunched = 0

	SELECT @SiteID = s.siteid, @Currency = c.currency
	FROM Customer c WITH (NOLOCK)
		INNER JOIN site s WITH (NOLOCK) ON s.site = c.site
	WHERE c.custid = @CustID

	IF @IsTest = 1 -- Testing mode
	BEGIN
		;WITH cte AS
		(
			SELECT SportType,BetType
			FROM dbo.f_CustSetting_ProductSettingDetailSel(1)
			WHERE SettingType IN (4,11,13,21)
				AND SettingStatus = 1
			UNION 
			SELECT SportType,BetType
			FROM dbo.f_CustSetting_ProductSettingDetailSel(3)
			WHERE SettingType IN (4,11,13,21)
		)
		--Get Product Status
		SELECT DISTINCT cs.CustID, t.Sporttype, CASE t.Sporttype	
											WHEN 44		THEN CAST(20	AS SMALLINT)
											--RNG Casino
											WHEN 248	THEN CAST(4101	AS SMALLINT)
											WHEN 237	THEN CAST(5401	AS SMALLINT)
											WHEN 156	THEN CAST(8900	AS SMALLINT)
											WHEN 224	THEN CAST(5500	AS SMALLINT)
											--Live Casino
											WHEN 159	THEN CAST(3151	AS SMALLINT)
											WHEN 170	THEN CAST(3701	AS SMALLINT)
											WHEN 211	THEN CAST(2401	AS SMALLINT)
											WHEN 225	THEN CAST(5601	AS SMALLINT)
											WHEN 233	THEN CAST(3401	AS SMALLINT)
											WHEN 236	THEN CAST(5701	AS SMALLINT)
											WHEN 239	THEN CAST(3501	AS SMALLINT)
											WHEN 241	THEN CAST(3300	AS SMALLINT)
											WHEN 242	THEN CAST(3201	AS SMALLINT)
											WHEN 243	THEN CAST(3101	AS SMALLINT)
											WHEN 244	THEN CAST(3001	AS SMALLINT)
											WHEN 228	THEN CAST(10300 AS SMALLINT)
											WHEN 176	THEN CAST(8201  AS SMALLINT)
											WHEN 138	THEN CAST(11850 AS SMALLINT)
											--Other RNG Casino
											WHEN 245	THEN CAST(4601	AS SMALLINT)
											WHEN 208	THEN CAST(2101	AS SMALLINT)
											WHEN 171	THEN CAST(3801  AS SMALLINT)
											WHEN 200	THEN CAST(1611  AS SMALLINT)
											WHEN 240	THEN CAST(10801 AS SMALLINT)
											----Keno/Lottery
											WHEN 220	THEN CAST(1024	AS SMALLINT)
											WHEN 222	THEN CAST(4901  AS SMALLINT)
											ELSE ps.Bettype END AS Bettype, 
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) AS IsHidden, 
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled, ps.bitmapOrder)) AS IsDisabled, 
				CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) = 1 THEN @IsLaunched ELSE t.IsLaunched END AS IsLaunched
		FROM cte sd
			CROSS APPLY( SELECT TOP 1 ps.Sporttype,ps.Bettype,ps.bitmapOrder FROM dbo.ProductStatusProfile ps WITH (NOLOCK) WHERE ps.Sporttype = sd.SportType AND ps.Bettype = sd.BetType) ps 
			CROSS APPLY ( SELECT DISTINCT SportType, IsLaunched
						FROM dbo.ProductLaunchedSiteCurrency psc WITH (NOLOCK) 
						WHERE psc.IsTest <= @IsTest                            
								AND psc.SiteID IN (@SiteID,0)  
								AND psc.Currency IN(@Currency,0) 
								AND NOT (psc.Currency = 0  AND psc.SiteID = 0) -- Not apply config for all site currency
								AND  (CASE WHEN psc.SportType IN (248,237,156,224) THEN 9906 --RNG Casino
										   WHEN psc.SportType IN (159,170,211,225,233,236,239,241,242,243,244,228,176,138) THEN 9911 --Live Casino
										   WHEN psc.SportType IN (245,208,171,200,240) THEN 9918 --Other RNG Casino
										   WHEN psc.SportType IN (220,222) THEN 9919 --Keno/Lottery
										   ELSE psc.SportType END) = ps.Sporttype
							) AS t
			CROSS APPLY dbo.CustProductStatus cs WITH (NOLOCK)
		WHERE cs.CustID = @CustID	
	END
	ELSE --Prod Mode
	BEGIN
		;WITH cte AS
		(
			SELECT SportType,BetType
			FROM dbo.f_CustSetting_ProductSettingDetailSel(0)
			WHERE SettingType IN (4,11,13,21)
		)
		--Get Product Status
		SELECT DISTINCT cs.CustID, t.Sporttype, CASE t.Sporttype	
											WHEN 44		THEN CAST(20	AS SMALLINT)
											--RNG Casino
											WHEN 248	THEN CAST(4101	AS SMALLINT)
											WHEN 237	THEN CAST(5401	AS SMALLINT)
											WHEN 156	THEN CAST(8900	AS SMALLINT)
											WHEN 224	THEN CAST(5500	AS SMALLINT)
											--Live Casino
											WHEN 159	THEN CAST(3151	AS SMALLINT)
											WHEN 170	THEN CAST(3701	AS SMALLINT)
											WHEN 211	THEN CAST(2401	AS SMALLINT)
											WHEN 225	THEN CAST(5601	AS SMALLINT)
											WHEN 233	THEN CAST(3401	AS SMALLINT)
											WHEN 236	THEN CAST(5701	AS SMALLINT)
											WHEN 239	THEN CAST(3501	AS SMALLINT)
											WHEN 241	THEN CAST(3300	AS SMALLINT)
											WHEN 242	THEN CAST(3201	AS SMALLINT)
											WHEN 243	THEN CAST(3101	AS SMALLINT)
											WHEN 244	THEN CAST(3001	AS SMALLINT)
											WHEN 228	THEN CAST(10300 AS SMALLINT)
											WHEN 176	THEN CAST(8201  AS SMALLINT)
											WHEN 138	THEN CAST(11850 AS SMALLINT)
											--Other RNG Casino
											WHEN 245	THEN CAST(4601	AS SMALLINT)
											WHEN 208	THEN CAST(2101	AS SMALLINT)
											WHEN 171	THEN CAST(3801  AS SMALLINT)
											WHEN 200	THEN CAST(1611  AS SMALLINT)
											WHEN 240	THEN CAST(10801 AS SMALLINT)
											----Keno/Lottery
											WHEN 220	THEN CAST(1024	AS SMALLINT)
											WHEN 222	THEN CAST(4901  AS SMALLINT)
											ELSE ps.Bettype END AS Bettype, 
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) AS IsHidden, 
				(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled, ps.bitmapOrder)) AS IsDisabled, 
				CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) = 1 THEN @IsLaunched ELSE t.IsLaunched END AS IsLaunched
		FROM cte sd
			CROSS APPLY( SELECT TOP 1 ps.Sporttype,ps.Bettype,ps.bitmapOrder FROM dbo.ProductStatusProfile ps WITH (NOLOCK) WHERE ps.Sporttype = sd.SportType AND ps.Bettype = sd.BetType) ps 
			CROSS APPLY ( SELECT DISTINCT SportType, IsLaunched
						FROM dbo.ProductLaunchedSiteCurrency psc WITH (NOLOCK) 
						WHERE psc.IsTest <= @IsTest                            
								AND psc.SiteID IN (@SiteID,0)  
								AND psc.Currency IN(@Currency,0) 
								AND NOT (psc.Currency = 0  AND psc.SiteID = 0) -- Not apply config for all site currency
								AND  (CASE WHEN psc.SportType IN (248,237,156,224) THEN 9906 --RNG Casino
										   WHEN psc.SportType IN (159,170,211,225,233,236,239,241,242,243,244,228,176,138) THEN 9911 --Live Casino
										   WHEN psc.SportType IN (245,208,171,200,240) THEN 9918 --Other RNG Casino
										   WHEN psc.SportType IN (220,222) THEN 9919 --Keno/Lottery
										   ELSE psc.SportType END) = ps.Sporttype
							) AS t
			CROSS APPLY dbo.CustProductStatus cs WITH (NOLOCK)
		WHERE cs.CustID = @CustID	
	END
END
GO