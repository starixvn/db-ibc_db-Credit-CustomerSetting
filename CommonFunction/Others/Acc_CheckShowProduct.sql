/*<info serverAlias="DBCust-CustDB,DBAGE-bodb02,DBACC-bodb02" executers="bodbAdminNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[Acc_CheckShowProduct]
	@ProductID	TINYINT,
	@Sporttype	SMALLINT = NULL,
	@IsHide		BIT OUTPUT,
	@SettingStatus TINYINT = 0 
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
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]

	Explanation's Param:
		- @SettingStatus: 0: Pro, 1: UAT
		
*/   
BEGIN 
	SET NOCOUNT ON
	
	SELECT @IsHide = 1

	-- For DCS Product
    DECLARE	@SettingType INT, @RealProductID TINYINT
	
	SELECT @SettingType = SettingType, @RealProductID = RealProductId
	FROM dbo.ProductSettingDetail WITH (NOLOCK) 
	WHERE ProductID = @ProductID 
		AND SettingType IN (4,11,13)
		AND SportType = CASE WHEN @Sporttype IS NULL THEN SportType ELSE @Sporttype END

	IF EXISTS( SELECT 1 FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,@SettingType,@SettingStatus) WHERE RealProductId = @RealProductID)
	BEGIN
		SELECT @IsHide = 0
	END
END
GO