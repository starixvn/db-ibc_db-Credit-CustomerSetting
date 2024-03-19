/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_SiteGroupSel] 
	@IsDeposit TINYINT = 2	
AS
/*
	Created by: 20230802@Johnson	
	Task: Select sitegroup 
	DB: DBCUST.CustDB
	
	Revisions:
		- 20230802@Johnson: initial sp [redmine: #179159]
		
	Parameter's explaination:
		- IsDeposit = 0: credit, 1: deposit, 2: all
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT s.site,s.siteid,s.SiteDBGroupID,s.isDeposit,c.LinkedServerName
	FROM site s WITH (NOLOCK)
		INNER JOIN SiteDBConfig c WITH(NOLOCK) ON s.SiteDBGroupID = c.SiteDBGroupID
	WHERE 1= CASE WHEN @IsDeposit = 2 OR isDeposit = @isDeposit THEN 1 ELSE 0 END
		AND isActive = 1
END	