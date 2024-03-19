/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,wsv_nap" viewers="vnteam" isFunction="0" isNested="0"></info>*/
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
        - 20200930@Johnson: get isInternal status [redmine:#161998]
		- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 
 Param's Explanation:
        - @UserNameList: 'MKW2RMB26, MKW3RMB, ITSA0341'
        
 Example:
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @UserNameList='MKW2RMB26, MKW3RMB, ITSA0341, usernameisnotexist'         
        EXEC [dbo].[Acc_CustSetting_CheckListDeposit] @CustIDList='267943, 268560, 77629, 77315, 123'
 */  
BEGIN
    
    DECLARE @tblCust TABLE (CustInfo VARCHAR(50), srecommend INT, recommend INT, roleid TINYINT, custid INT, isInternal BIT)

    IF @UserNameList != ''
    BEGIN
        INSERT INTO @tblCust (CustInfo)
        SELECT RTRIM(LTRIM(value)) 
        FROM STRING_SPLIT(@UserNameList,',') 
		WHERE value <> ''
        
        UPDATE tc
        SET srecommend = ci.srecommend,
			recommend = ci.recommend,
			roleid = ci.roleid,
			custid = ci.custid
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username = tc.CustInfo 
        WHERE ci.roleid  IN (1,2,3,4)
        
        UPDATE tc
        SET srecommend = ci.srecommend,
			recommend = ci.recommend,
			roleid = ci.roleid,
			custid = ci.custid
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username2 = tc.CustInfo
        WHERE tc.srecommend IS NULL AND ci.roleid  IN (1,2,3,4)
        
		UPDATE t
		SET isInternal = cs.isInternal
		FROM @tblCust t
			INNER JOIN CustSuper cs WITH(NOLOCK) ON t.custid = cs.custid
		WHERE t.roleid = 4
		
		UPDATE t
		SET isInternal = cs.isInternal
		FROM @tblCust t
			INNER JOIN CustMaster cs WITH(NOLOCK) ON t.custid = cs.custid
		WHERE t.roleid = 3
		
		UPDATE t
		SET isInternal = cs.isInternal
		FROM @tblCust t
			INNER JOIN CustAgent cs WITH(NOLOCK) ON t.custid = cs.custid
		WHERE t.roleid = 2
		
		UPDATE t
		SET isInternal = cs.isInternal
		FROM @tblCust t
			INNER JOIN CustAgent cs WITH(NOLOCK) ON t.recommend = cs.custid
		WHERE t.roleid = 1
		
        SELECT tc.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN tc.srecommend  IS NULL THEN 0 ELSE 1 END) AS IsValid,
			ISNULL(tc.IsInternal,0) IsInternal
        FROM @tblCust tc
        	LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON tc.srecommend = dep.custid
            
    END
    ELSE 
    BEGIN
        INSERT INTO @tblCust (CustInfo )
        SELECT RTRIM(LTRIM(value)) FROM STRING_SPLIT(@CustIDList,',') WHERE value <> ''
        
        SELECT tmpCust.CustInfo, 
            (CASE WHEN dep.CustId IS NULL THEN 0 ELSE 1 END) AS IsDeposit,
            (CASE WHEN ci.srecommend  IS NULL THEN 0 ELSE 1 END) AS IsValid,
			ISNULL(CASE WHEN ci.roleid = 4 THEN s.IsInternal
				 WHEN ci.roleid = 3 THEN m.IsInternal
				 WHEN ci.roleid IN (2,1) THEN a.IsInternal ELSE 0 END,0) IsInternal  
        FROM @tblCust tmpCust
            LEFT JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = tmpCust.CustInfo AND ci.roleid  IN (1,2,3,4)
            LEFT JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
			LEFT JOIN dbo.CustSuper s WITH(NOLOCK) ON ci.custid = s.custid
			LEFT JOIN dbo.CustMaster m WITH(NOLOCK) ON ci.custid = m.custid
			LEFT JOIN dbo.CustAgent a WITH(NOLOCK) ON ci.custid = a.custid OR ci.recommend = a.custid
    END 
END
GO


