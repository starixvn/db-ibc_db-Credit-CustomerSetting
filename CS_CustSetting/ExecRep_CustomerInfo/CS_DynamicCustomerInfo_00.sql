/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[CS_DynamicCustomerInfo_00] 
	@CustID			INT,
	@SuperID		INT,
	@MasterID		INT,
	@AgentID		INT,
	@RoleID			TINYINT,
	@ProductID		TINYINT = 1,
	@PTSetting		VARCHAR(MAX),
	@BetSetting		VARCHAR(MAX),
	@CommSetting	VARCHAR(MAX),	
	@IsTest			BIT = 0,
	@ErrCode		INT	= 0 OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Insert CS Settings
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
		@RoleID = 1:			
			@CommSetting: <ROOT>
							<Comm SportType="1" BetType="1" IsLive="0" ValueId = "6"/>
							<Comm SportType="1" BetType="1" IsLive="1" ValueId = "6"/>
							<Comm SportType="1" BetType="5" IsLive="0" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="0" ValueId = "21"/>
							<Comm SportType="1" BetType="9999" IsLive="1" ValueId = "21"/>	
							...						
						</ROOT>
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @MinPT_XML XML, @MaxPT_XML XML, @SuperPT_XML XML, @MasterPT_XML XML, @AgentPT_XML XML
	DECLARE @Discount_XML XML, @PlayerDiscount_XML XML, @AgentDiscount_XML XML, @MasterDiscount_XML XML, @SuperDiscount_XML XML
	DECLARE @_Currency INT, @_PTSetting XML, @_BetSetting XML, @_CommSetting XML
	
	SELECT @ErrCode = 0, @_PTSetting = @PTSetting, @_BetSetting = @BetSetting, @_CommSetting = @CommSetting
	SELECT @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID

	IF(dbo.f_CheckRepTable('CS_CustPTSetting_Agent') = 1
		AND dbo.f_CheckRepTable('CS_CustPTSetting_Member') = 1
		AND dbo.f_CheckRepTable('CS_CustPTGroupSetting_Member ') = 1
		AND dbo.f_CheckRepTable('CS_CustSettingMode') = 1
		AND dbo.f_CheckRepTable('CS_CustBetSetting_Agent') = 1
		AND dbo.f_CheckRepTable('CS_CustBetSetting_Member') = 1
		AND dbo.f_CheckRepTable('CS_CustDiscount_Agent') = 1
		AND dbo.f_CheckRepTable('CS_CustDiscount_Member') = 1
		AND dbo.f_CheckRepTable('CS_ProductSettingDetail') = 1 
	   )
	 BEGIN
		/********************************************* Position Taking: SettingType = 1 ***********************************/
		SELECT t.* INTO #SportBettypeFilter1
		FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 1, @IsTest) t
		
		SELECT * INTO #PT_tmp
		FROM dbo.f_CS_PTParse(@_PTSetting) pt
			INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive

		BEGIN TRY
			IF @RoleID = 4
			BEGIN						
				SET @MinPT_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													pt.MinPT		AS '@val'
											FROM #PT_tmp pt
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
											WHERE bs.Type = 'PTSetting'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)
						
				SET @MaxPT_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													pt.MaxPT		AS '@val'
											FROM #PT_tmp pt
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
											WHERE bs.Type = 'PTSetting'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)
										
				INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
				SELECT 
					@Custid
					,NULL
					,NULL
					,NULL
					,minpt.binaryStr_new
					,maxpt.binaryStr_new
				FROM dbo.f_SetBinaryValues(0x00, @MinPT_XML) minpt
					CROSS APPLY dbo.f_SetBinaryValues(0x00, @MaxPT_XML) maxpt
			END
			ELSE IF @RoleID = 3
			BEGIN								
				SET @SuperPT_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													pt.SuperPT		AS '@val'
											FROM #PT_tmp pt
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
											WHERE bs.Type = 'PTSetting'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)

				INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
				SELECT 
					@Custid
					,superpt.binaryStr_new
					,NULL
					,NULL
					,NULL
					,NULL
				FROM dbo.f_SetBinaryValues(0x00, @SuperPT_XML) superpt

			END
			ELSE IF @RoleID = 2
			BEGIN				
				SET @MasterPT_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													pt.MasterPT		AS '@val'
											FROM #PT_tmp pt
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
											WHERE bs.Type = 'PTSetting'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)

				SET @AgentPT_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													pt.AgentPT		AS '@val'
											FROM #PT_tmp pt
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = pt.SportType AND bs.BetType = pt.BetType AND bs.IsLive = pt.IsLive
											WHERE bs.Type = 'PTSetting'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)
				
				INSERT INTO dbo.CS_CustPTSetting_Agent (CustId, SuperPT, MasterPT, AgentPT, MinPT, MaxPT)				       
				SELECT 
					@Custid
					,NULL
					,masterpt.binaryStr_new
					,agentpt.binaryStr_new
					,NULL
					,NULL
				FROM dbo.f_SetBinaryValues(0x00, @MasterPT_XML) masterpt
					CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentPT_XML) agentpt

				INSERT INTO dbo.CS_CustPTGroupSetting_Member (AgentId, SuperPT, MasterPT, AgentPT)							       
				SELECT 
					@CustID
					,cs.SuperPT
					,masterpt.binaryStr_new
					,agentpt.binaryStr_new
				FROM CS_CustPTSetting_Agent cs WITH (NOLOCK)
					CROSS APPLY dbo.f_SetBinaryValues(0x00, @MasterPT_XML) masterpt
					CROSS APPLY dbo.f_SetBinaryValues(0x00, @AgentPT_XML) agentpt
				WHERE cs.CustId = @SuperID
			END			
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 1
			IF @RoleID = 2
			BEGIN
				DELETE FROM dbo.CS_CustPTSetting_Agent WHERE CustID = @CustID
				DELETE FROM dbo.CS_CustPTGroupSetting_Member WHERE AgentId = @CustID
			END
			ELSE
			BEGIN
				DELETE FROM dbo.CS_CustPTSetting_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH

		/********************************************* Commission & Bet Setting : SettingType = 2 ****************************************/	
		SELECT t.* INTO #SportBettypeFilter2
		FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t			
	
		SELECT * INTO #Comm_tmp
		FROM dbo.f_CS_CommParse(@_CommSetting) comm
			INNER JOIN #SportBettypeFilter2 ft ON comm.SportType = ft.SportType AND comm.BetType = ft.BetType AND comm.IsLive = ft.IsLive

		BEGIN TRY
			IF @RoleID IN (4,3,2)
			BEGIN
				SET @Discount_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													comm.ValueId	AS '@val'
											FROM #Comm_tmp comm
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive AND bs.GroupId = comm.GroupId
											WHERE bs.Type = 'DiscountAgent'
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)
				
				INSERT INTO dbo.CS_CustDiscount_Agent (CustId, Discount)
				SELECT @CustID, comm.binaryStr_new	
				FROM dbo.f_SetBinaryValues(0x00, @Discount_XML) comm			
			END
			ELSE IF @RoleID = 1
			BEGIN								
				SET @PlayerDiscount_XML =(
											SELECT (
													SELECT	bs.ByteOrder	AS '@pos',
															comm.ValueId	AS '@val'
													FROM #Comm_tmp comm
														INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
													WHERE bs.Type = 'DiscountMember'
													FOR XML PATH('r')
														, TYPE
													)
											FOR XML PATH('root')
												, TYPE
											)
				
				IF EXISTS (SELECT 1 FROM dbo.custInfo WITH (NOLOCK) WHERE recommend = @AgentID AND roleid = 1)
				BEGIN
					SELECT 'a'
				END
				ELSE
				BEGIN
					INSERT INTO dbo.CS_CustGroupDiscount_Member (AgentId, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
					SELECT @AgentID, playercomm.binaryStr_new, NULL, NULL, NULL
					FROM dbo.f_SetBinaryValues(0x00, @PlayerDiscount_XML) playercomm			
				END
			END			
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 2
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH
	
		/********************************************* Commision : SettingType = 3, Ticket Commision : SettingType = 14 ****************************************/
		SELECT * INTO #SportBettypeFilter3
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3)
		INSERT INTO #SportBettypeFilter3
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14)

		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter3)
				BEGIN
					INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount])
					SELECT 
						@CustID
						,ft.SportType
						,ft.BetType
						,0 -- 0 zero by default
					FROM #SportBettypeFilter3 ft 
						INNER JOIN #ProductSettingDetail fil ON ft.SettingType = fil.SettingType AND ft.SportType = fil.SportType AND ft.BetType = fil.BetType 
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[Discount])
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK) 
					INNER JOIN #SportBettypeFilter3 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
				WHERE CustID = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[Discount])
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK) 
					INNER JOIN #SportBettypeFilter3 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
				WHERE CustID = @MasterID
			END
			ELSE
			BEGIN
				--super.discount: super.discount
				--master.discount: master.discount
				--agent.discount: agent.discount
				--playerdiscount: 0
				INSERT INTO [dbo].[CustDiscount3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[PlayerDiscount]
				   ,[AgentDiscount]
				   ,[MasterDiscount]
				   ,[SuperDiscount])
				SELECT 
					@CustID
					,acs.SportType
					,acs.BetType
					,0
					,acs.Discount
					,mcs.Discount
					,scs.Discount
				FROM dbo.CustDiscount3rd_Agent acs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter3 f ON acs.SportType = f.SportType AND acs.BetType = f.BetType
					INNER JOIN dbo.CustDiscount3rd_Agent mcs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND mcs.custid = @MasterID
					INNER JOIN dbo.CustDiscount3rd_Agent scs WITH (NOLOCK) ON acs.sporttype = scs.sporttype AND acs.bettype = scs.bettype AND scs.custid = @SuperID
				WHERE acs.custid=@AgentID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 3
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH								

		DROP TABLE #SportBettypeFilter1
		DROP TABLE #SportBettypeFilter2		
	END
	
END
GO


