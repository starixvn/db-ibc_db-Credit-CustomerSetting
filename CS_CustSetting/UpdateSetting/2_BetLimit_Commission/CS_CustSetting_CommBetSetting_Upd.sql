/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_CommBetSetting_Upd
	@RoleId			TINYINT,
	@CustID			INT,
	@CommSetting	VARCHAR(MAX),
	@BetSetting		VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,

	@SubAccID		INT = 0,
	@UserID			INT = 0,       
	@IP				VARCHAR(15)='',
	@Language		VARCHAR(2)= 'E',
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Update comm and bet setting
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190606@Elodie: Apply new structure for CN88's log [Redmine: #113198]
	Param's Explanation:
		@RoleId 
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
	DECLARE @startRun DATETIME,@endRun DATETIME, @duration INT, @ActionId INT, @SPName VARCHAR(50), @logSPData VARCHAR(MAX),@logSPData_Old VARCHAR(MAX), @ErrType XML
	DECLARE @_CommSetting XML, @_BetSetting XML, @xml XML, @xml_Old XML, @IsGroupComm BIT, @uGroup VARCHAR(3), @MemCommGroup INT
	DECLARE @Discount_XML XML, @PlayerDiscount_XML XML
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @SettingLevel TINYINT
	DECLARE @OldBetLimitTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, MaxBet MONEY, MaxPerEvent MONEY)
	DECLARE @OldCommSMATbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, GroupA DECIMAL(9,8), GroupB DECIMAL(9,8), GroupC DECIMAL(9,8), GroupD DECIMAL(9,8), Comm DECIMAL(9,8))
	DECLARE @NewCommSMATbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, GroupA DECIMAL(9,8), GroupB DECIMAL(9,8), GroupC DECIMAL(9,8), GroupD DECIMAL(9,8), Comm DECIMAL(9,8))
	DECLARE @OldCommMemberTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, Comm DECIMAL(9,8))

	SELECT @ErrCode = 0, @_CommSetting = @CommSetting, @_BetSetting = @BetSetting
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId

	IF @_BetSetting IS NULL OR @_CommSetting IS NULL
		RETURN

	---------------------------
	-- ***Check Downline Belonging***
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0) RETURN
	
	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
		@custid		= @custid
		,@ErrCode	= @ErrCode OUTPUT
		,@ErrMsg	= @ErrMsg OUTPUT
		
	IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END
	--end

	---- Checking total downlines before update 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= @roleid
        ,@isExecRep		= 1
        ,@isUpdatePT	= 0
        ,@Sporttype		= 1
        ,@Language		= @Language
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
        
    IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 

	EXEC dbo.CS_CustSetting_CommBetSetting_Check
		@RoleId			= @RoleId,
		@CustID			= @CustID,
		@CommSetting	= @CommSetting,
		@BetSetting		= @BetSetting,
		@ProductID		= @ProductID,
		@IsTest			= @IsTest,
		@ErrCode		= @ErrCode OUTPUT,
		@MsgType		= @MsgType OUTPUT,
		@ErrMsg			= @ErrMsg OUTPUT
	IF @ErrCode > 0
		RETURN

    SET @startRun = GETDATE()

	/********************************************* Comm & BetSetting: SettingType = 2 ***********************************/
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t	

	---------------------Start BetSetting--------------------------------------
	SELECT bs.* INTO #BetSetting_tmp
	FROM dbo.f_CS_BetSettingParse(@_BetSetting) bs
		INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive	

	IF @RoleID = 1
	BEGIN				
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.IsLive
			, bl.MaxBet
			, bl.MaxPerEvent
		FROM dbo.CS_CustBetSetting_Member bl WITH (NOLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= bl.sporttype AND tmp.BetType = bl.bettype AND tmp.IsLive = bl.IsLive
		WHERE bl.custid = @CustID

		--update bet settings
		UPDATE main
		SET main.maxbet			= tmp.MaxBet, 
			main.MaxPerEvent	= tmp.MaxPerEvent
		FROM dbo.CS_CustBetSetting_Member main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= main.sporttype AND tmp.BetType = main.bettype AND tmp.IsLive = main.IsLive
		WHERE main.custid = @CustID
			AND (main.maxbet <> tmp.MaxBet OR main.MaxPerEvent <> tmp.MaxPerEvent)
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.IsLive
			, bl.MaxBet
			, bl.MaxPerEvent
		FROM dbo.CS_CustBetSetting_Agent bl WITH (NOLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= bl.sporttype AND tmp.BetType = bl.bettype AND tmp.IsLive = bl.IsLive
		WHERE bl.custid = @CustID

		--update new settings
		UPDATE main
		SET main.maxbet			= tmp.MaxBet, 
			main.MaxPerEvent	= tmp.MaxPerEvent
		FROM dbo.CS_CustBetSetting_Agent main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= main.sporttype AND tmp.BetType = main.bettype AND tmp.IsLive = main.IsLive
		WHERE main.custid = @CustID
			AND (main.maxbet <> tmp.MaxBet OR main.MaxPerEvent <> tmp.MaxPerEvent)		
	END
	---------------------End BetSetting--------------------------------------

	---------------------Start CommSetting--------------------------------------
	SELECT cm.* INTO #CommSetting_tmp
	FROM dbo.f_CS_CommParse(@_CommSetting) cm
		INNER JOIN #SportBettypeFilter2 ft ON cm.SportType = ft.SportType AND cm.BetType = ft.BetType AND cm.IsLive = ft.IsLive	

	IF @RoleID = 1
	BEGIN		
		SELECT @IsGroupComm = IsGroupComm FROM dbo.CS_CustSettingMode WITH (NOLOCK) WHERE CustId = @CustID
		SELECT @uGroup = uGroup FROM Customer WITH (NOLOCK) WHERE custid = @CustID

		IF @IsGroupComm = 1
		BEGIN			
			SELECT cm.* INTO #CommGroupMem_tmp
			FROM #CommSetting_tmp cm
				INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = cm.ValueId
				INNER JOIN dbo.f_CS_GetGroupDiscount_Member(@AgentId) cs ON cs.sporttype = cm.SportType AND cs.bettype = cm.BetType AND cs.isLive = cm.IsLive
			WHERE cs.PlayerDiscount <> ct.Value AND cs.uGroup = @uGroup

			INSERT INTO @OldCommMemberTbl(SportType, BetType, IsLive, Comm)
			SELECT cm.SportType, cm.BetType, cm.IsLive, cm.PlayerDiscount
			FROM dbo.f_CS_GetGroupDiscount_Member(@AgentId) cm
				INNER JOIN #CommSetting_tmp tmp ON tmp.SportType = cm.sporttype AND tmp.BetType = cm.bettype AND tmp.IsLive = cm.isLive
			WHERE cm.uGroup = @uGroup

			SET @PlayerDiscount_XML =(
										SELECT (
												SELECT	bs.ByteOrder	AS '@pos',
														comm.ValueId	AS '@val'
												FROM #CommGroupMem_tmp comm
													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
												WHERE bs.Type = 'DiscountMember'
												FOR XML PATH('r')
													, TYPE
												)
										FOR XML PATH('root')
											, TYPE
										)
			
			SELECT @MemCommGroup = COUNT(1) 
			FROM CS_CustSettingMode sm WITH (NOLOCK) 
				INNER JOIN customer c WITH (NOLOCK) ON c.custid = sm.CustID 
			WHERE c.recommend = @AgentId AND c.roleid = 1 AND sm.IsGroupComm = 1 AND c.ugroup = @uGroup 

			IF @MemCommGroup = 1 -- only one member is using this group comm
			BEGIN
				UPDATE cm
				SET cm.PlayerDiscount = playercomm.binaryStr_new
				FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
					CROSS APPLY dbo.f_SetBinaryValues(cm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
				WHERE cm.AgentId = @AgentId AND cm.uGroup = @uGroup
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.CS_CustDiscount_Member WITH (NOLOCK) WHERE CustId = @CustID)
				BEGIN
					UPDATE cm
					SET cm.PlayerDiscount = playercomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						CROSS JOIN dbo.CS_CustGroupDiscount_Member gm WITH (NOLOCK) 
						CROSS APPLY dbo.f_SetBinaryValues(gm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
					WHERE cm.CustId = @CustID AND gm.AgentId = @AgentId AND gm.uGroup = @uGroup				
				END
				ELSE
				BEGIN
					INSERT INTO CS_CustDiscount_Member (CustId, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
					SELECT @CustID, playercomm.binaryStr_new, gm.AgentDiscount, gm.MasterDiscount, gm.SuperDiscount
					FROM dbo.CS_CustGroupDiscount_Member gm WITH (NOLOCK) 
						CROSS APPLY dbo.f_SetBinaryValues(gm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
					WHERE gm.AgentId = @AgentId AND gm.uGroup = @uGroup
				END

				UPDATE cm
				SET cm.IsGroupComm = 0
				FROM dbo.CS_CustSettingMode cm WITH (ROWLOCK)
				WHERE cm.CustId = @CustID
			END

			DROP TABLE #CommGroupMem_tmp
		END
		ELSE
		BEGIN
			SELECT cm.* INTO #CommMem_tmp
			FROM #CommSetting_tmp cm
				INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = cm.ValueId
				INNER JOIN dbo.f_CS_GetDiscount_Member(@CustID) cs ON cs.sporttype = cm.SportType AND cs.bettype = cm.BetType AND cs.isLive = cm.IsLive
			WHERE cs.PlayerDiscount <> ct.Value

			INSERT INTO @OldCommMemberTbl(SportType, BetType, IsLive, Comm)
			SELECT cm.SportType, cm.BetType, cm.IsLive, PlayerDiscount
			FROM dbo.f_CS_GetDiscount_Member(@CustID) cm
				INNER JOIN #CommSetting_tmp tmp ON tmp.SportType = cm.sporttype AND tmp.BetType = cm.bettype AND tmp.IsLive = cm.isLive

			SET @PlayerDiscount_XML =(
										SELECT (
												SELECT	bs.ByteOrder	AS '@pos',
														comm.ValueId	AS '@val'
												FROM #CommMem_tmp comm
													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
												WHERE bs.Type = 'DiscountMember'
												FOR XML PATH('r')
													, TYPE
												)
										FOR XML PATH('root')
											, TYPE
										)

			UPDATE cm
			SET cm.PlayerDiscount = playercomm.binaryStr_new
			FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
				CROSS APPLY dbo.f_SetBinaryValues(cm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
			WHERE cm.CustId = @CustID

			DROP TABLE #CommMem_tmp
		END				
	END
	ELSE IF @RoleID IN (2,3,4)
	BEGIN
		SELECT cm.* INTO #CommSMA_tmp
		FROM #CommSetting_tmp cm
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) cs ON cs.sporttype = cm.SportType AND cs.bettype = cm.BetType AND cs.isLive = cm.IsLive AND cs.groupID = cm.GroupId
		WHERE cm.ValueId <> cs.ValueId

		INSERT INTO @OldCommSMATbl(SportType, BetType, IsLive)
		SELECT DISTINCT SportType, BetType, IsLive
		FROM #CommSetting_tmp

		UPDATE l
		SET l.GroupA = t.Discount
		FROM @OldCommSMATbl l
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'A'

		UPDATE l
		SET l.GroupB = t.Discount
		FROM @OldCommSMATbl l
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'B'

		UPDATE l
		SET l.GroupC = t.Discount
		FROM @OldCommSMATbl l
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'C'

		UPDATE l
		SET l.GroupD = t.Discount
		FROM @OldCommSMATbl l
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'D'

		UPDATE l
		SET l.Comm = t.Discount
		FROM @OldCommSMATbl l
			INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive	
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupId IS NULL

		INSERT INTO @NewCommSMATbl(SportType, BetType, IsLive)
		SELECT DISTINCT SportType, BetType, IsLive
		FROM #CommSetting_tmp

		UPDATE l
		SET l.GroupA = ct.Value
		FROM @NewCommSMATbl l
			INNER JOIN #CommSetting_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive
			INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'A'

		UPDATE l
		SET l.GroupB = ct.Value
		FROM @NewCommSMATbl l
			INNER JOIN #CommSetting_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive
			INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'B'

		UPDATE l
		SET l.GroupC = ct.Value
		FROM @NewCommSMATbl l
			INNER JOIN #CommSetting_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive
			INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'C'

		UPDATE l
		SET l.GroupD = ct.Value
		FROM @NewCommSMATbl l
			INNER JOIN #CommSetting_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive
			INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupName = 'D'

		UPDATE l
		SET l.Comm = ct.Value
		FROM @NewCommSMATbl l
			INNER JOIN #CommSetting_tmp t ON t.SportType = l.SportType AND t.BetType = l.BetType AND t.IsLive = l.IsLive
			INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = t.ValueId
			LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = t.SportType AND gc.BetType = t.BetType AND gc.IsLive = t.IsLive AND gc.GroupId = t.GroupId
		WHERE gc.GroupId IS NULL

		SET @Discount_XML =(
								SELECT (
										SELECT	bs.ByteOrder	AS '@pos',
												comm.ValueId	AS '@val'
										FROM #CommSMA_tmp comm
											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
										WHERE bs.Type = 'DiscountAgent'
										FOR XML PATH('r')
											, TYPE
										)
								FOR XML PATH('root')
									, TYPE
								)		
								
		EXEC dbo.CS_DynamicCustSetting_00
			@RoleId			= @RoleId,
			@CustID			= @CustID,
			@CommSetting	= @CommSetting,
			@ProductID		= @ProductID,
			@IsTest			= @IsTest,
			@SettingType	= 2
				
		UPDATE ca
		SET ca.Discount = comm.binaryStr_new
		FROM dbo.CS_CustDiscount_Agent ca WITH (ROWLOCK)
			CROSS APPLY dbo.f_SetBinaryValues(ca.Discount, @Discount_XML) comm	
		WHERE ca.CustId = @CustID		

		DROP TABLE #CommSMA_tmp
	END

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)
	---------------------End CommSetting--------------------------------------
	
	------------------Write log
	SELECT @SPName = dbo.f_CS_GetSPNameByEnvironment('CS_CustSetting_CommBetSetting_Upd') --Use this tip to pass GOSQL deploy tool

	-- Select ProductID and SettingLevel
	SELECT @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM CS_ProductSettingDetail AS psd WITH(NOLOCK)
				INNER JOIN #BetSetting_tmp AS tmp ON psd.SportType = tmp.SportType AND	psd.BetType = tmp.BetType AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 2	-- Comm & BetSetting
		 ) iq
	
	----------------------Log BetSetting
	-- Log old data
	IF @SettingLevel = 1 -- Product setting level
	BEGIN
		SET @xml_Old = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  @ProductID														AS '@ProductID'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM @OldBetLimitTbl cs 
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml_Old = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM @OldBetLimitTbl cs
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml_Old = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.bettype														AS '@BT'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM @OldBetLimitTbl cs 
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)					
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml_Old = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport'
											, cs.bettype													AS '@BT'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM @OldBetLimitTbl cs
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END		
	
	-- Log new data
	IF @SettingLevel = 1 -- Product setting level
	BEGIN
		SET @xml = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  @ProductID														AS '@ProductID'
											, bs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM #BetSetting_tmp bs WITH (NOLOCK)
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM #BetSetting_tmp cs WITH (NOLOCK)
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.bettype														AS '@BT'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM #BetSetting_tmp cs WITH (NOLOCK)
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)					
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport'
											, cs.bettype													AS '@BT'
											, cs.isLive														AS '@InPlay'
											, dbo.f_CS_FomatNumber (CAST (MaxBet AS VARCHAR(50)))			AS '@Max'
											, dbo.f_CS_FomatNumber (CAST (MaxPerEvent AS VARCHAR(50)))		AS '@MPE'
									FROM #BetSetting_tmp cs WITH (NOLOCK)
									FOR XML PATH('C'), 
									TYPE
								)
						FOR XML PATH('R'), 
						TYPE
						)
	END	

	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml_Old), '" />', '"/"')	
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')	

	SELECT @ActionId = l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID = @ProductID AND ld.Level = @RoleID AND l.ActionTypeID = 3
				
	EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = @ActionId,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @logSPData_Old,
		@duration = @duration

	----------------------Log Comm
	IF @RoleId IN (2,3,4)
	BEGIN
		-- Log old data
		IF @SettingLevel = 1 -- Product setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  @ProductID														AS '@ProductID'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.bettype														AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)					
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.bettype													AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END		
	
		-- Log new data
		IF @SettingLevel = 1 -- Product setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  @ProductID														AS '@ProductID'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @NewCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @NewCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.bettype														AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @NewCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)					
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.bettype													AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupA AS VARCHAR(50)))		AS '@GrA'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupB AS VARCHAR(50)))		AS '@GrB'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupC AS VARCHAR(50)))		AS '@GrC'
												, dbo.f_CS_FomatNumber (CAST (cs.GroupD AS VARCHAR(50)))		AS '@GrD'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @NewCommSMATbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END	
	END
	ELSE
	BEGIN
		-- Log old data
		IF @SettingLevel = 1 -- Product setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID														AS '@ProductID'
									, dbo.f_GetSubUsername(@SubAccID)								AS '@SubAcc'
									, @IP															AS '@IP'
									, cs.isLive														AS '@InPlay'
									, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
							FROM @OldCommMemberTbl cs 
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommMemberTbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.bettype														AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommMemberTbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)					
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.bettype													AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (cs.Comm AS VARCHAR(50)))			AS '@Comm'
										FROM @OldCommMemberTbl cs 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END		
	
		-- Log new data
		IF @SettingLevel = 1 -- Product setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID														AS '@ProductID'
									, dbo.f_GetSubUsername(@SubAccID)								AS '@SubAcc'
									, @IP															AS '@IP'
									, cs.isLive														AS '@InPlay'
									, dbo.f_CS_FomatNumber (CAST (ct.Value AS VARCHAR(50)))			AS '@Comm'
							FROM #CommSetting_tmp cs 
								INNER JOIN CS_CommTemplate ct ON cs.ValueId = ct.ValueId
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (ct.Value AS VARCHAR(50)))			AS '@Comm'
										FROM #CommSetting_tmp cs 
											INNER JOIN CS_CommTemplate ct ON cs.ValueId = ct.ValueId 
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.bettype														AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (ct.Value AS VARCHAR(50)))			AS '@Comm'
										FROM #CommSetting_tmp cs 
											INNER JOIN CS_CommTemplate ct ON cs.ValueId = ct.ValueId
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)					
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml = (
							SELECT  @ProductID						AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID) AS '@SubAcc',
									@IP                             AS '@IP',
									(
										SELECT  cs.sporttype													AS '@Sport'
												, cs.bettype													AS '@BT'
												, cs.isLive														AS '@InPlay'
												, dbo.f_CS_FomatNumber (CAST (ct.Value AS VARCHAR(50)))			AS '@Comm'
										FROM #CommSetting_tmp cs 
											INNER JOIN CS_CommTemplate ct ON cs.ValueId = ct.ValueId
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END	
	END

	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml_Old), '" />', '"/"')	
	SET @logSpData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')		

	SELECT @ActionId = l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID = @ProductID AND ld.Level = @RoleID AND l.ActionTypeID = 2
				
	EXEC dbo.CS_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = @ActionId,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @logSPData_Old,
		@duration = @duration

	DROP TABLE #BetSetting_tmp	
	DROP TABLE #CommSetting_tmp	
	DROP TABLE #SportBettypeFilter2
	
END
GO
