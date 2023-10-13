/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="1"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutCheck] 
	  @CustID		INT
	, @RoleID		INT
	, @AgentID		INT
	, @MasterID		INT
	, @SuperID		INT
	, @MaxPayoutLimit	VARCHAR(MAX)
	, @Language VARCHAR(2)= 'E'
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
	, @MsgType		INT				= 0		OUTPUT
AS
/*
	Created: 20210518@Winfred
	Task : Check Customer's Parlay Max Payout
	DB: DBCUST/CustDB
	Original:

	Revision: 
		- 20210518@Winfred: Initial SP [RedmineID:#154104]	
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083]

	Param's Explanation:
		• @@MaxPayoutLimit:
		'<ROOT>				<MaxPayoutLimit 						SportType="1" 						BetType="1" 						SingleMatchParlay="3000" 						Combo2="40000" 						Combo35="6000000"						ComboOver6="1000000"				/>		</ROOT>'

	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrorSportTypeTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, SingleMatchParlay	MONEY
			, Combo2			MONEY
			, Combo35			MONEY
			, ComboOver6		MONEY
			, Upline_SingleMatchParlay	MONEY
			, Upline_Combo2			MONEY
			, Upline_Combo35			MONEY
			, Upline_ComboOver6		MONEY
		)
	DECLARE @xml		XML ,@Currency INT,@Bettype NVARCHAR(50),@Columns NVARCHAR(100)
	DECLARE @UplineMaxPayoutTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, SingleMatchParlay	MONEY
			, Combo2			MONEY
			, Combo35			MONEY
			, ComboOver6		MONEY
		)
	DECLARE @NewMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)
	DECLARE @MatchParlayUnlimit TABLE(SportType SMALLINT, BetType SMALLINT, SingleMatchParlay_IsAllowUnlimit BIT, Combo2_IsAllowUnlimit BIT, Combo35_IsAllowUnlimit BIT, ComboOver6_IsAllowUnlimit BIT)

	IF @MaxPayoutLimit IS NULL
		OR @MaxPayoutLimit = ''
		RETURN

	SELECT	@ErrCode	= 0 ,@ErrMsg		= '', @MsgType	= 0

	-- Parse Data Json
	INSERT INTO @NewMaxPayoutTbl  ( SportType , BetType , SingleMatchParlay , Combo2 , Combo35 , ComboOver6 )
	SELECT SportType, BetType, SingleMP, Combo2 , Combo35 , Combo6
	FROM OPENJSON(@MaxPayoutLimit)
	    WITH
		  (
			SportType		SMALLINT,
			BetType		SMALLINT,
			SingleMP		MONEY,
			Combo2		MONEY,
			Combo35		MONEY,
			Combo6		MONEY
        ) AS MaxPayoutLimit


	--Get currency of member
	SELECT @Currency = ci.currency
	FROM dbo.custInfo ci WITH(NOLOCK)
	WHERE ci.custid=@CustID

	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @NewMaxPayoutTbl t
		INNER JOIN ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 27
		AND u.FunctionType = 1 --Edit Customer
	
	IF @RoleID BETWEEN 1 AND 3
	BEGIN
		IF @RoleID = 1 
		BEGIN
			INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
			SELECT cs.SportType,cs.BetType,
					CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 AND aMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
					CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 AND aMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
					CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0 AND aMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
					CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0 AND aMp.ComboOver6 = 0 THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
			FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
				INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
				INNER JOIN dbo.CustMaxPayoutSetting_Agent aMp WITH (NOLOCK) ON s.SportType = aMp.sporttype AND s.BetType = aMp.bettype
			WHERE cs.custid = @SuperID  AND mMp.CustID = @MasterID AND aMp.CustID = @AgentID  
		END
		ELSE IF @RoleID = 2 
		BEGIN
			INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
			SELECT cs.SportType,cs.BetType,
					CASE WHEN cs.SingleMatchParlay = 0 AND mMp.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
					CASE WHEN cs.Combo2 = 0 AND mMp.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
					CASE WHEN cs.Combo35 = 0 AND mMp.Combo35 = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
					CASE WHEN cs.ComboOver6 = 0 AND mMp.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
			FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
				INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				INNER JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) ON s.SportType = mMp.sporttype AND s.BetType = mMp.bettype
			WHERE cs.custid = @SuperID  AND mMp.CustID = @MasterID  
		END
		ELSE IF @RoleID = 3 
		BEGIN
			INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
			SELECT cs.SportType,cs.BetType,
					CASE WHEN cs.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
					CASE WHEN cs.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
					CASE WHEN cs.Combo35 = 0 THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
					CASE WHEN cs.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
			FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
				INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			WHERE cs.custid = @SuperID 
		END
	END
	ELSE
	BEGIN
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,
				SingleMatchParlay_IsAllowUnlimit,
				Combo2_IsAllowUnlimit,
				Combo35_IsAllowUnlimit,
				ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType, cs.BetType, 
				1 AS SingleMatchParlay_IsAllowUnlimit,
				1 AS Combo2_IsAllowUnlimit,
				1 AS Combo35_IsAllowUnlimit,
				1 AS ComboOver6_IsAllowUnlimit
		FROM @NewMaxPayoutTbl cs
	END

	IF @RoleID = 3
	BEGIN
		--Get super 's Max Payout
		INSERT INTO @UplineMaxPayoutTbl(SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, MIN(CASE 
						WHEN bl.SingleMatchParlay = 0
							THEN NULL
						ELSE bl.SingleMatchParlay
					END) AS SingleMatchParlay
			, MIN(CASE 
						WHEN bl.Combo2 = 0
							THEN NULL
						ELSE bl.Combo2
					END) AS Combo2
			, MIN(CASE 
						WHEN bl.Combo35 = 0
							THEN NULL
						ELSE bl.Combo35
					END) AS Combo35
			, MIN(CASE 
						WHEN bl.ComboOver6 = 0
							THEN NULL
						ELSE bl.ComboOver6
					END) AS ComboOver6					
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @MatchParlayUnlimit tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID			= @SuperID
		GROUP BY bl.SportType
			, bl.BetType
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Get super/master 's Max Payout
		INSERT INTO @UplineMaxPayoutTbl(SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, MIN(CASE 
						WHEN bl.SingleMatchParlay = 0
							THEN NULL
						ELSE bl.SingleMatchParlay
					END) AS SingleMatchParlay
			, MIN(CASE 
						WHEN bl.Combo2 = 0
							THEN NULL
						ELSE bl.Combo2
					END) AS Combo2
			, MIN(CASE 
						WHEN bl.Combo35 = 0
							THEN NULL
						ELSE bl.Combo35
					END) AS Combo35
			, MIN(CASE 
						WHEN bl.ComboOver6 = 0
							THEN NULL
						ELSE bl.ComboOver6
					END) AS ComboOver6	
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID		= @SuperID
			OR bl.CustID	= @MasterID
		GROUP BY bl.SportType
			, bl.BetType
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Get super/master 's Max Payout
		INSERT INTO @UplineMaxPayoutTbl(SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, MIN(CASE 
						WHEN bl.SingleMatchParlay = 0
							THEN NULL
						ELSE bl.SingleMatchParlay
					END) AS SingleMatchParlay
			, MIN(CASE 
						WHEN bl.Combo2 = 0
							THEN NULL
						ELSE bl.Combo2
					END) AS Combo2
			, MIN(CASE 
						WHEN bl.Combo35 = 0
							THEN NULL
						ELSE bl.Combo35
					END) AS Combo35
			, MIN(CASE 
						WHEN bl.ComboOver6 = 0
							THEN NULL
						ELSE bl.ComboOver6
					END) AS ComboOver6	
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID		= @SuperID
			OR bl.CustID	= @MasterID
			OR bl.CustID	= @AgentID
		GROUP BY bl.SportType
			, bl.BetType
	END

--Get 1 error row
	INSERT INTO @ErrorSportTypeTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,Upline_SingleMatchParlay,Upline_Combo2,Upline_Combo35,Upline_ComboOver6)
	SELECT tmp.SportType
			, tmp.BetType
			, tmp.SingleMatchParlay
			, tmp.Combo2
			, tmp.Combo35
			, tmp.ComboOver6
			, ISNULL(ubl.SingleMatchParlay,0)
			, ISNULL(ubl.Combo2,0)
			, ISNULL(ubl.Combo35,0)
			, ISNULL(ubl.ComboOver6,0)
	FROM @NewMaxPayoutTbl tmp
			LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
			LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
	WHERE	tmp.SingleMatchParlay < 0 OR tmp.Combo2 < 0 OR tmp.Combo35	< 0  OR tmp.ComboOver6	< 0 	
			OR (ubl.SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > ubl.SingleMatchParlay  ))
			OR (ubl.Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > ubl.Combo2))
			OR (ubl.Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > ubl.Combo35))
			OR (ubl.ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > ubl.ComboOver6))
			OR ( @RoleID = 4 AND (tmp.SingleMatchParlay> pb.SingleMatchParlay OR tmp.Combo2> pb.Combo2 OR tmp.Combo35> pb.Combo35 OR tmp.ComboOver6> pb.ComboOver6))

	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM @ErrorSportTypeTbl
			)
		RETURN
	--Check all setting >=0
	IF EXISTS(SELECT TOP 1 1 
			FROM @ErrorSportTypeTbl tmp
			WHERE	tmp.SingleMatchParlay < 0 OR tmp.Combo2 < 0 OR tmp.Combo35	< 0  OR tmp.ComboOver6	< 0 )
	BEGIN
		SET @XML = (SELECT 10055 AS '@MsgID'
						, 'The value must be a positive amount.' AS '@Msg'
						, (
							SELECT tmp.SportType   AS '@SportType'
							,	 tmp.BetType   AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							WHERE	tmp.SingleMatchParlay < 0 OR tmp.Combo2 < 0 OR tmp.Combo35	< 0  OR tmp.ComboOver6	< 0
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)
		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 72
		SET @ErrCode = 10055
		
		RETURN
	END
		
	IF EXISTS(SELECT TOP 1 1 
			FROM @ErrorSportTypeTbl tmp
			LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
			WHERE	(tmp.Upline_SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > tmp.Upline_SingleMatchParlay))
			OR (tmp.Upline_Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > tmp.Upline_Combo2))
			OR (tmp.Upline_Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > tmp.Upline_Combo35))
			OR (tmp.Upline_ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > tmp.Upline_ComboOver6))
			OR ( @RoleID = 4 AND (tmp.SingleMatchParlay> pb.SingleMatchParlay OR tmp.Combo2> pb.Combo2 OR tmp.Combo35> pb.Combo35 OR tmp.ComboOver6> pb.ComboOver6)))
	BEGIN
		SELECT TOP 1 @Bettype =  CASE WHEN tmp.BetType = 9 AND tmp.SportType = 9 THEN 'Soccer Parlay'
									  WHEN tmp.BetType = 9 AND tmp.SportType = 99 THEN 'Mix Sports Parlay'
								 ELSE 'Soccer Parlay' END
					,@Columns = CASE WHEN (tmp.Upline_SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > tmp.Upline_SingleMatchParlay)) 
								OR tmp.SingleMatchParlay> pb.SingleMatchParlay 
								THEN 'SingleMatchParlay' 
						WHEN (tmp.Upline_Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > tmp.Upline_Combo2)) OR tmp.Combo2> pb.Combo2 THEN 'Combo2' 
						WHEN (tmp.Upline_Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > tmp.Upline_Combo35)) OR tmp.Combo35> pb.Combo35  THEN 'Combo35' 
						WHEN (tmp.Upline_ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > tmp.Upline_ComboOver6)) OR tmp.ComboOver6> pb.ComboOver6 THEN 'ComboOver6' 
							ELSE 'SingleMatchParlay' END	
		FROM @ErrorSportTypeTbl tmp
			LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
		WHERE	(tmp.Upline_SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > tmp.Upline_SingleMatchParlay))
					OR (tmp.Upline_Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > tmp.Upline_Combo2))
					OR (tmp.Upline_Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > tmp.Upline_Combo35))
					OR (tmp.Upline_ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > tmp.Upline_ComboOver6))
					OR ( @RoleID = 4 AND (tmp.SingleMatchParlay> pb.SingleMatchParlay OR tmp.Combo2> pb.Combo2 OR tmp.Combo35> pb.Combo35 OR tmp.ComboOver6> pb.ComboOver6))
		
		IF @RoleID  = 4 
		BEGIN
			SET @XML = (SELECT 10057 AS '@MsgID'
						, N''+ @Bettype + ': The setting of ' + @Columns + ' is higher than the company setting' AS '@Msg'
						, (
							SELECT tmp.SportType   AS '@SportType'
							,	 tmp.BetType   AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
							WHERE	(tmp.Upline_SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > tmp.Upline_SingleMatchParlay))
									OR (tmp.Upline_Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > tmp.Upline_Combo2))
									OR (tmp.Upline_Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > tmp.Upline_Combo35))
									OR (tmp.Upline_ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > tmp.Upline_ComboOver6))
									OR ( @RoleID = 4 AND (tmp.SingleMatchParlay> pb.SingleMatchParlay OR tmp.Combo2> pb.Combo2 OR tmp.Combo35> pb.Combo35 OR tmp.ComboOver6> pb.ComboOver6))
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)
		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 72
			SET @ErrCode = 10057

			RETURN
		END 
		ELSE 
		BEGIN
			SET @XML = (SELECT 10056 AS '@MsgID'
						, N''+ @Bettype + ': The setting of ' + @Columns + ' is higher than the upline''s.''' AS '@Msg'
						, (
							SELECT tmp.SportType   AS '@SportType'
							,	 tmp.BetType   AS '@BetType'
							FROM @ErrorSportTypeTbl tmp
							LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
							WHERE	(tmp.Upline_SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > tmp.Upline_SingleMatchParlay))
									OR (tmp.Upline_Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > tmp.Upline_Combo2))
									OR (tmp.Upline_Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > tmp.Upline_Combo35))
									OR (tmp.Upline_ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > tmp.Upline_ComboOver6))
									OR ( @RoleID = 4 AND (tmp.SingleMatchParlay> pb.SingleMatchParlay OR tmp.Combo2> pb.Combo2 OR tmp.Combo35> pb.Combo35 OR tmp.ComboOver6> pb.ComboOver6))
							FOR XML PATH('Row')
								, TYPE
							)
					FOR XML PATH('Root')
						, TYPE
					)
		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 72
			SET @ErrCode = 10056	

			RETURN
		END 
		
		
		RETURN
	END
END
GO
