 ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTOnMemberUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,    
	@SubAccID	INT = 0, --Sub-AccountID  
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @MsgType	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-12-16
		Task: Update super's pt on member
		DB: DBCUST/CustDB
		
		Revisions:
            - 20151015@Billy: Fix log xml structure and naming
			- 20151104@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]
		
		Parameter's Explanation:
			@PT =<Root>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="50" AutoSuperPT="0" IsAutoSuperPT="0" />
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" AutoSuperPT="0" IsAutoSuperPT="0" />
				</Root>
	*/
BEGIN
	SET NOCOUNT ON 
--******************************************VARIABLE DECLARATION*************************************** 	
	DECLARE @StartRun		DATETIME
			, @EndRun		DATETIME
			, @Duration		INT 
			, @_RoleID		TINYINT
			, @logSPData		VARCHAR(5000)
			, @logSPData_Old	VARCHAR(5000)
			, @xml			XML
			, @SettingMode	BIT = 0
			, @MemGroup		INT
	
	DECLARE @tblPT TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT		
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	BIT
		, AutoMasterPT		TINYINT
		)
	
	DECLARE @NewPT TABLE(
		SportType			SMALLINT
		, BetType			SMALLINT
		, IsLive			BIT		
		, SuperPT			TINYINT
		, MasterPT			TINYINT
		, AgentPT			TINYINT
		, IsAutoSuperPT		BIT
		, AutoSuperPT		TINYINT
		, IsAutoMasterPT	BIT
		, AutoMasterPT		TINYINT
		)	
		
	DECLARE @_MasterID INT
			,@_AgentID INT
			,@_SuperID INT
	
	--Super PT Setting Values		
	DECLARE @_SuperPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S4				TINYINT  ,
					M4				TINYINT  ,
					A4				TINYINT  ,
					IM4				BIT  ,
					UM4				TINYINT  ,
					IS4				BIT  ,
					US4				TINYINT  ,
					N4				TINYINT  ,
					L4				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Master PT Setting Values
	DECLARE @_MasterPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S3				TINYINT  ,
					M3				TINYINT  ,
					A3				TINYINT  ,
					IM3				BIT  ,
					UM3				TINYINT  ,
					IS3				BIT  ,
					US3				TINYINT  ,
					N3				TINYINT  ,
					L3				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)
				
	--Agent PT Setting Values
	DECLARE @_AgentPTTbl TABLE(
					SportType		SMALLINT  ,
					BetType			SMALLINT  ,
					IsLive			BIT  ,
					S2				TINYINT  ,
					M2				TINYINT  ,
					A2				TINYINT  ,
					IM2				BIT  ,
					UM2				TINYINT  ,
					IS2				BIT  ,
					US2				TINYINT  ,
					N2				TINYINT  ,
					L2				TINYINT  
					UNIQUE CLUSTERED (SportType, BetType, IsLive) 
				)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT
    
--******************************************PERMISSION CHECKING*************************************** 				
	SET @StartRun = GETDATE()
	
	EXEC dbo.Age_CustomerSelCheckBelongingByCustID   
		 @SessionCustID = @Userid,   
		 @Custid = @custid,  		 
		 @RoleID = @_RoleID OUTPUT  
	
	IF (@_RoleID <> 1) RETURN-- return if not member    
	
	--Check disable user  
	EXEC dbo.Acc_CustomerSelCheckEnable 
			@custid = @custid
			,@ErrCode=@ErrCode OUTPUT
			,@ErrMsg=@ErrMsg OUTPUT  
			
	IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 
	
--******************************************PREPARE SETTING FOR UPDATE*************************************** 							
	SELECT @_SuperID = srecommend, @_MasterID = mrecommend, @_AgentID = recommend
	FROM customer WITH (NOLOCK)   
	WHERE custid = @custid 
	
	--Parse XML	
	INSERT @tblPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
	SELECT SportType
			,BetType
			,IsLive
			,SuperPT
			,0
			,0
			,IsAutoSuperPT
			,AutoSuperPT
			,0
			,0
	FROM dbo.f_DCS_PT_XMLParse(@PT)
		
	SELECT @SettingMode = IsGrouped
	FROM dbo.CustSettingMode3rd
	WHERE CustID= @CustID
	
	--Get Super PT Setting Values
	INSERT @_SuperPTTbl(SportType,BetType,IsLive,S4,M4,A4
							,IM4,UM4,IS4,US4,N4,L4)	
	SELECT cs.SportType,cs.BetType,cs.IsLive,cs.SuperPT,cs.MasterPT,cs.AgentPT
							,cs.IsAutoMasterPT,cs.AutoMasterPT,cs.IsAutoSuperPT,cs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent cs WITH(NOLOCK)
		INNER JOIN @tblPT mt 
			ON mt.SportType = cs.SportType
				AND mt.BetType = cs.BetType
				AND mt.IsLive = cs.IsLive
	WHERE cs.CustID = @_SuperID
	
	--Get master PT Setting Values
	INSERT @_MasterPTTbl(SportType,BetType,IsLive,S3,M3,A3
				,IM3,UM3,IS3,US3,N3,L3)	
	SELECT mcs.SportType,mcs.BetType,mcs.IsLive,mcs.SuperPT,mcs.MasterPT,mcs.AgentPT
				,mcs.IsAutoMasterPT,mcs.AutoMasterPT,mcs.IsAutoSuperPT,mcs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent mcs WITH(NOLOCK)
		INNER JOIN @tblPT mt 
			ON mt.SportType = mcs.SportType
				AND mt.BetType = mcs.BetType
				AND mt.IsLive = mcs.IsLive
	WHERE mcs.CustID = @_MasterID
	
	--Get Agent PT Setting Values
	INSERT @_AgentPTTbl(SportType,BetType,IsLive,S2,M2,A2
				,IM2,UM2,IS2,US2,N2,L2)	
	SELECT acs.SportType,acs.BetType,acs.IsLive,acs.SuperPT,acs.MasterPT,acs.AgentPT
				,acs.IsAutoMasterPT,acs.AutoMasterPT,acs.IsAutoSuperPT,acs.AutoSuperPT,MinPT,MaxPT 
	FROM dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK)
		INNER JOIN @tblPT mt 
			ON mt.SportType = acs.SportType
				AND mt.BetType = acs.BetType
				AND mt.IsLive = acs.IsLive
	WHERE acs.CustID = @_AgentID		
	
------------------------------------------------------------------------------------------------------------------	
	
	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@tblPT AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
					AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = 1	-- Position Taking
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID


	IF @SettingMode = 0
	BEGIN
		UPDATE b
		SET b.MasterPT = cs.MasterPT,
			b.AgentPT = cs.AgentPT,
			b.IsAutoMasterPT = cs.IsAutoMasterPT,
			b.AutoMasterPT = cs.AutoMasterPT
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.custid = @custid					
		
		INSERT @NewPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
		SELECT cs.SportType		
			, cs.BetType		
			, cs.ISLive	
			, cs.SuperPT							
			, cs.MasterPT	
			, cs.AgentPT		
			, cs.IsAutoSuperPT	
			, cs.AutoSuperPT	
			, cs.IsAutoMasterPT
			, cs.AutoMasterPT						
		FROM @tblPT b
			INNER JOIN CustPTSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.custid = @custid																	
					
														
			
        -- Log old data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',					
						@IP                             AS '@IP',				
						(
							SELECT  @ProductID										AS '@ProductID',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',					
						@IP                             AS '@IP',				
						(
							SELECT  cs.sporttype									AS '@SportType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',					
						@IP                             AS '@IP',				
						(
							SELECT  cs.bettype										AS '@BetType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',					
						@IP                             AS '@IP',				
						(
							SELECT  cs.sporttype									AS '@SportType',
									cs.bettype										AS '@BetType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
	END
	ELSE 
	BEGIN
		UPDATE b
		SET b.MasterPT = cs.MasterPT,
			b.AgentPT = cs.AgentPT,
			b.IsAutoMasterPT = cs.IsAutoMasterPT,
			b.AutoMasterPT = cs.AutoMasterPT
		FROM @tblPT b
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.AgentID = @_AgentID
		
		INSERT @NewPT(
					SportType		
					, BetType		
					, ISLive	
					, SuperPT							
					, MasterPT	
					, AgentPT		
					, IsAutoSuperPT	
					, AutoSuperPT	
					, IsAutoMasterPT
					, AutoMasterPT			
				)
		SELECT cs.SportType		
			, cs.BetType		
			, cs.ISLive	
			, cs.SuperPT							
			, cs.MasterPT	
			, cs.AgentPT		
			, cs.IsAutoSuperPT	
			, cs.AutoSuperPT	
			, cs.IsAutoMasterPT
			, cs.AutoMasterPT						
		FROM @tblPT b
			INNER JOIN CustPTGroupSetting3rd_Member cs WITH(NOLOCK) ON b.SportType = cs.sporttype
																	AND b.BetType = cs.bettype
																	AND b.ISLive = cs.isLive
		WHERE cs.AgentID = @_AgentID
				
        -- Log old data
		IF @SettingLevel = 1			-- Product setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',
						@IP                             AS '@IP',
						(
							SELECT  @ProductID										AS '@ProductID',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 2		-- SportType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',
						@IP                             AS '@IP',
						(
							SELECT  cs.sporttype									AS '@SportType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 3		-- BetType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',
						@IP                             AS '@IP',
						(
							SELECT  cs.bettype										AS '@BetType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
		ELSE IF @SettingLevel = 4		-- SportType BetType setting level
		BEGIN
			SET @xml = (
				SELECT  @ProductID						AS '@ProductID',
						@ProductName					AS '@ProductName',
						@custid                         AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
						@userid                         AS '@UserID',
						@IP                             AS '@IP',
						(
							SELECT  cs.sporttype									AS '@SportType',
									cs.bettype										AS '@BetType',
									cs.isLive										AS '@IsLive',
									CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
									cs.isAutoSuperPT								AS '@IsAutoSuperPT',
									CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
				TYPE
			)
		END
	END
		
	SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	

    -- Log new updated data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@userid                         AS '@UserID',
					@IP                             AS '@IP',
					(
						SELECT  @ProductID										AS '@ProductID',
								cs.isLive										AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.isAutoSuperPT								AS '@IsAutoSuperPT',
								CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@userid                         AS '@UserID',
					@IP                             AS '@IP',
					(
						SELECT  cs.sporttype									AS '@SportType',
								cs.isLive										AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.isAutoSuperPT								AS '@IsAutoSuperPT',
								CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@userid                         AS '@UserID',
					@IP                             AS '@IP',
					(
						SELECT  cs.bettype										AS '@BetType',
								cs.isLive										AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.isAutoSuperPT								AS '@IsAutoSuperPT',
								CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID						AS '@ProductID',
					@ProductName					AS '@ProductName',
					@custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
					@userid                         AS '@UserID',
					@IP                             AS '@IP',
					(
						SELECT  cs.sporttype									AS '@SportType',
								cs.bettype										AS '@BetType',
								cs.isLive										AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.isAutoSuperPT								AS '@IsAutoSuperPT',
								CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTOnMemberUpd'), 
			TYPE
		)
	END
	SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	

	--check any settings change
	IF NOT EXISTS(SELECT TOP 1 1 
				FROM @NewPT cs 
					INNER JOIN @tblPT b ON cs.SportType = b.SportType
											AND cs.BetType = b.BetType
											AND cs.IsLive = b.IsLive
				WHERE cs.SuperPT <> b.SuperPT
					OR cs.IsAutoSuperPT <> b.IsAutoSuperPT
					OR cs.AutoSuperPT <> b.AutoSuperPT
				)
		RETURN--no pt change
	
--******************************************VALIDATE PT VALUES*************************************** 	
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
				@CustID = @CustID
				, @RoleID		= 4
				, @AgentID		= @_AgentID
				, @MasterID		= @_MasterID
				, @SuperID		= @_SuperID
				, @PT			= @PT
								
				, @ErrCode		= @ErrCode	OUTPUT
				, @MsgType		= @MsgType	OUTPUT
				, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN	
	
	--Udpate new values	
	UPDATE cs
	SET	cs.AutoSuperPT = b.AutoSuperPT,  
		cs.IsAutoSuperPT = b.IsAutoSuperPT,
		cs.SuperPT = b.SuperPT  
	FROM @NewPT cs 
	INNER JOIN @tblPT b ON b.SportType = cs.SportType
							AND b.BetType = cs.BetType
							AND b.IsLive = cs.IsLive		
--******************************************ADJUST PT SETTINGS*************************************** 
	DECLARE @n2 SMALLMONEY
	DECLARE @a1 SMALLMONEY, @m1 SMALLMONEY, @s1 SMALLMONEY, @i1 BIT, @u1 SMALLMONEY, @im1 BIT, @um1 SMALLMONEY
	DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @temp3 SMALLMONEY
	DECLARE @s_new SMALLMONEY, @m_new SMALLMONEY, @a_new SMALLMONEY

	UPDATE cs
		SET @a1 = cs.AgentPT
			,@m1 = cs.MasterPT
			,@s1 = cs.SuperPT
			,@i1 = cs.IsAutoSuperPT
			,@u1 = cs.AutoSuperPT
			,@im1 = cs.IsAutoMasterPT
			,@um1 = cs.AutoMasterPT
			,@n2 = acs.N2
			--Adjust PT : s1= s1+m1+ a1> s4?s4-m1-a1:s1
			,@s1 = CASE WHEN @s1 > S4 - @m1 - @a1 THEN S4 - @m1 - @a1 ELSE @s1 END
			--Adjust PT : s1=s1<0?:0:s1
			,@s1 = CASE WHEN @s1 < 0 THEN 0 ELSE @s1 END
			-- rule #1 s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
			/*
				@x1 = (i1=1) ? u1 : u3
				s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
			*/
			,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE mcs.US3 END			
			,@s1 = CASE 
						WHEN @i1 = 1 OR mcs.IS3 = 1 
						THEN CASE WHEN scs.s4-@m1-@a1 > @temp1 THEN @temp1 ELSE scs.s4-@m1-@a1 END
						ELSE @s1
					END

            -- rule #2: s1 = max(n4-m1-a1,s1) --super min
			,@s1 = CASE WHEN @a1+@m1+@s1 < scs.n4 THEN scs.n4-@m1-@a1 ELSE @s1 END
            -- rule #3: UPDATE s1,m1,a1 IN case s1+m1+a1>s4
			/* -- explanation
				@x1 = (s4-m1-a1 < 0) ? 0 : s4-m1-a1
				s1 = (s1+a1+m1 > s4) ? @x1 : s1
				@x1 = (@x1+m1+a1 > s4) ? s4-@x1 : m1+a1
				@x2 = (m3 > l3) ? l3 : m3
				@x2 = (@x1 > @x2) ? @x2 : @x1
				@x2 = (@x2 < n3) ? n3 : @x2
				@x3 = (@x2-a1 < 0) ? 0 : @x2-a1
				m1 = (s1+a1+m1 > s4) ? @x3 : m1
				@x3 = (a1+@x3>@x2) ? @x2-@x3 : a1
				@x3 =  (@x3 < n2) ? n2 : @x3
				a1 = (s1+a1+m1 > s4) ? @x3 : a1				
			*/         
			,@temp1 = CASE WHEN scs.s4-@m1-@a1 < 0 THEN 0 ELSE scs.s4-@m1-@a1 END
			,@s_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp1 ELSE @s1 END
			,@temp1 = CASE WHEN @temp1+@m1+@a1 > scs.s4 THEN scs.s4-@temp1 ELSE @m1+@a1 END
			,@temp2 = CASE WHEN mcs.m3 > mcs.l3 THEN mcs.l3 ELSE mcs.m3 END
			,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
			,@temp2 = CASE WHEN @temp2 < mcs.n3 THEN mcs.n3 ELSE @temp2 END
			,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
			,@m_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp3 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
			,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
			,@a_new = CASE WHEN @s1+@a1+@m1 > scs.s4 THEN @temp3 ELSE @a1 END
			,@s1 = @s_new
			,@m1 = @m_new
			,@a1 = @a_new     
	
			--PT values must be in [0,100]
			,@s1 = CASE WHEN @s1 < 0 THEN 0 ELSE @s1 END
			,@s1 = CASE WHEN @s1 > 100 THEN 100 ELSE @s1 END
			,@m1 = CASE WHEN @m1 < 0 THEN 0 ELSE @m1 END
			,@m1 = CASE WHEN @m1 > 100 THEN 100 ELSE @m1 END
			,@a1 = CASE WHEN @a1 < 0 THEN 0 ELSE @a1 END
			,@a1 = CASE WHEN @a1 > 100 THEN 100 ELSE @a1 END
			--------------------------------	
			-- done apply all rule, then update to destination table
			,cs.AgentPT = @a1
			,cs.MasterPT = @m1
			,cs.SuperPT = @s1
	FROM @NewPT cs
	INNER JOIN @_SuperPTTbl scs
		ON scs.SportType = cs.SportType
			AND scs.BetType = cs.BetType
			AND scs.IsLive = cs.IsLive
	INNER JOIN @_MasterPTTbl mcs
		ON mcs.SportType = cs.SportType
			AND mcs.BetType = cs.BetType
			AND mcs.IsLive = cs.IsLive
	INNER JOIN @_AgentPTTbl acs
		ON acs.SportType = cs.SportType
			AND acs.BetType = cs.BetType
			AND acs.IsLive = cs.IsLive	
	
--***************************************UPDATE PT SETTINGS*******************************************
		
	IF @SettingMode = 0
	BEGIN
		UPDATE cs
		SET cs.SuperPT = b.SuperPT
			,cs.MasterPT = b.MasterPT
			,cs.AgentPT = b.AgentPT
			,cs.isAutoSuperPT = b.isAutoSuperPT
			,cs.IsAutoMasterPT = b.IsAutoMasterPT
			,cs.AutoSuperPT = b.AutoSuperPT
			,cs.AutoMasterPT = b.AutoMasterPT
		FROM CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
			INNER JOIN @NewPT b ON cs.sporttype = b.SportType	
									AND cs.bettype = b.BetType
									AND cs.isLive = b.IsLive
		WHERE cs.custid = @custid
			AND (
					cs.SuperPT <> b.SuperPT
				OR cs.MasterPT <> b.MasterPT
				OR cs.AgentPT <> b.AgentPT
				OR cs.isAutoSuperPT <> b.isAutoSuperPT
				OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
				OR cs.AutoSuperPT <> b.AutoSuperPT
				OR cs.AutoMasterPT <> b.AutoMasterPT
			)
	END
	ELSE
	BEGIN
		SELECT @MemGroup = count(1) 
		FROM CustSettingMode3rd sm WITH (NOLOCK) 
			INNER JOIN CustInfo ci WITH (NOLOCK) ON ci.custid = sm.CustID 
		WHERE ci.recommend = @_AgentID AND sm.IsGrouped = 1
		
		IF @MemGroup = 1
		BEGIN	
			UPDATE cs
				SET cs.SuperPT=b.SuperPT,
					cs.MasterPT=b.MasterPT,
					cs.AgentPT=b.AgentPT,
					cs.isAutoSuperPT = b.isAutoSuperPT,
					cs.IsAutoMasterPT = b.IsAutoMasterPT,
					cs.AutoSuperPT = b.AutoSuperPT,
					cs.AutoMasterPT = b.AutoMasterPT
				FROM dbo.CustPTGroupSetting3rd_Member cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewPT b ON  b.SportType=cs.SportType
											AND b.BetType=cs.BetType
											AND b.IsLive=cs.IsLive
				WHERE cs.AgentID = @_AgentID AND
						(
								cs.SuperPT <> b.SuperPT
							OR cs.MasterPT <> b.MasterPT
							OR cs.AgentPT <> b.AgentPT
							OR cs.isAutoSuperPT <> b.isAutoSuperPT
							OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
							OR cs.AutoSuperPT <> b.AutoSuperPT
							OR cs.AutoMasterPT <> b.AutoMasterPT
						)
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT TOP 1 1
						FROM CustPTGroupSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK)
							INNER JOIN @NewPT b ON cs.sporttype = b.SportType	
													AND cs.bettype = b.BetType
													AND cs.isLive = b.IsLive
						WHERE cs.AgentID = @_AgentID
							AND (
									cs.SuperPT <> b.SuperPT
								OR cs.MasterPT <> b.MasterPT
								OR cs.AgentPT <> b.AgentPT
								OR cs.isAutoSuperPT <> b.isAutoSuperPT
								OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
								OR cs.AutoSuperPT <> b.AutoSuperPT
								OR cs.AutoMasterPT <> b.AutoMasterPT
							)		
					)
			BEGIN
				--Move to Individual Setting
				INSERT INTO dbo.CustPTSetting3rd_Member
				SELECT
						@CustID,
						grpt.SportType,
						grpt.BetType,
						grpt.IsLive,
						grpt.SuperPT,
						grpt.MasterPT,
						grpt.AgentPT,
						grpt.IsAutoMasterPT,
						grpt.AutoMasterPT,
						grpt.IsAutoSuperPT,
						grpt.AutoSuperPT
				FROM dbo.CustPTGroupSetting3rd_Member grpt WITH(NOLOCK)
					LEFT JOIN dbo.CustPTSetting3rd_Member mempt ON mempt.CustID = @CustID
																	AND grpt.SportType=mempt.SportType
																	AND grpt.BetType=mempt.BetType
																	AND grpt.IsLive=mempt.IsLive
				WHERE grpt.AgentID=@_AgentID AND mempt.CustID IS NULL
		
				--Update Adjusted PT for indiviual setting
				UPDATE cs
				SET cs.SuperPT=b.SuperPT,
					cs.MasterPT=b.MasterPT,
					cs.AgentPT=b.AgentPT,
					cs.isAutoSuperPT = b.isAutoSuperPT,
					cs.IsAutoMasterPT = b.IsAutoMasterPT,
					cs.AutoSuperPT = b.AutoSuperPT,
					cs.AutoMasterPT = b.AutoMasterPT
				FROM dbo.CustPTSetting3rd_Member cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN @NewPT b ON  b.SportType=cs.SportType
											AND b.BetType=cs.BetType
											AND b.IsLive=cs.IsLive
				WHERE cs.CustID = @CustID AND
						(
								cs.SuperPT <> b.SuperPT
							OR cs.MasterPT <> b.MasterPT
							OR cs.AgentPT <> b.AgentPT
							OR cs.isAutoSuperPT <> b.isAutoSuperPT
							OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
							OR cs.AutoSuperPT <> b.AutoSuperPT
							OR cs.AutoMasterPT <> b.AutoMasterPT
						)
		
				---Update setting mode
				UPDATE dbo.CustSettingMode3rd WITH(ROWLOCK,UPDLOCK)
				SET IsGrouped = 0
				WHERE CustID = @CustID
			END
		END
	END
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @StartRun, @endRun) 
						
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 455,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 455,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END CATCH 	
	 
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTOnMemberUpd] TO [bodbExtAccNet] AS [dbo]


