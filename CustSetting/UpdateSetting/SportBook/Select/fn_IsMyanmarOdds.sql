/*<info serverAlias="DBCUST-CUSTDB,DBAGE-bodb02,DBACC-bodb02" executers="bodbAdminNet,wsv_nap,bodbExtAccNet,wsv_xnap,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="1" isNested="1"></info>*/
ALTER FUNCTION fn_IsMyanmarOdds (@CustID INT = 0)
RETURNs BIT
AS
/*
	Created By: Helen
	Created Date: 20150928
	Description: commission setting for MO [Redmine #41470]
	DB: DBCust.CustDB, DBTXN.CustDB
	
	Revisions:
		- 20200918@Winfred: Reinsert MyanmarOdds [Redmine: #141926]
*/
BEGIN
	
	IF EXISTS (SELECT 1 FROM Customer WITH (NOLOCK) WHERE CustID = @CustID AND [Site] = '76666B')
		RETURN 1
	RETURN 0	
END



