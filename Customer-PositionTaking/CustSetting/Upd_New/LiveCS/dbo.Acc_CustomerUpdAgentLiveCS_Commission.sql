ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentLiveCS_Commission]
(
	@custid				INT,
	@v162discount_1101	DECIMAL(9,8),
	@UserID				INT, 
	@SubAccID			INT,
	@Language			VARCHAR(10), 
	@IP					VARCHAR(21),  
	@ErrCode			INT = 0 OUTPUT, 
	@ErrMsg				NVARCHAR(200) = '' OUTPUT
)
AS
/*
	Created: 20120103@Lukas
	Task: update agent live CS setting - commission
	DB: DBTXN/BODB02
	
	Revisions:
		- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
		- 20130301@Johnson: write log on DBTXN if DBLOG failure
		- 20131031@Kathy: Apply exec rep to update commission [Redmine:#3244]
		- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckAllowedDownlines to DBCUST.CustDB)

	Parameters Explanation:
*/
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @startRun	DATETIME,
			@endRun		DATETIME,
			@duration	INT
			
	SET @startRun = GETDATE()
	
	DECLARE @username				NVARCHAR(50), 
			@mrecommend				INT , 
			@db_v162discount_1101	DECIMAL(9,8),
			@roleid					INT 

	SELECT	@UserName	= username, 
			@mrecommend = mrecommend,
			@roleid = roleid
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @CustID
	
	--Check Allowed downlines	
	EXEC Acc_CustomerSelCheckAllowedDownlines	@custid=@custid,
				@roleid=@roleid,
				@isExecRep=1,
				@isUpdatePT = 1,
				@Sporttype = 1,
				@Language='E',
				@ErrMsg=@ErrMsg output,
				@ErrCode=@ErrCode output
	IF	@ErrCode <> 0 
		RETURN 
		
	
	SELECT  @db_v162discount_1101 = discount	
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @custid 
		AND bettype = 1101 
		AND sporttype = 162
	
	--check if not change setting
	IF 	@db_v162discount_1101 = @v162discount_1101
		RETURN
		
	IF @v162discount_1101 < 0 AND @v162discount_1101 > 0.01	
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN N'Invalid commission rate (Live Casino)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](162,@Language) + ')'
						END, 
				@ErrCode = 101
		RETURN
	END
	
	--Get g2=g3 if g2>g3	
	SELECT @v162discount_1101 = CASE WHEN @v162discount_1101 > adiscount THEN adiscount ELSE @v162discount_1101 END
	FROM CustSettingGame AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend 
		AND bettype = 1101 AND sporttype = 162
		
	
	-- apply exec rep
	EXEC Acc_CustSetting3rd_06
	@CustId = @custid,
	@RoleId = @roleid,
	@v162discount_1101 = @v162discount_1101,
	@mode = 'LiveCasino'
	
	SET @endRun = GETDATE()
	set @duration  = DATEDIFF(MILLISECOND,@startRun,@endRun)

	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(4000)
			
	SELECT @LogSPData = '<Acc_CustomerUpdAgentLiveCS_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'discount162_1101="'+ coalesce(cast(@v162discount_1101 as varchar(50)),space(1))+ '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'


	Select @TrackingValueDB = '<Acc_CustomerUpdAgentLiveCS_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
	'discount162_1101="'+ coalesce(cast(@db_v162discount_1101 as varchar(50)),space(1))+ '" ' +
	'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
	'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
	'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
	'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
	'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
	'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'

	--Log customer info 
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 226,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration  = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdAgentLiveCS_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'discount162_1101="'+ coalesce(cast(@v162discount_1101 as varchar(50)),space(1))+ '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 226,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration  = @duration
	END CATCH
		

END


GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentLiveCS_Commission] TO [vnteam]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_Commission] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentLiveCS_Commission] TO [bodbDownlineNet]