/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetPTGroup_Member] (@AgentId INT)	       
RETURNS TABLE
AS
/*
	Created by: Viet
	Date: 20181212
	Task: Get PT group of member
	DB: DBCust/CustDB, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20181212@Viet: Initial SP [Redmine: #105338]

	Explanation's Param:
		
*/ 
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, 
		CONVERT(TINYINT, SUBSTRING(pt.SuperPT, seq.ByteOrder, 1)) AS SuperPT,
		CONVERT(TINYINT, SUBSTRING(pt.MasterPT, seq.ByteOrder, 1)) AS MasterPT,
		CONVERT(TINYINT, SUBSTRING(pt.AgentPT, seq.ByteOrder, 1)) AS AgentPT,

		CONVERT(TINYINT, SUBSTRING(pt.SuperPT2, seq.ByteOrder, 1)) AS SuperPT2,
		CONVERT(TINYINT, SUBSTRING(pt.MasterPT2, seq.ByteOrder, 1)) AS MasterPT2,
		CONVERT(TINYINT, SUBSTRING(pt.AgentPT2, seq.ByteOrder, 1)) AS AgentPT2
	FROM dbo.CS_CustPTGroupSetting_Member pt WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
	WHERE AgentId = @AgentId AND seq.Type = 'PTSetting' 
GO