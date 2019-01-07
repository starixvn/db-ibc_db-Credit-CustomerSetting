/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

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
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
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
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								...						
							</ROOT>
		• RuleCheck
			+ Roleid = 4:
				- n4 >= 0, l4 >= 0
				- n4 <= MaxPT, l4 <= MaxPT
				- l4 >= n4
				- l4 >= MAX(s1+m1+a1)
				- n4 <= MIN(s1+m1+a1)
			+ Roleid = 3:
				- s3 >= 0
				- s3 <= l4
				- s3 >= n4 - MAX(m1+a1)
				- s3 <= l4 - MAX(m1+a1)
			+ Roleid = 2:
				- m2 >= 0, a2 >=0
				- m2 <= l4, a2<=l4
				- a2 + m2 >= n4 - s1
				- a2 + m2 <= l4 - s1
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT
	DECLARE @ErrType XML, @_CommSetting XML, @_BetSetting XML  
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_CommSetting = @CommSetting, @_BetSetting = @BetSetting	
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId
	
	/********************************************* Commission & Bet Setting : SettingType = 2 ****************************************/	
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,2, @IsTest) t
	
	--Check BetSetting
	SELECT bs.* INTO #NewBetSetting
	FROM dbo.f_CS_BetSettingParse(@_BetSetting) bs
		INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive

	INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
	SELECT cs.SportType, cs.BetType, cs.IsLive, 
		CASE	WHEN cs.MaxBet < 0 OR cs.MaxPerMatch < 0 THEN 400
				WHEN cs.MaxBet > cs.MaxPerMatch THEN 401 END
	FROM #NewBetSetting cs
	WHERE cs.MaxBet < 0 OR cs.MaxPerMatch < 0
		OR cs.MaxBet > cs.MaxPerMatch

	IF @@ROWCOUNT <> 0
	BEGIN
		IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 400)
		BEGIN
			SET @ErrType = (
					SELECT 10040 AS '@MsgID'
						, 'Wrong Max bet/ Max per match.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
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
						, 'Max bet must be less than max bet per match.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
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

	IF @RoleId = 4
	BEGIN	
		SELECT mb.sporttype, mb.bettype, mb.Islive, mc.GroupId,
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(mc.Discount) AS MaxCommDownline
		INTO #Downlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) mc
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.CustId = ci.custid AND mc.sporttype = mb.SportType AND mc.Bettype = mb.BetType AND mc.isLive = mb.IsLive
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mb.sporttype, mb.bettype, mb.Islive, mc.GroupId
					
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet < dl.MaxMaxBetDownline THEN 402
					WHEN cs.MaxPerMatch < dl.MaxMaxPerMatchDownline THEN 403 END
		FROM #NewBetSetting cs
			INNER JOIN #Downlines4 dl WITH(NOLOCK) ON cs.SportType = dl.Sporttype AND cs.BetType = dl.bettype AND cs.IsLive = dl.IsLive
		WHERE cs.MaxBet < dl.MaxMaxBetDownline
			OR cs.MaxPerMatch < dl.MaxMaxPerMatchDownline

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 402)
			BEGIN
				SET @ErrType = (
						SELECT 10042 AS '@MsgID'
							, 'Max bet is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
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
							, 'Max bet per match is out of range.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
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
	END
	ELSE IF @RoleId = 3
	BEGIN		
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 300
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.SuperPT < 0 --check s3 >= 0
			OR cs.SuperPT > spt.MaxPT --check s3 <= l4
		
		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 20001 AS '@MsgID'
						, 'Wrong position taking.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 300									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 5
			SET @ErrCode = 300
		
			RETURN
		END

		SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.MasterPT + cs.AgentPT) AS MaxPTDownline 
		INTO #PTDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPTGroup_Member(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @SuperId AND ci.roleid = 2
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive,
			CASE	WHEN mpt.SuperPT < CASE WHEN spt.MinPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MinPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END THEN 301
					WHEN mpt.SuperPT > CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END THEN 302 END			
		FROM dbo.f_CS_GetPT_Agent(@SuperId) spt
			INNER JOIN #NewPT mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			LEFT JOIN #PTDownlines3 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive		
		WHERE mpt.SuperPT < CASE WHEN spt.MinPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MinPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END --check s3 >= n4 - MAX(m1+a1)
			OR mpt.SuperPT > CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END --check s3 <= l4 - MAX(m1+a1)

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 301)
			BEGIN
				SET @ErrType = (
						SELECT 20030 AS '@MsgID'
							, 'New Super PT is too low. It makes some lines'' Total PT Taken become less than Super Min PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 301									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 5
				SET @ErrCode = 301
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 302)
			BEGIN
				SET @ErrType = (
						SELECT 20031 AS '@MsgID'
							, 'New Super PT is too high. It makes some lines'' Total PT Taken become greater than Super Max PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 302									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 5
				SET @ErrCode = 302
		
				RETURN
			END
		END
	END	
	ELSE IF @RoleId = 2
	BEGIN
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 200
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.MasterPT < 0 OR cs.AgentPT < 0 --check m2 >= 0, a2 >=0
			OR cs.MasterPT > spt.MaxPT OR cs.AgentPT > spt.MaxPT --check m2 <= l4, a2<=l4
		
		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 20001 AS '@MsgID'
						, 'Wrong position taking.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 200									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 5
			SET @ErrCode = 200
		
			RETURN
		END

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 
			CASE	WHEN apt.MasterPT + apt.AgentPT < CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END THEN 201 
					WHEN apt.MasterPT + apt.AgentPT > CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END THEN 202 END
		FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
			INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			INNER JOIN #NewPT apt ON apt.SportType = mpt.SportType AND apt.BetType = mpt.BetType AND apt.IsLive = mpt.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		WHERE apt.MasterPT + apt.AgentPT < CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END --check a2 + m2 >= n4 - s1
			OR apt.MasterPT + apt.AgentPT > CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END --check a2 + m2 <= l4 - s1

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 201)
			BEGIN
				SET @ErrType = (
						SELECT 20032 AS '@MsgID'
							, 'Master & Agent''s Total PT is too low. It makes the line''s Total PT less than Super Min PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 201									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 5
				SET @ErrCode = 201
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 202)
			BEGIN
				SET @ErrType = (
						SELECT 20033 AS '@MsgID'
							, 'Master & Agent''s Total PT is too high. It makes the line''s Total PT greater than Super Max PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 202									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 5
				SET @ErrCode = 202
		
				RETURN
			END
		END
	END	
END
GO
