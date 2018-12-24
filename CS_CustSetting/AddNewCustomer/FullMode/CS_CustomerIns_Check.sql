/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[CS_CustomerIns_Check] 
	@UplineID		INT = NULL,	
	@ProductID		TINYINT = 1,
	@PTSetting		VARCHAR(MAX) = NULL,
	@BetSetting		VARCHAR(MAX) = NULL,
	@CommSetting	VARCHAR(MAX) = NULL,
	@uGroup			VARCHAR(3) = NULL,
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Check CS Settings
	DB:  DBCUST/CustDB
	Original:
	
	Revision
		- 20181212@Elodie: Initial SP [Redmine: #105338]

	Param's Explanation:
		@RoleID = 4:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MinPT="20" MaxPT = "80"/>
						</ROOT>
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
		@RoleID = 3:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" SuperPT="10"/>
						</ROOT>
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
		@RoleID = 2:
			@PTSetting: <ROOT>
							<PT SportType="1" BetType="1" IsLive="0" MasterPT="20" AgentPT = "50"/>
						</ROOT>
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
		@RoleID = 1:			
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
	DECLARE @MinPT_XML XML, @MaxPT_XML XML, @SuperPT_XML XML, @MasterPT_XML XML, @AgentPT_XML XML
	DECLARE @Discount_XML XML, @PlayerDiscount_XML XML, @AgentDiscount_XML XML, @MasterDiscount_XML XML, @SuperDiscount_XML XML
	DECLARE @_PTSetting XML, @_BetSetting XML, @_CommSetting XML
	DECLARE @SuperID INT, @MasterID INT, @AgentID INT, @RoleID TINYINT

	SELECT @ErrCode = 0, @_PTSetting = @PTSetting, @_BetSetting = @BetSetting, @_CommSetting = @CommSetting
	IF @UplineID IS NOT NULL
		SELECT @SuperID = srecommend, @MasterID = mrecommend, @AgentID = recommend, @RoleID = roleid - 1 FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @UplineID
	
	--IF(dbo.f_CheckRepTable('CS_CustPTSetting_Agent') = 1
	--	AND dbo.f_CheckRepTable('CS_CustPTSetting_Member') = 1
	--	AND dbo.f_CheckRepTable('CS_CustPTGroupSetting_Member ') = 1
	--	AND dbo.f_CheckRepTable('CS_CustSettingMode') = 1
	--	AND dbo.f_CheckRepTable('CS_CustBetSetting_Agent') = 1
	--	AND dbo.f_CheckRepTable('CS_CustBetSetting_Member') = 1
	--	AND dbo.f_CheckRepTable('CS_CustDiscount_Agent') = 1
	--	AND dbo.f_CheckRepTable('CS_CustDiscount_Member') = 1
	--	AND dbo.f_CheckRepTable('CS_ProductSettingDetail') = 1 
	--   )
	-- BEGIN
	--	/********************************************* Position Taking: SettingType = 1 ***********************************/
	--	SELECT t.* INTO #SportBettypeFilter1
	--	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 1, @IsTest) t
		
	--	SELECT * INTO #PT_tmp
	--	FROM dbo.f_CS_PTParse(@_PTSetting) pt
	--		INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive

	--	BEGIN TRY
	--		IF @RoleID = 4
	--		BEGIN						
	--			SET @MinPT_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												pt.MinPT		AS '@val'
	--										FROM #PT_tmp pt
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
	--										WHERE bs.Type = 'PTSetting'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)
						
	--			SET @MaxPT_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												pt.MaxPT		AS '@val'
	--										FROM #PT_tmp pt
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
	--										WHERE bs.Type = 'PTSetting'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)
										
	--			INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
	--			SELECT 
	--				@Custid
	--				,NULL
	--				,NULL
	--				,NULL
	--				,minpt.binaryStr_new
	--				,maxpt.binaryStr_new
	--			FROM dbo.f_SetBinaryValues(0x00, @MinPT_XML) minpt
	--				CROSS APPLY dbo.f_SetBinaryValues(0x00, @MaxPT_XML) maxpt
	--		END
	--		ELSE IF @RoleID = 3
	--		BEGIN								
	--			SET @SuperPT_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												pt.SuperPT		AS '@val'
	--										FROM #PT_tmp pt
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
	--										WHERE bs.Type = 'PTSetting'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)

	--			INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
	--			SELECT 
	--				@Custid
	--				,superpt.binaryStr_new
	--				,NULL
	--				,NULL
	--				,NULL
	--				,NULL
	--			FROM dbo.f_SetBinaryValues(0x00, @SuperPT_XML) superpt

	--		END
	--		ELSE IF @RoleID = 2
	--		BEGIN				
	--			SET @MasterPT_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												pt.MasterPT		AS '@val'
	--										FROM #PT_tmp pt
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
	--										WHERE bs.Type = 'PTSetting'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)

	--			SET @AgentPT_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												pt.AgentPT		AS '@val'
	--										FROM #PT_tmp pt
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
	--										WHERE bs.Type = 'PTSetting'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)
				
	--			INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
	--			SELECT 
	--				@Custid
	--				,NULL
	--				,masterpt.binaryStr_new
	--				,agentpt.binaryStr_new
	--				,NULL
	--				,NULL
	--			FROM dbo.f_SetBinaryValues(0x00, @MasterPT_XML) masterpt
	--				CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentPT_XML) agentpt

	--			INSERT INTO dbo.CS_CustPTGroupSetting_Member (AgentId, SuperPT, MasterPT, AgentPT)							       
	--			SELECT 
	--				@CustID
	--				,cs.SuperPT
	--				,masterpt.binaryStr_new
	--				,agentpt.binaryStr_new
	--			FROM CS_CustPTSetting_Agent cs WITH (NOLOCK)
	--				CROSS APPLY dbo.f_SetBinaryValues(0x00, @MasterPT_XML) masterpt
	--				CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentPT_XML) agentpt
	--			WHERE cs.CustId = @SuperID
	--		END			
	--	END TRY
	--	BEGIN CATCH
	--		SELECT @ErrCode = 1
	--		IF @RoleID = 2
	--		BEGIN
	--			DELETE FROM dbo.CS_CustPTSetting_Agent WHERE CustID = @CustID
	--			DELETE FROM dbo.CS_CustPTGroupSetting_Member WHERE AgentId = @CustID
	--		END
	--		ELSE
	--		BEGIN
	--			DELETE FROM dbo.CS_CustPTSetting_Agent WHERE CustID = @CustID
	--		END
	--		RETURN
	--	END CATCH

	--	/********************************************* Commission & Bet Setting : SettingType = 2 ****************************************/	
	--	SELECT t.* INTO #SportBettypeFilter2
	--	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t			
	
	--	SELECT * INTO #Comm_tmp
	--	FROM dbo.f_CS_CommParse(@_CommSetting) comm
	--		INNER JOIN #SportBettypeFilter2 ft ON comm.SportType = ft.SportType AND comm.BetType = ft.BetType AND comm.IsLive = ft.IsLive

	--	BEGIN TRY
	--		IF @RoleID IN (4,3,2)
	--		BEGIN
	--			INSERT INTO dbo.CS_CustBetSetting_Agent (CustId, SportType, BetType, IsLive, MaxBet, MaxPerMatch)
	--			SELECT @CustID, cs.SportType, cs.BetType, cs.IsLive, MaxBet, MaxPerMatch
	--			FROM f_CS_BetSettingParse(@_BetSetting) cs
	--				INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive

	--			SET @Discount_XML =(
	--								SELECT (
	--										SELECT	bs.ByteOrder	AS '@pos',
	--												comm.ValueId	AS '@val'
	--										FROM #Comm_tmp comm
	--											INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
	--										WHERE bs.Type = 'DiscountAgent'
	--										FOR XML PATH('r')
	--											, TYPE
	--										)
	--								FOR XML PATH('root')
	--									, TYPE
	--								)
				
	--			INSERT INTO dbo.CS_CustDiscount_Agent (CustId, Discount)
	--			SELECT @CustID, comm.binaryStr_new	
	--			FROM dbo.f_SetBinaryValues(0x00, @Discount_XML) comm									
	--		END
	--		ELSE IF @RoleID = 1
	--		BEGIN					
	--			INSERT INTO dbo.CS_CustBetSetting_Member (CustId, SportType, BetType, IsLive, MaxBet, MaxPerMatch)
	--			SELECT @CustID, cs.SportType, cs.BetType, cs.IsLive, MaxBet, MaxPerMatch
	--			FROM f_CS_BetSettingParse(@_BetSetting) cs
	--				INNER JOIN #SportBettypeFilter2 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive

	--			SELECT	cs.sporttype, cs.bettype, cs.isLive, cs.groupID, cs.Discount, bs.ByteOrder, cs.Valueid INTO #AgentComm
	--			FROM f_CS_GetDiscount_Agent (@AgentID) cs
	--				INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive AND bs.GroupId = cs.groupID
	--				INNER JOIN dbo.CS_CommTemplate t WITH (NOLOCK) ON cs.Discount = t.Value
	--				LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.GroupId = bs.GroupId
	--			WHERE bs.Type = 'DiscountAgent' AND (gc.uGroup = @uGroup OR gc.GroupId IS NULL) 
					
	--			SELECT	cs.sporttype, cs.bettype, cs.isLive, cs.groupID, cs.Discount, bs.ByteOrder, cs.Valueid INTO #MasterComm
	--			FROM f_CS_GetDiscount_Agent (@MasterID) cs
	--				INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive AND bs.GroupId = cs.groupID
	--				INNER JOIN dbo.CS_CommTemplate t WITH (NOLOCK) ON cs.Discount = t.Value
	--				LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.GroupId = bs.GroupId
	--			WHERE bs.Type = 'DiscountAgent' AND (gc.uGroup = @uGroup OR gc.GroupId IS NULL)
					
	--			SELECT	cs.sporttype, cs.bettype, cs.isLive, cs.groupID, cs.Discount, bs.ByteOrder, cs.Valueid INTO #SuperComm
	--			FROM f_CS_GetDiscount_Agent (@SuperID) cs
	--				INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive AND bs.GroupId = cs.groupID
	--				INNER JOIN dbo.CS_CommTemplate t WITH (NOLOCK) ON cs.Discount = t.Value
	--				LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.GroupId = bs.GroupId
	--			WHERE bs.Type = 'DiscountAgent' AND (gc.uGroup = @uGroup OR gc.GroupId IS NULL)
														
	--			SET @PlayerDiscount_XML =(
	--										SELECT (
	--												SELECT	bs.ByteOrder	AS '@pos',
	--														comm.ValueId	AS '@val'
	--												FROM #Comm_tmp comm
	--													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
	--												WHERE bs.Type = 'DiscountMember'
	--												FOR XML PATH('r')
	--													, TYPE
	--												)
	--										FOR XML PATH('root')
	--											, TYPE
	--										)
	--			SET @AgentDiscount_XML = (
	--										SELECT (
	--												SELECT	bs.ByteOrder AS '@pos',
	--														cs.ValueId	AS '@val'
	--												FROM #AgentComm cs
	--													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive
	--												WHERE bs.Type = 'DiscountMember'
	--												FOR XML PATH('r')
	--													, TYPE
	--												)
	--										FOR XML PATH('root')
	--											, TYPE
	--										)
	--			SET @MasterDiscount_XML = (
	--										SELECT (
	--												SELECT	bs.ByteOrder AS '@pos',
	--														cs.ValueId	AS '@val'
	--												FROM #MasterComm cs
	--													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive
	--												WHERE bs.Type = 'DiscountMember'
	--												FOR XML PATH('r')
	--													, TYPE
	--												)
	--										FOR XML PATH('root')
	--											, TYPE
	--										)
	--			SET @SuperDiscount_XML = (
	--										SELECT (
	--												SELECT	bs.ByteOrder AS '@pos',
	--														cs.ValueId	AS '@val'
	--												FROM #SuperComm cs
	--													INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = cs.SportType AND bs.BetType = cs.BetType AND bs.IsLive = cs.IsLive
	--												WHERE bs.Type = 'DiscountMember'
	--												FOR XML PATH('r')
	--													, TYPE
	--												)
	--										FOR XML PATH('root')
	--											, TYPE
	--										)
	--			IF EXISTS (SELECT 1 FROM dbo.custInfo WITH (NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
	--			BEGIN
	--				IF EXISTS (	SELECT 1
	--							FROM CS_CustGroupDiscount_Member cs
	--								CROSS APPLY dbo.f_SetBinaryValues(0x00, @PlayerDiscount_XML) playercomm	
	--								CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentDiscount_XML) acomm	
	--								CROSS APPLY dbo.f_SetBinaryValues(0x00, @MasterDiscount_XML) mcomm	
	--								CROSS APPLY dbo.f_SetBinaryValues(0x00, @SuperDiscount_XML)	scomm
	--							WHERE cs.AgentId = @AgentID 
	--								AND (cs.PlayerDiscount <> playercomm.binaryStr_new
	--									OR cs.AgentDiscount <> acomm.binaryStr_new
	--									OR cs.MasterDiscount <> mcomm.binaryStr_new
	--									OR cs.SuperDiscount <> scomm.binaryStr_new)
	--							)
	--				BEGIN
	--					INSERT INTO dbo.CS_CustDiscount_Member (CustId, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
	--					SELECT @CustID, playercomm.binaryStr_new, acomm.binaryStr_new, mcomm.binaryStr_new, scomm.binaryStr_new
	--					FROM dbo.f_SetBinaryValues(0x00, @PlayerDiscount_XML) playercomm	
	--						CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentDiscount_XML) acomm	
	--						CROSS APPLY dbo.f_SetBinaryValues(0x00, @MasterDiscount_XML) mcomm	
	--						CROSS APPLY dbo.f_SetBinaryValues(0x00, @SuperDiscount_XML)	scomm

	--					INSERT INTO dbo.CS_CustSettingMode (CustId, IsGroupPT, IsGroupComm)
	--					SELECT @CustID, 1, 0
	--				END
	--				ELSE
	--				BEGIN
	--					INSERT INTO dbo.CS_CustSettingMode (CustId, IsGroupPT, IsGroupComm)
	--					SELECT @CustID, 1, 1
	--				END
	--			END
	--			ELSE
	--			BEGIN
	--				INSERT INTO dbo.CS_CustGroupDiscount_Member (AgentId, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
	--				SELECT @AgentID, playercomm.binaryStr_new, acomm.binaryStr_new, mcomm.binaryStr_new, scomm.binaryStr_new
	--				FROM dbo.f_SetBinaryValues(0x00, @PlayerDiscount_XML) playercomm	
	--					CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentDiscount_XML) acomm	
	--					CROSS APPLY dbo.f_SetBinaryValues(0x00, @MasterDiscount_XML) mcomm	
	--					CROSS APPLY dbo.f_SetBinaryValues(0x00, @SuperDiscount_XML)	scomm

	--				INSERT INTO dbo.CS_CustSettingMode (CustId, IsGroupPT, IsGroupComm)
	--				SELECT @CustID, 1, 1
	--			END
	--		END			
	--	END TRY
	--	BEGIN CATCH
	--		SELECT @ErrCode = 2
	--		IF @RoleID = 1
	--		BEGIN
	--			DELETE FROM dbo.CS_CustSettingMode WHERE CustID = @CustID
	--			DELETE FROM dbo.CS_CustDiscount_Member WHERE CustID = @CustID
	--			DELETE FROM dbo.CS_CustBetSetting_Member WHERE CustID = @CustID
	--		END
	--		ELSE --SMA
	--		BEGIN
	--			DELETE FROM dbo.CS_CustPTSetting_Agent WHERE CustID = @CustID		
	--			DELETE FROM dbo.CS_CustDiscount_Agent WHERE CustID = @CustID
	--			DELETE FROM dbo.CS_CustBetSetting_Agent WHERE CustID = @CustID
	--		END
	--		RETURN
	--	END CATCH							

	--	DROP TABLE #SportBettypeFilter1
	--	DROP TABLE #SportBettypeFilter2		
	--END
	
END
GO


