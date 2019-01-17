/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_DynamicCustSetting_00
	@RoleId			TINYINT,
	@CustID			INT,
	@CommSetting	VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,
	@SettingType	SMALLINT = 2
AS
/*
	Created: 20181212@Elodie
	Task : Update setting for downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
*/

BEGIN
	SET NOCOUNT ON
	IF dbo.f_CheckRepTable('CS_CustDiscount_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CS_CustGroupDiscount_Member') = 0 RETURN

	DECLARE @_CommSetting XML, @PlayerDiscount_XML XML, @AgentDiscount_XML XML, @MasterDiscount_XML XML, @SuperDiscount_XML XML
	DECLARE @GroupADiscount_XML XML, @GroupBDiscount_XML XML, @GroupCDiscount_XML XML, @GroupDDiscount_XML XML
	DECLARE @DownlineGroupComm TABLE (AgentId INT, uGroup VARCHAR(3), NumOfMember INT)

	/********************************************* Comm: SettingType = 2 ***********************************/
	IF @SettingType = 2
	BEGIN
		SELECT @_CommSetting = @CommSetting
		
		SELECT t.* INTO #SportBettypeFilter2
		FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t	

		SELECT cm.* INTO #CommSetting_tmp
		FROM dbo.f_CS_CommParse(@_CommSetting) cm
			INNER JOIN #SportBettypeFilter2 ft ON cm.SportType = ft.SportType AND cm.BetType = ft.BetType AND cm.IsLive = ft.IsLive	
	
		IF @RoleID IN (2,3,4)
		BEGIN
			SELECT cm.* INTO #CommSMA_tmp
			FROM #CommSetting_tmp cm
				INNER JOIN dbo.f_CS_GetDiscount_Agent(@CustID) cs ON cs.sporttype = cm.SportType AND cs.bettype = cm.BetType AND cs.isLive = cm.IsLive AND cs.groupID = cm.GroupId
			WHERE cm.ValueId <> cs.ValueId
		
			SET @GroupADiscount_XML =(
									SELECT (
											SELECT	bs.ByteOrder	AS '@pos',
													comm.ValueId	AS '@val'
											FROM #CommSMA_tmp comm
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
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
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
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
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
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
												INNER JOIN dbo.CS_ByteSeq bs WITH (NOLOCK) ON bs.SportType = comm.SportType AND bs.BetType = comm.BetType AND bs.IsLive = comm.IsLive
												LEFT JOIN dbo.CS_GroupConfig gc WITH (NOLOCK) ON gc.SportType = comm.SportType AND gc.BetType = comm.BetType AND gc.IsLive = comm.IsLive AND gc.GroupId = comm.GroupId
											WHERE bs.Type = 'DiscountMember'
												AND (gc.GroupName = 'D' OR gc.GroupId IS NULL)
											FOR XML PATH('r')
												, TYPE
											)
									FOR XML PATH('root')
										, TYPE
									)		

			IF @RoleId = 2
			BEGIN
				IF @GroupADiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupADiscount_XML) acomm	
					WHERE c.recommend = @CustID AND c.ugroup = 'CNA' AND c.roleid = 1

					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupADiscount_XML) acomm	
					WHERE cm.AgentId = @CustID AND cm.uGroup = 'CNA'
				END
			
				IF @GroupBDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupBDiscount_XML) acomm	
					WHERE c.recommend = @CustID AND c.ugroup = 'CNB' AND c.roleid = 1

					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupBDiscount_XML) acomm	
					WHERE cm.AgentId = @CustID AND cm.uGroup = 'CNB'
				END

				IF @GroupCDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupCDiscount_XML) acomm	
					WHERE c.recommend = @CustID AND c.ugroup = 'CNC' AND c.roleid = 1

					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupCDiscount_XML) acomm	
					WHERE cm.AgentId = @CustID AND cm.uGroup = 'CNC'
				END

				IF @GroupDDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupDDiscount_XML) acomm	
					WHERE c.recommend = @CustID AND c.ugroup = 'CND' AND c.roleid = 1

					UPDATE cm
					SET cm.AgentDiscount = acomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						CROSS APPLY dbo.f_SetBinaryValues(cm.AgentDiscount, @GroupDDiscount_XML) acomm	
					WHERE cm.AgentId = @CustID AND cm.uGroup = 'CND'
				END
			END
			ELSE IF @RoleId = 3
			BEGIN
				IF @GroupADiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupADiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND c.ugroup = 'CNA' AND c.roleid = 1

					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupADiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND cm.uGroup = 'CNA' AND c.roleid = 2
				END
			
				IF @GroupBDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupBDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND c.ugroup = 'CNB' AND c.roleid = 1

					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupBDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND cm.uGroup = 'CNB' AND c.roleid = 2
				END

				IF @GroupCDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupCDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND c.ugroup = 'CNC' AND c.roleid = 1

					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupCDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND cm.uGroup = 'CNC' AND c.roleid = 2
				END

				IF @GroupDDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupDDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND c.ugroup = 'CND' AND c.roleid = 1

					UPDATE cm
					SET cm.MasterDiscount = mcomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.MasterDiscount, @GroupDDiscount_XML) mcomm	
					WHERE c.mrecommend = @CustID AND cm.uGroup = 'CND' AND c.roleid = 2
				END
			
			END
			ELSE IF @RoleId = 4
			BEGIN
				IF @GroupADiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupADiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND c.ugroup = 'CNA' AND c.roleid = 1

					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupADiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND cm.uGroup = 'CNA' AND c.roleid = 2
				END
			
				IF @GroupBDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupBDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND c.ugroup = 'CNB' AND c.roleid = 1

					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupBDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND cm.uGroup = 'CNB' AND c.roleid = 2
				END

				IF @GroupCDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupCDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND c.ugroup = 'CNC' AND c.roleid = 1

					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupCDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND cm.uGroup = 'CNC' AND c.roleid = 2
				END

				IF @GroupDDiscount_XML IS NOT NULL
				BEGIN
					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.CustId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupDDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND c.ugroup = 'CND' AND c.roleid = 1

					UPDATE cm
					SET cm.SuperDiscount = scomm.binaryStr_new
					FROM dbo.CS_CustGroupDiscount_Member cm WITH (ROWLOCK)
						INNER JOIN customer c WITH (NOLOCK) ON c.custid = cm.AgentId
						CROSS APPLY dbo.f_SetBinaryValues(cm.SuperDiscount, @GroupDDiscount_XML) scomm	
					WHERE c.srecommend = @CustID AND cm.uGroup = 'CND' AND c.roleid = 2
				END
			
			END
		END
	END
	---------------------End CommSetting--------------------------------------
END
GO
