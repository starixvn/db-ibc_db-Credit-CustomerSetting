/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
CREATE PROCEDURE [dbo].[CS_EditablePTDateSel] 
	@ProductId TINYINT = 1
/*	
	Created: 20181212@Elodie
	Task : Get date which user can edit PT setting (CS Customer Setting)
	DB:  DBCUST/CustDB
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]
*/
AS
BEGIN
	SET NOCOUNT ON
	SELECT * FROM f_CS_GetEditablePTDate(@ProductId)
END
