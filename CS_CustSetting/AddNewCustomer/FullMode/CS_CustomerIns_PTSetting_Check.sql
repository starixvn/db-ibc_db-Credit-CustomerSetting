/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerIns_PTSetting_Check
	@RoleId			TINYINT,
	@CustId			INT = NULL,		
	@PTSetting		VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check PT info when creating new downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId:
			= 4: Create super 
				@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
						</ROOT>
			= 3: Create master 
				@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" SuperPT="10"/>
						</ROOT>	
			= 2: Create agent 
				@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MasterPT="20" AgentPT = "50"/>
						</ROOT>	
		• RuleCheck
			+ Roleid = 4:
				- n4 >= 0, l4 >= 0
				- n4 <= MaxPT, l4 <= MaxPT
				- l4 >= n4
			+ Roleid = 3:
				- s3 >= 0
				- s3 <= l4
			+ Roleid = 2:
				- m2 >= 0, a2 >=0
				- m2 <= l4, a2<=l4
				- a2 + m2 >= n4 - s3
				- a2 + m2 <= l4 - s3	
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @IsEditablePT BIT	
	DECLARE @ErrType XML, @_PTSetting XML  
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_PTSetting = @PTSetting

	IF @RoleID <> 4	
		SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID
		
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	SELECT @IsEditablePT = IsEditablePT FROM f_CS_GetEditablePTDate(@ProductID)

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
	END
	ELSE IF @RoleId = 3
	BEGIN	
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 300
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.SuperPT < 0 --check s3 >= 0
			OR cs.SuperPT > spt.MaxPT --check s3 <= l4
			OR (@IsEditablePT = 1 AND cs.SuperPT > spt.MaxPT2) --check s3 <= l4
		
		IF @@ROWCOUNT <> 0
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
	END	
	ELSE IF @RoleId = 2
	BEGIN
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 200
		FROM #NewPT cs
			INNER JOIN dbo.f_CS_GetPT_Agent(@SuperId) spt ON cs.SportType = spt.Sporttype AND cs.BetType = spt.bettype AND cs.IsLive = spt.IsLive
		WHERE cs.MasterPT < 0 OR cs.AgentPT < 0 --check m2 >= 0, a2 >=0
			OR cs.MasterPT > spt.MaxPT OR cs.AgentPT > spt.MaxPT --check m2 <= l4, a2<=l4
			OR (@IsEditablePT = 1 AND (cs.MasterPT > spt.MaxPT2 OR cs.AgentPT > spt.MaxPT2)) --check m2 <= l4, a2<=l4
		
		IF @@ROWCOUNT <> 0
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

		CREATE TABLE #tmpAllowedPT (SportType SMALLINT, Bettype SMALLINT, IsLive BIT, MinAllowedPT TINYINT, MaxAllowedPT TINYINT)

		IF @IsEditablePT = 1 
		BEGIN
			INSERT INTO #tmpAllowedPT (SportType, Bettype, IsLive, MinAllowedPT, MaxAllowedPT)
			SELECT	ft.SportType, ft.Bettype, ft.IsLive, 
					CASE	WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) AND (spt.MinPT - mpt.SuperPT) >= (spt.MinPT2 - mpt.SuperPT2) THEN spt.MinPT - mpt.SuperPT 
							WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) AND (spt.MinPT - mpt.SuperPT) < (spt.MinPT2 - mpt.SuperPT2) THEN spt.MinPT2 - mpt.SuperPT2
							WHEN (spt.MinPT < mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) THEN spt.MinPT2 - mpt.SuperPT2
							WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 < mpt.SuperPT2) THEN spt.MinPT - mpt.SuperPT
							ELSE 0 END AS MinAllowedPT, 				
					CASE	WHEN (spt.MaxPT >= mpt.SuperPT) AND (spt.MaxPT2 >= mpt.SuperPT2) AND (spt.MaxPT - mpt.SuperPT) <= (spt.MaxPT2 - mpt.SuperPT2) THEN spt.MaxPT - mpt.SuperPT 
							WHEN (spt.MaxPT >= mpt.SuperPT) AND (spt.MaxPT2 >= mpt.SuperPT2) AND (spt.MaxPT - mpt.SuperPT) > (spt.MaxPT2 - mpt.SuperPT2) THEN spt.MaxPT2 - mpt.SuperPT2
							ELSE 0 END AS MaxAllowedPT
			FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
				INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		END
		ELSE
		BEGIN
			INSERT INTO #tmpAllowedPT (SportType, Bettype, IsLive, MinAllowedPT, MaxAllowedPT)
			SELECT	ft.SportType, ft.Bettype, ft.IsLive, 
					CASE	WHEN (spt.MinPT >= mpt.SuperPT) THEN spt.MinPT - mpt.SuperPT ELSE 0 END AS MinAllowedPT, 				
					CASE	WHEN (spt.MaxPT >= mpt.SuperPT) THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAllowedPT
			FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
				INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		END

		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 
			CASE	WHEN MaxAllowedPT < MinAllowedPT THEN 203
					WHEN apt.MasterPT + apt.AgentPT < MinAllowedPT THEN 201 
					WHEN apt.MasterPT + apt.AgentPT > MaxAllowedPT THEN 202 END
		FROM #NewPT apt 
			INNER JOIN #tmpAllowedPT t ON apt.SportType = t.SportType AND apt.BetType = t.BetType AND apt.IsLive = t.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON apt.SportType = ft.SportType AND apt.BetType = ft.BetType AND apt.IsLive = ft.IsLive
		WHERE apt.MasterPT + apt.AgentPT < MinAllowedPT --check a2 + m2 >= n4 - s3
			OR apt.MasterPT + apt.AgentPT > MaxAllowedPT --check a2 + m2 <= l4 - s3
			OR MaxAllowedPT < MinAllowedPT 

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
			ELSE IF EXISTS(SELECT 1 FROM @ErrorTbl WHERE ErrCode = 203)
			BEGIN
				SET @ErrType = (
						SELECT 20043 AS '@MsgID'
							, 'Conflict between current possess and new possess values. Please try again after the new possess value takes effect.' AS '@Msg'
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
		END
	END	

	DROP TABLE #NewPT
	DROP TABLE #SportBettypeFilter1
END
GO