/*<info serverAlias="DBCUST-AgencyCashService" executers="wsv_CashService" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdBankAccount_CashMember]
(
    @userID             INT             ,        -- User performing the action
    @custid             INT             ,
    @MemberBankId           INT             = NULL,
    @MemberBankAccountID    INT             = NULL,
    @MemberBankAccountNumber VARCHAR(100)   = NULL,
    @AgentBankAccountNumber VARCHAR(100)    = NULL, 
    @AgentBankID            INT             = NULL,
    @Language           VARCHAR(2)       = 'E',
    @SubAccID           INT             = 0,
    @IP                 VARCHAR(50)      = '',
    @ErrCode            INT             = 0     OUTPUT,
    @ErrMsg             NVARCHAR(4000)  = ''    OUTPUT
)
AS

/*
Created: 20241107@Helios
Task: Agent create cash member - Update Agent Bank Account [#223896]
DB: DBCUST-AgencyCashService

Revisions:
    - 20250623@Helios: Offer CashService - Changed Bank Account Associate's [RedmineID: #231204]
    - 20250724@Helios: Agency Cash Service -Customer Setting Sprint 7 [redmine: #233474] 
    - 20250724@Helios: Agency Cash Service -Customer Setting Sprint 8 [redmine: #235266] 

Parameter's Explanation:
    · @userID: User performing the action
    · @custid: Customer ID
    · @MemberBankId: BankID member identifier from CashBankList
    · @MemberBankAccountID: Member's bank account ID
    · @MemberBankAccountNumber: Current account number
    · @AgentBankAccountNumber: New agent's account number ID
    · @AgentBankID: Agent's Bank ID (if applicable)
    · @Language: Language for error messages ('E' for English)
    · @SubAccID: Sub-account identifier (optional)
    · @IP: Client IP address for audit
    · @ErrCode: Error code (0 = success, >0 = error)
    · @ErrMsg: Error message in specified language

Example Usage:
    DECLARE @ErrCode INT, @ErrMsg NVARCHAR(4000)
    
    EXEC Acc_CustomerUpdBankAccount_CashMember
        @userID = 1234,
        @custid = 1986752,
        @MemberBankId = 2,
        @MemberBankAccountID = 69,
        @MemberBankAccountNumber = '1823749102466',
        @AgentBankAccountNumber = 113,
        @Language = 'E',
        @ErrCode = @ErrCode OUTPUT,
        @ErrMsg = @ErrMsg OUTPUT
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

    -- Check if user has Cash Service enabled
    --IF @SubAccID <> 0
    --BEGIN
	   -- EXEC CustDB.dbo.Age_CashService_CustServiceTypeSel 
		  --@CustID = @userID,
		  --@ServiceType = @ServiceType OUTPUT

	   -- IF @ServiceType = 0
	   -- BEGIN
		  --SET @ErrMsg = N'Permission denied. Please enable the Cash Service to proceed.';
		  --SET @ErrCode = 103;
		  --RETURN;
	   -- END;
    --END

    -- Validate required parameters
    IF @custid IS NULL 
        OR @MemberBankId IS NULL 
        OR @MemberBankAccountID IS NULL 
        OR @MemberBankAccountNumber IS NULL 
        OR (@BankAccountNumber IS NOT NULL AND @AgentBankID = 0) 
        OR (@BankAccountNumber IS NULL AND @AgentBankID <> 0)
    BEGIN
        SET @ErrMsg = N'Invalid parameters';
        SET @ErrCode = 100;
        RETURN;
    END;

    -- Validate Bank ID
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

    DECLARE @IsExist_MemberBankAcc      BIT = NULL,
            @IsExist_AgentBankAcc       BIT = NULL,
            @AgentBankAccountID_New     INT = NULL,
            @AgentBankAccountID_Old     INT = 0,
            @AgentBankAccountNumber_Old VARCHAR(100) = NULL;

    -- Check if member bank account exists
    IF EXISTS (
        SELECT TOP 1 1 
        FROM dbo.CashMemberBankAccount WITH (NOLOCK)
        WHERE custid = @custid 
          AND BankId = @MemberBankId 
          AND AccountNumber = @MemberBankAccountNumber
          AND IsActive = 1
    )
    BEGIN
        SET @IsExist_MemberBankAcc = 1;
    END
    ELSE
    BEGIN
        SET @IsExist_MemberBankAcc = 0;
    END;

    IF ISNULL(@IsExist_MemberBankAcc, 0) = 0
    BEGIN
        SET @ErrMsg = N'Bank account not found';
        SET @ErrCode = 203;
        RETURN;
    END;
    
    -- Validate agent bank account if provided
    IF @BankAccountNumber IS NOT NULL
    BEGIN
        SELECT @AgentBankAccountID_New = AgentBankAccountID
        FROM dbo.CashAgentBankAccount WITH (NOLOCK)
        WHERE BankID = @AgentBankID
          AND BankAccountNumber = @BankAccountNumber
          AND (',' + TransTypeList + ',' LIKE '%,1,%' OR ',' + TransTypeList + ',' LIKE '%,2,%')
          AND BankAccountStatus = 1 
          AND IsActive = 1;

        IF ISNULL(@AgentBankAccountID_New, 0) = 0
        BEGIN
            SET @ErrMsg = N'Bank account not found';
            SET @ErrCode = 203;
            RETURN;
        END;
    END;
    
    -- Get current agent bank account ID
    SELECT @AgentBankAccountID_Old = BankAccountAgentID 
    FROM dbo.CashMemberBankAccount WITH (NOLOCK)
    WHERE BankAccountMemberID = @MemberBankAccountID 
      AND CustId = @custid 
      AND BankId = @MemberBankId 
      AND AccountNumber = @MemberBankAccountNumber
      AND IsActive = 1;
    
    -- Check if there's any change needed
    IF ISNULL(@AgentBankAccountID_New, 0) = ISNULL(@AgentBankAccountID_Old, 0)
    BEGIN
        SET @ErrMsg = N'NoChange';
        SET @ErrCode = 0;
        RETURN;
    END;

    -- Get for write log
    SELECT @AgentBankAccountNumber_Old = caba.BankAccountNumber
    FROM CashAgentBankAccount caba WITH (NOLOCK)
    WHERE caba.AgentBankAccountID = @AgentBankAccountID_Old;

    -- Update Operation
    BEGIN TRY
        UPDATE dbo.CashMemberBankAccount WITH (ROWLOCK, UPDLOCK)
        SET BankAccountAgentID = @AgentBankAccountID_New,
            RepUpdateTime      = [dbo].[f_GetDateTime2]()
        WHERE BankAccountMemberID = @MemberBankAccountID
          AND CustId = @custid
          AND BankId = @MemberBankId
          AND AccountNumber = @MemberBankAccountNumber
          AND IsActive = 1;
    END TRY
    BEGIN CATCH
        SET @ErrMsg = N'Action failed. Please try again.';
        SET @ErrCode = 500;
        RETURN;
    END CATCH;    

    IF @@ERROR = 0
    BEGIN
        SET @ErrMsg = N'Action completed successfully.';
        SET @ErrCode = 0;
    END;
    
    -- Write Log
    DECLARE @TrackingValue      NVARCHAR(MAX),
            @TrackingValue2     NVARCHAR(MAX),
            @TrackingValueMask  NVARCHAR(MAX),
            @TrackingValueMask2 NVARCHAR(MAX),
            @ActionID           INT = 300007;  -- Action ID for bank account update
    
    SET @endRun       = GETDATE();
    SET @DurationTime = DATEDIFF(millisecond, @startRun, @endRun);

    DECLARE @BankCode VARCHAR(10);
    SELECT @BankCode = cbl.BankCode 
    FROM CashBankList cbl WITH (NOLOCK) 
    WHERE cbl.BankID = @MemberBankId;

    -- First create tracking values with actual account numbers
    SELECT @TrackingValueMask = '<Acc_CustomerUpdBankAccount_CashMember 
                            CustID="' + CONVERT(VARCHAR(20), @CustID) 
                            + '" SubAccName="' + CustDB.dbo.f_GetSubUsername(@SubAccID) 
                            + '" IP="' + CONVERT(VARCHAR(50), @IP)   
                            + '" MemberBankId="' + CONVERT(VARCHAR(20), @MemberBankId)   
                            + '" MemberBankCode="' + CONVERT(VARCHAR(10), @BankCode)   
                            + '" MemberBankAccountID="' + CONVERT(VARCHAR(20), @MemberBankAccountID)   
                            + '" MemberBankAccountNumber="' + CONVERT(VARCHAR(100), @MemberBankAccountNumber) 
                            + '" AgentBankAccountID="' + CONVERT(VARCHAR(50), ISNULL(@AgentBankAccountID_New, 0)) 
                            + '" AgentBankAccountNumber="' + CONVERT(VARCHAR(100), ISNULL(@BankAccountNumber, N'NoMatchingBankAccount')) + '" />';

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
	
    SELECT @TrackingValueMask2 = '<Acc_CustomerUpdBankAccount_CashMember 
                            CustID="' + CONVERT(VARCHAR(20), @CustID) 
                            + '" SubAccName="' + CustDB.dbo.f_GetSubUsername(@SubAccID) 
                            + '" IP="' + CONVERT(VARCHAR(50), @IP)   
                            + '" MemberBankId="' + CONVERT(VARCHAR(20), @MemberBankId)   
                            + '" MemberBankCode="' + CONVERT(VARCHAR(10), @BankCode)   
                            + '" MemberBankAccountID="' + CONVERT(VARCHAR(20), @MemberBankAccountID)   
                            + '" MemberBankAccountNumber="' + CONVERT(VARCHAR(50), @MemberBankAccountNumber)    
                            + '" AgentBankAccountID="' + CONVERT(NVARCHAR(50), ISNULL(@AgentBankAccountID_Old, 0))
                            + '" AgentBankAccountNumber="' + CONVERT(VARCHAR(100), ISNULL(@AgentBankAccountNumber_Old, N'NoMatchingBankAccount')) + '" />';

    SELECT @TrackingValue2 = @TrackingValueMask2;

    SET @TrackingValue2 = REPLACE(
        @TrackingValue2,
        'MemberBankAccountNumber="' + CONVERT(VARCHAR(100), @MemberBankAccountNumber) + '"',
        'MemberBankAccountNumber=""'
    );

    IF @AgentBankAccountNumber_Old IS NOT NULL
    BEGIN
        SET @TrackingValue2 = REPLACE(
            @TrackingValue2,
            'AgentBankAccountNumber="' + CONVERT(VARCHAR(100), @AgentBankAccountNumber_Old) + '"',
            'AgentBankAccountNumber=""'
        );
    END;


    -- Return Log Data Object
    SELECT @UserID              AS UserID,
           @CustID              AS CustID,
           @ActionID            AS ActionID,
           @TrackingValue       AS TrackingValue,
           @TrackingValue2      AS TrackingValue2,
           @TrackingValueMask   AS TrackingValueMask,
           @TrackingValueMask2  AS TrackingValueMask2,
           @DurationTime        AS Duration;
END;

GO