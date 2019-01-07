/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

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
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT
	DECLARE @ErrType XML, @_PTSetting XML  
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_PTSetting = @PTSetting

	IF @RoleID <> 4	
		SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID
	
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