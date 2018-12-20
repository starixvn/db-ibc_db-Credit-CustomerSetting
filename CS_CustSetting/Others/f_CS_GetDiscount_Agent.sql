/*<info serverAlias="DBCUST-CUSTDB" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetDiscount_Agent] (@CustId INT)	       
RETURNS TABLE
AS
/*
	Created by: Viet
	Date: 20181212
	Task: Get comm of agent
	DB: DBCust/CustDB, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20181212@Viet: Initial SP [Redmine: #105338]

	Explanation's Param:
		
*/   
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, seq.groupID, t.value AS Discount, t.ValueId
	FROM dbo.CS_CustDiscount_Agent dc WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
		INNER JOIN dbo.CS_CommTemplate t WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.discount, seq.ByteOrder, 1)) = t.ValueID
	WHERE CustID = @CustId AND seq.Type = 'DiscountAgent' 
GO