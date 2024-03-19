ALTER PROCEDURE [dbo].[Acc_CustSetting_CustomerRoleSelect]  
	@CustID INT = 0  
AS  
/*  
	Created: 20140327@Dominic  
	Task: Get RoleID
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  
	
	--Check if roleid of taget cusomer is not consistent
	SELECT ISNULL(RoleID,0)  RoleID
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @CustID   
	 
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbAdminNet,wsv_nap]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbDownlineNet,wsv_alp]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CustomerRoleSelect] TO [bodbExtAccNet,wsv_xnap]