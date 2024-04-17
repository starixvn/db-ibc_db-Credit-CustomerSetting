/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_GameBetSettingCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @BetLimit	VARCHAR(MAX)
	, @SystemID TINYINT 
	, @ProductID TINYINT
	, @ErrCode		INT				= 0		OUTPUT
	, @MsgType		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20201118@Eden
	Task : Check Customer's Bet Setting
	DB: DBCUST/CustDB
	Original:

	Revisions: 
		- 20201118@Eden: Insert New SettingType = 20 [Redmine: #131370]

	Param's Explanation:
	- @BetLimit:
		<ROOT>
				<BetLimit 
						SportType="1" 
						BetType="1" 
						MinBet="1" 
						MaxBet="30000" 
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
			, MinMinBet			MONEY
			, MaxMaxBet			MONEY
		)
	DECLARE @xml		XML
	DECLARE @Currency INT
	DECLARE @UplineLimitTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
		)
	DECLARE @NewBetSettingTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
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
			)

	EXEC sp_xml_removedocument @iDoc	

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetSettingTbl t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 20
		AND u.FunctionType = 1 --Edit Customer

	--Get currency of member
	SELECT @Currency = ci.currency
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID
	
	INSERT INTO @BetSettingUnlimit
	SELECT s.SportType, s.BetType, 
			CASE WHEN ps.MinBet = 0 AND ps.MaxBet = 0 THEN 1 ELSE 0 END AS IsAllowUnlimit
	FROM @NewBetSettingTbl s
		INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON ps.Sporttype = s.SportType AND ps.Bettype = s.BetType
	WHERE ps.Currency = @Currency

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
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID	IN( @SuperID, @MasterID)
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
		FROM dbo.CustBetSetting3rd_Agent bl WITH (NOLOCK)
		INNER JOIN @NewBetSettingTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID	IN( @SuperID, @MasterID, @AgentID)
		GROUP BY bl.SportType
			, bl.BetType
	END
	--Get 1 error row
	INSERT INTO @ErrorSportTypeTbl
	SELECT tmp.SportType
			, tmp.BetType
			, tmp.MinBet
			, tmp.MaxBet
			, ISNULL(ubl.MinBet, 0)
			, ISNULL(ubl.MaxBet, 0)
	FROM @NewBetSettingTbl tmp
			INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
			LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
			LEFT JOIN dbo.ProductBetSetting pb WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
	WHERE	tmp.MinBet		< 0
			OR tmp.MaxBet		< 0
			OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (
					s.IsAllowUnlimit = 0
					AND
					((NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MinBet < ISNULL(pb.MinBet,0))
						OR (NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
				))
			OR ((tmp.MinBet	<> 0 OR tmp.MaxBet <> 0) AND tmp.MinBet > tmp.MaxBet)
			OR (ubl.MinBet	> 0 AND tmp.MinBet > 0 AND tmp.MinBet < ubl.MinBet)
			OR (ubl.MaxBet	> 0 AND tmp.MaxBet > 0 AND tmp.MaxBet > ubl.MaxBet)

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
					LEFT JOIN dbo.ProductBetSetting pb WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	tmp.MinBet		< 0
					OR tmp.MaxBet		< 0
					OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
					OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
					OR (
						s.IsAllowUnlimit = 0 
						AND
						((NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MinBet < ISNULL(pb.MinBet,0))
							OR (NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
						)))
	BEGIN
			SET @xml = (
					SELECT 10003 AS '@MsgID'
						, 'Wrong Min bet/ Max bet.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
								INNER JOIN @BetSettingUnlimit s ON s.SportType = tmp.SportType AND s.Bettype = tmp.BetType
								LEFT JOIN @UplineLimitTbl ubl ON tmp.SportType	= ubl.SportType AND tmp.BetType = ubl.BetType
								LEFT JOIN dbo.ProductBetSetting pb WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
							WHERE	tmp.MinBet		< 0
								OR tmp.MaxBet		< 0
								OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (
										s.IsAllowUnlimit = 0
										AND
										((NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MinBet < ISNULL(pb.MinBet,0))
											OR (NOT(tmp.MinBet = 0 AND tmp.MaxBet >= 0 AND tmp.MaxBet < 1) AND tmp.MaxBet	> ISNULL(pb.MaxBet,0))
										)
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
	

	--Check MinBet<=MaxBet
	IF EXISTS(SELECT TOP 1 1
			FROM @ErrorSportTypeTbl tmp
			WHERE ( tmp.MinBet	<> 0 OR tmp.MaxBet	<> 0 )
					AND tmp.MinBet > tmp.MaxBet
					)
	BEGIN
		SET @xml = (
				SELECT 10005 AS '@MsgID'
					, 'Min bet must be less than max bet.' AS '@Msg'
					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
						FROM @ErrorSportTypeTbl tmp
						WHERE ((tmp.MinBet <> 0 OR tmp.MaxBet <> 0)
								AND tmp.MinBet > tmp.MaxBet
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
	END
END
GO