/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_CommBetSetting_Check
	@RoleId			TINYINT,
	@CustID			INT,
	@CommSetting	VARCHAR(MAX),
	@BetSetting		VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check comm and betsetting when user update setting
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId 
			= 4,3,2: Update super, master, agent
				@CommSetting: <ROOT>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
								<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
								...						
							</ROOT>
				@BetSetting: <ROOT>
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								...						
							</ROOT>
			= 1: Update member 
				@CommSetting: <ROOT>
								<Comm SportType="1" BetType="1" IsLive="0" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="1" ValueId = "6"/>
								<Comm SportType="1" BetType="5" IsLive="0" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="0" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="1" ValueId = "21"/>	
								...						
							</ROOT>
				@BetSetting: <ROOT>
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerEvent = "80000"/>
								...						
							</ROOT>		
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @Currency INT
	DECLARE @ErrType XML, @_CommSetting XML, @_BetSetting XML, @uGroup VARCHAR(3)
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_CommSetting = @CommSetting, @_BetSetting = @BetSetting	
	
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend, @Currency = currency 
	FROM dbo.custInfo WITH (NOLOCK) 
	WHERE custid = @CustID AND roleid = @RoleId

	/********************************************* Commission & Bet Setting : SettingType = 2 ****************************************/	
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,2, @IsTest) t
	
	--Start check BetSetting
	SELECT bs.* INTO #NewBetSetting
	FROM dbo.f_CS_BetSettingParse(@_BetSetting) bs
		INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive

	INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
	SELECT cs.SportType, cs.BetType, cs.IsLive, 
		CASE	WHEN cs.MaxBet < 0 OR cs.MaxPerEvent < 0 THEN 400
				WHEN cs.MaxBet > cs.MaxPerEvent THEN 401 END
	FROM #NewBetSetting cs
	WHERE cs.MaxBet < 0 OR cs.MaxPerEvent < 0
		OR cs.MaxBet > cs.MaxPerEvent

	IF @@ROWCOUNT <> 0
	BEGIN
		IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 400)
		BEGIN
			SET @ErrType = (
					SELECT 10040 AS '@MsgID'
						, 'Wrong Max per Bet/ Max per Event.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 400									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 400
		
			RETURN
		END
		ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 401)
		BEGIN
			SET @ErrType = (
					SELECT 10041 AS '@MsgID'
						, 'Max per Bet must be less than Max per Event.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 401									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 401
		
			RETURN
		END
	END	

	INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
	SELECT cs.SportType, cs.BetType, cs.IsLive, 404
	FROM #NewBetSetting cs
		INNER JOIN dbo.CS_ProductBetSetting bs WITH(NOLOCK) ON cs.SportType = bs.Sporttype AND cs.BetType = bs.bettype AND cs.IsLive = bs.IsLive AND bs.Currency = @Currency
	WHERE cs.MaxBet < bs.MinBet

	IF @@ROWCOUNT <> 0
	BEGIN
		IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 404)
		BEGIN
			SET @ErrType = (
					SELECT 10044 AS '@MsgID'
						, 'The current Max Per Bet value is lower than Company Min Bet.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 404									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 71
			SET @ErrCode = 404
		
			RETURN
		END		
	END		

	IF @RoleId = 4
	BEGIN			
		SELECT mb.sporttype, mb.bettype, mb.Islive,
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.CustId = ci.custid
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mb.sporttype, mb.bettype, mb.Islive
					
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet < dl.MaxMaxBetDownline THEN 402
					WHEN cs.MaxPerEvent < dl.MaxMaxPerEventDownline THEN 403 END
		FROM #NewBetSetting cs
			INNER JOIN #BetDownlines4 dl WITH(NOLOCK) ON cs.SportType = dl.Sporttype AND cs.BetType = dl.bettype AND cs.IsLive = dl.IsLive
		WHERE cs.MaxBet < dl.MaxMaxBetDownline
			OR cs.MaxPerEvent < dl.MaxMaxPerEventDownline

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 402)
			BEGIN
				SET @ErrType = (
						SELECT 10042 AS '@MsgID'
							, 'Max per Bet is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 402									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 402
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 403)
			BEGIN
				SET @ErrType = (
						SELECT 10043 AS '@MsgID'
							, 'Max per Event is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 403									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 403
		
				RETURN
			END
		END		

		DROP TABLE #BetDownlines4
	END
	ELSE IF @RoleId = 3
	BEGIN		
		SELECT mb.sporttype, mb.bettype, mb.Islive,
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.CustId = ci.custid
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY mb.sporttype, mb.bettype, mb.Islive
					
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet < ISNULL(dl.MaxMaxBetDownline,0) OR cs.MaxBet > sb.MaxBet THEN 302
					WHEN cs.MaxPerEvent < ISNULL(dl.MaxMaxPerEventDownline,0) OR cs.MaxPerEvent > sb.MaxPerEvent THEN 303 END
		FROM #NewBetSetting cs			
			INNER JOIN dbo.CS_CustBetSetting_Agent sb WITH (NOLOCK) ON sb.SportType = cs.SportType AND sb.BetType = cs.BetType AND sb.IsLive = cs.IsLive
			LEFT JOIN #BetDownlines3 dl WITH(NOLOCK) ON cs.SportType = dl.Sporttype AND cs.BetType = dl.bettype AND cs.IsLive = dl.IsLive
		WHERE sb.CustId = @SuperId AND (cs.MaxBet < dl.MaxMaxBetDownline
											OR cs.MaxPerEvent < dl.MaxMaxPerEventDownline
											OR cs.MaxBet > sb.MaxBet
											OR cs.MaxPerEvent > sb.MaxPerEvent)

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 302)
			BEGIN
				SET @ErrType = (
						SELECT 10042 AS '@MsgID'
							, 'Max per Bet is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 302									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 302
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 303)
			BEGIN
				SET @ErrType = (
						SELECT 10043 AS '@MsgID'
							, 'Max per Event is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 303									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 303
		
				RETURN
			END
		END		

		DROP TABLE #BetDownlines3
	END	
	ELSE IF @RoleId = 2
	BEGIN
		SELECT mb.sporttype, mb.bettype, mb.Islive,
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines2
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Member mb WITH (NOLOCK) ON mb.CustId = ci.custid
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.recommend = @CustId AND ci.roleid = 1
		GROUP BY mb.sporttype, mb.bettype, mb.Islive
					
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet < ISNULL(dl.MaxMaxBetDownline,0) OR cs.MaxBet > mb.MaxBet THEN 202
					WHEN cs.MaxPerEvent < ISNULL(dl.MaxMaxPerEventDownline,0) OR cs.MaxPerEvent > mb.MaxPerEvent THEN 203 END
		FROM #NewBetSetting cs			
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.SportType = cs.SportType AND mb.BetType = cs.BetType AND mb.IsLive = cs.IsLive
			LEFT JOIN #BetDownlines2 dl WITH(NOLOCK) ON cs.SportType = dl.Sporttype AND cs.BetType = dl.bettype AND cs.IsLive = dl.IsLive
		WHERE mb.CustId = @MasterId AND (cs.MaxBet < dl.MaxMaxBetDownline
											OR cs.MaxPerEvent < dl.MaxMaxPerEventDownline
											OR cs.MaxBet > mb.MaxBet
											OR cs.MaxPerEvent > mb.MaxPerEvent)

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 202)
			BEGIN
				SET @ErrType = (
						SELECT 10042 AS '@MsgID'
							, 'Max per Bet is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 202									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 202
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 203)
			BEGIN
				SET @ErrType = (
						SELECT 10043 AS '@MsgID'
							, 'Max per Event is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 203									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 203
		
				RETURN
			END
		END
		
		DROP TABLE #BetDownlines2		
	END	
	ELSE IF @RoleId = 1
	BEGIN
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet > ab.MaxBet THEN 102
					WHEN cs.MaxPerEvent > ab.MaxPerEvent THEN 103 END
		FROM #NewBetSetting cs			
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = cs.SportType AND ab.BetType = cs.BetType AND ab.IsLive = cs.IsLive
		WHERE ab.CustId = @AgentId AND (cs.MaxBet > ab.MaxBet OR cs.MaxPerEvent > ab.MaxPerEvent)

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 102)
			BEGIN
				SET @ErrType = (
						SELECT 10042 AS '@MsgID'
							, 'Max per Bet is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 102									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 102
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 103)
			BEGIN
				SET @ErrType = (
						SELECT 10043 AS '@MsgID'
							, 'Max per Event is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 103									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 71
				SET @ErrCode = 103
		
				RETURN
			END
		END		
	END	
	--End check BetSetting

	--Start check CommSetting
	SELECT cs.* INTO #NewComm
	FROM dbo.f_CS_CommParse(@_CommSetting) cs
		INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive

	--Check if new discount is invalid
	INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
	SELECT cs.SportType, cs.BetType, cs.IsLive, 404
	FROM #NewComm cs
		LEFT JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cs.ValueId
	WHERE ct.ValueId IS NULL

	IF @@ROWCOUNT <> 0
	BEGIN
		SET @ErrType = (
				SELECT 1 AS '@MsgID'
					, 'Invalid commission rate.' AS '@Msg'
					, (
						SELECT tmp.SportType AS '@SportType'
							, tmp.BetType AS '@BetType'
							, tmp.IsLive AS '@IsLive'
						FROM @ErrorTbl tmp
						WHERE	ErrCode = 404									
						FOR XML PATH('Row')
							, TYPE	
						)						
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
		SET @MsgType = 51
		SET @ErrCode = 404
		
		RETURN
	END

	IF @RoleId = 4
	BEGIN
		--Check if new discount > default Max Discount
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 405
		FROM #NewComm cs
			INNER JOIN CS_ProductSettingDetail ps  WITH (NOLOCK) ON ps.SportType = cs.SportType AND ps.BetType = cs.BetType AND ps.IsLive = cs.IsLive AND ps.SettingType = 2
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cs.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = ps.SportType AND gc.BetType = ps.BetType AND gc.IsLive = ps.IsLive AND gc.GroupId = cs.GroupId
		WHERE ct.Value > CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 1 AS '@MsgID'
						, 'Invalid commission rate.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 405									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 405
		
			RETURN
		END
		
		SELECT mc.sporttype, mc.bettype, mc.Islive, mc.GroupId, MAX(mc.Discount) AS MaxCommDownline
		INTO #CommDownlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) mc 
			INNER JOIN #SportBettypeFilter2 ft ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mc.sporttype, mc.bettype, mc.Islive, mc.GroupId
		
		--Check if new discount < downline's discount
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 406
		FROM #NewComm cs
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cs.ValueId
			INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			LEFT JOIN #CommDownlines4 dl WITH (NOLOCK) ON dl.SportType = cs.SportType AND dl.BetType = cs.BetType AND dl.IsLive = cs.IsLive AND dl.GroupId = cs.GroupId
		WHERE ct.Value < ISNULL(dl.MaxCommDownline,0)
	
		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 406									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 406
		
			RETURN
		END

		DROP TABLE #CommDownlines4		
	END
	ELSE IF @RoleId = 3
	BEGIN 
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cm.SportType, cm.BetType, cm.IsLive, 305		
		FROM #NewComm cm
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@SuperId) uc ON cm.SportType = uc.SportType AND cm.BetType = uc.BetType AND cm.IsLive = uc.IsLive AND uc.groupID = cm.GroupId
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cm.ValueId
		WHERE ct.Value > uc.Discount

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 305									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 305
		
			RETURN
		END	

		SELECT mc.sporttype, mc.bettype, mc.Islive, mc.GroupId, MAX(mc.Discount) AS MaxCommDownline
		INTO #CommDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) mc 
			INNER JOIN #SportBettypeFilter2 ft ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY mc.sporttype, mc.bettype, mc.Islive, mc.GroupId

		--Check if new discount < downline's discount
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 306
		FROM #NewComm cs
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cs.ValueId
			INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			LEFT JOIN #CommDownlines3 dl WITH (NOLOCK) ON dl.SportType = cs.SportType AND dl.BetType = cs.BetType AND dl.IsLive = cs.IsLive AND dl.GroupId = cs.GroupId
		WHERE ct.Value < ISNULL(dl.MaxCommDownline,0)
	
		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 306									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 306
		
			RETURN
		END
		
		DROP TABLE #CommDownlines3
	END
	ELSE IF @RoleId = 2
	BEGIN 
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cm.SportType, cm.BetType, cm.IsLive, 205
		FROM #NewComm cm
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@MasterId) uc ON cm.SportType = uc.SportType AND cm.BetType = uc.BetType AND cm.IsLive = uc.IsLive AND uc.groupID = cm.GroupId
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cm.ValueId
		WHERE ct.Value > uc.Discount

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 205									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 205
		
			RETURN
		END	
		
		SELECT memc.sporttype, memc.bettype, memc.Islive, gc.GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #CommDownlines2
		FROM dbo.customer c WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Member(c.custid) memc 
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustID AND c.roleid = 1
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId

		SELECT memc.sporttype, memc.bettype, memc.Islive, gc.GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #CommGroupDownlines2
		FROM dbo.f_CS_GetGroupDiscount_Member(@CustID) memc  
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			INNER JOIN dbo.CS_GroupConfig gc ON memc.uGroup = gc.uGroup
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId

		--Check if new discount < downline's discount
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 206
		FROM #NewComm cs
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cs.ValueId
			INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			LEFT JOIN #CommDownlines2 dl WITH (NOLOCK) ON dl.SportType = cs.SportType AND dl.BetType = cs.BetType AND dl.IsLive = cs.IsLive AND dl.GroupId = cs.GroupId
			LEFT JOIN #CommGroupDownlines2 dlg WITH (NOLOCK) ON dlg.SportType = cs.SportType AND dlg.BetType = cs.BetType AND dlg.IsLive = cs.IsLive AND dlg.GroupId = cs.GroupId
		WHERE ct.Value < CASE WHEN ISNULL(dl.MaxCommDownline,0) < ISNULL(dlg.MaxCommDownline,0) THEN ISNULL(dlg.MaxCommDownline,0) ELSE ISNULL(dl.MaxCommDownline,0) END
	
		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 206									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 206
		
			RETURN
		END

		DROP TABLE #CommDownlines2
	END
	ELSE IF @RoleId = 1
	BEGIN 
		SELECT @uGroup = ugroup FROM Customer WITH (NOLOCK) WHERE custid = @CustID

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cm.SportType, cm.BetType, cm.IsLive, 105		
		FROM #NewComm cm
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cm.ValueId
			INNER JOIN #SportBettypeFilter2 ft ON cm.SportType = ft.SportType AND cm.BetType = ft.BetType AND cm.IsLive = ft.IsLive
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@AgentId) uc ON cm.SportType = uc.SportType AND cm.BetType = uc.BetType AND cm.IsLive = uc.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = uc.sporttype AND gc.BetType = uc.bettype AND gc.IsLive = uc.isLive AND gc.GroupId = uc.groupID			
		WHERE (gc.uGroup = @uGroup OR gc.GroupId IS NULL) AND ct.Value > uc.Discount

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Please refresh the page and try again. Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 105									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 105
		
			RETURN
		END	
	END

	DROP TABLE #NewBetSetting
	DROP TABLE #NewComm
	DROP TABLE #SportBettypeFilter2
	--End check CommSetting
END
GO
