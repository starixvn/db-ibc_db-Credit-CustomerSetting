USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission]    Script Date: 04/27/2015 16:03:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission] 
    @custid				INT,
    @v255discount_1701	DECIMAL(9,8),
    @IP					VARCHAR(50)		= '',    
    @UserID				INT				= 0,
    @Language			VARCHAR(20)		= 'E',        
    @ErrCode			INT				= 0			OUTPUT,
    @ErrMsg				NVARCHAR(4000)	= ''		OUTPUT
AS
    /*
        Created: Kathy
        Date: 20150423
        Task: Company update commission on super
        DB: DBTXN/BODB02
        
        Revisions:
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
        Parameters Explanation:         
    */
BEGIN

	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
			,@endRun	DATETIME 
			,@duration	INT

	SET @startRun = GETDATE()

	DECLARE @roleid			TINYINT
			,@ErrCode_Cur	INT
			,@ErrMsg_Cur	NVARCHAR(4000)
			,@ErrAcc		NVARCHAR(4000)
			
	SELECT	@ErrCode_Cur = 0
			,@ErrMsg_Cur = ''
			,@ErrCode = ''
			,@ErrMsg = ''

	---------------------------
	-- ***Check Downline Belonging***
	EXEC Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid, 
		@Custid			= @custid,
		@roleid			= @roleid OUTPUT
		
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
	EXEC Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode_Cur	OUTPUT
		,@ErrMsg	= @ErrMsg_Cur	OUTPUT
		
	IF @ErrCode_Cur > 0
	BEGIN
		SELECT @ErrCode = @ErrCode + cast(@ErrCode_cur as varchar(300)) + char(7), 
				@ErrMsg = @ErrMsg + @ErrMsg_Cur + char(7)
				
		RETURN
	END
	--end

	--Check Allowed downlines    
	EXEC Acc_CustomerSelCheckAllowedDownlines    
		@custid		= @custid,
		@roleid		= 4,-- @roleid,
		@isExecRep	= 1,
		@isUpdatePT = 1,
		@Sporttype	= 1,
		@Language	='E',
		@ErrMsg		= @ErrMsg	OUTPUT,
		@ErrCode	= @ErrCode	OUTPUT
		
	IF @ErrCode <> 0 
		RETURN 
	        
	DECLARE @db_v255discount_1701 DECIMAL(9,8)

	SELECT	@db_v255discount_1701 = sdiscount 
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype = 255 
			AND bettype = 1701

	IF @db_v255discount_1701 = @v255discount_1701 
		RETURN
	    

	IF @v255discount_1701 < 0 OR ( @v255discount_1701 > 0.01)
	BEGIN    
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
						 END
						 ,@ErrCode = 103
		RETURN
	END

	-- Apply exec rep
		EXEC Acc_CustSetting3rd_06
			@CustId				= @custid,
			@RoleId				= @roleid,
			@Discount			= @v255discount_1701,
			@mode				= 'GoldDeluxe',
			@Sporttype			= 255,
			@Bettype			= 1701
	    
	Declare @LogSPData varchar(MAX),
			@TrackingValueDB varchar(4000)
	     
	SELECT @LogSPData = '<Acc_CustomerUpdSuperGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
						'v255discount_1701="' + COALESCE(CAST(@v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


	SELECT @TrackingValueDB = '<Acc_CustomerUpdSuperGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
						'v255discount_1701="' + COALESCE(CAST(@db_v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

	--Log customer info 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID			= @UserID,
			@CustID			= @CustID,
			@ActionID		= 238,
			@TrackingValue	= @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration		= @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdSuperGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
						'v255discount_1701="' + COALESCE(CAST(@v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
						'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	    
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 238,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdSuperGoldDeluxe_Commission] TO [vnteam] AS [dbo]