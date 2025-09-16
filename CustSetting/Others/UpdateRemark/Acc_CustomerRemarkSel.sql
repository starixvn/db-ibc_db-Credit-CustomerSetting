/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_alp,wsv_alpv" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerRemarkSel]
    @CustID         INT
    , @UserID       INT
AS
/*
    Created: 20250915@Dave
    Task : Alpha_Add remark field when editing info of master/Agent/member
    DB: DBCUST/CUSTDB

    Revisions:
        - 20250915@Dave: Initial SP [RedmineID: #238689]
        

    Parameter's Explanation;
        • @CustID: Customer ID
        • @UserID: User who get the remark
*/
BEGIN

    SET NOCOUNT ON;

    DECLARE @RoleID INT;

    SELECT @RoleID = RoleID 
    FROM dbo.CustInfo WITH (NOLOCK) 
    WHERE CustID = @UserID;

    SELECT 
        custID,
        CASE @RoleID
            WHEN 4 THEN SuperRemark
            WHEN 3 THEN MasterRemark
            WHEN 2 THEN AgentRemark
            ELSE ''
        END AS Remark
    FROM dbo.CustomerRemark WITH (NOLOCK)
    WHERE CustID = @CustID;

END