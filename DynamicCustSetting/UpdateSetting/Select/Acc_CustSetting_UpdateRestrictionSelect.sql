/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_UpdateRestrictionSelect]   
	@ProductID	TINYINT ,
	@SystemID	TINYINT,
	@TargetID	INT,
	@ActorRoleID TINYINT,
	@TargetRoleID TINYINT,
	@SettingStatus TINYINT = 0
AS  
/*  
 Created: 20160111@Dominic  
 Task : Get Update Restriction Information  
 DB:  DBCUST/custdb  
 Original:  

 Revisions: 
	- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
	- 20220615@Tacy: Hot modify Select Into statement to avoid dump [Redmine: #174035]
  
 Param's Explanation:  
	- @SettingStatus: 0: Pro, 1: UAT

   
 */  
BEGIN   
	CREATE TABLE #tmp (
			ProductID	TINYINT ,
			SettingType SMALLINT,
			SystemID	TINYINT,
			TargetID	INT,
			ActorRoleID TINYINT,
			TargetRoleID TINYINT)

	INSERT INTO #tmp(ProductID, SettingType, SystemID, TargetID, ActorRoleID, TargetRoleID)
	SELECT DISTINCT @ProductID ProductID,fil.SettingType,@SystemID SystemID,@TargetID TargetID,@ActorRoleID ActorRoleID,@TargetRoleID TargetRoleID
	FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,NULL,@SettingStatus) fil
	
	
	SELECT t.SettingType,ISNULL(rs.RestrictionMode,1) RestrictionMode,ISNULL(rs.ErrCode,0) ErrCode
	FROM #tmp t WITH(NOLOCK)
	LEFT JOIN dbo.ProductSettingUpdateRestriction rs WITH(NOLOCK)
		ON rs.ProductID = t.ProductID AND rs.SettingType = t.SettingType AND rs.SystemID = t.SystemID 
		AND rs.ActorRoleID = t.ActorRoleID AND rs.TargetRoleID = t.TargetRoleID
	
	DROP TABLE #tmp
END  
  