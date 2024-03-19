/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetPT_Agent] (@CustId INT)	       
RETURNS TABLE
AS
/*
	Created by: Viet
	Date: 20181212
	Task: Get PT of agent
	DB: DBCust/CustDB, DBACC/bodb02
	Original: 
	
	Revisions:
		- 20181212@Viet: Initial SP [Redmine: #105338]

	Explanation's Param:
		
*/ 
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, 
		CASE WHEN pt.SuperPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.SuperPT, seq.ByteOrder, 1)) END AS SuperPT,
		CASE WHEN pt.MasterPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MasterPT, seq.ByteOrder, 1)) END AS MasterPT,
		CASE WHEN pt.AgentPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.AgentPT, seq.ByteOrder, 1)) END AS AgentPT,
		CASE WHEN pt.MinPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MinPT, seq.ByteOrder, 1)) END AS MinPT,
		CASE WHEN pt.MaxPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MaxPT, seq.ByteOrder, 1)) END AS MaxPT,

		CASE WHEN pt.SuperPT2 IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.SuperPT2, seq.ByteOrder, 1)) END AS SuperPT2,
		CASE WHEN pt.MasterPT2 IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MasterPT2, seq.ByteOrder, 1)) END AS MasterPT2,
		CASE WHEN pt.AgentPT2 IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.AgentPT2, seq.ByteOrder, 1)) END AS AgentPT2,
		CASE WHEN pt.MinPT2 IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MinPT2, seq.ByteOrder, 1)) END AS MinPT2,
		CASE WHEN pt.MaxPT2 IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MaxPT2, seq.ByteOrder, 1)) END AS MaxPT2
	FROM dbo.CS_CustPTSetting_Agent pt WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
	WHERE CustID = @CustId AND seq.Type = 'PTSetting' 
GO