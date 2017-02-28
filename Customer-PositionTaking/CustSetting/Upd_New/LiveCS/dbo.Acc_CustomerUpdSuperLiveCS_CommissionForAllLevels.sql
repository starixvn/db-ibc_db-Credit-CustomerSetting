USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels]    Script Date: 06/10/2015 16:04:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels    Script Date: 8/28/2014 2:05:18 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels    Script Date: 8/21/2014 2:58:08 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels    Script Date: 12/5/2013 5:35:49 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels]
    @custid        INT,
    @v162discount_1101        DECIMAL(9,8),
    @IP            VARCHAR(50)='',    
    @UserID        INT = 0,    
    @ErrCode    INT = 0 OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20130221@Dan
Task : update live casino commission for super and all downlines
DB: DBTXN/bodb02
Original:

Revisions:    
    - 20131118@Kathy: Apply exec rep [Redmine:#3244]
    - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]

Param's Explanation:
    • @custid: super id.   
    • @@v162discount_1101: commission to apply

*/
SET NOCOUNT ON

DECLARE @startRun DATETIME
DECLARE @endRun DATETIME
DECLARE @duration INT
SET @startRun = GETDATE()

--Check permission for account site
EXEC DBPOLICY.bodb02.dbo.Acc_Con_CheckPermission @custid=@UserID,@funcname='[UpdateLiveCasinoComm]',@ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
If @ErrCode <> 0
    RETURN
    
--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end

DECLARE @roleid tinyint
SELECT @roleid = roleid
FROM custinfo WITH (NOLOCK)
WHERE custid=@custid

-- check customer is super
IF ISNULL(@RoleID,0) <> 4
BEGIN
    SELECT @ErrMsg = 'Invalid user!', @ErrCode = 101
    RETURN
END

--validate commision
IF (@v162discount_1101<0.02 OR @v162discount_1101 > 0.027)
BEGIN
    SELECT @ErrMsg = 'Invalid commission (from 0.02 to 0.027)!', @ErrCode = 100
    RETURN
END

-- Check Allowed downlines during peak hour at weekend 
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

DECLARE @db_v162discount_1101 DECIMAL(9,8)

--get old value to write log
SELECT @db_v162discount_1101 = sdiscount 
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

    -- exec rep
EXEC Acc_CustSetting3rd_06
    @CustId = @custid,
    @RoleId = @roleid,
    @v162discount_1101 = @v162discount_1101,-- Live Casino
    @mode = 'LiveCasinoUpdAll'


-- write log
Declare @LogSPData varchar(8000),
        @TrackingValueDB varchar(8000)
     
SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

BEGIN TRY
    --Log customer info 
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 228,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH
    SELECT @LogSPData = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" />'


    SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(ERROR_NUMBER() AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ COALESCE(CAST(ERROR_MESSAGE() AS VARCHAR(4000)),SPACE(1)) + '" />'

    --Log customer info 
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 228,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperLiveCS_CommissionForAllLevels] TO [vnteam] AS [dbo]