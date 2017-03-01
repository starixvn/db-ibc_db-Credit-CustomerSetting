ALTER PROCEDURE Age_CustomerSelCheckPermission  
 @UserId INT,  
 @FuncId INT  
AS  
/*
Created: 20100223@lewin
Task : 
DB: bodb05
Original:

Revisions:
    - 20090122@[Reviewer]: [Description of revision]    

Param's Explanation:
• @UserId: user id
*/

BEGIN  
 
 SET NOCOUNT ON;  
 
 SELECT TOP 1 Policy  
 FROM dbo.Acc_MemberPolicy_1 with(nolock)  
 WHERE FuncID = @FuncId and CustID = @UserId  
 
END  