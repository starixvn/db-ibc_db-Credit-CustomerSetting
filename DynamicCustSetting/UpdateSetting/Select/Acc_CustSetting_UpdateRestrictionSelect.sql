SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_UpdateRestrictionSelect]   
	@ProductID	TINYINT ,
	@SystemID	TINYINT,
	@TargetID	INT,
	@ActorRoleID TINYINT,
	@TargetRoleID TINYINT
AS  
/*  
 Created: 20160111@Dominic  
 Task : Get Update Restriction Information  
 DB:  DBCUST/custdb  
 Original:  
  
 Param's Explanation:  

   
 */  
BEGIN   
	
	SELECT DISTINCT @ProductID ProductID,fil.SettingType,@SystemID SystemID,@TargetID TargetID,@ActorRoleID ActorRoleID,@TargetRoleID TargetRoleID
	INTO #tmp
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL) fil
	
	
	SELECT t.SettingType,ISNULL(rs.RestrictionMode,1) RestrictionMode,ISNULL(rs.ErrCode,0) ErrCode
	FROM #tmp t WITH(NOLOCK)
	LEFT JOIN dbo.ProductSettingUpdateRestriction rs WITH(NOLOCK)
		ON rs.ProductID = t.ProductID AND rs.SettingType = t.SettingType AND rs.SystemID = t.SystemID 
		AND rs.ActorRoleID = t.ActorRoleID AND rs.TargetRoleID = t.TargetRoleID
	
END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_UpdateRestrictionSelect] TO [bodbExtAccNet]