ALTER PROCEDURE [dbo].[Acc_CustomerUpdClosed]
	@CustID int,
	@Closed bit,	
	@SubAccID int = 0, --Sub-AccountID
	@UserID int,
	@disCasino bit =0,	
	@Language varchar(2) = 'E',
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(500) = '' OUTPUT,
	@IP varchar(15)=''
AS
/*
Created: 20080911@whoknow
Task : Update status 'closed' for customer
DB: DBCUST/CustDB
Original:

Revisions:
    - 20090314@HanhVu: add Korean language
    - 20090801@Shifu: check disabled user
	- 20090917@Phuc: write log into DBLOG.
	- 20090308@Phuc: check if @old_closed=@closed and @logincount > 5(closed by over 5 times attempt login with wrong password)=> do nothing
					Write log subaccname instead of subaccid.
	- 20090407@HanhVu: update logincount in case member got closed by entering wrong pass.
	- 20090818@Phuc: check page access and check upline closed first(call Age_CustSubCheckPageAccess)	

	- 20091008@Kiwi: Remove WriteLog_UserLog
	- 20091125@Terry : add one more para @disCasino check disabled Casino
	- 20100102@Lewin : modify LogSP Data, call WriteLog_UserLog_RunSPNew instead of WriteLog_UserLog_RunSP 
	- 20100728@Kiwi: grant execute permission to [bodbExtAccNet]
	- 20101021@Henry: Record execution time
	- 20110907@Sophia: Change Linked Server from DB052 to DB053
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20121206@Scott : Check Allowed downlines during peak hour at weekend  
	- 20130218@Dan: Change linked server DB053 to DBAGE; Write more log on DBTXN server in case of DBLOG server failure
	- 20130410@Elodie: Only update 'closed' status if values are different
	- 20130709@Jamie: Apply ExecRep 
	- 20131108@Elodie: Splitting bodb02 into CustDB (call Acc_ExecRep_Cust_04 instead of Acc_ExecRep_04)
	- 20140618@Thien: Prevent robot from opening back the closed accounts
	- 20141125@Jamie: Use Acc_CustomerInfo_Execrep_04 instead of Acc_ExecRep_Cust_04 [Redmine:#26497]	
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines, Acc_CustomerSelCheckEnable to DBCUST.CustDB)
	- 20160104@Helen: Disallow SMA changes password or updates account status of members - [Redmine:#49967]
	
Param's Explanation:
• @custid: custid that need to be viewed.   

*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	if @ErrCode <>0 return
	--end

	-----***20140618@Thien***-----
	-----***START: PREVENT ROBOT OPENED BACK***-----
	IF @CustID IN (14105547, --SUPERTEST1IY for testing
					15046519, --TVA9661
					15046495, --TVA9660
					11799369, --ECJACR
					14953680, --TVA960A
					2434401, --ELAC
					14953786, --TVA960B
					13925115 --TVA12P7
					, 15151088 --KX467
					, 15127440 --TVA6244
					, 15183681 --TVA6245
					, 14025219 --CG7KC
					, 6364393 --EA656
					, 14040657	--EG5TI23
					, 14040683	--EG5TI30
					, 14040677	--EG5TI28
					, 14040654	--EG5TI22
					, 14040682	--EG5TI29
					,14040662	--EG5TI24
					,11799369	--ECJACR
					,14040669	--EG5TI26
					,14040673	--EG5TI27
					,14040666	--EG5TI25
					,15103901 --TVA620A
					
					--20140712
					,	15134582	--	TVA967100
					,	15134804	--	TVA967800
					,	15134769	--	TVA967600
					,	15134831	--	TVA967900
					,	15134751	--	TVA967500
					,	15134782	--	TVA967700
					,	15134550	--	TVA967000
					,	15134594	--	TVA967200
					,	15134622	--	TVA967400
					,	15134609	--	TVA967300
					, 15131938 --TVA9670
					
					
					
					) AND @Closed = 0
	BEGIN
		Select @ErrMsg = case @Language 
							when 'E' then 'This function is temporarily unavailable, please update later.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](60004,@Language)
						end	,
			@ErrCode = 106
			return
			
	END
	-----***END: PREVENT ROBOT OPENED BACK***-----

	IF exists(select 1 from custinfo with (nolock) where synccasino = 1 and custid = @CustID)
	BEGIN
		IF @disCasino = 1
			BEGIN	
				Select @ErrMsg = case @Language 
									when 'E' then 'This CLOSED function is temporarily unavailable, please update later.'
									ELSE [dbo].[f_Get_MsgNamebyMsgID](60004,@Language)
								end	,
					@ErrCode = 106
					return
			END
	END

	IF @UserID <> @CustID AND CURRENT_USER <> 'bodbAdminNet' AND EXISTS (SELECT 1 FROM custInfo WITH (NOLOCK) WHERE custid = @CustID AND LockUpd = 1 AND roleid = 1)
	BEGIN
		 SELECT  @ErrMsg = CASE @Language
                                WHEN 'E' THEN 'You are currently not authorized to perform this action. Please contact the Customer Service Department for further assistance.'
                                ELSE [dbo].[f_Get_MsgNamebyMsgID](40033,@Language)
                              END ,
                 @ErrCode = 107
         RETURN
	END
	
	
	---------------------------

	Declare @roleid tinyint, @LoginCount int, @Old_Closed bit, @UplineClosed bit, @srecommend int, @mrecommend int, @recommend int 

	select @roleid = roleid, @LoginCount = logincount
	from customer with (nolock)
	where custid = @custid

	select  @Old_Closed = closed,
			@srecommend = srecommend,
			@mrecommend = mrecommend,
			@recommend = recommend
	from custinfo with (nolock)
	where custid = @custid

	-- 20130410@Elodie: Only update 'closed' status if values are different
	IF @Old_Closed = @Closed -- and @LoginCount > 5
		return
		
	-- Check Allowed downlines during peak hour at weekend 
	IF @closed = 1 
	BEGIN
		EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
												@roleid=@roleid,
												@isExecRep=1,  --Apply Exec Rep 
												@Language=@Language,
												@ErrMsg=@ErrMsg output,
												@ErrCode=@ErrCode output
		if @ErrCode <>0 return 
	END	
	--End 

	select @roleid = isnull(@roleid, 0)

	if @roleid not in (1,2,3,4)
	BEGIN
		Select @ErrMsg = case @Language 
							when 'E' then 'Invalid user!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						end	,
			@ErrCode = 100	
		return
	END

	IF @roleid = 1
		Select @UplineClosed = isnull(closed,0)
		from Custinfo with (nolock) where custid = @recommend 
	ELSE IF @roleid = 2
		Select @UplineClosed = isnull(closed,0)
		from Custinfo with (nolock) where custid = @mrecommend 
	ELSE IF @roleid = 3
		Select @UplineClosed = isnull(closed,0)
		from Custinfo with (nolock) where custid = @srecommend 
	ELSE IF @roleid = 4
		Select @UplineClosed = 0
		
	IF @UplineClosed = 1 AND @Old_Closed <> @Closed
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'This user''s upline was closed. Cannot edit.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60003,@Language)
							END, @ErrCode = 105
		return
	END


	update custinfo with (ROWLOCK, UPDLOCK) set Closed = @Closed
	where custid = @custid

	IF (@Old_Closed = 1 and @Closed = 0 and @LoginCount > 5) or (@Old_Closed = 1 and @Closed = 0 and @roleid = 1 and @logincount = 5)
		update customer with (ROWLOCK, UPDLOCK) set logincount = 0
		where custid = @custid 

	if (@@error <> 0)
	begin
		Select @ErrMsg =
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end	, @ErrCode = 101
		return
	end

	--20130709@Jamie: Apply Exec Rep SP 
	IF @Closed = 1 AND @RoleID BETWEEN 2 AND 4
	BEGIN
		EXEC Acc_CustomerInfo_Execrep_04
			 @CustID		= @CustID
			,@RoleID		= @RoleID
			,@Action		= 'Closed'
			,@Closed		= @Closed

	END


	-- WRITE LOG 

	declare @LogSPData varchar(8000)

	Select @LogSPData = '<Acc_CustomerUpdClosed CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
						'Closed="'+ coalesce(cast(@Closed as varchar(50)),space(1)) + '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

	/* 1105	Acc_CustomerUpdClosed	Update Closed status  */

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1105,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData = '<Acc_CustomerUpdClosed CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +
							'Closed="'+ coalesce(cast(@Closed as varchar(50)),space(1)) + '" ' +
							'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1)) + '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" ' +
							'ErrCode="'+ coalesce(cast(ERROR_NUMBER() as varchar(50)),space(1)) + '" ' +
							'ErrMsg="'+ coalesce(cast(ERROR_MESSAGE() as varchar(4000)),space(1))+'" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1105,
			@TrackingValue = @LogSPData	,
			@duration = @duration
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdClosed] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdClosed] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdClosed] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdClosed] TO [vnteam] AS [dbo]