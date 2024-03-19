/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustSetting_AgentCommSBSel] 
	@CustID INT
AS
/*
	Created by: 2023710@Johnson	
	Task: Select agent setting for create member on Lite mode
	DB: DBCUST.CustDB
	
	Revisions:
		- 2023710@Johnson: initial sp [redmine: #179159]
		
	Parameter's explaination:
	
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT sporttype, bettype,
			CASE WHEN bettype = 1 THEN groupA
				WHEN bettype = 3 THEN groupB
				WHEN bettype = 7 THEN groupC
				WHEN bettype = 8 THEN groupD END as discount		 
		FROM custsetting WITH(NOLOCK)
		WHERE custid = @custid
			AND sporttype = 1
			AND bettype IN (1,3,7,8)
END			