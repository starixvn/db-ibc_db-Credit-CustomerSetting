/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuspended]
	@CustID int,
	@Suspended bit,	
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@ActionID int=1104,
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(500) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20090121@Thien
Task : Update suspended
DB: DBTXN/CustDB
Original:

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090341@HanhVu: hardcode: not allow agent and master to active 2 members 'S1p0106001','S1P0106002'
    - 20090430@kIWI: ROLLBACK --and @Old_Suspended <> @Suspended
	- 20090723@Phuc: Write log subaccname instead of subaccid.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)
	- 20090917@Phuc: write log into DBLOG.
	- 20091008@Kiwi: Remove WriteLog_UserLog
	- 20091105@Hanh: Hardcode to not allow update closed status by moving Casino DB
	- 20091125@Terry : add one more para @disCasino check disabled Casino
	- 20100107@Lewin: Modify LogSPData Format, call new version write log
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101021@Henry: Record execution time
	- 20110907@Sophia: Change Linked Server from DB052 to DB053
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend  
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20130527@Elodie: Change linked server DB053 to DBAGE for Acc_CustomerSelCheckAllowedDownlines
	- 20130709@Jamie: Apply Exec Rep 
	- 20131108@Elodie: Splitting bodb02 into CustDB (call Acc_ExecRep_Cust_04 instead of Acc_ExecRep_04)	
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]
	- 20150610@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable, Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB) [Redmine:#36216]                          
	- 20160104@Helen: Disallow SMA changes password or updates account status of members - [Redmine:#49967]
	- 20190404@Johnson: add suspendinfo [redmine: #105587]
	- 20200216@Elodie: Lock close/suspend for some member [Redmine: #128541]
	- 20210505@Tina: Lock account & indirect close account [redmine: #148600]
	- 20220110@Eden: Saba Casino use DCS Setting [RedmineID: #164280]
	- 20230921@Tacy: CWL - Suspend member accounts when member reaches Yellow level on RNG Slots Games [RedmineID: #184911]
	
Param's Explanation:
• @ActionID = 1104 ~ normal flow
			<>1104 ~ CWL flow

• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN

	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	if @ErrCode <>0 return
	--end
	
	IF @UserID <> @CustID AND CURRENT_USER <> 'bodbAdminNet' 
	AND (EXISTS (SELECT 1 FROM custInfo WITH (NOLOCK) WHERE custid = @CustID AND LockUpd = 1 AND roleid = 1)
		OR (EXISTS (SELECT 1 FROM CustSuspendLockUpd WITH (NOLOCK) WHERE custid = @CustID) AND @Suspended = 0))
	BEGIN
		 SELECT  @ErrMsg = CASE @Language
                                WHEN 'E' THEN 'You are currently not authorized to perform this action. Please contact the Customer Service Department for further assistance.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](40033,@Language)
                              END ,
                 @ErrCode = 106
         RETURN
	END
	

	---hardcode: force agent or master not able to active 2 member
	Declare @custid_Edited int,@recommend int, @mrecommend int, @srecommend int
	
	select @custid_Edited=custid,@recommend=recommend, @mrecommend=srecommend
	from custinfo with (nolock) where username in ('S1p0106001','S1P0106002')
	if @custid_Edited =@CustID and (@UserID=@recommend or @UserID=@mrecommend) and @Suspended = 0
	begin
		SELECT @ErrMsg =  'This account was suspended by your upline!', @ErrCode = 105
		return
	end
	----------

	Declare @RoleID tinyint , @UplineSuspended bit , @Old_Suspended bit, @UplineClosed bit
	DECLARE @IsDeposit BIT = 0, @SuperSuspended BIT, @MasterSuspended BIT, @AgentSuspended BIT, @MemberSuspended BIT
			, @SuperClosed BIT, @MasterClosed BIT, @AgentClosed BIT, @MemberClosed BIT

	IF EXISTS (SELECT TOP 1 1 FROM dbo.custInfo ci WITH(NOLOCK)
					INNER JOIN dbo.Dep_CustSuper dep WITH(NOLOCK) ON ci.srecommend = dep.custid
			   WHERE ci.custid = @custid)
	BEGIN
		SET @IsDeposit = 1
	END

	select 
		@RoleID = RoleID, 
		@Old_Suspended = isnull(reject,0),
		@srecommend = srecommend,
		@mrecommend = mrecommend,
		@recommend = recommend
	from Custinfo with (nolock)
	where CustID = @CustID

	select @RoleID = isnull(@RoleID, 0)

	if @RoleID not in (1,2,3,4)
	BEGIN
		Select @ErrMsg = case @Language 
							when 'E' then 'Invalid user!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						end
		
		,
			@ErrCode = 100	
		return
	END
	
	-- Check Allowed downlines during peak hour at weekend 
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
												@roleid=@roleid,
												@isExecRep=1, --Use Exec Rep for UPDATE 
												@Language=@Language,
												@ErrMsg=@ErrMsg output,
												@ErrCode=@ErrCode output
	if @ErrCode <>0 return 
	--End 
	
	--Get Close status for Credit
	IF (@IsDeposit = 0)
	BEGIN
		SELECT @SuperSuspended = sp.SuperStatus, 
			   @MasterSuspended = sp.MasterStatus, 
			   @AgentSuspended = sp.AgentStatus, 
			   @MemberSuspended = sp.MemberStatus,
			   @Old_Suspended = (CASE WHEN cps.SuspendInfo > 0 THEN 1 ELSE 0 END),
			   @SuperClosed = cl.SuperStatus, 
			   @MasterClosed = cl.MasterStatus, 
			   @AgentClosed = cl.AgentStatus, 
			   @MemberClosed = cl.MemberStatus
		FROM CustProductStatus cps WITH (NOLOCK)
			CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS sp
			CROSS APPLY (SELECT * FROM f_GetInfoStatus(cps.SuspendInfo)) AS cl
		WHERE cps.CustID = @CustID

		IF(@roleid = 1)
		BEGIN
			SET @UplineSuspended =  CASE WHEN (@SuperSuspended = 1 OR @MasterSuspended = 1 OR @AgentSuspended = 1) THEN 1 ELSE 0 END
			SET @UplineClosed =  CASE WHEN (@SuperClosed = 1 OR @MasterClosed = 1 OR @AgentClosed = 1) THEN 1 ELSE 0 END
		END
		ELSE IF(@roleid = 2)
		BEGIN
			SET @UplineSuspended =  CASE WHEN (@SuperSuspended = 1 OR @MasterSuspended = 1) THEN 1 ELSE 0 END
			SET @UplineClosed =  CASE WHEN (@SuperClosed = 1 OR @MasterClosed = 1) THEN 1 ELSE 0 END
		END
		ELSE IF(@roleid = 3)
		BEGIN
			SET @UplineSuspended =  @SuperSuspended
			SET @UplineClosed =  @SuperClosed 
		END
		ELSE IF(@roleid = 4)
		BEGIN
			SET @UplineSuspended =  0
			SET @UplineClosed =  0
		END
	END

	IF @Old_Suspended = @Suspended RETURN --Only update 'Suspended' status if values are different

	IF (@IsDeposit = 1)
	BEGIN
		IF @roleid = 1
			Select @UplineSuspended = isnull(reject,0),
				@UplineClosed = isnull(closed,0)
			from Custinfo with (nolock) where custid = @recommend 
		ELSE IF @roleid = 2
			Select @UplineSuspended = isnull(reject,0),
				@UplineClosed = isnull(closed,0)
			from Custinfo with (nolock) where custid = @mrecommend 
		ELSE IF @roleid = 3
			Select @UplineSuspended = isnull(reject,0), 
				@UplineClosed = isnull(closed,0)
			from Custinfo with (nolock) where custid = @srecommend 
		ELSE IF @roleid = 4
			Select @UplineSuspended = 0, @UplineClosed = 0
	END 

	IF @UplineSuspended = 1 and @Old_Suspended <> @Suspended
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'This user''s upline was suspended. Cannot edit.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60002,@Language)
						END, @ErrCode = 105
		return
	END 
	IF @UplineClosed = 1 AND @Old_Suspended <> @Suspended
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'This user''s upline was closed. Cannot edit.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60003,@Language)
							END, @ErrCode = 106
		return
	END
	
	-------------
	IF(@IsDeposit = 0) --Credit
	BEGIN
		UPDATE	cs 
		SET	SuspendInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(@roleid,@Suspended,ISNULL(SuspendInfo,0)))	
		FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 		
		WHERE custid = @CustID;
	END
	ELSE --Deposit
	BEGIN
		UPDATE CustInfo with (ROWLOCK, UPDLOCK) set Reject = @Suspended
		WHERE CustID = @CustID
	END
	if (@@error <> 0)
	begin
		
		Select @ErrMsg =
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 101
		return
	end
		
	IF @IsDeposit = 0 AND @RoleID BETWEEN 2 AND 4 
	BEGIN
		EXEC Acc_DynamicCustomerInfo_04
			@CustID		= @CustID
			,@RoleID	= @RoleID
			,@Action	= 'SuspendInfo'
			,@Suspended	= @Suspended
	END

	---------------
	declare @LogSPData varchar(8000)

	IF @ActionID=1104
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdSuspended CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
							'Suspended="'+ coalesce(cast(@Suspended as varchar(50)),space(1)) + '" '+
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
							'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
							'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
	END
	ELSE
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdSuspended CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
							'Suspended="'+ coalesce(cast(@Suspended as varchar(50)),space(1)) + '" '+
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" />'
	END

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		--write log for themself
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = @ActionID,
			@TrackingValue = @LogSPData,
			@duration = @duration
		
		--write log to support downlines view upline's actions
		IF @roleid = 4
		BEGIN
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 65018,--master view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 70027,--agent view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75036,--member view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END
		
		IF @roleid = 3
		BEGIN	
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 70028,--agent view on master action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75037,--member view on master action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END
		
		IF @roleid = 2
		BEGIN	
			EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75038,--member view on agent action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END								
	END TRY
	BEGIN CATCH	
		IF @ActionID=1104
		BEGIN
			Select @LogSPData = '<Acc_CustomerUpdSuspended CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
								'Suspended="'+ coalesce(cast(@Suspended as varchar(50)),space(1)) + '" '+
								'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" '+
								'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
								'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
								'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" '+
								'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" '+
								'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
		END

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = @ActionID,
			@TrackingValue = @LogSPData,
			@duration = @duration
		
		--write log to support downlines view upline's actions
		IF @roleid = 4
		BEGIN
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 65018,--master view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 70027,--agent view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75036,--member view on super action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END
		
		IF @roleid = 3
		BEGIN	
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 70028,--agent view on master action
			@TrackingValue = @LogSPData,
			@duration = @duration
			
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75037,--member view on master action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END
		
		IF @roleid = 2
		BEGIN	
			EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 75038,--member view on agent action
			@TrackingValue = @LogSPData,
			@duration = @duration
		END	
	END CATCH
END
GO