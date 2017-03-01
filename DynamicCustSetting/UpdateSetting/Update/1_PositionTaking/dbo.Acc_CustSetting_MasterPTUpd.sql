ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPTUpd]
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
		Date: 2014-12-2
		Task: Update pt on Master
		DB: DBCUST/CustDB
		
		Revisions:
            - 20151015@Billy: Fix log xml structure and naming
			- 20151104@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]
			- 20160122@Helen: AllBet - always correct PT for Allbet
			- 20160408@Winnie: VoidBridge - always correct PT for VoidBridge [RedmineID: #55532]
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MinPT="0" IsUpdAllMems="1" UpdAllMems_Value="20"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="30" IsAutoSuperPT = "0" AutoSuperPT = "0" MasterPT ="60" MinPT="0" IsUpdAllMems="0" UpdAllMems_Value="0"/>
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
			,@xml			XML
	  SET @startRun = GETDATE()

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT
			
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
        ,@roleid		= 3
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

    DECLARE @username VARCHAR(40), @srecommend INT
	
	SELECT @username = username, @srecommend = srecommend 
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	DECLARE @tblPT TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLINT,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLINT,
				MasterPT		SMALLINT,				
				MasterMinPT		SMALLINT,
				UpdAllMems		BIT,
				NewSuperPT		SMALLINT
				)			
	
	-- For read xml 				
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				IsAutoSuperPT,
				AutoSuperPT,
				MasterPT,				
				MasterMinPT,
				UpdAllMems,
				NewSuperPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,
		SuperPT,
		IsAutoSuperPT,
		AutoSuperPT,
		MasterPT,		
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
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@MasterMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewSuperPT		/100.0)	AS '@NewSuperPT'
					FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
					INNER JOIN  @tblPT t 
                            ON  cs.sporttype = t.SportType 
							AND cs.bettype = t.BetType 
							AND cs.isLive = t.IsLive
					WHERE       custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'), 
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
					SELECT  cs.SportType									AS '@SportType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@MasterMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewSuperPT		/100.0)	AS '@NewSuperPT'
					FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
					INNER JOIN  @tblPT t 
                            ON  cs.sporttype = t.SportType 
							AND cs.bettype = t.BetType 
							AND cs.isLive = t.IsLive
					WHERE       custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'), 
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
					SELECT  cs.BetType										AS '@BetType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@MasterMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewSuperPT		/100.0)	AS '@NewSuperPT'
					FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
					INNER JOIN  @tblPT t 
                            ON  cs.sporttype = t.SportType 
							AND cs.bettype = t.BetType 
							AND cs.isLive = t.IsLive
					WHERE       custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'), 
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
					SELECT  cs.SportType									AS '@SportType',
						    cs.BetType										AS '@BetType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MinPT			/100.0)	AS '@MasterMinPT',
						    t.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), t.NewSuperPT		/100.0)	AS '@NewSuperPT'
					FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
					INNER JOIN  @tblPT t 
                            ON  cs.sporttype = t.SportType 
							AND cs.bettype = t.BetType 
							AND cs.isLive = t.IsLive
					WHERE       custid = @custid
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'), 
        TYPE
	)
	END
	
	SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
    SET @AutoPT =(
		SELECT cs.sporttype AS '@SportType'
			,cs.bettype AS '@BetType'
			,cs.isLive AS '@IsLive'			
			,t.isAutoSuperPT AS '@IsAuto_New'
			,cs.isAutoSuperPT AS '@IsAuto_Old'	
			,t.UpdAllMems AS '@IsUpdAllMems'
			,t.NewSuperPT AS '@UpdAllMems_Value'
		FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
			INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
		WHERE custid = @custid AND (t.IsAutoSuperPT <> cs.IsAutoSuperPT OR t.AutoSuperPT <> cs.AutoSuperPT)
		FOR XML PATH('PT'), ROOT('ROOT')
	 )
	 
    --Check Param
    DECLARE @UpdateMinPT BIT
			,@UpdatePresetPT BIT
    
    --check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,212)) 
		OR EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
				WHERE custid = @custid
					AND (cs.SuperPT <> t.SuperPT
						OR cs.IsAutoSuperPT <> t.IsAutoSuperPT
						OR cs.AutoSuperPT <> t.AutoSuperPT
						OR cs.MasterPT <> t.MasterPT				
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
						AND cs.MinPT <> t.MasterMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0 
		RETURN
	
	EXEC Acc_CustSetting_MasterPTCheck
		@custid		= @custid,	
		@srecommend = @srecommend,
		
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
	SET cs.SuperPT = b.SuperPT
		,cs.MasterPT = b.MasterPT
		,cs.IsAutoSuperPT = b.IsAutoSuperPT
		,cs.AutoSuperPT = b.AutoSuperPT
		,cs.MinPT = b.MasterMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.SuperPT <> b.SuperPT
			OR cs.isAutoSuperPT <> b.IsAutoSuperPT
			OR cs.AutoSuperPT <> b.AutoSuperPT			
			OR cs.MasterPT <> b.MasterPT
			OR cs.MinPT <> b.MasterMinPT					
		)
	
	IF @UpdateMinPT = 1 
	BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_04 
				@MasterID = @custid
				,@SuperID = @srecommend
				,@RoleID = 3
				,@SportBettypeXML = @PT
	END
	
	IF @UpdatePresetPT = 1 
	BEGIN
		 EXEC dbo.Acc_DynamicCustSetting3rd_05
            @SuperID = @srecommend,
            @MasterID = @custid,
            @RoleID = 3,          
            @AutoPT = @AutoPT
           
         EXEC dbo.Acc_DynamicCustSetting3rd_07
            @SuperID = @srecommend
            ,@MasterID = @custid
            ,@RoleID = 3
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
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MasterMinPT	/100.0)	AS '@MasterMinPT',
						    cs.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), cs.NewSuperPT	/100.0)	AS '@NewSuperPT'
					FROM    @tblPT cs							
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'),
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
					SELECT  cs.SportType									AS '@SportType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MasterMinPT	/100.0)	AS '@MasterMinPT',
						    cs.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), cs.NewSuperPT	/100.0)	AS '@NewSuperPT'
					FROM    @tblPT cs							
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'),
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
					SELECT  cs.BetType										AS '@BetType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MasterMinPT	/100.0)	AS '@MasterMinPT',
						    cs.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), cs.NewSuperPT	/100.0)	AS '@NewSuperPT'
					FROM    @tblPT cs							
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'),
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
					SELECT  cs.SportType									AS '@SportType',
						    cs.BetType										AS '@BetType',
						    cs.IsLive										AS '@IsLive',
						    CONVERT(DECIMAL(10,2), cs.SuperPT		/100.0)	AS '@SuperPT',
						    cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
						    CONVERT(DECIMAL(10,2), cs.MasterPT		/100.0)	AS '@MasterPT',
						    CONVERT(DECIMAL(10,2), cs.MasterMinPT	/100.0)	AS '@MasterMinPT',
						    cs.UpdAllMems									AS '@UpdAllMems',
						    CONVERT(DECIMAL(10,2), cs.NewSuperPT	/100.0)	AS '@NewSuperPT'
					FROM    @tblPT cs							
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('Acc_CustSetting_MasterPTUpd'),
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
			@ActionID = 449,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 449,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END CATCH 
		
END	
 GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_MasterPTUpd] TO [bodbExtAccNet]
GO 