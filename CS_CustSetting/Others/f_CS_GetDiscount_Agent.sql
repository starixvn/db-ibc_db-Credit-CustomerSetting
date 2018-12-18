/*<info serverAlias="DBCUST-CUSTDB,DBACC-bodb02" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet,vnteam" viewers="" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[f_CS_GetDiscount_Agent] (@CustId INT)	       
RETURNS TABLE
AS
	--Created: 20181212@Viet	
RETURN
	SELECT seq.sporttype, seq.bettype, seq.isLive, seq.groupID, t.value AS Discount
	FROM dbo.CS_CustDiscount_Agent dc WITH(NOLOCK)	
		CROSS APPLY dbo.CS_ByteSeq seq WITH(NOLOCK)
		INNER JOIN dbo.CS_CommTemplate t WITH(NOLOCK) ON CONVERT(TINYINT, SUBSTRING(dc.discount, seq.ByteOrder, 1)) = t.ValueID
	WHERE CustID = @CustId AND seq.Type = 'DiscountAgent' 
GO