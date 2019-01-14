/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

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
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME,@endRun DATETIME, @duration INT, @ActionId INT, @logSPData VARCHAR(MAX),@logSPData_Old VARCHAR(MAX), @ErrType XML
	DECLARE @_CommSetting XML, @_BetSetting XML, @xml XML, @xml_Old XML, @IsGroupComm BIT
	DECLARE @Discount_XML XML, @PlayerDiscount_XML XML, @AgentDiscount_XML XML, @MasterDiscount_XML XML, @SuperDiscount_XML XML
	DECLARE @GroupADiscount_XML XML, @GroupBDiscount_XML XML, @GroupCDiscount_XML XML, @GroupDDiscount_XML XML
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @uGroup VARCHAR(3), @SettingLevel TINYINT
	DECLARE @OldBetLimitTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, MaxBet MONEY, MaxPerMatch MONEY)
	DECLARE @OldCommSMATbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, GroupA DECIMAL(9,8), GroupB DECIMAL(9,8), GroupC DECIMAL(9,8), GroupD DECIMAL(9,8), Comm DECIMAL(9,8))
	DECLARE @OldCommMemberTbl TABLE (SportType SMALLINT, BetType SMALLINT, IsLive BIT, Comm DECIMAL(9,8))
	DECLARE @DownlineGroupComm TABLE (AgentId INT, uGroup VARCHAR(3), NumOfMember INT)

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
			, bl.MaxPerMatch
		FROM dbo.CS_CustBetSetting_Member bl WITH (NOLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= bl.sporttype AND tmp.BetType = bl.bettype AND tmp.IsLive = bl.IsLive
		WHERE bl.custid = @CustID

		--update bet settings
		UPDATE main
		SET main.maxbet			= tmp.MaxBet, 
			main.maxpermatch	= tmp.MaxperMatch
		FROM dbo.CS_CustBetSetting_Member main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= main.sporttype AND tmp.BetType = main.bettype AND tmp.IsLive = main.IsLive
		WHERE main.custid = @CustID
			AND (main.maxbet <> tmp.MaxBet OR main.maxpermatch <> tmp.MaxperMatch)
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		--get old settings
		INSERT INTO @OldBetLimitTbl
		SELECT bl.SportType
			, bl.BetType
			, bl.IsLive
			, bl.MaxBet
			, bl.MaxPerMatch
		FROM dbo.CS_CustBetSetting_Agent bl WITH (NOLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= bl.sporttype AND tmp.BetType = bl.bettype AND tmp.IsLive = bl.IsLive
		WHERE bl.custid = @CustID

		--update new settings
		UPDATE main
		SET main.maxbet			= tmp.MaxBet, 
			main.maxpermatch	= tmp.MaxperMatch
		FROM dbo.CS_CustBetSetting_Agent main WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #BetSetting_tmp tmp ON tmp.SportType	= main.sporttype AND tmp.BetType = main.bettype AND tmp.IsLive = main.IsLive
		WHERE main.custid = @CustID
			AND (main.maxbet <> tmp.MaxBet OR main.maxpermatch <> tmp.MaxperMatch)		
	END
	---------------------End BetSetting--------------------------------------

	---------------------Start CommSetting--------------------------------------
	SELECT cm.* INTO #CommSetting_tmp
	FROM dbo.f_CS_CommParse(@_CommSetting) cm
		INNER JOIN #SportBettypeFilter2 ft ON cm.SportType = ft.SportType AND cm.BetType = ft.BetType AND cm.IsLive = ft.IsLive	

	IF @RoleID = 1
	BEGIN		
		SELECT @IsGroupComm = IsGroupComm FROM dbo.CS_CustSettingMode WITH (NOLOCK) WHERE CustId = @CustID
		
		IF @IsGroupComm = 1
		BEGIN			
			SELECT cm.* INTO #CommGroupMem_tmp
			FROM #CommSetting_tmp cm
				INNER JOIN dbo.CS_CommTemplate ct ON ct.ValueId = cm.ValueId
				INNER JOIN dbo.f_CS_GetGroupDiscount_Member(@CustID) cs ON cs.sporttype = cm.SportType AND cs.bettype = cm.BetType AND cs.isLive = cm.IsLive
			WHERE cs.PlayerDiscount <> ct.Value

			INSERT INTO @OldCommMemberTbl(SportType, BetType, IsLive, Comm)
			SELECT cm.SportType, cm.BetType, cm.IsLive, cm.PlayerDiscount
			FROM dbo.f_CS_GetGroupDiscount_Member(@CustID) cm
				LEFT JOIN #CommSetting_tmp tmp ON tmp.SportType = cm.sporttype AND tmp.BetType = cm.bettype AND tmp.IsLive = cm.isLive

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
			IF EXISTS (SELECT 1 FROM dbo.CS_CustDiscount_Member WITH (NOLOCK) WHERE CustId = @CustID)
			BEGIN
				UPDATE cm
				SET cm.PlayerDiscount = playercomm.binaryStr_new
				FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
					CROSS JOIN dbo.CS_CustGroupDiscount_Member gm WITH (NOLOCK) 
					CROSS APPLY dbo.f_SetBinaryValues(gm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
				WHERE cm.CustId = @CustID AND gm.AgentId = @AgentId				
			END
			ELSE
			BEGIN
				INSERT INTO CS_CustDiscount_Member (CustId, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
				SELECT @CustID, playercomm.binaryStr_new, gm.AgentDiscount, gm.MasterDiscount, gm.SuperDiscount
				FROM dbo.CS_CustGroupDiscount_Member gm WITH (NOLOCK) 
					CROSS APPLY dbo.f_SetBinaryValues(gm.PlayerDiscount, @PlayerDiscount_XML) playercomm	
				WHERE gm.AgentId = @AgentId
			END

			UPDATE cm
			SET cm.IsGroupComm = 0
			FROM dbo.CS_CustSettingMode cm WITH (ROWLOCK)
			WHERE cm.CustId = @CustID
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
		
		SET @GroupADiscount_XML =(
								SELECT (
										SELECT	bs.ByteOrder	AS '@pos',
												comm.ValueId	AS '@val'
										FROM #CommSMA_tmp comm
											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
											LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = comm.SportType AND gc.BetType = comm.BetType AND gc.IsLive = comm.IsLive AND gc.GroupId = comm.GroupId
										WHERE bs.Type = 'DiscountMember'
											AND (gc.GroupName = 'A' OR gc.GroupId IS NULL)
										FOR XML PATH('r')
											, TYPE
										)
								FOR XML PATH('root')
									, TYPE
								)	
								
		SET @GroupBDiscount_XML =(
								SELECT (
										SELECT	bs.ByteOrder	AS '@pos',
												comm.ValueId	AS '@val'
										FROM #CommSMA_tmp comm
											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
											LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = comm.SportType AND gc.BetType = comm.BetType AND gc.IsLive = comm.IsLive AND gc.GroupId = comm.GroupId
										WHERE bs.Type = 'DiscountMember'
											AND (gc.GroupName = 'B' OR gc.GroupId IS NULL)
										FOR XML PATH('r')
											, TYPE
										)
								FOR XML PATH('root')
									, TYPE
								)			
		
		SET @GroupCDiscount_XML =(
								SELECT (
										SELECT	bs.ByteOrder	AS '@pos',
												comm.ValueId	AS '@val'
										FROM #CommSMA_tmp comm
											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
											LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = comm.SportType AND gc.BetType = comm.BetType AND gc.IsLive = comm.IsLive AND gc.GroupId = comm.GroupId
										WHERE bs.Type = 'DiscountMember'
											AND (gc.GroupName = 'C' OR gc.GroupId IS NULL)
										FOR XML PATH('r')
											, TYPE
										)
								FOR XML PATH('root')
									, TYPE
								)		
		SET @GroupDDiscount_XML =(
								SELECT (
										SELECT	bs.ByteOrder	AS '@pos',
												comm.ValueId	AS '@val'
										FROM #CommSMA_tmp comm
											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
											LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = comm.SportType AND gc.BetType = comm.BetType AND gc.IsLive = comm.IsLive AND gc.GroupId = comm.GroupId
										WHERE bs.Type = 'DiscountMember'
											AND (gc.GroupName = 'D' OR gc.GroupId IS NULL)
										FOR XML PATH('r')
											, TYPE
										)
								FOR XML PATH('root')
									, TYPE
								)		

		UPDATE ca
		SET ca.Discount = comm.binaryStr_new
		FROM dbo.CS_CustDiscount_Agent ca WITH (ROWLOCK)
			CROSS APPLY dbo.f_SetBinaryValues(ca.Discount, @Discount_XML) comm	
		WHERE ca.CustId = @CustID

		IF @RoleId = 2
		BEGIN
			IF @GroupADiscount_XML IS NULL OR @GroupADiscount_XML = ''
			BEGIN
				UPDATE cm
				SET cm.AgentDiscount = acomm.binaryStr_new
				FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
					INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
					CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupADiscount_XML) acomm	
				WHERE c.recommend = @CustID AND c.ugroup = 'CNA'
			END
			
			IF @GroupBDiscount_XML IS NULL OR @GroupBDiscount_XML = ''
			BEGIN
				UPDATE cm
				SET cm.AgentDiscount = acomm.binaryStr_new
				FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
					INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
					CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupBDiscount_XML) acomm	
				WHERE c.recommend = @CustID AND c.ugroup = 'CNB'
			END

			IF @GroupCDiscount_XML IS NULL OR @GroupCDiscount_XML = ''
			BEGIN
				UPDATE cm
				SET cm.AgentDiscount = acomm.binaryStr_new
				FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
					INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
					CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupCDiscount_XML) acomm	
				WHERE c.recommend = @CustID AND c.ugroup = 'CNC'
			END

			IF @GroupDDiscount_XML IS NULL OR @GroupDDiscount_XML = ''
			BEGIN
				UPDATE cm
				SET cm.AgentDiscount = acomm.binaryStr_new
				FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
					INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
					CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupDDiscount_XML) acomm	
				WHERE c.recommend = @CustID AND c.ugroup = 'CND'
			END

			INSERT INTO @DownlineGroupComm (AgentId, uGroup, NumOfMember)
			SELECT @CustID, c.ugroup, COUNT(1)
			FROM dbo.CS_CustSettingMode cs WITH (NOLOCK)
				INNER JOIN Customer c WITH (NOLOCK) ON c.custid = cs.CustId
			WHERE c.recommend = @CustID AND c.roleid = 1 AND cs.IsGroupComm = 1
			GROUP BY uGroup
		END
		
	END
	---------------------End CommSetting--------------------------------------

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM CS_ProductSettingDetail AS psd WITH(NOLOCK)
				INNER JOIN #BetSetting_tmp AS tmp ON psd.SportType = tmp.SportType AND	psd.BetType = tmp.BetType AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 2	-- Comm & BetSetting
		 ) iq
	
	--Update BetSetting
	-- Log old data
	IF @SettingLevel = 1 -- Product setting level
	BEGIN
		SET @xml_Old = (
						SELECT  @ProductID						AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
								@IP                             AS '@IP',
								(
									SELECT  @ProductID														AS '@ProductID'
											--CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPT',
											--CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPT'
									FROM dbo.CS_CustBetSetting_Agent bs WITH (NOLOCK)
										INNER
									WHERE bs.CustId = @CustID
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
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport',
											cs.isLive														AS '@IsL',
											CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPT',
											CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPT'
									FROM dbo.f_CS_GetPT_Agent(@CustID) cs
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
								@IP                             AS '@IP',
								(
									SELECT  cs.bettype														AS '@BT',
											cs.isLive														AS '@IsL',
											CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPT',
											CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPT'
									FROM dbo.f_CS_GetPT_Agent(@CustID) cs
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
								@IP                             AS '@IP',
								(
									SELECT  cs.sporttype													AS '@Sport',
											cs.bettype														AS '@BT',
											cs.isLive														AS '@IsL',
											CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPT',
											CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPT'
									FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											FOR XML PATH('C'), 
											TYPE
										)
								FOR XML PATH('R'), 
								TYPE
						)
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
		
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(mb.MaxCommDownline,0) AS MinComm, CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END AS MaxComm,
			sc.Discount AS Comm,
			ISNULL(mb.MaxMaxBetDownline,0) AS MinMaxBet, ISNULL(mb.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch,
			sb.MaxBet AS MaxBet, sb.MaxPerMatch AS MaxPerMatch
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter2 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) sc ON sc.SportType = ft.SportType AND sc.BetType = ft.BetType AND sc.IsLive = ft.IsLive			
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive 
			LEFT JOIN #Downlines4 mb ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive AND sc.groupID = mb.groupID
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND  gc.GroupId = sc.GroupId
		WHERE sb.CustId = @CustID
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ab.sporttype, ab.bettype, ab.Islive, ac.groupID, 
			MAX(ab.MaxBet) AS MaxMaxBetDownline, MAX(ab.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(ac.Discount) AS MaxCommDownline
		INTO #Downlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) ac
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.CustId = ci.custid AND ab.SportType = ac.sporttype AND ab.BetType = ac.bettype AND ab.IsLive = ac.isLive
			INNER JOIN #SportBettypeFilter2 ft ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY ab.sporttype, ab.bettype, ab.Islive, ac.groupID

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(ab.MaxCommDownline,0) AS MinComm, sc.Discount AS MaxComm, mc.Discount AS Comm,
			ISNULL(ab.MaxMaxBetDownline,0) AS MinMaxBet, sb.MaxBet AS MaxMaxBet,
			ISNULL(ab.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch, sb.MaxPerMatch AS MaxMaxPerMatch,
			mb.MaxBet AS MaxBet, mb.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@SuperId) sc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) mc ON mc.sporttype = sc.sporttype AND mc.bettype = sc.bettype AND mc.isLive = sc.isLive AND mc.groupID = sc.groupID
			INNER JOIN #SportBettypeFilter2 ft ON sc.SportType = ft.SportType AND sc.BetType = ft.BetType AND sc.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent mb ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive 
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive 
			LEFT JOIN #Downlines3 ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive AND sc.groupID = ab.groupID
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive  AND gc.GroupId = sc.GroupId
		WHERE mb.CustId = @CustID AND sb.CustId = @SuperId
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT memb.sporttype, memb.bettype, memb.Islive, gc.GroupId,
			MAX(memb.MaxBet) AS MaxMaxBetDownline, MAX(memb.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #Downlines2
		FROM dbo.customer c WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Member(c.custid) memc 
			INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.CustId = c.custid AND memb.SportType = memc.sporttype AND memb.BetType = memc.bettype AND memb.IsLive = memc.isLive
			INNER JOIN #SportBettypeFilter2 ft ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustId AND c.roleid = 1
		GROUP BY memb.sporttype, memb.bettype, memb.Islive, gc.GroupId
		
		SELECT memc.sporttype, memc.bettype, memc.Islive, gc.GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #GroupDownlines2
		FROM dbo.f_CS_GetGroupDiscount_Member(@CustID) memc  
			CROSS JOIN dbo.customer c WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustSettingMode cm WITH (NOLOCK) ON cm.CustId = c.custid 			
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustID AND c.roleid = 1 AND cm.IsGroupComm = 1
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			CASE WHEN ISNULL(memb.MaxCommDownline,0) > ISNULL(dlg.MaxCommDownline,0) THEN ISNULL(memb.MaxCommDownline,0) ELSE ISNULL(dlg.MaxCommDownline,0) END AS MinComm, 
			mc.Discount AS MaxComm, ac.Discount AS Comm,
			ISNULL(memb.MaxMaxBetDownline,0) AS MinMaxBet, mb.MaxBet AS MaxMaxBet, 
			ISNULL(memb.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch, mb.MaxPerMatch AS MaxMaxPerMatch,
			ab.MaxBet AS MaxBet, ab.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@MasterId) mc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) ac ON ac.sporttype = mc.sporttype AND ac.bettype = mc.bettype AND ac.isLive = mc.isLive AND ac.groupID = mc.groupID
			INNER JOIN #SportBettypeFilter2 ft ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			LEFT JOIN #Downlines2 memb ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive AND mc.groupID = memb.GroupId
			LEFT JOIN #GroupDownlines2 dlg ON dlg.SportType = ft.SportType AND dlg.BetType = ft.BetType AND dlg.IsLive = ft.IsLive AND mc.groupID = dlg.GroupId
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = mc.GroupId
		WHERE ab.CustId = @CustID AND mb.CustId = @MasterId
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT @uGroup = ugroup FROM dbo.customer WITH (NOLOCK) WHERE custid = @CustID
		
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, ac.Discount AS MaxComm, memc.PlayerDiscount AS Comm,
			0 AS MinMaxBet, ab.MaxBet AS MaxMaxBet,
			0 AS MinMaxPerMatch, ab.MaxPerMatch AS MaxMaxPerMatch,
			memb.MaxBet AS MaxBet, memb.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@AgentId) ac
			INNER JOIN dbo.f_CS_GetDiscount_Member(@CustID) memc ON memc.sporttype = ac.sporttype AND memc.bettype = ac.bettype AND memc.isLive = ac.isLive
			INNER JOIN #SportBettypeFilter2 ft ON ac.SportType = ft.SportType AND ac.BetType = ft.BetType AND ac.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = ac.GroupId 
		WHERE (gc.uGroup = @uGroup OR gc.GroupId IS NULL) AND ab.CustId = @AgentId AND memb.CustId = @CustID
	END
END
GO
