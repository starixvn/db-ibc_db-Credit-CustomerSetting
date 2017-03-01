 ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTOnMemberUpd]
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
		Date: 2014-12-18
		Task: Update master's pt on member
		DB: DBCUST/CustDB
		
		Revisions:
            - 20151015@Billy: Fix log xml structure and naming
			- 20151104@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]
		
		Parameter's Explanation:
			@PT =<ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MasterPT="50" AutoMasterPT="0" IsAutoMasterPT="0" />
					<PT SportType="1" BetType="1" IsLive="1" MasterPT="30" AutoMasterPT="0" IsAutoMasterPT="0" />
				</ROOT>	
	*/
BEGIN
	SET NOCOUNT ON 
--******************************************VARIABLE DECLARATION*************************************** 		
	DECLARE @StartRun	DATETIME
			, @EndRun		DATETIME
			, @Duration		INT  
			,@_RoleID		INT
			,@logSPData		VARCHAR(5000)
			,@logSPData_Old	VARCHAR(5000)
			,@XML			XML
			,@SettingMode	BIT = 0
			,@MemGroup		INT

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
						
	DECLARE @_MasterID INT
			,@_AgentID INT
			,@_SuperID INT

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT
    

--******************************************CHECK PERMISSION*************************************** 		
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
	SELECT @_SuperID = srecommend,
			@_MasterID = mrecommend,
			@_AgentID = recommend
	FROM CustInfo WITH(NOLOCK)
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
			,0
			,MasterPT
			,0
			,0
			,0
			,IsAutoMasterPT
			,AutoMasterPT
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
--------------------------------------------------------------------------------------------------------	

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
		SET b.SuperPT = cs.SuperPT
			,b.AgentPT = cs.AgentPT
			,b.IsAutoSuperPT = cs.IsAutoSuperPT
			,b.AutoSuperPT = cs.AutoSuperPT
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
				TYPE
			)
		END
	END
	ELSE
	BEGIN
		UPDATE b
		SET b.SuperPT = cs.SuperPT
			,b.AgentPT = cs.AgentPT
			,b.IsAutoSuperPT = cs.IsAutoSuperPT
			,b.AutoSuperPT = cs.AutoSuperPT
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
									CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
									cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
									CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
							FROM        CustPTGroupSetting3rd_Member cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       AgentID = @_AgentID
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
								CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
								cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
								CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
								CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
								cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
								CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
								CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
								cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
								CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
								CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
								cs.IsAutoMasterPT								AS '@IsAutoMasterPT',
								CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT'
						FROM    @tblPT cs						
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_MasterPTOnMemberUpd'), 
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
				WHERE cs.MasterPT <> b.MasterPT
					OR cs.IsAutoMasterPT <> b.IsAutoMasterPT
					OR cs.AutoMasterPT <> b.AutoMasterPT
				)
		RETURN--no pt change
		
--******************************************VALIDATE PT VALUES*************************************** 		
	EXEC [dbo].Acc_CustSetting_MemberPTCheck 
				@CustID = @CustID
				, @RoleID		= 3
				, @AgentID		= @_AgentID
				, @MasterID		= @_MasterID
				, @SuperID		= @_SuperID
				, @PT			= @PT

				, @ErrCode		= @ErrCode	OUTPUT
				, @MsgType		= @MsgType  OUTPUT
				, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN		

	--Update values
	UPDATE cs
	SET AutoMasterPT =  b.AutoMasterPT,   
		IsAutoMasterPT = b.IsAutoMasterPT,
		MasterPT = b.MasterPT ,  
		SuperPT = b.SuperPT  
	FROM @NewPT cs 
		INNER JOIN @tblPT b ON cs.SportType = b.SportType
								AND cs.BetType = b.BetType
								AND cs.IsLive = b.IsLive  
									
--******************************************ADJUST PT SETTINGS*************************************** 	
	DECLARE @m3 SMALLMONEY,@us3 SMALLMONEY, @s4 SMALLMONEY, @is3 BIT
	DECLARE @n2 SMALLMONEY, @l2 SMALLMONEY
	DECLARE @im2 BIT, @um2 SMALLMONEY
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
			,@um2 = acs.UM2
			,@im2 = acs.IM2
			,@n2 = acs.N2
			,@l2 = acs.L2
			,@m3 = mcs.M3
			,@s4 = scs.S4
			--Adjust: m1=m1+a1>min(m3,m4)?min(m3,m4)-a1:m1
			,@temp1 = CASE WHEN M3 < M4 THEN M3 ELSE M4 END
			,@m1 = CASE WHEN @m1 > @temp1 - @a1 THEN @temp1 - @a1 ELSE @m1 END
			--Adjust: m1=m1+a1<n3?n3-a1:m1
			,@m1 = CASE WHEN N3 - @a1 > @m1 THEN N3 - @a1 ELSE @m1 END
			--Adjust : m1=m1>0?m1:0
			,@m1 = CASE WHEN @m1 > 0 THEN @m1 ELSE 0 END
			
			--Adjust : m1=im1/im2=1 ? min(um1/um2,m3-a1):m1
			,@um2 = CASE WHEN @im1>0 THEN @um1 ELSE @um2 END
			,@im2 = CASE WHEN @im1>0 THEN @im1 ELSE @im2 END  
			,@m1 = CASE WHEN ISNULL(@im2, 0)<=0 THEN @m1 ELSE CASE WHEN @um2 < @m3 - @a1 THEN @um2 ELSE @m3 - @a1 END END
			 
			--Adjust : s1=(is=0?s1:min(us,s4-m1-a1))
			,@us3 = CASE WHEN @i1>0 THEN @u1 ELSE @us3 END
			,@is3 = CASE WHEN @i1>0 THEN @i1 ELSE @is3 END 
			,@s1 = CASE WHEN ISNULL(@is3, 0)<=0 THEN @s1 ELSE CASE WHEN @us3 < @s4 - @m1 - @a1 THEN @us3 ELSE @s4 - @m1 - @a1 END END  

			--Adjust : s1=s1>(isauto?s4:s4-m3)?(isauto?s4:s4-m3):s1
			,@s4 = CASE WHEN ISNULL(@is3, 0)>0 THEN @s4 ELSE @s4-@m3 END
			,@s1 = CASE WHEN @s1 > @s4 THEN @s4 ELSE @s1 END  

			-- rule #1: a1 = max(a1,n2); m1 = (a1<n2) ? m3-n2 : m1 -- agent min
			,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
			,@m_new = CASE WHEN @a1 < @n2 AND @m1 +@n2 > mcs.m3 THEN mcs.m3-@n2 ELSE @m1 END
			,@a1 = @a_new
			,@m1 = @m_new
			-- rule #2: a1 = min(a1,l2) -- agent max                        
			,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END			
            -- rule #3: m1 = min(m3-a1,u2) -- Recal AUTO MPT
			,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END
			,@m1 = CASE 
						WHEN @im2 = 1 OR @im1 = 1 
						THEN CASE WHEN mcs.m3-@a1 > @temp1 THEN @temp1 ELSE mcs.m3-@a1 END 
						ELSE @m1 
					END
			-- rule #4: m1 = n3-a1 -- check master min/max
			,@m1 = CASE WHEN @a1+@m1 < mcs.n3 THEN mcs.n3-@a1 ELSE @m1 END			
            -- rule #5: UPDATE m1,a1 WHEN m1+a1>l3
			/*	@x1 = min(m3,l3) -- mpt max
				@x2 = max(@x1-a1,0) --mpt
				m1 = (a1+m1>l3) ? @x2 : m1
				@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
				a1 = (a1+m1>l1) ? max(@x3, n2) : a1
			*/
			,@temp1 = CASE WHEN mcs.m3 > mcs.l3 THEN mcs.l3 ELSE mcs.m3 END
			,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
			,@m_new = CASE WHEN @a1+@m1 > mcs.l3 THEN @temp2 ELSE @m1 END
			,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
			,@a_new = CASE 
						WHEN @a1+@m1 > mcs.l3 
						THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
						ELSE @a1 
					END	
			,@m1 = @m_new
			,@a1 = @a_new

			-- rule #6 s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
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

            -- rule #7: s1 = max(n4-m1-a1,s1) --super min
			,@s1 = CASE WHEN @a1+@m1+@s1 < scs.n4 THEN scs.n4-@m1-@a1 ELSE @s1 END
            -- rule #8: UPDATE s1,m1,a1 IN case s1+m1+a1>s4
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
			@ActionID = 456,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 456,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END CATCH 	
	
END


GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbadminNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbDownlineNet] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTOnMemberUpd] TO [bodbExtAccNet] AS [dbo]