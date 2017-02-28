
ALTER PROCEDURE [dbo].[Acc_CustomerUpdEnableBetSettingVS]
	@custid			INT,
	@DisableVS		BIT = 0,
	@DisableDownlinesVS  BIT = 0,
	@minbetv180		MONEY = 0,
	@maxbetv180		MONEY = 0,
	@maxpermatchv180 MONEY = 0,	
	@UserID			INT,
	@Language		VARCHAR(2) = 'E',
	@ErrCode		INT = 0 OUTPUT,
	@ErrMsg			NVARCHAR(200) = '' OUTPUT,
	@IP				VARCHAR(15)=''
AS
	/*
		Created: Johnson
		Date: 2012-09-04
		Task: Update status and bet setting for virtual sports
		DB: DBTRANS.BODB02
		
		Revisions:
			- 20121203@Scott : update status and bet setting for virtual tennis by setting's virtual soccer
			- 20121206@Scott : Check Allowed downlines during peak hour at weekend
			
		Parameters Explanation:
	*/ 
SET NOCOUNT ON 
	DECLARE @startRun DATETIME,
			@endRun DATETIME,
			@duration INT,
			
			@MinMinBetv180 MONEY,
			@MaxMaxBetv180 MONEY,
			@MaxMaxPerMatchv180 MONEY,
			
			@MinBetv180_old MONEY,
			@MaxBetv180_old MONEY,
			@MaxPerMatchv180_old MONEY,
			
			@roleid TINYINT,
			@srecommend INT,
			@mrecommend INT,
			@recommend INT,
			@DisableUplineVS BIT
	
	SET @startRun = GETDATE()

	--Check disable user
	EXEC DB053.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
	IF @ErrCode <>0 RETURN
	
	SELECT @recommend = recommend, 
		@mrecommend = mrecommend,
		@srecommend	= srecommend,		
		@roleid = roleid
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	

--Check Allowed downlines during peak hour at weekend	
	IF @DisableDownlinesVS = 0
	BEGIN
		EXEC DB053.bodb02.dbo.Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
											@roleid=@roleid,
											@isExecRep=1,
											@Language=@Language,
											@ErrMsg=@ErrMsg output,
											@ErrCode=@ErrCode output
		IF @ErrCode <>0 RETURN
	END
--END	
	
	IF @roleid = 3
	BEGIN
		SELECT @MinMinBetv180 = minbet,
				@MaxMaxBetv180 = maxbet
		FROM custsetting3rd WITH(NOLOCK)
		WHERE custid = @srecommend AND sporttype = 180 AND bettype = 1201
		
		SELECT @MaxMaxPerMatchv180 = maxpermatch180
		FROM custinfo WITH(NOLOCK)
		WHERE custid = @srecommend
	END
	ELSE IF @roleid = 2
	BEGIN
		SELECT @MinMinBetv180 = MAX(minbet),
				@MaxMaxBetv180 = MIN(maxbet)
		FROM custsetting3rd WITH(NOLOCK)
		WHERE custid IN (@srecommend, @mrecommend) AND sporttype = 180 AND bettype = 1201
		
		SELECT @MaxMaxPerMatchv180 = MIN(maxpermatch180)
		FROM custinfo WITH(NOLOCK)
		WHERE custid IN (@srecommend,@mrecommend)
	END
	ELSE IF @roleid = 1
	BEGIN
		SELECT @MinMinBetv180 = MAX(minbet),
				@MaxMaxBetv180 = MIN(maxbet)
		FROM custsetting3rd WITH(NOLOCK)
		WHERE custid IN (@srecommend, @mrecommend,@recommend) AND sporttype = 180 AND bettype = 1201
		
		SELECT @MaxMaxPerMatchv180 = MIN(maxpermatch180)
		FROM custinfo WITH(NOLOCK)
		WHERE custid IN (@srecommend,@mrecommend,@recommend)
	END
	
	IF @roleid = 3
		SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @srecommend
	ELSE IF @roleid = 2
		SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @mrecommend
	ELSE IF @roleid = 1
		SELECT @DisableUplineVS = DisableVirtualSports FROM custInfo WITH(NOLOCK) WHERE custid = @recommend

	
	IF ISNULL(@DisableUplineVS,0) = 1
	BEGIN
		SELECT @ErrMsg = 'Upline is disable virtual sports.',
				@ErrCode = 100
		RETURN	
	END 
	
	IF @minbetv180 < 0 OR @maxbetv180 < 0 OR @maxpermatchv180 < 0
	BEGIN
		SELECT @ErrMsg = 'Wrong Min bet/ Max bet/ Max per match.',
					@ErrCode = 101
		RETURN
	END
	
	IF (@minbetv180<>0 and @maxbetv180 <> 0 and  @minbetv180>@maxbetv180) 
		or (@maxbetv180<> 0 and @maxpermatchv180 <> 0 and @maxbetv180>@maxpermatchv180) 
		or (@minbetv180 <> 0 and @maxpermatchv180 <> 0 and @minbetv180>@maxpermatchv180)
	BEGIN
		SELECT @ErrMsg = 'Min bet must be less than max bet and max bet must be less than max bet per match!!!',
				@ErrCode = 102
		RETURN
	END
	
	IF @roleid < 4
	BEGIN
		IF (@MinMinBetv180>0 and @MinBetv180>0 and @minbetv180<@MinMinBetv180)
		BEGIN
			SELECT @ErrMsg = 'Min bet must be equal to or greater than upline min bet ' + convert(varchar(10),@MinMinBetv180),
					@ErrCode = 103
			RETURN
		END
		
		IF (@MaxMaxBetv180>0 and @MaxBetv180>0 and @maxbetv180>@MaxMaxBetv180)
		BEGIN
			SELECT @ErrMsg = 'max bet must be equal to or less than upline max bet ' + convert(varchar(10),@MaxMaxBetv180),
					@ErrCode = 104
			RETURN
		END
		
		IF (@MaxMaxPerMatchv180>0 and @MaxPerMatchv180>0 and @MaxPerMatchv180>@MaxMaxPerMatchv180)
		BEGIN
			SELECT @ErrMsg = 'Max Per Match must be equal to or less than Upline Max Per Match ' + convert(varchar(10),@MaxMaxPerMatchv180),
					@ErrCode = 105
			RETURN
		END					
	END		
	
	SELECT @MinBetv180_old = MinBet,
			@MaxBetv180_old = MaxBet
	FROM custsetting3rd WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 180 AND bettype = 1201
	
	SELECT @MaxPerMatchv180_Old = MaxPerMatch180
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @custid
	
	IF @DisableVS = 0
	BEGIN
		UPDATE custinfo WITH(UPDLOCK,ROWLOCK)
		SET DisableVirtualSports = @DisableVS,
			HideVirtualSports = CASE WHEN HideVirtualSports = 1 THEN 0 ELSE HideVirtualSports END,
			maxpermatch180 = @maxpermatchv180,
			maxpermatch186 = @maxpermatchv180
		WHERE custid = @custid
		
		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = 'Update process is unsuccessful.',
					@ErrCode = 201
			RETURN
		END
		
		UPDATE custsetting3rd WITH(UPDLOCK, ROWLOCK)
		SET minbet = @minbetv180,
			maxbet = @maxbetv180
		WHERE custid = @custid AND sporttype in(180,186) AND bettype in(1201,1220)
		
		IF (@@ERROR <> 0)
		BEGIN			
			SELECT @ErrMsg = 'Update process is unsuccessful.',
					@ErrCode = 202
			RETURN
		END
	END
	
	IF @DisableDownlinesVS = 0
	BEGIN
		EXEC Acc_CustSetting3rd_03
			@custid				= @custid,
			@roleid				= @roleid,
			@DisableDownlinesVS = @DisableDownlinesVS,
			@minbetv180			= @minbetv180,
			@maxbetv180			= @maxbetv180,
			@maxpermatchv180	= @maxpermatchv180,
			@ErrCode			= @ErrCode OUTPUT,
			@ErrMsg				= @ErrMsg OUTPUT
		
		IF @ErrCode > 0
			RETURN
				
	END
		
	DECLARE @LogSPData VARCHAR(2000),
			@LogSPData_Old VARCHAR(2000)

	Select @LogSPData = '<Acc_CustomerUpdEnableBetSettingVS CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
						'DisableVS="'+ coalesce(cast(@DisableVS as varchar(50)),space(1)) + '" '+
						'ApplyDownlinesVS="'+ coalesce(cast(CASE WHEN @DisableDownlinesVS = 1 THEN 0 ELSE 1 END as varchar(50)),space(1)) + '" '+
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)
	
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1138,
		@TrackingValue = @LogSPData	 ,
		@duration = @duration
		
	IF @DisableDownlinesVS = 0 OR @DisableVS = 0
	BEGIN
		Select @LogSPData = '<Acc_CustomerUpdEnableBetSettingVS CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
							'Minbet="'+ coalesce(cast(@minbetv180 as varchar(50)),space(1)) + '" '+
							'Maxbet="'+ coalesce(cast(@maxbetv180 as varchar(50)),space(1)) + '" '+
							'Maxpermatch="'+ coalesce(cast(@maxpermatchv180 as varchar(50)),space(1)) + '" '+
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
							'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
							'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
		
		Select @LogSPData_old = '<Acc_CustomerUpdEnableBetSettingVS CustID="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" '+
							'Minbet="'+ coalesce(cast(@minbetv180_old as varchar(50)),space(1)) + '" '+
							'Maxbet="'+ coalesce(cast(@maxbetv180_old as varchar(50)),space(1)) + '" '+
							'Maxpermatch="'+ coalesce(cast(@maxpermatchv180_old as varchar(50)),space(1)) + '" '+
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" '+
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+'" '+
							'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" '+
							'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(400)),space(1))+'" '+
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+'" />'
												
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 374,
			@TrackingValue = @LogSPData	 ,
			@TrackingValue2 = @LogSPData_Old,
			@duration = @duration
	END
	
GO

GRANT EXECUTE ON [dbo].[Acc_CustomerUpdEnableBetSettingVS] TO [bodbAdminNet]
GO 