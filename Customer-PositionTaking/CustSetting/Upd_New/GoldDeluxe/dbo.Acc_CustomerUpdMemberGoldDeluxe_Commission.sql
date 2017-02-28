ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Commission]
	@custid		INT,	
	@v255playerdiscount_1701	DECIMAL(9,8),
	
	@SubAccID	INT = 0 ,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: Elodie
	Date: 20150422
	Task: Update commission on member
	DB: DBTXN/CustDB
		
	Revisions:
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
	Parameters Explanation:
*/ 
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	set @startRun = getdate()

	DECLARE @db_v255playerdiscount_1701 DECIMAL(9,8), @v255discount_1701 DECIMAL(9,8),
			@srecommend INT, @mrecommend INT, @recommend INT, @roleid INT

	SELECT @srecommend = srecommend, @mrecommend = mrecommend , @recommend = recommend, @roleid = roleid
	FROM CustInfo WITH(NOLOCK)
	WHERE CustID = @custid
		            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	SELECT @db_v255playerdiscount_1701 = playerdiscount
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @custid AND sporttype = 255 AND bettype = 1701

	SELECT @v255discount_1701 = discount 
	FROM CustSettingGame WITH(NOLOCK)
	WHERE custid = @recommend AND sporttype = 255 AND bettype = 1701 

	IF @v255playerdiscount_1701 < 0 OR (@v255playerdiscount_1701 > 0.01)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid commission rate.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
						END, @ErrCode = 101
		RETURN
	END

	IF @v255playerdiscount_1701 = @db_v255playerdiscount_1701
		RETURN

	
	SELECT @v255playerdiscount_1701 = CASE WHEN @v255playerdiscount_1701 > @v255discount_1701 THEN @v255discount_1701 ELSE @v255playerdiscount_1701 END

	-- Apply exec rep
	EXEC dbo.Acc_CustSetting3rd_06
			@CustId				= @custid,
			@RoleId				= @roleid,
			@discount			= @v255playerdiscount_1701,	
			@mode				= 'GoldDeluxe',				
			@SportType			= 255,
			@BetType			= 1701	

	DECLARE @LogSPData varchar(MAX)
	DECLARE @TrackingValue2 varchar(5000)

	SELECT @LogSPData = '<Acc_CustomerUpdMemberGoldDeluxe_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
						'v255playerdiscount_1701 ="' + COALESCE(CAST(@v255playerdiscount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	SELECT @TrackingValue2 =	'<Acc_CustomerUpdMemberGoldDeluxe_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
								'v255playerdiscount_1701 ="' + COALESCE(CAST(@db_v255playerdiscount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
								'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
								'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
								'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
								'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
								'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
								'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (millisecond,@startRun,@endRun)

	--Log customer info 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 241,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberGoldDeluxe_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
							'v255playerdiscount_1701 ="' + COALESCE(CAST(@v255playerdiscount_1701 AS VARCHAR(50)),SPACE(1)) + '" ' +
							'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
							'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
							'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
							'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
							'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
							'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 241,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValue2,
			@duration = @duration
	END CATCH	
END

GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Commission] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Commission] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Commission] TO [bodbExtAccNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberGoldDeluxe_Commission] TO [bodbDownlineNet]