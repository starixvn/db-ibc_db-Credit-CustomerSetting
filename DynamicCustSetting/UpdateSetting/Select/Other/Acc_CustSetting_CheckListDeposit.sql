/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CheckListDeposit] 
        @UserNameList NVARCHAR(MAX)=''
        ,@CustIDList  VARCHAR(MAX)=''
AS
/*  
 Created: 20180713@Vicky  
 Task : Check if customer is a deposit customer or not
 DB:  DBCUST/CustDB   
 Original:  
        - 20180713@Vicky: NAP - Add new permission control to view Licensee Account [Redmine: #96118]
        
 Param's Explanation:
        - @UserNameList: 'MKW2RMB26, MKW3RMB, ITSA0341'
        
 Example:
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @UserNameList='MKW2RMB26, MKW3RMB, ITSA0341'
 */  
BEGIN
    
    DECLARE @tblCust TABLE (CustInfo NVARCHAR(50))

    IF @UserNameList != ''
    BEGIN
        INSERT INTO @tblCust (CustInfo )
        SELECT RTRIM(LTRIM(val)) FROM dbo.strSplit(@UserNameList,',') 
        
        SELECT tmpCust.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN ci.CustId  IS NULL THEN 0 ELSE 1 END) AS IsValid
        FROM @tblCust tmpCust
            LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.username = tmpCust.CustInfo
            LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
    END
    ELSE 
    BEGIN
        INSERT INTO @tblCust (CustInfo )
        SELECT RTRIM(LTRIM(val)) FROM dbo.strSplit(@CustIDList,',') 
        
        SELECT tmpCust.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN ci.CustId  IS NULL THEN 0 ELSE 1 END) AS IsValid
        FROM @tblCust tmpCust
            LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = tmpCust.CustInfo
            LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
    END 
END
GO


