/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_CheckBetSetting]
	@custid int = NULL,
	
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
	--
	@language varchar(2) = 'E',
	@SystemID TINYINT = 1,
	@ErrCode int = 0 OUTPUT,
	@ErrMsg nvarchar(4000) = '' OUTPUT,
	@BetSettingXML VARCHAR(8000) = '' OUTPUT
AS
/*
Created: 20210802@Eden
Task : Validate Betsetting of SportBook and NumberGame when create new customer
DB: DBCUST/CUSTDB

Revisions:
	- 20210802@Eden: Max Payout Per Match [redmine: #158073]
	- 20210831@Eden: Break setting for Saba Soccer/Basketball [redmine: #159626]
	- 20221226@Tacy: Alpha/NAP - Split 789y Site [RedmineID: #181596]
	- 20221123@Elodie: Migrate NG and Keno to DCS structure [Redmine: #179711]
	- 20231113Johnson: Change text SABA to Virtual for site 777777 [redmine:#194591]

Param's Explanation:
• @ErrCode:
    = 0: Update successfully.
    > 0: Specific Error.
  
• @ErrMsg: Error description.
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RoleID TINYINT, @recommend INT, @mrecommend int, @srecommend INT,  
			@SiteLabel VARCHAR (50), @SpecialPlatform TINYINT
	DECLARE @ErrType NVARCHAR(4000) = ''

	DECLARE @BetSetting TABLE(
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY,
		SportName		  NVARCHAR(50)
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

	INSERT INTO @BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch,SportName)
	--Soccer
	SELECT 1, 1, @minbet, @maxbet, @maxpermatch, NULL, @maxPOpermatch, [dbo].[f_Get_SportNameBySporttype](1,@Language) UNION ALL
	--Soccer Parlay
	SELECT 1, 9, @minbetv1mp, @maxbetv1mp, @maxpermatchv1mp, NULL, @maxPOpermatchv1mp, [dbo].[f_Get_SportNameBySporttype](1,@Language) UNION ALL
	--Basketball
	SELECT 2, 1, @minbetv2, @maxbetv2, @maxpermatchv2, NULL, @maxPOpermatchv2, [dbo].[f_Get_SportNameBySporttype](2,@Language) UNION ALL
	--Football
	SELECT 3, 1, @minbetv3, @maxbetv3, @maxpermatchv3, NULL, @maxPOpermatchv3, [dbo].[f_Get_SportNameBySporttype](3,@Language) UNION ALL
	--Tennis
	SELECT 5, 1, @minbetv5, @maxbetv5, @maxpermatchv5, NULL, @maxPOpermatchv5, [dbo].[f_Get_SportNameBySporttype](5,@Language) UNION ALL
	--Baseball
	SELECT 8, 1, @minbetv8, @maxbetv8, @maxpermatchv8, NULL, @maxPOpermatchv8, [dbo].[f_Get_SportNameBySporttype](8,@Language) UNION ALL
	--Golf
	SELECT 10, 1, @minbetv10, @maxbetv10, @maxpermatchv10, NULL, @maxPOpermatchv10, [dbo].[f_Get_SportNameBySporttype](10,@Language) UNION ALL
	--Motorsports
	SELECT 11, 1, @minbetv11, @maxbetv11, @maxpermatchv11, NULL, @maxPOpermatchv11, [dbo].[f_Get_SportNameBySporttype](11,@Language) UNION ALL
	--Other Sports
	SELECT 99, 1, @minbetv99, @maxbetv99, @maxpermatchv99, NULL, @maxPOpermatchv99, [dbo].[f_Get_SportNameBySporttype](99,@Language) UNION ALL
	--Mix Sports Parlay
	SELECT 99, 9, @minbetv99mp, @maxbetv99mp, @maxpermatchv99mp, NULL, @maxPOpermatchv99mp, NULL UNION ALL	
	--Saba Soccer
	SELECT 9901, 1, @minbetv1saba, @maxbetv1saba, @maxpermatchv1saba, NULL, @maxPOpermatchv1saba, NULL UNION ALL
	--Saba Basketball
	SELECT 9902, 1, @minbetv2saba, @maxbetv2saba, @maxpermatchv2saba, NULL, @maxPOpermatchv2saba, NULL
	
	Select @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend,
		@RoleID=RoleID, @SiteLabel = SiteLabel, @SpecialPlatform = SpecialPlatfrom
	from customer c with (NOLOCK)
	inner join Site s with (nolock) on s.site=c.site
	where CustID = @CustID
	
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
	SET t.SportName = CASE @Language 
						WHEN 'CS' THEN CASE WHEN @SpecialPlatform = 4 THEN N'虚拟足球' ELSE N'沙巴足球' END
						WHEN 'CT' THEN CASE WHEN @SpecialPlatform = 4 THEN N'虛擬足球' ELSE N'沙巴足球' END
						WHEN 'TH' THEN CASE WHEN @SpecialPlatform = 4 THEN N'ฟุตบอลอนิเมชั่น' ELSE N'ฟุตบอล Saba' END
						WHEN 'J' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Soccer' ELSE N'Saba Soccer' END
						WHEN 'KO' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Soccer' ELSE N'Saba Soccer' END
						WHEN 'VI' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Soccer' ELSE N'Saba Soccer' END
						ELSE CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Soccer' ELSE N'Saba Soccer' END
					 END
	FROM @BetSetting t
	WHERE sporttype = 9901 AND bettype = 1

	--Correct sportname for Saba Basketball
	UPDATE t
	SET t.SportName = case @Language 
						WHEN 'CS' THEN CASE WHEN @SpecialPlatform = 4 THEN N'虚拟篮球' ELSE N'沙巴篮球' END
						WHEN 'CT' THEN CASE WHEN @SpecialPlatform = 4 THEN N'虛擬籃球' ELSE N'沙巴籃球' END
						WHEN 'TH' THEN CASE WHEN @SpecialPlatform = 4 THEN N'บาสเกตบอลเสมือนจริง' ELSE N'บาสเกตบอล Saba' END
						WHEN 'J' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Basketball' ELSE N'Saba Basketball' END
						WHEN 'KO' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Basketball' ELSE N'Saba Basketball' END
						WHEN 'VI' THEN CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Basketball' ELSE N'Saba Basketball' END
						ELSE CASE WHEN @SpecialPlatform = 4 THEN N'Virtual Basketball' ELSE N'Saba Basketball' END
					 end
	FROM @BetSetting t
	WHERE sporttype = 9902 AND bettype = 1
	
	--> Check rule : Wrong Min bet/ Max bet/ Max per match/ Credit/ Master Agent name/ user group
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10001,@Language) + ' (' + SportName + ')'
				, @ErrCode = 410
	FROM @BetSetting
	WHERE (Minbet < 0 OR MaxBet < 0 OR MaxperMatch < 0)

	IF @ErrCode <> 0
		RETURN	

	--> Check rule : Wrong Max Payout Per Match
	SELECT TOP(1) @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10059,@Language) + ' (' + SportName + ')'
				, @ErrCode = 401
	FROM @BetSetting
	WHERE (MaxPayoutPerMatch < 0)
	
	IF @ErrCode <> 0
		RETURN

	--> Check rule : Min bet must be less than or equal to max bet and max bet must be less than or equal to max per match
	SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + ', ' + SportName 
    FROM @BetSetting 
    WHERE ( (MinBet > MaxBet) 
			OR (MaxBet > MaxPerMatch) 
		  )

	IF @ErrType <> ''
    BEGIN
		SELECT @ErrType = STUFF( @ErrType,1,2,'')
	    SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10067,@Language) + ' (' + @ErrType + ')'
				, @ErrCode = 402

	    RETURN
    END

	--> Check rule : Max Per Match must be less than or equal to Max Payout Per Match
	SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + ', ' + SportName 
    FROM @BetSetting 
    WHERE (MaxPerMatch > MaxPayoutPerMatch)

	IF @ErrType <> ''
    BEGIN
		SELECT @ErrType = STUFF( @ErrType,1,2,'')
	    SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10060,@Language) + ' (' + @ErrType + ')'
				, @ErrCode = 403

	    RETURN
    END
	
	--> Check rule : Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match
	SELECT @ErrType = ''
    SELECT @ErrType = @ErrType + ', ' + SportName 
    FROM @BetSetting 
    WHERE  ((MaxPerNumber <> 0 AND MaxBet > MaxPerNumber) 
			OR (MaxPerNumber<> 0 AND MaxPerNumber > MaxPerMatch) 
		  )

	IF @ErrType <> ''
    BEGIN
		SELECT @ErrType = STUFF( @ErrType,1,2,'')
	    SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10061,@Language) + ' (' + @ErrType + ')'
				, @ErrCode = 404

	    RETURN
    END

	IF @RoleID IN(2,3,4) -- Validate betlimit with upline's bet limit
	BEGIN
		IF @RoleID = 4
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
		IF @RoleID = 3
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
			WHERE cb.custid IN (@recommend,@mrecommend,@srecommend)
			GROUP BY cb.Sporttype,cb.Bettype
		END
		
		--> Check rule : Min Bet must be equal to or greater than Upline's Min Bet
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + ', ' + SportName 
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrType = STUFF( @ErrType,1,2,'')
			SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10062,@Language) + ' (' + @ErrType + ')'
					, @ErrCode = 405

			RETURN
		END

		--> Check rule : Max Bet must be equal to or less than Upline's Max Bet
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + ', ' + SportName 
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrType = STUFF( @ErrType,1,2,'')
			SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10063,@Language) + ' (' + @ErrType + ')'
					, @ErrCode = 406

			RETURN
		END

		--> Check rule : Max Per Match  must be equal to or less than Upline's Max Per Match
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + ', ' + SportName 
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrType = STUFF( @ErrType,1,2,'')
			SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10064,@Language) + ' (' + @ErrType + ')'
					, @ErrCode = 407

			RETURN
		END

		--> Check rule : Max Payout Per Match must be equal to or less than Upline's Max Payout Per Match
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + ', ' + SportName 
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPayoutPerMatch > 0 AND u.MaxPayoutPerMatch > 0 AND t.MaxPayoutPerMatch > u.MaxPayoutPerMatch)

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrType = STUFF( @ErrType,1,2,'')
			SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10065,@Language) + ' (' + @ErrType + ')'
					, @ErrCode = 408

			RETURN
		END

		--> Check rule : Max Per Ball must be equal to or less than Upline's Max Per Ball
		SELECT @ErrType = ''
		SELECT @ErrType = @ErrType + ', ' + SportName 
		FROM @BetSetting t
			INNER JOIN @Upline_BetSetting u 
				ON t.SportType = u.SportType AND t.BetType = u.BetType
		WHERE (t.MaxPerNumber > 0 AND u.MaxPerNumber > 0 AND t.MaxPerNumber > u.MaxPerNumber)

		IF @ErrType <> ''
		BEGIN
			SELECT @ErrType = STUFF( @ErrType,1,2,'')
			SELECT @ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](10066,@Language) + ' (' + @ErrType + ')'
					, @ErrCode = 409

			RETURN
		END
	END

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
							FOR XML PATH('Row'), ROOT ('Root'), TYPE)
						)

END
GO
