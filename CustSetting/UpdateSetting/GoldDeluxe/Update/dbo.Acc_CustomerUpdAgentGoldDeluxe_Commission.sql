ALTER PROCEDURE [dbo].[Acc_CustomerUpdAgentGoldDeluxe_Commission]
	@custid				INT,
	@v255discount_1701	DECIMAL(9,8),
	@UserID				INT, 
	@SubAccID			INT,
	@Language			VARCHAR(10), 
	@IP					VARCHAR(21),  
	@ErrCode			INT = 0 OUTPUT, 
	@ErrMsg				NVARCHAR(200) = '' OUTPUT
AS
/*
	Created: 20150423@Elodie
	Task: update agent Gold Deluxe setting - commission
	DB: DBTXN/CustDB
	
	Revisions:		
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
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
			@db_v255discount_1701	DECIMAL(9,8),
			@roleid					INT 

	SELECT	@UserName	= username, 
			@mrecommend = mrecommend,
			@roleid = roleid
	FROM customer WITH(NOLOCK) 
	WHERE CustID = @CustID
	
	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,@roleid,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	SELECT  @db_v255discount_1701 = discount	
	FROM CustSettingGame WITH(NOLOCK) 
	WHERE custid = @custid 
		AND bettype = 1701 
		AND sporttype = 255
	
	--check if not change setting
	IF 	@db_v255discount_1701 = @v255discount_1701
		RETURN
		
	IF @v255discount_1701 < 0 AND @v255discount_1701 > 0.01	
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN N'Invalid commission rate (Gold Deluxe)'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](1,@Language) + ' (' + [dbo].[f_Get_SportNameBySporttype](255,@Language) + ')'
						END, 
				@ErrCode = 101
		RETURN
	END
	
	--Get g2=g3 if g2>g3	
	SELECT @v255discount_1701 = CASE WHEN @v255discount_1701 > adiscount THEN adiscount ELSE @v255discount_1701 END
	FROM CustSettingGame AS cs WITH (NOLOCK) 
	WHERE custid = @mrecommend 
		AND bettype = 1701 AND sporttype = 255
		
	
	-- apply exec rep
	EXEC Acc_CustSetting3rd_06
		@CustId = @custid
		,@RoleId = @roleid
		,@discount = @v255discount_1701
		,@mode = 'GoldDeluxe'
		,@SportType = 255
		,@BetType = 1701
	
	SET @endRun = GETDATE()
	set @duration  = DATEDIFF(MILLISECOND,@startRun,@endRun)

	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB VARCHAR(4000)
			
	SELECT @LogSPData = '<Acc_CustomerUpdAgentGoldDeluxe_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
						'discount255_1701="'+ coalesce(cast(@v255discount_1701 as varchar(50)),space(1))+ '" ' +
						'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
						'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
						'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
						'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
						'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
						'ErrMsg="'+ coalesce(cast(@ErrMsg as varchar(5000)),space(1)) + '" />'


	Select @TrackingValueDB =	'<Acc_CustomerUpdAgentGoldDeluxe_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
								'discount255_1701="'+ coalesce(cast(@db_v255discount_1701 as varchar(50)),space(1))+ '" ' +
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
			@ActionID = 240,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration  = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdAgentGoldDeluxe_Commission custid="'+ coalesce(cast(@custid as varchar(50)),space(1))+ '" ' +
		'discount255_1701="'+ coalesce(cast(@v255discount_1701 as varchar(50)),space(1))+ '" ' +
		'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1))+ '" ' +
		'SubAccName="'+ coalesce(cast(dbo.f_GetSubUsername(@SubAccID) as varchar(30)),space(1))+ '" ' +
		'Language="'+ coalesce(cast(@Language as varchar(2)),space(1))+ '" ' +
		'IP="'+ coalesce(cast(@IP as varchar(15)),space(1))+ '" ' +
		'ErrCode="'+ coalesce(cast(@ErrCode as varchar(50)),space(1))+ '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 240,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration  = @duration
	END CATCH
		

END
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_Commission] TO [bodbAdminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_Commission] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_Commission] TO [bodbExtAccNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgentGoldDeluxe_Commission] TO [vnteam] AS [dbo]