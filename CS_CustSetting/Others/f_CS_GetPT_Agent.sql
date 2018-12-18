/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet,vnteam" viewers="" isFunction="1"></info>*/

CREATE FUNCTION [dbo].[f_CS_GetPT_Agent] (@CustId INT)	       
RETURNS TABLE
AS
	--Created: 20181212@Viet	
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, 
		CASE WHEN pt.SuperPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.SuperPT, seq.ByteOrder, 1)) END AS SuperPT,
		CASE WHEN pt.MasterPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MasterPT, seq.ByteOrder, 1)) END AS MasterPT,
		CASE WHEN pt.AgentPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.AgentPT, seq.ByteOrder, 1)) END AS AgentPT,
		CASE WHEN pt.MinPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MinPT, seq.ByteOrder, 1)) END AS MinPT,
		CASE WHEN pt.MaxPT IS NULL THEN NULL ELSE CONVERT(TINYINT, SUBSTRING(pt.MaxPT, seq.ByteOrder, 1)) END AS MaxPT
	FROM dbo.CS_CustPTSetting_Agent pt WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
	WHERE CustID = @CustId AND seq.Type = 'PTSetting' 
GO