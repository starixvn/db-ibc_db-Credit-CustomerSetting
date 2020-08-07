/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_CheckPGSoftEnable]
	-- Add the parameters for the stored procedure here
	@site   varchar(10)
AS
BEGIN
	/*
		Task : Check PG Soft on site
		DB: DBCUST/CustDB
		Original: 
		Revisions:
			- 20200806@Winfred: Check PG Soft on site [Redmine: #137763]
	*/
	SET NOCOUNT ON;
	DECLARE @PGEnable BIT  = 0 
	SELECT	@PGEnable = 1 WHERE	@site IN ('755555','IBCIndo','Indo','KORIBC','789y')
	
	SELECT ProductID, SportType, BetType
	FROM ProductSettingDetail WITH(NOLOCK)
	WHERE ProductID = 22 AND SettingType = 8
	AND ((@PGEnable = 0 AND BetType <> 6001) OR @PGEnable = 1 )
END
GO
