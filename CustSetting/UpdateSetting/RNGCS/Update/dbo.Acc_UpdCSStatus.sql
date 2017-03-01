USE [CustDB]
GO
ALTER PROCEDURE [dbo].[Acc_UpdCSStatus]
    @custid INT,
    @disabledCS BIT=NULL,
    @syncCS BIT=NULL,
    @enableDownline BIT=0,
    @status BIT = 1 OUTPUT,
    
    @ErrMsg NVARCHAR(200) = '' OUTPUT,    
    @ErrCode INT = 0 OUTPUT,    
    
    @UserID INT = 0,
    @SubAccID INT = 0, --Sub-AccountID
    @LoginIP VARCHAR(20)='',
    @Language VARCHAR(2) = 'E'
AS
/*

Created: 20090310@QuiNV
Task: Update casino status
DB: DBTXN/bodb02
Original:

   Revisions:
    - 20090421@Lee: Add params and add write log section.
    - 20090729@Phuc: write log subaccname instead of subaccid.
    - 20090801@Shifu: check disabled user
    - 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
    - 20090402@Phuc: write log into dblog.
    - 20100105@Hanh: Replace Chinese language.
    - 20100114@Simon: Update disable status for Casino.
    - 20100115@Kiwi: amend to write log in xml format.
    - 20101015@Jamie: update input @syncCS (Casino update setting failed)
    - 20101021@Henry: Record execution time
    - 20110526@Henry: Check Upline Disable Casino, if Upline is disabled then raise error
    - 20110531@Amy: Check Old/New value
    - 20110615@Amy: Add more check condition to allow create member automatically
    - 20110710@Thien: split/amend the update command to fix the clustered index scan
    - 20110709@Johnson: Change to use new server BD053 instead DB052
    - 20121206@Scott : Check Allowed downlines during peak hour at weekend   
    - 20130124@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
    - 20130128@Scott : add more parameter  @ErrCode  
    - 20130301@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
    - 20130709@Jamie: Apply Exec Rep 
    - 20130827@Johnson: check enabled status on DBTXN instead of DBAGE
    - 20130808@Elodie: Splitting DBTXN into DBCUST (call Acc_ExecRep_Cust_04 instead of Acc_ExecRep_04)
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
    
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


BEGIN TRY

-- Checking

DECLARE @Allow2Udpate BIT, @SyncCasino BIT ,@RoleID TINYINT, @UplineSyncCS BIT, @UplineEnableCS BIT, @Old_disabledCS BIT
SELECT @SyncCasino=SyncCasino,@RoleID=RoleID, @Old_disabledCS=DisableCasino FROM custinfo(NOLOCK) WHERE custid=@custid
IF(@RoleID IS NULL OR @roleid > 4) 
BEGIN
    SELECT @status=0, @ErrCode=101 ,@ErrMsg = CASE @Language WHEN 'E' THEN 'Account does not exist or invalid customer account'
                                                ELSE [dbo].[f_Get_MsgNamebyMsgID](40019,@Language) END
    RETURN
END


IF @SyncCasino = 0  AND @syncCS = 0 AND @disabledCS = 0
BEGIN
    SELECT @status=0, @ErrCode=102 ,@ErrMsg = CASE @Language WHEN 'E' THEN 'Cannot enable Casino for this account due to lack of settings.'
                                                ELSE [dbo].[f_Get_MsgNamebyMsgID](60026,@Language) END                    
    RETURN
END


-- Check Allowed downlines during peak hour at weekend
IF @disabledCS = 1 OR @enableDownline = 1
BEGIN
    
    EXEC DBAGE.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines    @custid=@custid,
                                            @roleid=@roleid,
                                            @isExecRep=1, -- Apply Exec Rep 
                                            @Language=@Language,
                                            @ErrMsg=@ErrMsg output,
                                            @ErrCode=@ErrCode output
    IF @ErrCode <>0 RETURN
END
--End 

IF(@roleid = 4)
    SELECT @Allow2Udpate=1
ELSE
BEGIN
    SELECT @UplineSyncCS = ISNULL((SyncCasino),0), @UplineEnableCS = case when DisableCasino = 0 then 1 else 0 end
    FROM custinfo(NOLOCK)
    WHERE
    custid = (SELECT CASE roleid WHEN 1 THEN recommend
                                WHEN 2 THEN mrecommend
                                WHEN 3 THEN srecommend END
          FROM custinfo(NOLOCK) WHERE custid=@custid)
    
    IF @UplineSyncCS = 1 AND (@UplineEnableCS = 1 or (@UplineEnableCS = 0 and @disabledCS=1))
        SET @Allow2Udpate=1
    ELSE
        SET @Allow2Udpate=0
END
    

IF @Allow2Udpate = 0
BEGIN
    SELECT @status=0, @ErrCode=103 , @ErrMsg = CASE @Language WHEN 'E' THEN 'Cannot enable Casino because the upline either has Casino disaled or does not have any settings.'
                                                ELSE [dbo].[f_Get_MsgNamebyMsgID](60027,@Language) END                            
    RETURN
END

IF @Old_disabledCS = @disabledCS AND @SyncCasino = @syncCS RETURN


-- Update itself
UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET
    DisableCasino = ISNULL(@disabledCS, DisableCasino),
    SyncCasino = @syncCS --CASE @syncCS WHEN 1 THEN 1 ELSE SyncCasino END
WHERE custid=@custid

--    Update downline
--    20130709@Jamie: Apply ExecRep 
IF (@disabledCS = 1 OR @enableDownline = 1) AND @RoleID BETWEEN 2 AND 4 
BEGIN
    EXEC [Acc_CustomerInfo_Execrep_04]
         @CustID        = @CustID
        ,@RoleID        = @RoleID
        ,@Action        = 'disabledCS'
        ,@disabledCS    = @disabledCS
END 

SELECT @status = 1
    
END TRY

BEGIN CATCH
    SELECT @status = 0
END CATCH



--Log data
--Log data
DECLARE @LogData NVARCHAR(MAX)
DECLARE @TrackingValue2 NVARCHAR(200)
---------------------------
select @LogData ='<Acc_UpdCSStatus custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'disabledCS="'+ coalesce(cast(@disabledCS as varchar(50)),space(1)) + '" ' +
'syncCS="'+ coalesce(cast(@syncCS as varchar(50)),space(1)) + '" ' +
'enableDownline="'+ coalesce(cast(@enableDownline as varchar(50)),space(1)) + '" ' +
'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'LoginIP="'+ coalesce(cast(@LoginIP as varchar(20)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'

select @TrackingValue2 ='<Acc_UpdCSStatus custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
'disabledCS="'+ coalesce(cast(@Old_disabledCS as varchar(50)),space(1)) + '" ' +
'syncCS="'+ coalesce(cast(@SyncCasino as varchar(50)),space(1)) + '" ' +
'enableDownline="'+ coalesce(cast(@enableDownline as varchar(50)),space(1)) + '" ' +
'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
'LoginIP="'+ coalesce(cast(@LoginIP as varchar(20)),space(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'

set @endRun = getdate()
set @duration  = datediff (millisecond,@startRun,@endRun)

BEGIN TRY
    EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
        @UserID = @UserID, 
        @CustID = @custid,
        @ActionID = 1109,
        @TrackingValue = @LogData,
        @TrackingValue2 = @TrackingValue2,
        @duration = @duration
END TRY
BEGIN CATCH
    select @LogData ='<Acc_UpdCSStatus custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
    'disabledCS="'+ coalesce(cast(@disabledCS as varchar(50)),space(1)) + '" ' +
    'syncCS="'+ coalesce(cast(@syncCS as varchar(50)),space(1)) + '" ' +
    'enableDownline="'+ coalesce(cast(@enableDownline as varchar(50)),space(1)) + '" ' +
    'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
    'ErrMsg="'+ ERROR_MESSAGE() + '" ' +
    'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
    'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
    'LoginIP="'+ coalesce(cast(@LoginIP as varchar(20)),space(1)) + '" ' +
    'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'
    
    EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
        @UserID = @UserID, 
        @CustID = @custid,
        @ActionID = 1109,
        @TrackingValue = @LogData,
        @TrackingValue2 = @TrackingValue2,
        @duration = @duration
END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_UpdCSStatus] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_UpdCSStatus] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_UpdCSStatus] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_UpdCSStatus] TO [vnteam] AS [dbo]