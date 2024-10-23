/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_BetSettingCheck_MAg]
	@mrecommend INT,
	@siteid SMALLINT =0,
	@currency SMALLINT=0,
	
	@SettingType26 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2, VS
	@SettingType23 VARCHAR(MAX)= '', --RNG Games
	@SettingType16 VARCHAR(MAX)= '', --Others Games	
	@SystemID TINYINT = 1,
	@SettingStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT,
	@IsValidateParam BIT = 1,
	@IsUpdateParam BIT = 0 -- Update Parameter
AS
/*
	Created: 20230628@Johnson  
	Task : check bet setting for agent 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230628@Johnson: initial sp [redmine: #179159]
		- 20240118@Eden: avoid data duplicate of Esport & Muay Thai Betsetting [redmine: #199970]
		- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240610@Johnson: Scale out DBCUST [redmine: #199915]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20240822@Eden: Scale out DBCUST - Credit Customer in GlobCustDB [redmine: #206823]

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
		- @SettingType16 = '<Root>
						<R SportType="43" BetType="1" MinBet="1" MaxBet="100" MPM="1000" />			
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
		MaxPayoutPerMatch MONEY,
		Child_DisplayOrder	INT
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
	
	DECLARE @BetSettingUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)

	CREATE TABLE #ProductSettingDetail_Check(	
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[GroupID] [tinyint],
		[GroupType] [tinyint],
		[SettingLevel] [tinyint],	
		Child_DisplayOrder	INT,
		SubType TINYINT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,GroupID,GroupType,SettingLevel,Child_DisplayOrder,SubType)
	SELECT SportType,BetType,SettingType,IsLive,GroupID,GroupType,
		2 as SettingLevel,--Sporttype		
		Child_DisplayOrder,
		SubType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (26,2,23,16)
	
	DECLARE @xml XML,	
		@srecommend INT
	
	SELECT @srecommend = srecommend 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @mrecommend
	
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
		
		IF @IsValidateParam = 1
		BEGIN
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
									OR (@SystemID BETWEEN 6 AND 9 --789y ExtNAP and Alpha
										AND (Minbet < 1 OR MaxBet < 1 OR MaxperMatch < 1)
										)
								FOR XML PATH('Row')
									, TYPE
								)
							FOR XML PATH('Root')
							, TYPE
							)
			
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 201
				RETURN
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
				RETURN
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
					RETURN
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
					RETURN
			END
		
			--SB bet setting
			INSERT INTO @Upline_BetSetting(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPayoutPerMatch)
			SELECT  cb.Sporttype,cb.Bettype,
					MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
					MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
					MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),				
					MaxPOpermatch = ISNULL(MIN(CASE WHEN cb.MaxPayoutPerMatch = 0 THEN NULL ELSE cb.MaxPayoutPerMatch END),0)
			FROM BetSetting_Agent cb WITH (NOLOCK,FORCESEEK)
				INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			WHERE cb.custid IN (@mrecommend,@srecommend)
			GROUP BY cb.Sporttype,cb.Bettype
			
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
					SET @ErrCode = 205
					RETURN
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
					RETURN
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
					RETURN
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
					RETURN
			END
		END

		IF @IsUpdateParam = 1 -- UpdateParameter for update and writelog
		BEGIN
			UPDATE t
			SET t.Child_DisplayOrder = d.Child_DisplayOrder
			FROM @BetSetting t
				INNER JOIN #ProductSettingDetail_Check d 
					ON t.SportType = d.SportType
					AND t.BetType = d.BetType
		
			SELECT @SettingType26 = (
			SELECT SportType '@SportType', 
				BetType '@BetType', 
				MinBet '@MinBet',
				MaxBet '@MaxBet',
				MaxPerMatch '@MPM',
				MaxPayoutPerMatch '@MaxPayout'
			FROM @BetSetting
			ORDER BY Child_DisplayOrder,SportType,BetType
			FOR XML PATH ('R'), ROOT('Root')
			)
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
			RETURN
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
			RETURN
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
				RETURN
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
				RETURN
		END
		
		--Settingtype 23
		INSERT INTO @Upline_BetSetting (SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
				MaxPerNumber = CASE WHEN MAX(d.SubType) = 2 THEN ISNULL(MIN(CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0) END
		FROM BetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			INNER JOIN #ProductSettingDetail_Check d 
				ON b.SportType = d.SportType
				AND b.BetType = d.BetType
				AND d.SettingType = 23
		WHERE cb.custid IN (@srecommend,@mrecommend)
		GROUP BY cb.Sporttype,cb.Bettype

		--Other Settingtype
		INSERT INTO @Upline_BetSetting (SportType,BetType,MinBet,MaxBet,MaxPerMatch)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0)
		FROM CustBetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
			INNER JOIN #ProductSettingDetail_Check d 
				ON b.SportType = d.SportType
				AND b.BetType = d.BetType
				AND d.SettingType <> 23
		WHERE cb.custid IN (@srecommend,@mrecommend)
		GROUP BY cb.Sporttype,cb.Bettype

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
				RETURN
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
				RETURN
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
				RETURN
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
				RETURN
		END
	END	
		
	--check Others Games
	IF ISNULL(@SettingType16,'') <> '' 
	BEGIN
		DELETE @BetSetting
		DELETE @Upline_BetSetting
		DELETE @BetSettingUnlimit
		
		SELECT @xml = CONVERT(XML,@SettingType16)
		
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
		
		INSERT INTO @BetSettingUnlimit
		SELECT cs.SportType,cs.BetType,
				CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
							OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN @BetSetting s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE cs.custid = @srecommend AND ps.Currency = @Currency
		
		--> Check rule : Wrong Min bet/ Max bet/ Max per match
		IF EXISTS(SELECT TOP 1 1
				FROM @BetSetting tmp
				INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
				LEFT JOIN dbo.ProductBetSetting pb
					ON pb.Sporttype = tmp.SportType
						AND pb.Bettype = tmp.BetType
						AND pb.Currency = @Currency
				WHERE (tmp.Minbet < 0 OR tmp.MaxBet < 0 OR tmp.MaxperMatch < 0)
					OR (	
							s.IsAllowUnlimit = 0
							AND
							(
								tmp.MinBet	<> 0 OR tmp.MaxBet	<> 0 OR tmp.MaxPerMatch	<> 0
							)							
							AND
							((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
							OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
							OR (tmp.MaxPerMatch <> 0 AND tmp.MaxPerMatch > ISNULL(pb.MaxPerMatch,0))
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
								INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
								INNER JOIN #ProductSettingDetail_Check ps ON tmp.Sporttype = ps.Sporttype AND tmp.Bettype = ps.Bettype
							LEFT JOIN dbo.ProductBetSetting pb
								ON pb.Sporttype = tmp.SportType
									AND pb.Bettype = tmp.BetType
									AND pb.Currency = @Currency
							WHERE (tmp.Minbet < 0 OR tmp.MaxBet < 0 OR tmp.MaxperMatch < 0)
								OR (	
									s.IsAllowUnlimit = 0
									AND
									(
										tmp.MinBet	<> 0 OR tmp.MaxBet	<> 0 OR tmp.MaxPerMatch	<> 0
									)							
									AND
									((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
									OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
									OR (tmp.MaxPerMatch <> 0 AND tmp.MaxPerMatch > ISNULL(pb.MaxPerMatch,0))
									)
								)
								OR (@SystemID BETWEEN 6 AND 9 --789y ExtNAP and Alpha 
									AND (tmp.Minbet < 1 OR tmp.MaxBet < 1 OR tmp.MaxperMatch < 1)
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
			RETURN
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
				RETURN
		END
		
		INSERT INTO @Upline_BetSetting (SportType,BetType,MinBet,MaxBet,MaxPerMatch)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0)
		FROM CustBetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @BetSetting b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid IN (@srecommend, @mrecommend)		
		GROUP BY cb.Sporttype,cb.Bettype		
		
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
				RETURN
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
				RETURN
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
				RETURN
		END		
	END
	
	DROP TABLE #ProductSettingDetail_Check
END	