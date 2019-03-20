/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_PTSetting_Upd
	@RoleId			TINYINT,
	@CustID			INT,
	@PTSetting		VARCHAR(MAX),
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
	Task : Update PT
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
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @startRun DATETIME,@endRun DATETIME, @duration INT, @ActionId INT, @logSPData VARCHAR(MAX),@logSPData_Old VARCHAR(MAX), @ErrType XML, @_PTSetting XML, @xml XML, @xml_Old XML  
	DECLARE @MinPT_XML XML, @MaxPT_XML XML, @SuperPT_XML XML, @MasterPT_XML XML, @AgentPT_XML XML
	DECLARE @SettingLevel	TINYINT
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @IsEditablePT BIT
	

	IF @PTSetting = '' OR @PTSetting IS NULL RETURN 

	SELECT @ErrCode = 0, @_PTSetting = @PTSetting	
	SELECT @IsEditablePT = IsEditablePT FROM f_CS_GetEditablePTDate(@ProductID)

	IF @IsEditablePT = 0
	BEGIN
		SELECT	@ErrMsg = CASE @Language WHEN 'E' THEN 'You cannot update new possess value at this moment.'
												ELSE [dbo].[f_Get_MsgNamebyMsgID](20042,@Language) END,
				@ErrCode = 999, @MsgType = 200	
		RETURN
	END

	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId	

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
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= @Language
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
        
    IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 
    
	EXEC CS_CustSetting_PTSetting_Check
		@RoleId			= @RoleId,
		@CustID			= @CustID,
		@PTSetting		= @PTSetting,
		@ProductID		= @ProductID,
		@IsTest			= @IsTest,
		@ErrCode		= @ErrCode OUTPUT,
		@MsgType		= @MsgType OUTPUT,
		@ErrMsg			= @ErrMsg OUTPUT
	IF @ErrCode > 0
		RETURN

    SET @startRun = GETDATE()

	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	SELECT pt.* INTO #PT_tmp
	FROM dbo.f_CS_PTParse(@_PTSetting) pt
		INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
	
	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM CS_ProductSettingDetail AS psd WITH(NOLOCK)
				INNER JOIN #PT_tmp AS tmp ON psd.SportType = tmp.SportType AND	psd.BetType = tmp.BetType AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 1	-- Position Taking
		 ) iq

	IF @RoleId = 4
	BEGIN						
		-- Log old data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID														AS '@ProductID',
									@IP																AS '@IP',
									cs.isLive														AS '@InPlay',
									CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
									CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
							FROM dbo.f_CS_GetPT_Agent(@CustID) cs
								INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END		
				
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

		UPDATE cs
		SET cs.MinPT = minpt.binaryStr_new,
			cs.MaxPT = maxpt.binaryStr_new
		FROM dbo.CS_CustPTSetting_Agent cs WITH (ROWLOCK)
			CROSS APPLY dbo.f_SetBinaryValues(cs.MinPT, @MinPT_XML) minpt
			CROSS APPLY dbo.f_SetBinaryValues(cs.MaxPT, @MaxPT_XML) maxpt	
		WHERE cs.CustId = @CustID

		-- Log new data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml = (
						SELECT  @ProductID														AS '@ProductID',
								@IP																AS '@IP',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
								CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
						FROM #PT_tmp cs								
						FOR XML PATH('R'), 
						TYPE
					)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
		SET @xml = (
					SELECT  @ProductID						AS '@ProductID',
							@IP                             AS '@IP',
							(
								SELECT  cs.sporttype													AS '@Sport',
										cs.isLive														AS '@InPlay',
										CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
										CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
								FROM #PT_tmp cs
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
					@IP                             AS '@IP',
					(
						SELECT  cs.bettype														AS '@BT',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
								CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
						FROM #PT_tmp cs
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
					@IP                             AS '@IP',
					(
						SELECT  cs.sporttype													AS '@Sport',
								cs.bettype														AS '@BT',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.MinPT/100.0) AS VARCHAR(30))	AS '@MinPossess',
								CAST(CONVERT(DOUBLE PRECISION,cs.MaxPT/100.0) AS VARCHAR(30))	AS '@MaxPossess'
						FROM #PT_tmp cs
								FOR XML PATH('C'), 
								TYPE
							)
					FOR XML PATH('R'), 
					TYPE
					)
		END				
	END
	ELSE IF @RoleId = 3
	BEGIN
		-- Log old data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID														AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID)									AS '@SubAcc',
									@IP																AS '@IP',
									cs.isLive														AS '@InPlay',
									CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
							FROM dbo.f_CS_GetPT_Agent(@CustID) cs
								INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.sporttype													AS '@Sport',
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.bettype														AS '@BT',
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.sporttype													AS '@Sport',
												cs.bettype														AS '@BT',
												cs.isLive														AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END	

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

		
		UPDATE cs
		SET cs.SuperPT = spt.binaryStr_new
		FROM dbo.CS_CustPTSetting_Agent cs WITH (ROWLOCK) 
			CROSS APPLY dbo.f_SetBinaryValues(cs.SuperPT, @SuperPT_XML) spt
		WHERE cs.CustId = @CustID

		UPDATE cs
		SET cs.SuperPT = mpt.binaryStr_new
		FROM dbo.CS_CustPTGroupSetting_Member cs WITH (ROWLOCK) 
			INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.AgentId
			CROSS APPLY dbo.f_SetBinaryValues(cs.SuperPT, @SuperPT_XML) mpt
		WHERE ci.mrecommend = @CustID AND ci.roleid = 2

		-- Log new data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml = (
						SELECT  @ProductID														AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID)									AS '@SubAcc',
								@IP																AS '@IP',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
						FROM #PT_tmp cs
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
								SELECT  cs.sporttype													AS '@Sport',
										cs.isLive														AS '@InPlay',
										CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
								FROM #PT_tmp cs
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
						SELECT  cs.bettype														AS '@BT',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
						FROM #PT_tmp cs
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
						SELECT  cs.sporttype													AS '@Sport',
								cs.bettype														AS '@BT',
								cs.isLive														AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.SuperPT/100.0) AS VARCHAR(30))	AS '@SuperPossess'
						FROM #PT_tmp cs
								FOR XML PATH('C'), 
								TYPE
							)
					FOR XML PATH('R'), 
					TYPE
					)
		END				
	END	
	ELSE IF @RoleId = 2
	BEGIN
		-- Log old data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml_Old = (
							SELECT  @ProductID															AS '@ProductID',
									dbo.f_GetSubUsername(@SubAccID)										AS '@SubAcc',
									@IP																	AS '@IP',
									cs.isLive															AS '@InPlay',
									CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
									CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
							FROM dbo.f_CS_GetPT_Agent(@CustID) cs
								INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.sporttype														AS '@Sport',
												cs.isLive															AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.bettype															AS '@BT',
												cs.isLive															AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
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
										SELECT  cs.sporttype														AS '@Sport',
												cs.bettype															AS '@BT',
												cs.isLive															AS '@InPlay',
												CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
												CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
										FROM dbo.f_CS_GetPT_Agent(@CustID) cs
											INNER JOIN #PT_tmp newpt ON newpt.SportType = cs.sporttype AND newpt.BetType = cs.bettype AND newpt.IsLive = cs.isLive
										FOR XML PATH('C'), 
										TYPE
									)
							FOR XML PATH('R'), 
							TYPE
							)
		END	

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

		UPDATE cs
		SET cs.MasterPT = apt1.binaryStr_new,
			cs.AgentPT = apt2.binaryStr_new
		FROM dbo.CS_CustPTSetting_Agent cs WITH (ROWLOCK) 
			CROSS APPLY dbo.f_SetBinaryValues(cs.MasterPT, @MasterPT_XML) apt1
			CROSS APPLY dbo.f_SetBinaryValues(cs.AgentPT, @AgentPT_XML) apt2
		WHERE cs.CustId = @CustID

		UPDATE cs
		SET cs.MasterPT = apt1.binaryStr_new,
			cs.AgentPT = apt2.binaryStr_new
		FROM dbo.CS_CustPTGroupSetting_Member cs WITH (ROWLOCK) 
			CROSS APPLY dbo.f_SetBinaryValues(cs.MasterPT, @MasterPT_XML) apt1
			CROSS APPLY dbo.f_SetBinaryValues(cs.AgentPT, @AgentPT_XML) apt2
		WHERE cs.AgentId = @CustID

		-- Log new data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml = (
						SELECT  @ProductID															AS '@ProductID',
								dbo.f_GetSubUsername(@SubAccID)										AS '@SubAcc',
								@IP																	AS '@IP',
								cs.isLive															AS '@InPlay',
								CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
								CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
						FROM #PT_tmp cs
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
								SELECT  cs.sporttype														AS '@Sport',
										cs.isLive															AS '@InPlay',
										CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
										CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
								FROM #PT_tmp cs
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
									SELECT  cs.bettype															AS '@BT',
											cs.isLive															AS '@InPlay',
											CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
											CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
									FROM #PT_tmp cs
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
									SELECT  cs.sporttype														AS '@Sport',
											cs.bettype															AS '@BT',
											cs.isLive															AS '@InPlay',
											CAST(CONVERT(DOUBLE PRECISION,cs.MasterPT/100.0) AS VARCHAR(30))	AS '@MasterPossess',
											CAST(CONVERT(DOUBLE PRECISION,cs.AgentPT/100.0) AS VARCHAR(30))		AS '@AgentPossess'
									FROM #PT_tmp cs
											FOR XML PATH('C'), 
											TYPE
										)
								FOR XML PATH('R'), 
								TYPE
						)
		END	
	END	

	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
		
	SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml_Old), '" />', '"/"')		
	SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')				

	SELECT @ActionId = l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = 'CS_CustSetting_PTSetting_Upd' AND ld.ProductID = @ProductID AND ld.Level = @RoleID	
				
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = @ActionId,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @logSPData_Old,
		@duration = @duration

	DROP TABLE #PT_tmp
	DROP TABLE #SportBettypeFilter1 
END
GO
