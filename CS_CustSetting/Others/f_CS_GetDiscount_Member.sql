/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet,vnteam" viewers="" isFunction="1"></info>*/

CREATE FUNCTION [dbo].[f_CS_GetDiscount_Member] (@CustId INT)	       
RETURNS TABLE
AS
	--Created: 20181212@Viet	
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, pc.value AS PlayerDiscount, ac.value AS AgentDiscount, mc.value AS MasterDiscount, sc.value AS SuperDiscount
	FROM dbo.CS_CustDiscount_Member dc WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
		INNER JOIN dbo.CS_CommTemplate pc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.PlayerDiscount, seq.ByteOrder, 1)) = pc.ValueID
		INNER JOIN dbo.CS_CommTemplate ac WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.AgentDiscount, seq.ByteOrder, 1)) = ac.ValueID
		INNER JOIN dbo.CS_CommTemplate mc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.MasterDiscount, seq.ByteOrder, 1)) = mc.ValueID
		INNER JOIN dbo.CS_CommTemplate sc WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.SuperDiscount, seq.ByteOrder, 1)) = sc.ValueID
	WHERE CustID = @CustId AND seq.Type = 'DiscountMember' 
GO