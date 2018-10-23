/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_CheckListDeposit] 
        @UserNameList NVARCHAR(MAX)		= ''
        ,@CustIDList  VARCHAR(MAX)		= ''
AS
/*  
 Created: 20180713@Vicky  
 Task : Check if a customer is a deposit customer or not
 DB:  DBCUST/CustDB   
 Original: Acc_CustSetting_CheckIsDeposit
 
 Revisions: 
        - 20180713@Vicky: NAP - Add new permission control to view Licensee Account [Redmine: #96118]
        
 Param's Explanation:
        - @UserNameList: 'MKW2RMB26, MKW3RMB, ITSA0341'
        
 Example:
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @UserNameList='MKW2RMB26, MKW3RMB, ITSA0341, usernameisnotexist'         
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @CustIDList='267943, 268560, 77629, 77315, 123'
 */  
BEGIN
    
    DECLARE @tblCust TABLE (CustInfo VARCHAR(50), srecommend INT)

    IF @UserNameList != ''
    BEGIN
        INSERT INTO @tblCust (CustInfo)
        SELECT RTRIM(LTRIM(val)) 
        FROM dbo.strSplit(@UserNameList,',') 
        
        UPDATE tc
        SET srecommend = ci.srecommend
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username = tc.CustInfo 
        WHERE ci.roleid  IN (1,2,3,4)
        
        UPDATE tc
        SET srecommend = ci.srecommend
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username2 = tc.CustInfo
        WHERE tc.srecommend IS NULL AND ci.roleid  IN (1,2,3,4)

        
        SELECT tc.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN tc.srecommend  IS NULL THEN 0 ELSE 1 END) AS IsValid
        FROM @tblCust tc
        	LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON tc.srecommend = dep.custid
            
    END
    ELSE 
    BEGIN
        INSERT INTO @tblCust (CustInfo )
        SELECT RTRIM(LTRIM(val)) FROM dbo.strSplit(@CustIDList,',') 
        
        SELECT tmpCust.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN ci.srecommend  IS NULL THEN 0 ELSE 1 END) AS IsValid
        FROM @tblCust tmpCust
            LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = tmpCust.CustInfo AND ci.roleid  IN (1,2,3,4)
            LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
    END 
END
GO


