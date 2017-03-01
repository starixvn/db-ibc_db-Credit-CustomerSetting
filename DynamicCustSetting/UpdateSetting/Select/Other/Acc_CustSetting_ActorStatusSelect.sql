ALTER PROCEDURE [dbo].[Acc_CustSetting_ActorStatusSelect]  
	@CustID INT = 0 
AS  
/*  
	Created: 20140327@Dominic  
	Task: return distable status
	DB: DBCUST.CustDB  
	Original:   
	  
	Revisions:  
*/  
BEGIN  
	SET NOCOUNT ON  

	SELECT ISNULL([enabled],0) [Enabled]
	FROM dbo.custinfo WITH (NOLOCK)  
	WHERE custid = @custid   

	
END   
  
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ActorStatusSelect] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ActorStatusSelect] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_ActorStatusSelect] TO [bodbExtAccNet]