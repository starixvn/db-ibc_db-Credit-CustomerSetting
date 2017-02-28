ALTER PROCEDURE [dbo].[Acc_CustomerUpdMasterKeno_MinMaxBet]
(
	@CustId INT --master
	, @SportType INT = 202
	, @BetType INT --IBCBetTypeID

	, @MinBet MONEY
	, @MaxBet MONEY
	, @MaxPerMatch MONEY
	
	, @SubAccID	INT = 0
	, @UserId INT
	, @IP VARCHAR(50)= ''
	, @Language	VARCHAR(20) = 'E'
	, @ErrCode INT = 0 OUTPUT
	, @ErrMsg NVARCHAR(4000) = '' OUTPUT
)
 AS
/*
	Created: 20140325@Patrick
	Task: update bet setting of Keno on master
	DB: DBCUST/CustDB
		
	Revisions:

        - 20141104@Logan:    Add constraint Master MinBet >= Global MinBet [Redmine: #25005]
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)
		- 20160413@Dominic: HotFix - Alpha - Update Keno setting - No error alert when update minbet=0 and minbet <upline minbet [Redmine: #55596]
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
	Parameter's Explanation
		@ErrCode:
			= 0: Update successfully.
			> 0: Specific Error.

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

	DECLARE @startRun DATETIME, @endRun	DATETIME, @duration INT, @srecommend INT, @Username VARCHAR(50), @currency INT
		, @MinMinBet MONEY, @MaxMaxBet MONEY, @MaxMaxPerMatch MONEY
		, @Old_MinBet MONEY, @Old_MaxBet MONEY,	@Old_MaxPerMatch MONEY
	
	SELECT @ErrCode = 0, @ErrMsg = '', @startRun = GETDATE()
	
	SELECT @srecommend = srecommend, @UserName = username, @currency = currency
	FROM dbo.custinfo WITH(NOLOCK)
	WHERE custid = @custid AND roleid = 3

	IF @UserName IS NULL
		RETURN

	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,3,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END

	
	--Check @MinBet, @MaxBet & @MaxPerMatch >= 0
	IF @MinBet < 0 OR @MaxBet < 0 OR @MaxPerMatch < 0
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)	END
			, @ErrCode = 101
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
	
	DECLARE @GameTypeID INT
	SELECT @GameTypeID = GameTypeID
      FROM @tmp_GameType WHERE IBCBetTypeID = @BetType

	SELECT @MinMinBet = ISNULL(cg.MinBet, 0)
		 , @MaxMaxBet = ISNULL(MaxBet, 0)
		 , @MaxMaxPerMatch = ISNULL(cg.MaxPerGameType, 0)
	  FROM dbo.CustGameType cg WITH(NOLOCK)
INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON cg.CustID = ci.custid
	 WHERE cg.custid = @srecommend
       AND cg.GameTypeID = @GameTypeID

	--Check @MinBet >= Super's MinBet
	IF (@MinMinBet > 0 AND NOT(@MinBet=0 AND @MaxBet=0 AND @MaxPerMatch=0) AND @MinBet < @MinMinBet)
	BEGIN
		SELECT @ErrMsg =
                 CASE @Language
                   WHEN 'E' THEN 'Min bet must be equal to or greater than Super Agent min bet'
				   ELSE [dbo].[f_Get_MsgNamebyMsgID](10016, @Language)
                 END + ' (' + CONVERT(VARCHAR(20), @MinMinBet) + ').'
			 , @ErrCode = 103
		RETURN
	END

    --Check @MinBet >= Global's MinBet
	SELECT @MinMinBet = MinBet
      FROM ProductBetSetting bs WITH(NOLOCK)
     WHERE bs.Bettype = @BetType
       AND bs.Sporttype = @SportType
       AND currency = @currency
       AND IsDep = 0
	
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

		--Check @MaxBet <= @MaxMaxBet
		IF (@MaxMaxBet > 0 AND @MaxBet > @MaxMaxBet)
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Max bet must be equal to or less than Super Agent max bet'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10017, @Language) END +' (' + CONVERT(VARCHAR(20), @MaxMaxBet) + ').'
					, @ErrCode = 104
			RETURN
		END
		--Check @MaxPerMatch <= @MaxMaxPerMatch
		IF (@MaxMaxPerMatch > 0 AND @MaxPerMatch > @MaxMaxPerMatch)
		BEGIN
			SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Max Per Match must be equal to or less than Super Agent Max Per Match'
								ELSE [dbo].[f_Get_MsgNamebyMsgID](10018, @Language) END +' (' + CONVERT(VARCHAR(20), @MaxMaxPerMatch) + ').'
					, @ErrCode = 105
			RETURN
		END
	END
	
	--check old values and new values before update
	SELECT @Old_MinBet = MinBet, @Old_MaxBet = MaxBet, @Old_MaxPerMatch = MaxPerGameType
	FROM dbo.CustGameType AS cg WITH (NOLOCK)
	WHERE cg.custid = @custid AND GameTypeID = @GameTypeID

	--Check not change value
	IF (@Old_MinBet = @MinBet AND @Old_MaxBet = @MaxBet AND @Old_MaxPerMatch = @MaxPerMatch)
		RETURN

	UPDATE dbo.CustGameType WITH (ROWLOCK, UPDLOCK)
	SET MinBet = @MinBet, MaxBet = @MaxBet, MaxPerGameType = @MaxPerMatch
	WHERE custid = @custid AND GameTypeID = @GameTypeID

	IF (@@ERROR <> 0)
	BEGIN
		SELECT @ErrMsg = CASE @Language WHEN 'E' THEN 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001, @Language)	END
			, @ErrCode = 106
		RETURN
	END
		
	DECLARE @LogSPData VARCHAR(5000), @TrackingValueDB VARCHAR(4000)
	SELECT @LogSPData ='<Acc_CustomerUpdMasterKeno_MinMaxBet CustId="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="'+ COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'BetType="'+ COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg as varchar(5000)), SPACE(1)) + '" />'

	SELECT @TrackingValueDB ='<Acc_CustomerUpdMasterKeno_MinMaxBet CustId="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="'+ COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'BetType="'+ COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MinB="'+ COALESCE(CAST(@Old_MinBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MaxB="'+ COALESCE(CAST(@Old_MaxBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPM="'+ COALESCE(CAST(@Old_MaxPerMatch AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ COALESCE(CAST(@ErrMsg as varchar(5000)), SPACE(1)) + '" />'
	
	SELECT @endRun = GETDATE(), @duration = DATEDIFF (MILLISECOND, @startRun, @endRun)
	
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 380,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END TRY
	BEGIN CATCH
		SELECT @LogSPData ='<Acc_CustomerUpdMasterKeno_MinMaxBet CustId="'+ COALESCE(CAST(@custid AS VARCHAR(50)), SPACE(1)) 
		+ '" ' + 'SportType="'+ COALESCE(CAST(@SportType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'BetType="'+ COALESCE(CAST(@BetType AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MinB="'+ COALESCE(CAST(@MinBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MaxB="'+ COALESCE(CAST(@MaxBet AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'MPM="'+ COALESCE(CAST(@MaxPerMatch AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'UserID="'+ COALESCE(CAST(@UserID AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1))
		+ '" ' + 'Language="'+ COALESCE(CAST(@Language AS VARCHAR(2)), SPACE(1))
		+ '" ' + 'IP="'+ COALESCE(CAST(@IP AS VARCHAR(15)), SPACE(1))
		+ '" ' + 'ErrCode="'+ COALESCE(CAST(@ErrCode AS VARCHAR(50)), SPACE(1))
		+ '" ' + 'ErrMsg="'+ ERROR_MESSAGE() + '" />'

		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 380,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @TrackingValueDB,
			@duration = @duration
	END CATCH
END
