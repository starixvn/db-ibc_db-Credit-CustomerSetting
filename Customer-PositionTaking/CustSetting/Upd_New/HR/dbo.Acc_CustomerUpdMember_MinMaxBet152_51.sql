
ALTER PROCEDURE [dbo].[Acc_CustomerUpdMember_MinMaxBet152_51]
	@custid			INT,-- MemberID
	@minbet			MONEY,
	@maxbet			MONEY,
	@maxpermatch	MONEY,
	@UpdateMultiple BIT	= 0,	
	@SubAccID		INT = 0, --Sub-AccountID	
	@UserID			INT = 0,	
	@Language		VARCHAR(2)		= 'E',
	@IP				VARCHAR(15)		='',
	@ErrCode		INT				= 0 OUTPUT,
	@ErrMsg			NVARCHAR(4000)	= '' OUTPUT
AS

/*
Created: 20110121@Lukas
Task : Update member's minbet, maxbet, max per match for Greyhound racing
DB: DBTRANS.bodb02

Revisions:
	- 20110518@Johnson: write log for old setting
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130227@Johnson: write log on DBTXN if DBLOG failure
Param's Explanation:
• @ErrCode:
    = 0: Transaction recorded successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	declare @startRun datetime,
			@endRun datetime,
			@duration int,
			@minbet_old money,
			@maxbet_old money,
			@maxpermatch_old money

	SET @startRun = getdate()

	DECLARE @MinMinBet		MONEY, 
			@MaxMaxBet		MONEY,	
			@MaxMaxPerMatch MONEY
		
	DECLARE @ErrAcc		VARCHAR(4000), 
			@ErrType	VARCHAR(4000),
			@UserName	VARCHAR(30), 
			@recommend	INT
			
	SELECT @UserName = username, @recommend = recommend
	FROM customer WITH (NOLOCK)
	WHERE roleid = 1 and CustID = @CustID

	IF (@username = NULL) RETURN

	---------------------------------------------------------------
	--Check Param
	IF @UpdateMultiple = 0
	BEGIN
		IF 
			@MinBet<0
			or @MaxBet < 0
			or @MaxPerMatch <0		
		BEGIN
			SELECT @ErrCode = 2
			SELECT @ErrMsg = 	CASE @Language 
								WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10003,@Language)
						END
			RETURN
		END
	END
	---------------------------------------------------------------

	SELECT
		@MinMinBet = MAX(CASE WHEN MinBet = 0 THEN NULL ELSE MinBet END), 
		@MaxMaxBet = MIN(CASE WHEN MaxBet = 0 THEN NULL ELSE MaxBet END)
	FROM 
		CustSetting3rd AS cs WITH (NOLOCK)
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
		and cs.bettype = 51 and cs.sporttype=152
	where ci.custid = @recommend


	SELECT @MaxMaxperMatch = MIN(CASE WHEN cs.MaxPerMatch152_AU = 0 THEN NULL ELSE cs.MaxPerMatch152_AU END)
	FROM
		custinfo AS cs WITH (NOLOCK) 
		INNER JOIN custinfo AS ci WITH (NOLOCK) ON (cs.CustID = ci.Recommend or cs.CustID = ci.MRecommend or cs.CustID = ci.SRecommend)
	WHERE ci.custid = @recommend

	IF @UpdateMultiple = 0
	BEGIN
		IF (@MinBet<>0 and  @MinBet>@MaxBet) or (@MaxBet<> 0 and @MaxBet>@MaxPerMatch) 
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language)
							END						
							+ CHAR(13) + CHAR(10) + CONVERT(VARCHAR(20), @MinBet) + '-' + CONVERT(VARCHAR(20), @MaxBet) + '-' + CONVERT(VARCHAR(20), @MaxPerMatch), @ErrCode = 108				
			RETURN			
		END
		
		IF (@MinMinBet>0 AND @MinBet>0 AND @MinBet<@MinMinBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': ' +
							CASE @Language 
								WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10006,@Language)
							END						
							+' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').', @ErrCode = 109
					
			RETURN
		END
		
		IF (@MaxMaxBet>0 AND @MaxBet>0 AND @MaxBet>@MaxMaxBet)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10007,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').', @ErrCode = 110
					
			return
		END
		
		IF (@MaxMaxPerMatch>0 AND @MaxPerMatch>0 AND @MaxPerMatch>@MaxMaxPerMatch)
		BEGIN
			SELECT @ErrMsg =	@UserName + ': '+
							CASE @Language 
								WHEN 'E' THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10008,@Language)
							END						
							+'(' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').', @ErrCode = 110					
			RETURN
		END

	END

SELECT @minbet_old = MinBet, @maxbet_old = MaxBet
FROM custsetting3rd WITH(NOLOCK)
WHERE custid = @custid and sporttype = 152 and bettype = 51

SELECT @maxpermatch_old = maxpermatch152_AU FROM custinfo WITH(NOLOCK) WHERE custid = @custid

IF @MinBet <> @minbet_old OR @MaxBet <> @maxbet_old
BEGIN
	UPDATE CustSetting3rd WITH (ROWLOCK, UPDLOCK)
	SET
		MinBet=CASE WHEN @UpdateMultiple = 1 THEN MinBet ELSE @MinBet END,
		MaxBet=CASE WHEN @UpdateMultiple = 1 THEN MaxBet ELSE @MaxBet END
	WHERE custid=@custid AND sporttype = 152 and bettype in(51,52)
	IF (@@ERROR <> 0)
	BEGIN

		SELECT @ErrMsg = @UserName + ': '+
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END, @ErrCode = 115
		RETURN
	END
END

IF @MaxPerMatch <> @maxpermatch_old
BEGIN
	EXEC dbo.Acc_CustomerUpdMaxPerMatch152_51
		@custid		= @custid,
		@MaxPerMatch= @MaxPerMatch,
		@Language	= @Language,
		@ErrCode	= @ErrCode OUTPUT,
		@ErrMsg		= @ErrMsg OUTPUT
		IF @ErrCode > 0
		BEGIN
			return
		END
END
	/*319	Acc_CustomerUpdMember_MinMaxBetOpenTote	Update Horse racing Bet Setting for member*/	



	DECLARE @LogSPData VARCHAR(MAX),
			@TrackingValueDB varchar(4000)
			
	SELECT @LogSPData ='<Acc_CustomerUpdMember_MinMaxBet152_51 custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinB="'+ COALESCE(CAST(@minbet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxB="'+ COALESCE(CAST(@maxbet AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPM="'+ COALESCE(CAST(@maxpermatch AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UpdMultiple="'+ COALESCE(CAST(@UpdateMultiple AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'
	
	SELECT @TrackingValueDB ='<Acc_CustomerUpdMember_MinMaxBet152_51 custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MinB="'+ COALESCE(CAST(@minbet_old AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MaxB="'+ COALESCE(CAST(@maxbet_old AS VARCHAR(50)),SPACE(1)) + '" ' +
	'MPM="'+ COALESCE(CAST(@maxpermatch_old AS VARCHAR(50)),SPACE(1)) + '" ' +
	'UpdMultiple="'+ COALESCE(CAST(@UpdateMultiple AS VARCHAR(50)),SPACE(1)) + '" ' +
	'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
	'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
	'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
	'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
	'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
	'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(5000)),SPACE(1)) + '" />'

	SET @endRun = getdate()
	SET @duration  = datediff (millisecond,@startRun,@endRun)
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 332,
			@TrackingValue = @LogSPData	,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData ='<Acc_CustomerUpdMember_MinMaxBet152_51 custid="'+ COALESCE(CAST(@custid AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MinB="'+ COALESCE(CAST(@minbet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MaxB="'+ COALESCE(CAST(@maxbet AS VARCHAR(50)),SPACE(1)) + '" ' +
		'MPM="'+ COALESCE(CAST(@maxpermatch AS VARCHAR(50)),SPACE(1)) + '" ' +
		'UpdMultiple="'+ COALESCE(CAST(@UpdateMultiple AS VARCHAR(50)),SPACE(1)) + '" ' +
		'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" ' +
		'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" ' +
		'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1)) + '" ' +
		'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1)) + '" ' +
		'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" ' +
		'ErrMsg="'+ ERROR_MESSAGE() + '" />'
		
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 332,
			@TrackingValue = @LogSPData	,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBet152_51] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdMember_MinMaxBet152_51] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdMember_MinMaxBet152_51] TO [vnteam]