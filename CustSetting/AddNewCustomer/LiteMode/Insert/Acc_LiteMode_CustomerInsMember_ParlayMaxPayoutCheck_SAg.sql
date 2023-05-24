/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_LiteMode_CustomerInsMember_ParlayMaxPayoutCheck_SAg]
	@srecommend INT,
	@SettingType27 VARCHAR(MAX)= '', --SB
	
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT	
AS
/*
	Created: 20230519@Johnson  
	Task : check Parlay Max Payout for master 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20230519@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
		- @SettingType27 = '<Root>
						<r sporttype="1" bettype="9" singlemp="1000" combo2="1000" combo35="1000" combo6="1000" />
						<r sporttype="99" bettype="1" singlemp="1000" combo2="1000" combo35="1000" combo6="1000" />
					</Root>'	
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
	
	DECLARE @xml XML,
		@currency TINYINT
	
	IF ISNULL(@SettingType27,'') <> ''
		RETURN
		
	SELECT @xml = CONVERT(XML,@SettingType27)
		
	INSERT INTO @NewMaxPayoutTbl(SportType, 
		BetType, 
		SingleMatchParlay, 
		Combo2, 
		Combo35, 
		ComboOver6)
	SELECT T.c.query('.').value('(r/@sporttype)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(r/@bettype)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(r/@singlemp)[1]', 'money') AS SingleMatchParlay,
		T.c.query('.').value('(r/@combo2)[1]', 'money') AS Combo2,
		T.c.query('.').value('(r/@combo35)[1]', 'money') AS Combo35,
		T.c.query('.').value('(r/@combo6)[1]', 'money') AS ComboOver6
	FROM  @xml.nodes('/Root/r') T(c) 
			
	INSERT INTO @MatchParlayUnlimit(SportType,BetType,SingleMatchParlay_IsAllowUnlimit,Combo2_IsAllowUnlimit,Combo35_IsAllowUnlimit,ComboOver6_IsAllowUnlimit)
	SELECT cs.SportType,cs.BetType,
			CASE WHEN cs.SingleMatchParlay = 0 THEN 1 ELSE 0 END AS SingleMatchParlay_IsAllowUnlimit,
			CASE WHEN cs.Combo2 = 0 THEN 1 ELSE 0 END AS Combo2_IsAllowUnlimit,
			CASE WHEN cs.Combo35 = 0 THEN 1 ELSE 0 END AS Combo35_IsAllowUnlimit,
			CASE WHEN cs.ComboOver6 = 0  THEN 1 ELSE 0 END AS ComboOver6_IsAllowUnlimit
	FROM dbo.CustMaxPayoutSetting_Agent cs WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
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
	WHERE bl.CustID			= @srecommend
	GROUP BY bl.SportType, bl.BetType
	
	SELECT @currency = currency 
	FROM custinfo WITH(NOLOCK)
	WHERE custid = @srecommend 

	-->check rule: The value must be a positive amount.
	IF EXISTS(SELECT TOP 1 1 
			FROM @NewMaxPayoutTbl tmp
			WHERE	(tmp.SingleMatchParlay < 0 OR tmp.Combo2 < 0 OR tmp.Combo35	< 0  OR tmp.ComboOver6	< 0 )
			)
	BEGIN
		SET @xml = (
					SELECT 10070 AS '@MsgID'
						, 'The Parlay Max Payout value must be a positive amount.'  AS '@Msg'
						, (
							SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewMaxPayoutTbl tmp
							WHERE	(tmp.SingleMatchParlay < 0 OR tmp.Combo2 < 0 OR tmp.Combo35	< 0  OR tmp.ComboOver6	< 0 )
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
						, 'Parlay Max Payout: The setting of SingleMatchParlay is higher than the upline''s.'  AS '@Msg'
						, (SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewMaxPayoutTbl tmp
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
						, 'Parlay Max Payout: The setting of Combo2 is higher than the upline''s.'  AS '@Msg'
						, (SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewMaxPayoutTbl tmp
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
						, 'Parlay Max Payout: The setting of Combo35 is higher than the upline''s.'  AS '@Msg'
						, (SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewMaxPayoutTbl tmp
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
						, 'Parlay Max Payout: The setting of ComboOver6 is higher than the upline''s.'  AS '@Msg'
						, (SELECT  tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @NewMaxPayoutTbl tmp
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