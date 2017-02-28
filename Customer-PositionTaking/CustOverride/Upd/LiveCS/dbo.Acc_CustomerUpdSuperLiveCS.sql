USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustOverrideUpdLiveCS]    Script Date: 06/10/2015 17:11:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdLiveCS    Script Date: 8/28/2014 2:05:17 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdLiveCS    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdLiveCS    Script Date: 8/21/2014 2:58:08 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdLiveCS    Script Date: 12/5/2013 5:35:45 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustOverrideUpdLiveCS]
    @custid        INT,
    @UplineID    INT = 0,
    @min_v162positiontaking_1101    SMALLMONEY,
    
    @SubAccID    INT = 0 ,
    @UserID        INT = 0    ,
    @IP            VARCHAR(50)= '',    
    @Language    VARCHAR(20) = 'E',        
    
    @ErrCode    VARCHAR(300) = '' OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
AS
    /*
        Created: Johnson
        Date: 30Dec2011
        Task: Update min positiontaking
        DB: DBTrans.BODB02
        
        Revisions:
            - 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
            - 20131030@Lukas: Apply execRep
            - 20131112@Johnson: change to use execrep Acc_CustSetting3rd_04 instead of Acc_CustSetting3rd_00 for updating min pt on super
            - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]
        Parameters Explanation:
    */
SET NOCOUNT ON
        
    DECLARE @startRun DATETIME
    DECLARE @endRun DATETIME
    DECLARE @duration INT
    SET @startRun = GETDATE()

    DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000)
    DECLARE @old_min_v162positiontaking_1101 SMALLMONEY
    
    SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

    ---------------------------
    -- ***Check Downline Belonging***
    EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
        @SessionCustID = @Userid, 
        @Custid = @custid,
        @roleid = @roleid OUTPUT
        IF (@roleid = 0) RETURN
    ---------------------------

    --Check disable user
    EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
    IF @ErrCode_Cur > 0
    BEGIN
        select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
                @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
        return
    END
    --end
    
    --Check Allowed downlines    
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
                @roleid=@roleid,
                @isExecRep=1,
                @isUpdatePT = 1,
                @Sporttype = 1,
                @Language='E',
                @ErrMsg=@ErrMsg output,
                @ErrCode=@ErrCode output
    IF    @ErrCode <> 0 
        RETURN 
    
    SELECT @old_min_v162positiontaking_1101 = minpositiontaking
    FROM CustOverrideGame WITH(NOLOCK)
    WHERE custid = @custid AND sporttype = 162 AND bettype = 1101
    
    IF @old_min_v162positiontaking_1101 = @min_v162positiontaking_1101
        RETURN     
    
    UPDATE CustOverrideGame WITH(UPDLOCK, ROWLOCK)
    SET minpositiontaking = @min_v162positiontaking_1101
    WHERE custid = @custid AND sporttype = 162 AND bettype = 1101


    IF @roleid = 4
    BEGIN
        --EXEC Acc_CustomerUpdSuperLiveCS_MinPositiontaking @srecommend = @custid
                                EXEC [Acc_CustSetting3rd_04] @srecommend = @custid, @roleid = 4, @mode = 'LiveCasino'
    END

    IF @roleid = 3
    BEGIN
        --EXEC Acc_CustomerUpdMasterLiveCS_MinPositiontaking @custid = @custid, @srecommend = @UplineID
                                EXEC [Acc_CustSetting3rd_04] @custid = @custid, @srecommend = @UplineID, @roleid = 3, @mode = 'LiveCasino'
    END

    IF @roleid = 2
    BEGIN
        --EXEC Acc_CustomerUpdAgentLiveCS_MinPositiontaking @custid = @custid, @mrecommend = @UplineID
                                EXEC [Acc_CustSetting3rd_04] @custid = @custid, @mrecommend = @UplineID, @roleid = 2, @mode = 'LiveCasino'
    END

    DECLARE @LogSPData VARCHAR(MAX),
            @TrackingValueDB VARCHAR(4000)
            
    SELECT @LogSPData = '<Acc_CustOverrideUpdLiveCS custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v162positiontaking_1101="' + COALESCE(CAST(@min_v162positiontaking_1101 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

    SELECT @TrackingValueDB = '<Acc_CustOverrideUpdLiveCS custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v162positiontaking_1101="' + COALESCE(CAST(@old_min_v162positiontaking_1101 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
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
            @ActionID = 503,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH
        SELECT @LogSPData = '<Acc_CustOverrideUpdLiveCS custid="' + COALESCE(CAST(@custid AS VARCHAR(30)), SPACE(1)) + '" ' +
        'min_v162positiontaking_1101="' + COALESCE(CAST(@min_v162positiontaking_1101 AS VARCHAR(30)), SPACE(1)) + '" ' + 
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 503,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH


GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdLiveCS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdLiveCS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpdLiveCS] TO [vnteam] AS [dbo]