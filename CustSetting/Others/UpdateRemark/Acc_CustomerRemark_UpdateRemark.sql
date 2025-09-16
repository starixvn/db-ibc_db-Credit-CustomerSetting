/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_alp,wsv_alpv" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerRemark_UpdateRemark]
    @CustID         INT
    , @Remark       NVARCHAR(200)
    , @UserID       INT
    , @IP           VARCHAR(15)     = ''
    , @ErrCode      INT             = 0  OUTPUT
    , @ErrMsg       NVARCHAR(500)   = '' OUTPUT
AS
/*
    Created: 20250915@Dave
    Task : Alpha_Add remark field when editing info of master/Agent/member
    DB: DBCUST/CUSTDB

    Revisions:
        - 20250915@Dave: Initial SP [RedmineID: #238689]
        

    Parameter's Explanation;
        • @CustID: Customer ID
        • @Remark: Remark to update
        • @UserID: User who update
        • @ErrCode:
            = 0: Update successfully.
            > 0: Specific Error.
        • @ErrMsg: Error description.
*/
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RoleID INT;
    DECLARE @OldRemark NVARCHAR(200);
    DECLARE @LogSPData NVARCHAR(MAX);
    DECLARE @ActionID INT = 264008;

    BEGIN TRY
        -- Check if customer exists
        IF NOT EXISTS (SELECT TOP(1) 1 FROM dbo.CustInfo WITH (NOLOCK) WHERE CustID = @CustID)
        BEGIN
            SET @ErrCode = 100;
            SET @ErrMsg = 'Customer does not exist.';
            RETURN;
        END


        SELECT @RoleID = RoleID FROM dbo.CustInfo WITH (NOLOCK) WHERE CustID = @UserID;


        IF EXISTS (SELECT TOP(1) 1 FROM dbo.CustomerRemark WITH (NOLOCK) WHERE CustID = @CustID)
        BEGIN
        
            SELECT @OldRemark = 
                CASE @RoleID
                    WHEN 4 THEN SuperRemark
                    WHEN 3 THEN MasterRemark
                    WHEN 2 THEN AgentRemark
                    ELSE NULL
                END
            FROM dbo.CustomerRemark WITH (NOLOCK)
            WHERE CustID = @CustID;


            UPDATE dbo.CustomerRemark WITH (ROWLOCK, UPDLOCK)
            SET 
                SuperRemark = CASE WHEN @RoleID = 4 THEN @Remark ELSE SuperRemark END,
                MasterRemark = CASE WHEN @RoleID = 3 THEN @Remark ELSE MasterRemark END,
                AgentRemark = CASE WHEN @RoleID = 2 THEN @Remark ELSE AgentRemark END
            WHERE CustID = @CustID;

        END
        ELSE
        BEGIN
        
            INSERT INTO dbo.CustomerRemark (CustID, SuperRemark, MasterRemark, AgentRemark)
            VALUES (
                @CustID,
                CASE WHEN @RoleID = 4 THEN @Remark ELSE NULL END,
                CASE WHEN @RoleID = 3 THEN @Remark ELSE NULL END,
                CASE WHEN @RoleID = 2 THEN @Remark ELSE NULL END
            );

        END
           
        SELECT @LogSPData = 
            '<Acc_CustomerRemark_UpdateRemark CustID="' + COALESCE(CAST(@CustID AS VARCHAR(50)), SPACE(1)) + '" ' +
            'RoleID="' + COALESCE(CAST(@RoleID AS VARCHAR(50)), SPACE(1)) + '" ' +
            'OldRemark="' + dbo.f_EncodeXMLValue(COALESCE(@OldRemark, SPACE(1))) + '" ' +
            'NewRemark="' + dbo.f_EncodeXMLValue(COALESCE(@Remark, SPACE(1))) + '" ' +
            'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) + '" ' +
            'IP="' + COALESCE(@IP, SPACE(1)) + '" />';

        EXECUTE bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = @ActionID,
            @TrackingValue = @LogSPData,
            @duration = 0;

    END TRY
    BEGIN CATCH
        SET @ErrCode = ERROR_NUMBER();
        SET @ErrMsg = ERROR_MESSAGE();
    END CATCH

END