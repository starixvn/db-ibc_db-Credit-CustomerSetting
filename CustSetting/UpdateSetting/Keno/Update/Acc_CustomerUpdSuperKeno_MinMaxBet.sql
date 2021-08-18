/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpdSuperKeno_MinMaxBet]  
	@CustID			INT,  
	@Sporttype		INT = 202,  
	@Bettype		INT,  
  
	@MinBet			MONEY,  
	@MaxBet			MONEY,  
	@MaxPerMatch	MONEY,  
  
	@SubAccID       INT = 0,  
	@UserID			INT = 0,   
	@Language		VARCHAR(2) = 'E',  
	@IP				VARCHAR(15)='',
	@SystemID		TINYINT, --20200310@Tiara
	@ErrCode		INT  = 0  OUTPUT,  
	@ErrMsg			NVARCHAR(4000) = '' OUTPUT  
AS  
/*  
	Created: 20140225@Elodie  
	Task : Update super's minbet, maxbet, max per match for Keno  
	DB: DBCUST/CustDB  
  
	Revisions:  
		- 20141027@Logan:   Add currency when selecting Min Bet Global [Redmine: #25040]
		- 20150609@David: Separate CustDB to DBCUST server (Use temp table for sports, bettype, GameType table, call some SPs by link server)   
		- 20160613@Helen: Security Prevention Step 1 - Cross level update -  [Redmine:55377]
		- 20200310@Tiara: Bet Limit Restriction for 789y on Alpha/ExtNAP [Redmine: #129429]
		- 20210727@Elodie: Adjust downline's betsetting [Redmine: #158073]

	Param's Explanation:  
		* @ErrCode:  
		= 0: Update successfully.  
		> 0: Specific Error.  
    
		* @ErrMsg: Error description.  
*/  
BEGIN  
    SET NOCOUNT ON  
    ----- David @ 09 JUN 2015 -------------------
	DECLARE @tmp_GameType TABLE (GameTypeID INT, GameTypeName NVARCHAR(50), IsDisabled BIT, IBCBettypeID INT)
	DECLARE @AgentList TABLE (CustId INT, IsFinished BIT)

	BEGIN TRY		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBAGE.bodb02.dbo.GameType WITH (NOLOCK)
	END TRY
	BEGIN CATCH		
		INSERT INTO @tmp_GameType (GameTypeID, GameTypeName, IsDisabled, IBCBettypeID)
		SELECT GameTypeID, GameTypeName, IsDisabled, IBCBettypeID FROM DBTXN.bodb02.dbo.GameType WITH (NOLOCK)
	END CATCH
	----- /David @ 09 JUN 2015 -------------------

    DECLARE @startRun			DATETIME
          , @endRun				DATETIME
          , @duration			INT
          , @minbet_old			MONEY
          , @maxbet_old			MONEY
          , @maxpermatch_old	MONEY
          , @currency			SMALLINT
		  , @IsAdjustDownline	BIT = 0
		  , @UserName			NVARCHAR(50)
		  , @AgentID			INT

    SET @startRun = GETDATE()

    SELECT @currency = currency, @UserName = Username
      FROM dbo.custInfo WITH(NOLOCK)
     WHERE custid = @CustID
       AND roleid = 4
	            
	-- Only direct upline have update permission
	IF NOT EXISTS (SELECT 1 FROM dbo.f_AGE_IsCrossLevelUpdate(@custid,4,@userid))
	BEGIN
		SELECT @ErrMsg = 'You don''t have permission to perform this action.',
			   @ErrCode = 103	
		RETURN
	END
	
	DECLARE @GameTypeID INT
	SELECT @GameTypeID = GameTypeID
    FROM @tmp_GameType WHERE IBCBetTypeID = @BetType

	--Get site info
	DECLARE @Site NVARCHAR (50), @RoleID TINYINT, @recommend INT
	SELECT @RoleID=RoleID  FROM custinfo(NOLOCK) WHERE custid=@custid
	IF @RoleID IN (2,3,4)
		SELECT @Site = C.site FROM Customer C WITH (NOLOCK) WHERE C.custid = @custid
	ELSE IF @RoleID = 1
	BEGIN
		SELECT @recommend = recommend FROM custinfo (NOLOCK) WHERE custid=@custid
		SELECT @Site = C.site FROM Customer C WITH (NOLOCK) WHERE C.custid = @recommend
	END

    IF @MinBet < 0  
        OR @MaxBet < 0  
        OR @MaxPerMatch <0 
		OR (@MinBet < 1 AND @SystemID!=1 AND @Site IN ('789y')) -- Bet Limit Restriction for 789y on Alpha/ExtNAP
		OR (@MaxBet < 1 AND @SystemID!=1 AND @Site IN ('789y'))
		OR (@MaxPerMatch < 1 AND @SystemID!=1 AND @Site IN ('789y'))
    BEGIN  
        SELECT @ErrMsg =
                 CASE @Language   
                   WHEN 'E' THEN 'Wrong Min bet/ Max bet/ Max per match.'  
                   ELSE [dbo].[f_Get_MsgNamebyMsgID](10003, @Language)
                 END
             , @ErrCode = 101  
        RETURN
    END

     IF((@MinBet <> 0 OR @MaxBet <> 0) AND @MinBet > @MaxBet)   
		OR ((@MaxBet <> 0 OR @MaxPerMatch <> 0) AND @MaxBet > @MaxPerMatch)   
		OR ((@MinBet <> 0 OR @MaxPerMatch <> 0) AND @MinBet > @MaxPerMatch)   
     BEGIN  
		  SELECT  
			   @ErrMsg = CASE @Language   
					WHEN 'E' THEN 'Min bet must be less than max bet and max bet must be less than max bet per match.'  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10005,@Language) END,   
			   @ErrCode = 102  
		  RETURN  
     END  
  
     IF EXISTS (SELECT 1
				FROM ProductBetSetting WITH(NOLOCK)
				WHERE sporttype = @Sporttype
                   AND bettype = @bettype
                   AND Currency = @currency
                   AND MinBet > @MinBet
                   AND @MinBet <> 0
                   AND IsDep = 0
               )  
     BEGIN  
		  SELECT  
			   @ErrMsg = CASE @Language   
					WHEN 'E' THEN 'Min Bet must be greater than or equal to Min Bet limit.'  
					ELSE [dbo].[f_Get_MsgNamebyMsgID](10030, @Language) END,   
			   @ErrCode = 103  
		  RETURN  
     END  
  
     SELECT @minbet_old = cg.MinBet, @maxbet_old = cg.MaxBet, @maxpermatch_old = cg.MaxPerGameType  
     FROM CustGameType cg WITH(NOLOCK)  
		INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID  
     WHERE custid = @CustID and gt.IBCBetTypeID = @bettype  
  
     --Check not change value  
     IF (@minbet_old = @MinBet AND @maxbet_old = @MaxBet AND @maxpermatch_old = @MaxPerMatch)  
		RETURN  
   
     UPDATE cg with (ROWLOCK, UPDLOCK)  
     SET MinBet = @MinBet,   
		MaxBet= @MaxBet,  
		MaxPerGameType = @MaxPerMatch  
     FROM CustGameType cg INNER JOIN @tmp_GameType gt ON cg.GameTypeID = gt.GameTypeID  
     WHERE custid=@CustID AND gt.IBCBetTypeID = @bettype  
   
     IF (@@error <> 0)  
     BEGIN  
		  SELECT @ErrMsg = CASE @Language   
							   WHEN 'E' THEN 'Update process is unsuccessful!'  
							   ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language) END,   
				@ErrCode = 104  
		  RETURN  
     END    
  
	IF EXISTS (	SELECT 1
				FROM dbo.CustGameType bsm WITH(NOLOCK)
					INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON bsm.custid = ci.custid
														AND ci.srecommend = @CustID
														AND ci.roleid = 3
				WHERE bsm.GameTypeID = @GameTypeID  
					AND @MaxBet <> 0 AND @MaxPerMatch <> 0
					AND (bsm.MaxBet > @MaxBet OR bsm.MaxPerGameType > @MaxPerMatch
						OR (@MinBet = 0 AND @MaxBet < 1 AND @MaxPerMatch < 1)))
			SELECT @IsAdjustDownline = 1

	INSERT INTO @AgentList (CustId, IsFinished)
	SELECT bsa.CustId, 0
	FROM dbo.CustGameType bsa WITH(NOLOCK)
		INNER JOIN dbo.custinfo ci WITH(NOLOCK) ON bsa.custid = ci.custid
											AND ci.srecommend = @CustID
											AND ci.roleid = 2
	WHERE bsa.GameTypeID = @GameTypeID  
		AND @MaxBet <> 0 AND @MaxPerMatch <> 0
		AND (bsa.MaxBet > @MaxBet OR bsa.MaxPerGameType > @MaxPerMatch
			OR (@MinBet = 0 AND @MaxBet < 1 AND @MaxPerMatch < 1))

	IF @IsAdjustDownline = 1
	BEGIN
		-- Correct downlines via ExecRep
		EXECUTE	Acc_CustSetting3rd_02
			@CustID			= @CustID,
			@RoleID			= @RoleID,
			@Sporttype		= @Sporttype,
			@bettype		= @GameTypeID,
			@MinBet			= @MinBet,
			@MaxBet			= @MaxBet,
			@MaxPerMatch	= @MaxPerMatch,
			@Mode			= 'Keno',
			@ErrCode		= @ErrCode OUTPUT,
			@ErrMsg			= @ErrMsg OUTPUT
	END

	WHILE (1=1)
	BEGIN
		UPDATE TOP(1) a
		SET IsFinished = 1,
			@AgentID = CustId
		FROM @AgentList a 
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 
			BREAK

		EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @AgentID
			, @userID = @UserID
			, @TypeID = 2
	END

    DECLARE @LogSPData VARCHAR (MAX), @TrackingValueDB VARCHAR(4000), @logSpData_Indirectly VARCHAR (MAX), @TrackingValueDB_Indirectly VARCHAR(4000)  
    
    Select @LogSPData_Indirectly =	'<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +  
									'SourceAccount="' + COALESCE(@UserName,SPACE(1)) + '" ' +   
									'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +   
									'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
									'MinB="'+ coalesce(cast(@MinBet as varchar(50)),space(1)) + '" ' +  
									'MaxB="'+ coalesce(cast(@MaxBet as varchar(50)),space(1)) + '" ' +  
									'MPM="'+ coalesce(cast(@MaxPerMatch as varchar(50)),space(1)) + '" ' +  
									'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
									'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +  
									'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +  
									'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +  
									'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +  
									'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'  
  
    SELECT @TrackingValueDB_Indirectly =	'<Acc_CustomerUpdSuperKeno_MinMaxBet custid="'+ coalesce(cast(@CustID as varchar(50)),space(1)) + '" ' +  
											'SourceAccount="' + COALESCE(@UserName,SPACE(1)) + '" ' +  
											'sporttype="'+ COALESCE(CAST(@sporttype AS VARCHAR(10)),SPACE(1)) + '" ' +   
											'bettype="'+ coalesce(cast(@bettype as varchar(50)),space(1)) + '" ' +  
											'MinB="'+ coalesce(cast(@MinBet_old as varchar(50)),space(1)) + '" ' +  
											'MaxB="'+ coalesce(cast(@MaxBet_old as varchar(50)),space(1)) + '" ' +  
											'MPM="'+ coalesce(cast(@MaxPerMatch_old as varchar(50)),space(1)) + '" ' +  
											'UserID="'+ coalesce(cast(@UserID as varchar(50)),space(1)) + '" ' +  
											'SubAccName="' + COALESCE(CAST(dbo.f_GetSubUsername(@SubAccID) AS VARCHAR(30)), SPACE(1)) + '" ' +  
											'Language="'+ coalesce(cast(@Language as varchar(2)),space(1)) + '" ' +  
											'IP="'+ coalesce(cast(@IP as varchar(15)),space(1)) + '" ' +  
											'ErrCode="'+ coalesce(cast(@ErrCode as varchar(300)),space(1)) + '" ' +  
											'ErrMsg="'+ coalesce(cast(@ErrMsg as nvarchar(4000)),space(1)) + '" />'  
  
	SET @logSpData = REPLACE(@logSpData_Indirectly, 'SourceAccount="'+ @UserName +'"', '')
	SET @TrackingValueDB = REPLACE(@TrackingValueDB_Indirectly, 'SourceAccount="'+ @UserName +'"', '')

    SET @endRun = getdate()  
    SET @duration  = datediff (millisecond,@startRun,@endRun)  

	EXEC Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,  
		@CustID = @CustID,  
		@ActionID = 379,  
		@TrackingValue = @LogSPData,  
		@TrackingValue2 = @TrackingValueDB,  
		@duration = @duration  

	IF @IsAdjustDownline = 1
		EXEC Acc_WriteLog_UserLog_RunSP_Wrapper
			@UserID = @UserID,  
			@CustID = @CustID,  
			@ActionID = 220017,  
			@TrackingValue = @logSpData_Indirectly,  
			@TrackingValue2 = @TrackingValueDB_Indirectly,  
			@duration = @duration  
END
