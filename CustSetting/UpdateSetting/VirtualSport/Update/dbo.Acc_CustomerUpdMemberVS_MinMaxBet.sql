USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet]    Script Date: 06/09/2015 16:40:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_MinMaxBet    Script Date: 4/22/2014 1:45:57 AM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_MinMaxBet    Script Date: 10/04/2014 5:25:04 PM ******/
/****** Object:  Stored Procedure dbo.Acc_CustomerUpdMemberVS_MinMaxBet    Script Date: 12/5/2013 5:35:50 PM ******/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet]
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
		Date: 2012-08-16
		Task: update bet setting for virtual sports on member
		DB: DBTXN/custDB
		
		Revisions:
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20121130@Scott: Add virtual Tennis (sporttype=186)
			- 20130221@Johnson: - add virtual horse racing setting (sporttype: 181)
								- change linked server DB053 to DBAGE
								- write log on DBTXN if DBLOG failure
			- 20131121@Elodie: Add Virtual greyhounds(182), Virtual Motor Racing(184)						
			- 20140402@Kathy: Add Virtual Speedway (183), Virtual Virtual Cycling (185)	[Redmine:#14142]	
			- 20150606@Kathy: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB, Change Age_CustomerSelCheckBelonging -> Age_CustomerSelCheckBelongingByCustID) [Redmine:#36216]										
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	
		Parameter's Explanation:
	*/
SET NOCOUNT ON 
-----------------------
	DECLARE @startRun		DATETIME, 
			@endRun			DATETIME, 
			@duration		INT,
			@roleid			TINYINT, 
			@recommend		INT,
			
			@minminbet		MONEY,
			@maxmaxbet		MONEY,
			@maxmaxpermatch MONEY,
						
			@minbet_old		MONEY,
			@maxbet_old		MONEY,
			@maxpermatch_old MONEY,		
			
			@ErrCode_Cur INT, 
			@ErrMsg_Cur NVARCHAR(4000)
	SELECT @ErrCode_Cur = 0, @ErrMsg_Cur = '', @ErrCode = '', @ErrMsg = ''

	SET @startRun = GETDATE()
	
	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID = @Userid, 
		@Custid = @custid,
		@roleid = @roleid OUTPUT
		IF (@roleid = 0) RETURN
	---------------------------

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
		
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode_Cur output,@ErrMsg=@ErrMsg_Cur output
	IF @ErrCode_Cur > 0
	BEGIN
		select @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
		return
	END
	--end
		
	SELECT @recommend = recommend ,
			@maxpermatch_old = CASE WHEN @sporttype = 180 THEN maxpermatch180
									WHEN @sporttype = 181 THEN maxpermatch181
									WHEN @sporttype = 182 THEN maxpermatch182
									WHEN @sporttype = 183 THEN maxpermatch183
									WHEN @sporttype = 184 THEN maxpermatch184
									WHEN @sporttype = 185 THEN maxpermatch185
									WHEN @sporttype = 186 THEN maxpermatch186 end
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid AND roleid = 1
	
	IF @recommend IS NULL
		RETURN
	
	SELECT @minminbet = minbet,
			@maxmaxbet = maxbet
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = @sporttype AND bettype = @bettype
	
	SELECT @maxmaxpermatch = CASE	WHEN @sporttype = 180 THEN maxpermatch180
									WHEN @sporttype = 181 THEN maxpermatch181
									WHEN @sporttype = 182 THEN maxpermatch182
									WHEN @sporttype = 183 THEN maxpermatch183
									WHEN @sporttype = 184 THEN maxpermatch184
									WHEN @sporttype = 185 THEN maxpermatch185
									WHEN @sporttype = 186 THEN maxpermatch186 END 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @recommend
	
	SELECT @minbet_old = minbet, 
			@maxbet_old = maxbet
	FROM custsetting3rd WITH(NOLOCK) 
	WHERE custid = @custid AND sporttype = @sporttype AND bettype = @bettype
	
	IF @minbet<0
		or @maxbet < 0
		or @maxpermatch <0
	BEGIN	 
		SELECT @ErrMsg_Cur = case @Language 
								when 'E' then 'Wrong Min bet/ Max bet/ Max per match.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
						end, @ErrCode_Cur = 101
						
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		
			RETURN
	END
	
	IF (@MinBet<>0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxBet>@MaxPerMatch) 
	BEGIN
		SELECT @ErrMsg_Cur =
						case @Language 
							when 'E' then 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
						end						
						+ char(13) + char(10) + convert(varchar(20), @MinBet) + '-' + convert(varchar(20), @MaxBet) + '-' + convert(varchar(20), @MaxPerMatch), @ErrCode_Cur = 102
			
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
		
		RETURN
	END
	
	IF (@MinMinBet>0 AND @MinBet>0 AND @MinBet<@MinMinBet)
	BEGIN
		SELECT @ErrMsg_Cur =
						CASE @Language 
							WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
						END						
						+' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').', @ErrCode_Cur = 103
				
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	
		RETURN
	END
	
	IF(@MaxMaxBet > 0 AND @MaxBet > 0 AND @MaxBet > @MaxMaxBet)
	BEGIN
		SELECT @ErrMsg_Cur =
						CASE @Language 
							WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language)
						END						
						+'(' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').', @ErrCode_Cur = 104
				
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	
		RETURN
	END
	
	IF (@MaxMaxPerMatch>0 AND @MaxPerMatch>0 AND @MaxPerMatch>@MaxMaxPerMatch)
	BEGIN
		SELECT @ErrMsg_Cur =	
						CASE @Language 
							WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language)
						END						
						+'(' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').', @ErrCode_Cur = 105
				
		SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	
		RETURN
	END
	
	IF @MinBet <> @minbet_old OR @MaxBet <> @maxbet_old
	BEGIN
		UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
		SET
			MinBet= @MinBet,
			MaxBet= @MaxBet 
		WHERE custid=@custid AND sporttype = @sporttype AND bettype = @bettype
		
		IF (@@error <> 0)
		BEGIN
			Select @ErrMsg_Cur =
							case @Language 
								when 'E' then 'Update process is unsuccessful !'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							end, @ErrCode_Cur = 106
							
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
			@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
	
			RETURN
		END
		ELSE 		
			SELECT @ErrCode = @ErrCode + '-101' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END
	
	IF @MaxPerMatch <> @maxpermatch_old
	BEGIN
		IF (@sporttype = 180)
		BEGIN
		
						EXEC Acc_CustomerUpdMaxPerMatchVS180_1201
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		
		IF (@sporttype = 181)
		BEGIN
		
						EXEC Acc_CustomerUpdMaxPerMatchVS181_1231
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		
		IF (@sporttype = 182)
		BEGIN
		
						EXEC Acc_CustomerUpdMaxPerMatchVS182_1231
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END

		IF (@sporttype = 183)
		BEGIN
		
																								EXEC Acc_CustomerUpdMaxPerMatchVS183_1231
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END


		IF (@sporttype = 184)
		BEGIN
		
						EXEC Acc_CustomerUpdMaxPerMatchVS184_1231
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		
		IF (@sporttype = 185)
		BEGIN
		
																								EXEC Acc_CustomerUpdMaxPerMatchVS185_1231
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END

		IF (@sporttype = 186)
		BEGIN
		
						EXEC Acc_CustomerUpdMaxPerMatchVS186_1220
				@custid = @custid,
				@MaxPerMatch = @MaxPerMatch,
				@Language = @Language,
				@ErrCode = @ErrCode_Cur OUTPUT,
				@ErrMsg = @ErrMsg_Cur OUTPUT
		END
		
			
		IF @ErrCode_Cur > 0
		BEGIN
			SELECT @ErrCode = @ErrCode + CAST(@ErrCode_Cur AS VARCHAR(10)) + CHAR(7),
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + CHAR(7)
			
			RETURN	
		END
		ELSE 
			SELECT @ErrCode = @ErrCode + '-102' + CHAR(7), @ErrMsg = @ErrMsg + CHAR(7)	
	END		
	
	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(4000)
			
	Select @LogSPData ='<Acc_CustomerUpdMemberVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
			@ActionID = 373,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		Select @LogSPData ='<Acc_CustomerUpdMemberVS_MinMaxBet custid="'+ coalesce(cast(@custid as varchar(50)),space(1)) + '" ' +
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
			@ActionID = 373,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberVS_MinMaxBet] TO [vnteam] AS [dbo]