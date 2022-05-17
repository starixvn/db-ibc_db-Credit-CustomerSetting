/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerUpd_BetSetting]
	@custid int,
	
	@minbet money,
	@maxbet money,
	@maxpermatch money,
	
	@minbetv2 money,
	@maxbetv2 money,
	@maxpermatchv2 money,
	
	@minbetv3 money,
	@maxbetv3 money,
	@maxpermatchv3 money,
	
	@minbetv5 money,
	@maxbetv5 money,
	@maxpermatchv5 money,
	
	@minbetv8 money,
	@maxbetv8 money,
	@maxpermatchv8 money,
	
	@minbetv10 money,
	@maxbetv10 money,
	@maxpermatchv10 money,
	
	@minbetv11 money,
	@maxbetv11 money,
	@maxpermatchv11 money,

	@minbetv99 money,
	@maxbetv99 money,
	@maxpermatchv99 money,	

	--- mixed sports
	@minbetv99mp money,
	@maxbetv99mp money,
	@maxpermatchv99mp money,
	
	--- soccer sports
	@minbetv1mp money,
	@maxbetv1mp money,
	@maxpermatchv1mp money,

	-- number game
	@minbetv161 money,
	@maxbetv161 money,
	@maxpermatchv161 money,
	@MaxPerBallv161 money = 0,	
	
	-- Happy 5
	@minbetv164 money=0,
	@maxbetv164 money=0,
	@maxpermatchv164 money=0,

	--Max Payout Per Match
	@maxPOpermatch money = NULL,
	@maxPOpermatchv2 money = NULL,
	@maxPOpermatchv3 money = NULL,
	@maxPOpermatchv5 money = NULL,
	@maxPOpermatchv8 money = NULL,
	@maxPOpermatchv10 money = NULL,
	@maxPOpermatchv11 money = NULL,
	@maxPOpermatchv99 money = NULL,
	@maxPOpermatchv99mp money = NULL,
	@maxPOpermatchv1mp money = NULL,

	--Saba
	--- Saba soccer
	@minbetv1saba money = NULL,
	@maxbetv1saba money = NULL,
	@maxpermatchv1saba money  = NULL,
	@maxPOpermatchv1saba money = NULL,

	--- Saba basketball
	@minbetv2saba money = NULL,
	@maxbetv2saba money = NULL,
	@maxpermatchv2saba money  = NULL,
	@maxPOpermatchv2saba money = NULL,

	@UpdateMinMaxBetv1saba bit = 1,
	@UpdateMinMaxBetv2saba bit = 1,

	@UpdateMultiple bit = 0,	

	@UpdateMinMaxBet bit = 1,
	@UpdateMinMaxBetv2 bit = 1,
	@UpdateMinMaxBetv3 bit = 1,
	@UpdateMinMaxBetv5 bit = 1,
	@UpdateMinMaxBetv8 bit = 1,
	@UpdateMinMaxBetv10 bit = 1,
	@UpdateMinMaxBetv11 bit = 1,
	@UpdateMinMaxBetv99 bit = 1,
	-- mixed sports
	@UpdateMinMaxBetv99MP bit = 1,
	@UpdateMinMaxBetMP bit = 1,
	-- number game
	@UpdateMinMaxBetv161 bit = 1,
	@UpdateMinMaxBetv164 bit = 1,
	@SubAccID int = 0, --Sub-AccountID	
	@UserID int = 0,	
	@Language varchar(2) = 'E',
	@IP varchar(15)='',
	@SystemID TINYINT = 1,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT
AS
/*
	Created: 20210802@Eden
	Task : Update Bet Setting of Sportbook and NumberGame (use for all level Super/master/agent/member)
	DB: DBCUST/CUSTDB
	Original: Acc_CustomerUpdAgent_MinMaxBet

	Revisions:
		- 20210802@Eden: Max Payout Per Match [redmine: #158073]
		- 20211005@Johnson: change param @UpdateMinMaxBetv1MP to @UpdateMinMaxBetMP [redmine:#161425]
		- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
		- 20220516@Tacy: Insert history of member bet setting (Number Game, Happy 5) [redmineID: #170739]

	Param's Explanation:
	- @ErrCode:
		= 0: Update successfully.
		> 0: Specific Error.
  
	- @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @CustList VARCHAR(MAX)

	declare @startRun datetime
	declare @endRun datetime
	declare @duration int
	DECLARE @Site NVARCHAR (50), @RoleID TINYINT, @recommend INT, @mrecommend int, @srecommend INT, @UserName varchar(30)
	SET @startRun = getdate()

	SELECT @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend, @RoleID=RoleID, @Site = site
	FROM customer with (NOLOCK)
	WHERE CustID = @CustID

	DECLARE @BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY,
		IsUpdate		  BIT,
		SportName		  NVARCHAR(50),
		IsSpecial		  BIT DEFAULT (0),
		LogOrder		  TINYINT
		PRIMARY KEY(sporttype, Bettype)
	);

	DECLARE @Upline_BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY
		PRIMARY KEY(sporttype, Bettype)
	);

	DECLARE @Old_BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY
		PRIMARY KEY(sporttype, Bettype)
	);

	DECLARE @History_BetSetting TABLE(
		CustID			  INT,
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		UpdateTime		  DATETIME
	);

	INSERT INTO @BetSetting(LogOrder,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch,IsUpdate,SportName)
	--Soccer
	SELECT 10,1, 1, @minbet, @maxbet, @maxpermatch, NULL, @maxPOpermatch, @UpdateMinMaxBet, [dbo].[f_Get_SportNameBySporttype](1,@Language) UNION ALL
	--Saba Soccer
	SELECT 20,9901, 1, @minbetv1saba, @maxbetv1saba, @maxpermatchv1saba, NULL, @maxPOpermatchv1saba, @UpdateMinMaxBetv1saba, NULL UNION ALL
	--Soccer Parlay
	SELECT 30,1, 9, @minbetv1mp, @maxbetv1mp, @maxpermatchv1mp, NULL, @maxPOpermatchv1mp, @UpdateMinMaxBetmp, [dbo].[f_Get_SportNameBySporttype](1,@Language) UNION ALL
	--Basketball
	SELECT 40,2, 1, @minbetv2, @maxbetv2, @maxpermatchv2, NULL, @maxPOpermatchv2, @UpdateMinMaxBetv2, [dbo].[f_Get_SportNameBySporttype](2,@Language) UNION ALL
	--Saba Basketball
	SELECT 50,9902, 1, @minbetv2saba, @maxbetv2saba, @maxpermatchv2saba, NULL, @maxPOpermatchv2saba, @UpdateMinMaxBetv2saba, NULL UNION ALL
	--Football
	SELECT 60,3, 1, @minbetv3, @maxbetv3, @maxpermatchv3, NULL, @maxPOpermatchv3, @UpdateMinMaxBetv3, [dbo].[f_Get_SportNameBySporttype](3,@Language) UNION ALL
	--Tennis
	SELECT 70,5, 1, @minbetv5, @maxbetv5, @maxpermatchv5, NULL, @maxPOpermatchv5, @UpdateMinMaxBetv5, [dbo].[f_Get_SportNameBySporttype](5,@Language) UNION ALL
	--Baseball
	SELECT 80,8, 1, @minbetv8, @maxbetv8, @maxpermatchv8, NULL, @maxPOpermatchv8, @UpdateMinMaxBetv8, [dbo].[f_Get_SportNameBySporttype](8,@Language) UNION ALL
	--Golf
	SELECT 90,10, 1, @minbetv10, @maxbetv10, @maxpermatchv10, NULL, @maxPOpermatchv10, @UpdateMinMaxBetv10, [dbo].[f_Get_SportNameBySporttype](10,@Language) UNION ALL
	--Motorsports
	SELECT 100,11, 1, @minbetv11, @maxbetv11, @maxpermatchv11, NULL, @maxPOpermatchv11, @UpdateMinMaxBetv11, [dbo].[f_Get_SportNameBySporttype](11,@Language) UNION ALL
	--Other Sports
	SELECT 110,99, 1, @minbetv99, @maxbetv99, @maxpermatchv99, NULL, @maxPOpermatchv99, @UpdateMinMaxBetv99, [dbo].[f_Get_SportNameBySporttype](99,@Language) UNION ALL
	--Mix Sports Parlay
	SELECT 120,99, 9, @minbetv99mp, @maxbetv99mp, @maxpermatchv99mp, NULL, @maxPOpermatchv99mp, @UpdateMinMaxBetv99mp, NULL UNION ALL
	--Number Game
	SELECT 130,161, 81, @minbetv161, @maxbetv161, @maxpermatchv161, @MaxPerBallv161, NULL, @UpdateMinMaxBetv161, [dbo].[f_Get_SportNameBySporttype](161,@Language) UNION ALL
	--Happy 5
	SELECT 140,164, 8101, @minbetv164, @maxbetv164, @maxpermatchv164, NULL, NULL, @UpdateMinMaxBetv164, [dbo].[f_Get_SportNameBySporttype](164,@Language)

	DELETE FROM @BetSetting WHERE ISNULL(IsUpdate,0) = 0

	--Correct sportname for Mix Sports Parlay 
	UPDATE t
	SET t.SportName = case @Language 
						when 'CS' then N'供混合体育过关'
						when 'CT' then N'供混合體育過關'
						when 'TH' then N'สำหรับกีฬาบอลชุด'
						when 'J' then N'Mix Sports Parlay'
						when 'KO' then N'Mix Sports Parlay'
						when 'VI' then N'Mix Sports Parlay'
						else N'Mix Sports Parlay' 
					 end
	FROM @BetSetting t
	WHERE sporttype = 99 AND bettype = 9

	--Correct sportname for Soccer Parlay 
	UPDATE t
	SET t.SportName = case @Language 
						when 'CS' then N'足球混合过关'
						when 'CT' then N'足球混合過關'
						when 'TH' then N'บอลชุดฟุตบอล'
						when 'J' then N'Soccer Parlay'
						when 'KO' then N'Soccer Parlay'
						when 'VI' then N'Soccer Parlay'
						else N'Soccer Parlay' 
					 end
	FROM @BetSetting t
	WHERE sporttype = 1 AND bettype = 9

	--Correct sportname for Saba Soccer
	UPDATE t
	SET t.SportName = case @Language 
						when 'CS' then N'沙巴足球'
						when 'CT' then N'沙巴足球'
						when 'TH' then N'ฟุตบอล Saba'
						when 'J' then N'Saba Soccer'
						when 'KO' then N'Saba Soccer'
						when 'VI' then N'Saba Soccer'
						else N'Saba Soccer' 
					 end
	FROM @BetSetting t
	WHERE sporttype = 9901 AND bettype = 1

	--Correct sportname for Saba Basketball
	UPDATE t
	SET t.SportName = case @Language 
						when 'CS' then N'沙巴篮球'
						when 'CT' then N'沙巴籃球'
						when 'TH' then N'บาสเกตบอล Saba'
						when 'J' then N'Saba Basketball'
						when 'KO' then N'Saba Basketball'
						when 'VI' then N'Saba Basketball'
						else N'Saba Basketball' 
					 end
	FROM @BetSetting t
	WHERE sporttype = 9902 AND bettype = 1

	--> Check rule : Wrong Min bet/ Max bet/ Max per match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + SportName + ')'
				, @ErrCode = 3
	FROM @BetSetting
	WHERE (MinBet < 0 or MaxBet < 0 or MaxPerMatch < 0)
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Wrong Max Payout Per Match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10059,@Language) + ' (' + SportName + ')'
				, @ErrCode = 3
	FROM @BetSetting
	WHERE (MaxPayoutPerMatch < 0)
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Wrong Min bet/ Max bet/ Max per match for NumberGame and Happy 5 (Bet Limit Restriction for 789y on Alpha/ExtNAP)
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10003,@Language) + ' (' + SportName + ')'
				, @ErrCode = 3
	FROM @BetSetting
	WHERE (MinBet < 1 or MaxBet < 1 or MaxPerMatch < 1)
		AND @SystemID!=1 AND @Site IN ('789y')
		AND SportType IN(161, 164)
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Wrong Max Per Ball for NumberGame (Include Bet Limit Restriction for 789y on Alpha/ExtNAP)
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10002,@Language) + ' (' + SportName + ')'
				, @ErrCode = 3
	FROM @BetSetting
	WHERE ( (MaxPerNumber < 0) 
			OR (MaxPerNumber < 1 AND @SystemID!=1 AND @Site IN ('789y'))
		 )
		AND SportType = 161
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Min bet must be less than or equal to max bet and max bet must be less than or equal to max per match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10067,@Language) + ' (' + SportName + ')'
							+ char(13) + char(10) + convert(varchar(20), MinBet) + '-' + convert(varchar(20), MaxBet) + '-' + convert(varchar(20), MaxPerMatch)
				, @ErrCode = 109
	FROM @BetSetting
	WHERE ( (MinBet > MaxBet) 
			OR (MaxBet > MaxPerMatch) 
		  )
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Max Per Match must be less than or equal to Max Payout Per Match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10060,@Language) + ' (' + SportName + ')'
							+ char(13) + char(10) + convert(varchar(20), MaxPerMatch) + '-' + convert(varchar(20), MaxPayoutPerMatch)
				, @ErrCode = 112
	FROM @BetSetting
	WHERE (MaxPerMatch > MaxPayoutPerMatch) 
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	--> Check rule : Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10061,@Language) + ' (' + SportName + ')'
				+ char(13) + char(10) + convert(varchar(20), MaxBet) + '-' + convert(varchar(20), MaxPerNumber) + '-' + convert(varchar(20), MaxPerMatch)
				, @ErrCode = 113
	FROM @BetSetting
	WHERE  ((MaxPerNumber <> 0 AND MaxBet > MaxPerNumber) 
			OR (MaxPerNumber<> 0 AND MaxPerNumber > MaxPerMatch) 
		  )
		AND IsUpdate = 1

	IF @ErrCode <> 0
		RETURN

	IF @RoleID IN(1,2,3) -- Validate betlimit with upline's bet limit
	BEGIN
		IF @RoleID = 3
		BEGIN
			INSERT INTO @Upline_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
			SELECT  cb.Sporttype,cb.Bettype,
					MinBet = ISNULL((CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
					MaxBet = ISNULL((CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
					MaxPerMatch = ISNULL((CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
					MaxPerNumber = ISNULL((CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0),
					MaxPOpermatch = ISNULL((CASE WHEN cb.MaxPayoutPerMatch = 0 THEN NULL ELSE cb.MaxPayoutPerMatch END),0)
			FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
				INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			WHERE cb.custid = @srecommend
		END
		IF @RoleID = 2
		BEGIN
			INSERT INTO @Upline_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
			SELECT  cb.Sporttype,cb.Bettype,
					MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
					MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
					MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
					MaxPerNumber = ISNULL(MIN(CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0),
					MaxPOpermatch = ISNULL(MIN(CASE WHEN cb.MaxPayoutPerMatch = 0 THEN NULL ELSE cb.MaxPayoutPerMatch END),0)
			FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
				INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			WHERE cb.custid IN (@mrecommend,@srecommend)
			GROUP BY cb.Sporttype,cb.Bettype
		END
		IF @RoleID = 1
		BEGIN
			INSERT INTO @Upline_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
			SELECT  cb.Sporttype,cb.Bettype,
					MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
					MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
					MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
					MaxPerNumber = ISNULL(MIN(CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0),
					MaxPOpermatch = ISNULL(MIN(CASE WHEN cb.MaxPayoutPerMatch = 0 THEN NULL ELSE cb.MaxPayoutPerMatch END),0)
			FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
				INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			WHERE cb.custid IN (@recommend,@mrecommend,@srecommend)
			GROUP BY cb.Sporttype,cb.Bettype
		END

		--> Check rule : Min Bet must be equal to or greater than Upline's Min Bet
		SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10062,@Language) + ' (' + SportName + ')'
					+' (' + convert(varchar(20), u.MinBet) + ').'
					, @ErrCode = 110
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)
			AND IsUpdate = 1

		IF @ErrCode <> 0
			RETURN

		--> Check rule : Max Bet must be equal to or less than Upline's Max Bet
		SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10063,@Language) + ' (' + SportName + ')'
					+' (' + convert(varchar(20), u.MaxBet) + ').'
					, @ErrCode = 111
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)
			AND IsUpdate = 1

		IF @ErrCode <> 0
			RETURN

		--> Check rule : Max Per Match  must be equal to or less than Upline's Max Per Match
		SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10064,@Language) + ' (' + SportName + ')'
					+' (' + convert(varchar(20), u.MaxPerMatch) + ').'
					, @ErrCode = 111
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)
			AND IsUpdate = 1

		IF @ErrCode <> 0
			RETURN

		--> Check rule : Max Payout Per Match must be equal to or less than Upline's Max Payout Per Match
		SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10065,@Language) + ' (' + SportName + ')'
					+' (' + convert(varchar(20), u.MaxPayoutPerMatch) + ').'
					, @ErrCode = 111
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPayoutPerMatch > 0 AND u.MaxPayoutPerMatch > 0 AND t.MaxPayoutPerMatch > u.MaxPayoutPerMatch)
			AND IsUpdate = 1

		IF @ErrCode <> 0
			RETURN

		--> Check rule : Max Per Ball must be equal to or less than Upline's Max Per Ball
		SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10066,@Language) + ' (' + SportName + ')'
					+' (' + convert(varchar(20), u.MaxPerNumber) + ').'
					, @ErrCode = 111
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPerNumber > 0 AND u.MaxPerNumber > 0 AND t.MaxPerNumber > u.MaxPerNumber)
			AND IsUpdate = 1

		IF @ErrCode <> 0
			RETURN
	END

	--Get current Setting
	IF @RoleID > 1
	BEGIN
		INSERT INTO @Old_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPerNumber,cb.MaxPayoutPerMatch
		FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid
			AND b.IsUpdate = 1
	END
	ELSE
	BEGIN
		INSERT INTO @Old_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
		SELECT cb.SportType,cb.BetType,cb.MinBet,cb.MaxBet,cb.MaxPerMatch,cb.MaxPerNumber,cb.MaxPayoutPerMatch
		FROM CustBetSetting_Member cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @custid
			AND b.IsUpdate = 1
	END

	IF NOT EXISTS(
		SELECT TOP 1 1
		FROM @BetSetting t
			INNER JOIN @Old_BetSetting old
				ON t.SportType = old.SportType AND t.BetType = old.BetType
		WHERE (t.IsUpdate = 1) 
			AND (	ISNULL(t.MinBet,0)  <>  ISNULL(old.MinBet,0)
					OR ISNULL(t.MaxBet,0)  <>  ISNULL(old.MaxBet,0)
					OR ISNULL(t.MaxPerMatch,0)  <>  ISNULL(old.MaxPerMatch,0)
					OR ISNULL(t.MaxPerNumber,0)  <>  ISNULL(old.MaxPerNumber,0)
					OR ISNULL(t.MaxPayoutPerMatch,0)  <>  ISNULL(old.MaxPayoutPerMatch,0)
				)
	)
	BEGIN
		PRINT 'Unchanged'
		RETURN
	END

	DECLARE @BetSettingXML VARCHAR(MAX)  = '', @IsAffected BIT = 0

	IF @RoleID > 1
	BEGIN
		-- Set IsSpecial = 1 --> not affect to downline
		UPDATE t
		SET t.IsSpecial = 1
		FROM @BetSetting t
		WHERE ISNULL(t.MinBet,0) = 0 
			AND ISNULL(t.MaxBet,0) = 0 
			AND ISNULL(t.MaxPerMatch,0) = 0 
			AND ISNULL(t.MaxPayoutPerMatch,0) = 0 
			AND ISNULL(t.MaxPerNumber,0) = 0 

		SELECT @BetSettingXML = CONVERT( VARCHAR(MAX), 
							(	
								SELECT  SportType			AS	'@SportType'		
										,BetType 			AS	'@BetType' 
										,MinBet 			AS	'@MinBet'
										,MaxBet 			AS	'@MaxBet' 
										,MaxPerMatch 		AS	'@MaxPerMatch' 
										,MaxPerNumber 		AS	'@MaxPerNumber' 
										,MaxPayoutPerMatch	AS	'@MaxPayoutPerMatch'
								FROM @BetSetting
								WHERE IsUpdate = 1
									AND IsSpecial = 0
								FOR XML PATH('Row'), ROOT ('Root'), TYPE)
							)

		--Check affected downline
		EXEC [Acc_CustomerUpd_BetSetting_Checkdownline]
			@custid = @custid,
			@RoleID = @RoleID,
			@BetSettingXML = @BetSettingXML,
			@IsAffected = @IsAffected OUTPUT

		IF @IsAffected = 1
		BEGIN
			--Check Allowed downlines	
			EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
				@custid		= @custid
			,	@roleid		= @roleid
			,	@isExecRep	= 1
			,	@Language	= @Language
			,	@ErrCode	= @ErrCode	OUTPUT
			,	@ErrMsg		= @ErrMsg	OUTPUT

			IF @ErrCode > 0
			BEGIN
				RETURN
			END
		END

		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPerNumber = t.MaxPerNumber,
			a.MaxPayoutPerMatch = t.MaxPayoutPerMatch,
			a.MinBet = t.MinBet
		FROM @BetSetting t
			INNER JOIN CustBetSetting_Agent a WITH(ROWLOCK,UPDLOCK)
				ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid
			AND t.IsUpdate = 1
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Update setting
		UPDATE a
		SET a.MaxBet = t.MaxBet,
			a.MaxPerMatch = t.MaxPerMatch,
			a.MaxPerNumber = t.MaxPerNumber,
			a.MaxPayoutPerMatch = t.MaxPayoutPerMatch,
			a.MinBet = t.MinBet
		OUTPUT deleted.CustID, deleted.SportType, deleted.BetType, deleted.MaxBet, deleted.MaxPerMatch, GETDATE()
			INTO @History_BetSetting(CustID, SportType, BetType, MaxBet, MaxPerMatch, UpdateTime)
		FROM @BetSetting t
			INNER JOIN CustBetSetting_Member a WITH(ROWLOCK,UPDLOCK)
				ON t.SportType = a.SportType AND t.BetType = a.BetType
		WHERE a.CustID = @custid
			AND t.IsUpdate = 1

		--Insert history bet setting
		DELETE @History_BetSetting
		WHERE SportType NOT IN (161, 164)

		SET @CustList = (SELECT CustID		AS '@CustID',
								SportType	AS '@SportType',
								BetType		AS '@BetType',
								MaxBet		AS '@MaxBet',
								MaxPerMatch	AS '@MaxPerMatch',
								'NULL'		AS '@StakeLevelList',
								UpdateTime	AS '@UpdateTime'
						 FROM @History_BetSetting
						 FOR XML PATH ('r'), ROOT ('root')
						 )

		EXECUTE Acc_DynamicCustSetting3rd_08 @CustList, @ErrMsg = @ErrMsg OUTPUT;

		IF @ErrMsg <> ''
			RETURN
	END

	IF (@@ERROR <> 0)
	BEGIN
	
		SELECT @ErrMsg = @UserName + ': '+
						case @Language 
							when 'E' then 'Update process is unsuccessful !'
							ELSE [dbo].[f_Get_MsgNamebyMsgID](90001,@Language)
						end, @ErrCode = 115	
		RETURN
	END

	DECLARE @Notify_agents TABLE ( CustID INT, Isfinished BIT default 0)

	IF @RoleID = 2
	BEGIN
		INSERT INTO @Notify_agents(CustID) 
		SELECT @custid
	END

	IF @RoleID > 1 AND @IsAffected = 1
	BEGIN
		--> Generate affected Agents to send notify message
		IF @RoleID = 4
		BEGIN
			INSERT INTO @Notify_agents(CustID)
			SELECT c.custid
			FROM @BetSetting t
				INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
					ON t.SportType = a.SportType AND t.BetType = a.BetType
				INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
			WHERE c.srecommend = @custid
				AND t.IsUpdate = 1
				AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
						OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
						OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
						OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				AND c.roleid = 2
				AND t.IsSpecial = 0
				AND c.enabled = 1
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO @Notify_agents(CustID)
			SELECT c.custid
			FROM @BetSetting t
				INNER JOIN CustBetSetting_Agent a WITH(NOLOCK)
					ON t.SportType = a.SportType AND t.BetType = a.BetType
				INNER JOIN custInfo c WITH(NOLOCK) ON a.CustID = c.custid
			WHERE c.mrecommend = @custid
				AND t.IsUpdate = 1
				AND (  (a.MaxBet > t.MaxBet AND t.MaxBet > 0)
						OR (a.MaxPerMatch > t.MaxPerMatch AND t.MaxPerMatch > 0)
						OR (a.MaxPayoutPerMatch > t.MaxPayoutPerMatch AND t.MaxPayoutPerMatch > 0)
						OR (a.MaxPerNumber > t.MaxPerNumber AND t.MaxPerNumber > 0))
				AND c.roleid = 2
				AND t.IsSpecial = 0
				AND c.enabled = 1
		END

		--Update Downline
		EXEC dbo.Acc_CustSetting_12
			 @CustId = @CustId
			,@RoleId = @RoleId
			,@XML = @BetSettingXML
			,@Mode='SB_BetSetting'
	END

	--Insert notify message
	DECLARE @Notify_AgentID INT

	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @Notify_agents
		SET IsFinished = 1, 
			@Notify_AgentID = custid
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK
		
		EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @Notify_AgentID, @userID = @UserID, @TypeID = 2
	END

	------------------------------ write log-------------------------------
	DECLARE @XML XML, @LogSPData VARCHAR(MAX), @LogSPData_Old VARCHAR(MAX),@ActionID INT, @LogSPData_Indirect VARCHAR(MAX), @LogSPData_Old_Indirect VARCHAR(MAX)
	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))

	--START LOGGING
	DECLARE @SPName varchar(100) = 'Acc_CustomerUpd_BetSetting'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)
	
	INSERT INTO @LogAction (ActionID)
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID = 1 AND ld.Level = @RoleID

	SET @xml = (
	SELECT	@custid							AS '@custid',
			@UserID							AS '@UserID',
			dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
			@Language						AS '@Language',
			@UserName						AS '@SourceAccount',
			@IP								AS '@IP',
			@UpdateMultiple					AS '@UpdateMultiple',
			(
				SELECT	t.SportType									AS '@SportType',
						t.BetType									AS '@BetType',
						CONVERT(DECIMAL(20,2), old.MinBet)			AS '@MinBet',
						CONVERT(DECIMAL(20,2), old.MaxBet)			AS '@MaxBet',
						CONVERT(DECIMAL(20,2), old.MaxPerMatch)		AS '@MaxPerMatch',
						CONVERT(DECIMAL(20,2), old.MaxPerNumber)	AS '@MaxPerNumber',
						CONVERT(DECIMAL(20,2), old.MaxPayoutPerMatch)	AS '@MaxPayoutPerMatch'
				FROM @BetSetting t
					INNER JOIN @Old_BetSetting old ON t.SportType = old.SportType AND t.BetType = old.BetType
				WHERE (t.IsUpdate = 1)
				ORDER BY LogOrder 
				FOR XML PATH('BetLimit'),
				TYPE
			)
	FOR XML PATH('Acc_CustomerUpd_BetSetting'),
	TYPE
	)

	SET @LogSPData_Old_Indirect = REPLACE(CONVERT(VARCHAR(MAX), @XML), '" />', '"/"')

	SET @xml = (
	SELECT	@custid							AS '@custid',
			@UserID							AS '@UserID',
			dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
			@Language						AS '@Language',
			@UserName						AS '@SourceAccount',
			@IP								AS '@IP',
			@UpdateMultiple					AS '@UpdateMultiple',
			(
				SELECT	SportType							AS '@SportType',
						BetType								AS '@BetType',
						CONVERT(DECIMAL(20,2), MinBet)		AS '@MinBet',
						CONVERT(DECIMAL(20,2), MaxBet)		AS '@MaxBet',
						CONVERT(DECIMAL(20,2), MaxPerMatch)	AS '@MaxPerMatch',
						CONVERT(DECIMAL(20,2), MaxPerNumber)	AS '@MaxPerNumber',
						CONVERT(DECIMAL(20,2), MaxPayoutPerMatch)	AS '@MaxPayoutPerMatch'
				FROM @BetSetting t
				WHERE (t.IsUpdate = 1)
				ORDER BY LogOrder 
				FOR XML PATH('BetLimit'),
				TYPE
			)
	FOR XML PATH('Acc_CustomerUpd_BetSetting'),
	TYPE
	)

	SET @LogSPData_Indirect = REPLACE(CONVERT(VARCHAR(MAX), @XML), '" />', '"/"')

	SELECT @LogSPData_Indirect = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData_Indirect)

	SELECT @LogSPData_Old_Indirect = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData_Old_Indirect)

	SET @logSpData = REPLACE(@LogSPData_Indirect, 'SourceAccount="'+ @UserName +'"', '')
	SET @logSpData_Old = REPLACE(@LogSPData_Old_Indirect, 'SourceAccount="'+ @UserName +'"', '')

	SELECT @endRun = GETDATE(), @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK
		
		IF @ActionID NOT IN (220021,220023,220025) -- Direct log
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @LogSPData_Old,
				@duration = @duration	
		END
		ELSE IF @IsAffected = 1 -- Indirect log
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData_Indirect,
				@TrackingValue2 = @LogSPData_Old_Indirect,
				@duration = @duration	
		END
		
		
	END

END
GO
