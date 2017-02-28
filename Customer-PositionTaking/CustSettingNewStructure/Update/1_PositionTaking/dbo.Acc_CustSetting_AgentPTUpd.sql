 ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentPTUpd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	
	@SubAccID			INT = 0,
	@UserID				INT = 0,       
    @IP					VARCHAR(15)='',
    @ErrCode			INT = 0 OUTPUT,
    @MsgType			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(4000) = '' OUTPUT
 AS
	/*
		Created: Johnson
		Date: 2014-12-09
		Task: Update pt on Agent
		DB: DBCUST/CustDB
		
		Revisions:
            - 20151015@Billy: Fix log xml structure and naming
			- 20151103@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]
			- 20160122@Helen: AllBet - always correct PT for Allbet
			- 20160408@Winnie: VoidBridge - always correct PT for VoidBridge [RedmineID: #55532]
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" MinPT="0" IsUpdAllMems="0" UpdAllMems_Value="0"/>
					<PT SportType="1" BetType="1" IsLive="1" MasterPT="70" IsAutoMasterPT = "0" AutoMasterPT = "0" AgentPT ="30" MinPT="0" IsUpdAllMems="0" UpdAllMems_Value="0"/>
				</ROOT>
	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @roleid			TINYINT			
			,@startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT			
			,@logSPData		VARCHAR(5000)
			,@logSPData_Old	VARCHAR(5000)
			,@AutoPT		VARCHAR(MAX)	
			,@UpdateMinPT	BIT
			,@UpdatePresetPT BIT		
			,@xml			XML

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT
    
	  SET @startRun = GETDATE()
			
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
	
	---- Checking total downlines before UPDATEs 
    EXEC dbo.Acc_CustomerSelCheckAllowedDownlines    
		@custid			= @custid
        ,@roleid		= 2
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
        
    IF @ErrCode > 0	
	BEGIN
		SELECT @MsgType = 101
		RETURN
	END 
    ----------		
    
    IF @PT = '' RETURN 
    
    DECLARE @username VARCHAR(40), @srecommend INT, @mrecommend INT
    
    SELECT @UserName = username, @mrecommend = mrecommend, @srecommend = srecommend         
	FROM custinfo with (NOLOCK)         
	WHERE CustID = @CustID 
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				MasterPT		SMALLINT,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLINT,
				AgentPT			SMALLINT,				
				AgentMinPT		SMALLINT,
				UpdAllMems		BIT,
				NewMasterPT		SMALLINT
				)	
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				MasterPT,
				IsAutoMasterPT,
				AutoMasterPT,
				AgentPT,								
				AgentMinPT,
				UpdAllMems,
				NewMasterPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,
		MasterPT,
		IsAutoMasterPT,
		AutoMasterPT,	
		AgentPT,			
		MinPT,
		IsUpdAllMems,
		UpdAllMems_Value
	FROM dbo.f_DCS_PT_XMLParse(@PT)
	-- end read xml	
	
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
						    cs.isAutoMasterPT								AS '@IsAutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@AgentMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewMasterPT    /100.0)	AS '@NewMasterPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'), 
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
						    cs.isAutoMasterPT								AS '@IsAutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@AgentMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewMasterPT    /100.0)	AS '@NewMasterPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'), 
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
						    cs.isAutoMasterPT								AS '@IsAutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@AgentMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewMasterPT    /100.0)	AS '@NewMasterPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'), 
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
						    cs.isAutoMasterPT								AS '@IsAutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
						    CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@AgentMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewMasterPT    /100.0)	AS '@NewMasterPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'), 
        TYPE
	)
	END
	
    SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	

	SET @AutoPT =(
		SELECT cs.sporttype AS '@SportType'
			,cs.bettype AS '@BetType'
			,cs.isLive AS '@IsLive'						
			,t.isAutoMasterPT AS '@IsAuto_New'
			,cs.isAutoMasterPT AS '@IsAuto_Old'	
			,t.UpdAllMems AS '@IsUpdAllMems'		
			,t.NewMasterPT AS '@UpdAllMems_Value'
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
		WHERE custid = @custid AND (t.IsAutoMasterPT <> cs.IsAutoMasterPT OR t.AutoMasterPT <> cs.AutoMasterPT)
		FOR XML PATH('PT'), ROOT('ROOT')
	 ) 			
    
     --check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,212)) 
		OR EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
						AND (cs.MasterPT <> t.MasterPT
							OR cs.IsAutoMasterPT <> t.IsAutoMasterPT
							OR cs.AutoMasterPT <> t.AutoMasterPT
							OR cs.AgentPT <> t.AgentPT				
					)
				)
	BEGIN
		SELECT @UpdatePresetPT = 1
	END
	
	IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,212)) 
		OR EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
					WHERE custid = @custid
						AND cs.MinPT <> t.AgentMinPT			
					)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	EXEC Acc_CustSetting_AgentPTCheck
		@custid		= @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		
		@PT			= @PT,
		@UpdateMinPT = @UpdateMinPT,
		@UpdatePresetPT = @UpdatePresetPT,
					
		@ErrCode	= @ErrCode OUTPUT,
		@MsgType	= @MsgType OUTPUT,
		@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN
	
	 --update data change into db
	 UPDATE cs
	SET cs.MasterPT = b.MasterPT
		,cs.IsAutoMasterPT = b.IsAutoMasterPT
		,cs.AutoMasterPT = b.AutoMasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.AgentMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.MasterPT <> b.MasterPT
			OR cs.isAutoMasterPT <> b.isAutoMasterPT
			OR cs.AutoMasterPT <> b.AutoMasterPT			
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.AgentMinPT					
		)
	
	IF @UpdateMinPT = 1 
	BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_04 
			@AgentID = @custid
			,@MasterID = @mrecommend
			,@SuperID = @srecommend
			,@RoleID = 2
			,@SportBettypeXML = @PT

		-- The minimum position taking value of agent was modified by agent's upline
		EXEC DBONUSER.On_User.dbo.Age_MessageNoticeUpd @custID = @custid, @userID = @UserID 
	END
	
	IF @UpdatePresetPT = 1 
	BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_05
			@SuperID = @Srecommend
            ,@MasterID = @mrecommend
			,@AgentID = @custid
			,@RoleID = 2
            ,@AutoPT = @AutoPT
            
       EXEC dbo.Acc_DynamicCustSetting3rd_07 
			@SuperID = @Srecommend
            ,@MasterID = @mrecommend
			,@AgentID = @custid
			,@RoleID = 2
			,@SportBettypeXML = @PT
	END	
	
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
                            cs.isAutoMasterPT								AS '@IsAutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
                            CONVERT(DECIMAL(10,2), cs.AgentMinPT	/100.0)	AS '@AgentMinPT',
                            cs.UpdAllMems									AS '@UpdAllMems',
                            CONVERT(DECIMAL(10,2), cs.NewMasterPT	/100.0)	AS '@NewMasterPT'
				    FROM    @tblPT cs	
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'),
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
                            cs.isAutoMasterPT								AS '@IsAutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
                            CONVERT(DECIMAL(10,2), cs.AgentMinPT	/100.0)	AS '@AgentMinPT',
                            cs.UpdAllMems									AS '@UpdAllMems',
                            CONVERT(DECIMAL(10,2), cs.NewMasterPT	/100.0)	AS '@NewMasterPT'
				    FROM    @tblPT cs	
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'),
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
                            cs.isAutoMasterPT								AS '@IsAutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
                            CONVERT(DECIMAL(10,2), cs.AgentMinPT	/100.0)	AS '@AgentMinPT',
                            cs.UpdAllMems									AS '@UpdAllMems',
                            CONVERT(DECIMAL(10,2), cs.NewMasterPT	/100.0)	AS '@NewMasterPT'
				    FROM    @tblPT cs	
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'),
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
                            cs.isAutoMasterPT								AS '@IsAutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AutoMasterPT	/100.0)	AS '@AutoMasterPT',
                            CONVERT(DECIMAL(10,2), cs.AgentPT		/100.0)	AS '@AgentPT',
                            CONVERT(DECIMAL(10,2), cs.AgentMinPT	/100.0)	AS '@AgentMinPT',
                            cs.UpdAllMems									AS '@UpdAllMems',
                            CONVERT(DECIMAL(10,2), cs.NewMasterPT	/100.0)	AS '@NewMasterPT'
				    FROM    @tblPT cs	
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_AgentPTUpd'),
        TYPE				
	)
	END
	
	SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 454,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 454,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END CATCH 
    
    
				
END
 GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_AgentPTUpd] TO [bodbExtAccNet]
GO 	