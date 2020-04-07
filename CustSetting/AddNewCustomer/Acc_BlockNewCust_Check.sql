/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/
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
*/
BEGIN
	DECLARE @BlockNewCust BIT = 0  ,@UnblockTime VARCHAR(50) = ''

	SELECT @BlockNewCust = BlockNewCust, @UnblockTime = UnblockTime FROM dbo.[Site_BlockNewCust] WITH (NOLOCK) WHERE site = @Site

	IF @BlockNewCust = 1
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'VI' THEN N'Chúng tôi đang xử lý việc ra mắt sản phẩm mới, vui lòng tạo tài khoản cấp dưới sau ' + @UnblockTime + N'. Vui lòng liên hệ với cấp trên hoặc bộ phận Chăm Sóc Khách Hàng để biết thêm thông tin.'
							ELSE 'We are in processing for new product offering, please try to create downline account after ' + @UnblockTime + '. Please contact your upline or CSD for further information.'
						END	
				,@ErrCode = 101	
		RETURN
	END
END
GO