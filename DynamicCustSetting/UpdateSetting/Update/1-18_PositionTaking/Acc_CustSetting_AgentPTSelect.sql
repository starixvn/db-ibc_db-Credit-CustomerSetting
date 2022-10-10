/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Acc_CustSetting_AgentPTSelect  
	@CustID			INT  
	, @ProductID	TINYINT = NULL 
	, @DisableAutoMPT BIT = 0 OUTPUT
	, @SettingStatus TINYINT = 0
	, @SystemID	TINYINT = 1
AS  
/*  
	Created: 20200612@Elodie
	Task : Get Agent'PT values of a product  
	DB:  DBCUST/CustDB  
	Original:  
  
	Revision:
		- 20200612@Elodie: Initial SP for setting type 18 [Redmine: #135363]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
		- 20221006@Winfred: Don't show setting of products which are not offered to a credit site [Redmine: #174744]
	 
	Param's Explanation:  
		- @CustID: Agent's ID 
		- @SettingStatus: 0: Pro, 1: UAT 
		- @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
   
 */  
BEGIN   
	DECLARE @SuperID INT, @MasterID INT , @Siteid INT, @currency	TINYINT 
   
   SELECT @SuperID=ci.srecommend, @MasterID=ci.mrecommend , @Siteid=s.siteid, @currency = ci.currency   
	FROM dbo.Customer ci WITH(NOLOCK)  
	INNER JOIN Site s  WITH(NOLOCK) ON ci.site = s.site
	WHERE ci.custid=@CustID    

	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT)

	IF @SystemID IN (2, 4)
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
		SELECT a.SportType, a.Bettype, a.IsLive, a.SettingType 
		FROM dbo.f_CustSetting_ProductOfferedSelect(@ProductID,@Siteid,@currency,18,@SettingStatus) b
	END
	ELSE
	BEGIN
		INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
		SELECT SportType,Bettype,IsLive, SettingType 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus)
	END	
	
	--Disable auto master PT  
	SELECT @DisableAutoMPT = ISNULL(DisableAutoMPT, 0)
	FROM CustMaster WITH (NOLOCK)  
	WHERE CustID = @MasterID 
	
	SELECT pdt.SportType  
		, pdt.BetType  
		, pdt.IsLive  
		, pt.masterPT AS M2  
		, pt.agentPT AS A2  
		, pt.IsAutoMasterPT AS IM2  
		, pt.AutoMasterPT AS UM2  
		, pt.minPT AS N2  
		, CASE   
			WHEN masterpt.masterPT < masterpt.maxPT  
			THEN masterpt.masterPT  
			ELSE masterpt.maxPT  
		END AS M3  
		, masterpt.minPT AS N3  
		, superpt.agentPT AS A4
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
	INNER JOIN dbo.CustPTSetting3rd_Agent masterpt WITH (NOLOCK)  
		ON pdt.SportType = masterpt.sporttype  
		AND pdt.BetType = masterpt.bettype  
		AND pdt.IsLive = masterpt.islive  
		AND masterpt.custid = @MasterID  
	INNER JOIN dbo.CustPTSetting3rd_Agent superpt WITH (NOLOCK)  
		ON pdt.SportType = superpt.sporttype  
		AND pdt.BetType = superpt.bettype  
		AND pdt.IsLive = superpt.islive  
		AND superpt.custid = @SuperID  
	ORDER BY pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #SportBettypeFilter
END  
GO