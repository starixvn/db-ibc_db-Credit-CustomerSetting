/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_SettingDetailSelect] 
	  @ProductID TINYINT
	  , @SettingStatus TINYINT = 0
AS
/*
	Created: 20150304@Dominic
	Task : Get sport/bet types that belong to a specified product
	DB:  DBCUST/CustDB
	Original:

	Revisions: 
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]

	Param's Explanation:
	- @ProductID: ID of a product
	- @SettingStatus: 0: Pro, 1: UAT
	
	*/
BEGIN
	CREATE TABLE #SportBettypeFilter (sporttype SMALLINT, bettype SMALLINT, IsLive BIT, SettingType SMALLINT)

	INSERT INTO #SportBettypeFilter(SportType,Bettype,IsLive, SettingType)
	SELECT SportType,Bettype,IsLive, SettingType 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL,@SettingStatus) -- comm
	
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
