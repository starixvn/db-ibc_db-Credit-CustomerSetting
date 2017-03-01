ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetLimitCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @GameBetLimit	VARCHAR(MAX)
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20160801@Elodie
	Task : Check Customer's Bet Game Limits
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	• @GameBetLimit:
		<ROOT>
				<GameBetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
						MaxPerNumber="1000000"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrorSportTypeTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerNumber		MONEY
			, MinMinBet			MONEY
			, MaxMaxBet			MONEY
			, MaxMaxPerNumber	MONEY
		)
	DECLARE @xml		XML
	DECLARE @Currency INT
	DECLARE @UplineLimitTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerNumber	MONEY
		)
	DECLARE @NewBetLimitTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerNumber	MONEY
		)
	DECLARE @BetGameUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)

	IF @GameBetLimit IS NULL
		OR @GameBetLimit = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	--Parse XML data
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @GameBetLimit

	INSERT @NewBetLimitTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/GameBetLimit', 1) WITH (
				SportType		SMALLINT
				, BetType		SMALLINT
				, MinBet		MONEY
				, MaxBet		MONEY
				, MaxPerNumber	MONEY
			)

	EXEC sp_xml_removedocument @iDoc

	--Get currency of member
	SELECT @Currency = ci.currency
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID
	
	IF @RoleID BETWEEN 1 AND 3
	BEGIN
		INSERT INTO @BetGameUnlimit
		SELECT cs.SportType,cs.BetType,
				CASE WHEN cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0 THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN @NewBetLimitTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
		WHERE cs.custid = @SuperID 
	END
	ELSE
	BEGIN
		INSERT INTO @BetGameUnlimit
		SELECT SportType, BetType, 0 AS IsAllowUnlimit
		FROM @NewBetLimitTbl s
	END

	IF @RoleID = 3
	BEGIN
		--Get super 's bet limit
		INSERT INTO @UplineLimitTbl
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
					END) AS MaxPerNumber
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID			= @SuperID
		GROUP BY bl.SportType
			, bl.BetType
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Get super/master 's bet limit
		INSERT INTO @UplineLimitTbl
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
					END) AS MaxPerNumber
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetLimitTbl tmp
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
		INSERT INTO @UplineLimitTbl
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
					END) AS MaxPerNumber
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetLimitTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID		= @SuperID
			OR bl.CustID	= @MasterID
			OR bl.CustID	= @AgentID
		GROUP BY bl.SportType
			, bl.BetType
	END
	
	--Get 1 error row
	INSERT INTO @ErrorSportTypeTbl
	SELECT tmp.SportType
		, tmp.BetType
		, tmp.MinBet
		, tmp.MaxBet
		, tmp.MaxPerNumber
		, ISNULL(ubl.MinBet, 0)
		, ISNULL(ubl.MaxBet, 0)
		, ISNULL(ubl.MaxPerNumber, 0)
	FROM @NewBetLimitTbl tmp
		INNER JOIN @BetGameUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
		LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
		LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
	WHERE	tmp.MinBet		< 0
		OR tmp.MaxBet		< 0
		OR tmp.MaxPerNumber	< 0
		OR (
				s.IsAllowUnlimit = 0
				AND
				((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
					OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
					OR (tmp.MaxPerNumber <> 0 AND tmp.MaxPerNumber > ISNULL(pb.MaxPerMatch,0)))
			)
		OR ((tmp.MinBet	<> 0 OR tmp.MaxBet <> 0) AND tmp.MinBet > tmp.MaxBet)
		OR ((tmp.MaxBet	<> 0 OR tmp.MaxPerNumber <> 0) AND tmp.MaxBet > tmp.MaxPerNumber)
		OR ((tmp.MinBet	<> 0 OR tmp.MaxPerNumber <> 0) AND tmp.MinBet > tmp.MaxPerNumber)
		OR (ubl.MinBet	> 0 AND tmp.MinBet > 0 AND tmp.MinBet < ubl.MinBet)
		OR (ubl.MaxBet	> 0 AND tmp.MaxBet > 0 AND tmp.MaxBet > ubl.MaxBet)
		OR (ubl.MaxPerNumber > 0 AND tmp.MaxPerNumber > 0 AND tmp.MaxPerNumber > ubl.MaxPerNumber)

	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
			)
		RETURN

	--Check all setting >=0
	IF EXISTS(SELECT TOP 1 1 
			FROM @ErrorSportTypeTbl tmp
				INNER JOIN @BetGameUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
				LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
				LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
			WHERE	tmp.MinBet		< 0
				OR tmp.MaxBet		< 0
				OR tmp.MaxPerNumber	< 0
				OR (
					s.IsAllowUnlimit = 0 
					AND
					((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
						OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
						OR (tmp.MaxPerNumber <> 0 AND tmp.MaxPerNumber > ISNULL(pb.MaxPerMatch,0)))
					))
	BEGIN
		SET @xml = (
				SELECT 10035 AS '@MsgID'
					, 'Wrong Min bet/ Max bet/ Max per number.' AS '@Msg'
					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
						FROM @ErrorSportTypeTbl tmp
							INNER JOIN @BetGameUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
							LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
							LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
						WHERE	tmp.MinBet		< 0
							OR tmp.MaxBet		< 0
							OR tmp.MaxPerNumber	< 0
							OR (
									s.IsAllowUnlimit = 0
									AND
									((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
										OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
										OR (tmp.MaxPerNumber <> 0 AND tmp.MaxPerNumber > ISNULL(pb.MaxPerMatch,0)))
								)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 71
		SET @ErrCode = 101
		
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
						OR tmp.MaxPerNumber	<> 0
						)
					AND tmp.MaxBet > tmp.MaxPerNumber
					)
				OR (
					(
							tmp.MinBet		<> 0
						OR tmp.MaxPerNumber	<> 0
						)
					AND tmp.MinBet > tmp.MaxPerNumber
					))
	BEGIN
		SET @xml = (
				SELECT 10036 AS '@MsgID'
					, 'Min bet must be less than max bet and max bet must be less than max bet per number.' AS '@Msg'
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
									OR tmp.MaxPerNumber	<> 0
									)
								AND tmp.MaxBet > tmp.MaxPerNumber
								)
							OR (
								(
										tmp.MinBet		<> 0
									OR tmp.MaxPerNumber	<> 0
									)
								AND tmp.MinBet > tmp.MaxPerNumber
								)
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
			SET @ErrCode = 103
			
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
			SET @ErrCode = 104
			
			RETURN
		END

		--Check if MIN(upper.maxpermatch)> 0 and maxpermatch>0 then maxpermatch<=MIN(upper.maxpermatch)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.MaxMaxPerNumber	> 0
					AND tmp.MaxPerNumber		> 0
					AND tmp.MaxPerNumber		> tmp.MaxMaxPerNumber)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10037
								WHEN @RoleID = 2
									THEN 10038
								WHEN @RoleID = 1
									THEN 10039
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Max Per Number must be equal to or less than Super Agent Max Per Number'
								WHEN @RoleID = 2
									THEN 'Max Per Number must be equal to or less than Master Agent Max Per Number'
								WHEN @RoleID = 1
									THEN 'Max Per Number must be equal to or less than Agent Max Per Number'
								END
							AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE tmp.MaxMaxPerNumber	> 0
								AND tmp.MaxPerNumber	> 0
								AND tmp.MaxPerNumber	> tmp.MaxMaxPerNumber
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
	END
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitCheck] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitCheck] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_GameBetLimitCheck] TO [bodbExtAccNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_GameBetLimitCheck] TO [vnteam] AS [dbo]