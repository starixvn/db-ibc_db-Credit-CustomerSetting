/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE CS_SpreadGroupSel
/*	
	Created: 20181212@Elodie
	Task : SpreadGroup list select
	DB:  DBACC/bodb02
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]
*/
AS
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT GroupName, uGroup FROM dbo.CS_GroupConfig WITH (NOLOCK)
END