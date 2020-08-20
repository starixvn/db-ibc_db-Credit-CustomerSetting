/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE Acc_CustSetting_ViewMatrixInfo
   @ProductID TINYINT = NULL,
   @Sporttype SMALLINT = NULL,
   @Mode TINYINT
AS  
/*  
	Created: 20200820@Elodie  
	Task : Get info to view PT matrix and comm matrix
	DB:  DBCUST/CustDB   
	Original:  
  
	Revision: 
		- 20200820@Elodie: Initial SP [Redmine: #135363]

	Param's Explanation:  
		@Mode: 1: PT
		       2: Comm		
   
 */  
BEGIN  
	IF @Mode = 1 
	BEGIN
		SELECT DISTINCT SettingType 
		FROM ProductSettingDetail ps WITH (NOLOCK)
		WHERE ProductId = ISNULL(@ProductID, ProductId)
			AND sporttype = ISNULL(@Sporttype, Sporttype)
			AND SettingType IN (1,18)
	END
	ELSE IF @Mode = 2
	BEGIN
		SELECT DISTINCT SettingType 
		FROM ProductSettingDetail ps WITH (NOLOCK)
		WHERE ProductId = @ProductID
			AND sporttype = ISNULL(@Sporttype, Sporttype)
			AND SettingType IN (3,5,14,19)
	END
END  
GO