/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE Acc_CustSetting_SuperPTSelect
	  @CustID		INT
	, @ProductID	TINYINT
AS
/*
	Created: 20200612@Elodie
	Task : Get Super'PT values of a product
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20200612@Elodie: Initial SP for setting type 18 [Redmine: #135363]
		
	Param's Explanation:
		- @CustID: Super's ID
	
*/
BEGIN
	
	SELECT SportType, Bettype, IsLive, SettingType 
	INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,18)
	
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