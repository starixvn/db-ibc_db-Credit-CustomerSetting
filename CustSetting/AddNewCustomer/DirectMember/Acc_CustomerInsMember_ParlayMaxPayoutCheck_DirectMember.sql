/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_CustomerInsMember_ParlayMaxPayoutCheck_DirectMember
	@srecommend INT,
	@mrecommend INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	
	@GroupTypeT152 VARCHAR(MAX)= '', --SB
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

	Param's Explanation: 
		- @GroupTypeT152 :
			[
				{"SportType": "161","BetType": "81","MinBet": "0","MaxBet": "10","MPM": "10","MaxPerNumber": "10"},
				{"SportType": "164","BetType": "8101","MinBet": "0","MaxBet": "0","MPM": "0"}
			]
*/	
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @NewMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		, Child_DisplayOrder	INT
		)
	DECLARE @UplineMaxPayoutTbl TABLE (
			SportType		SMALLINT
			, BetType		SMALLINT
			, SingleMatchParlay	MONEY
			, Combo2			MONEY
			, Combo35			MONEY
			, ComboOver6		MONEY
		)		
	DECLARE @MatchParlayUnlimit TABLE(
			SportType SMALLINT, 
			BetType SMALLINT, 
			SingleMatchParlay_IsAllowUnlimit BIT, 
			Combo2_IsAllowUnlimit BIT, 
			Combo35_IsAllowUnlimit BIT, 
			ComboOver6_IsAllowUnlimit BIT)
			
	CREATE TABLE #ProductSettingDetail_Check(	
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[GroupID] [tinyint],
		[GroupType] [tinyint],
		[SettingLevel] [tinyint],	
		Child_DisplayOrder	INT,
	)
	
	DECLARE @xml XML
	
	IF ISNULL(@GroupTypeT152,'') = ''
		RETURN
		
	INSERT INTO @NewMaxPayoutTbl(SportType, 
		BetType, 
		SingleMatchParlay, 
		Combo2, 
		Combo35, 
		ComboOver6)
	SELECT SportType,BetType,SingleMP,Combo2,Combo35,Combo6
	FROM OPENJSON(@GroupTypeT152) WITH (
			SportType SMALLINT  '$.SportType'
			,BetType SMALLINT  '$.BetType'
			,SingleMP MONEY  '$.SingleMP'
			,Combo2 MONEY  '$.Combo2'
			,Combo35 MONEY  '$.Combo35'
			,Combo6 MONEY  '$.Combo6'
		)
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,IsLive,GroupID,GroupType,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,IsLive,GroupID,GroupType,
		CASE WHEN SettingLevel = 4 THEN SettingLevel --SporttypeBettype
			ELSE 2 END as SettingLevel,--Sporttype		
			Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType IN (152)
	
	BEGIN
		INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
		SELECT cs.SportType,cs.BetType,
			CASE WHEN cs.SingleMatchParlay = 0 AND ISNULL(mMp.SingleMatchParlay,0) = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
			CASE WHEN cs.Combo2 = 0 AND ISNULL(mMp.Combo2,0) = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
			CASE WHEN cs.Combo35 = 0 AND ISNULL(mMp.Combo35,0) = 0  THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
			CASE WHEN cs.ComboOver6 = 0 AND ISNULL(mMp.ComboOver6,0) = 0 THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit			
		FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
			INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			LEFT JOIN dbo.CustMaxPayoutSetting_Agent mMp WITH (NOLOCK) 
				ON s.SportType = mMp.sporttype 
				AND s.BetType = mMp.bettype 
				AND mMp.CustID = @mrecommend
		WHERE cs.custid = @srecommend  
	
		INSERT INTO @UplineMaxPayoutTbl(SportType, BetType, SingleMatchParlay, Combo2, Combo35, ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, MIN(CASE WHEN bl.SingleMatchParlay = 0 THEN NULL ELSE bl.SingleMatchParlay END) AS SingleMatchParlay
			, MIN(CASE WHEN bl.Combo2 = 0 THEN NULL ELSE bl.Combo2 END) AS Combo2
			, MIN(CASE WHEN bl.Combo35 = 0 THEN NULL ELSE bl.Combo35 END) AS Combo35
			, MIN(CASE WHEN bl.ComboOver6 = 0 THEN NULL ELSE bl.ComboOver6 END) AS ComboOver6					
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @MatchParlayUnlimit tmp
			ON tmp.SportType	= bl.SportType
				AND tmp.BetType = bl.BetType
		WHERE bl.CustID	IN(@srecommend,@mrecommend)
		GROUP BY bl.SportType, bl.BetType
	
		-->check rule: The value must be a positive amount.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
				WHERE	(tmp.SingleMatchParlay <= 0 OR tmp.Combo2 <= 0 OR tmp.Combo35	<= 0  OR tmp.ComboOver6	<= 0 )
				)
		BEGIN
			SET @xml = (
						SELECT 10070 AS '@MsgID'
							, 'The Parlay Max Payout value must be a positive amount.'  AS '@Msg'
							, (
								SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
								WHERE	(tmp.SingleMatchParlay <= 0 OR tmp.Combo2 <= 0 OR tmp.Combo35	<= 0  OR tmp.ComboOver6	<= 0 )
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 31
			SET @ErrCode = 301
		
			RETURN
		END
	
		-->Check rule: The setting of Parlay Max Payout is higher than the upline''s.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(ubl.SingleMatchParlay> 0 AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > ubl.SingleMatchParlay))				
				)	
		BEGIN
			SET @xml = (
						SELECT 10071 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Single Match Parlay is higher than the upline''s.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE	ubl.SingleMatchParlay> 0 
										AND (tmp.SingleMatchParlay = 0 OR tmp.SingleMatchParlay > ubl.SingleMatchParlay)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 31
			SET @ErrCode = 302
		
			RETURN
		END
	
		-->Check rule: The setting of Parlay Max Payout is higher than the upline''s.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE (ubl.Combo2	> 0  AND ( tmp.Combo2 = 0 OR tmp.Combo2 > ubl.Combo2))				
				)	
		BEGIN
			SET @xml = (
						SELECT 10072 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo 2 is higher than the upline''s.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE ubl.Combo2	> 0  
									AND ( tmp.Combo2 = 0 OR tmp.Combo2 > ubl.Combo2)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 31
			SET @ErrCode = 303
		
			RETURN
		END	
	
		-->Check rule: The setting of Parlay Max Payout is higher than the upline''s.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(ubl.Combo35 > 0  AND ( tmp.Combo35 = 0 OR tmp.Combo35 > ubl.Combo35))				
				)	
		BEGIN
			SET @xml = (
						SELECT 10073 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo 3 - 5 is higher than the upline''s.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE ubl.Combo35	> 0  
									AND ( tmp.Combo35 = 0 OR tmp.Combo35 > ubl.Combo35)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 31
			SET @ErrCode = 304
		
			RETURN
		END	
	
		-->Check rule: The setting of Parlay Max Payout is higher than the upline''s.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE (ubl.ComboOver6 > 0  AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > ubl.ComboOver6))
				)	
		BEGIN
			SET @xml = (
						SELECT 10074 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo Over 6 is higher than the upline''s.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, ps.GroupID AS '@GroupID'
									, ps.GroupType AS '@GroupType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN @UplineMaxPayoutTbl ubl ON tmp.SportType = ubl.SportType AND tmp.BetType = ubl.BetType
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE ubl.ComboOver6 > 0  
									AND ( tmp.ComboOver6 = 0 OR tmp.ComboOver6 > ubl.ComboOver6)
								FOR XML PATH('Row')
									, TYPE
								)
						FOR XML PATH('Root')
							, TYPE
						)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
			SET @MsgType = 31
			SET @ErrCode = 305
		
			RETURN
		END
	END

	DROP TABLE #ProductSettingDetail_Check
END
GO