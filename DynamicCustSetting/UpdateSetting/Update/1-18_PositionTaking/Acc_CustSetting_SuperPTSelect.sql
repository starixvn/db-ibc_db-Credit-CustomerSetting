/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_SuperPTSelect
	  @CustID		INT
	, @ProductID	TINYINT
	, @SettingStatus TINYINT = 0
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
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20221123@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		
	Param's Explanation:
		- @CustID: Super's ID
		- @SettingStatus: 0: Pro, 1: UAT
	
*/
BEGIN
	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT, Child_DisplayOrder INT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType, Child_DisplayOrder)
	SELECT SportType, Bettype, IsLive, SettingType, Child_DisplayOrder 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18,@SettingStatus)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,MaxPT 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
	
	SELECT pdt.SportType
		, pdt.BetType
		, pdt.IsLive
		, pt.SuperPT	AS S4
		, pt.MasterPT	AS M4
		, pt.AgentPT	AS A4
		, pt.MinPT		AS N4
		, pdt.MaxPT		AS DefaultMaxPT
	FROM #ProductSettingDetail pdt WITH (NOLOCK)
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
	ORDER BY ft.Child_DisplayOrder,pdt.SportType, pdt.BetType, pdt.IsLive  

	DROP TABLE #SportBettypeFilter
	DROP TABLE #ProductSettingDetail
END
GO