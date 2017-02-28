USE [CustDB]
GO
/****** Object:  StoredProcedure [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission]    Script Date: 04/27/2015 15:54:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
 ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission]
    @custid					INT,
    @v255discount_1701      DECIMAL(9,8),
    
    @SubAccID				INT				= 0,
    @IP						VARCHAR(50)		='',    
    @UserID					INT				= 0,
    @Language				VARCHAR(20)		= 'E',        
    @ErrCode				INT				= 0		OUTPUT,
    @ErrMsg					NVARCHAR(4000)	= ''	OUTPUT
AS
    /*
        Created: Kathy
        Date: 20150424
        DB: DBTXN/custdb
        Task: Update commission on master
        
        Revisions:
			- 20150610@Elodie: Migrate custDB to new server DBCust (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)
			- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]	  
        Parameters Explanation:
    */
BEGIN
	
	SET NOCOUNT ON

	DECLARE @startRun	DATETIME
			,@endRun	DATETIME
			,@duration	INT

	SET @startRun = GETDATE()

	DECLARE @roleid					TINYINT
			,@ErrCode_Cur			INT
			,@ErrMsg_Cur			NVARCHAR(4000)
			,@ErrAcc				NVARCHAR(4000)
			,@db_v255discount_1701	DECIMAL(9,8)
	    
	SELECT	@ErrCode_Cur	= 0
			,@ErrMsg_Cur	= ''
			,@ErrCode		= 0
			,@ErrMsg		= ''

	SELECT	@db_v255discount_1701 = adiscount
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @custid 
			AND sporttype	= 255 
			AND bettype		= 1701

	IF @v255discount_1701 = @db_v255discount_1701
		RETURN 
	    
	IF @v255discount_1701 < 0 OR @v255discount_1701 > 0.01
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
						 END
						 ,@ErrCode = 100
		RETURN
	END

	---------------------------------------
	DECLARE @srecommend		INT
			,@username		NVARCHAR(50)

	SELECT	@srecommend	= srecommend 
			,@username	= username
			,@roleid	= roleid
	FROM	dbo.CustInfo WITH(NOLOCK)
	WHERE	custid = @custid

	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	--Check Allowed downlines    
	EXEC Acc_CustomerSelCheckAllowedDownlines    
		@custid		= @custid,
		@roleid		= @roleid,
		@isExecRep	= 1,
		@isUpdatePT = 1,
		@Sporttype	= 1,
		@Language	= 'E',
		@ErrMsg		= @ErrMsg	OUTPUT,
		@ErrCode	= @ErrCode	OUTPUT
		
	IF  @ErrCode <> 0 
		RETURN 
	        
	SELECT	@v255discount_1701 = CASE WHEN @v255discount_1701 > sdiscount THEN sdiscount 
									 ELSE @v255discount_1701 
								 END
	FROM	CustSettingGame WITH(NOLOCK)
	WHERE	custid = @srecommend 
			AND sporttype = 255 
			AND bettype = 1701

	-- Apply exec rep
	EXEC Acc_CustSetting3rd_06
	@CustId = @custid,
	@RoleId = @roleid,
	@Discount = @v255discount_1701,
	@mode = 'GoldDeluxe',
	@Sporttype = 255,
	@Bettype = 1701	
	    
	DECLARE @LogSPData			VARCHAR(MAX),
			@TrackingValueDB	VARCHAR(4000)
	     
	SELECT @LogSPData = '<Acc_CustomerUpdMasterGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255discount_1701="' + COALESCE(CAST(@v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
					'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
					'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
					'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
					'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'


	SELECT @TrackingValueDB = '<Acc_CustomerUpdMasterGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
					'v255discount_1701="' + COALESCE(CAST(@db_v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
					'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
					'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
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
			@ActionID		= 239,
			@TrackingValue	= @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration		= @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMasterGoldDeluxe_Commission Custid ="' + COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' + 
		'v255discount_1701="' + COALESCE(CAST(@v255discount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
		'userid="' + COALESCE(CAST(@userid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	    
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID			= @UserID,
			@CustID			= @CustID,
			@ActionID		= 239,
			@TrackingValue	= @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration		= @duration
	END CATCH


END



GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMasterGoldDeluxe_Commission] TO [vnteam] AS [dbo]