/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Acc_CustSetting_SuperPTSelect
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
	, @SystemID	TINYINT = 1
AS
/*
	Created: 20200612@Elodie
	Task : Get Super'PT values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20200612@Elodie: Initial SP for setting type 18 [Redmine: #135363]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221006@Winfred: Don't show setting of products which are not offered to a credit site [Redmine: #174744]
		
	Param's Explanation:
		- @CustID: Super's ID
		- @SettingStatus: 0: Pro, 1: UAT
		- @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
	
*/
BEGIN
	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT)
	
	DECLARE @Siteid INT, @currency	TINYINT
	SELECT @Siteid=s.siteid, @currency = ci.currency  
	FROM dbo.Customer ci WITH(NOLOCK)  
	INNER JOIN Site s  WITH(NOLOCK) ON ci.site = s.site
	WHERE ci.custid=@CustID 
	
	IF @SystemID IN (2, 4)
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
		SELECT a.SportType, a.Bettype, a.IsLive, a.SettingType 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus) a
			INNER JOIN dbo.f_CustSetting_ProductHiddenStatusSettingSelect(@ProductID,@Siteid,@currency,18,@SettingStatus) b ON a.SportType  = b.SportType AND a.Bettype = b.Bettype AND a.IsLive = b.IsLive
	END
	ELSE
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
		SELECT SportType, Bettype, IsLive, SettingType 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus)
	END
		
	SELECT pdt.SportType
		, pdt.BetType
		, pdt.IsLive
		, pt.SuperPT	AS S4
		, pt.MasterPT	AS M4
		, pt.AgentPT	AS A4
		, pt.MinPT		AS N4
		, pdt.MaxPT		AS DefaultMaxPT
	FROM dbo.ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN #SportBettypeFilter ft 
			ON pdt.SportType = ft.sporttype
				AND pdt.BetType = ft.bettype
				AND pdt.IsLive = ft.islive
				AND pdt.SettingType = ft.SettingType
	INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
		ON pdt.SportType = pt.sporttype
			AND pdt.BetType = pt.bettype
			AND pdt.IsLive = pt.islive
			AND pt.custid = @CustID
	ORDER BY pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #SportBettypeFilter
END
GO