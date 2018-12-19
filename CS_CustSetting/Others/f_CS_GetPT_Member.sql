/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" selecters="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet,vnteam" viewers="" isFunction="1"></info>*/

CREATE FUNCTION [dbo].[f_CS_GetPT_Member] (@CustId INT)	       
RETURNS TABLE
AS
/*
	Created by: Viet
	Date: 20181212
	Task: Get PT of member
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
		CONVERT(TINYINT, SUBSTRING(pt.AgentPT, seq.ByteOrder, 1)) AS AgentPT
	FROM dbo.CS_CustPTSetting_Member pt WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
	WHERE CustID = @CustId AND seq.Type = 'PTSetting' 
GO