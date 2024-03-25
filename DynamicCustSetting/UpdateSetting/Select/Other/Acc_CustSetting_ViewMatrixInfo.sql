/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_ViewMatrixInfo
   @ProductID TINYINT = NULL,
   @Sporttype SMALLINT = NULL,
   @Mode TINYINT, 
   @SettingType SMALLINT OUTPUT, 
   @SettingStatus TINYINT = 0
AS  
/*  
	Created: 20200820@Elodie  
	Task : Get info to view PT matrix and comm matrix
	DB:  DBCUST/CustDB   
	Original:  
  
	Revision: 
		- 20200820@Elodie: Initial SP [Redmine: #135363]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]


	Param's Explanation:  
		@Mode: 1: PT
		       3: Comm		
   
 */  
BEGIN  
	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID)
	SELECT SportType,BetType,SettingType,IsLive,ProductID 
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	IF @Mode = 1 
	BEGIN
		SELECT TOP 1 @SettingType = SettingType 
		FROM #ProductSettingDetail ps WITH (NOLOCK)
		WHERE ProductId = ISNULL(@ProductID, ProductId)
			AND sporttype = ISNULL(@Sporttype, Sporttype)
			AND SettingType IN (1,18,28)
	END
	ELSE IF @Mode = 3
	BEGIN
		SELECT TOP 1 @SettingType = SettingType 
		FROM #ProductSettingDetail ps WITH (NOLOCK)
		WHERE ProductId = ISNULL(@ProductID, ProductId)
			AND sporttype = ISNULL(@Sporttype, Sporttype)
			AND SettingType IN (3,5,14,19,25)
	END

	DROP TABLE #ProductSettingDetail
END  
GO