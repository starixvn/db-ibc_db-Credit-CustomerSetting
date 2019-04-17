/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetGroupDiscount_Member] (@AgentId INT)	       
RETURNS TABLE
AS
/*
	Created by: Viet
	Date: 20181212
	Task: Get comm of member
	DB: DBCust/CustDB, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20181212@Viet: Initial SP [Redmine: #105338]

	Explanation's Param:
		
*/ 	
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, dc.uGroup, pc.value AS PlayerDiscount, ac.value AS AgentDiscount, mc.value AS MasterDiscount, sc.value AS SuperDiscount
	FROM dbo.CS_CustGroupDiscount_Member dc WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
		INNER JOIN dbo.CS_CommTemplate pc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.PlayerDiscount, seq.ByteOrder, 1)) = pc.ValueID
		INNER JOIN dbo.CS_CommTemplate ac WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.AgentDiscount, seq.ByteOrder, 1)) = ac.ValueID
		INNER JOIN dbo.CS_CommTemplate mc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.MasterDiscount, seq.ByteOrder, 1)) = mc.ValueID
		INNER JOIN dbo.CS_CommTemplate sc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.SuperDiscount, seq.ByteOrder, 1)) = sc.ValueID
	WHERE dc.AgentId = @AgentId AND seq.Type = 'DiscountMember' 
GO