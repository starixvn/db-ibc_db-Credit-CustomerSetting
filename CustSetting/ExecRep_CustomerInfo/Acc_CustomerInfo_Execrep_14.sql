/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap,wsv_alpv" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_14]
	@custid INT =0,
	@srecommend INT = 0,
	@mrecommend INT = 0,	
	@recommend INT = 0,
	@roleid INT,
	@siteid SMALLINT=0,
	@currency SMALLINT=0,
	
	--Discount	
	@SettingType25 VARCHAR(MAX)= '', --SB
	@SettingType19 VARCHAR(MAX)= '', --LCS
	@SettingType3 VARCHAR(MAX)= '', --Others Games
	
	--Bet Setting
	--@SettingType26 VARCHAR(MAX)= '', --SB
	@SettingType2 VARCHAR(MAX)= '', --SB2, VS
	@SettingType23 VARCHAR(MAX)= '', --RNG Games
	@SettingType16 VARCHAR(MAX)= '', --Others Games
	
	--Parlay Max Payout
	@SettingType27 VARCHAR(MAX)= '', --SB Parlay Max Payout
	
	--WinLoss Limit
	@SettingType6 VARCHAR(MAX)= '',-- VS
	@SettingType22 VARCHAR(MAX)= '', -- RNG Lottery, LCS
	
	--Loss Limit
	@SettingType12 VARCHAR(MAX)= '',-- BBIN
	
	--PT
	@SettingType28 VARCHAR(MAX)= '',-- SB
	@SettingType1 VARCHAR(MAX)= '',-- SB2, RNG(VS), LCS(VGgaming,Saba.Games,RNG Slot), NG2
	@SettingType18 VARCHAR(MAX)= '',-- RNG(Lottery, Table Game, Keno,NG), LCS(Allbet, SA Gaming,...)
	
	@SettingStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
	
AS
/*
		Created: 20230525@Johnson	
		Task: Apply execrep when insert customer settings
		DB: DBCUST/CustDB
		
		Revisions: 
			- 20230525@Johnson: initial sp [redmine: #179159]
			- 20231017@Johnson: extend MaxPT for SB = 0.93 [redmine:#195578]
			- 20230918@Eden: DCS Sportsbook Credit[redmine: #193083]
			- 20240610@Johnson: Scale out DBCUST [redmine: #199915]
			- 20240520@Eden: Unify RNG Games [redmine: #204358] 
			- 20241206@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
			- 20241107@Eden: Offer Direct Member for Super/Master [redmine: #211969]
			- 20250513@Johnson: Add Potential Winning Limit/Threshold [redmine:#226060]
	Param's Explanation: 
	
*/
BEGIN
	SET NOCOUNT ON
	
	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
		)
	RETURN;
	
	SELECT @ErrCode = 0
	
	CREATE TABLE #ProductSettingDetail_tmp00(
		[SettingType] [smallint] ,
		[SportType] [smallint] ,
		[BetType] [smallint] ,
		[IsLive] [bit] ,
		[ProductID] [tinyint] ,
		[MaxPT] [smallmoney] ,
		[MaxDiscount] [decimal](9, 8) ,
		[IsSync] [bit] ,
		[IsHidden] [bit] ,
		[IsDisabled] [bit] ,
		[SettingLevel] [tinyint] ,
		[DisplayOrder] [tinyint] ,
		[SettingStatus] [tinyint] ,
		[IntervalValue] [decimal](19, 8) ,
		[RealProductId] [tinyint] ,
		[MaxChoice] [tinyint] ,
		[ProductSettingID] [int] ,
		[Parent_ProductSettingID] [int] ,
		[Child_DisplayOrder] [int] ,
		SubType [TINYINT],
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)		
	
	INSERT INTO #ProductSettingDetail_tmp00(SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
		,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType)
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
			,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@siteid,@currency)
		
	BEGIN	
		DECLARE @xmlStrDisabled XML
		DECLARE @xmlStrHidden XML
		DECLARE @xmlStrSync XML
		CREATE TABLE #SportBettypeFilter4(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
		/*********************** Product Status: SettingType = 4 & New Product Status: SettingType = 13**************************/
		--Get sporttype/Bettype for this setting type	
		INSERT INTO #SportBettypeFilter4(SportType,Bettype,IsLive, SettingType,IsDisabled,IsHidden,IsSync,bitmapOrder)
		SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
		FROM #ProductSettingDetail_tmp00 psd WITH(NOLOCK)  
			INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.[SportType] = psd.[SportType]	AND pbs.[BetType] = psd.[BetType]
			INNER JOIN (		  SELECT Sporttype, bettype FROM dbo.f_CustSetting_ProductProfileSel(4,@SettingStatus,@siteid,@currency)
						UNION ALL SELECT Sporttype, bettype FROM dbo.f_CustSetting_ProductProfileSel(13,@SettingStatus,@siteid,@currency)
						UNION ALL SELECT Sporttype, bettype FROM dbo.f_CustSetting_ProductProfileSel(21,@SettingStatus,@siteid,@currency)
						)t 
						ON pbs.[SportType] = t.[SportType]	AND pbs.[BetType] = t.[BetType]
		WHERE psd.SettingType IN (4,13,21)
		
		----Hard code to hide CF if Upline is a dummy Super or Master
		DECLARE @DirectUplineID INT, @IsDirect BIT = 0
		
		IF (@RoleID = 3) 
			SET @DirectUplineID = @srecommend
		ELSE IF (@RoleID = 2)
			SET @DirectUplineID = @mrecommend	
		ELSE IF @RoleID = 1
			SET @DirectUplineID = @recommend	
			
		IF @DirectUplineID <= 100 OR EXISTS( SELECT 1 FROM Acc_CustDirect WITH (NOLOCK) WHERE Custid = @DirectUplineID)
		BEGIN
			SET @IsDirect = 1
			
			UPDATE #SportBettypeFilter4
			SET IsDisabled = 1, 
				IsHidden = 1
			WHERE SportType = 206
		END		
		
		IF @RoleID = 4 OR (@IsDirect = 1 AND @RoleID = 3)
		BEGIN
			UPDATE main
			SET main.IsDisabled = stt.IsDisabled, 
				main.IsHidden = stt.IsHidden
			FROM #SportBettypeFilter4 main
				INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
			WHERE stt.Currency = @Currency AND (stt.SiteID = @SiteID OR stt.SiteID = 0)
			
			UPDATE main
			SET main.IsDisabled = stt.IsDisabled, 
				main.IsHidden = stt.IsHidden
			FROM #SportBettypeFilter4 main
				INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
			WHERE (stt.Currency = @Currency OR stt.Currency = 0 ) AND stt.SiteID = @SiteID
		END
		
		BEGIN TRY
			IF @RoleID = 4 OR (@IsDirect = 1 AND @RoleID = 3)
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter4)
				BEGIN
					--Get from default status values
					--Sync: default status setting
					--Hide: default status setting
					--Enable/Disable: default status setting														
				
					SET @xmlStrDisabled = (
							SELECT (
									SELECT DISTINCT ft.bitmapOrder	AS '@b'
										, ft.IsDisabled	AS '@s'
									FROM #SportBettypeFilter4 ft 	
									FOR XML PATH('r')
										, TYPE
									)
							FOR XML PATH('root')
								, TYPE
							)
						
					SET @xmlStrHidden = (
							SELECT (
									SELECT DISTINCT ft.bitmapOrder	AS '@b'
										, ft.IsHidden	AS '@s'
									FROM #SportBettypeFilter4 ft 	
									FOR XML PATH('r')
										, TYPE
									)
							FOR XML PATH('root')
								, TYPE
							)
						
					SET @xmlStrSync = (
						SELECT (
								SELECT DISTINCT ft.bitmapOrder	AS '@b'
									, ft.IsSync	AS '@s'
								FROM #SportBettypeFilter4 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
				END
						
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,RepUpdateTime)
				SELECT	@CustID
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrHidden)))
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrSync)))
						, 0
						, 0
						, dbo.f_GetDateTime2()
			END	
			ELSE IF @RoleID IN (3,2,1)
			BEGIN
				--Get from Super
				--Sync: upline status
				--Enable/Disable: upline status
				DECLARE @UplineID INT
				
				IF @RoleID = 3
					SET @UplineID = @srecommend
				ELSE IF @RoleID = 2
					SET @UplineID = @mrecommend
				ELSE IF @RoleID = 1
					SET @UplineID = @recommend		
				
				
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo,RepUpdateTime)
				SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced, cs.SuspendInfo,cs.CloseInfo,dbo.f_GetDateTime2()
				FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
				WHERE cs.CustID = @UplineID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4
			RETURN
		END CATCH
		
		/********************************************* Game Status: SettingType = 11 ************************************/
		CREATE TABLE #SportBettypeFilter11(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
		--Get sporttype/Bettype for this setting type	
		INSERT INTO #SportBettypeFilter11(SportType,Bettype,IsLive, SettingType,IsDisabled,IsHidden,IsSync,bitmapOrder)
		SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 		
		FROM #ProductSettingDetail_tmp00 psd WITH(NOLOCK)  
			INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
		WHERE psd.SettingType = 11				
					
		IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter11)
		BEGIN
			
			UPDATE main
			SET main.IsDisabled = stt.IsDisabled, 
				main.IsHidden = stt.IsHidden
			FROM #SportBettypeFilter11 main
				INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
			WHERE stt.Currency = @Currency AND (stt.SiteID = @SiteID OR stt.SiteID = 0)
			
			UPDATE main
			SET main.IsDisabled = stt.IsDisabled, 
				main.IsHidden = stt.IsHidden
			FROM #SportBettypeFilter11 main
				INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
			WHERE (stt.Currency = @Currency OR stt.Currency = 0 ) AND stt.SiteID = @SiteID
			
			BEGIN TRY				
				--Get from default status values
				--Sync: default status setting
				--Hide: default status setting
				--Enable/Disable: default status setting
				SET @xmlStrDisabled = (
						SELECT (
								SELECT DISTINCT ft.bitmapOrder	AS '@b'
									, ft.IsDisabled	AS '@s'
								FROM #SportBettypeFilter11 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
						
				SET @xmlStrHidden = (
						SELECT (
								SELECT DISTINCT ft.bitmapOrder	AS '@b'
									, ft.IsHidden	AS '@s'
								FROM #SportBettypeFilter11 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
						
				SET @xmlStrSync = (
					SELECT (
							SELECT DISTINCT ft.bitmapOrder	AS '@b'
								, ft.IsSync	AS '@s'
							FROM #SportBettypeFilter11 ft 	
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
				
				UPDATE cs
				SET bitmapIsDisabled = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
					bitmapIsHidden = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
					bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync))),
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
				WHERE cs.CustID = @CustID     

			END TRY
			BEGIN CATCH
				SELECT @ErrCode = 11
				RETURN
			END CATCH
		END
		
		DROP TABLE #SportBettypeFilter4
		DROP TABLE #SportBettypeFilter11
	
		/********************************************* Position Taking: SettingType = 1 ***********************************/
		--PT setting
		CREATE TABLE #SportBettypeFilter1 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)

		DECLARE @tblPT18 TABLE (
				SportType		SMALLINT,
				BetType			SMALLINT,
				IsLive			BIT,
				SuperPT			SMALLMONEY,
				IsAutoSuperPT	BIT,
				AutoSuperPT		SMALLMONEY,
				MasterPT		SMALLMONEY,				
				MasterMinPT		SMALLMONEY,
				MasterMaxPT		SMALLMONEY,
				IsAutoMasterPT	BIT,
				AutoMasterPT	SMALLMONEY,
				AgentPT			SMALLMONEY,				
				AgentMinPT		SMALLMONEY
				)
				
		DECLARE @xml XML
		
		INSERT INTO #SportBettypeFilter1(ProductID, SportType,Bettype,IsLive, SettingType, RealProductId)
		SELECT ProductID, SportType,Bettype,IsLive, SettingType, RealProductId
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (1,18,28)
		
		IF ISNULL(@SettingType28,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML, @SettingType28)
			
			IF @Roleid = 3
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					IsAutoSuperPT,
					AutoSuperPT,
					MasterPT,				
					MasterMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
				FROM  @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					MasterPT,
					IsAutoMasterPT,
					AutoMasterPT,
					AgentPT,				
					AgentMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
				FROM  @xml.nodes('/Root/R') T(c) 
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					MasterPT,					
					AgentPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
				FROM  @xml.nodes('/Root/R') T(c) 
			END
		END
		
		IF ISNULL(@SettingType1,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML, @SettingType1)
			
			IF @roleid = 3
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					IsAutoSuperPT,
					AutoSuperPT,
					MasterPT,				
					MasterMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
				FROM  @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO @tblPT18(SportType,
					BetType, 
					IsLive,
					MasterPT,
					IsAutoMasterPT,
					AutoMasterPT,
					AgentPT,				
					AgentMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
				FROM  @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid =1 
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					MasterPT,					
					AgentPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
				FROM  @xml.nodes('/Root/R') T(c) 
			END
		END
		
		IF ISNULL(@SettingType18,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML, @SettingType18)
			
			IF @roleid = 3
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					IsAutoSuperPT,
					AutoSuperPT,
					MasterPT,				
					MasterMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoSuperPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoSuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS MasterMinPT
				FROM  @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO @tblPT18(SportType,
					BetType, 
					IsLive,
					MasterPT,
					IsAutoMasterPT,
					AutoMasterPT,
					AgentPT,				
					AgentMinPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@IsAuto)[1]', 'bit') AS IsAutoMasterPT,
					T.c.query('.').value('(R/@AutoPT)[1]', 'smallmoney') AS AutoMasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT,
					T.c.query('.').value('(R/@MinPT)[1]', 'smallmoney') AS AgentMinPT
				FROM  @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid =1 
			BEGIN
				INSERT INTO @tblPT18(SportType, 
					BetType, 
					IsLive,
					SuperPT,
					MasterPT,					
					AgentPT)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS SportType,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS BetType,
					T.c.query('.').value('(R/@IsLive)[1]', 'bit') AS IsLive,
					T.c.query('.').value('(R/@SuperPT)[1]', 'smallmoney') AS SuperPT,
					T.c.query('.').value('(R/@MasterPT)[1]', 'smallmoney') AS MasterPT,
					T.c.query('.').value('(R/@AgentPT)[1]', 'smallmoney') AS AgentPT
				FROM  @xml.nodes('/Root/R') T(c) 
			END
		END		
				
		BEGIN TRY
			IF @RoleID = 3
			BEGIN				
				INSERT INTO [dbo].[CustPTSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[IsLive]
				   ,[SuperPT]
				   ,[MasterPT]
				   ,[AgentPT]
				   ,[IsAutoMasterPT]
				   ,[AutoMasterPT]
				   ,[IsAutoSuperPT]
				   ,[AutoSuperPT]
				   ,[MinPT]
				   ,[MaxPT]
				   ,RepUpdateTime)
				SELECT 
					@CustID
					,t.SportType
					,t.BetType
					,t.IsLive
					,t.SuperPT
					,t.MasterPT
					,0 as AgentPT
					,0 IsAutoMasterPT
					,0 AutoMasterPT
					,t.IsAutoSuperPT
					,t.AutoSuperPT
					,t.MasterMinPT
					,100 MaxPT
					,dbo.f_GetDateTime2()
				FROM @tblPT18 t
					INNER JOIN #SportBettypeFilter1 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO [dbo].[CustPTSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[IsLive]
				   ,[SuperPT]
				   ,[MasterPT]
				   ,[AgentPT]
				   ,[IsAutoMasterPT]
				   ,[AutoMasterPT]
				   ,[IsAutoSuperPT]
				   ,[AutoSuperPT]
				   ,[MinPT]
				   ,[MaxPT]
				   ,RepUpdateTime)
				SELECT 
					@CustID
					,t.SportType
					,t.BetType
					,t.IsLive
					,0 as SuperPT
					,t.MasterPT
					,t.AgentPT
					,t.IsAutoMasterPT
					,t.AutoMasterPT
					,0 as IsAutoSuperPT
					,0 as AutoSuperPT
					,t.AgentMinPT
					,100 MaxPT
					,dbo.f_GetDateTime2()
				FROM @tblPT18 t
					INNER JOIN #SportBettypeFilter1 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
			END
			ELSE IF @roleid = 1
			BEGIN
				--If this is the first member,insert into Group Setting
				INSERT INTO [dbo].[CustPTGroupSetting3rd_Member]
				   ([AgentID]
				   ,[SportType]
				   ,[BetType]
				   ,[IsLive]
				   ,[SuperPT]
				   ,[MasterPT]
				   ,[AgentPT]
				   ,[IsAutoMasterPT]
				   ,[AutoMasterPT]
				   ,[IsAutoSuperPT]
				   ,[AutoSuperPT]
				   ,RepUpdateTime)		
				SELECT 
					@recommend,SportType,BetType,Islive,
					SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT, dbo.f_GetDateTime2()
				FROM @tblPT18
				WHERE NOT EXISTS(SELECT TOP 1 1 FROM dbo.CustPTGroupSetting3rd_Member WHERE AgentID = @recommend)
				AND @srecommend IN (
						13869621,
						5340162,
						12262401,
						12141653,
						4138910,
						6379932,
						16112208,
						12141529,
						1539339,
						720475
						--UUS
						,17287861
						,18879367
						,14373244
						,18362423
						,18479460
						,18289591
					)
			
				IF @@ROWCOUNT<>0
				BEGIN
					INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped,RepUpdateTime)
						SELECT @CustID,1,dbo.f_GetDateTime2()
				END
				ELSE 
				BEGIN
					IF EXISTS(SELECT TOP 1 1
								FROM dbo.CustPTGroupSetting3rd_Member grp WITH(NOLOCK)
								JOIN @tblPT18 tmp ON tmp.SportType = grp.SportType
														AND tmp.BetType = grp.BetType
														AND tmp.Islive = grp.Islive
								WHERE grp.AgentID = @recommend
								AND (
									tmp.SuperPT <> grp.SuperPT
									OR
									tmp.MasterPT <> grp.MasterPT
									OR
									tmp.AgentPT <> grp.AgentPT
									OR
									0 <> grp.IsAutoMasterPT
									OR
									0 <> grp.AutoMasterPT
									OR
									0 <> grp.IsAutoSuperPT
									OR
									0 <> grp.AutoSuperPT
								))
						OR @srecommend NOT IN (
											13869621,
											5340162,
											12262401,
											12141653,
											4138910,
											6379932,
											16112208,
											12141529,
											1539339,
											720475
											--UUS
											,17287861
											,18879367
											,14373244
											,18362423
											,18479460
											,18289591
										)
					BEGIN
						--If this member's PT setting are diffrent from Group PT Setting
						INSERT INTO [dbo].[CustPTSetting3rd_Member]
							   ([CustID]
							   ,[SportType]
							   ,[BetType]
							   ,[IsLive]
							   ,[SuperPT]
							   ,[MasterPT]
							   ,[AgentPT]
							   ,[IsAutoMasterPT]
							   ,[AutoMasterPT]
							   ,[IsAutoSuperPT]
							   ,[AutoSuperPT]
							   ,RepUpdateTime)
						SELECT 
						@CustID,SportType,BetType,Islive,
							SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT, dbo.f_GetDateTime2()
						FROM @tblPT18
					
						INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped,RepUpdateTime)
							SELECT @CustID,0,dbo.f_GetDateTime2()
					END
					ELSE
					BEGIN
						INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped,RepUpdateTime)
							SELECT @CustID,1,dbo.f_GetDateTime2()
					END
				END				
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 1					
			RETURN
		END CATCH
		
		/********************************************* Commision : SettingType = 3,19,25, Ticket Commision : SettingType = 14 ****************************************/
		CREATE TABLE #SportBettypeFilter19 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, bettype SMALLINT, discount DECIMAL(9,8), playerdiscount DECIMAL(9,8), sdiscount DECIMAL(9,8), adiscount DECIMAL(9,8))
	
		INSERT INTO #SportBettypeFilter19(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId		
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (3,19,25)
		
		IF ISNULL(@SettingType19,'') <> '' OR ISNULL(@SettingType3,'') <> '' OR ISNULL(@SettingType25,'') <> ''
		BEGIN			
			IF @roleid IN (3,2)
			BEGIN
				SELECT @xml = CONVERT(XML,@SettingType25)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
				FROM   @xml.nodes('/Root/R') T(c) 
				
				SELECT @xml = CONVERT(XML,@SettingType19)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
				FROM   @xml.nodes('/Root/R') T(c) 
				
				SELECT @xml = CONVERT(XML,@SettingType3)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
				FROM   @xml.nodes('/Root/R') T(c) 
			END
			ELSE IF @roleid = 1
			BEGIN
				SELECT @xml = CONVERT(XML,@SettingType25)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
					T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount,
					T.c.query('.').value('(R/@adiscount)[1]', 'decimal(9,8)') AS adiscount,
					T.c.query('.').value('(R/@sdiscount)[1]', 'decimal(9,8)') AS sdiscount
				FROM   @xml.nodes('/Root/R') T(c) 
				
				SELECT @xml = CONVERT(XML,@SettingType19)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
					T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount,
					T.c.query('.').value('(R/@adiscount)[1]', 'decimal(9,8)') AS adiscount,
					T.c.query('.').value('(R/@sdiscount)[1]', 'decimal(9,8)') AS sdiscount
				FROM   @xml.nodes('/Root/R') T(c) 
				
				SELECT @xml = CONVERT(XML,@SettingType3)
				
				INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
					T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount,
					T.c.query('.').value('(R/@adiscount)[1]', 'decimal(9,8)') AS adiscount,
					T.c.query('.').value('(R/@sdiscount)[1]', 'decimal(9,8)') AS sdiscount
				FROM   @xml.nodes('/Root/R') T(c)
			END
		END
		
		BEGIN TRY
			IF @RoleID IN (3,2)
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount]
					   ,RepUpdateTime)
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,dc.discount
					,dbo.f_GetDateTime2()
				FROM @NewDiscountTbl dc
					INNER JOIN #SportBettypeFilter19 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
			END	
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[PlayerDiscount]
				   ,[AgentDiscount]
				   ,[MasterDiscount]
				   ,[SuperDiscount]
				   ,RepUpdateTime)
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,dc.playerdiscount
					,dc.discount
					,dc.adiscount
					,dc.sdiscount
					,dbo.f_GetDateTime2()
				FROM @NewDiscountTbl dc
					INNER JOIN #SportBettypeFilter19 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType   
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 3						
			RETURN
		END CATCH
		
		/********************************************* SMA WinLimit : SettingType = 6,22 ****************************************/
		/********************************************* SMA LossLimit : SettingType = 12 ****************************************/
		CREATE TABLE #SportBettypeFilter6 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
			
		INSERT INTO #SportBettypeFilter6(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId		
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (6,22,12)
					
		BEGIN TRY
			IF @roleid = 3
			BEGIN
				INSERT INTO [dbo].[CustWinLossLimit_Agent]
						([CustID]
						,[SportType]
						,[BetType]
						,[MaxWinLimit]
						,[MaxLossLimit]
						,[IsAutoReset]
						,RepUpdateTime)
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,cs.MaxWinLimit
					,cs.MaxLossLimit
					,cs.IsAutoReset
					,dbo.f_GetDateTime2()
				FROM dbo.CustWinLossLimit_Agent cs WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType				
				WHERE cs.custid = @srecommend	
			END	
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO [dbo].[CustWinLossLimit_Agent]
						([CustID]
						,[SportType]
						,[BetType]
						,[MaxWinLimit]
						,[MaxLossLimit]
						,[IsAutoReset]
						,RepUpdateTime)
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,cs.MaxWinLimit
					,cs.MaxLossLimit
					,cs.IsAutoReset
					,dbo.f_GetDateTime2()
				FROM dbo.CustWinLossLimit_Agent cs WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType				
				WHERE cs.custid = @mrecommend
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustWinLossLimit_Member]
					([CustID]
					,[SportType]
					,[BetType]
					,[MaxWinLimit]
					,[MaxLossLimit]
					,[IsAutoReset]
					,RepUpdateTime)
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MaxWinLimit
					,MaxLossLimit
					,IsAutoReset
					,dbo.f_GetDateTime2()
				FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType
				WHERE custid = @recommend
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 6						
			RETURN
		END CATCH
		
		/****************************** Stake Level Member Single Selection : SettingType = 7 ******************************/
		/****************************** Stake Level Member Multiple Selection : SettingType = 17 ******************************/
		/*************************** Group Stake Level Member Single Selection : SettingType = 8 ***************************/
		CREATE TABLE #SportBettypeFilter7 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		
		INSERT INTO #SportBettypeFilter7(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId		
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (7,8,17)
		
		DELETE sb		
		FROM #SportBettypeFilter7 sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE ssc.Currency = @Currency AND (ssc.SiteID = @SiteID OR ssc.SiteID = 0)
			
		DELETE sb		
		FROM #SportBettypeFilter7 sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE (ssc.Currency = @Currency OR ssc.Currency = 0 ) AND ssc.SiteID = @SiteID		

		BEGIN TRY
			IF	@RoleID = 3
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType     , BetType     , StakeLevelList, RepUpdateTime)
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList, dbo.f_GetDateTime2()
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @srecommend
			END	
			ELSE IF @roleid = 2
			BEGIN			
			    INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType     , BetType     , StakeLevelList, RepUpdateTime)
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList, dbo.f_GetDateTime2()
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @mrecommend			
			END
			ELSE IF	@roleid = 1
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Member
					(	CustID , SportType     , BetType     , StakeLevelList, LastUpdated, RepUpdateTime)
				SELECT	@CustID, csla.SportType, csla.BetType, ISNULL(sr.LowestStakeLevel, ''), GETDATE(), dbo.f_GetDateTime2()
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
					OUTER APPLY (
						SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
						FROM (
							SELECT	CAST(value AS INT) AS val
							FROM	STRING_SPLIT(csla.StakeLevelList, ',')
						) AS ss
						INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
								ON	ss.val = sl.StakeLevelID
						ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
					) sr
				WHERE	csla.CustID = @recommend
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 7						
			RETURN
		END CATCH
		
		/********************************************* SB Parlay Max Payout : SettingType = 27 ****************************************/
		CREATE TABLE #SportBettypeFilter27 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		DECLARE @NewMaxPayoutTbl TABLE (
					SportType			SMALLINT
					, BetType			SMALLINT
					, SingleMatchParlay	MONEY
					, Combo2			MONEY
					, Combo35			MONEY
					, ComboOver6		MONEY
					)
		
		INSERT INTO #SportBettypeFilter27(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (27)
		
		IF ISNULL(@SettingType27,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML,@SettingType27)
				
			INSERT INTO @NewMaxPayoutTbl(SportType, 
				BetType, 
				SingleMatchParlay, 
				Combo2, 
				Combo35, 
				ComboOver6)
			SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
				T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
				T.c.query('.').value('(R/@SingleMP)[1]', 'money') AS SingleMatchParlay,
				T.c.query('.').value('(R/@Combo2)[1]', 'money') AS Combo2,
				T.c.query('.').value('(R/@Combo35)[1]', 'money') AS Combo35,
				T.c.query('.').value('(R/@Combo6)[1]', 'money') AS ComboOver6
			FROM  @xml.nodes('/Root/R') T(c)
		END		
		
		BEGIN TRY
			IF @roleid IN (3,2)
			BEGIN 
				INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,RepUpdateTime)
				SELECT @custid , cs.SportType, cs.BetType, 
						cs.SingleMatchParlay,
						cs.Combo2,
						cs.Combo35,
						cs.ComboOver6,
						dbo.f_GetDateTime2()
				FROM @NewMaxPayoutTbl cs
					INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6,RepUpdateTime)
				SELECT @custid , cs.SportType, cs.BetType, 
						cs.SingleMatchParlay,
						cs.Combo2,
						cs.Combo35,
						cs.ComboOver6,
						dbo.f_GetDateTime2()
				FROM @NewMaxPayoutTbl cs
					INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 27								
			RETURN	
		END CATCH
		
		/********************************************* Potential Win Limit : SettingType = 30 ****************************************/
		IF @roleid = 1
		BEGIN TRY
			CREATE TABLE #SportBettypeFilter30 (ProductID TINYINT, SportType SMALLINT,Bettype INT)
			
			INSERT INTO #SportBettypeFilter30(ProductID ,SportType ,Bettype)
			SELECT ProductID ,SportType ,Bettype
			FROM #ProductSettingDetail_tmp00
			WHERE SettingType IN (30)

			INSERT INTO CustPotentialWinLimit(CustID,SportType,BetType,PotentialWinLimit,IsAutoReset,OfferOption, RepUpdateTime)
			SELECT @CustID, Sporttype, Bettype, 0 PotentialWinLimit, 1 IsAutoReset, 0 OfferOption, dbo.f_GetDateTime2()
			FROM #SportBettypeFilter30
			
			DROP TABLE #SportBettypeFilter30
		END	TRY
		BEGIN CATCH
			SELECT @ErrCode = 30
			RETURN
		END CATCH
		
		DROP TABLE #SportBettypeFilter1
		DROP TABLE #SportBettypeFilter19				
		DROP TABLE #SportBettypeFilter6
		DROP TABLE #SportBettypeFilter7
	END	
	
	DROP TABLE #ProductSettingDetail_tmp00
END

