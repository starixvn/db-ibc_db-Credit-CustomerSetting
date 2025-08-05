/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_nap,wsv_CashService" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsBankAccount_CashMember]
(
    @userID                     INT,                -- AgentID
    @custid                     INT OUTPUT,
    @MemberBankId               INT = NULL,
    @MemberBankAccountNumber    VARCHAR(100) = NULL,
    @AgentBankAccountNumber     VARCHAR(100) = NULL,
    @AgentBankID                INT = 0,
    @Language                   VARCHAR(2) = 'E',
    @SubAccID                   INT = 0,
    @IP                         VARCHAR(50) = '',
    @ErrCode                    INT = 0 OUTPUT,
    @ErrMsg                     NVARCHAR(4000) = '' OUTPUT
)
AS

/*
    Created: 20250424@Elodie
    Task: Agent create cash member - Insert bank account [#223896]
    DB: DBCUST.CustDB
    
    Revisions:
        - 20241107@Elodie: Offer Cash service [redmine: #224778]
        - 20250623@Helios: Offer CashService - Add Bank Account Member [RedmineID: #231204] 
	  - 20250724@Helios: Agency Cash Service -Customer Setting Sprint 7 [redmine: #233474] 
    
    Parameter's Explanation:
    DECLARE @custid   INT;
    DECLARE @ErrCode  INT;
    DECLARE @ErrMsg   NVARCHAR(4000);

    EXEC dbo.Acc_CustomerInsBankAccount_CashMember
        @userID                     = 233657454,         -- AgentID
        @custid                     = @custid OUTPUT,    -- Customer ID (output)
        @MemberBankId               = 1,                 -- Bank ID (e.g., 1 = Kasikornbank)
        @MemberBankAccountNumber    = '1234567890',      -- Customer's bank account number
        @AgentBankAccountNumber     = 'AGT123456',       -- Agent's account number (if applicable)
        @AgentBankID                = 2,                 -- Agent's Bank ID (if applicable)
        @Language                   = 'E',               -- 'E' for English
        @SubAccID                   = 0,                 -- Sub-account ID (optional)
        @IP                         = '10.0.0.1',        -- Client IP (optional)
        @ErrCode                    = @ErrCode OUTPUT,
        @ErrMsg                     = @ErrMsg OUTPUT;

    SELECT
        @custid  AS CustomerID,
        @ErrCode AS ErrorCode,
        @ErrMsg  AS ErrorMessage;
*/	
BEGIN
    SET NOCOUNT ON;
    
    -- Declare timing variables at the start
    DECLARE @startRun           DATETIME,
            @endRun             DATETIME,
            @DurationTime       INT,
            @BankAccountNumber  VARCHAR(100) = NULL,
            @ServiceType        TINYINT    -- Added for service type check
    
    -- Initialize error handling variables
    SELECT @ErrCode = 0,
           @ErrMsg = ''
    
    SET @startRun = GETDATE();

    SET @BankAccountNumber = NULLIF(LTRIM(RTRIM(@AgentBankAccountNumber)), '');

    -- Check if Agent has Cash Service enabled
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

    IF @custid IS NULL OR @MemberBankId IS NULL OR @MemberBankAccountNumber IS NULL
    BEGIN
        SET @ErrMsg = N'Invalid parameters';
        SET @ErrCode = 100;
        RETURN;
    END;

    -- Validate Bank ID using AgencyCashService validation function
    -- @MemberBankId Required Is Not Null
    IF dbo.f_IsValidBank(@MemberBankId) = 0
    BEGIN
        SET @ErrMsg = N'Invalid parameters';
        SET @ErrCode = 101;
        RETURN;
    END;

    -- @AgentBankID not required, is allows NULL
    IF @AgentBankID IS NOT NULL AND @AgentBankID <> 0 AND @BankAccountNumber IS NOT NULL
    BEGIN
        IF dbo.f_IsValidBank(@AgentBankID) = 0
        BEGIN
            SET @ErrMsg = N'Invalid parameters';
            SET @ErrCode = 101;
            RETURN;
        END;
    END;

    -- Check if account already exists
    IF EXISTS (
        SELECT TOP 1 1 
        FROM dbo.CashMemberBankAccount WITH (NOLOCK)
        WHERE custid = @custid 
          AND BankId = @MemberBankId 
          AND AccountNumber = @MemberBankAccountNumber
          AND IsActive = 1
    )
    BEGIN
        SET @ErrMsg = N'This bank account already exists';
        SET @ErrCode = 200;
        RETURN;    
    END;

    DECLARE @AgentBankAccountID INT = NULL;

    -- Validate agent bank account if provided
    IF @BankAccountNumber IS NOT NULL
    BEGIN
        SELECT @AgentBankAccountID = caba.AgentBankAccountID
        FROM dbo.CashAgentBankAccount caba WITH (NOLOCK)
        WHERE caba.AgentID = @userID 
          AND caba.BankID = @AgentBankID 
          AND caba.BankAccountNumber = @BankAccountNumber 
          AND (',' + caba.TransTypeList + ',' LIKE '%,1,%' OR ',' + caba.TransTypeList + ',' LIKE '%,2,%')  --  Deposit
          AND caba.BankAccountStatus = 1 
          AND caba.IsActive = 1;                                              --  Active and valid account
        
        IF ISNULL(@AgentBankAccountID, 0) = 0
        BEGIN
            SET @ErrMsg = N'Invalid parameters';
            SET @ErrCode = 102;
            RETURN;
        END;
        
        IF @AgentBankAccountID IS NOT NULL
        BEGIN   
            -- Check if account already exists
            IF EXISTS (
                SELECT TOP 1 1 
                FROM dbo.CashMemberBankAccount WITH (NOLOCK)
                WHERE custid = @custid 
                  AND BankId = @MemberBankId 
                  AND AccountNumber = @MemberBankAccountNumber
                  AND BankAccountAgentID = @AgentBankAccountID
                  AND IsActive = 1
            )
            BEGIN
                SET @ErrMsg = N'This bank account already exists';
                SET @ErrCode = 200;
                RETURN;    
            END;
        END;
    END;

    -- Insert Operation
    BEGIN TRY
        INSERT INTO dbo.CashMemberBankAccount (
            custid, 
            BankId, 
            AccountNumber, 
            BankAccountAgentID,
            IsActive,
            RepUpdateTime
        )
        VALUES (
            @custid, 
            @MemberBankId, 
            @MemberBankAccountNumber, 
            @AgentBankAccountID,
            1,
            [dbo].[f_GetDateTime2]()
        );
    END TRY
    BEGIN CATCH
        SET @ErrMsg = N'Action failed. Please try again.';
        SET @ErrCode = 500;
        RETURN;    
    END CATCH;

    -- Check Success
    IF @@ERROR = 0
    BEGIN
        SET @ErrMsg = N'Action completed successfully.';
        SET @ErrCode = 0;
    END;    
    
    -- Write Log
    -- Param use for writelog
    DECLARE @TrackingValue      NVARCHAR(MAX),
            @TrackingValue2     NVARCHAR(MAX),
            @TrackingValueMask  NVARCHAR(MAX),
            @TrackingValueMask2 NVARCHAR(MAX),
            @ActionID           INT = 300008;  -- Action ID for bank account creation
    
    SET @endRun       = GETDATE();
    SET @DurationTime = DATEDIFF(millisecond, @startRun, @endRun);

    DECLARE @BankCode VARCHAR(10);
    SELECT @BankCode = cbl.BankCode 
    FROM CashBankList cbl WITH (NOLOCK) 
    WHERE cbl.BankID = @MemberBankId;


    -- LOG NEW VALUES
    SELECT @TrackingValueMask = '<Acc_CustomerInsBankAccount_CashMember 
                            CustID="' + CONVERT(VARCHAR(20), @CustID) 
                            + '" SubAccName="' + CustDB.dbo.f_GetSubUsername(@SubAccID) 
                            + '" IP="' + CONVERT(VARCHAR(50), @IP)   
				    + '" MemberBankId="' + CONVERT(VARCHAR(50), @MemberBankId)
                            + '" MemberBankCode="' + CONVERT(VARCHAR(10), @BankCode)   
                            + '" MemberBankAccountNumber="' + CONVERT(VARCHAR(100), @MemberBankAccountNumber)   
                            + '" AgentBankAccountID="' + CONVERT(VARCHAR(50), ISNULL(@AgentBankAccountID, 0))
                            + '" AgentBankAccountNumber="' + CONVERT(VARCHAR(100), ISNULL(@BankAccountNumber, N'NoMatchingBankAccount'))   
                            + '" IsActive="' + CONVERT(VARCHAR(20), 1) + '" />';


    -- Then create display values with empty account numbers by replacing the actual account numbers
    SELECT @TrackingValue = @TrackingValueMask;

    SET @TrackingValue = REPLACE(
        @TrackingValue,
        'MemberBankAccountNumber="' + CONVERT(VARCHAR(100), @MemberBankAccountNumber) + '"',
        'MemberBankAccountNumber=""'
    );

    IF @BankAccountNumber IS NOT NULL
    BEGIN
        SET @TrackingValue = REPLACE(
            @TrackingValue,
            'AgentBankAccountNumber="' + CONVERT(VARCHAR(100), @BankAccountNumber) + '"',
            'AgentBankAccountNumber=""'
        );
    END;


    SELECT @userID             AS UserID,        -- Changed from @custid to @userID
           @custid             AS CustID,
           @ActionID           AS ActionID,
           @TrackingValue      AS TrackingValue,
           NULL                AS TrackingValue2,
           @TrackingValueMask  AS TrackingValueMask,
           NULL                AS TrackingValueMask2,
           @DurationTime       AS Duration;
END
GO