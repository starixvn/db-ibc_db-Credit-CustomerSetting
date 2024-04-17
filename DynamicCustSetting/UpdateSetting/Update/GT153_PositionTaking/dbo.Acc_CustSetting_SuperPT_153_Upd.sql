/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE Acc_CustSetting_SuperPT_153_Upd
	@custid				INT,
	@PT					VARCHAR(MAX) = NULL,
	@OnlyMinPT			VARCHAR(MAX) = NULL,
	@UserID				INT = 0,       
    @IP					VARCHAR(15)='',
    @ErrCode			INT = 0 OUTPUT,
    @MsgType			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(MAX) = '' OUTPUT, 
	@SettingStatus		TINYINT = 0,
	@GroupType			SMALLINT = 153,
	@GroupID			TINYINT = 1 -- default SB
AS
/*
	Created: 20231101@Eden
	Task : Update PT of super
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]

	Parameter's Explanation:
		@PT/@OnlyMinPT = [
				{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "87"},
				{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
				{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
				{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
				{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
				{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"},
				{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "90","MasterPT": "89","AgentPT": "88","MinPT": "85"}
			]
				
	*/
BEGIN
	SET NOCOUNT ON

	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @PT OUTPUT
	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @OnlyMinPT OUTPUT
	
	IF @OnlyMinPT IS NOT NULL AND @OnlyMinPT <> '' AND @OnlyMinPT <> '<ROOT></ROOT>'
	BEGIN
		EXEC Acc_CustSetting_SuperMinPT_153_Upd
			@custid		= @custid,
			@PT			= @OnlyMinPT,	
			@UserID		= @UserID,
			@IP			= @IP,
			@MsgType	= @MsgType OUTPUT,		
			@ErrCode	= @ErrCode OUTPUT,
			@ErrMsg		= @ErrMsg OUTPUT,
			@SettingStatus = @SettingStatus,
			@GroupType = @GroupType,
			@GroupID = @GroupID

		IF @ErrCode > 0	AND @ErrCode <> 90017
				RETURN
	END

	IF @PT IS NOT NULL AND @PT <> '' AND @PT <> '<ROOT></ROOT>'
	BEGIN
		IF @ErrCode = 90017
			SELECT @ErrCode = 0 , @ErrMsg = ''
		
		DECLARE @roleid			TINYINT			
				,@startRun		DATETIME
				,@endRun		DATETIME
				,@duration		INT
				,@logSPData		VARCHAR(5000)
				,@logSPData_Old	VARCHAR(5000)
				,@xml			XML
				,@UpdateMinPT	BIT
				,@UpdatePresetPT BIT
    
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

		DECLARE @username VARCHAR(40)
	
		SELECT @username = username 
		FROM custinfo WITH (NOLOCK) 
		WHERE custid = @custid
	
		DECLARE @tmpPTGroup TABLE(custid INT)

		DECLARE @tblPT TABLE (
					SportType	SMALLINT,
					BetType		SMALLINT,
					IsLive		BIT,
					SuperPT		SMALLMONEY,
					MasterPT	SMALLMONEY,
					AgentPT		SMALLMONEY,
					SuperMinPT	SMALLMONEY,
					SettingLevel TINYINT,
					ProductID TINYINT,
					Child_DisplayOrder TINYINT
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


		DECLARE  @SiteID SMALLINT,
			@Currency SMALLINT	
	
		SELECT  @siteID = s.siteID,
				@Currency = c.currency
		FROM Customer c with (NOLOCK)
			INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
		WHERE custid = @custid

		CREATE TABLE #ProductSettingDetail(
			[SettingType] [smallint],
			[SportType] [smallint],
			[BetType] [smallint],
			[IsLive] [bit] ,
			[ProductID] [tinyint],
			[SettingLevel] [tinyint],
			[MaxPT]	[smallmoney],
			Child_DisplayOrder TINYINT,
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
		)

		INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT,Child_DisplayOrder)
		SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,MaxPT,Child_DisplayOrder
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
		WHERE Grouptype = @GroupType
			AND (GroupID = @GroupID OR @GroupID IS NULL)
	
		-- end read xml	

		--Exclude Update for Sport is having UM
		DELETE t
		FROM @tblPT t
			INNER JOIN #ProductSettingDetail ps 
				ON ps.BetType = t.BetType AND ps.SportType = t.SportType
			INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
				ON u.SportType IN( t.SportType,0)
				AND u.SettingType IN (ps.SettingType,0)
				AND u.ProductID  IN (ps.ProductID, 0)
		WHERE u.FunctionType = 1 --Edit Customer

		IF NOT EXISTS( SELECT 1 FROM @tblPT)
		BEGIN
			SELECT @ErrCode = 90017,
					@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

			RETURN
		END
		
		UPDATE tmp
		SET tmp.SettingLevel = psd.SettingLevel,
			tmp.ProductID = psd.ProductID,
			tmp.Child_DisplayOrder = psd.Child_DisplayOrder
		FROM @tblPT tmp
			INNER JOIN #ProductSettingDetail psd
				ON	psd.SportType = tmp.SportType
						AND	psd.BetType = tmp.BetType
						AND psd.IsLive = tmp.IsLive

		-- Log old data
		SET @xml = (
				SELECT  @custid			AS '@CustID',			
						@IP				AS '@IP',
						(           
							SELECT  @GroupID									AS '@GroupID',
									t.ProductID									AS '@ProductID',
									cs.SportType								AS '@SportType',
									cs.BetType									AS '@BetType',
									cs.IsLive									AS '@IsLive',
									dbo.f_FomatNumericToChar(cs.SuperPT   /100.0)	AS '@SuperPT',
									dbo.f_FomatNumericToChar(cs.MasterPT  /100.0)	AS '@MasterPT',
									dbo.f_FomatNumericToChar(cs.AgentPT   /100.0)	AS '@AgentPT',
									dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT',
									t.SettingLevel									AS '@SettingLevel'
							FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							ORDER BY t.Child_DisplayOrder
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('ROOT'), 
				TYPE
			)

		SET @logSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
		--check PT change or not	
		SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
		IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906))  
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
	
		IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906)) 
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
	
		EXEC Acc_CustSetting_SuperPT_153_Check 
				@custid		= @custid,
				@PT			= @PT,	
				@UpdatePresetPT = @UpdatePresetPT,	
				@MsgType	= @MsgType OUTPUT,		
				@ErrCode	= @ErrCode OUTPUT,
				@ErrMsg		= @ErrMsg OUTPUT,
				@GroupID = @GroupID,
				@GroupType = @GroupType,
				@SettingStatus = @SettingStatus
	
		IF @ErrCode > 0
			RETURN		
	
		--Update data change
		UPDATE cs
		SET cs.SuperPT = b.SuperPT
			,cs.MasterPT = b.MasterPT
			,cs.AgentPT = b.AgentPT
			,cs.MinPT = b.SuperMinPT
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
		END
    
		IF @UpdateMinPT = 1 
		BEGIN
			EXEC dbo.Acc_DynamicCustSetting3rd_04 
				@SuperID = @custid
				,@RoleID = 4
				,@SportBettypeXML = @PT 
		END

		-- Log new updated data
		SET @xml = (
				SELECT  @custid			AS '@CustID',			
						@IP				AS '@IP',
						(           
							SELECT  @GroupID									AS '@GroupID',
									t.ProductID									AS '@ProductID',
									cs.SportType								AS '@SportType',
									cs.BetType									AS '@BetType',
									cs.IsLive									AS '@IsLive',
									dbo.f_FomatNumericToChar(cs.SuperPT   /100.0)	AS '@SuperPT',
									dbo.f_FomatNumericToChar(cs.MasterPT  /100.0)	AS '@MasterPT',
									dbo.f_FomatNumericToChar(cs.AgentPT   /100.0)	AS '@AgentPT',
									dbo.f_FomatNumericToChar(cs.MinPT     /100.0)	AS '@SuperMinPT',
									t.SettingLevel									AS '@SettingLevel'
							FROM        CustPTSetting3rd_Agent cs WITH(NOLOCK)
							INNER JOIN  @tblPT t 
									ON  cs.sporttype = t.SportType 
									AND cs.bettype = t.BetType 
									AND cs.isLive = t.IsLive
							WHERE       custid = @custid
							ORDER BY t.Child_DisplayOrder
							FOR XML PATH('PT'), 
							TYPE
						)
				FOR XML PATH('ROOT'), 
				TYPE
			)
	
		SET @logSPData = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
	
		SELECT @logSpData_Old = LogStr 
		FROM f_CustSetting_FormatLog (@logSpData_Old)
		SELECT @logSpData = LogStr 
		FROM f_CustSetting_FormatLog (@logSpData)

		-- end write log
		SET @endRun		= GETDATE()  
		SET @duration	= DATEDIFF(MILLISECOND, @startRun, @endRun) 

		DECLARE @ActionID INT

		SELECT @ActionID = CASE WHEN @GroupID = 1 THEN 511 
							END
						
		EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
				
		DROP TABLE #ProductSettingDetail
	END
END
GO
