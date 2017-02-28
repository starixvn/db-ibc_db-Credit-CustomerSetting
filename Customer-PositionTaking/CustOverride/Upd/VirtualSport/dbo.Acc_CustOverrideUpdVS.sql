USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustOverrideUpdVS]    Script Date: 06/10/2015 17:24:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdVS    Script Date: 8/28/2014 2:05:06 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdVS    Script Date: 8/21/2014 3:12:18 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdVS    Script Date: 8/21/2014 2:58:06 PM ******/

/****** Object:  Stored Procedure dbo.Acc_CustOverrideUpdVS    Script Date: 12/5/2013 5:35:45 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustOverrideUpdVS] 
    @custid int,
    @sporttype tinyint,
    @bettype int,
    
    @positiontaking_min smallmoney = 0,
    @positiontaking_max smallmoney = 0.9,    
    
    @UpdateMinPos bit = 1,
    @UpdateMaxPos bit = 1,
    
    @language varchar(2) = 'E',
    @UserID int = 0,
    @SubAccID int = 0, --Sub-AccountID
    @WriteLog bit = 1,
    @IP varchar(15)='',
    @ErrCode int = 0 OUTPUT,
    @ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
    Created: 20120803@Dan
    Task : Update CustOverride for VS
    DB: DBTXN/bodb02
    Original: [Acc_CustOverrideUpd], Acc_CustOverrideUpdHR

    Revisions:
        - 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
        - 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
        - 20131029@Elodie: Apply execrep when update min/max pt on master or agent
        - 20131112@Johnson: change to use execrep Acc_CustSetting3rd_04 instead of Acc_CustSetting3rd_00 for updating min pt on super
        - 20131203@Johnson: Pass param @sporttype, @bettype when call sp Acc_CustSetting3rd_04 for super
        - 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]
    Param's Explanation:
    • @ErrCode:
        = 0: Update successfully.
        > 0: Specific Error.
      
    • @ErrMsg: Error description.
*/
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

--Check disable user
EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
if @ErrCode <>0 return
--end
Declare @maxpos smallmoney 
Declare @roleid int, @srecommend int, @mrecommend int, @recommend int
select @roleid = roleid, @srecommend=srecommend, @mrecommend=mrecommend, @recommend=recommend from customer with (NOLOCK) where custid = @custid
select @maxpos = 0.9 --Max posistion for VS = 0.9
----------------------------------------------------------------------------------------------------
declare @IsValid bit, @totalDownlines int 
declare @ErrAcc varchar(4000)


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


--Check Old_minmax <> New_minmax
Declare      
    @old_minpositiontaking smallmoney,
    @old_maxpositiontaking smallmoney
    
    --Get Old data
    select @old_minpositiontaking = minpositiontaking, @old_maxpositiontaking = maxpositiontaking 
    from CustOverride3rd with (NOLOCK) 
    where custid = @custid and sporttype=@sporttype and bettype = @bettype
    
--Check Old_minmax = New_minmax
IF (@UpdateMinPos = 0 or @positiontaking_min = @old_minpositiontaking )
    and ( @UpdateMaxPos = 0 or @positiontaking_max = @old_maxpositiontaking )
BEGIN
    return
END


--Check param
--1.Check values:
if @UpdateMinPos = 0
BEGIN
    select @positiontaking_min = minpositiontaking 
    from CustOverride3rd with (NOLOCK) 
    where custid = @custid and sporttype=@sporttype and bettype = @bettype    
END
if @UpdateMaxPos = 0
BEGIN    
    select @positiontaking_max = maxpositiontaking 
    from CustOverride3rd with (NOLOCK) 
    where custid = @custid and sporttype=@sporttype and bettype = @bettype        
END

Select @isvalid = 1
if @UpdateMinPos=1
BEGIN
    if (@positiontaking_min <0 or @positiontaking_min > @maxpos)    
    BEGIN
        select @isvalid = 0, @ErrCode = 101
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong min position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30001,@Language)
                    end
        return
    END
END

if @UpdateMaxPos=1
BEGIN
    if (@positiontaking_max <0 or @positiontaking_max > @maxpos)    
    BEGIN
        select @isvalid = 0, @ErrCode = 102
        Select @ErrMsg =     case @Language 
                            when 'E' then 'Wrong max position taking.'
                            ELSE [dbo].[f_Get_MsgNamebyMsgID](30002,@Language)
                    end
        return
    END
END

if (@positiontaking_min > @positiontaking_max)
BEGIN
    select @isvalid = 0, @ErrCode = 103
    Select @ErrMsg =     case @Language 
                        when 'E' then 'Wrong min/max position taking.'
                        ELSE [dbo].[f_Get_MsgNamebyMsgID](30003,@Language)
                end
    return
END

--End check param
if @ErrCode <> 0
BEGIN
    return
END

----------------------------------------------------------------------------------------------------
declare @logdata nvarchar(300)

if @UpdateMinPos = 1
BEGIN    
    Update CustOverride3rd with (ROWLOCK, UPDLOCK) 
    set minpositiontaking = b.minpositiontaking
    from CustOverride3rd as co inner join     
            (
                select     @custid as custid,  @sporttype as sporttype, @bettype as bettype, @positiontaking_min as minpositiontaking    
            ) as b on co.custid = b.custid and co.sporttype=b.sporttype and co.bettype = b.bettype
    where co.custid = @custid
END

if @UpdateMaxPos = 1
BEGIN
    Update CustOverride3rd with (ROWLOCK, UPDLOCK) 
    set maxpositiontaking = b.maxpositiontaking
    from CustOverride3rd as co inner join     
            (
                select     @custid as custid,  @sporttype as sporttype, @bettype as bettype, @positiontaking_max as maxpositiontaking    
            ) as b on co.custid = b.custid and co.sporttype=b.sporttype and co.bettype = b.bettype
    where co.custid = @custid    
END

if @roleid = 2
BEGIN    
                EXEC dbo.Acc_CustSetting3rd_04 @recommend = @recommend, @mrecommend = @mrecommend, @srecommend = @srecommend, @mode = 'virtual-sports', @sporttype = @sporttype, @bettype = @bettype, @roleid = 2

    -- The minimum position taking value of agent was modified by agent's upline
    EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID    
END
ELSE IF @roleid = 3
BEGIN    
                EXEC dbo.Acc_CustSetting3rd_04 @mrecommend = @mrecommend, @srecommend = @srecommend, @mode = 'virtual-sports', @sporttype = @sporttype, @bettype = @bettype, @roleid = 3

END
ELSE IF @roleid= 4 and @UpdateMinPos = 1 
BEGIN    
                EXEC dbo.Acc_CustSetting3rd_04 @srecommend = @srecommend, @roleid = 4, @mode = 'virtual-sports', @sporttype = @sporttype, @bettype = @bettype
END
ELSE IF @roleid= 4 and @WriteLog = 1 and @UpdateMaxPos = 1 -- process like SB, not correct when changing preset
BEGIN    
    EXEC dbo.Acc_CustSetting3rd_01 @srecommend = @srecommend, @mode = 'virtual-sports'
END

if @WriteLog = 1
BEGIN
    Declare @LogSPData varchar(MAX),
            @TrackingValueDB varchar(4000)
            
    Select @LogSPData = '<Acc_CustOverrideUpdVS><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
    'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +    
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minpt="'+ coalesce(cast(@positiontaking_min as varchar(50)),space(1)) + '" ' +
    'maxpt="'+ coalesce(cast(@positiontaking_max as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdVS>'
    
    
    Select @TrackingValueDB = '<Acc_CustOverrideUpdVS><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
    'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +    
    'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
    'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
    'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
    'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
    'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />' +
    
    '<MinMaxPT minpt="'+ coalesce(cast(@old_minpositiontaking as varchar(50)),space(1)) + '" ' +
    'maxpt="'+ coalesce(cast(@old_maxpositiontaking as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdVS>'
    
    set @endRun = getdate()
    set @duration  = datediff (millisecond,@startRun,@endRun)
    
    --Write log
    BEGIN TRY
        EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 504,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END TRY
    BEGIN CATCH                
        Select @LogSPData = '<Acc_CustOverrideUpdVS><info custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
        'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
        'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +    
        'UpdMinPos="'+ coalesce(cast(@UpdateMinPos as varchar(50)),space(1)) + '" ' +
        'UpdMaxPos="'+ coalesce(cast(@UpdateMaxPos as varchar(50)),space(1)) + '" ' +
        'language="'+ coalesce(cast(@language as varchar(2)),space(1)) + '" ' +
        'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
        'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
        'WriteLog="'+ coalesce(cast(@WriteLog as varchar(50)),space(1)) + '" ' +
        'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
        'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
        'ErrMsg="'+ ERROR_MESSAGE() + '" />' +
        
        '<MinMaxPT minpt="'+ coalesce(cast(@positiontaking_min as varchar(50)),space(1)) + '" ' +
        'maxpt="'+ coalesce(cast(@positiontaking_max as varchar(50)),space(1)) + '" /></Acc_CustOverrideUpdVS>'
        
        EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
            @UserID = @UserID,
            @CustID = @CustID,
            @ActionID = 504,
            @TrackingValue = @LogSPData,
            @TrackingValue2 = @TrackingValueDB,
            @duration = @duration
    END CATCH

END

GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdVS] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdVS] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustOverrideUpdVS] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustOverrideUpdVS] TO [vnteam] AS [dbo]