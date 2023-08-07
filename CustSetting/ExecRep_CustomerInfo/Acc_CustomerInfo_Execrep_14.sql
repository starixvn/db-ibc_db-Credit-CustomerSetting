/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet,bodbDownlineNetView" viewers="" isFunction="0" isNested="1"></info>*/
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
	@SettingType26 VARCHAR(MAX)= '', --SB
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
	
	-- Myanmar Odds		
	@IsMyanmarOdds BIT = 0,
	
	@CreationStatus TINYINT = 0,
	@ErrCode INT = 0 OUTPUT
	
AS
/*
		Created: 20230525@Johnson	
		Task: Apply execrep when insert customer settings
		DB: DBCUST/CustDB
		
		Revisions: 
			- 20230525@Johnson: initial sp [redmine: #179159]

	Param's Explanation: 
	
*/
BEGIN
	SET NOCOUNT ON
	
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
		
	--IF dbo.f_CheckRepTable('ProductSettingProfile') = 1 
	--	AND dbo.f_CheckRepTable('ProductProfileSiteCurrency') = 1
	IF EXISTS ( SELECT 1 FROM sys.tables WHERE Name='ProductSettingProfile')	
		AND EXISTS ( SELECT 1 FROM sys.tables WHERE Name='ProductProfileSiteCurrency')	
	BEGIN
		INSERT INTO #ProductSettingDetail_tmp00(SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
			,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType)
		SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
				,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType
		FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(NULL,@CreationStatus,@siteid,@currency)

	END
		
	IF (dbo.f_CheckRepTable('CustProductStatus') = 1
		--AND dbo.f_CheckRepTable('ProductSettingProfile') = 1 
		AND EXISTS ( SELECT 1 FROM sys.tables WHERE Name='ProductSettingProfile')
		AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
		AND dbo.f_CheckRepTable('ProductStatusSiteCurrency') = 1
	)
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
			INNER JOIN (		  SELECT Sporttype, bettype FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(4,@CreationStatus,@siteid,@currency)
						UNION ALL SELECT Sporttype, bettype FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(13,@CreationStatus,@siteid,@currency)
						UNION ALL SELECT Sporttype, bettype FROM dbo.f_LiteMode_CustSetting_ProductSettingDetailSel(21,@CreationStatus,@siteid,@currency)
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
						
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo)
				SELECT	@CustID
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrHidden)))
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrSync)))
						, 0
						, 0
						
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
				
				
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo,CloseInfo)
				SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced, cs.SuspendInfo,cs.CloseInfo
				FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
				WHERE cs.CustID = @UplineID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4

			DELETE FROM CustProductStatus WHERE CustID = @CustID
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
					bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync)))									
				FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
				WHERE cs.CustID = @CustID     

			END TRY
			BEGIN CATCH
				SELECT @ErrCode = 11

				DELETE FROM CustProductStatus WHERE CustID = @CustID
				RETURN
			END CATCH
		END
		
		DROP TABLE #SportBettypeFilter4
		DROP TABLE #SportBettypeFilter11
	END	
	
	IF (dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustSettingMode3rd') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1
		AND dbo.f_CheckRepTable('CustWinLossLimit_Member') = 1
		--AND dbo.f_CheckRepTable('ProductSettingProfile') = 1 
		 AND EXISTS( SELECT 1 FROM sys.tables WHERE Name='ProductSettingProfile')
		 
		AND	dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1
		AND	dbo.f_CheckRepTable('CustStakeLevel_Member') = 1
		AND	dbo.f_CheckRepTable('CustBetSetting_Agent') = 1
		AND	dbo.f_CheckRepTable('CustBetSetting_Member') = 1
		
		AND dbo.f_CheckRepTable('CustSetting') = 1 
		AND dbo.f_CheckRepTable('CustOverride') = 1 
		AND dbo.f_CheckRepTable('ProductGlobalSetting') = 1 
		AND dbo.f_CheckRepTable('ProductBetSetting') = 1
		AND dbo.f_CheckRepTable('AgentCommRate') = 1
		AND dbo.f_CheckRepTable('CustCommRate') = 1 
		AND dbo.f_CheckRepTable('CustBetSetting_Agent') = 1
		AND dbo.f_CheckRepTable('CustBetSetting_Member') = 1 
		AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Agent') = 1 
		AND dbo.f_CheckRepTable('CustMaxPayoutSetting_Member') = 1 	  
	)
	BEGIN
		CREATE TABLE #tmpcustSetting(
			[custid] [int] NOT NULL,
			[bettype] [smallint] NOT NULL,
			[sporttype] [smallint] NOT NULL,
			[apositiontaking] [smallmoney] NOT NULL,
			[mpositiontaking] [smallmoney] NOT NULL,
			[spositiontaking] [smallmoney] NOT NULL,
			[alivepositiontaking] [smallmoney] NOT NULL,
			[mlivepositiontaking] [smallmoney] NOT NULL,
			[slivepositiontaking] [smallmoney] NOT NULL,
			[playerdiscount] [decimal](9, 8) NOT NULL,
			[discount] [decimal](9, 8) NOT NULL,
			[adiscount] [decimal](9, 8) NOT NULL,
			[sdiscount] [decimal](9, 8) NOT NULL,
			[groupa] [decimal](9, 8) NOT NULL,
			[groupb] [decimal](9, 8) NOT NULL,
			[groupc] [decimal](9, 8) NOT NULL,
			[groupd] [decimal](9, 8) NOT NULL,
			[groupe] [decimal](9, 8) NOT NULL,
			[groupf] [decimal](9, 8) NOT NULL,
			[autopositiontaking] [smallmoney] NOT NULL,
			[autolivepositiontaking] [smallmoney] NOT NULL,
			[isautopositiontaking] [bit] NOT NULL,
			[isautolivepositiontaking] [bit] NOT NULL,
			[autompositiontaking] [smallmoney] NOT NULL,
			[autolivempositiontaking] [smallmoney] NOT NULL,
			[isautompositiontaking] [bit] NOT NULL,
			[isautolivempositiontaking] [bit] NOT NULL
		)	
		
		/********************************************* Position Taking: SettingType = 1 ***********************************/
		--PT setting
		CREATE TABLE #SportBettypeFilter1 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
				
		DECLARE @tblPT28 TABLE (
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
		WHERE SettingType IN (1,18)
		
		IF ISNULL(@SettingType28,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML, @SettingType28)
			
			IF @Roleid = 3
			BEGIN
				INSERT INTO @tblPT28(SportType, 
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
				INSERT INTO @tblPT28(SportType, 
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
				INSERT INTO @tblPT28(SportType, 
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
				INSERT INTO #tmpcustsetting([custid],[sporttype],[bettype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
				SELECT @custid, sporttype, bettype, SuperPT, MasterPT, 0 as apositiontaking, 0 as slivepositiontaking, 0 as mlivepositiontaking, 0 alivepositiontaking, 0 as autolivepositiontaking, AutoSuperPT, 0 as adiscount, 0 as sdiscount, 0 as groupa, 0 as groupb, 0 as groupc, 0 as groupd, 0 groupe, 0 groupf, 0 playerdiscount, 0 discount, IsAutoSuperPT, 0 as isautolivepositiontaking, 0 as autompositiontaking, 0 as autolivempositiontaking, 0 as isautompositiontaking, 0 as isautolivempositiontaking
				FROM @tblPT28
				WHERE IsLive = 0
				
				--update live for sporttype = 1, bettype in (1,3,7,8)
				UPDATE cs
				SET slivepositiontaking = SuperPT,
					isautolivepositiontaking = IsAutoSuperPT,
					autolivepositiontaking = AutoSuperPT,
					mlivepositiontaking = MasterPT
				FROM #tmpcustsetting cs
					INNER JOIN @tblPT28 t ON cs.sporttype = t.sporttype
											AND cs.bettype = t.bettype
											AND t.IsLive = 1
			
				INSERT INTO [dbo].[custoverride]([custid],[sporttype],[bettype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
				SELECT @custid, sporttype, bettype, MasterMinPT, 0.9 as maxpositiontaking, 
						ISNULL((SELECT MasterMinPT FROM @tblPT28 t2 
						WHERE t2.sporttype = t.sporttype AND t2.bettype = t.bettype AND t2.IsLive = 1),0) as minlivepositiontaking
						, 0.9 as maxlivepositiontaking
				FROM @tblPT28 t
				WHERE IsLive = 0
				
				IF @@Error <> 0
				BEGIN
					--Error Occurs
					SELECT @ErrCode=118				

					-- ROLLBACK MANUALLY				
					DELETE custoverride with (ROWLOCK) where custid =  @custid
								
					RETURN
				END	
				
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
				   ,[MaxPT])
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
				FROM @tblPT18 t
					INNER JOIN #SportBettypeFilter1 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
			END
			ELSE IF @roleid = 2
			BEGIN
				INSERT INTO #tmpcustsetting([custid],[sporttype],[bettype],[spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
				SELECT @custid, sporttype, bettype,0 as spositiontaking, MasterPT, AgentPT, 0 as slivepositiontaking, 0 as mlivepositiontaking, 0 alivepositiontaking, 0 as autolivepositiontaking, 0 as autopositiontaking, 0 as adiscount, 0 as sdiscount, 0 as groupa, 0 as groupb, 0 as groupc, 0 as groupd, 0 groupe, 0 groupf, 0 playerdiscount, 0 discount, 0 as isautopositiontaking, 0 as isautolivepositiontaking, 0 as autolivempositiontaking, 0 as isautolivempositiontaking, AutoMasterPT, IsAutoMasterPT
				FROM @tblPT28
				WHERE IsLive = 0
				
				--update live for sporttype = 1, bettype in (1,3,7,8)
				UPDATE cs
				SET alivepositiontaking = AgentPT,
					isautolivempositiontaking = IsAutoMasterPT,
					autolivempositiontaking = AutoMasterPT,
					mlivepositiontaking = MasterPT
				FROM #tmpcustsetting cs
					INNER JOIN @tblPT28 t ON cs.sporttype = t.sporttype
											AND cs.bettype = t.bettype
											AND t.IsLive = 1
			
				INSERT INTO [dbo].[custoverride]([custid], [bettype], [sporttype], minpositiontaking, maxpositiontaking, minlivepositiontaking, maxlivepositiontaking)
				SELECT @custid, bettype, sporttype, AgentMinPT, 0.9 as maxpositiontaking, 
						ISNULL((SELECT AgentMinPT FROM @tblPT28 t2 
						WHERE t2.sporttype = t.sporttype AND t2.bettype = t.bettype AND t2.IsLive = 1),0) as minlivepositiontaking
						, 0.9 as maxlivepositiontaking
				FROM @tblPT28 t
				WHERE IsLive = 0
				
				IF @@Error <> 0
				BEGIN
					--Error Occurs
					SELECT @ErrCode=118				

					-- ROLLBACK MANUALLY				
					DELETE custoverride with (ROWLOCK) where custid =  @custid
								
					RETURN
				END	
				
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
				   ,[MaxPT])
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
				FROM @tblPT18 t
					INNER JOIN #SportBettypeFilter1 ft ON t.SportType = ft.SportType AND t.BetType = ft.BetType AND t.IsLive = ft.IsLive				
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO #tmpcustsetting([custid],[sporttype],[bettype],[spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
				SELECT @custid, sporttype, bettype, SuperPT, MasterPT, AgentPT, 0 as slivepositiontaking, 0 as mlivepositiontaking, 0 alivepositiontaking, 0 as autolivepositiontaking, 0 as autopositiontaking, 0 as adiscount, 0 as sdiscount, 0 as groupa, 0 as groupb, 0 as groupc, 0 as groupd, 0 groupe, 0 groupf, 0 playerdiscount, 0 discount, 0 as isautopositiontaking, 0 as isautolivepositiontaking, 0 as autolivempositiontaking, 0 as isautolivempositiontaking, 0 as autompositiontaking, 0 as isautompositiontaking
				FROM @tblPT28
				WHERE IsLive = 0
				
				--update live for sporttype = 1, bettype in (1,3,7,8)
				UPDATE cs
				SET alivepositiontaking = AgentPT,					
					mlivepositiontaking = MasterPT,
					slivepositiontaking = SuperPT
				FROM #tmpcustsetting cs
					INNER JOIN @tblPT28 t ON cs.sporttype = t.sporttype
											AND cs.bettype = t.bettype
											AND t.IsLive = 1
											
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
				   ,[AutoSuperPT])		
				SELECT 
					@recommend,SportType,BetType,Islive,
					SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT
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
					INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
						SELECT @CustID,1
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
							   ,[AutoSuperPT])
						SELECT 
						@CustID,SportType,BetType,Islive,
							SuperPT,MasterPT,AgentPT,0 IsAutoMasterPT,0 AutoMasterPT,0 IsAutoSuperPT,0 AutoSuperPT
						FROM @tblPT18
					
						INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
							SELECT @CustID,0
					END
					ELSE
					BEGIN
						INSERT INTO dbo.CustSettingMode3rd(CustID,IsGrouped)
							SELECT @CustID,1
					END
				END				
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 1			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID				
			END	
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		/********************************************* Bet Limit : SettingType = 2 ****************************************/
		CREATE TABLE #SportBettypeFilter2 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		
		DECLARE @BetSetting TABLE(
			SportType         SMALLINT, 
			BetType           SMALLINT, 
			MinBet            MONEY, 
			MaxBet            MONEY, 
			MaxPerMatch       MONEY, 
			MaxPerNumber      MONEY, 
			MaxPayoutPerMatch MONEY		
			PRIMARY KEY(sporttype, Bettype)
		);
		
		INSERT INTO #SportBettypeFilter2(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (2)
		
		IF ISNULL(@SettingType2,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML,@SettingType2)
			
			INSERT INTO @BetSetting(SportType, 
				BetType, 
				MinBet, 
				MaxBet, 
				MaxPerMatch)
			SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
				T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
				T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
				T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
				T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch			
			FROM  @xml.nodes('/Root/R') T(c) 
		END
		
		BEGIN TRY
			IF @RoleID IN (3,2)
			BEGIN				
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter2 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType				
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustBetSetting3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter2 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType				
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 2			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
			END	
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		/********************************************* Commision : SettingType = 3, Ticket Commision : SettingType = 14 ****************************************/
		CREATE TABLE #SportBettypeFilter19 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		DECLARE @NewDiscountTbl TABLE (sporttype SMALLINT, bettype SMALLINT, discount DECIMAL(9,8), playerdiscount DECIMAL(9,8), sdiscount DECIMAL(9,8), adiscount DECIMAL(9,8))
	
		INSERT INTO #SportBettypeFilter19(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId		
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (3,19)
		
		IF ISNULL(@SettingType19,'') <> '' OR ISNULL(@SettingType3,'') <> ''
		BEGIN			
			IF @roleid IN (3,2)
			BEGIN
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
					   ,[Discount])
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,dc.discount
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
				   ,[SuperDiscount])
				SELECT 
					@CustID
					,dc.SportType
					,dc.BetType
					,dc.playerdiscount
					,dc.discount
					,dc.adiscount
					,dc.sdiscount
				FROM @NewDiscountTbl dc
					INNER JOIN #SportBettypeFilter19 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType   
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 3			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			END	
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
			END
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
						,[IsAutoReset])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,cs.MaxWinLimit
					,cs.MaxLossLimit
					,cs.IsAutoReset
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
						,[IsAutoReset])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,cs.MaxWinLimit
					,cs.MaxLossLimit
					,cs.IsAutoReset
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
					,[IsAutoReset])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MaxWinLimit
					,MaxLossLimit
					,IsAutoReset
				FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType
				WHERE custid = @recommend
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 6			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
			END	
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
			END
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
					(	CustID , SportType     , BetType     , StakeLevelList     )
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @srecommend
			END	
			ELSE IF @roleid = 2
			BEGIN			
			    INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType     , BetType     , StakeLevelList     )
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @mrecommend			
			END
			ELSE IF	@roleid = 1
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Member
					(	CustID , SportType     , BetType     , StakeLevelList                 , LastUpdated)
				SELECT	@CustID, csla.SportType, csla.BetType, ISNULL(sr.LowestStakeLevel, ''), GETDATE()
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
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		
		/********************************************* Bet Game Limit : SettingType = 16,20 ****************************************/
		CREATE TABLE #SportBettypeFilter16 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		
		INSERT INTO #SportBettypeFilter16(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (16)
		
		DELETE @BetSetting
		
		IF ISNULL(@SettingType16,'') <> ''
		BEGIN
			SELECT @xml = CONVERT(XML,@SettingType16)
			
			INSERT INTO @BetSetting(SportType, 
				BetType, 
				MinBet, 
				MaxBet, 
				MaxPerMatch)
			SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
				T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
				T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
				T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
				T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch			
			FROM  @xml.nodes('/Root/R') T(c) 
		END
		
		BEGIN TRY
			IF @RoleID IN (3,2)
			BEGIN				
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter16 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType				
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustBetSetting3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter16 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType				
			END
		END TRY		
		BEGIN CATCH 
			SELECT @ErrCode = 16			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		/********************************************* Bet Game Limit : SettingType = 20 ****************************************/
		CREATE TABLE #SportBettypeFilter20(
			SportType   SMALLINT, 
			BetType     SMALLINT, 
			IsLive      BIT, 
			SettingType SMALLINT
		)

		INSERT INTO #SportBettypeFilter20(SportType,BetType,IsLive,SettingType)
		SELECT SportType,BetType,IsLive,SettingType
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (20)
				
		BEGIN TRY
			/* Master:
				min bet
					If Super bet setting value = 0;0 ==> min bet = super min bet
					If Super bet setting value = 0;<1 ==> min bet = super min bet
					If Super bet setting value <> 0;0 or 0;<1 ==> min bet = max(global min bet; super min bet)
				max bet
					If Super bet setting value = 0;0 ==> max bet = super max bet
					If Super bet setting value = 0;<1 ==> max bet = super max bet
					If Super bet setting value <> 0;<1 ==> max bet = min(global max bet, super max bet)
			*/
			/* Agent:
				min bet
					If Master bet setting value = 0;0 ==> min bet = master min bet
					If Master bet setting value = 0;<1 ==> min bet = master min bet
					If Master bet setting value <> 0;0 or 0;<1 ==> min bet = max(global min bet; super min bet; master min bet)
				max bet
					If Master bet setting value = 0;0 ==> max bet = master max bet
					If Master bet setting value = 0;<1 ==> max bet = master max bet
					If Master bet setting value <> 0;0 or 0;<1 ==> max bet = min(global max bet, super max bet, master max bet)
			*/
			/* Member:
				min bet
					If Agent bet setting value = 0;0 ==> min bet = agent min bet
					If Agent bet setting value = 0;<1 ==> min bet = agent min bet
					If Agent bet setting value <> 0;0 or 0;<1 ==> min bet = max(global min bet; super min bet; master min bet; agent min bet)
				max bet
					If Agent bet setting value = 0;0 ==> max bet = agent max bet
					If Agent bet setting value = 0;<1 ==> max bet = agent max bet
					If Agent bet setting value <> 0;0 or 0;<1 ==> max bet = min(global max bet, super max bet, master max bet; agent max bet)
			*/
			DECLARE @BetGamelimitSMA20 TABLE(
					SportType SMALLINT,
					BetType SMALLINT,
					MinBet MONEY,
					MaxBet MONEY
				)
			
			INSERT INTO @BetGamelimitSMA20
			SELECT cs.SportType,cs.BetType
					,cs.MinBet
					,cs.MaxBet
			FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
				INNER JOIN #SportBettypeFilter20 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			WHERE cs.custid = @DirectUplineID
				AND cs.MinBet = 0 AND cs.MaxBet >= 0 AND cs.MaxBet < 1

			IF @@ROWCOUNT = 0 -- Upline not in 0,0 ; 0,<1
			BEGIN
				INSERT INTO @BetGamelimitSMA20
				SELECT cs.SportType,cs.BetType
						,ISNULL(Max(case when cs.MinBet = 0 and cs.MaxBet = 0 then NULL else cs.MinBet end),0) MinBet
						,ISNULL(Min(case when cs.MinBet = 0 and cs.MaxBet = 0 then NULL else cs.MaxBet end),0) MaxBet
				FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter20 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE cs.custid IN (@srecommend,@mrecommend,@recommend)
				GROUP BY cs.SportType,cs.BetType

				--UPDATE @BetGamelimitSMA20
				--SET MinBet = 0
				--WHERE MaxBet >= 0 AND MaxBet < 1
			END

			IF @RoleID IN (3,2)
			BEGIN
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   )
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,case when ps.MinBet = 0 and ps.MaxBet = 0 then cs.MinBet
						  when cs.MinBet = 0 and cs.MaxBet >= 0 and cs.MaxBet < 1 then cs.MinBet
						  when cs.MinBet < ps.MinBet THEN ps.MinBet
						  else cs.MinBet
					 end AS  MinBet
					,case when ps.MinBet = 0 and ps.MaxBet = 0 then cs.MaxBet
						  when cs.MaxBet > ps.MaxBet AND ps.MaxBet <> 0 THEN ps.MaxBet
						  else cs.MaxBet
					 end AS  MaxBet
				FROM @BetGamelimitSMA20 cs
					INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON cs.SportType = ps.SportType AND cs.BetType = ps.BetType AND ps.Currency = @Currency
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustBetSetting3rd_Member]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[MinBet]
					   ,[MaxBet]
					   )
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,case when ps.MinBet = 0 and ps.MaxBet = 0 then cs.MinBet
						  when cs.MinBet = 0 and cs.MaxBet >= 0 and cs.MaxBet < 1 then cs.MinBet
						  when cs.MinBet < ps.MinBet THEN ps.MinBet
						  else cs.MinBet
					 end AS  MinBet
					,case when ps.MinBet = 0 and ps.MaxBet = 0 then cs.MaxBet
						  when cs.MaxBet > ps.MaxBet AND ps.MaxBet <> 0 THEN ps.MaxBet
						  else cs.MaxBet
					 end AS  MaxBet
				FROM @BetGamelimitSMA20 cs
					INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON cs.SportType = ps.SportType AND cs.BetType = ps.BetType AND ps.Currency = @Currency
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 20			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
			END
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID				
			END
			RETURN	
		END CATCH
		
		/********************************************* Bet Limit : SettingType = 23 ****************************************/
		CREATE TABLE #SportBettypeFilter23 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT,SubType TinyINT)
		
		INSERT INTO #SportBettypeFilter23(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId,SubType)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId,SubType
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (23)
		
		DELETE @BetSetting
		
		IF ISNULL(@SettingType23,'') <> ''
		BEGIN			
			SELECT @xml = CONVERT(XML,@SettingType23)
			
			INSERT INTO @BetSetting(SportType, 
				BetType, 
				MinBet, 
				MaxBet, 
				MaxPerMatch, 
				MaxPerNumber)
			SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
				T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
				T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
				T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
				T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
				T.c.query('.').value('(R/@MaxPerNumber)[1]', 'money') AS MaxPerNumber
			FROM  @xml.nodes('/Root/R') T(c)  
		END

		BEGIN TRY
			IF @RoleID IN (3,2)
			BEGIN				
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs 
					INNER JOIN #SportBettypeFilter23 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE s.SubType = 1

				INSERT INTO [dbo].[CustBetSetting_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch]
				   ,[MaxPerNumber]
				   ,MaxPayoutPerMatch
				   )
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
					,MaxPerNumber
					,MaxPayoutPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter23 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE s.SubType = 2
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO [dbo].[CustBetSetting3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
				FROM @BetSetting cs 
					INNER JOIN #SportBettypeFilter23 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE s.SubType = 1
				
				INSERT INTO [dbo].[CustBetSetting_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch]
				   ,[MaxPerNumber]
				   ,MaxPayoutPerMatch
				   )
				SELECT
					@CustID
					,cs.SportType
					,cs.BetType
					,MinBet
					,MaxBet
					,MaxPerMatch
					,MaxPerNumber
					,MaxPayoutPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter23 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE s.SubType = 2
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 23			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
			END
			RETURN	
		END CATCH
		
		
		/********************************************* SB Discount : SettingType = 25 ****************************************/
		DELETE @NewDiscountTbl
		
		IF ISNULL(@SettingType25,'') <> ''		
		BEGIN
			SELECT @xml = CONVERT(XML,@SettingType25)
			
			IF @roleid IN (3,2)
			BEGIN
				INSERT INTO @NewDiscountTbl(sporttype,bettype,discount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@Discount)[1]', 'decimal(9,8)') AS discount
				FROM   @xml.nodes('/Root/R') T(c)
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO @NewDiscountTbl(sporttype,bettype,playerdiscount,discount,adiscount,sdiscount)
				SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
					T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
					T.c.query('.').value('(R/@playerdiscount)[1]', 'decimal(9,8)') AS playerdiscount,
					T.c.query('.').value('(R/@discount)[1]', 'decimal(9,8)') AS discount,
					T.c.query('.').value('(R/@adiscount)[1]', 'decimal(9,8)') AS adiscount,
					T.c.query('.').value('(R/@sdiscount)[1]', 'decimal(9,8)') AS sdiscount
				FROM   @xml.nodes('/Root/R') T(c) 
			END
			
			IF @roleid = 3
			BEGIN
				UPDATE t
				SET groupa = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
								ELSE groupa END,
					groupb = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 3),0)
								ELSE groupb END,
					groupc = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 7),0)
								ELSE groupc END,
					groupd = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 8),0)
								ELSE groupd END,
					adiscount = CASE WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
										THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
									WHEN bettype = 5
										THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)
									ELSE adiscount END			
				FROM #tmpcustsetting t
			END
			ELSE IF @roleid = 2
			BEGIN
				UPDATE t
				SET groupa = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
								ELSE groupa END,
					groupb = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 3),0)
								ELSE groupb END,
					groupc = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 7),0)
								ELSE groupc END,
					groupd = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
								THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 8),0)
								ELSE groupd END,
					discount = CASE WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
										THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
									WHEN bettype = 5
										THEN ISNULL((SELECT Discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)
									ELSE discount END			
				FROM #tmpcustsetting t
			END
			ELSE IF @roleid = 1
			BEGIN
				UPDATE t
				SET playerdiscount = CASE WHEN bettype IN (1, 2, 3, 7, 8) 
											THEN ISNULL((SELECT playerdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
										WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
											THEN ISNULL((SELECT playerdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
										WHEN bettype = 5
											THEN ISNULL((SELECT playerdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)
										ELSE playerdiscount END,
					discount = 	CASE WHEN bettype IN (1, 2, 3, 7, 8) 
											THEN ISNULL((SELECT discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
										WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
											THEN ISNULL((SELECT discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
										WHEN bettype = 5
											THEN ISNULL((SELECT discount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)	
										ELSE discount END,
					adiscount = 	CASE WHEN bettype IN (1, 2, 3, 7, 8) 
											THEN ISNULL((SELECT adiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
										WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
											THEN ISNULL((SELECT adiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
										WHEN bettype = 5
											THEN ISNULL((SELECT adiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)	
										ELSE adiscount END,
					sdiscount = 	CASE WHEN bettype IN (1, 2, 3, 7, 8) 
											THEN ISNULL((SELECT sdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 1),0)
										WHEN bettype IN (4, 6, 9, 10, 20, 21, 22, 9999) and sporttype <> 154
											THEN ISNULL((SELECT sdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 4),0)
										WHEN bettype = 5
											THEN ISNULL((SELECT sdiscount FROM @NewDiscountTbl WHERE sporttype = 1 AND bettype = 5),0)		
										ELSE sdiscount END					
				FROM #tmpcustsetting t
			END
		END
		
		BEGIN TRY
			IF @roleid IN (3,2,1)
			BEGIN			
				INSERT INTO [dbo].[custsetting]([custid], [bettype], [sporttype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking] )
				SELECT @custid, [bettype], [sporttype], [spositiontaking], [mpositiontaking], [apositiontaking], [slivepositiontaking], [mlivepositiontaking], [alivepositiontaking], autolivepositiontaking, autopositiontaking, [adiscount], [sdiscount], [groupa], [groupb], [groupc], [groupd], [groupe], [groupf], playerdiscount, discount, isautopositiontaking, isautolivepositiontaking, [autolivempositiontaking],[isautolivempositiontaking],[autompositiontaking],[isautompositiontaking]
				FROM #tmpcustSetting
			END
			
			IF (@IsMyanmarOdds = 1 AND @roleid > 1)
			BEGIN
				INSERT INTO dbo.AgentCommRate (CustID,SportType,BetType,CommRate) 
				SELECT @custid,1,1,Discount
				FROM @NewDiscountTbl
				WHERE sporttype = 2
					AND bettype = 1				
			END
			ELSE IF (@IsMyanmarOdds = 1 AND @roleid = 1)
			BEGIN
				CREATE TABLE #CustCommRate_MOtemp (CustID INT, SportType SMALLINT, BetType SMALLINT,CommRate decimal(9,8),roleid TINYINT)
			
				INSERT INTO #CustCommRate_MOtemp(CustID,SportType,BetType,CommRate,roleid )
				SELECT @CustID AS CustID,AC.SportType,AC.BetType,AC.CommRate,CI.roleid 
				FROM AgentCommRate ac WITH (NOLOCK)
					JOIN custInfo ci WITH (NOLOCK) ON ac.CustID = ci.custid
				WHERE ac.CustID IN (@srecommend,@mrecommend,@recommend) AND ac.Sporttype = 1 AND ac.Bettype = 1
				
				INSERT INTO CustCommRate (CustID,SportType,BetType,sdiscount,adiscount,discount,playerdiscount)
				SELECT CustID,SportType,BetType,T.[4],T.[3],T.[2],
					ISNULL((SELECT playerdiscount FROM @NewDiscountTbl WHERE sporttype = 2 AND bettype = 1),0)
				FROM #CustCommRate_MOtemp
				PIVOT(
					SUM(CommRate)
					FOR roleID IN ([2],[3],[4])
				) AS T
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 25			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
				DELETE FROM AgentCommRate WHERE CustID = @CustID
				DELETE FROM custsetting WHERE CustID = @CustID
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
				DELETE FROM CustCommRate WHERE CustID = @CustID
				DELETE FROM custsetting WHERE CustID = @CustID
			END
			RETURN	
		END CATCH
		
		/********************************************* SB Bet Setting : SettingType = 26 ****************************************/
		CREATE TABLE #SportBettypeFilter26 (ProductID TINYINT, SportType SMALLINT,Bettype SMALLINT,IsLive BIT, SettingType SMALLINT, RealProductId TINYINT)
		
		INSERT INTO #SportBettypeFilter26(ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId)
		SELECT ProductID ,SportType ,Bettype ,IsLive ,SettingType ,RealProductId
		FROM #ProductSettingDetail_tmp00
		WHERE SettingType IN (26)
		
		DELETE @BetSetting
		
		IF ISNULL(@SettingType26,'') <> ''
		BEGIN			
			SELECT @xml = CONVERT(XML,@SettingType26)
		
			INSERT INTO @BetSetting(SportType, 
				BetType, 
				MinBet, 
				MaxBet, 
				MaxPerMatch, 
				MaxPayoutPerMatch)
			SELECT T.c.query('.').value('(R/@SportType)[1]', 'smallint') AS sporttype,
				T.c.query('.').value('(R/@BetType)[1]', 'smallint') AS bettype,
				T.c.query('.').value('(R/@MinBet)[1]', 'money') AS minbet,
				T.c.query('.').value('(R/@MaxBet)[1]', 'money') AS maxbet,
				T.c.query('.').value('(R/@MPM)[1]', 'money') AS MaxPerMatch,
				T.c.query('.').value('(R/@MaxPayout)[1]', 'money') AS MaxPayoutPerMatch
			FROM  @xml.nodes('/Root/R') T(c)   
		END
				
		BEGIN TRY
			IF @roleid IN (3,2)
			BEGIN 
				INSERT INTO CustBetSetting_Agent(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
				SELECT @custid
					,cs.SportType        
					,cs.BetType          
					,MinBet           
					,MaxBet           
					,MaxPerMatch      
					,MaxPerNumber     
					,MaxPayoutPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO CustBetSetting_Member(CustID,SportType,BetType,MinBet,MaxBet,MaxPerMatch,MaxPerNumber,MaxPayoutPerMatch)
				SELECT @custid
					,cs.SportType        
					,cs.BetType          
					,MinBet           
					,MaxBet           
					,MaxPerMatch      
					,MaxPerNumber     
					,MaxPayoutPerMatch
				FROM @BetSetting cs
					INNER JOIN #SportBettypeFilter26 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 26			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
				DELETE FROM AgentCommRate WHERE CustID = @CustID
				DELETE FROM custsetting WHERE CustID = @CustID
			END		
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
				DELETE FROM CustCommRate WHERE CustID = @CustID
				DELETE FROM custsetting WHERE CustID = @CustID
			END
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
				INSERT INTO CustMaxPayoutSetting_Agent(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
				SELECT @custid , cs.SportType, cs.BetType, 
						cs.SingleMatchParlay,
						cs.Combo2,
						cs.Combo35,
						cs.ComboOver6
				FROM @NewMaxPayoutTbl cs
					INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
			ELSE IF @roleid = 1
			BEGIN
				INSERT INTO CustMaxPayoutSetting_Member(CustID,SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
				SELECT @custid , cs.SportType, cs.BetType, 
						cs.SingleMatchParlay,
						cs.Combo2,
						cs.Combo35,
						cs.ComboOver6
				FROM @NewMaxPayoutTbl cs
					INNER JOIN #SportBettypeFilter27 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
			END
		END TRY
		BEGIN CATCH 
			SELECT @ErrCode = 27			
			DELETE FROM CustProductStatus WHERE CustID = @CustID			
			IF @roleid > 1
			BEGIN
				DELETE FROM CustOverride WHERE CustID = @CustID
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID					
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Agent WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Agent WHERE CustID = @CustID
				DELETE FROM AgentCommRate WHERE CustID = @CustID
				DELETE FROM CustMaxPayoutSetting_Agent WHERE CustID = @CustID
			END	
			ELSE IF @roleid = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM CustStakeLevel_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustBetSetting_Member WHERE CustID = @CustID
				DELETE FROM CustCommRate WHERE CustID = @CustID
				DELETE FROM custsetting WHERE CustID = @CustID
				DELETE FROM CustMaxPayoutSetting_Member WHERE CustID = @CustID
			END			
			RETURN	
		END CATCH
		
		DROP TABLE #SportBettypeFilter1
		DROP TABLE #SportBettypeFilter2
		DROP TABLE #SportBettypeFilter19				
		DROP TABLE #SportBettypeFilter6
		DROP TABLE #SportBettypeFilter7			
		DROP TABLE #SportBettypeFilter16
		DROP TABLE #SportBettypeFilter20
		DROP TABLE #SportBettypeFilter23
		DROP TABLE #SportBettypeFilter26
		DROP TABLE #SportBettypeFilter27
		DROP TABLE #tmpcustSetting
	END	
	
	DROP TABLE #ProductSettingDetail_tmp00
END

