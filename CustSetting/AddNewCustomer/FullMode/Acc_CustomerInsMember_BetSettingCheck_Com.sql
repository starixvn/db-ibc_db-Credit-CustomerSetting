/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_BetSettingCheck_Com]
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	@SettingType26 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT	
AS
/*
	Created: 20231010@Eden  
	Task : check bet setting for Super 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]

	Param's Explanation: 
		- @SettingType26 = '<Root>
						<R SportType="1" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						<R SportType="2" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						...
						<R SportType="9901" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
						<R SportType="9902" BetType="1" MinBet="1" MaxBet="100" MPM="1000" MaxPayout="1000" />
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
		MaxPayoutPerMatch MONEY,	
		Child_DisplayOrder	INT
		PRIMARY KEY(sporttype, Bettype)
	);

	CREATE TABLE #ProductSettingDetail_Check(	
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SettingLevel] [tinyint],		
		Child_DisplayOrder	INT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,
		2 as SettingLevel,--Sporttype		
		Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE SettingType IN (26)
	
	DECLARE @xml XML
		
	IF ISNULL(@SettingType26,'') <> ''
	BEGIN
		SELECT @xml = CONVERT(XML,@SettingType26)
		
		INSERT INTO @BetSetting(
			SportType, 
			BetType, 
			MinBet, 
			MaxBet, 
			MaxPerMatch, 
			MaxPayoutPerMatch
			)
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
	
	DROP TABLE #ProductSettingDetail_Check
END	