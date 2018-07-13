CREATE PROCEDURE Acc_CustSetting_CheckIsDeposit @UserName NVARCHAR(50)=''
AS
/*  
 Created: 201511111@Dominic  
 Task : Check if a customer is a deposit customer or not
 DB:  DBCUST/CustDB   
 Original:  
  
 Param's Explanation:  
 
   
 */  
BEGIN
	DECLARE @IsDeposit BIT = 0
	IF EXISTS (SELECT TOP 1 1
	FROM dbo.custInfo ci WITH(NOLOCK)
	INNER JOIN dbo.Dep_CustSuper dep WITH(NOLOCK) ON ci.srecommend = dep.custid
	WHERE ci.username = @UserName)
	SELECT @IsDeposit = 1
	
	SELECT @IsDeposit IsDeposit
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_CheckIsDeposit] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_CheckIsDeposit] TO [vnteam] AS [dbo]


