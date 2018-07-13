/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CheckListDeposit] 
        @UserName NVARCHAR(50)=''
AS
/*  
 Created: 20180713@Vicky  
 Task : Check if customer is a deposit customer or not
 DB:  DBCUST/CustDB   
 Original:  
        - 20180713@Vicky: NAP - Add new permission control to view Licensee Account [Redmine: #96118]
        
 Param's Explanation:
        - @UserName: 'MKW2RMB26, MKW3RMB, ITSA0341'
        
 Example:
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @UserName='MKW2RMB26, MKW3RMB, ITSA0341'
 */  
BEGIN
    
   DECLARE @tblCust TABLE (UserName NVARCHAR(50))

   INSERT INTO @tblCust (UserName )
   SELECT RTRIM(LTRIM(val)) FROM dbo.strSplit(@UserName,',') 
    
   SELECT tmpCust.Username, 
        (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
        (CASE WHEN ci.CustId  IS NULL THEN 0 ELSE 1 END) AS IsValid
   FROM @tblCust tmpCust
        LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.username = tmpCust.username
        LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
END
GO


