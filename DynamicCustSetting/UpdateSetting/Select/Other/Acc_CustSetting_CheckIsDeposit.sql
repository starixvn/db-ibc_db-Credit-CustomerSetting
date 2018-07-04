/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_CheckIsDeposit 
        @UserName NVARCHAR(50)='',
        @CustID INT = 0
AS
/*  
 Created: 201511111@Dominic  
 Task : Check if a customer is a deposit customer or not
 DB:  DBCUST/CustDB   
 Original:  
        - 20180704@Vicky: search by custid [Redmine: #96118]
 Param's Explanation:  
        
   
 */  
BEGIN
	DECLARE @IsDeposit BIT = 0
    
    IF @CustID = 0
    BEGIN
        SELECT @IsDeposit = 1
        FROM dbo.custInfo ci WITH (NOLOCK)
            INNER JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
        WHERE ci.username = @UserName
    END 
    ELSE
    BEGIN
       SELECT @IsDeposit = 1
       FROM dbo.custInfo ci WITH (NOLOCK)
            INNER JOIN dbo.Dep_CustSuper dep WITH (NOLOCK) ON ci.srecommend = dep.custid
       WHERE ci.custid = @CustID
    END 
    
    SELECT @IsDeposit IsDeposit
END
GO


