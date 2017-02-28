ALTER PROCEDURE [dbo].[Acc_CustomerUpdMaster_CommissionHR]
    @custid INT,-- masterId
    @v151discount_31 DECIMAL(9,8),--commission for tote.
    @v151discount_41 DECIMAL(9,8),--commission for OT.
    @v151discount_51 DECIMAL(9,8)=0, --comm for HR AU
    @v152discount_41 DECIMAL(9,8)=0, --comm for Greyhound UK
    @v152discount_51 DECIMAL(9,8)=0, --comm for Greyhound AU
    @v153discount_51 DECIMAL(9,8)=0, --comm for Harness AU
    
    @UpdateMultiple BIT = 0,
    @Updatediscountv151_31 BIT = 1,
    @Updatediscountv151_41 BIT = 1,
    @Updatediscountv151_51 BIT = 1,
    @Updatediscountv152_41 BIT = 1,
    @Updatediscountv152_51 BIT = 1,    
    @Updatediscountv153_51 BIT = 1,    
        
    @SubAccID INT = 0, --Sub-AccountID
    @UserID INT = 0,    
    @Language VARCHAR(2) = 'E',
    @IP VARCHAR(15)='',
    @ErrCode INT = 0 OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
Created: 20081023@VinhTruong
Task : Update Master's commission for Horseracing
DB: DBTXN/bodb02

Revisions:
    - 20090515@Phuc: commission for tote and fixed odds.
                    Write log subaccname instead of subaccid.
    - 20090917@Phuc: write log into DBLOG.
    - 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
    - 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
    - 20100112@Kiwi: amend to write log in xml format.
    - 20101019@Henry: Record execution time
    - 20110113@Henry: Update Comm for Greyhound and Harness
    - 20110509@Johnson: Update error message for Thai Version
    - 20110516@Johnson: write log for old setting
    - 20111104@TOM: Apply Multiple Edit Racing PT.
    - 20120412@Hurri: hardcode not to update commission for member under agent BARM.
    - 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130226@Johnson: write log on DBTXN if DBLOG failure
    - 20131030@Kathy: Apply exec rep to update commission [Redmine:#3244]
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)

Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/

SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check Allowed downlines    
EXEC Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
            @roleid=3,--@roleid,
            @isExecRep=1,
            @isUpdatePT = 1,
            @Sporttype = 1,
            @Language='E',
            @ErrMsg=@ErrMsg output,
            @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 
    
--Check Param
if (@UpdateMultiple = 0 or @Updatediscountv151_31 = 1 or @Updatediscountv151_41 = 1 or @Updatediscountv151_51 = 1)
BEGIN --@Updatediscountv151
    IF (@v151discount_31 < 0 OR @v151discount_31 > 0.01) and @Updatediscountv151_31 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (SA Tote).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](2,@Language)
                    END, @ErrCode = 101
        RETURN
    END

    IF (@v151discount_41 < 0 OR @v151discount_41 > 0.01) and @Updatediscountv151_41 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (UK/Irish Tote).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](3,@Language)
                    END, @ErrCode = 101
        RETURN
    END
    IF (@v151discount_51 < 0 OR @v151discount_51 > 0.01) and @Updatediscountv151_51 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (Aust Tote).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](4,@Language)
                    END, @ErrCode = 101
        RETURN
    END
END--@Updatediscountv151

if (@UpdateMultiple = 0 or @Updatediscountv152_41 = 1 or @Updatediscountv152_51 = 1)
BEGIN --@Updatediscountv152
    IF (@v152discount_41 < 0 OR @v152discount_41 > 0.01) and @Updatediscountv152_41 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (UK/Irish Greyhounds).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](5,@Language)
                    END, @ErrCode = 101
        RETURN
    END
    IF (@v152discount_51 < 0 OR @v152discount_51 > 0.01) and @Updatediscountv152_51 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (Aust Greyhound).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](6,@Language)
                    END, @ErrCode = 101
        RETURN
    END
END--@Updatediscountv152

if (@UpdateMultiple = 0 or @Updatediscountv153_51 = 1)
BEGIN --@Updatediscountv153
    IF (@v153discount_51 < 0 OR @v153discount_51 > 0.01) and @Updatediscountv153_51 = 1
    BEGIN        
        SELECT @ErrMsg =     CASE @Language 
                            WHEN 'E' THEN 'Invalid commission rate (Aust Harness).'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](7,@Language)
                    END, @ErrCode = 101
        RETURN
    END
END --@Updatediscountv153



---------------------------------------
DECLARE @srecommend INT, @username VARCHAR(40), 
    @db_v151discount_31 DECIMAL(9,8), @db_v151discount_41 DECIMAL(9,8),
    @db_v151discount_51 DECIMAL(9,8), @db_v152discount_41 DECIMAL(9,8),
    @db_v152discount_51 DECIMAL(9,8), @db_v153discount_51 DECIMAL(9,8)
SELECT @username = username,
    @srecommend = srecommend
FROM custinfo WITH (NOLOCK)
WHERE custid = @custid AND roleid = 3

SELECT @db_v151discount_31 = ISNULL(adiscount,0)    -- @db_v151discount_31
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 31 and sporttype = 151

SELECT @db_v151discount_41 = ISNULL(adiscount,0)    -- @db_v151discount_41
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 41 and sporttype = 151

SELECT @db_v151discount_51 = ISNULL(adiscount,0)     -- @db_v151discount_51
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 51 and sporttype = 151

SELECT @db_v152discount_41 = ISNULL(adiscount,0)     -- @db_v152discount_41
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 41 and sporttype = 152

SELECT @db_v152discount_51 = ISNULL(adiscount,0)     -- @db_v152discount_51
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 51 and sporttype = 152

SELECT @db_v153discount_51 = ISNULL(adiscount,0)    
        FROM CustSetting3rd WITH (NOLOCK) 
        WHERE custid = @custid AND bettype = 51 and sporttype = 153

DECLARE @RoleId int
SELECT @RoleId = roleid
FROM custInfo with(NOLOCK)
WHERE custid = @custid 

if (@UpdateMultiple = 0 
    or @Updatediscountv151_31 = 1 
    or @Updatediscountv151_41 = 1 
    or @Updatediscountv153_51 = 1
    or @Updatediscountv152_41 = 1 
    or @Updatediscountv152_51 = 1
    or @Updatediscountv153_51 = 1
    )
BEGIN 
    --@@Updatediscountv151
    if (@Updatediscountv151_31 = 1)
    BEGIN
        SELECT @v151discount_31 = CASE WHEN @v151discount_31 >sdiscount THEN sdiscount ELSE @v151discount_31 END -- @v151discount_31
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype=31 AND sporttype = 151
    END
    ELSE
        SELECT @v151discount_31 = @db_v151discount_31

    if (@Updatediscountv151_41 = 1)
    BEGIN
        SELECT @v151discount_41 = CASE WHEN @v151discount_41 > sdiscount THEN sdiscount ELSE @v151discount_41 END  -- @v151discount_41
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype = 41 AND sporttype = 151
    END
    ELSE 
        SELECT @v151discount_41 = @db_v151discount_41     

    if (@Updatediscountv151_51 = 1)
    BEGIN
        SELECT @v151discount_51 = CASE WHEN @v151discount_51 > sdiscount THEN sdiscount ELSE @v151discount_51 END   -- @v151discount_51
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype = 51 AND sporttype = 151
    END
    ELSE 
        SELECT @v151discount_51 = @db_v151discount_51

    --@@Updatediscountv152
    if (@Updatediscountv152_41 = 1)
    BEGIN
        SELECT @v152discount_41 = CASE WHEN @v152discount_41 > sdiscount THEN sdiscount ELSE @v152discount_41 END  -- @v152discount_41
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype = 41 AND sporttype = 152 
    END
    ELSE 
        SELECT @v152discount_41 = @db_v152discount_41    

    if (@Updatediscountv152_51 = 1)
    BEGIN
        SELECT @v152discount_51 = CASE WHEN @v152discount_51 > sdiscount THEN sdiscount ELSE @v152discount_51 END  -- @v152discount_51
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype = 51 AND sporttype = 152
    END
    ELSE
        SELECT @v152discount_51 = @db_v152discount_51    

    --@@Updatediscountv153
    if (@Updatediscountv153_51 = 1)
    BEGIN
        SELECT @v153discount_51 = CASE WHEN @v153discount_51 > sdiscount THEN sdiscount ELSE @v153discount_51 END 
        FROM CustSetting3rd AS cs WITH (NOLOCK) 
        WHERE custid = @srecommend AND bettype = 51 AND sporttype = 153 
    END
    ELSE 
        SELECT @v153discount_51 = @db_v153discount_51    

    -- Apply exec rep
                exec dbo.Acc_CustSetting3rd_06
            @CustId = @custid,
            @RoleId = @RoleId ,
            @v151discount_31 = @v151discount_31,
            @v151discount_41 = @v151discount_41, 
            @v151discount_51 = @v151discount_51,
            @v152discount_41 = @v152discount_41,
            @v152discount_51 = @v152discount_51,
            @v153discount_51 = @v153discount_51,
            @mode = 'HorseRacing'
END 

-- Check whether user edits commission or not - If not - RETURN 
--20090305: Thien comment out the make sure the commission is updated correctly
--IF @db_UKComm = @UKComm and @db_OtherComm = @OtherComm 
--    RETURN 

---------------------------------------

---------------------------------------

Declare @LogSPData varchar(MAX),
        @TrackingValueDB varchar(4000)

Select @LogSPData = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +

'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

Select @TrackingValueDB = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@db_v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@db_v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@db_v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@db_v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@db_v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@db_v153discount_51 as varchar(50)),space(1)) + '" ' +

'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

--Log customer info 
BEGIN TRY
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 210,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH    
    Select @LogSPData = '<Acc_CustomerUpdMaster_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
    'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
    'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
    'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
    'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
    'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +

    'UpdateMultiple="'+ coalesce(cast(@UpdateMultiple as varchar(1)),space(1)) + '" ' +
    'Updatediscountv151_31="'+ coalesce(cast(@Updatediscountv151_31 as varchar(1)),space(1)) + '" ' +
    'Updatediscountv151_41="'+ coalesce(cast(@Updatediscountv151_41 as varchar(1)),space(1)) + '" ' +
    'Updatediscountv151_51="'+ coalesce(cast(@Updatediscountv151_51 as varchar(1)),space(1)) + '" ' +
    'Updatediscountv152_41="'+ coalesce(cast(@Updatediscountv152_41 as varchar(1)),space(1)) + '" ' +
    'Updatediscountv152_51="'+ coalesce(cast(@Updatediscountv152_51 as varchar(1)),space(1)) + '" ' +
    'Updatediscountv153_51="'+ coalesce(cast(@Updatediscountv153_51 as varchar(1)),space(1)) + '" ' +

    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 210,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH

GO 
 GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMaster_CommissionHR] TO [bodbDownlineNet]
GO 
