

ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberLiveCS_Commission]
	@custid		INT,	
	@v162playerdiscount_1101	DECIMAL(9,8),
	
	@SubAccID	INT = 0 ,
	@IP			VARCHAR(50)='',	
	@UserID		INT = 0,
	@Language	VARCHAR(20) = 'E',		
	@ErrCode	VARCHAR(300) = '' OUTPUT,
	@ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 17Jan2012
		Task: Update commission on member
		DB: DBTXN/BODB02
		
		Revisions:
			- 20120622@Lukas: Update sdiscount, adiscount, discount in case of manually sync
			- 20121002@Kiwi: Hardcode for super SLAM can have 0.022 comm
			- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
			- 20130301@Johnson: write log on DBTXN if DBLOG failure
			- 20141114@Johnson: Apply execrep when update commission on member [Redmine: #25787]
		Parameters Explanation:
	*/ 
SET NOCOUNT ON

declare @startRun datetime
declare @endRun datetime
declare @duration int
set @startRun = getdate()

DECLARE @db_v162playerdiscount_1101 DECIMAL(9,8), @v162discount_1101 DECIMAL(9,8), @v162adiscount_1101 DECIMAL(9,8), @v162sdiscount_1101 DECIMAL(9,8),
		@srecommend INT, @mrecommend INT, @recommend INT, @SyncLiveCasino BIT, @roleid INT

SELECT @srecommend = srecommend, @mrecommend = mrecommend , @recommend = recommend, @roleid = roleid,
	@SyncLiveCasino = SyncLiveCasino 
FROM CustInfo WITH(NOLOCK)
WHERE CustID = @custid

SELECT @db_v162playerdiscount_1101 = playerdiscount
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @custid AND sporttype = 162 AND bettype = 1101

SELECT @v162discount_1101 = discount 
FROM CustSettingGame WITH(NOLOCK)
WHERE custid = @recommend AND sporttype = 162 AND bettype = 1101 

IF @v162playerdiscount_1101 < 0 OR (@v162playerdiscount_1101 > 0.01 AND @srecommend <> 8156203)
BEGIN
	SELECT @ErrMsg = CASE @Language 
						WHEN 'E' THEN 'Invalid commission rate.'
						ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language)
					END, @ErrCode = 101
	RETURN
END

IF @v162playerdiscount_1101 = @db_v162playerdiscount_1101 AND @SyncLiveCasino = 1
	RETURN

IF @SyncLiveCasino = 1
BEGIN
	SELECT @v162playerdiscount_1101 = CASE WHEN @v162playerdiscount_1101 > @v162discount_1101 THEN @v162discount_1101 ELSE @v162playerdiscount_1101 END

	-- Apply exec rep
	exec dbo.Acc_CustSetting3rd_06
			@CustId						= @custid,
			@RoleId						= @roleid,
			@v162playerdiscount_1101	= @v162playerdiscount_1101,	
			@SyncLiveCasino				= @SyncLiveCasino,		
			@mode						= 'LiveCasino'			
END
ELSE
BEGIN 
	SELECT @v162adiscount_1101 = adiscount 
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE CustID = @mrecommend AND sporttype = 162 AND bettype = 1101
	
	SELECT @v162sdiscount_1101 = sdiscount
	FROM CustSettingGame WITH(NOLOCK)
	WHERE CustID = @srecommend AND sporttype = 162 AND bettype = 1101

	SELECT @v162adiscount_1101 = CASE WHEN @v162adiscount_1101 > @v162sdiscount_1101 THEN @v162sdiscount_1101 ELSE @v162adiscount_1101 END
	SELECT @v162discount_1101  = CASE WHEN @v162discount_1101 > @v162adiscount_1101 THEN @v162adiscount_1101 ELSE @v162discount_1101 END	
	SELECT @v162playerdiscount_1101 = CASE WHEN @v162playerdiscount_1101 > @v162discount_1101 THEN @v162discount_1101 ELSE @v162playerdiscount_1101 END
	
	-- Apply exec rep
	exec dbo.Acc_CustSetting3rd_06
			@CustId						= @custid,
			@RoleId						= @roleid,
			@v162sdiscount_1101			= @v162sdiscount_1101,
			@v162adiscount_1101			= @v162adiscount_1101,
			@v162discount_1101			= @v162discount_1101,
			@v162playerdiscount_1101	= @v162playerdiscount_1101,	
			@SyncLiveCasino				= @SyncLiveCasino,		
			@mode						= 'LiveCasino'	
	
END


Declare @LogSPData varchar(MAX)
Declare @TrackingValue2 varchar(5000)

SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
'v162playerdiscount_1101 ="' + COALESCE(CAST(@v162playerdiscount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1))+ '" />'

SELECT @TrackingValue2 = '<Acc_CustomerUpdMemberLiveCS_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
'v162playerdiscount_1101 ="' + COALESCE(CAST(@db_v162playerdiscount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
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
		@ActionID = 227,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END TRY
BEGIN CATCH
	SELECT @LogSPData = '<Acc_CustomerUpdMemberLiveCS_Commission custid ="' + CAST(@custid AS VARCHAR(50)) + '" ' +
	'v162playerdiscount_1101 ="' + COALESCE(CAST(@v162playerdiscount_1101 AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1)) + '" ' +
	'ErrMsg="'+ ERROR_MESSAGE() + '" />'
	
	EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 227,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @TrackingValue2,
		@duration = @duration
END CATCH	


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMemberLiveCS_Commission] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_Commission] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMemberLiveCS_Commission] TO [bodbDownlineNet]