ALTER PROCEDURE [Acc_CustomerUpdMasterVS_MinMaxBet]
	@custid			INT,
	@sporttype		INT,
	@bettype		INT,

	@minbet			MONEY,
	@maxbet			MONEY,
	@maxpermatch	MONEY,
	
	@SubAccID	INT = 0,
	@userid		INT,
	@IP			VARCHAR(50)= '',
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2012-08-15
		Task: update bet setting of virtual sports on master
		DB: DBTXN/custDB
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20121130@Scott:  Add virtual Tennis (sporttype = 186)
			- 20130221@Johnson: - add virtual horse racing setting
								- write log on DBTXN if DBLOG failure
			- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)	
			- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]					
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
											
		Parameter's Explanation
	*/
SET NOCOUNT ON
--------------------------
	DECLARE @startRun		DATETIME, 
			@endRun			DATETIME, 
			@duration		INT,
			@srecommend		INT,
			
			@minminbet		MONEY,
			@maxmaxbet		MONEY,
			@maxmaxpermatch MONEY,
			
			@minbet_old		MONEY,
			@maxbet_old		MONEY,
			@maxpermatch_old MONEY,
			@ErrCode_Cur	INT, 
			@ErrMsg_Cur		NVARCHAR(4000)

	DECLARE @roleid TINYINT
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''
	
	SET @startRun = GETDATE()
	
	SELECT @srecommend = srecommend ,
			@maxpermatch_old = CASE WHEN @sporttype = 180 THEN maxpermatch180 
									WHEN @sporttype = 181 THEN maxpermatch181 
									WHEN @sporttype = 182 THEN maxpermatch182 
									WHEN @sporttype = 183 THEN maxpermatch183 
									WHEN @sporttype = 184 THEN maxpermatch184
									WHEN @sporttype = 185 THEN maxpermatch185
									WHEN @sporttype = 186 THEN maxpermatch186  END 
			, @roleid = roleid						
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid AND roleid = 3

	IF @srecommend IS NULL
		RETURN
		            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	SELECT @minminbet = minbet,
			@maxmaxbet = maxbet
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @srecommend AND sporttype = @sporttype AND bettype = @bettype
	
	SELECT @maxmaxpermatch = CASE	WHEN @sporttype = 180 THEN maxpermatch180 
									WHEN @sporttype = 181 THEN maxpermatch181 
									WHEN @sporttype = 182 THEN maxpermatch182 
									WHEN @sporttype = 183 THEN maxpermatch183 
									WHEN @sporttype = 184 THEN maxpermatch184
									WHEN @sporttype = 185 THEN maxpermatch185
									WHEN @sporttype = 186 THEN maxpermatch186 END 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @srecommend
	
	SELECT @minbet_old = minbet, 
			@maxbet_old = maxbet
	FROM custsetting3rd WITH(NOLOCK) 
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
	IF @minbet<0
		or @maxbet < 0
		or @maxpermatch <0
	BEGIN	 
		Select @ErrMsg_Cur = 	case @Language 
							when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
					end, @ErrCode_Cur = 101
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
	END
	
	IF (@minbet<>0 and @maxbet <> 0 and  @minbet>@maxbet) 
		or (@maxbet<> 0 and @maxpermatch <> 0 and @maxbet>@maxpermatch) 
		or (@minbet <> 0 and @maxpermatch <> 0 and @minbet>@maxpermatch)
	BEGIN
		SELECT @ErrMsg_Cur =  
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						end	, @ErrCode_Cur = 102
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
	END
	
	if (@MinMinBet>0 and @MinBet>0 and @minbet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg_Cur =	
						case @Language 
							when 'E' then 'Min bet must be equal to or greater than Super Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10016,@Language)
						end						
						+' (' + convert(varchar(20), @MinMinBet) + ').'
				, @ErrCode_Cur = 103
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
	END
	
	if (@MaxMaxBet>0 and @MaxBet>0 and @maxbet>@MaxMaxBet)
	BEGIN
		SELECT @ErrMsg_Cur =	
						case @Language 
							when 'E' then 'Max bet must be equal to or less than Super Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10017,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxBet) + ').'
				, @ErrCode_Cur = 104
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
	END
	
	if (@MaxMaxPerMatch>0 and @MaxPerMatch>0 and @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg_Cur =	
						case @Language 
							when 'E' then 'Max Per Match must be equal to or less than Super Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10018,@Language)
						end						
						+' (' + convert(varchar(20), @MaxMaxPerMatch) + ').'
				, @ErrCode_Cur = 105	
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
					@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			RETURN
		END
	END
	
	IF (@minbet_old <> @minbet OR @maxbet_old <> @maxbet)
	BEGIN
		UPDATE custsetting3rd WITH(UPDLOCK,ROWLOCK)
		SET minbet = @minbet,
			maxbet = @maxbet
		WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
		
		IF (@@ERROR <> 0)
		BEGIN
			Select @ErrMsg_Cur =
							case @Language 
								when 'E' then 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							end	, @ErrCode_cur = 106
			IF @ErrCode_Cur > 0
			BEGIN
				SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
						@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				RETURN
			END			
		END
		ELSE	
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END
	
	IF @maxpermatch_old <> @maxpermatch
	BEGIN
		IF (@sporttype = 180)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS180_1201
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 181)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS181_1231
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 182)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS182_1231
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 183)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS183_1231
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 184)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS184_1231
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 185)
		BEGIN 
		
						EXEC Acc_CustomerUpdMaxPerMatchVS185_1231
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		IF (@sporttype = 186)
		BEGIN
			
						EXEC Acc_CustomerUpdMaxPerMatchVS186_1220
						@custid = @custid,
						@MaxPerMatch = @MaxPerMatch,
						@Language = @Language,
						@ErrCode = @ErrCode_cur OUTPUT,
						@ErrMsg = @ErrMsg_Cur OUTPUT
		
		END
		
		IF @ErrCode_cur > 0
		BEGIN
			select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
			return
		END
		ELSE
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END
	
		
	DECLARE @LogSPData VARCHAR(5000),
			@TrackingValueDB VARCHAR(4000)
			
	Select @LogSPData ='<Acc_CustomerUpdMasterVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 372,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData ='<Acc_CustomerUpdMasterVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
		'sporttype="'+ coalesce(cast(@sporttype as varchar(50)),space(1)) + '" ' +
		'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +
		'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +
		'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +
		'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 372,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxBet] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterVS_MinMaxBet] TO [vnteam] AS [dbo]