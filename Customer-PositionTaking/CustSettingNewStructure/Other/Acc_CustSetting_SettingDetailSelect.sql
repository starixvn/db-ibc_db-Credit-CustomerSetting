SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_SettingDetailSelect] 
	  @ProductID TINYINT
AS
/*
	Created: 20150304@Dominic
	Task : Get sport/bet types that belong to a specified product
	DB:  DBCUST/CustDB
	Original:

	Param's Explanation:
	- @ProductID: ID of a product
	
	*/
BEGIN
	SELECT * INTO #SportBettypeFilter
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL) -- comm
	
	SELECT pdt.[SettingType]
	  ,pdt.[SportType]
	  ,pdt.[BetType]
	  ,pdt.[IsLive]
	FROM [dbo].[ProductSettingDetail] pdt
	INNER JOIN #SportBettypeFilter ft 
			ON ft.SportType = pdt.sporttype
				AND ft.BetType = pdt.bettype
				AND ft.[IsLive] = pdt.[IsLive]
				AND ft.[SettingType] = pdt.[SettingType]

	DROP TABLE #SportBettypeFilter
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SettingDetailSelect] TO [bodbExtAccNet]