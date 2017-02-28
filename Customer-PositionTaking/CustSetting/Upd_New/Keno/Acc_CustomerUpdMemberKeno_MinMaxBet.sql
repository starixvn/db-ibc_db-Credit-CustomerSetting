ALTER PROCEDURE [dbo].[Acc_CustomerUpdMemberKeno_MinMaxBet] 
	@CustID INT
	,@Bettype INT
	,@sporttype INT = 202

	,@MinBet MONEY
	,@MaxBet MONEY
	,@MaxPerMatch MONEY

	,@SubAccID INT = 0 --Sub-AccountID		
	,@UserID INT = 0
	,@Language VARCHAR(2) = 'E'
	,@IP VARCHAR(15) = ''
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20140319@Bobby
	Task : Update member's minbet, maxbet, max per match for Keno
	DB: DBTXN/CustDB

	Revisions:
        - 20141104@Logan:    Add constraint Member MinBet >= Global MinBet [Redmine: #25005]
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
		- 20160413@Dominic: HotFix - Alpha - Update Keno setting - No error alert when update minbet=0 and minbet <upline minbet [Redmine: #55596]				
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
	Param's Explanation:
	* @ErrCode:
		= 0: Transaction recorded successfully.
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON
----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
----- /David @ 09 JUN 2015 -------------------
	DECLARE @startRun DATETIME, @endRun DATETIME, @duration INT
	SELECT @ErrCode = 0, @ErrMsg = '', @startRun = GETDATE()

	DECLARE @Old_MinBet MONEY, @Old_MaxBet MONEY, @Old_MaxPerGame MONEY, @GameTypeID INT, @UserName VARCHAR(50), @mrecommend INT, @srecommend INT, @recommend INT, @currency INT
	DECLARE @MinMinBet MONEY, @MaxMaxBet MONEY, @MaxMaxPerMatch MONEY

	SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend, @recommend = recommend, @currency = currency
	FROM dbo.customer WITH (NOLOCK) WHERE CustID = @CustID AND roleid = 1

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,1,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END



	IF (@UserName IS NULL) RETURN

	IF @MinBet < 0 OR @MaxBet < 0 OR @MaxPerMatch < 0
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)
				END
			,@ErrCode = 101
		RETURN
	END

	--Check @MinBet <= @MaxBet <= @MaxPerMatch
	IF((@MinBet <> 0 OR @MaxBet <> 0) AND @MinBet > @MaxBet) 
		or ((@MaxBet <> 0 OR @MaxPerMatch <> 0) AND @MaxBet > @MaxPerMatch) 
		or ((@MinBet <> 0 OR @MaxPerMatch <> 0) AND @MinBet > @MaxPerMatch) 
	BEGIN
		SELECT @ErrMsg = CASE @Language 
							WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match!!!'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10005, @Language) END
			, @ErrCode = 102
		RETURN
	END

	SELECT @GameTypeID = GameTypeID FROM @tmp_GameType WHERE IBCBetTypeID = @bettype

	SELECT @MinMinBet = ISNULL(MAX(CASE WHEN cg.MinBet = 0 THEN NULL ELSE cg.MinBet END), 0)
		 , @MaxMaxBet = ISNULL(MIN(CASE WHEN cg.MaxBet = 0 THEN NULL ELSE cg.MaxBet END), 0)
		 , @MaxMaxperMatch = ISNULL(MIN(CASE WHEN cg.MaxPerGameType = 0 THEN NULL ELSE cg.MaxPerGameType END), 0)
	  FROM dbo.CustGameType cg WITH(NOLOCK)
INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON cg.CustID = ci.custid
	 WHERE cg.custid IN (@mrecommend, @srecommend, @recommend)
       AND cg.GameTypeID = @GameTypeID
  GROUP BY cg.GameTypeID

	IF (@MinMinBet > 0 AND NOT(@MinBet=0 AND @MaxBet=0 AND @MaxPerMatch=0) AND @MinBet < @MinMinBet)
	BEGIN
		SELECT @ErrMsg = @UserName + ': ' + CASE @Language
				WHEN 'E' THEN 'Min bet must be equal to or greater than Agent min bet'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](10006, @Language)
				END + ' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').'
			, @ErrCode = 103
		RETURN
	END

    SELECT @MinMinBet = MinBet
      FROM ProductBetSetting bs WITH(NOLOCK)
     WHERE bs.Bettype = @BetType
       AND bs.Sporttype = @SportType
       AND currency = @currency
       AND IsDep = 0

    --MinBet >= Global MinBet
    IF NOT(@MinBet=0 AND @MaxBet=0 AND @MaxPerMatch=0)
    BEGIN
		IF (@MinMinBet > 0 AND @MinBet < @MinMinBet)
		BEGIN
			SELECT @ErrMsg =
					 CASE @Language 
					   WHEN 'E' THEN 'Min Bet must be greater than or equal to Min Bet limit.'
					   ELSE [dbo].[f_Get_MsgNamebyMsgID](10030, @Language)
					 END + ' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').'
				 , @ErrCode = 107
			RETURN
		END


		IF (@MaxMaxBet > 0 AND @MaxBet > @MaxMaxBet)
		BEGIN
			SELECT @ErrMsg = @UserName + ': ' + CASE @Language
					WHEN 'E' THEN 'Max bet must be equal to or less than Agent max bet'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10007, @Language)
					END + ' (' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').'
				, @ErrCode = 104
			RETURN
		END

		IF (@MaxMaxPerMatch > 0 AND @MaxPerMatch > @MaxMaxPerMatch)
		BEGIN
			SELECT @ErrMsg = @UserName + ': ' + CASE @Language
					WHEN 'E' THEN 'Max Per Match must be equal to or less than Master Agent Max Per Match'
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10008, @Language)
					END + ' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').'
				, @ErrCode = 105
			RETURN
		END
	END

	SELECT @Old_MinBet = cg.MinBet, @Old_MaxBet = cg.MaxBet, @Old_MaxPerGame = cg.MaxPerGameType
	FROM CustGameType cg WITH (NOLOCK)
	WHERE custid = @CustID AND GameTypeID = @GameTypeID
	
	--Check not change value
	IF (@Old_MinBet = @Minbet AND @Old_MaxBet = @MaxBet AND @Old_MaxPerGame = @MaxPerMatch)
		RETURN
	
	UPDATE cg
	SET MinBet = @MinBet, MaxBet = @MaxBet, MaxPerGameType = @MaxPerMatch
	FROM CustGameType cg WITH (ROWLOCK, UPDLOCK)
	WHERE custid = @CustID AND gametypeid = @GameTypeID

	IF (@@error <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language
				WHEN 'E' THEN 'Update process is unsuccessful!'
				ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)
				END
			,@ErrCode = 106
		RETURN
	END

	DECLARE @LogSPData VARCHAR(MAX), @TrackingValueDB VARCHAR(4000)
		
	SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MinB="' + COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxB="' + COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MPM="' + COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB = '<Acc_CustomerUpdMemberKeno_MinMaxBet CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MinB="' + COALESCE(CAST(@Old_MinBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxB="' + COALESCE(CAST(@Old_MaxBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MPM="' + COALESCE(CAST(@Old_MaxPerGame AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + COALESCE(CAST(@ErrMsg AS VARCHAR(5000)), SPACE(1)) + '" />'

	SET @endRun = getdate()
	SET @duration = datediff(millisecond, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 382
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValueDB
			,@duration = @duration
	END TRY

	BEGIN CATCH
		SELECT @LogSPData = '<Acc_CustomerUpdMemberKeno_MinMaxBet CustId="' + COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="' + COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'BetType="' + COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MinB="' + COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MaxB="' + COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'MPM="' + COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'UserID="' + COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'Language="' + COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1)) 
		+ '" ' + 'IP="' + COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1)) 
		+ '" ' + 'ErrCode="' + COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="' + ERROR_MESSAGE() + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP @UserID = @UserID
			,@CustID = @CustID
			,@ActionID = 382
			,@TrackingValue = @LogSPData
			,@TrackingValue2 = @TrackingValueDB
			,@duration = @duration
	END CATCH
END
