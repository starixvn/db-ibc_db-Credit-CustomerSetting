/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_BetSetting_154_Check] 
	  @CustID			INT
	, @BetLimit			VARCHAR(MAX)
	, @SystemID			TINYINT 
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
	, @SettingStatus	TINYINT = 0
	, @GroupType		SMALLINT = 154
	, @GroupID			TINYINT = 2
AS
/*
	Created: 20240520@Eden
	Task : Check Customer's Bet Limits
	DB: DBCUST/CustDB
	Original:
	Revisions:
		- 20240520@Eden: Unify RNG Games [redmine: #204358]

	Param's Explanation:
	- @BetLimit:
		[
			{"SportType": "169","BetType": "3611","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9919","BetType": "1501","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "9908","BetType": "1201","MinBet": "1","MaxBet": "10","MPM": "100"},
			{"SportType": "161","BetType": "81","MinBet": "1","MaxBet": "10","MPM": "100","MaxPerNumber": "80"}
		]

*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xml		XML
		, @RoleID		INT
		, @AgentID		INT
		, @MasterID		INT
		, @SuperID		INT

	DECLARE @ErrorSportTypeTbl TABLE (
			  SportType			SMALLINT
			, BetType			SMALLINT
			, MinBet			MONEY
			, MaxBet			MONEY
			, MaxPerMatch		MONEY
			, MaxPerNumber		MONEY 
			, MinMinBet			MONEY
			, MaxMaxBet			MONEY
			, MaxMaxPerMatch	MONEY
			, MaxMaxPerNumber   MONEY 
			, Subtype			TINYINT
		)
	
	DECLARE @UplineLimitTbl TABLE (
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
			, MaxPerNumber  MONEY 
			
		)
	DECLARE @NewBetLimitTbl TABLE (
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MinBet		MONEY
			, MaxBet		MONEY
			, MaxPerMatch	MONEY
			, MaxPerNumber  MONEY 
			, Subtype		TINYINT
		)
	
	CREATE TABLE #ProductSettingDetail(
		SettingType SMALLINT,
		SportType SMALLINT,
		BetType SMALLINT,
		SubType TINYINT,
		IsLive BIT, 
		ProductID TINYINT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	IF @BetLimit IS NULL OR @BetLimit = ''
		RETURN
	
	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg		= ''
	
	INSERT @NewBetLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
	SELECT SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber
	FROM OPENJSON(@BetLimit) WITH (
			SportType smallint  '$.SportType',
			BetType smallint  '$.BetType',
			MinBet MONEY  '$.MinBet',
			MaxBet MONEY  '$.MaxBet',
			MaxPerMatch MONEY  '$.MPM',
			MaxPerNumber MONEY  '$.MaxPerNumber'
		)

	DECLARE  @SiteID SMALLINT,
			 @Currency SMALLINT,
			 @Site VARCHAR (10)
	
	SELECT  @siteID = s.siteID,
			@Currency = c.currency,
			@Site = C.site,
			@RoleID = roleid, 
			@SuperID = srecommend, 
			@MasterID = mrecommend, 
			@AgentID = recommend
	FROM Customer c with (NOLOCK)
		INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE custid = @custid

	INSERT INTO #ProductSettingDetail(SportType,BetType,SubType,SettingType,IsLive,ProductID)
	SELECT SportType,BetType,SubType,SettingType,IsLive,ProductID
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
		AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewBetLimitTbl t
		INNER JOIN #ProductSettingDetail ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	UPDATE t
	SET t.Subtype = p.SubType
	FROM @NewBetLimitTbl t
		INNER JOIN #ProductSettingDetail p 
			ON t.SportType = p.SportType
			AND t.BetType = p.BetType		
	
	IF @RoleID = 3
	BEGIN
		INSERT INTO @UplineLimitTbl (SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL((CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL((CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL((CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
				MaxPerNumber = ISNULL((CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0)
		FROM BetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid = @SuperID
	END
	ELSE IF @RoleID = 2
	BEGIN
		INSERT INTO @UplineLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
				MaxPerNumber = ISNULL(MIN(CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0)
		FROM BetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid IN (@SuperID,@MasterID)
		GROUP BY cb.Sporttype,cb.Bettype
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @UplineLimitTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber)
		SELECT  cb.Sporttype,cb.Bettype,
				MinBet = ISNULL(MAX(CASE WHEN cb.MinBet = 0 THEN NULL ELSE cb.MinBet END),0), 
				MaxBet = ISNULL(MIN(CASE WHEN cb.MaxBet = 0 THEN NULL ELSE cb.MaxBet END),0),
				MaxPerMatch = ISNULL(MIN(CASE WHEN cb.MaxPerMatch = 0 THEN NULL ELSE cb.MaxPerMatch END),0),
				MaxPerNumber = ISNULL(MIN(CASE WHEN cb.MaxPerNumber = 0 THEN NULL ELSE cb.MaxPerNumber END),0)
		FROM BetSetting3rd_Agent cb WITH (NOLOCK,FORCESEEK)
			INNER JOIN @NewBetLimitTbl b ON cb.SportType = b.SportType AND cb.BetType = b.BetType
		WHERE cb.custid IN (@SuperID,@MasterID,@AgentID)
		GROUP BY cb.Sporttype,cb.Bettype
	END

	--Get 1 error row
	INSERT INTO @ErrorSportTypeTbl(SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MinMinBet,MaxMaxBet,MaxMaxPerMatch,MaxMaxPerNumber,Subtype)
	SELECT tmp.SportType
			, tmp.BetType
			, tmp.MinBet
			, tmp.MaxBet
			, tmp.MaxPerMatch
			, tmp.MaxPerNumber
			, ISNULL(ubl.MinBet, 0)
			, ISNULL(ubl.MaxBet, 0)
			, ISNULL(ubl.MaxPerMatch, 0)
			, ISNULL(ubl.MaxPerNumber, 0)
			, Subtype
	FROM @NewBetLimitTbl tmp
		LEFT JOIN @UplineLimitTbl ubl
			ON tmp.SportType	= ubl.SportType
				AND tmp.BetType = ubl.BetType
		LEFT JOIN dbo.ProductBetSetting pb
			ON pb.Sporttype = tmp.SportType
				AND pb.Bettype = tmp.BetType
				AND pb.Currency = @Currency
	WHERE	tmp.MinBet		< 0
			OR tmp.MaxBet		< 0
			OR tmp.MaxPerMatch	< 0
			OR tmp.MaxPerNumber < 0
			OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.MaxPerMatch	< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (tmp.MaxPerNumber < 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			OR (
					(
						tmp.MinBet	<> 0
						OR tmp.MaxBet	<> 0
						OR tmp.MaxPerMatch	<> 0
					)
					AND tmp.Subtype = 1
					AND
					(
						tmp.MinBet		< ISNULL(pb.MinBet,0)
						OR tmp.MaxBet		< ISNULL(pb.MinBet,0)
						OR tmp.MaxPerMatch	< ISNULL(pb.MinBet,0)
					)
				)
			OR (
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
				tmp.MaxPerNumber <> 0
				AND (
						tmp.MaxBet > tmp.MaxPerNumber 
						OR tmp.MaxPerNumber > tmp.MaxPerMatch 
					)
				)
			OR (
				ubl.MinBet		> 0
				AND tmp.MinBet	> 0
				AND tmp.MinBet	< ubl.MinBet
				)
			OR (
				ubl.MaxBet		> 0
				AND tmp.MaxBet	> 0
				AND tmp.MaxBet	> ubl.MaxBet
				)
			OR (
				ubl.MaxPerMatch		> 0
				AND tmp.MaxPerMatch > 0
				AND tmp.MaxPerMatch > ubl.MaxPerMatch
				)
			OR (
				ubl.MaxPerNumber	> 0
				AND tmp.MaxPerNumber > 0
				AND tmp.MaxPerNumber > ubl.MaxPerNumber
				)
	
	--IF there's no error data then return
	IF NOT EXISTS (SELECT TOP 1 1 FROM @ErrorSportTypeTbl)
		RETURN
	
	--Check all setting >=0
	IF EXISTS(	SELECT TOP 1 1 
				FROM @ErrorSportTypeTbl tmp
					LEFT JOIN dbo.ProductBetSetting pb
					ON pb.Sporttype = tmp.SportType
						AND pb.Bettype = tmp.BetType
						AND pb.Currency = @Currency
				WHERE	tmp.MinBet		< 0
						OR tmp.MaxBet		< 0
						OR tmp.MaxPerMatch	< 0
						OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
						OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
						OR (tmp.MaxPerMatch	< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
						OR (
							(
								tmp.MinBet	<> 0
								OR tmp.MaxBet	<> 0
								OR tmp.MaxPerMatch	<> 0
							)
							AND tmp.Subtype = 1
							AND
							(
								tmp.MinBet		< ISNULL(pb.MinBet,0)
								OR tmp.MaxBet		< ISNULL(pb.MinBet,0)
								OR tmp.MaxPerMatch	< ISNULL(pb.MinBet,0)
							)
						)
			)
	BEGIN
		SET @xml = (
				SELECT 10003 AS '@MsgID'
						, 'Wrong Min bet/ Max bet/ Max per match' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
								LEFT JOIN dbo.ProductBetSetting pb
									ON pb.Sporttype = tmp.SportType
										AND pb.Bettype = tmp.BetType
										AND pb.Currency = @Currency
							WHERE	tmp.MinBet		< 0
								OR tmp.MaxBet		< 0
								OR tmp.MaxPerMatch	< 0
								OR (tmp.MinBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (tmp.MaxBet		< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
								OR (tmp.MaxPerMatch	< 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha
								OR (
									(
										tmp.MinBet	<> 0
										OR tmp.MaxBet	<> 0
										OR tmp.MaxPerMatch	<> 0
									)
									AND tmp.Subtype = 1
									AND
									(
										tmp.MinBet		< ISNULL(pb.MinBet,0)
										OR tmp.MaxBet		< ISNULL(pb.MinBet,0)
										OR tmp.MaxPerMatch	< ISNULL(pb.MinBet,0)
									)
								)
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 72
		SET @ErrCode = 101
		
		RETURN
	END

	--Check all setting >=0
	IF EXISTS(	SELECT TOP 1 1 
				FROM @ErrorSportTypeTbl tmp
				WHERE	tmp.MaxPerNumber < 0
						OR (tmp.MaxPerNumber < 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
			)
	BEGIN
		SET @xml = (
				SELECT 10002 AS '@MsgID'
						, 'Wrong Max Per Ball' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE	tmp.MaxPerNumber < 0
								OR (tmp.MaxPerNumber < 1 AND @SystemID BETWEEN 6 AND 9) --789y ExtNAP and Alpha 
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 72
		SET @ErrCode = 201
		
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
				)
	BEGIN
			SET @xml = (
					SELECT 10067 AS '@MsgID'
						, 'Min bet must be less than or equal to max bet and max bet must be less than or equal to max per match' AS '@Msg'
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
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 72
			SET @ErrCode = 102
		
		RETURN
	END

	--Check MaxBet<=MaxPerBall<=MaxPerMatch	
	IF EXISTS(SELECT TOP 1 1
			FROM @ErrorSportTypeTbl tmp
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
							FROM @ErrorSportTypeTbl tmp
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
			SET @MsgType = 72
			SET @ErrCode = 202
		
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
			SET @MsgType = 72
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
			SET @MsgType = 72
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
								AND tmp.MaxPerMatch		> 0
								AND tmp.MaxPerMatch		> tmp.MaxMaxPerMatch
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 72
			SET @ErrCode = 105
			
			RETURN
		END

		--Check if MIN(upper.MaxPerBall)> 0 and MaxPerBall>0 then MaxPerBall<=MIN(upper.MaxPerBall)
		IF EXISTS(SELECT TOP 1 1
				FROM @ErrorSportTypeTbl tmp
				WHERE tmp.MaxMaxPerNumber	> 0
					AND tmp.MaxPerNumber	> 0
					AND tmp.MaxPerNumber	> tmp.MaxMaxPerNumber)
		BEGIN
			SET @xml = (
					SELECT CASE 
								WHEN @RoleID = 3
									THEN 10010
								WHEN @RoleID = 2
									THEN 10011
								WHEN @RoleID = 1
									THEN 10009
								END 
							AS '@MsgID'
						, CASE 
								WHEN @RoleID = 3
									THEN 'Max Per Ball must be equal to or less than Super Agent Max Per Ball'
								WHEN @RoleID = 2
									THEN 'Max Per Ball must be equal to or less than Master Agent Max Per Ball'
								WHEN @RoleID = 1
									THEN 'Max Per Ball must be equal to or less than Agent Max Per Ball'
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
			SET @MsgType = 72
			SET @ErrCode = 106
			
			RETURN
		END
	END
	DROP TABLE #ProductSettingDetail
END
GO
