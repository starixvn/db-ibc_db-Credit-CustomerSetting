/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02" executers="bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/


ALTER PROCEDURE [dbo].[Acc_CheckShowProduct]
	@ProductID	TINYINT,
	@IsHide		BIT OUTPUT 
AS
/*
	Created by: Elodie
	Date: 20170317
	Task: check if show product or not
	DB: DBCust/CustDB, DBAGE/bodb02, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20170331@Winnie: Change to IsHide
		- 20170601@Elodie: Migrate Inspired VS to DCS structure, add BetRadar VS product [Redmine: #77274]
		- 20200303@Tiara: Add SA Gaming Product [Redmine: #128058]
		- 20200403@Elodie: Add Table Games Product [Redmine: #129440]

	Explanation's Param:
		
*/   
BEGIN 
	SET NOCOUNT ON
	
	SELECT @IsHide = 1

	-- For DCS Product
    DECLARE	@SettingType INT
	
	SELECT TOP 1 @SettingType = SettingType 
	FROM dbo.ProductSettingDetail WITH (NOLOCK) 
	WHERE ProductID = @ProductID 
		AND SettingType IN (4,11,13)

	IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType))
	BEGIN
		SELECT @IsHide = 0
	END
END
GO