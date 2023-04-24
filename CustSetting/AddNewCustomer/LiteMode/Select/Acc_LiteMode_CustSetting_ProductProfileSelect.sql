/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductProfileSelect]   
	@CreationStatus TINYINT = 0
AS  
/*  
	 Created: 20230428@Johnson  
	 Task : Get Product Profile for Lite Mode create downlines
	 DB:  DBCUST/CustDB  
	
	 Revisions: 
		- 20230428@Johnson: initial sp [redmine: #179159]

	 Param's Explanation: 
		- @CreationStatus: 0: Pro, 1: UAT
 */  
BEGIN   
	SET NOCOUNT ON
	
	SELECT SettingType,	SportType, BetType, IsLive,	GroupID, GroupType,	GroupTypeOrder,	SubGroupID,	SubGroupOrder, CreationStatus, DisplayType, Child_DisplayOrder
	FROM dbo.ProductSettingDetail WITH(NOLOCK)
	WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
		AND GroupID IS NOT NULL
	ORDER BY GroupID, GroupTypeOrder, SubGroupOrder, Child_DisplayOrder
END