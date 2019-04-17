/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet" viewers="" isFunction="0" ></info>*/

ALTER PROCEDURE CS_CustomerIns_CommBetSetting_Check
	@RoleId			TINYINT,
	@CustId			INT = NULL,
	@CommSetting	VARCHAR(MAX),
	@BetSetting		VARCHAR(MAX),
	@uGroup			VARCHAR(3) = NULL,
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check some info of commission and betsetting when creating new downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId 
			= 4,3,2: Create super, master, agent
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
			= 1: Create member 
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
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT
	DECLARE @ErrType XML, @_CommSetting XML, @_BetSetting XML  
	DECLARE @ErrorTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, ErrCode INT)

	SELECT @ErrCode = 0, @_CommSetting = @CommSetting, @_BetSetting = @BetSetting	

	IF @RoleID <> 4	
		SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID
		
	/********************************************* Commission & Bet Setting : SettingType = 2 ****************************************/	
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,2, @IsTest) t
	
	--Start check BetSetting
	SELECT bs.* INTO #NewBetSetting
	FROM dbo.f_CS_BetSettingParse(@_BetSetting) bs
		INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive
	
	--Check all bet setting >=0
	--Check MaxBet<=MaxPerEvent	
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
						, 'Wrong Max bet/ Max per match.' AS '@Msg'
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
						, 'Max bet must be less than max bet per match.' AS '@Msg'
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

	IF @RoleId <> 4
	BEGIN
		--Check MaxBet < upline's maxbet
		--Check MaxPerEvent < upline's MaxPerEvent
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT cs.SportType, cs.BetType, cs.IsLive, 
			CASE	WHEN cs.MaxBet > ubs.MaxBet THEN 402
					WHEN cs.MaxPerEvent > ubs.MaxPerEvent THEN 403 END
		FROM #NewBetSetting cs
			INNER JOIN dbo.CS_CustBetSetting_Agent ubs WITH (NOLOCK) ON ubs.SportType = cs.SportType AND ubs.BetType = cs.BetType AND ubs.IsLive = cs.IsLive
		WHERE ubs.CustId = @CustId
			AND (cs.MaxBet > ubs.MaxBet OR cs.MaxPerEvent > ubs.MaxPerEvent)

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
							, 'Max bet per match is out of range.' AS '@Msg'
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
	END
	--End check BetSetting

	--Check Comm
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
		SELECT DISTINCT cs.SportType, cs.BetType, cs.IsLive, 405
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
	END
	ELSE IF @RoleId IN (2, 3)
	BEGIN 
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT DISTINCT cm.SportType, cm.BetType, cm.IsLive, 406			
		FROM #NewComm cm
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustId) uc ON cm.SportType = uc.SportType AND cm.BetType = uc.BetType AND cm.IsLive = uc.IsLive AND uc.groupID = cm.GroupId
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cm.ValueId
		WHERE ct.Value > uc.Discount

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Commission is out of range.' AS '@Msg'
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
	END
	ELSE IF @RoleId = 1
	BEGIN 
		INSERT INTO @ErrorTbl (SportType, BetType, IsLive, ErrCode)
		SELECT DISTINCT cm.SportType, cm.BetType, cm.IsLive, 407		
		FROM #NewComm cm
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustId) uc ON cm.SportType = uc.SportType AND cm.BetType = uc.BetType AND cm.IsLive = uc.IsLive
			INNER JOIN dbo.CS_GroupConfig gc ON gc.SportType = uc.sporttype AND gc.BetType = uc.bettype AND gc.IsLive = uc.isLive AND gc.GroupId = uc.groupID
			INNER JOIN dbo.CS_CommTemplate ct WITH (NOLOCK) ON ct.ValueId = cm.ValueId
		WHERE gc.uGroup = @uGroup AND ct.Value > uc.Discount

		IF @@ROWCOUNT <> 0
		BEGIN
			SET @ErrType = (
					SELECT 11 AS '@MsgID'
						, 'Commission is out of range.' AS '@Msg'
						, (
							SELECT tmp.SportType AS '@SportType'
								, tmp.BetType AS '@BetType'
								, tmp.IsLive AS '@IsLive'
							FROM @ErrorTbl tmp
							WHERE	ErrCode = 407									
							FOR XML PATH('Row')
								, TYPE	
							)						
					FOR XML PATH('Root')
						, TYPE
					)		
			SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @ErrType), '" />', '"/"')
			SET @MsgType = 51
			SET @ErrCode = 407
		
			RETURN
		END	
	END

	DROP TABLE #NewBetSetting
	DROP TABLE #NewComm
	DROP TABLE #SportBettypeFilter2
END
GO
