USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuper_CommissionHR]    Script Date: 06/10/2015 15:24:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_CommissionHR    Script Date: 8/28/2014 2:05:11 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_CommissionHR    Script Date: 8/21/2014 3:12:19 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_CommissionHR    Script Date: 8/21/2014 2:58:08 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustomerUpdSuper_CommissionHR    Script Date: 12/5/2013 5:35:48 PM ******/

ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuper_CommissionHR]
    @custid INT,-- superid
    @v151discount_31 DECIMAL(9,8),--commission for tote.
    @v151discount_41 DECIMAL(9,8),--commission for FO.    

    @v151discount_51 DECIMAL(9,8) = 0,
    @v152discount_41 DECIMAL(9,8) = 0,
    @v152discount_51 DECIMAL(9,8) = 0,
    @v153discount_51 DECIMAL(9,8) = 0,

    @UserID INT = 0,    
    @Language VARCHAR(2) = 'E',
    @IP VARCHAR(15)='',
    @ErrCode INT = 0 OUTPUT,
    @ErrMsg NVARCHAR(4000) = '' OUTPUT
AS

/*
Created: 20081023@VinhTruong
Task : Update Super's commission for Horseracing.
DB: DBTXN/bodb02

Revisions:
    - 20090515@Phuc: commission for tote and fixed odds.
    - 20090917@Phuc: write log into DBLOG.
    - 20091201@Kiwi: Move custsetting to the separated table CustSetting3rd.
    - 20100112@Phuc: hardcode not to update commission for member under agent 8RM.
    - 20100112@Kiwi: Amend to write log in xml format.
    - 20101019@Henry: Record execution time
    - 20110111@Lukas: Add setting
                        + AU Horse racing
                        + UK, AU Greyhound racing
                        + AU Harness racing
    - 20110509@Lukas: Add message translation(Thai version)
    - 20110511@Johnson: Write log for old setting values
    - 20120412@Hurri: hardcode not to update commission for member under agent BARM.
    - 20120522@Sophia: Remove hardcode not to update commission for member under agent BARM.
    - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130227@Johnson: write log on DBTXN if DBLOG failure
    - 20131030@Kathy: Apply exec rep to update commission [Redmine:#3244]
    - 20150609@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]
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
EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
            @roleid=4,--@roleid,
            @isExecRep=1,
            @isUpdatePT = 1,
            @Sporttype = 1,
            @Language='E',
            @ErrMsg=@ErrMsg output,
            @ErrCode=@ErrCode output
IF    @ErrCode <> 0 
    RETURN 
    
    
IF @v151discount_31 <0 OR @v151discount_31 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (SA Tote).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](2,@Language)
                END, @ErrCode = 101
    RETURN
END
IF @v151discount_41 <0 OR @v151discount_41 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (UK/Irish Tote).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](3,@Language)
                END, @ErrCode = 102
    RETURN
END
IF @v151discount_51 < 0 OR @v151discount_51 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (Aust Tote).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](4,@Language)
                END, @ErrCode = 103
    RETURN
END
IF @v152discount_41 < 0 OR @v152discount_41 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (UK/Irish Greyhounds).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](5,@Language)
                END, @ErrCode = 104
    RETURN
END
IF @v152discount_51 < 0 OR @v152discount_51 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (Aust Greyhound).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](6,@Language)
                END, @ErrCode = 105
    RETURN
END
IF @v153discount_51 < 0 OR @v153discount_51 > 0.01
BEGIN    
    SELECT @ErrMsg =     CASE @Language 
                        WHEN 'E' THEN 'Invalid commission rate (Aust Harness).'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](7,@Language)
                END, @ErrCode = 106
    RETURN
END

DECLARE @db_v151discount_31 DECIMAL(9,8) , 
        @db_v151discount_41 DECIMAL(9,8),
        @db_v151discount_51 DECIMAL(9,8),
        @db_v152discount_41 DECIMAL(9,8),
        @db_v152discount_51 DECIMAL(9,8),
        @db_v153discount_51 DECIMAL(9,8)

SELECT @db_v151discount_31 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 31 AND sporttype = 151
SELECT @db_v151discount_41 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 AND sporttype = 151
SELECT @db_v151discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 151
SELECT @db_v152discount_41 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 41 AND sporttype = 152
SELECT @db_v152discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 152
SELECT @db_v153discount_51 =  sdiscount FROM CustSetting3rd WITH (NOLOCK) WHERE custid = @custid AND bettype = 51 AND sporttype = 153

-- Check whether user updates or not - RETURN if not change commission
IF    @db_v151discount_31 = @v151discount_31 
    AND 
    @db_v151discount_41 = @v151discount_41 
    AND 
    @db_v151discount_51 = @v151discount_51
    AND 
    @db_v152discount_41 = @v152discount_41
    AND 
    @db_v152discount_51 = @v152discount_51
    AND 
    @db_v153discount_51 = @v153discount_51
    
    RETURN 

-- Apply exec rep
DECLARE @RoleId int
SELECT @RoleId = roleid
FROM custInfo with(NOLOCK)
WHERE custid = @custid 

EXEC dbo.Acc_CustSetting3rd_06
    @CustId = @custid,
    @RoleId = @RoleId,
    @v151discount_31 = @v151discount_31,
    @v151discount_41 = @v151discount_41, 
    @v151discount_51 = @v151discount_51,
    @v152discount_41 = @v152discount_41,
    @v152discount_51 = @v152discount_51,
    @v153discount_51 = @v153discount_51,
    @mode = 'HorseRacing'


Declare @LogSPData varchar(MAX),
        @TrackingValueDB varchar(4000)
        
Select @LogSPData = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

SELECT @TrackingValueDB = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'v151discount_31="'+ coalesce(cast(@db_v151discount_31 as varchar(50)),space(1)) + '" ' +
'v151discount_41="'+ coalesce(cast(@db_v151discount_41 as varchar(50)),space(1)) + '" ' +
'v151discount_51="'+ coalesce(cast(@db_v151discount_51 as varchar(50)),space(1)) + '" ' +
'v152discount_41="'+ coalesce(cast(@db_v152discount_41 as varchar(50)),space(1)) + '" ' +
'v152discount_51="'+ coalesce(cast(@db_v152discount_51 as varchar(50)),space(1)) + '" ' +
'v153discount_51="'+ coalesce(cast(@db_v153discount_51 as varchar(50)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
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
        @ActionID = 209,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END TRY
BEGIN CATCH    
    Select @LogSPData = '<Acc_CustomerUpdSuper_CommissionHR custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'v151discount_31="'+ coalesce(cast(@v151discount_31 as varchar(50)),space(1)) + '" ' +
    'v151discount_41="'+ coalesce(cast(@v151discount_41 as varchar(50)),space(1)) + '" ' +
    'v151discount_51="'+ coalesce(cast(@v151discount_51 as varchar(50)),space(1)) + '" ' +
    'v152discount_41="'+ coalesce(cast(@v152discount_41 as varchar(50)),space(1)) + '" ' +
    'v152discount_51="'+ coalesce(cast(@v152discount_51 as varchar(50)),space(1)) + '" ' +
    'v153discount_51="'+ coalesce(cast(@v153discount_51 as varchar(50)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" />'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
        @UserID = @UserID,
        @CustID = @CustID,
        @ActionID = 209,
        @TrackingValue = @LogSPData,
        @TrackingValue2 = @TrackingValueDB,
        @duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuper_CommissionHR] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuper_CommissionHR] TO [vnteam] AS [dbo]