/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustOverrideUpdKeno] 
    @CustID INT,
    @UplineID INT = 0,
    @Sporttype INT = 202,
    @Bettype INT,
    
    @Min_Positiontaking SMALLMONEY,
    
    @Language VARCHAR(2) = 'E',
    @UserID INT = 0,
    @SubAccID INT = 0, --Sub-AccountID
    @IP VARCHAR(15)='',
    @ErrCode INT = 0 OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
    Created: 20140225@Elodie
    Task : Update CustOverrideGame for Keno
    DB: DBCUST/CustDB

    Revisions:
		- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216] 
		- 20201028@Eden: Adjust new pt for 789y [Redmine: #143764]                       

    Param's Explanation:
    • @ErrCode:
        = 0: Update successfully.
        > 0: Specific Error.
      
    • @ErrMsg: Error description.
*/
BEGIN
    DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
    SET @startRun = GETDATE()

    DECLARE @roleid INT
    DECLARE @Old_Min_Positiontaking SMALLMONEY    

    SELECT @roleid = roleid FROM CustInfo WITH (NOLOCK) WHERE custid = @custid

    --Check Allowed downlines    
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
        @CustID = @CustID,
        @roleid = @roleid,
        @isExecRep = 1,
        @isUpdatePT = 1,
        @Sporttype = 1,
        @Language='E',
        @ErrMsg=@ErrMsg OUTPUT,
        @ErrCode=@ErrCode OUTPUT
    IF    @ErrCode <> 0 
        RETURN     

    SELECT @Old_Min_Positiontaking = minpositiontaking
    FROM CustOverrideGame WITH(NOLOCK)
    WHERE custid = @CustID AND sporttype = @Sporttype AND bettype = @Bettype

    IF @Old_Min_Positiontaking = @Min_Positiontaking
        RETURN    

    UPDATE CustOverrideGame WITH(UPDLOCK, ROWLOCK)
    SET minpositiontaking = @Min_Positiontaking
    WHERE custid = @CustID AND sporttype = @Sporttype AND bettype = @Bettype
    IF @roleid = 4
    BEGIN        
                EXEC Acc_CustSetting3rd_04 @srecommend = @CustID, @roleid = 4, @mode = 'Keno', @sporttype = @Sporttype, @bettype = @Bettype
    END

    IF @roleid = 3
    BEGIN
                                                                EXEC Acc_CustSetting3rd_04 @custid = @CustID, @srecommend = @UplineID, @roleid = 3, @mode = 'Keno', @sporttype = @Sporttype, @bettype = @Bettype
    END

    IF @roleid = 2
    BEGIN        
                EXEC Acc_CustSetting3rd_04 @custid = @CustID, @mrecommend = @UplineID, @roleid = 2, @mode = 'Keno', @sporttype = @Sporttype, @bettype = @Bettype
    END

    DECLARE @LogSPData VARCHAR(MAX),
            @TrackingValueDB VARCHAR(4000)
            
    SELECT @LogSPData = '<Acc_CustOverrideUpdKeno custid="' + COALESCE(CAST(@CustID AS VARCHAR(30)), SPACE(1)) + '" ' +
        'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'Min_Positiontaking="' + COALESCE(dbo.f_FomatNumericToChar(@Min_Positiontaking), SPACE(1)) + '" ' + 
        'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustOverrideUpdKeno custid="' + COALESCE(CAST(@CustID AS VARCHAR(30)), SPACE(1)) + '" ' +
        'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'Min_Positiontaking="' + COALESCE(dbo.f_FomatNumericToChar(@Old_Min_Positiontaking), SPACE(1)) + '" ' + 
        'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'
    
    SET @endRun = GETDATE()
    SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)
    
    --Write log
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 506,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustOverrideUpdKeno custid="' + COALESCE(CAST(@CustID AS VARCHAR(30)), SPACE(1)) + '" ' +
        'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'bettype="'+ COALESCE(CAST(@bettype AS VARCHAR(10)),SPACE(1)) + '" ' + 
        'Min_Positiontaking="' + COALESCE(dbo.f_FomatNumericToChar(@Min_Positiontaking), SPACE(1)) + '" ' + 
        'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 506,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH
END

GO
