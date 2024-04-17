/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap,Dot_Member" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_AdminUpdCSStatus_Cust]
	@custid INT,
	@disabledCS BIT=NULL,
	@syncCS BIT=NULL,
	
	@UpdateAllMasters BIT = 0,
	@UpdateAllAgents  BIT = 0,
	@UpdateAllMembers BIT = 0,
	
	@DisableAllMasters BIT = NULL,
	@DisableAllAgents  BIT = NULL,
	@DisableAllMembers BIT = NULL,
	
	@status BIT=1 OUTPUT,	
	@ErrMsg NVARCHAR(200) = '' OUTPUT,	
	@ErrCode INT = 0 OUTPUT,    	
	@UserID INT = 0,
	@SubAccID INT = 0, --Sub-AccountID
	@IP VARCHAR(20)='',
	@Language VARCHAR(2) = 'E'
AS

/*

Created: 20180117@Johnson
Task: Update casino status by Admin
DB: DBCUST/CUSTDB
Original: Acc_UpdCSStatus_Cust

   Revisions:
	- 20180117@Johnson: launch new sp from Acc_UpdCSStatus_Cust for new direction change [Redmine:#87328]
	- 20200717@Eden: Minimize UM Time - Lock updating customer settings [#136464]
*/
BEGIN
	SET NOCOUNT ON
	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 6
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	if @ErrCode <>0 return
	--end

	BEGIN TRY

	-- Checking

	DECLARE @Allow2Udpate BIT, @SyncCasino BIT ,@RoleID TINYINT, @UplineSyncCS BIT, @UplineEnableCS BIT, @Old_disabledCS BIT
	,@HasDownline BIT = 0
	
	SELECT @SyncCasino=SyncCasino,@RoleID=RoleID, @Old_disabledCS=DisableCasino 
	FROM custinfo(NOLOCK) 
	WHERE custid=@custid
	
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

	IF(@roleid = 4)
	BEGIN
		SELECT @Allow2Udpate=1		
	END	
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
	
	IF @roleid = 4 
	BEGIN
		SELECT top 1 @HasDownline = 1   
		FROM dbo.CustInfo WITH (NOLOCK)  
		WHERE (srecommend = @CustID and roleid = 3 AND SyncCasino=1)  			
	END
	ELSE IF @roleid = 3
	BEGIN
		SELECT top 1 @HasDownline = 1   
		FROM dbo.CustInfo WITH (NOLOCK)  
		WHERE (mrecommend = @CustID and roleid = 2 AND SyncCasino=1)
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT top 1 @HasDownline = 1   
		FROM dbo.CustInfo WITH (NOLOCK)  
		WHERE (recommend = @CustID and roleid = 1 AND SyncCasino=1)  
	END
	

	IF @Old_disabledCS = @disabledCS AND @UpdateAllMasters = 0 AND @UpdateAllAgents = 0 AND @UpdateAllMembers = 0
	BEGIN
		UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET	
		SyncCasino = @syncCS --CASE @syncCS WHEN 1 THEN 1 ELSE SyncCasino END
		WHERE custid=@custid
		
		--write log for sync
		GOTO WRITELOG
		--RETURN
	END
	
	--check constraint parameters
	SELECT @Allow2Udpate=1
	IF(@roleid = 4)
	BEGIN
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)
			OR (@UpdateAllMasters=1 AND @UpdateAllAgents=1 AND @DisableAllMasters=1 AND @DisableAllAgents=0)			
			OR (@disabledCS = 1 
				AND @HasDownline=1
				AND (@UpdateAllMasters = 0 OR @UpdateAllAgents = 0 OR @UpdateAllMembers = 0
					OR (@UpdateAllMasters =1 AND @DisableAllMasters = 0)
					OR (@UpdateAllAgents = 1 AND @DisableAllAgents = 0)
					OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
					)
				)
		SELECT @Allow2Udpate=0		
		
		IF @UpdateAllMembers=1 AND @UpdateAllAgents=0 AND @DisableAllMembers=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE srecommend = @custid
						AND roleid = 2
						AND DisableCasino = 1
						AND SyncCasino = 1
					)
			SELECT @Allow2Udpate=0			
		END
		
		IF @UpdateAllAgents=1 AND @UpdateAllMasters=0 AND @DisableAllAgents=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE srecommend = @custid
						AND roleid = 3
						AND DisableCasino = 1
						AND SyncCasino = 1
					)
			SELECT @Allow2Udpate=0			
		END
	END	
	ELSE IF (@Roleid =3)
	BEGIN	
		IF (@UpdateAllMembers=1 AND @UpdateAllAgents=1 AND @DisableAllAgents=1 AND @DisableAllMembers=0)			
			OR (@disabledCS = 1 
				AND @HasDownline=1
				AND (@UpdateAllAgents = 0 OR @UpdateAllMembers = 0					
					OR (@UpdateAllAgents = 1 AND @DisableAllAgents = 0)
					OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
					)
				)
			SELECT @Allow2Udpate=0	
			
		IF @UpdateAllMembers=1 AND @UpdateAllAgents=0 AND @DisableAllMembers=0
		BEGIN
			IF EXISTS(SELECT TOP 1 1 
					FROM dbo.CustInfo WITH(NOLOCK) 
					WHERE mrecommend = @custid
						AND roleid = 2
						AND DisableCasino = 1
						AND SyncCasino = 1
					)
			SELECT @Allow2Udpate=0			
		END
	END
	ELSE IF (@roleid =2)
	BEGIN
		IF @disabledCS = 1 
			AND @HasDownline=1
			AND (@UpdateAllMembers = 0					
				OR (@UpdateAllMembers = 1 AND @DisableAllMembers = 0)
				)
		SELECT @Allow2Udpate=0		
	END
	
	IF @Allow2Udpate=0		
	BEGIN
		SELECT @ErrMsg =  CASE @Language 
							WHEN 'E' THEN 'You are not allowed to perform this action.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90012,@Language)
						END, @ErrCode = 103
		RETURN
	END 
	-- Update itself
	UPDATE CustInfo WITH (ROWLOCK, UPDLOCK) SET
		DisableCasino = ISNULL(@disabledCS, DisableCasino),
		SyncCasino = @syncCS --CASE @syncCS WHEN 1 THEN 1 ELSE SyncCasino END
	WHERE custid=@custid

	-- Update PlayForFun - Member Request
	IF @RoleID = 1 AND EXISTS (SELECT 1 FROM CustRequestGame WITH (NOLOCK) WHERE CustID = @custid AND Sporttype = 208 AND isActive = 1) AND @disabledCS = 0
	BEGIN
		UPDATE cr
		SET isActive = 0,
			ModifiedDate = GETDATE()
		FROM CustRequestGame cr WITH (ROWLOCK, UPDLOCK)
		WHERE CustID = @custid AND Sporttype = 208

		DECLARE @Content_es NVARCHAR(4000), @Content_cs NVARCHAR(4000), @Content_ch NVARCHAR(4000), @Content_th NVARCHAR(4000),
				@UserName NVARCHAR(50), @CustName NVARCHAR(50), @MessageID INT
		SELECT @Content_es = N'Dear user,
We would like to inform you that your activation request of product Casino has been completed, now you can place bet on the product.
Thank you'
		SELECT @Content_cs = N'?????,?????????????????????,?????????????'
		SELECT @Content_ch = N'?????,?????????????????????,?????????????'
		SELECT @Content_th = N'???????????,?????????????????????????????????????????????????????????????????????????????????????????????????????????????. ?????????'

		SELECT @CustName = username
		FROM CustInfo WITH (NOLOCK)
		WHERE custid = @custid

		EXEC DBMSG.bodb_Message.dbo.Dot_Msg_SetMessage @IsSticky=0,@Content_th=@Content_es,@Content_es=@Content_es,@Content_ko=@Content_es,@Creator=@UserID,@Content_ch=@Content_es,@CreatorName=@UserName,@IsBatch=0,@Content_it=@Content_es,@Content_jp=@Content_es,@MsgType=1,@IsTest=0,@Content_en=@Content_es,@MatchId=0,@Content_cs=@Content_es, @MessageIDOutput = @MessageID OUTPUT

		EXEC DBMSG.bodb_Message.dbo.NAP_Setting_BatchMessage_Upload @CreatorId=@UserID,@MessageID=@MessageID, @TargetID = @custid, @TargetName = @CustName
	END

	--	Update downline
	IF ( @RoleID > 1 
		AND(@disabledCS = 1  
			OR (@disabledCS = 0 
				AND (@UpdateAllMasters = 1 
					OR @UpdateAllAgents = 1  
					OR @UpdateAllMembers = 1 )
				AND @HasDownline = 1
				)
			)  
		)  
	BEGIN
		EXEC [Acc_CustomerInfo_Execrep_04]
			 @CustID		= @CustID
			,@RoleID		= @RoleID
			,@Action		= 'disabledCS'
			,@disabledCS	= @disabledCS
			,@UpdateAllMasters = @UpdateAllMasters
			,@UpdateAllAgents = @UpdateAllAgents
			,@UpdateAllMembers = @UpdateAllMembers
			,@DisableAllMasters = @DisableAllMasters
			,@DisableAllAgents = @DisableAllAgents
			,@DisableAllMembers = @DisableAllMembers
	END 

	SELECT @status = 1
		
	END TRY

	BEGIN CATCH
		SELECT @status = 0
	END CATCH



	--Log data
	--Log data
	WRITELOG:
	DECLARE @LogData NVARCHAR(MAX)
			,@TrackingValue2 NVARCHAR(MAX)
			,@ActionID INT
	---------------------------
	select @LogData ='<Acc_AdminUpdCSStatus_Cust custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'disabledCS="'+ coalesce(cast(@disabledCS as varchar(50)),space(1)) + '" ' +
	'syncCS="'+ coalesce(cast(@syncCS as varchar(50)),space(1)) + '" ' +
	'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
	'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
	'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
	'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
	'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
	'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  	
	'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as varchar(20)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'

	select @TrackingValue2 ='<Acc_AdminUpdCSStatus_Cust custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
	'disabledCS="'+ coalesce(cast(@Old_disabledCS as varchar(50)),space(1)) + '" ' +
	'syncCS="'+ coalesce(cast(@SyncCasino as varchar(50)),space(1)) + '" ' +
	'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
	'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
	'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
	'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
	'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
	'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  	
	'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +	
	'IP="'+ coalesce(cast(@IP as varchar(20)),space(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'

	set @endRun = getdate()
	set @duration  = datediff (millisecond,@startRun,@endRun)

	BEGIN TRY
		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60005 
										WHEN 3 THEN 65010
										WHEN 2 THEN 70015 
										WHEN 1 THEN 75020 END
										
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID, 
			@CustID = @custid,
			@ActionID = @ActionID,
			@TrackingValue = @LogData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
			
		--write log for downlines in-case disable downline
		IF @HasDownline = 1
		BEGIN
			IF @roleid >3 
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65011
				
				--actionID on master
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70016 
												WHEN 4 THEN 70017 END
										
				--actionID on agent
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75021 
												WHEN 3 THEN 75022
												WHEN 4 THEN 75023 END
												
				--actionID on member
				EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration
			END	
		END			
	END TRY
	BEGIN CATCH
		select @LogData ='<Acc_AdminUpdCSStatus_Cust custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'disabledCS="'+ coalesce(cast(@disabledCS as varchar(50)),space(1)) + '" ' +
		'syncCS="'+ coalesce(cast(@syncCS as varchar(50)),space(1)) + '" ' +
		'UpdateAllMasters="'+ coalesce(cast(ISNULL(@UpdateAllMasters,0) as varchar(50)),space(1)) + '" '+ 
		'DisableAllMasters="'+ coalesce(cast(ISNULL(CAST(@DisableAllMasters AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+ 
		'UpdateAllAgents="'+ coalesce(cast(ISNULL(@UpdateAllAgents,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllAgents="'+ coalesce(cast(ISNULL(CAST(@DisableAllAgents AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  
		'UpdateAllMembers="'+ coalesce(cast(ISNULL(@UpdateAllMembers,0) as varchar(50)),space(1)) + '" '+  
		'DisableAllMembers="'+ coalesce(cast(ISNULL(CAST(@DisableAllMembers AS VARCHAR(10)),0) as varchar(50)),space(1)) + '" '+  	
		'status="'+ coalesce(cast(@status as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +		
		'IP="'+ coalesce(cast(@IP as varchar(20)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))  + '" />'
		
		--write log for themself
		SELECT @ActionID = CASE @roleid WHEN 4 THEN 60005 
										WHEN 3 THEN 65010
										WHEN 2 THEN 70015 
										WHEN 1 THEN 75020 END
										
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID, 
			@CustID = @custid,
			@ActionID = @ActionID,
			@TrackingValue = @LogData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
			
		--write log for downlines in-case disable downline
		IF @HasDownline = 1
		BEGIN
			IF @roleid >3 
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllMasters = 1 )
					)			
			BEGIN
				SELECT @ActionID = 65011
				
				--actionID on master
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration  
			END
			
			IF @Roleid >2
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllAgents = 1 )
					)	
			BEGIN	
				SELECT @ActionID = CASE @roleid WHEN 3 THEN 70016 
												WHEN 4 THEN 70017 END
										
				--actionID on agent
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration 
			END
			
			IF @Roleid >1
				AND ( @DisabledCS = 1 
					OR (@DisabledCS = 0 AND @UpdateAllMembers = 1 )
					)
			BEGIN
				SELECT @ActionID = CASE @roleid WHEN 2 THEN 75021 
												WHEN 3 THEN 75022
												WHEN 4 THEN 75023 END
												
				--actionID on member
				EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP  
					@UserID = @UserID,  
					@CustID = @CustID,  
					@ActionID = @ActionID,  
					@TrackingValue = @LogData  , 
					@TrackingValue2 = @TrackingValue2  ,  
					@duration = @duration
			END	
		END	
	END CATCH
END
GO