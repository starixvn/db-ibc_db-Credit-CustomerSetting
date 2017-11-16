/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSettingCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @BetLimit	VARCHAR(MAX)
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20171010@Elodie
	Task : Check Customer's Bet Setting
	DB: DBCUST/CustDB
	Original:

	Revisions: 
		- 20171017@Elodie: Implementing BetSetting Plugin - [Redmine #83729]	
	Param's Explanation:
	• @BetLimit:
		<ROOT>
				<BetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
						MaxPerMatch="1000000"
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
			, MaxPerMatch		MONEY
			, MinMinBet			MONEY
			, MaxMaxBet			MONEY
			, MaxMaxPerMatch	MONEY
		)
	DECLARE @xml		XML
	DECLARE @Currency INT
	DECLARE @UplineLimitTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
		)
	DECLARE @NewBetSettingTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
		)
	DECLARE @BetSettingUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, IsAllowUnlimit BIT)

	IF @BetLimit IS NULL
		OR @BetLimit = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''

	--Parse XML data
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @BetLimit

	INSERT @NewBetSettingTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/BetLimit', 1) WITH (
				SportType		SMALLINT
				, BetType		SMALLINT
				, MinBet		MONEY
				, MaxBet		MONEY
				, MaxPerMatch	MONEY
			)

	EXEC sp_xml_removedocument @iDoc

	--Get currency of member
	SELECT @Currency = ci.currency
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID
	
	IF @RoleID BETWEEN 1 AND 3
	BEGIN
		INSERT INTO @BetSettingUnlimit
		SELECT cs.SportType,cs.BetType,
				CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
							OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
			INNER JOIN @NewBetSettingTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE cs.custid = @SuperID AND ps.Currency = @Currency
	END
	ELSE
	BEGIN
		INSERT INTO @BetSettingUnlimit
		SELECT s.SportType, s.BetType, 
				CASE WHEN ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0 THEN 1 ELSE 0 END AS IsAllowUnlimit
		FROM @NewBetSettingTbl s
			INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
		WHERE ps.Currency = @Currency
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
					END) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
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
					END) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
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
					END) AS MaxPerMatch
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
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
		, tmp.MaxPerMatch
		, ISNULL(ubl.MinBet, 0)
		, ISNULL(ubl.MaxBet, 0)
		, ISNULL(ubl.MaxPerMatch, 0)
	FROM @NewBetSettingTbl tmp
		INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
		LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
		LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
	WHERE	tmp.MinBet		< 0
		OR tmp.MaxBet		< 0
		OR tmp.MaxPerMatch	< 0
		OR (
				s.IsAllowUnlimit = 0
				AND
				((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
					OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
					OR (tmp.MaxPerMatch <> 0 AND tmp.MaxPerMatch > ISNULL(pb.MaxPerMatch,0)))
			)
		OR ((tmp.MinBet	<> 0 OR tmp.MaxBet <> 0) AND tmp.MinBet > tmp.MaxBet)
		OR ((tmp.MaxBet	<> 0 OR tmp.MaxPerMatch <> 0) AND tmp.MaxBet > tmp.MaxPerMatch)
		OR ((tmp.MinBet	<> 0 OR tmp.MaxPerMatch <> 0) AND tmp.MinBet > tmp.MaxPerMatch)
		OR (ubl.MinBet	> 0 AND tmp.MinBet > 0 AND tmp.MinBet < ubl.MinBet)
		OR (ubl.MaxBet	> 0 AND tmp.MaxBet > 0 AND tmp.MaxBet > ubl.MaxBet)
		OR (ubl.MaxPerMatch > 0 AND tmp.MaxPerMatch > 0 AND tmp.MaxPerMatch > ubl.MaxPerMatch)

	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
			)
		RETURN

	--Check all setting >=0
	IF EXISTS(SELECT TOP 1 1 
			FROM @ErrorSportTypeTbl tmp
				INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
				LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
				LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
			WHERE	tmp.MinBet		< 0
				OR tmp.MaxBet		< 0
				OR tmp.MaxPerMatch	< 0
				OR (
					s.IsAllowUnlimit = 0 
					AND
					((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
						OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
						OR (tmp.MaxPerMatch <> 0 AND tmp.MaxPerMatch > ISNULL(pb.MaxPerMatch,0)))
					))
	BEGIN
		SET @xml = (
				SELECT 10003 AS '@MsgID'
					, 'Wrong Min bet/ Max bet/ Max per match.' AS '@Msg'
					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
						FROM @ErrorSportTypeTbl tmp
							INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
							LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
							LEFT JOIN dbo.ProductBetSetting pb ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
						WHERE	tmp.MinBet		< 0
							OR tmp.MaxBet		< 0
							OR tmp.MaxPerMatch	< 0
							OR (
									s.IsAllowUnlimit = 0
									AND
									((tmp.MinBet <> 0 AND tmp.MinBet < ISNULL(pb.MinBet,0))
										OR (tmp.MaxBet <> 0 AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
										OR (tmp.MaxPerMatch <> 0 AND tmp.MaxPerMatch > ISNULL(pb.MaxPerMatch,0)))
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
					))
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
			SET @ErrCode = 105
			
			RETURN
		END
	END
END
GO