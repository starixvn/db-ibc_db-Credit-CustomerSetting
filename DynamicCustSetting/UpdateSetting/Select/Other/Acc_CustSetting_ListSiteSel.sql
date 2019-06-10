/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_ListSiteSel]
    @UserNameList NVARCHAR(MAX) = '',
    @CustIDList VARCHAR(MAX) = ''
AS
/*  
    Created: 20190529@Kan
    Task: Get Site Name of cust Id or cust name list
    DB:  DBCUST/CustDB
    
    Revisions:
        - 20190529@Kan: NAP - Add new permission control to view CN88 Accounts [Redmine: #114215]
        - 20190610@Winnie: Revise SP for selecting site NAP - Add new permission control to view CN88 Accounts [Redmine: #114215]
    Param's Explanation:
        - @UserNameList: 'MKW2RMB26, MKW3RMB, ITSA0341'
    
    Example:
        EXEC [dbo].[Acc_CustSetting_ListSiteSel] @UserNameList='MKW2RMB26, MKW3RMB, ITSA0341, usernameisnotexist'         
        EXEC [dbo].[Acc_CustSetting_ListSiteSel] @CustIDList='267943, 268560, 77629, 77315, 123'
 */  
BEGIN
    DECLARE @tblCust TABLE (CustInfo VARCHAR(50), srecommend INT, Site VARCHAR(10))

    IF @UserNameList <> ''
    BEGIN
        INSERT INTO @tblCust (CustInfo)
        SELECT RTRIM(LTRIM(val)) 
        FROM dbo.strSplit(@UserNameList, ',') 
        
        UPDATE tc
        SET srecommend = ci.srecommend, Site = ci.Site
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username = tc.CustInfo 
        WHERE ci.roleid IN (0,1,2,3,4)
        
        UPDATE tc
        SET srecommend = ci.srecommend, Site = ci.Site
        FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.username2 = tc.CustInfo
        WHERE tc.srecommend IS NULL AND ci.roleid IN (0,1,2,3,4)

		UPDATE tc
        SET Site = ci.Site        
		FROM @tblCust tc
        	INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.CustID = tc.srecommend
		WHERE tc.srecommend IS NOT NULL AND tc.Site =''
        
        SELECT tc.CustInfo, tc.Site,
            (CASE WHEN tc.srecommend IS NULL THEN 0 ELSE 1 END) AS IsValid
        FROM @tblCust tc
    END
    ELSE 
    BEGIN
        INSERT INTO @tblCust (CustInfo)
        SELECT RTRIM(LTRIM(val))
        FROM dbo.strSplit(@CustIDList, ',') 
        
        SELECT tmpCust.CustInfo, ci.Site,1 AS IsValid     
        FROM @tblCust tmpCust
            INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.custid = tmpCust.CustInfo AND ci.roleid IN (0,2,3,4)
		UNION ALL
		SELECT tmpCust.CustInfo, a.Site,1 AS IsValid       
        FROM @tblCust tmpCust
            INNER JOIN dbo.Customer ci WITH (NOLOCK) ON ci.custid = tmpCust.CustInfo AND ci.roleid =1
			INNER JOIN dbo.Customer a WITH (NOLOCK) ON ci.recommend = a.CustID
		UNION ALL		 
		SELECT tmpCust.CustInfo,NULL,0 AS IsValid   
		FROM @tblCust tmpCust
		WHERE tmpCust.CustInfo NOT IN(SELECT CustID FROM Customer WITH(NOLOCK))
    END 
END
GO
