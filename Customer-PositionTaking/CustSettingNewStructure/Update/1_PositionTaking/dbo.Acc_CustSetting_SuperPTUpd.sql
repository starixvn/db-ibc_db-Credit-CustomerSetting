 ALTER PROCEDURE [dbo].[Acc_CustSetting_SuperPTUpd]
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,       
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @MsgType	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(4000) = '' OUTPUT
AS
	/*
		Created: Johnson
		Date: 2014-11-24
		Task: Update pt on super
		DB: DBCUST/CustDB
		
		Revisions:
            - 20151015@Billy: Fix log xml structure and naming
			- 20151103@Billy: Change log PT value range from [0,90] to [0,0.9] and update log structure - [Redmine: #46781, #46788]
			- 20160122@Helen: AllBet - always correct PT for Allbet
			- 20160408@Winnie: VoidBridge - always correct PT for VoidBridge [RedmineID: #55532]
		Parameter's Explanation:
			@PT = <ROOT>
					<PT SportType="1" BetType="1" IsLive="0" SuperPT="90" MasterPT ="90" AgentPT = "90" MinPT="0"/>
					<PT SportType="1" BetType="1" IsLive="1" SuperPT="90" MasterPT ="90" AgentPT = "90" MinPT="0"/>
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
			,@xml			XML
			,@UpdateMinPT BIT
			,@UpdatePresetPT BIT

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
        ,@roleid		= 4
        ,@isExecRep		= 1
        ,@isUpdatePT	= 1
        ,@Sporttype		= 1
        ,@Language		= 'E'
        ,@ErrMsg		= @ErrMsg OUTPUT
        ,@ErrCode		= @ErrCode OUTPUT
    IF    @ErrCode <> 0 
    BEGIN
		SELECT @MsgType = 101
		RETURN 
	END
    ----------
    
    IF @PT = '' RETURN 

    DECLARE @username VARCHAR(40)
	
	SELECT @username = username 
	FROM custinfo WITH (NOLOCK) 
	WHERE custid = @custid
	
	DECLARE @tmpPTGroup TABLE(custid INT)

	DECLARE @tblPT TABLE (
				SportType	SMALLINT,
				BetType		SMALLINT,
				IsLive		BIT,
				SuperPT		SMALLINT,
				MasterPT	SMALLINT,
				AgentPT		SMALLINT,
				SuperMinPT	SMALLINT
				)	
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperPT,
				MasterPT,
				AgentPT,
				SuperMinPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,
		SuperPT,
		MasterPT,
		AgentPT,
		MinPT
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  @ProductID									AS '@ProductID',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.SportType								AS '@SportType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'), 
			TYPE
		)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.SportType								AS '@SportType',
								cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'), 
			TYPE
		)
	END

	SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	--check PT change or not	
	SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
	IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,212))  
		OR	EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
					WHERE custid = @custid
						AND (cs.SuperPT <> t.SuperPT
							OR cs.MasterPT <> t.MasterPT
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
						AND cs.MinPT <> t.SuperMinPT			
	)
	BEGIN
		SELECT @UpdateMinPT = 1
	END
	
	--No PT change
	IF @UpdateMinPT = 0 AND @UpdatePresetPT = 0
		RETURN
	
	EXEC Acc_CustSetting_SuperPTCheck 
			@custid		= @custid,
			@PT			= @PT,	
			@UpdatePresetPT = @UpdatePresetPT,	
			@MsgType	= @MsgType OUTPUT,		
			@ErrCode	= @ErrCode OUTPUT,
			@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN		
	
	--Update data change
	UPDATE cs
	SET cs.SuperPT = b.SuperPT
		,cs.MasterPT = b.MasterPT
		,cs.AgentPT = b.AgentPT
		,cs.MinPT = b.SuperMinPT
		,cs.MaxPT = b.SuperPT	
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND (
				cs.SuperPT <> b.SuperPT
			OR cs.MasterPT <> b.MasterPT
			OR cs.AgentPT <> b.AgentPT
			OR cs.MinPT <> b.SuperMinPT					
		)
	
	IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg = '<Root MsgID="90001" Msg="Update process is unsuccessful !" />'
                        , @ErrCode = 109                    
						, @MsgType = 100--just return msgID
        RETURN
    END
    
    IF @UpdatePresetPT = 1 
    BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_07 
			@SuperID = @custid
			,@RoleID = 4
			,@SportBettypeXML = @PT  
		
		--EXEC dbo.Acc_DynamicCustSetting3rd_01 
		--	@SuperID = @custid
		--	,@SportBettypeXML = @PT 
    END
    
    IF @UpdateMinPT = 1 
    BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_04 
			@SuperID = @custid
			,@RoleID = 4
			,@SportBettypeXML = @PT 
    END
    
    -- Log new updated data
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  @ProductID									AS '@ProductID',
								cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs							
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'),
			TYPE				
		)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.SportType								AS '@SportType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs							
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'),
			TYPE				
		)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs							
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'),
			TYPE				
		)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.SportType								AS '@SportType',
								cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								CONVERT(DECIMAL(10,2), cs.SuperPT   /100.0)	AS '@SuperPT',
								CONVERT(DECIMAL(10,2), cs.MasterPT  /100.0)	AS '@MasterPT',
								CONVERT(DECIMAL(10,2), cs.AgentPT   /100.0)	AS '@AgentPT',
								CONVERT(DECIMAL(10,2), cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs							
						FOR XML PATH('PT'), 
						TYPE
					)
			FOR XML PATH('Acc_CustSetting_SuperPTUpd'),
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
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END	TRY
	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID = @UserID,
			@CustID = @CustID,
			@ActionID = 448,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration
	END CATCH 
 
END
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbAdminNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbDownlineNet]
GO 
GRANT EXECUTE ON [dbo].[Acc_CustSetting_SuperPTUpd] TO [bodbExtAccNet]
GO 