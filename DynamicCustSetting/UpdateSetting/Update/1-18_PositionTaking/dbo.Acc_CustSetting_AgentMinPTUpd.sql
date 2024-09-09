 /*<info serverAlias="DBCUST-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_AgentMinPTUpd]
	@custid				INT,
	@PT					VARCHAR(MAX),
	@SubAccID			INT = 0,
	@UserID				INT = 0,       
    @IP					VARCHAR(15)='', 
    @IsCountPT			BIT = 1,     
    @ErrCode			INT = 0 OUTPUT,
    @MsgType			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(MAX) = '' OUTPUT, 
	@SettingStatus TINYINT = 0
 AS
/*
	Created: Elodie
	Date: 20200626
	Task: Update Min pt on Agent
	DB: DBCUST/CustDB
		
	Revisions:
        - 20200615@Elodie: Initial SP [Redmine: #135363]
		- 20200708@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20201026@Eden: Adjust new pt for 789y [Redmine: #143764]
		- 20210510@Eden: Enhancement for not relying on DB On_User [redmine: #154507]
		- 20211027@Winfred: NAP CM -  Limit Daily PT Update [Redmine: #162476]
		- 20221222@Winfred: Update Correct PT for RNG SLOT [RedmineID: #181929]
		- 20230104@Winfred: NAP CM -  Limit Monthly PT Update [Redmine: #182469]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230410@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 20240521@Helios: Unify RNG Games - Use ProductSettingProfile Table instead of ProductSettingDetail table [Redmine: #204358]
		
	Parameter's Explanation:
		@PT = <ROOT>
				<PT SportType="1" BetType="1" IsLive="0" MinPT="0"/>
				<PT SportType="1" BetType="1" IsLive="1" MinPT="0"/>
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
				AgentMinPT		SMALLMONEY,
				RID INT Identity(1,1)
				)	
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				AgentMinPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,		
		MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT)
	-- end read xml	

	CREATE TABLE #ProductSettingProfile_AMinUpd(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingProfile_AMinUpd(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN dbo.ProductSettingProfile ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType IN(1,18)
		AND u.FunctionType = 1 --Edit Customer
	
	IF NOT EXISTS( SELECT 1 FROM @tblPT)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	-- check Limit Daily PT Update
	DECLARE  @isLimit BIT = 0 ,@isCancel BIT = 0, @LastUpdated DATE
	IF @IsCountPT = 1
	BEGIN
		EXEC dbo.Age_LimitPTDailyCheck    
			 @custid		= @custid
			,@Actorid		= @UserID
			,@UpdatePT		= @PT
			,@LastUpdated	= @LastUpdated OUTPUT
			,@isLimit		= @isLimit OUTPUT
			,@isCancel		= @isCancel OUTPUT
			,@SettingStatus = @SettingStatus
		IF @isCancel > 0	
		BEGIN
			
			SELECT @ErrMsg = '<Root MsgID="10068" Msg="'+ CAST (@LastUpdated AS VARCHAR(10)) +'"> </Root>'
                    , @ErrCode = 10068
                    , @MsgType = 6   
				RETURN
		END
	END 
	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		#ProductSettingProfile_AMinUpd AS psd WITH(NOLOCK)
			INNER JOIN	@tblPT AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
					AND psd.IsLive = tmp.IsLive
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType IN (1,18)	-- Position Taking
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
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.RID
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('R'), 
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
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.RID
					FOR XML PATH('PT'), 
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
				@ProductName					AS '@ProductName',
				@custid                         AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
                @userid                         AS '@UserID',
                @IP                             AS '@IP',
                (
					SELECT  cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.RID
					FOR XML PATH('PT'), 
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
				@ProductName					AS '@ProductName',
				@custid                         AS '@CustID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
                @userid                         AS '@UserID',
                @IP                             AS '@IP',
                (
					SELECT  cs.sporttype									AS '@SportType',
                            cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
						    dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@AgentMinPT'
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
												AND cs.bettype = t.BetType 
												AND cs.isLive = t.IsLive
					WHERE custid = @custid
					ORDER BY t.RID
					FOR XML PATH('PT'), 
                    TYPE
				)
		FOR XML PATH('R'), 
        TYPE
	)
	END
	
    SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
	IF NOT EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906)) 
		AND NOT EXISTS (SELECT TOP 1 1
					FROM CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN @tblPT t ON cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
					WHERE custid = @custid
						AND cs.MinPT <> t.AgentMinPT			
					)
	BEGIN
		RETURN
	END
	
	EXEC Acc_CustSetting_AgentMinPTCheck
		@custid		= @custid,
		@srecommend = @srecommend,
		@mrecommend = @mrecommend,
		@PT			= @PT,
		@ErrCode	= @ErrCode OUTPUT,
		@MsgType	= @MsgType OUTPUT,
		@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN
	
	 --update data change into db
	 UPDATE cs
	SET cs.MinPT = b.AgentMinPT		
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND cs.MinPT <> b.AgentMinPT					
	
	EXEC dbo.Acc_DynamicCustSetting3rd_04 
		@AgentID = @custid
		,@MasterID = @mrecommend
		,@SuperID = @srecommend
		,@RoleID = 2
		,@SportBettypeXML = @PT

	-- The minimum position taking value of agent was modified by agent's upline
	EXEC dbo.Age_MessageNoticeUpd_Wrapper @custID = @custid, @userID = @UserID 
	
	IF @isLimit > 0
	BEGIN
		EXEC dbo.Age_LimitPTDailyUpd    
			 @custid		= @custid
			,@Actorid		= @UserID
			,@UpdatePT		= @PT
			,@ErrCode		= @ErrCode OUTPUT
			,@ErrMsg		= @ErrMsg OUTPUT
		IF @ErrCode > 0
		RETURN
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
                            dbo.f_FomatNumericToChar(cs.AgentMinPT	/100.0)	AS '@AgentMinPT'
				    FROM    @tblPT cs	
					ORDER BY cs.RID
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('R'),
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
                            dbo.f_FomatNumericToChar(cs.AgentMinPT	/100.0)	AS '@AgentMinPT'
				    FROM    @tblPT cs	
					ORDER BY cs.RID
				    FOR XML PATH('PT'),
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
				@ProductName					AS '@ProductName',
				@custid                         AS '@CustID',
			    dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
			    @userid                         AS '@UserID',
                @IP                             AS '@IP',
                (
				    SELECT  cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
                            dbo.f_FomatNumericToChar(cs.AgentMinPT	/100.0)	AS '@AgentMinPT'
				    FROM    @tblPT cs	
					ORDER BY cs.RID
				    FOR XML PATH('PT'),
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
				@ProductName					AS '@ProductName',
				@custid                         AS '@CustID',
			    dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
			    @userid                         AS '@UserID',
                @IP                             AS '@IP',
                (
				    SELECT  cs.sporttype									AS '@SportType',
                            cs.bettype										AS '@BetType',
                            cs.isLive										AS '@IsLive',
                            dbo.f_FomatNumericToChar(cs.AgentMinPT	/100.0)	AS '@AgentMinPT'
				    FROM    @tblPT cs
					ORDER BY cs.RID
				    FOR XML PATH('PT'),
                    TYPE
				)
		FOR XML PATH('R'),
        TYPE				
	)
	END
	
	SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)
	
	-- end write log
	SET @endRun		= GETDATE()  
	SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 
						
	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
		@UserID = @UserID,
		@CustID = @CustID,
		@ActionID = 510,
		@TrackingValue = @LogSPData,
		@TrackingValue2 = @logSPData_Old,
		@duration = @duration

	DROP TABLE #ProductSettingProfile_AMinUpd
END
GO
