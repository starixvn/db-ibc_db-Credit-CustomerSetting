/*<info serverAlias="DBCust-CustDB" executers="Dot_Member,Dot_Intg" viewers="" isFunction="0"></info>*/
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

	Example: EXEC Dot_Member_ProductStatusList_DCS @CustID = 1176092, @IsTest = 1
*/
BEGIN
	DECLARE @SiteID INT, @Currency TINYINT, @IsLaunched BIT
	SET @IsLaunched = 0

	DECLARE @ProductSettingDetail TABLE(
		[SportType] [smallint],
		[BetType] [smallint],
		PRIMARY KEY(SportType,BetType)
	)

	IF @IsTest = 1
	BEGIN
		INSERT INTO @ProductSettingDetail(SportType,BetType)
		SELECT SportType,BetType
		FROM dbo.f_CustSetting_ProductSettingDetailSel(1)
		WHERE SettingType IN (4,11,13,21)
			AND SettingStatus = 1
		UNION 
		SELECT SportType,BetType
		FROM dbo.f_CustSetting_ProductSettingDetailSel(3)
		WHERE SettingType IN (4,11,13,21)
	END
	ELSE
	BEGIN
		INSERT INTO @ProductSettingDetail(SportType,BetType)
		SELECT SportType,BetType
		FROM dbo.f_CustSetting_ProductSettingDetailSel(0)
		WHERE SettingType IN (4,11,13,21)
	END

	SELECT @SiteID = s.siteid, @Currency = c.currency
	FROM Customer c WITH (NOLOCK)
		INNER JOIN Customer ag WITH (NOLOCK) ON c.recommend = ag.custid 
		INNER JOIN site s WITH (NOLOCK) ON s.site = ag.site
	WHERE c.custid = @CustID

	--Get Product Status
	declare @BetType20 SMALLINT, @BetType2701 SMALLINT,@BetType2801 SMALLINT, @BetType4101 SMALLINT ,@Bettype5401 SMALLINT ,@Bettype8900 SMALLINT
	SELECT @BetType20=20, @BetType4101 = 4101, @Bettype5401 = 5401, @Bettype8900=8900

	SELECT DISTINCT cs.CustID, psc.Sporttype, CASE psc.Sporttype	
	                                    WHEN 44  THEN @BetType20 
										WHEN 248 THEN @BetType4101
										WHEN 237 THEN @Bettype5401
										WHEN 156 THEN @Bettype8900
										ELSE ps.Bettype END AS Bettype, 
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) AS IsHidden, 
			(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsDisabled, ps.bitmapOrder)) AS IsDisabled, 
			CASE	WHEN (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(cs.bitmapIsHidden, ps.bitmapOrder)) = 1 THEN @IsLaunched ELSE psc.IsLaunched END AS IsLaunched
	FROM @ProductSettingDetail sd
		INNER JOIN dbo.ProductStatusProfile ps WITH (NOLOCK) ON ps.Sporttype = sd.SportType AND ps.Bettype = sd.BetType
		INNER JOIN
					(	SELECT SportType, IsLaunched
					FROM dbo.ProductLaunchedSiteCurrency psc WITH (NOLOCK) 
					WHERE psc.IsTest <= @IsTest
						AND psc.Currency = @Currency  
						AND (psc.SiteID = @SiteID OR psc.SiteID = 0)
					UNION -- NOT UNION ALL
					SELECT SportType, IsLaunched
					FROM dbo.ProductLaunchedSiteCurrency psc WITH (NOLOCK) 
					WHERE psc.IsTest <= @IsTest AND psc.SiteID = @SiteID AND (psc.Currency = @Currency OR psc.Currency = 0) 
				) as psc ON  (CASE psc.SportType 
				                WHEN 248 THEN 9906
								WHEN 237 THEN 9906
								WHEN 156 THEN 9906
				                ELSE psc.Sporttype END) = ps.Sporttype
		CROSS APPLY dbo.CustProductStatus cs WITH (NOLOCK)
	WHERE cs.CustID = @CustID
END
GO