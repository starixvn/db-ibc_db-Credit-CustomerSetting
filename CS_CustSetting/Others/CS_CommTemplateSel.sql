/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[CS_CommTemplateSel] 
/*	
	Created: 20181212@Elodie
	Task : CommTemplate Select
	DB:  DBCUST/CustDB
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]
*/
AS
BEGIN
	SET NOCOUNT ON
	SELECT ValueId, Value FROM CS_CommTemplate WITH (NOLOCK)
END