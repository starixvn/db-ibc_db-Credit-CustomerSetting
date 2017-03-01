ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable152_41]
	@CustID					INT,
	@Disable152_41			BIT,
	@DisableDownlines152_41	BIT				= true, --Disable all downline
	@SubAccID				INT				= 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2)		= 'E',
	@ErrCode				INT				= 0 OUTPUT,
	@ErrMsg					NVARCHAR(200)	= '' OUTPUT,
	@IP						VARCHAR(15)		= ''
AS
/*
Created: 20110111@Lukas
Task : Update UK Greyhound racing status for customer
DB: DBTXN/bodb02
Original:

Revisions:    
	- 20110509@Johnson: update error message for Thai version.
	- 20110709@Johnson: Change to use new server BD053 instead DB052
	- 20121128@Elodie: Get an error message from f_Get_MsgNameByMsgID function by language
	- 20130226@Johnson: change linked server DB053 to DBAGE and write log on DBTXN if DBLOG failure
	- 20150606@Elodie: Separate CustDB to DBCUST server (Move Acc_CustomerSelCheckEnable to DBCUST.CustDB)
Param's Explanation:
â€¢ @custid: customer id.   

*/
BEGIN
	SET NOCOUNT ON

	DECLARE	@startRun	DATETIME,
			@endRun		DATETIME,
			@duration	INT
	SET @startRun = GETDATE()

	--Check disable user
	EXEC Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
	IF @ErrCode <>0 
		RETURN 
	--end
	DECLARE @RoleID TINYINT, 
			@UplineDisable152_41 BIT, 
			@Old_Disable152_41 BIT

	SELECT	@RoleID = RoleID,
			@Old_Disable152_41 = ISNULL(Disable152_UK, 0)
	FROM	Custinfo WITH(nolock)
	WHERE	CustID = @CustID

	IF @RoleID NOT IN (1,2,3,4)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid user!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](40002,@Language)
						END, @ErrCode = 100	
		RETURN
	END

	--current status change or not?
	-- Qui.Nguyen add "and @IsUpdDownline = 0" for wap
	-- Remove @IsUpdDownline

	if @Old_Disable152_41 = @Disable152_41 RETURN--and @IsUpdDownline = 0
	--begin
		--rase message if Account was already disabled!
	--	if (@DisableOpenTote = 1 AND @UplineDisableOpenTote = 1)
	--	begin
	--		SELECT @ErrMsg =  CASE @Language 
	--							WHEN 'E' THEN 'Your account was disabled Horse Racing betting. Cannot edit customer.'
	--							WHEN 'CS' THEN N'èµ›é©¬æŠ•æ³¨ç›®å‰å·²è¢«ä¸Šçº¿é™åˆ¶ã€‚æ— æ³•ä¿®æ”¹ä¼šå‘˜ã€‚'
	--							WHEN 'CT' THEN N'è³½é¦¬æŠ•æ³¨ç›®å‰å·²è¢«ä¸Šç·šé™åˆ¶ã€‚ç„¡æ³•ä¿®æ”¹æœƒå“¡ã€‚'
	--							WHEN 'TH' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'							
	--							WHEN 'J' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
	--							WHEN 'KO' THEN N'Your account was disabled Horse Racing betting. Cannot edit customer.'
	--							ELSE N'Your account was disabled Horse Racing betting. Cannot edit customer.'
	--						END
	--	end
	--
	--	return
	--end

	IF @Disable152_41 = 0 -- check status upline
	BEGIN
		IF @RoleID = 3
			SELECT @UplineDisable152_41 = ISNULL(Disable152_UK,0) FROM CustInfo WITH(nolock)
			WHERE custid = (SELECT SRecommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisable152_41 = ISNULL(Disable152_UK,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT MRecommend FROM Custinfo WITH(nolock) WHERE custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisable152_41 = ISNULL(Disable152_UK,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT Recommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 4 SELECT @UplineDisable152_41 = 0   --not checking the upline when the customer is the super
			
		IF @UplineDisable152_41 = 1
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Account disabled for UK Greyhound. Unable to edit downlines.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](60009,@Language)
							END, @ErrCode = 105
			RETURN
		END 
	END



	---------------------

	UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
	SET		Disable152_UK = @Disable152_41
	WHERE	CustID = @CustID
	if (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg =
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						END	, @ErrCode = 101
		RETURN
	END
	--Check condition for update all downline
	IF (@Disable152_41 = 1 or (@Disable152_41 = 0 and @DisableDownlines152_41 = 0)) --Disable all downline or enable all downline
	BEGIN
		IF @RoleID = 4 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable152_UK = @Disable152_41
			WHERE SRecommend = @CustID

			IF (@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 102
				RETURN
			END
		END

		IF @RoleID = 3 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET		Disable152_UK = @Disable152_41 
			WHERE	MRecommend = @CustID
			IF(@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 103
				RETURN
			END
		END

		IF @RoleID = 2 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable152_UK = @Disable152_41
			WHERE Recommend = @CustID

			IF(@@ERROR <> 0)
			BEGIN
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
							END	, @ErrCode = 104
				RETURN
			END
		END
	END

	DECLARE @LogSPData VARCHAR(MAX)

	SELECT @LogSPData = '<Acc_CustomerUpdDisable152_41 CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Disable152_41="'+ COALESCE(CAST(@Disable152_41 AS VARCHAR(50)),SPACE(1)) + '" '+
						'DisableDownline152_41="'+ COALESCE(CAST(@DisableDownlines152_41 AS VARCHAR(50)),SPACE(1)) + '" '+
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
						'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1))+'" '+
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF(millisecond,@startRun,@endRun)

	/*1126	Acc_CustomerUpdDisable152_UK	Update Enabled/Disabled UK Greyhound racing status*/
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1126,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END TRY
	BEGIN CATCH		
		SELECT @LogSPData = '<Acc_CustomerUpdDisable152_41 CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+
							'Disable152_41="'+ COALESCE(CAST(@Disable152_41 AS VARCHAR(50)),SPACE(1)) + '" '+
							'DisableDownline152_41="'+ COALESCE(CAST(@DisableDownlines152_41 AS VARCHAR(50)),SPACE(1)) + '" '+
							'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
							'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
							'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
							'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
							'ErrMsg="'+ ERROR_MESSAGE() +'" '+
							'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'
							
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 1126,
			@TrackingValue = @LogSPData,
			@duration = @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet152_41] TO [bodbAdminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet152_41] TO [bodbDownlineNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustomerUpdAgent_MinMaxBet152_41] TO vnteam
