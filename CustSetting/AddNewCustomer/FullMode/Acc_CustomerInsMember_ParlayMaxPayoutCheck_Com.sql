/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_ParlayMaxPayoutCheck_Com]
	@siteid SMALLINT=0,
	@currency SMALLINT = 0,
	@SettingType27 VARCHAR(MAX)= '' OUTPUT, --SB
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT,
	@IsValidateParam BIT = 1,
	@IsUpdateParam BIT = 0 -- Update Parameter
AS
/*
	Created: 20231010@Eden
	Task : check Parlay Max Payout for Super 
	DB:  DBCUST/CustDB  
	Original sp: 
	
	Revisions: 
		- 20231010@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240822@Eden: Scale out DBCUST - Credit Customer in GlobCustDB [redmine: #206823]

	Param's Explanation: 
		- @SettingType27 = '<Root>
						<R SportType="1" BetType="9" SingleMP="1000" Combo2="1000" Combo35="1000" Combo6="1000" />
						<R SportType="99" BetType="1" SingleMP="1000" Combo2="1000" Combo35="1000" Combo6="1000" />
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
		, Child_DisplayOrder	INT
		)
	
	CREATE TABLE #ProductSettingDetail_Check(	
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SettingLevel] [tinyint],		
		Child_DisplayOrder	INT,
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	DECLARE @xml XML
	
	IF ISNULL(@SettingType27,'') = ''
		RETURN
		
	SELECT @xml = CONVERT(XML,@SettingType27)
		
	INSERT INTO @NewMaxPayoutTbl(SportType, 
		BetType, 
		SingleMatchParlay, 
		Combo2, 
		Combo35, 
		ComboOver6)
	SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
		T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
		T.c.query('.').value('(R/@SingleMP)[1]', 'money') AS SingleMatchParlay,
		T.c.query('.').value('(R/@Combo2)[1]', 'money') AS Combo2,
		T.c.query('.').value('(R/@Combo35)[1]', 'money') AS Combo35,
		T.c.query('.').value('(R/@Combo6)[1]', 'money') AS ComboOver6
	FROM  @xml.nodes('/Root/R') T(c) 
	
	INSERT INTO #ProductSettingDetail_Check(SportType,BetType,SettingType,IsLive,SettingLevel,Child_DisplayOrder)
	SELECT SportType,BetType,SettingType,IsLive,
		CASE WHEN SettingLevel = 4 THEN SettingLevel --SporttypeBettype
			ELSE 2 END as SettingLevel,--Sporttype	
			Child_DisplayOrder
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteID,@currency)
	WHERE SettingType IN (27)
	
	IF @IsValidateParam = 1
		BEGIN
		-->check rule: The value must be a positive amount.
		IF EXISTS(	SELECT TOP 1 1 
					FROM @NewMaxPayoutTbl tmp
						INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype	
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
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype																		
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
	
		-->Check rule: The setting of Parlay Max Payout is higher than the company setting.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(tmp.SingleMatchParlay> pb.SingleMatchParlay AND tmp.SingleMatchParlay > 0)				
				)	
		BEGIN
			SET @xml = (
						SELECT 10071 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Single Match Parlay is higher than the company setting.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype																		
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE	(tmp.SingleMatchParlay> pb.SingleMatchParlay AND tmp.SingleMatchParlay > 0)	
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
	
		-->Check rule: The setting of Parlay Max Payout is higher than the company setting.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(tmp.Combo2> pb.Combo2 AND tmp.Combo2 > 0)					
				)	
		BEGIN
			SET @xml = (
						SELECT 10072 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo 2 is higher than the company setting.'  AS '@Msg'
							, ( SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE	(tmp.Combo2> pb.Combo2 AND tmp.Combo2 > 0)	
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
	
		-->Check rule: The setting of Parlay Max Payout is higher than the company setting.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(tmp.Combo35> pb.Combo35 AND tmp.Combo35 > 0)				
				)	
		BEGIN
			SET @xml = (
						SELECT 10073 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo 3 - 5 is higher than the company setting.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE	(tmp.Combo35> pb.Combo35 AND tmp.Combo35 > 0)	
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
	
		-->Check rule: The setting of Parlay Max Payout is higher than the company setting.
		IF EXISTS(SELECT TOP 1 1 
				FROM @NewMaxPayoutTbl tmp
					INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
					LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
				WHERE	(tmp.ComboOver6> pb.ComboOver6 AND tmp.ComboOver6 > 0)	
				)	
		BEGIN
			SET @xml = (
						SELECT 10074 AS '@MsgID'
							, 'Parlay Max Payout per Bet: The setting of Combo Over 6 is higher than the company setting.'  AS '@Msg'
							, (SELECT  tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @NewMaxPayoutTbl tmp
									INNER JOIN #ProductSettingDetail_Check ps ON tmp.SportType = ps.SportType AND tmp.Bettype = ps.Bettype
									LEFT JOIN dbo.MaxPayoutGlobalSetting pb  WITH (NOLOCK) ON pb.Sporttype = tmp.SportType AND pb.Bettype = tmp.BetType AND pb.Currency = @Currency
								WHERE	(tmp.ComboOver6> pb.ComboOver6 AND tmp.ComboOver6 > 0)	
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

	IF @IsUpdateParam = 1 -- UpdateParameter for update and writelog
	BEGIN
		UPDATE t
		SET t.Child_DisplayOrder = d.Child_DisplayOrder
		FROM @NewMaxPayoutTbl t
			INNER JOIN #ProductSettingDetail_Check d 
				ON t.SportType = d.SportType
				AND t.BetType = d.BetType
		
		SELECT @SettingType27 = (
		SELECT SportType '@SportType', 
			BetType '@BetType', 
			SingleMatchParlay '@SingleMP',
			Combo2 '@Combo2',
			Combo35 '@Combo35',
			ComboOver6 '@Combo6'
		FROM @NewMaxPayoutTbl
		ORDER BY Child_DisplayOrder,SportType,BetType
		FOR XML PATH ('R'), ROOT('Root')
		)	
	END

	DROP TABLE #ProductSettingDetail_Check
END