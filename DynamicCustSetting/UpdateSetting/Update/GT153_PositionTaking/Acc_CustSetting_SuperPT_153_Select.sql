/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_SuperPT_153_Select
	  @CustID		INT
	, @GroupID TINYINT = 1
	, @GroupType SMALLINT = 153
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20231101@Eden
	Task : Get Super'PT values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]
		
	Param's Explanation:
		- @CustID: Super's ID
		- @SettingStatus: 0: Pro, 1: UAT
	
	Example:
		EXEC Acc_CustSetting_SuperPT_153_Select
			@CustID = 102596317,
			@GroupID = 1,
			@GroupType  = 153,
			@SettingStatus = 3
		
*/
BEGIN
	DECLARE @SiteID SMALLINT,
		@Currency SMALLINT	
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	CREATE TABLE #ProductSettingDetail(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[MaxPT]	[smallmoney],
		Child_DisplayOrder INT,
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,IsLive,MaxPT,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,MaxPT,Child_DisplayOrder 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	SELECT pdt.SportType
		, pdt.BetType
		, pdt.IsLive
		, pt.SuperPT	AS S4
		, pt.MasterPT	AS M4
		, pt.AgentPT	AS A4
		, pt.MinPT		AS N4
		, pdt.MaxPT		AS DefaultMaxPT
	FROM #ProductSettingDetail pdt WITH (NOLOCK)
	INNER JOIN dbo.CustPTSetting3rd_Agent pt WITH (NOLOCK)
		ON pdt.SportType = pt.sporttype
			AND pdt.BetType = pt.bettype
			AND pdt.IsLive = pt.islive
			AND pt.custid = @CustID
	ORDER BY pdt.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #ProductSettingDetail
END
GO