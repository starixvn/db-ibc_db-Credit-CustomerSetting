/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbExtAccNet,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MasterPT_153_Upd]
	@custid				INT,
	@PT					VARCHAR(MAX) = NULL,
	@OnlyMinPT			VARCHAR(MAX) = NULL,
	@SubAccID			INT = 0,
	@UserID				INT = 0,        
    @IP					VARCHAR(15)='',   
    @ErrCode			INT = 0 OUTPUT,
    @MsgType			INT = 0 OUTPUT,
    @ErrMsg				NVARCHAR(MAX) = '' OUTPUT,
	@SettingStatus		TINYINT = 0,
	@GroupType SMALLINT = 153,
	@GroupID			TINYINT = 1 -- default SB
AS
/*
	Created: 20231101@Eden
	Task : Update pt on Master
	DB: DBCUST/CustDB
	Original:

	Revision:
		- 20231101@Eden: DCS Sportsbook Credit[redmine: #193083]

	Parameter's Explanation:
		@PT/ @OnlyMinPT = [
			{"SportType": "9914","BetType": "915","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9914","BetType": "917","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9913","BetType": "917","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9915","BetType": "918","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9913","BetType": "915","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9913","BetType": "916","IsLive": "1","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"},
			{"SportType": "9914","BetType": "916","IsLive": "0","SuperPT": "30","IsAutoSuperPT": "0","AutoSuperPT": "0.0000","MasterPT": "58","MinPT": "0","IsUpdAllMems": "0","UpdAllMems_Value": "0"}
		]
				
*/
BEGIN
	SET NOCOUNT ON
	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @PT OUTPUT
	EXEC Acc_CustSetting_PT_JsonParse @PTSetting = @OnlyMinPT OUTPUT

	IF @OnlyMinPT IS NOT NULL AND @OnlyMinPT <> '' AND @OnlyMinPT <> '<ROOT></ROOT>'
	BEGIN
		EXEC Acc_CustSetting_MasterMinPT_153_Upd
			@custid		= @custid,
			@PT			= @OnlyMinPT,	
			@SubAccID	= @SubAccID,
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
				,@AutoPT		VARCHAR(MAX)		
				,@xml			XML
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
		DECLARE  @SiteID SMALLINT,
			@Currency SMALLINT,
			@username VARCHAR(40), 
			@srecommend INT
	
		SELECT  @siteID = s.siteID,
				@Currency = c.currency,
				@username = c.username, 
				@srecommend = c.srecommend 
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
			Child_DisplayOrder TINYINT,
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
		)
 
		INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder)
		SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,Child_DisplayOrder
		FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
		WHERE Grouptype = @GroupType
			AND (GroupID = @GroupID OR @GroupID IS NULL)
	
		DECLARE @tblPT TABLE (
					SportType		SMALLINT,
					BetType			SMALLINT,
					IsLive			BIT,
					SuperPT			SMALLMONEY,
					IsAutoSuperPT	BIT,
					AutoSuperPT		SMALLMONEY,
					MasterPT		SMALLMONEY,				
					MasterMinPT		SMALLMONEY,
					UpdAllMems		BIT,
					NewSuperPT		SMALLMONEY,
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
			SELECT  @custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',		
					@IP                             AS '@IP',		
					(
						SELECT  @GroupID									AS '@GroupID',
								t.ProductID									AS '@ProductID',
								cs.SportType									AS '@SportType',
								cs.BetType										AS '@BetType',
								cs.IsLive										AS '@IsLive',
								dbo.f_FomatNumericToChar(cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
								dbo.f_FomatNumericToChar(cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
								dbo.f_FomatNumericToChar(cs.MasterPT		/100.0)	AS '@MasterPT',
								dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@MasterMinPT',
								t.UpdAllMems										AS '@UpdAllMems',
								dbo.f_FomatNumericToChar(t.NewSuperPT		/100.0)	AS '@NewSuperPT',
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
			ORDER BY t.Child_DisplayOrder
			FOR XML PATH('PT'), ROOT('ROOT')
		 )
	 
		--Check Param
		DECLARE @UpdateMinPT BIT
				,@UpdatePresetPT BIT
    
		--check PT change or not	
		SELECT @UpdateMinPT =0, @UpdatePresetPT = 0
	
		IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906)) 
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
	
		IF EXISTS (SELECT 1 FROM @tblPT WHERE SportType IN (211,9906)) 
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
	
		EXEC Acc_CustSetting_MasterPT_153_Check
			@custid		= @custid,	
			@srecommend = @srecommend,
		
			@PT			= @PT,
			@UpdateMinPT = @UpdateMinPT, 
			@UpdatePresetPT = @UpdatePresetPT,
				
			@ErrCode	= @ErrCode OUTPUT,
			@MsgType	= @MsgType OUTPUT,	
			@ErrMsg		= @ErrMsg OUTPUT,
			@GroupID = @GroupID,
			@GroupType = @GroupType,
			@SettingStatus = @SettingStatus
	
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
		SET @xml = (
			SELECT  @custid                         AS '@CustID',
					dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',			
					@IP                             AS '@IP',		
					(
						SELECT  @GroupID									AS '@GroupID',
								t.ProductID									AS '@ProductID',
								cs.SportType									AS '@SportType',
								cs.BetType										AS '@BetType',
								cs.IsLive										AS '@IsLive',
								dbo.f_FomatNumericToChar(cs.SuperPT		/100.0)	AS '@SuperPT',
								cs.IsAutoSuperPT								AS '@IsAutoSuperPT',
								dbo.f_FomatNumericToChar(cs.AutoSuperPT	/100.0)	AS '@AutoSuperPT',
								dbo.f_FomatNumericToChar(cs.MasterPT		/100.0)	AS '@MasterPT',
								dbo.f_FomatNumericToChar(cs.MinPT			/100.0)	AS '@MasterMinPT',
								t.UpdAllMems										AS '@UpdAllMems',
								dbo.f_FomatNumericToChar(t.NewSuperPT		/100.0)	AS '@NewSuperPT',
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

		SELECT @ActionID = CASE WHEN @GroupID = 1 THEN 512 
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
