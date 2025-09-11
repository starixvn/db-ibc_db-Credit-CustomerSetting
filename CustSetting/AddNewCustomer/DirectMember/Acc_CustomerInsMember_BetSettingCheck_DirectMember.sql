/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerInsMember_BetSettingCheck_DirectMember
	@srecommend INT,
	@mrecommend INT,
	@siteid SMALLINT =0,
	@currency SMALLINT=0,
	
	@GroupTypeT151 VARCHAR(MAX)= '', --SB
	@GroupTypeT154 VARCHAR(MAX)= '', --Others
	@SystemID TINYINT = 1,
	@SettingStatus TINYINT = 0,
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20241107@Eden	
	Task: Validate when Super/Master create direct member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969] 
		- 20250911@Johnson: Max Payout Per Match - Change to Max Win [redmine: #236447]
	Param's Explanation: 
		@GroupTypeT151 :
			[
				{"SportType": "1","BetType": "9","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "2","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "9902","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "1","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "9901","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "11","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "99","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "3","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "5","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "8","BetType": "1","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "10","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10","MaxPayout": "110"},
				{"SportType": "99","BetType": "9","MinBet": "0","MaxBet": "0","MPM": "0","MaxPayout": "0"},
				{"SportType": "43","BetType": "1","MinBet": "0","MaxBet": "10","MPM": "10"},
				{"SportType": "44","BetType": "3","MinBet": "0","MaxBet": "0","MPM": "0"}
			],
			@GroupTypeT154:
			[
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			],
		
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
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[GroupID] [tinyint],
		[GroupType] [tinyint],
		[SettingLevel] [tinyint],
		Child_DisplayOrder	INT,
		SubType TINYINT,
	)
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,IsLive,GroupID,GroupType,SettingLevel,Child_DisplayOrder,SubType)
	SELECT SportType,BetType,IsLive,GroupID,GroupType,
		2 as SettingLevel,--Sporttype
		Child_DisplayOrder,
		SubType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType IN (151,154)
	
	DECLARE @xml XML
	
	IF ISNULL(@GroupTypeT151,'') <> ''
	BEGIN
		INSERT INTO @BetSetting(SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPayoutPerMatch)
		SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPayout
		FROM OPENJSON(@GroupTypeT151) WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,MinBet MONEY  '$.MinBet'
				,MaxBet MONEY  '$.MaxBet'
				,MPM MONEY  '$.MPM'
				,MaxPayout MONEY  '$.MaxPayout'
				,MaxPerNumber MONEY  '$.MaxPerNumber'
			)
		
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

			--> Check rule : Wrong Max Win Per Match
			IF EXISTS(SELECT TOP 1 1
					FROM @BetSetting
					WHERE MaxPayoutPerMatch < 0
					)
			BEGIN
				SET @xml = (
					SELECT 10059 AS '@MsgID'
							, 'Wrong Max Win Per Match.' AS '@Msg'
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
		
			--> Check rule : Max Per Match must be less than or equal to Max Win Per Match
			IF EXISTS(SELECT TOP 1 1
						FROM @BetSetting
						WHERE MaxPerMatch > MaxPayoutPerMatch 
						)
			BEGIN
				SET @xml = (
						SELECT 10060 AS '@MsgID'
								, 'Max Per Match must be less than or equal to Max Win Per Match' AS '@Msg'
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
		
			--> Check rule : Max Win Per Match must be equal to or less than Upline's Max Win Per Match
			IF EXISTS (SELECT TOP 1 1
					FROM @BetSetting t
						INNER JOIN @Upline_BetSetting u 
							ON t.SportType = u.SportType AND t.BetType = u.BetType
					WHERE (t.MaxPayoutPerMatch > 0 AND u.MaxPayoutPerMatch > 0 AND t.MaxPayoutPerMatch > u.MaxPayoutPerMatch)
			)
			BEGIN
				SET @xml = (
						SELECT 10065 AS '@MsgID'
								, 'Max Win Per Match must be less than or equal to Upline''s Max Win Per Match' AS '@Msg'
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
	END
	
	--check RNG Games, SB2
	IF ISNULL(@GroupTypeT154,'') <> '' 	
	BEGIN
		DELETE @BetSetting
		DELETE @Upline_BetSetting
		
		INSERT INTO @BetSetting(SportType, BetType, MinBet, MaxBet, MaxPerMatch, MaxPerNumber)
		SELECT SportType,BetType,MinBet,MaxBet,MPM,MaxPerNumber
		FROM OPENJSON(@GroupTypeT154) WITH (
				SportType SMALLINT  '$.SportType'
				,BetType SMALLINT  '$.BetType'
				,MinBet MONEY  '$.MinBet'
				,MaxBet MONEY  '$.MaxBet'
				,MPM MONEY  '$.MPM'
				,MaxPerNumber MONEY '$.MaxPerNumber'
			)
				
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

	DROP TABLE #ProductSettingDetail_Check
END	
GO