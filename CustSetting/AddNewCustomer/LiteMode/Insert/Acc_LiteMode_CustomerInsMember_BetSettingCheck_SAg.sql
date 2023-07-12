/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_BetSettingCheck_SAg]
	@srecommend INT,
	@SettingType26 VARCHAR(MAX)= '', --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2, VS
	@SettingType23 VARCHAR(MAX)= '', --RNG Games	
	@SystemID TINYINT = 1,
	@CreationStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20230516@Johnson  
	Task : check bet setting for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230516@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType26 = '<Root>
						<R SportType="1" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						<R SportType="2" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						...
						<R SportType="9901" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						<R SportType="9902" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
					</Root>'
		- @SettingType2 = '<Root>
						<R SportType="43" BetType="1" MinBet="1" MaxBet="100" MPM="1000" />
						<R SportType="44" BetType="3" MinBet="1" MaxBet="100" MPM="1000" />
						<R SportType="9908" BetType="1201" MinBet="1" MaxBet="100" MPM="1000" />
					</Root>'			
		- @SettingType23 = '<Root>
						<R SportType="161" BetType="81" MinBet="1" MaxBet="100" MPM="1000" MaxPerNumber="100" />
						<R SportType="202" BetType="1501" MinBet="1" MaxBet="100" MPM="1000"  />
						...
						<R SportType="220" BetType="1024" MinBet="1" MaxBet="100" MPM="1000" />						
					</Root>'		
		
*/	
BEGIN
	SET NOCOUNT ON
	
	DECLARE @BetSetting TABLE(		
		SportType         SMALLINT, 
		BetType           SMALLINT, 
		MinBet            MONEY, 
		MaxBet            MONEY, 
		MaxPerMatch       MONEY, 
		MaxPerNumber      MONEY, 
		MaxPayoutPerMatch MONEY		
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
	
	CREATE TABLE #ProductSettingDetail_Check(	
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[GroupID] [tinyint],
		[GroupType] [tinyint],
		[SettingLevel] [tinyint],		
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,GroupID,GroupType,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,GroupID,GroupType,
		2 as SettingLevel--Sporttype		
	FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus)
	WHERE SettingType IN (26,2,23)
	
	DECLARE @xml XML,
		@currency TINYINT
	
	SELECT @currency = currency 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @srecommend
	
	IF ISNULL(@SettingType26,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType26)
		
		INSERT INTO @BetSetting(
			SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch, 
			MaxPayoutPerMatch)
		SELECT 
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
			T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
			T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
			T.c.query('.').value('(R/@MaxPayout)[1]', 'money') AS MaxPayoutPerMatch
		FROM  @xml.nodes('/Root/R') T(c) 
		
		--> Check rule : Wrong Min bet/ Max bet/ Max per match
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting
				WHERE (Minbet < 0 OR MaxBet < 0 OR MaxperMatch < 0)
				)
		BEGIN
			SET @xml = (
				SELECT 10003 AS '@MsgID'
						, 'Wrong Min bet/ Max bet/ Max per match' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, ps.SettingLevel AS '@SettingLevel'
								, ps.GroupID AS '@GroupID'
								, ps.GroupType AS '@GroupType'
							FROM @BetSetting tmp
								INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
							WHERE (Minbet < 0 OR MaxBet < 0 OR MaxperMatch < 0)								
							FOR XML PATH('Row')
								, TYPE
							)
						FOR XML PATH('Root')
						, TYPE
						)
			
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 201
		END	

		--> Check rule : Wrong Max Payout Per Match
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting
				WHERE MaxPayoutPerMatch < 0
				)
		BEGIN
			SET @xml = (
				SELECT 10059 AS '@MsgID'
						, 'Wrong Max Payout Per Match.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, ps.SettingLevel AS '@SettingLevel'
								, ps.GroupID AS '@GroupID'
								, ps.GroupType AS '@GroupType'
							FROM @BetSetting tmp
								INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
							WHERE MaxPayoutPerMatch < 0	
							FOR XML PATH('Row')
								, TYPE
							)
						FOR XML PATH('Root')
						, TYPE
						)
			
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 202
		END
	
		--> Check rule : Min bet must be less than or equal to max bet and max bet must be less than or equal to max per match
		IF EXISTS(SELECT TOP 1 1
					FROM @BetSetting
					WHERE (MinBet > MaxBet) 
						OR (MaxBet > MaxPerMatch) 
					)
		BEGIN
			SET @xml = (
					SELECT 10067 AS '@MsgID'
							, 'Min Bet must be less than or equal to Max Bet and Max Bet must be less than or equal to Max Per Match' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, ps.SettingLevel AS '@SettingLevel'
								, ps.GroupID AS '@GroupID'
								, ps.GroupType AS '@GroupType'
								FROM @BetSetting tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
								WHERE (MinBet > MaxBet) 
										OR (MaxBet > MaxPerMatch) 
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 203
		END
		
		--> Check rule : Max Per Match must be less than or equal to Max Payout Per Match
		IF EXISTS(SELECT TOP 1 1
					FROM @BetSetting
					WHERE MaxPerMatch > MaxPayoutPerMatch 
					)
		BEGIN
			SET @xml = (
					SELECT 10060 AS '@MsgID'
							, 'Max Per Match must be less than or equal to Max Payout Per Match' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
								WHERE MaxPerMatch > MaxPayoutPerMatch 
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 204
		END
		
		--SB bet setting
		INSERT INTO @Upline_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL((CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL((CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL((CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),				
				MaxPOpermatch = ISNULL((CASE WHEN cb.MaxPayoutPerMatch = 0 THEN NULL ELSE cb.MaxPayoutPerMatch END),0)
		FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @srecommend
			
		--> Check rule : Min Bet must be equal to or greater than Upline's Min Bet
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)
		)
		BEGIN
			SET @xml = (
					SELECT 10062 AS '@MsgID'
							, 'Min Bet must be greater than or equal to Upline''s Min Bet' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t. BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 205
		END
		
		--> Check rule : Max Bet must be equal to or less than Upline's Max Bet
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)
		)
		BEGIN
			SET @xml = (
					SELECT 10063 AS '@MsgID'
							, 'Max Bet must be less than or equal to Upline''s Max Bet' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 206
		END
		
		--> Check rule : Max Per Match  must be equal to or less than Upline's Max Per Match
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)
		)
		BEGIN
			SET @xml = (
					SELECT 10064 AS '@MsgID'
							, 'Max Per Match must be less than or equal to Upline''s Max Per Match' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 207
		END
		
		--> Check rule : Max Payout Per Match must be equal to or less than Upline's Max Payout Per Match
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxPayoutPerMatch > 0 AND u.MaxPayoutPerMatch > 0 AND t.MaxPayoutPerMatch > u.MaxPayoutPerMatch)
		)
		BEGIN
			SET @xml = (
					SELECT 10065 AS '@MsgID'
							, 'Max Payout Per Match must be less than or equal to Upline''s Max Payout Per Match' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxPayoutPerMatch > 0 AND u.MaxPayoutPerMatch > 0 AND t.MaxPayoutPerMatch > u.MaxPayoutPerMatch)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 208
		END
	END
	
	--check RNG Games, SB2
	IF ISNULL(@SettingType23,'') <> '' OR ISNULL(@SettingType2,'') <> ''
	BEGIN
		DELETE @BetSetting
		DELETE @Upline_BetSetting
		
		SELECT @xml = CONVERT(XML,@SettingType23)
		
		INSERT INTO @BetSetting(
			SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch, 
			MaxPerNumber)
		SELECT
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
			T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
			T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
			T.c.query('.').value('(R/@MaxPerNumber)[1]', 'money') AS MaxPerNumber
		FROM  @xml.nodes('/Root/R') T(c) 
		
		SELECT @xml = CONVERT(XML,@SettingType2)
		
		INSERT INTO @BetSetting(
			SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch)
		SELECT 
			T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
			T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
			T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
			T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
			T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch		
		FROM  @xml.nodes('/Root/R') T(c) 
		
		--> Check rule : Wrong Min bet/ Max bet/ Max per match
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting tmp
				LEFT JOIN dbo.ProductBetSetting pb
					ON pb.Sporttype = tmp.SportType
						AND pb.Bettype = tmp.BetType
						AND pb.Currency = @Currency
				WHERE (tmp.Minbet < 0 OR tmp.MaxBet < 0 OR tmp.MaxperMatch < 0)
					OR (
							(
								tmp.MinBet	<> 0 OR tmp.MaxBet	<> 0 OR tmp.MaxPerMatch	<> 0
							)							
							AND
							(
								tmp.MinBet		< ISNULL(pb.MinBet,0)
								OR tmp.MaxBet		< ISNULL(pb.MinBet,0)
								OR tmp.MaxPerMatch	< ISNULL(pb.MinBet,0)
							)
						)
					OR (@SystemID BETWEEN 6 AND 9 --789y ExtNAP and Alpha 
						AND (tmp.Minbet < 1 OR tmp.MaxBet < 1 OR tmp.MaxperMatch < 1 OR tmp.MaxPerNumber < 1)
						)
				)	
		BEGIN
			SET @xml = (
				SELECT 10003 AS '@MsgID'
						, 'Wrong Min bet/ Max bet/ Max per match' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, ps.SettingLevel AS '@SettingLevel'
								, ps.GroupID AS '@GroupID'
								, ps.GroupType AS '@GroupType'
							FROM @BetSetting tmp
								INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
							LEFT JOIN dbo.ProductBetSetting pb
								ON pb.Sporttype = tmp.SportType
									AND pb.Bettype = tmp.BetType
									AND pb.Currency = @Currency
							WHERE (tmp.Minbet < 0 OR tmp.MaxBet < 0 OR tmp.MaxperMatch < 0)
								OR (
										(
											tmp.MinBet	<> 0 OR tmp.MaxBet	<> 0 OR tmp.MaxPerMatch	<> 0
										)							
										AND
										(
											tmp.MinBet		< ISNULL(pb.MinBet,0)
											OR tmp.MaxBet		< ISNULL(pb.MinBet,0)
											OR tmp.MaxPerMatch	< ISNULL(pb.MinBet,0)
										)
									)
								OR (@SystemID BETWEEN 6 AND 9 --789y ExtNAP and Alpha 
									AND (tmp.Minbet < 1 OR tmp.MaxBet < 1 OR tmp.MaxperMatch < 1 OR tmp.MaxPerNumber < 1)
									)
							FOR XML PATH('Row')
								, TYPE
							)
						FOR XML PATH('Root')
						, TYPE
						)
			
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 220
		END	
		
		--> Check rule : Wrong Max Per Ball
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting tmp				
				WHERE tmp.MaxPerNumber < 0
					OR (tmp.MaxPerNumber < 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
				)	
		BEGIN
			SET @xml = (
				SELECT 10002 AS '@MsgID'
						, 'Wrong Max Per Ball' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, ps.SettingLevel AS '@SettingLevel'
								, ps.GroupID AS '@GroupID'
								, ps.GroupType AS '@GroupType'
							FROM @BetSetting tmp
								INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype				
							WHERE tmp.MaxPerNumber < 0
								OR (tmp.MaxPerNumber < 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
							FOR XML PATH('Row')
								, TYPE
							)
						FOR XML PATH('Root')
						, TYPE
						)
			
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 221
		END	
		
		--> Check rule : Min bet must be less than or equal to max bet and max bet must be less than or equal to max per match
		IF EXISTS(SELECT TOP 1 1
					FROM @BetSetting
					WHERE (MinBet > MaxBet) 
						OR (MaxBet > MaxPerMatch) 
					)
		BEGIN
			SET @xml = (
					SELECT 10067 AS '@MsgID'
							, 'Min Bet must be less than or equal to Max Bet and Max Bet must be less than or equal to Max Per Match' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
								WHERE (MinBet > MaxBet) 
									OR (MaxBet > MaxPerMatch) 
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 222
		END
		
		--> Check rule :Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting tmp
				WHERE tmp.MaxPerNumber <> 0
					AND (
						tmp.MaxBet > tmp.MaxPerNumber 
						OR tmp.MaxPerNumber > tmp.MaxPerMatch 
						)
				)
		BEGIN
			SET @xml = (
					SELECT 10061 AS '@MsgID'
							, 'Max Per Ball must be greater than or equal to Max Bet and less than or equal to Max Per Match' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
								WHERE tmp.MaxPerNumber <> 0
									AND (
										tmp.MaxBet > tmp.MaxPerNumber 
										OR tmp.MaxPerNumber > tmp.MaxPerMatch 
										) 
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
						)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 223
		END
		
		--NG,Happy5
		INSERT INTO @Upline_BetSetting (SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL((CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL((CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL((CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
				MaxPerNumber = ISNULL((CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0)
		FROM CustBetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @srecommend
		
		--RNG Lottery,VS..
		INSERT INTO @Upline_BetSetting (SportType,BetType,MinBet,MaxBet,MaxPerMatch)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL((CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL((CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL((CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0)
		FROM CustBetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @srecommend
		
		--> Check rule : Min Bet must be equal to or greater than Upline's Min Bet
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)
		)
		BEGIN
			SET @xml = (
					SELECT 10062 AS '@MsgID'
							, 'Min Bet must be greater than or equal to Upline''s Min Bet' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MinBet > 0 AND u.MinBet > 0 AND t.MinBet < u.MinBet)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 224
		END
		
		--> Check rule : Max Bet must be equal to or less than Upline's Max Bet
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)
		)
		BEGIN
			SET @xml = (
					SELECT 10063 AS '@MsgID'
							, 'Max Bet must be less than or equal to Upline''s Max Bet' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxBet > 0 AND u.MaxBet > 0 AND t.MaxBet > u.MaxBet)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 225
		END
		
		--> Check rule : Max Per Match  must be equal to or less than Upline's Max Per Match
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)
		)
		BEGIN
			SET @xml = (
					SELECT 10064 AS '@MsgID'
							, 'Max Per Match must be less than or equal to Upline''s Max Per Match' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxPerMatch > 0 AND u.MaxPerMatch > 0 AND t.MaxPerMatch > u.MaxPerMatch)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 226
		END
		
		--> Check rule : Max Per Ball must be equal to or less than Upline's Max Per Ball
		IF EXISTS (SELECT TOP 1 1
				FROM @BetSetting t
					INNER JOIN @Upline_BetSetting u 
						ON t.SportType = u.SportType AND t.BetType = u.BetType
				WHERE (t.MaxPerNumber > 0 AND u.MaxPerNumber > 0 AND t.MaxPerNumber > u.MaxPerNumber)
		)
		BEGIN
			SET @xml = (
					SELECT 10066 AS '@MsgID'
							, 'Max Per Ball must be less than or equal to Upline''s Max Per Ball' AS '@Msg'
							, (
								SELECT t.SportType AS '@SportType'
									, t.BetType AS '@BetType'
									, ps.SettingLevel AS '@SettingLevel'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @BetSetting t
									INNER JOIN #ProductSettingDetail_Check ps ON t.Sporttype = ps.Sporttype AND t.Bettype = ps.Bettype
									INNER JOIN @Upline_BetSetting u 
										ON t.SportType = u.SportType AND t.BetType = u.BetType
								WHERE (t.MaxPerNumber > 0 AND u.MaxPerNumber > 0 AND t.MaxPerNumber > u.MaxPerNumber)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
				
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 227
		END
	END	
	
	DROP TABLE #ProductSettingDetail_Check
END	