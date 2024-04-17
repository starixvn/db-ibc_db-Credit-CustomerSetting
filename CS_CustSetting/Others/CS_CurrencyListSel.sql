/*<info serverAlias="DBACC-bodb02" executers="wsv_nap,wsv_alp,wsv_alpv" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE CS_CurrencyListSel
/*	
	Created: 20181212@Elodie
	Task : Currency list select
	DB:  DBACC/bodb02
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]
*/
AS
BEGIN
	SET NOCOUNT ON
	SELECT exchangeid, currency, Code FROM dbo.exchange WITH (NOLOCK) WHERE exchangeid <> 51
END