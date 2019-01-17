/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_PTSetting_Check
	@RoleId			TINYINT,
	@CustID			INT,
	@PTSetting		VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check PT info when update PT
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId 
			= 4: Update super 
				@PTSetting:	<ROOT>
								<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
							</ROOT>	
			= 3: Update master 
				@PTSetting: <ROOT>
								<PT SportType="1" BetType="1" IsLive="0" SuperPT="10"/>
							</ROOT>
			= 2: Update agent 
				@PTSetting: <ROOT>
								<PT SportType="1" BetType="1" IsLive="0" MasterPT="20" AgentPT = "50"/>
							</ROOT>	
		• RuleCheck
			+ Roleid = 4:
				- n4 >= 0, l4 >= 0
				- n4 <= MaxPT, l4 <= MaxPT
				- l4 >= n4
				- l4 >= MAX(s3)
				- l4 >= MAX(s1+m1+a1)
				- n4 <= MIN(s1+m1+a1)
			+ Roleid = 3:
				- s3 >= 0
				- s3 <= l4
				- s3 >= n4 - MAX(m2+a2) if master has at least 1 agent
				- s3 <= l4 - MAX(m2+a2) if master has at least 1 agent
			+ Roleid = 2:
				- m2 >= 0, a2 >=0
				- m2 <= l4, a2<=l4
				- a2 + m2 >= n4 - s3
				- a2 + m2 <= l4 - s3
	Example: 
		EXEC CS_CustSetting_PTSetting_Check @RoleId = 4, @CustID = 33418956, @IsTest = 1,
			@PTSetting = '<ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
						</ROOT>'
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT
	DECLARE @ErrType XML, @_PTSetting XML  
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_PTSetting = @PTSetting	
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	SELECT pt.* INTO #NewPT
	FROM dbo.f_CS_PTParse(@_PTSetting) pt
		INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive

	IF @RoleId = 4
	BEGIN				
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MinPT < 0 OR cs.MinPT > ps.MaxPT OR cs.MaxPT < 0 OR cs.MaxPT > ps.MaxPT THEN 400
					WHEN cs.MaxPT < cs.MinPT THEN 401 END
		FROM #NewPT cs
			INNER JOIN CS_ProductSettingDetail ps WITH(NOLOCK) ON cs.SportType = ps.Sporttype AND cs.BetType = ps.bettype AND cs.IsLive = ps.IsLive AND ps.SettingType = 1
		WHERE cs.MinPT < 0 OR cs.MinPT > ps.MaxPT --check n4 >= 0, l4 >= 0
			OR cs.MaxPT < 0 OR cs.MaxPT > ps.MaxPT --check n4 <= MaxPT, l4 <= MaxPT
			OR cs.MaxPT < cs.MinPT --check l4 >= n4

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 400)
			BEGIN
				SET @ErrType = (
						SELECT 20001 AS '@MsgID'
							, 'Wrong position taking.' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 400
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 401)
			BEGIN
				SET @ErrType = (
						SELECT 30009 AS '@MsgID'
							, 'Super Min PT must be less than or equal to Super Max PT.' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 401
		
				RETURN
			END
		END		

		SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.SuperPT) AS MaxSuperPT
		INTO #PTMaster4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPT_Agent(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 404 -- check l4 >= MAX(s3)
		FROM #NewPT spt				
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
			LEFT JOIN #PTMaster4 mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
		WHERE spt.MaxPT < ISNULL(mpt.MaxSuperPT,0)

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 30008 AS '@MsgID'
						, 'New Super Max PT is less than the Total PT Taken by some lines.' AS '@Msg'
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
			SET @MsgType = 5
			SET @ErrCode = 404
		
			RETURN
		END		

		SELECT acs.sporttype, acs.bettype, acs.Islive, MIN(acs.SuperPT + acs.MasterPT + acs.AgentPT) AS MinPTDownline, MAX(acs.SuperPT + acs.MasterPT + acs.AgentPT) AS MaxPTDownline 
		INTO #PTDownlines4
		FROM dbo.custInfo a WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPTGroup_Member(a.custid) acs
			INNER JOIN #SportBettypeFilter1 ft ON acs.SportType = ft.SportType AND acs.BetType = ft.BetType AND acs.IsLive = ft.IsLive
		WHERE a.srecommend = @CustId AND a.roleid = 2
		GROUP BY acs.sporttype, acs.bettype, acs.Islive

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive,
			CASE	WHEN spt.MinPT > ISNULL(dl.MinPTDownline,spt.MaxPT) THEN 402 -- check n4 <= MIN(s1+m1+a1)			 
					WHEN spt.MaxPT < ISNULL(dl.MaxPTDownline,0) THEN 403 END -- check l4 >= MAX(s1+m1+a1)
		FROM #NewPT spt	
			LEFT JOIN #PTDownlines4 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		WHERE spt.MinPT > ISNULL(dl.MinPTDownline,spt.MaxPT) OR spt.MaxPT < ISNULL(dl.MaxPTDownline,0)

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 402)
			BEGIN
				SET @ErrType = (
						SELECT 30007 AS '@MsgID'
							, 'New Super Min PT is greater than the Total PT Taken by some lines.' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 402
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 403)
			BEGIN
				SET @ErrType = (
						SELECT 30008 AS '@MsgID'
							, 'New Super Max PT is less than the Total PT Taken by some lines.' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 403
		
				RETURN
			END
		END		
	END
	ELSE IF @RoleId = 3
	BEGIN		
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.SuperPT < 0 THEN 300
					WHEN cs.SuperPT > spt.MaxPT THEN 303 END
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.SuperPT < 0 --check s3 >= 0
			OR cs.SuperPT > spt.MaxPT --check s3 <= l4
		
		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 300)
			BEGIN
				SET @ErrType = (
						SELECT 20001 AS '@MsgID'
							, 'Wrong position taking.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
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
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 303)
			BEGIN
				SET @ErrType = (
						SELECT 20036 AS '@MsgID'
							, 'New Super PT is too high. It makes some lines'' Total PT Taken become greater than Super Max PT' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 303
		
				RETURN
			END
		END

		SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.MasterPT + cs.AgentPT) AS MaxPTDownline 
		INTO #PTDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPT_Agent(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @SuperId AND ci.roleid = 2 AND ci.mrecommend = @CustID
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		IF @@ROWCOUNT <> 0 --If Master has at least 1 Agent: Range: [Max(0, Super Min PT - (Master PT + Agent PT)); Super Max PT - (Master PT + Agent PT)]
		BEGIN
			INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
			SELECT ft.SportType, ft.Bettype, ft.IsLive,
				CASE	WHEN mpt.SuperPT < CASE WHEN spt.MinPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MinPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END THEN 301
						WHEN mpt.SuperPT > CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END THEN 302 END			
			FROM dbo.f_CS_GetPT_Agent(@SuperId) spt
				INNER JOIN #NewPT mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
				LEFT JOIN #PTDownlines3 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive		
			WHERE mpt.SuperPT < CASE WHEN spt.MinPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MinPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END --check s3 >= n4 - MAX(m2+a2)
				OR mpt.SuperPT > CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END --check s3 <= l4 - MAX(m2+a2)

			IF @@ROWCOUNT <> 0
			BEGIN
				IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 301)
				BEGIN
					SET @ErrType = (
							SELECT 20035 AS '@MsgID'
								, 'New Super PT is too low. It makes some lines'' Total PT Taken become less than Super Min PT' AS '@Msg'
								, (
									SELECT tmp.SportType AS '@SportType'
										, tmp.BetType AS '@BetType'
										, tmp.IsLive AS '@IsLive'
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
							SELECT 20036 AS '@MsgID'
								, 'New Super PT is too high. It makes some lines'' Total PT Taken become greater than Super Max PT' AS '@Msg'
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
					SET @MsgType = 5
					SET @ErrCode = 302
		
					RETURN
				END
			END
		END	
	END
	ELSE IF @RoleId = 2
	BEGIN
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MasterPT < 0 OR cs.AgentPT < 0 THEN 200
					WHEN cs.MasterPT > spt.MaxPT THEN 203
					WHEN cs.AgentPT > spt.MaxPT THEN 204 END
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.MasterPT < 0 OR cs.AgentPT < 0 --check m2 >= 0, a2 >=0
			OR cs.MasterPT > spt.MaxPT OR cs.AgentPT > spt.MaxPT --check m2 <= l4, a2<=l4
		
		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 200)
			BEGIN
				SET @ErrType = (
						SELECT 20001 AS '@MsgID'
							, 'Wrong position taking.' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
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
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 203)
			BEGIN
				SET @ErrType = (
						SELECT 20039 AS '@MsgID'
							, 'Master''s PT is too high. It makes the line''s Total PT greater than Super Max PT' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 203
		
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 204)
			BEGIN
				SET @ErrType = (
						SELECT 20040 AS '@MsgID'
							, 'Agent''s PT is too high. It makes the line''s Total PT greater than Super Max PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
								FROM @ErrorTbl tmp
								WHERE	ErrCode = 204									
								FOR XML PATH('Row')
									, TYPE	
								)						
						FOR XML PATH('Root')
							, TYPE
						)		
				SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
				SET @MsgType = 5
				SET @ErrCode = 204
		
				RETURN
			END
		END

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 
			CASE	WHEN apt.MasterPT + apt.AgentPT < CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END THEN 201 
					WHEN apt.MasterPT + apt.AgentPT > CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END THEN 202 END
		FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
			INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			INNER JOIN #NewPT apt ON apt.SportType = mpt.SportType AND apt.BetType = mpt.BetType AND apt.IsLive = mpt.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		WHERE apt.MasterPT + apt.AgentPT < CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END --check a2 + m2 >= n4 - s3
			OR apt.MasterPT + apt.AgentPT > CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END --check a2 + m2 <= l4 - s3

		IF @@ROWCOUNT <> 0
		BEGIN
			IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 201)
			BEGIN
				SET @ErrType = (
						SELECT 20037 AS '@MsgID'
							, 'Master & Agent''s Total PT is too low. It makes the line''s Total PT less than Super Min PT' AS '@Msg'
							, (
								SELECT tmp.SportType AS '@SportType'
									, tmp.BetType AS '@BetType'
									, tmp.IsLive AS '@IsLive'
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
						SELECT 20038 AS '@MsgID'
							, 'Master & Agent''s Total PT is too high. It makes the line''s Total PT greater than Super Max PT' AS '@Msg'
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
				SET @MsgType = 5
				SET @ErrCode = 202
		
				RETURN
			END
		END
	END	
END
GO
