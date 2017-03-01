SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_AllowMasterPTSelect]   
	@UserName	NVARCHAR(50)  
AS  
/*  
 Created: 20141104@Dominic  
 Task : Get automasterPT  
 DB:  DBCUST/CustDB  
 Original:  
  
 Param's Explanation:  
 • @CustID: Master Username
   
 */  
BEGIN   	

	--Disable auto master PT  
	SELECT ISNULL(cm.DisableAutoMPT, 0)  
	FROM Custinfo ci WITH(NOLOCK)
	INNER JOIN CustMaster cm WITH (NOLOCK) ON ci.custid = cm.custid
	WHERE ci.username = @UserName 
	

END  
  

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AllowMasterPTSelect ] TO [bodbExtAccNet]