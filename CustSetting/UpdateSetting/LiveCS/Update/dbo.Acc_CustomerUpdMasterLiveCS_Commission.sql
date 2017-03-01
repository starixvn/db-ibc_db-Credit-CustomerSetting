ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterLiveCS_Commission]
    @custid        INT,
    @v162discount_1101        DECIMAL(9,8),
    
    @SubAccID   INT  = 0,
    @IP            VARCHAR(50)='',    
    @UserID        INT = 0,
    @Language    VARCHAR(20) = 'E',        
    @ErrCode    INT = 0 OUTPUT,
    @ErrMsg        NVARCHAR(4000) = '' OUTPUT
AS
    /*
        Created: Johnson
        Date: 04Jan2012
        DB: DBTXN/BODB02
        Task: Update commission on master
        
        Revisions:
            - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
            - 20130301@Johnson: write log on DBTXN if DBLOG failure
            - 20131031@Kathy: Apply exec rep to update commission [Redmine:#3244]
			- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
        Parameters Explanation:
    */
SET NOCOUNT ON

DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT

SET @startRun = GETDATE()

DECLARE @roleid TINYINT, @ErrCode_Cur INT, @ErrMsg_Cur NVARCHAR(4000), @ErrAcc NVARCHAR(4000),
    @db_v162discount_1101 DECIMAL(9,8)
    
SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = 0, @ErrMsg = ''

---------------------------
-- ***Check Downline Belonging***
--EXEC DB053.bodb02.dbo.Age_CustomerSelCheckBelonging 
--    @SessionCustID = @Userid, 
--    @Custid = @custid,
--    @roleid = @roleid OUTPUT
--    IF (@roleid = 0) RETURN
---------------------------

--Check disable user
--EXEC DB053.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
--IF @ErrCode_Cur > 0
--BEGIN
--    select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
--            @ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
--    return
--END
--end
SELECT @db_v162discount_1101 = adiscount
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

IF @v162discount_1101 = @db_v162discount_1101
    RETURN 
    
IF @v162discount_1101 < 0 OR @v162discount_1101 > 0.01
BEGIN
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate.'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
                END, @ErrCode = 100
    RETURN
END

---------------------------------------
DECLARE @srecommend INT, @username NVARCHAR(50)

SELECT @srecommend = srecommend , @username = username, @roleid = roleid
FROM CustInfo WITH(NOLOCK)
WHERE custid = @custid

--Check Allowed downlines    
EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
            @roleid=@roleid,
            @isExecRep=1,
            @isUpdatePT = 1,
            @Sporttype = 1,
            @Language='E',
            @ErrMsg=@ErrMsg output,
            @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 
        
SELECT @v162discount_1101 = CASE WHEN @v162discount_1101 > sdiscount THEN sdiscount ELSE @v162discount_1101 END
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @srecommend AND sporttype = 162 AND bettype = 1101

-- Apply exec rep
                EXEC Acc_CustSetting3rd_06
    @CustId = @custid,
    @RoleId = @roleid,
    @v162discount_1101 = @v162discount_1101,
    @mode = 'LiveCasino'
    
Declare @LogSPData varchar(MAX),
        @TrackingValueDB varchar(4000)
     
SELECT @LogSPData = '<Acc_CustomerUpdMasterLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
'v162discount_1101="' + COALESCE(CAST(@db_v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


SET @endRun = GETDATE()
SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

--Log customer info 
BEGIN TRY
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 225,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH
    SELECT @LogSPData = '<Acc_CustomerUpdMasterLiveCS_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
    'v162discount_1101="' + COALESCE(CAST(@v162discount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
    'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
    'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
    'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
    'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 225,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH


GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterLiveCS_Commission] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Commission] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Commission] TO [bodbDownlineNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterLiveCS_Commission] TO [bodbExtAccNet]
GO 
