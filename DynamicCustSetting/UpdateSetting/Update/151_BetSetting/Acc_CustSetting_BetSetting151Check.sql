/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_BetSetting151Check] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @BetSetting	VARCHAR(MAX)
	, @SystemID		TINYINT
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)		= ''		OUTPUT
AS
/*
	Created: 20231023@Helios
	Task : Check Customer's Bet Setting for SB
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_BetSettingCheck

	Revisions: 
		- 20231023@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 

	Param's Explanation:
	@BetSetting: Json Type
		'[
				  { "SportType": "1","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "880" },
				  { "SportType": "1","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "2","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "3","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "5","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "8","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "10","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "11","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "99","BetType": "9","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9901","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "9902","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "40" },
				  { "SportType": "43","BetType": "1","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" },
				  { "SportType": "44","BetType": "3","MinBet": "28","MaxBet": "40","MPM": "40","MaxPayout": "0" }
		]'

*/

BEGIN
	SET NOCOUNT ON

	DECLARE @xml		XML

	DECLARE @ErrorSportTypeTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPayoutPerMatch	MONEY
			, MinMinBet			MONEY
			, MaxMaxBet			MONEY
			, MaxMaxPerMatch		MONEY
			, MaxMaxPayoutPerMatch	MONEY
		)
	DECLARE @UplineLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPayoutPerMatch	MONEY
		)
	DECLARE @NewBetSettingTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPayoutPerMatch	MONEY
		)

	--------------------Collect Data--------------------
	-- Check if XML is null or empty
	IF @BetSetting IS NULL OR @BetSetting = ''
		RETURN
	

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg	= ''



	-- Parse Data Json
	INSERT INTO @NewBetSettingTbl (SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch)
	SELECT
	    SportType,
	    BetType,
	    MinBet,
	    MaxBet,
	    MPM,
	    MaxPayout
	FROM OPENJSON(@BetSetting)
	    WITH
		  (
			SportType		SMALLINT,
			BetType		SMALLINT,
			MinBet		MONEY,
			MaxBet		MONEY,
			MPM			MONEY,
			MaxPayout		MONEY
        ) AS BetSetting 

	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetSettingTbl t
		INNER JOIN ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 26
		AND u.FunctionType = 1 --Edit Customer


	IF @roleid = 3
	  BEGIN
		INSERT INTO @UplineLimitTbl (SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch)
		SELECT bl.SportType
			, bl.BetType
			, MAX(CASE 
						WHEN bl.MinBet = 0
							THEN NULL
						ELSE bl.MinBet
					END) AS MinBet
			, MIN(CASE 
						WHEN bl.MaxBet = 0
							THEN NULL
						ELSE bl.MaxBet
					END) AS MaxBet
			, MIN(CASE 
						WHEN bl.MaxPerMatch = 0
							THEN NULL
						ELSE bl.MaxPerMatch
					END) AS MaxPerMatch
			, MIN(CASE 
						WHEN bl.MaxPayoutPerMatch = 0
							THEN NULL
						ELSE bl.MaxPayoutPerMatch
					END) AS MaxPayoutPerMatch
		FROM dbo.CustBetSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID			= @SuperID
		GROUP BY bl.SportType
			, bl.BetType
	  END
	 ELSE IF @RoleID = 2
	 BEGIN
		--Get super/master 's bet limit
		INSERT INTO @UplineLimitTbl (SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch)
		SELECT bl.SportType
			, bl.BetType
			, MAX(CASE 
						WHEN bl.MinBet = 0
							THEN NULL
						ELSE bl.MinBet
					END) AS MinBet
			, MIN(CASE 
						WHEN bl.MaxBet = 0
							THEN NULL
						ELSE bl.MaxBet
					END) AS MaxBet
			, MIN(CASE 
						WHEN bl.MaxPerMatch = 0
							THEN NULL
						ELSE bl.MaxPerMatch
					END) AS MaxPerMatch
			, MIN(CASE 
						WHEN bl.MaxPayoutPerMatch = 0
							THEN NULL
						ELSE bl.MaxPayoutPerMatch
					END) AS MaxPayoutPerMatch
		FROM dbo.CustBetSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID		= @SuperID
			OR bl.CustID	= @MasterID
		GROUP BY bl.SportType
			, bl.BetType
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Get super/master 's bet limit
		INSERT INTO @UplineLimitTbl (SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch)
		SELECT bl.SportType
			, bl.BetType
			, MAX(CASE 
						WHEN bl.MinBet = 0
							THEN NULL
						ELSE bl.MinBet
					END) AS MinBet
			, MIN(CASE 
						WHEN bl.MaxBet = 0
							THEN NULL
						ELSE bl.MaxBet
					END) AS MaxBet
			, MIN(CASE 
						WHEN bl.MaxPerMatch = 0
							THEN NULL
						ELSE bl.MaxPerMatch
					END) AS MaxPerMatch
			, MIN(CASE 
						WHEN bl.MaxPayoutPerMatch = 0
							THEN NULL
						ELSE bl.MaxPayoutPerMatch
					END) AS MaxPayoutPerMatch
		FROM dbo.CustBetSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID		= @SuperID
			OR bl.CustID	= @MasterID
			OR bl.CustID	= @AgentID
		GROUP BY bl.SportType
			, bl.BetType
	END

	-- Check rule : Wrong Min bet/ Max bet/ Max per match

	--Get 1 error row
	INSERT INTO @ErrorSportTypeTbl (SportType , BetType , MinBet , MaxBet , MaxPerMatch , MaxPayoutPerMatch , MinMinBet , MaxMaxBet , MaxMaxPerMatch , MaxMaxPayoutPerMatch)
	SELECT	  tmp.SportType
			, tmp.BetType
			, tmp.MinBet
			, tmp.MaxBet
			, tmp.MaxPerMatch
			, tmp.MaxPayoutPerMatch
			, ISNULL(ubl.MinBet, 0)
			, ISNULL(ubl.MaxBet, 0)
			, ISNULL(ubl.MaxPerMatch, 0)
			, ISNULL(ubl.MaxPayoutPerMatch, 0)
	FROM @NewBetSettingTbl tmp
			LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
	WHERE		   tmp.MinBet			< 0
			OR tmp.MaxBet			< 0
			OR tmp.MaxPerMatch		< 0
			OR (tmp.SportType NOT IN (43,44) AND tmp.MaxPayoutPerMatch	< 0)

			OR (tmp.SportType IN (43,44) AND tmp.MinBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.SportType IN (43,44) AND tmp.MaxBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.SportType IN (43,44) AND tmp.MaxPerMatch		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha

			OR ((tmp.MinBet	<> 0 OR tmp.MaxBet <> 0) AND tmp.MinBet > tmp.MaxBet)
			OR ((tmp.MaxBet	<> 0 OR tmp.MaxPerMatch <> 0) AND tmp.MaxBet > tmp.MaxPerMatch)
			OR ((tmp.MinBet	<> 0 OR tmp.MaxPerMatch <> 0) AND tmp.MinBet > tmp.MaxPerMatch)
			OR (tmp.SportType NOT IN (43,44) AND (tmp.MaxPerMatch <> 0 OR tmp.MaxPayoutPerMatch <> 0) AND tmp.MaxPerMatch > tmp.MaxPayoutPerMatch)

			OR (ubl.MinBet	> 0 AND tmp.MinBet > 0 AND tmp.MinBet < ubl.MinBet)
			OR (ubl.MaxBet	> 0 AND tmp.MaxBet > 0 AND tmp.MaxBet > ubl.MaxBet)
			OR (ubl.MaxPerMatch > 0 AND tmp.MaxPerMatch > 0 AND tmp.MaxPerMatch > ubl.MaxPerMatch)
			OR (tmp.SportType NOT IN (43,44) AND ubl.MaxPayoutPerMatch > 0 AND tmp.MaxPayoutPerMatch > 0 AND tmp.MaxPayoutPerMatch > ubl.MaxPayoutPerMatch)
			

	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
			)
		RETURN
	
	--Check all setting >=0
	IF EXISTS(SELECT TOP 1 1 
				FROM @ErrorSportTypeTbl tmp
					LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
				WHERE	tmp.MinBet				< 0
					OR tmp.MaxBet			< 0
					OR tmp.MaxPerMatch		< 0
					OR (tmp.SportType IN (43,44) AND tmp.MinBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
					OR (tmp.SportType IN (43,44) AND tmp.MaxBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
					OR (tmp.SportType IN (43,44) AND tmp.MaxPerMatch		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			)
	BEGIN
			SET @xml = (
					SELECT 10003 AS '@MsgID'
						, 'Wrong Min bet/ Max bet/ Max per match.' AS '@Msg'
						, (
							SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType   AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
								LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
							WHERE	tmp.MinBet				< 0
								OR tmp.MaxBet			< 0
								OR tmp.MaxPerMatch		< 0
								OR (tmp.SportType IN (43,44) AND tmp.MinBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (tmp.SportType IN (43,44) AND tmp.MaxBet			< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (tmp.SportType IN (43,44) AND tmp.MaxPerMatch		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha	
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 102
		
			RETURN
	END

	--Check rule : Wrong Max Payout Per Match
	IF EXISTS(SELECT TOP 1 1 
				FROM @ErrorSportTypeTbl tmp
					LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
				WHERE	(tmp.SportType NOT IN (43,44) AND tmp.MaxPayoutPerMatch < 0)
			)
	BEGIN
			SET @xml = (
					SELECT 10059 AS '@MsgID'
						, 'Wrong Max payout per match.' AS '@Msg'
						, (
							SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType   AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
								LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
							WHERE	(tmp.SportType NOT IN (43,44) AND tmp.MaxPayoutPerMatch < 0)
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 103
		
			RETURN
	END
	

	--Check MinBet<=MaxBet<=MaxPerMatch	
	IF EXISTS(SELECT TOP 1 1
			FROM @ErrorSportTypeTbl tmp
			WHERE (
					(
							tmp.MinBet	<> 0
						OR tmp.MaxBet	<> 0
						)
					AND tmp.MinBet > tmp.MaxBet
					)
				OR (
					(
							tmp.MaxBet		<> 0
						OR tmp.MaxPerMatch	<> 0
						)
					AND tmp.MaxBet > tmp.MaxPerMatch
					)
				OR (
					(
							tmp.MinBet		<> 0
						OR tmp.MaxPerMatch	<> 0
						)
					AND tmp.MinBet > tmp.MaxPerMatch
					)  )
	BEGIN
		SET @xml = (
				SELECT 10005 AS '@MsgID'
					, 'Min bet must be less than max bet and max bet must be less than max bet per match.' AS '@Msg'
					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
						FROM @ErrorSportTypeTbl tmp
						WHERE (
								(
										tmp.MinBet	<> 0
									OR tmp.MaxBet	<> 0
									)
								AND tmp.MinBet > tmp.MaxBet
								)
							OR (
								(
										tmp.MaxBet		<> 0
									OR tmp.MaxPerMatch	<> 0
									)
								AND tmp.MaxBet > tmp.MaxPerMatch
								)
							OR (
								(
										tmp.MinBet		<> 0
									OR tmp.MaxPerMatch	<> 0
									)
								AND tmp.MinBet > tmp.MaxPerMatch
								)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 71
		SET @ErrCode = 104
		
		RETURN
	END

	--Check MaxPerMatch <= MaxPayoutPerMatch
	IF EXISTS(SELECT TOP 1 1
			FROM @ErrorSportTypeTbl tmp
			WHERE (	tmp.SportType		NOT IN (43,44)
					AND (tmp.MaxPerMatch	<> 0 OR tmp.MaxPayoutPerMatch	<> 0)
					AND tmp.MaxPerMatch	> tmp.MaxPayoutPerMatch
				) 
		   )
	BEGIN
		SET @xml = (
				SELECT 10060 AS '@MsgID'
					, 'Max Per Match must be less than or equal to Max Payout Per Match.' AS '@Msg'

					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
						FROM @ErrorSportTypeTbl tmp
						WHERE (	tmp.SportType		NOT IN (43,44)
								AND (tmp.MaxPerMatch	<> 0 OR tmp.MaxPayoutPerMatch	<> 0)
								AND tmp.MaxPerMatch	> tmp.MaxPayoutPerMatch
							)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 71
		SET @ErrCode = 105
		
		RETURN
	END


	IF @RoleID IN (1, 2, 3)
	BEGIN
		--Check if MAX(upper.minbet) > 0 and minbet>0 then minbet>=MAX(upper.minbet)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.MinMinBet > 0
					AND tmp.MinBet	> 0
					AND tmp.MinBet	< tmp.MinMinBet)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10016
								WHEN @RoleID = 2
									THEN 10019
								WHEN @RoleID = 1
									THEN 10006
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Min bet must be equal to or greater than Super Agent min bet'
								WHEN @RoleID = 2
									THEN 'Min bet must be equal to or greater than Master Agent min bet'
								WHEN @RoleID = 1
									THEN 'Min bet must be equal to or greater than Agent min bet'
								END 
							AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE tmp.MinMinBet > 0
								AND tmp.MinBet	> 0
								AND tmp.MinBet	< tmp.MinMinBet
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 106
			
			RETURN
		END

		--Check if MIN(upper.maxbet) > 0 and maxbet>0 then maxbet<=MIN(upper.maxbet)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.MaxMaxBet > 0
					AND tmp.MaxBet	> 0
					AND tmp.MaxBet	> tmp.MaxMaxBet)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10017
								WHEN @RoleID = 2
									THEN 10020
								WHEN @RoleID = 1
									THEN 10007
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Max bet must be equal to or less than Super Agent max bet'
								WHEN @RoleID = 2
									THEN 'Max bet must be equal to or less than Master Agent max bet'
								WHEN @RoleID = 1
									THEN 'Max bet must be equal to or less than Agent max bet'
								END 
							AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE tmp.MaxMaxBet > 0
									AND tmp.MaxBet	> 0
									AND tmp.MaxBet	> tmp.MaxMaxBet
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 107

			
			RETURN
		END

		--Check if MIN(upper.maxpermatch)> 0 and maxpermatch>0 then maxpermatch<=MIN(upper.maxpermatch)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.MaxMaxPerMatch	> 0
					AND tmp.MaxPerMatch		> 0
					AND tmp.MaxPerMatch		> tmp.MaxMaxPerMatch)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10018
								WHEN @RoleID = 2
									THEN 10021
								WHEN @RoleID = 1
									THEN 10008
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Max Per Match must be equal to or less than Super Agent Max Per Match'
								WHEN @RoleID = 2
									THEN 'Max Per Match must be equal to or less than Master Agent Max Per Match'
								WHEN @RoleID = 1
									THEN 'Max Per Match must be equal to or less than Agent Max Per Match'
								END
							AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE tmp.MaxMaxPerMatch	> 0
								AND tmp.MaxPerMatch	> 0
								AND tmp.MaxPerMatch	> tmp.MaxMaxPerMatch
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 108
			
			RETURN
		END


		--Check if MIN(upper.MaxPayoutPerMatch)> 0 and MaxPayoutPerMatch>0 then MaxPayoutPerMatch<=MIN(upper.MaxPayoutPerMatch)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.SportType NOT IN (43,44)
					AND tmp.MaxMaxPayoutPerMatch	> 0
					AND tmp.MaxPayoutPerMatch	> 0
					AND tmp.MaxPayoutPerMatch	> tmp.MaxMaxPayoutPerMatch)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10075
								WHEN @RoleID = 2
									THEN 10076
								WHEN @RoleID = 1
									THEN 10077
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Max Payout Per Match must be equal to or less than Super Agent Max Payout Per Match'
								WHEN @RoleID = 2
									THEN 'Max Payout Per Match must be equal to or less than Master Agent Max Payout Per Match'
								WHEN @RoleID = 1
									THEN 'Max Payout Per Match must be equal to or less than Agent Max Payout Per Match'
								END
							AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE tmp.SportType NOT IN (43,44)
								AND tmp.MaxMaxPerMatch	> 0
								AND tmp.MaxPerMatch	> 0
								AND tmp.MaxPerMatch	> tmp.MaxMaxPerMatch
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 109
			
			RETURN
		END
	END

END