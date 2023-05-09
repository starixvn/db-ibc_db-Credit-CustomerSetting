/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_SuperMinPTUpd
	@custid		INT,
	@PT			VARCHAR(MAX),
	@UserID		INT = 0,       
    @IP			VARCHAR(15)='',
    @ErrCode	INT = 0 OUTPUT,
    @MsgType	INT = 0 OUTPUT,
    @ErrMsg		NVARCHAR(MAX) = '' OUTPUT, 
	@SettingStatus TINYINT = 0
AS
/*
	Created: Elodie
	Date: 2020-06-26
	Task: Update MinPT on super
	DB: DBCUST/CustDB
		
	Revisions:
        - 20200626@Elodie: Initial SP [Redmine:#135363]
		- 20200708@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20201022@Elodie: Change datatype of PT from tinyint to smallmoney  [Redmine: #143764]
		- 20221222@Winfred: Update Correct PT for RNG SLOT [RedmineID: #181929]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230410@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]

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
				SuperMinPT	SMALLMONEY,
				RID INT Identity(1,1)
				)	
				
	-- For read xml
	INSERT INTO @tblPT(
				SportType,
				BetType,
				IsLive,
				SuperMinPT
			)
	SELECT
		SportType,
		BetType,
		IsLive,
		MinPT
	FROM dbo.f_DCS_PT_XMLParse(@PT)
	-- end read xml

	CREATE TABLE #ProductSettingDetail_SMinUpd(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[MaxPT]	[smallmoney],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_SMinUpd(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT
	FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM @tblPT t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
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

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		#ProductSettingDetail_SMinUpd AS psd WITH(NOLOCK)
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  @ProductID									AS '@ProductID',
								cs.IsLive									AS '@IsLive',								
								dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.SportType								AS '@SportType',
								cs.IsLive									AS '@IsLive',								
								dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',								
								dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',				
					@IP				AS '@IP',
					(           
						SELECT  cs.SportType								AS '@SportType',
								cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',								
								dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT'
						FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
						INNER JOIN  @tblPT t 
								ON  cs.sporttype = t.SportType 
								AND cs.bettype = t.BetType 
								AND cs.isLive = t.IsLive
						WHERE       custid = @custid
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
						AND cs.MinPT <> t.SuperMinPT			
	)
	BEGIN
		RETURN
	END
	
	EXEC Acc_CustSetting_SuperMinPTCheck 
			@custid		= @custid,
			@PT			= @PT,	
			@MsgType	= @MsgType OUTPUT,		
			@ErrCode	= @ErrCode OUTPUT,
			@ErrMsg		= @ErrMsg OUTPUT
	
	IF @ErrCode > 0
		RETURN		
	
	--Update data change
	UPDATE cs
	SET cs.MinPT = b.SuperMinPT
	FROM CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK)
		INNER JOIN @tblPT b ON cs.Sporttype = b.SportType
								AND cs.bettype = b.BetType
								AND cs.isLive = b.IsLive								
	WHERE cs.custid = @custid
		AND cs.MinPT <> b.SuperMinPT						
	
	IF (@@ERROR <> 0)
    BEGIN
        SELECT @ErrMsg = '<Root MsgID="90001" Msg="Update process is unsuccessful !" />'
                        , @ErrCode = 109                    
						, @MsgType = 100--just return msgID
        RETURN
    END
    
	EXEC dbo.Acc_DynamicCustSetting3rd_04 
		@SuperID = @custid
		,@RoleID = 4
		,@SportBettypeXML = @PT 
    
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
								dbo.f_FomatNumericToChar(cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs	
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.SportType								AS '@SportType',
								cs.IsLive									AS '@IsLive',
								dbo.f_FomatNumericToChar(cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs	
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								dbo.f_FomatNumericToChar(cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs	
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
			SELECT  @ProductID		AS '@ProductID',
					@ProductName	AS '@ProductName',
					@custid			AS '@CustID',
					@userid			AS '@UserID',
					@IP				AS '@IP',
					(
						SELECT  cs.SportType								AS '@SportType',
								cs.BetType									AS '@BetType',
								cs.IsLive									AS '@IsLive',
								dbo.f_FomatNumericToChar(cs.SuperMinPT/100.0)	AS '@SuperMinPT'
						FROM    @tblPT	cs	
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
			@ActionID = 508,
			@TrackingValue = @LogSPData,
			@TrackingValue2 = @logSPData_Old,
			@duration = @duration

	DROP TABLE #ProductSettingDetail_SMinUpd
END
GO