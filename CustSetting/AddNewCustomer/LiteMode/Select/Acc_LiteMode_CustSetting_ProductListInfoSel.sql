/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_ProductListInfoSel]   
	@CreationStatus TINYINT = 0		
AS  
/*  
	 Created: 20230627@Johnson  
	 Task : Get Product List info for Lite Mode notes
	 DB:  DBCUST/CustDB  
	
	 Revisions: 
		- 20230627@Johnson: initial sp [redmine: #179159]

	 Param's Explanation: 
		@CreationStatus: 0: Pro, 1: UAT, 3: UAT/PRO
 */  
BEGIN   
	SET NOCOUNT ON
	
	IF @CreationStatus IN (1,0)
	BEGIN
		SELECT DISTINCT GroupID,ProductID,0 SportType
		FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 1 --SB,SB2
		UNION ALL	
		SELECT DISTINCT GroupID,ProductID,CASE WHEN productid IN (5) THEN 0 ELSE SportType END --VS
		FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND sporttype NOT IN (164)--happy 5
			AND GroupID = 2--RnG Games
		UNION ALL	
		SELECT DISTINCT GroupID,ProductID,CASE WHEN productid IN (6,18) THEN 0 ELSE SportType END --Saba Casino,RNG Slot
		FROM dbo.ProductSettingDetail WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 3--Live & RnG CS
		ORDER BY GroupID,ProductID,SportType	
	END
	ELSE IF @CreationStatus = 3
	BEGIN	
		SELECT DISTINCT GroupID,ProductID,0 SportType
		FROM dbo.ProductSettingDetail_UAT WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 1 --SB,SB2
		UNION ALL	
		SELECT DISTINCT GroupID,ProductID,CASE WHEN productid IN (5) THEN 0 ELSE SportType END --VS
		FROM dbo.ProductSettingDetail_UAT WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND sporttype NOT IN (164)--happy 5
			AND GroupID = 2--RnG Games
		UNION ALL	
		SELECT DISTINCT GroupID,ProductID,CASE WHEN productid IN (6,18) THEN 0 ELSE SportType END --Saba Casino,RNG Slot
		FROM dbo.ProductSettingDetail_UAT WITH(NOLOCK)
		WHERE CreationStatus <= CASE WHEN @CreationStatus = 1 THEN 1 ELSE 0 END
			AND GroupID = 3--Live & RnG CS
		ORDER BY GroupID,ProductID,SportType			
	END
END