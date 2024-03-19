/*<info serverAlias="DBCUST-CUSTDB,DBAGE-bodb02,DBACC-bodb02" executers="bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="1" isNested="1"></info>*/
CREATE FUNCTION fn_IsMyanmarOddsBySite (@Site VARCHAR(50) = '' )
RETURNs BIT
AS
/*
	Created By: Winfred
	Created Date: 20200918
	Description: Check Site for MO [Redmine #141926]
	DB: DBCust.CustDB, DBTXN.CustDB
	
	Revisions:
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
*/
BEGIN
	RETURN CASE WHEN @Site in ('76666B') THEN 1 ELSE 0 END	
END



