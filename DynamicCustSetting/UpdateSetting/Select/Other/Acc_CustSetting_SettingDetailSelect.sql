/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
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
	- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]

	Param's Explanation:
	- @ProductID: ID of a product
	- @SettingStatus: 0: Pro, 1: UAT
	
	*/
BEGIN
	SELECT SettingType,SportType,Bettype,IsLive 
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL,@SettingStatus)
END
