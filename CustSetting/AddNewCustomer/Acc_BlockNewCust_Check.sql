/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_BlockNewCust_Check]
	@Site NVARCHAR(50) = '',
	@Language VARCHAR(2),
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20200407@Eden
Task :  check Block new cust
DB: DBCUST/CustDB
Original:  
Revisions:
    - 20200407@Eden: Block to add new customer by site [Redmine: #131758]
	- 20200407@Eden: Block to add new customer by site --> Switch to Site table [Redmine: #131758]
*/
BEGIN
	DECLARE @BlockNewCust BIT = 0  ,@UnblockTime VARCHAR(50) = ''

	SELECT @BlockNewCust = BlockNewCust, @UnblockTime = UnblockTime FROM dbo.[Site] WITH (NOLOCK) WHERE site = @Site

	IF @BlockNewCust = 1
	BEGIN

		SELECT	@ErrMsg = REPLACE([dbo].[f_Get_MsgNamebyMsgID](90013,@Language),'<UnblockTime>',@UnblockTime),
				@ErrCode = 90013	
		
		RETURN
	END
END
GO