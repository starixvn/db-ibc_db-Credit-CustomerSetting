/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_CashService" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerDelBankAccount_CashMember]
(
    @userID             INT             ,        -- User performing the action
    @custid             INT             ,
    @MemberBankAccountID INT             = NULL,
    @Language           VARCHAR(2)       = 'E',
    @SubAccID           INT             = 0,
    @IP                 VARCHAR(50)      = '',
    @ErrCode            INT             = 0     OUTPUT,
    @ErrMsg             NVARCHAR(4000)  = ''    OUTPUT
)
AS
/*
    Created: 20241107@Helios
    Task: Agent create cash member - Remove Member Bank Account [#223896] 
    DB: DBCUST-AgencyCashService
    
    Revisions:
        - 20250623@Helios: Offer CashService - Remove Bank Account Member [RedmineID: #231204]
    
    Parameter's Explanation:
    · @userID: User performing the action
    · @custid: Customer ID
    · @MemberBankAccountID: Member's bank account ID to delete
    · @Language: Language for error messages ('E' for English)
    · @SubAccID: Sub-account identifier (optional)
    · @IP: Client IP address for audit
    · @ErrCode: Error code (0 = success, >0 = error)
    · @ErrMsg: Error message in specified language

    Example Usage:
    DECLARE
        @p1 INT
    SET @p1=0
    DECLARE
        @p2 NVARCHAR(1000)
    SET @p2=NULL
    EXEC Acc_CustomerDelBankAccount_CashMember        @ErrCode				= @p1 OUTPUT
                                    , @ErrMsg				= @p2 OUTPUT
                                    , @userID				= 1
                                    , @custid				= 1986752
                                    , @MemberBankAccountID		= 69
                                    , @SubAccID				= 0
                                    , @IP					= '172.18.0.15'
                                    , @Language				= 'E'
    SELECT @p1 , @p2
*/	
BEGIN
    SET NOCOUNT ON;
    
    -- Declare timing variables at the start
    DECLARE 
        @startRun       DATETIME,
        @endRun         DATETIME,
        @DurationTime   INT,
        @ServiceType    TINYINT    -- Added for service type check
    
    -- Initialize error handling variables
    SELECT  @ErrCode = 0,
            @ErrMsg = ''
    
    SET @startRun = GETDATE()
    
    -- Check if user has Cash Service enabled
    EXEC CustDB.dbo.Age_CashService_CustServiceTypeSel 
        @CustID = @userID,
        @ServiceType = @ServiceType OUTPUT

    IF @ServiceType = 0
    BEGIN
        SET @ErrMsg = N'Permission denied. Please enable the Cash Service to proceed.';
        SET @ErrCode = 103;
        RETURN;
    END;

    -- Validate required parameters
    IF @custid IS NULL OR @MemberBankAccountID IS NULL
    BEGIN
        SET @ErrMsg = N'Invalid parameters';
        SET @ErrCode = 100;
        RETURN;
    END;

    DECLARE @Old_MemberBankStatus BIT = NULL;

    -- Check if member bank account exists and is active
    SELECT @Old_MemberBankStatus = IsActive
    FROM dbo.CashMemberBankAccount WITH (NOLOCK)
    WHERE CustId = @custid 
      AND BankAccountMemberID = @MemberBankAccountID
      AND IsActive = 1;

    IF @Old_MemberBankStatus IS NULL
    BEGIN
        SET @ErrMsg = N'Bank account not found';
        SET @ErrCode = 200;
        RETURN;
    END;

    -- Delete Operation (Soft Delete)
    BEGIN TRY
        UPDATE dbo.CashMemberBankAccount WITH (ROWLOCK, UPDLOCK)
        SET IsActive = 0,
            RepUpdateTime = [dbo].[f_GetDateTime2]()
        WHERE CustId = @custid
          AND BankAccountMemberID = @MemberBankAccountID
          AND IsActive = 1;    
    END TRY
    BEGIN CATCH
        SET @ErrMsg = N'Action failed. Please try again.';
        SET @ErrCode = 500;
        RETURN;
    END CATCH;

    -- If no error, set success message
    IF @@ERROR = 0
    BEGIN
        SET @ErrMsg = N'Action completed successfully.';
        SET @ErrCode = 0;
    END

    -- Write Log
    DECLARE 
        @TrackingValue  NVARCHAR(MAX),
        @TrackingValue2 NVARCHAR(MAX),
        @ActionID INT = 300005  -- Action ID for bank account deletion
    
    SET @endRun = GETDATE()
    SET @DurationTime = DATEDIFF(millisecond, @startRun, @endRun)

    -- LOG NEW VALUES
    SELECT @TrackingValue = '<Acc_CustomerDelBankAccount_CashMember 
                            CustID="' + convert(varchar(20), @CustID) 
                            +'" SubAccName="' + CustDB.dbo.f_GetSubUsername(@SubAccID) 
                            +'" IP="' + convert(varchar(50), @IP)   
                            +'" IsActive="' + convert(varchar(20), 0) +'" />'

    -- LOG OLD VALUES
    SELECT @TrackingValue2 = '<Acc_CustomerDelBankAccount_CashMember 
                            CustID="' + convert(varchar(20), @CustID) 
                            +'" SubAccName="' + CustDB.dbo.f_GetSubUsername(@SubAccID) 
                            +'" IP="'  + convert(varchar(50), @IP)    
                            +'" IsActive="' +  convert(varchar(20), @Old_MemberBankStatus)  +'" />'

    -- Return Log Data Object
    SELECT 
        @UserID         AS UserID,
        @CustID         AS CustID,
        @ActionID       AS ActionID,
        @TrackingValue  AS TrackingValue,
        @TrackingValue2 AS TrackingValue2,
        @TrackingValue  AS TrackingValueMask,
        @TrackingValue2 AS TrackingValueMask2,
        @DurationTime   AS Duration;
END;
GO