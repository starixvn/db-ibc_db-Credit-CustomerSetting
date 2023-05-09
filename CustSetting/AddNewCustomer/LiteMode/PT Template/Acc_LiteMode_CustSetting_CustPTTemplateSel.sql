/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_CustPTTemplateSel] 
	@CustID INT
AS
/*
	Created: 20230508@Johnson  
	Task : Get PT Template List for customer
	DB:  DBCUST/CustDB  
	
	Revisions: 
		- 20230508@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @TemplateID = 0: get All	
*/	
BEGIN
	SET NOCOUNT ON 
		
	SELECT t.TemplateID, TemplateName, GroupID, SubGroupID, PT, IsDefault	
	FROM CustPTTemplate t WITH(NOLOCK)
		INNER JOIN CustPTTemplateDetail cs WITH(NOLOCK) ON t.TemplateID = cs.TemplateID
	WHERE custid = @custid
	ORDER BY t.TemplateID DESC
END	