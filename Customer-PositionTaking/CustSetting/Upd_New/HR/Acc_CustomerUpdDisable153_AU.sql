 
ALTER PROCEDURE [dbo].[Acc_CustomerUpdDisable153_AU]
	@CustID					INT,
	@Disable153_AU			BIT,
	@DisableDownline153_AU	BIT				= true, --Disable all downline
	@SubAccID				INT				= 0, --Sub-AccountID
	@UserID					INT,
	@Language				VARCHAR(2)		= 'E',
	@ErrCode				INT				= 0 OUTPUT,
	@ErrMsg					NVARCHAR(200)	= '' OUTPUT,
	@IP						VARCHAR(15)		= ''
AS
/*
Created: 20110111@Lukas
Task : Update AU Harness status for customer
DB: DB02.bodb02
Original:

Revisions:    

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
	EXEC DB052.bodb02.dbo.Acc_CustomerSelCheckEnable @custid = @custid, @ErrCode=@ErrCode OUTPUT,@ErrMsg=@ErrMsg OUTPUT
	IF @ErrCode <>0 
		RETURN 
	--end
	DECLARE @RoleID TINYINT, 
			@UplineDisable153_AU BIT,
			@Old_Disable153_AU BIT

	SELECT	@RoleID = RoleID,
			@Old_Disable153_AU = ISNULL(Disable153_AU, 0)
	FROM	Custinfo WITH(nolock)
	WHERE	CustID = @CustID

	IF @RoleID NOT IN (1,2,3,4)
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Invalid user!'
							WHEN 'CS' THEN N'账号无效!'
							WHEN 'CT' THEN N'帳號無效.!'
							WHEN 'TH' THEN N'ผู้ใช้ไม่ถูกต้อง!'
							WHEN 'J' THEN N'Invalid user!'
							WHEN 'KO' THEN N'잘못된 사용자 입니다.'
							ELSE N'Invalid user!'
						END, @ErrCode = 100	
		RETURN
	END

	--current status change or not?
	-- Qui.Nguyen add "and @IsUpdDownline = 0" for wap
	-- Remove @IsUpdDownline

	if @Old_Disable153_AU = @Disable153_AU RETURN--and @IsUpdDownline = 0
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

	IF @Disable153_AU = 0 -- check status upline
	BEGIN
		IF @RoleID = 3
			SELECT @UplineDisable153_AU = ISNULL(Disable153_AU,0) FROM CustInfo WITH(nolock)
			WHERE custid = (SELECT SRecommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 2
			SELECT @UplineDisable153_AU = ISNULL(Disable153_AU,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT MRecommend FROM Custinfo WITH(nolock) WHERE custid = @CustID)
		IF @RoleID = 1
			SELECT @UplineDisable153_AU = ISNULL(Disable153_AU,0) FROM CustInfo WITH(NOLOCK)
			WHERE custid = (SELECT Recommend FROM Custinfo WITH(NOLOCK) WHERE custid = @CustID)
		IF @RoleID = 4 SELECT @UplineDisable153_AU = 0   --not checking the upline when the customer is the super
			
		IF @UplineDisable153_AU = 1
		BEGIN
			SELECT @ErrMsg =  CASE @Language 
								WHEN 'E' THEN 'Your account was disabled Horse Racing AU Tote betting. Cannot edit customer.'
								WHEN 'CS' THEN N'赛马投注目前已被上线限制。无法修改会员。'
								WHEN 'CT' THEN N'賽馬投注目前已被上線限制。無法修改會員。'
								WHEN 'TH' THEN N'Your account was disabled Horse Racing AU Tote betting. Cannot edit customer.'			
								WHEN 'J' THEN N'Your account was disabled Horse Racing AU Tote betting. Cannot edit customer.'
								WHEN 'KO' THEN N'Your account was disabled Horse Racing AU Tote betting. Cannot edit customer.'
								ELSE N'Your account was disabled Horse Racing AU Tote betting. Cannot edit customer.'
							END, @ErrCode = 105
			RETURN
		END 
	END



	---------------------

	UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
	SET		Disable153_AU = @Disable153_AU
	WHERE	CustID = @CustID
	if (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg =
						CASE @Language 
							WHEN 'E' THEN 'Update process is unsuccessful.'
							WHEN 'CS' THEN N'更新程序不成功。'
							WHEN 'CT' THEN N'更新程序不成功。'
							WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น'
							WHEN 'J' THEN N'アップデート出来ません。'
							WHEN 'KO' THEN N'업데이트에 실패했습니다.'
							ELSE N'Update process is unsuccessful.'
						END	, @ErrCode = 101
		RETURN
	END
	--Check condition for update all downline
	IF (@Disable153_AU = 1 or (@Disable153_AU = 0 and @DisableDownline153_AU = 0)) --Disable all downline or enable all downline
	BEGIN
		IF @RoleID = 4 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable153_AU = @Disable153_AU 
			WHERE SRecommend = @CustID

			IF (@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								WHEN 'CS' THEN N'更新程序不成功。'
								WHEN 'CT' THEN N'更新程序不成功。'
								WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น'
								WHEN 'J' THEN N'アップデート出来ません。'
								WHEN 'KO' THEN N'업데이트에 실패했습니다.'
								ELSE N'Update process is unsuccessful.'
							END	, @ErrCode = 102
				RETURN
			END
		END

		IF @RoleID = 3 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET		Disable153_AU = @Disable153_AU 
			WHERE	MRecommend = @CustID
			IF(@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								WHEN 'CS' THEN N'更新程序不成功。'
								WHEN 'CT' THEN N'更新程序不成功。'
								WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น'
								WHEN 'J' THEN N'アップデート出来ません。'
								WHEN 'KO' THEN N'업데이트에 실패했습니다.'
								ELSE N'Update process is unsuccessful.'
							END	, @ErrCode = 103
				RETURN
			END
		END

		IF @RoleID = 2 
		BEGIN
			UPDATE CustInfo WITH(ROWLOCK, UPDLOCK) 
			SET Disable153_AU = @Disable153_AU 
			WHERE Recommend = @CustID

			IF(@@ERROR <> 0)
			BEGIN				
				SELECT @ErrMsg = 
							CASE @Language 
								WHEN 'E' THEN 'Update process is unsuccessful.'
								WHEN 'CS' THEN N'更新程序不成功。'
								WHEN 'CT' THEN N'更新程序不成功'
								WHEN 'TH' THEN N'ขั้นตอนหรือกระบวนการในการปรับยอดไม่เสร็จสิ้น'
								WHEN 'J' THEN N'アップデート出来ません。'
								WHEN 'KO' THEN N'업데이트에 실패했습니다.'
								ELSE N'Update process is unsuccessful.'
							END	, @ErrCode = 104
				RETURN
			END
		END
	END

	DECLARE @LogSPData VARCHAR(2000)

	SELECT @LogSPData = '<Acc_CustomerUpdDisable153_AU CustID="'+ COALESCE(CAST(@CustID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Disable153_AU="'+ COALESCE(CAST(@Disable153_AU AS VARCHAR(50)),SPACE(1)) + '" '+
						'DisableDownline153_AU="'+ COALESCE(CAST(@DisableDownline153_AU AS VARCHAR(50)),SPACE(1)) + '" '+
						'SubAccName="'+ COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)),SPACE(1)) + '" '+
						'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)),SPACE(1)) + '" '+
						'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)),SPACE(1))+'" '+
						'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)),SPACE(1)) + '" '+
						'ErrMsg="'+ COALESCE(CAST(@ErrMsg AS VARCHAR(400)),SPACE(1))+'" '+
						'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)),SPACE(1))+'" />'

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF(millisecond,@startRun,@endRun)

	/*1128	Acc_CustomerUpdDisable153_AU	Update Enabled/Disabled AU Horse racing status*/
	EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 1128,
		@TrackingValue = @LogSPData,
		@duration = @duration
END