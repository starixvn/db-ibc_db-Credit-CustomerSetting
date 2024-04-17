/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_AgentPT_153_Select  
	  @CustID INT  
	, @GroupID TINYINT = 1
	, @GroupType SMALLINT = 153
	, @DisableAutoMPT BIT = 0 OUTPUT
	, @SettingStatus TINYINT = 0
AS  
/*  
	Created: 20231101@Eden
	Task : Get Agent'PT values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
		
	Param's Explanation:
		- @CustID: Super's ID
		- @SettingStatus: 0: Pro, 1: UAT

	Example:
		DECLARE @DisableAutoMPT BIT = 0
		EXEC Acc_CustSetting_AgentPT_153_Select
			@CustID = 102596319,
			@GroupID = 1,
			@GroupType  = 153,
			@SettingStatus = 3,
			@DisableAutoMPT = @DisableAutoMPT OUT
		SELECT @DisableAutoMPT
 */  
BEGIN   
	DECLARE @SuperID INT,
		@MasterID INT,  
		@SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency,
			@SuperID = c.srecommend,
			@MasterID = c.mrecommend  
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE #ProductSettingDetail(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[MaxPT]	[smallmoney],
		Child_DisplayOrder INT
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,IsLive,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,MaxPT,Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)
	
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
	FROM #ProductSettingDetail pdt WITH (NOLOCK)  
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
	ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #ProductSettingDetail

END  
GO