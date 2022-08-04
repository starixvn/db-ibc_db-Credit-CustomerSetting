/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" IsNested = "1"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_02] 
	@CustID				INT		= 0
	, @ExistingCustID	INT		= 0
	, @ErrCode			INT		= 0		OUTPUT
	, @SettingStatus TINYINT = 0
AS
/*
	Created: 20150928@Dominic
	Task : Copy Insert Settings of an existing S/M/A Into DCS Structure
	DB:  DBCUST/CustDB
	Original:

	
	Revision
		- 20160108@Elodie: Implementing SMA WinLossLimit Plugin - [Redmine #50082]
		- 20160125@Billy: Implementing Stake Level Settings - [Redmine: #51026]
		- 20160801@Elodie: Implementing GameStatus Plugin - [Redmine #60809]
		- 20161124@Winnie: Implementing Loss Limit - [Redmine #52647]
		- 20170310@Elodie: Implementing NewProductStatus Plugin - [Redmine #60809]
		- 20170310@Elodie: Update status by site and currency which user is offered - [Redmine #73126]
		- 20170310@Elodie: No data of DCS product when copy super from non-offered sites to offered sites - [Redmine #73155]
		- 20170530@Elodie: Implementing TicketCommission Plugin - [Redmine #75221]	
		- 20171017@Elodie: Implementing BetSetting Plugin - [Redmine #83729]	
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]
		- 20190409@Johnson: add suspendinfo [redmine: #105587]
		- 20200325@Elodie: Only insert sport is unhided [RedmineID:#128058]
		- 20200514@Elodie: Add new Setting Type 17 for mulitple stakelevel for member [Redmine: #131171]
		- 20200521@Elodie: NAP - Search & Copy Super - DCS: Product status of new super is Enabled when copy super from offered site to non-offered site [RedmineID: #108811]
		- 20200528@Elodie: NAP - Search & Copy Super - DCS: Win Loss limit is not insert for offer supers when search and copy non-offered to offer site [RedmineID: #134949]
		- 20200619@Elodie: Hardcode MaxPT = 100 [Redmine: #136081]
		- 20200615@Elodie: Implement new setting type 18,19 [Redmine: #135363]
		- 20201118@Eden: Insert New SettingType = 20 [Redmine: #131370]
		- 20201009@Tina: Add new parameter @SettingStatus [Redmine: #143077]
		- 20210408@Tina: Lock account & indirect close account [redmine: #148600]
		- 20220616@Johnson: define temp table to avoid dump db [redmine:#174035]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
	Parameter's explanation:
		- @SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN
	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency TINYINT, @_SourceSite VARCHAR(10), @_SourceSiteID INT, @_SourceCurrency TINYINT
	DECLARE @AgentID INT, @RoleID TINYINT		
	DECLARE @xmlStrDisabled XML, @xmlStrHidden XML, @xmlStrSync XML

	IF @ExistingCustID = 0 RETURN
	
	SELECT @ErrCode = 0

	if dbo.f_CheckRepTable('CustProductStatus') = 1
	BEGIN
		SELECT @AgentID = recommend, @RoleID = roleid, @_Site = Site, @_Currency = currency FROM Customer WITH (NOLOCK) WHERE custid = @CustID
		IF @RoleID = 1
			SELECT @_Site = Site FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @AgentID 			

		SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

		/********************** Product Status: SettingType = 4, Game Status: SettingType = 11, NewProductStatus = 13, NewProductStatus = 21*************/
		--Copy all status from source super
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[CustProductStatus] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			BEGIN
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,suspendinfo,CloseInfo)
				SELECT @CustID,cs.bitmapIsDisabled,cs.bitmapIsHidden,
						CASE WHEN @RoleID = 4 THEN 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ELSE bitmapHasSynced END,
						suspendinfo,
						CloseInfo
				FROM [dbo].[CustProductStatus] cs WITH(NOLOCK)
				WHERE CustID = @ExistingCustID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4
			DELETE FROM CustProductStatus WHERE CustID = @CustID

			RETURN
		END CATCH

		IF @RoleID = 4 --copy status theo site, currency of super [Redmine:#73155]
		BEGIN
			SELECT @_SourceSite = Site, @_SourceCurrency = currency FROM Customer WITH (NOLOCK) WHERE custid = @ExistingCustID

			SELECT @_SourceSiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_SourceSite

			DECLARE @OfferedProduct TABLE (Sporttype SMALLINT, Bettype INT, IsHiddenSource BIT, IsHiddenDes BIT)

			INSERT INTO @OfferedProduct (Sporttype, Bettype, IsHiddenSource, IsHiddenDes)
			SELECT Sporttype, Bettype, IsHidden, IsHidden
			FROM ProductSettingDetail WITH (NOLOCK)
			WHERE SettingType IN (4,11,13,21)

			UPDATE op
			SET IsHiddenSource = ps.IsHidden
			FROM @OfferedProduct op
				INNER JOIN dbo.ProductStatusSiteCurrency ps WITH (NOLOCK) ON ps.BetType = op.Bettype AND ps.SportType = op.Sporttype
			WHERE ps.Currency = @_SourceCurrency AND (ps.SiteID = @_SourceSiteID OR ps.SiteID = 0)

			UPDATE op
			SET IsHiddenSource = ps.IsHidden
			FROM @OfferedProduct op
				INNER JOIN dbo.ProductStatusSiteCurrency ps WITH (NOLOCK) ON ps.BetType = op.Bettype AND ps.SportType = op.Sporttype
			WHERE (ps.Currency = @_SourceCurrency OR ps.Currency = 0 ) AND ps.SiteID = @_SourceSiteID

			UPDATE op
			SET op.IsHiddenDes = ps.IsHidden
			FROM @OfferedProduct op
				INNER JOIN dbo.ProductStatusSiteCurrency ps WITH (NOLOCK) ON ps.BetType = op.Bettype AND ps.SportType = op.Sporttype
			WHERE ps.Currency = @_Currency AND (ps.SiteID = @_SiteID OR ps.SiteID = 0)

			UPDATE op
			SET op.IsHiddenDes = ps.IsHidden
			FROM @OfferedProduct op
				INNER JOIN dbo.ProductStatusSiteCurrency ps WITH (NOLOCK) ON ps.BetType = op.Bettype AND ps.SportType = op.Sporttype
			WHERE (ps.Currency = @_Currency OR ps.Currency = 0 ) AND ps.SiteID = @_SiteID

			/********************************************* Product Status: SettingType = 4 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter4(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
			INSERT INTO #SportBettypeFilter4(SportType,Bettype,IsLive,SettingType,IsDisabled,IsHidden,IsSync,bitmapOrder)
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 			
			FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
				INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
				INNER JOIN @OfferedProduct op ON op.Bettype = pbs.Bettype AND op.Sporttype = pbs.Sporttype
				INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,4,@SettingStatus) t ON pbs.SportType = t.SportType AND pbs.BetType = t.BetType AND psd.SettingType = t.SettingType
			WHERE op.IsHiddenSource <> 0 OR op.IsHiddenDes <> 0
		
			IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter4)
			BEGIN
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter4 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE stt.Currency = @_Currency AND (stt.SiteID = @_SiteID OR stt.SiteID = 0)
			
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter4 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE (stt.Currency = @_Currency OR stt.Currency = 0 ) AND stt.SiteID = @_SiteID
		
				BEGIN TRY				
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
				
					UPDATE cs
					SET bitmapIsDisabled = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
						bitmapIsHidden = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
						bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync)))									
					FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
					WHERE cs.CustID = @CustID     

				END TRY
				BEGIN CATCH
					SELECT @ErrCode = 4

					DELETE FROM CustProductStatus WHERE CustID = @CustID
					RETURN
				END CATCH
			END

				/********************************************* NewProductStatus: SettingType = 13 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter13(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
			INSERT INTO #SportBettypeFilter13(SportType, Bettype, IsLive, SettingType, IsDisabled, IsHidden, IsSync, bitmapOrder)
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
				INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
				INNER JOIN @OfferedProduct op ON op.Bettype = pbs.Bettype AND op.Sporttype = pbs.Sporttype
				INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,13,@SettingStatus) t ON pbs.SportType = t.SportType AND pbs.BetType = t.BetType AND psd.SettingType = t.SettingType
			WHERE op.IsHiddenSource <> 0 OR op.IsHiddenDes <> 0

			IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter13)
			BEGIN							
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter13 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE stt.Currency = @_Currency AND (stt.SiteID = @_SiteID OR stt.SiteID = 0)
			
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter13 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE (stt.Currency = @_Currency OR stt.Currency = 0 ) AND stt.SiteID = @_SiteID
		
				BEGIN TRY				
					--Get from default status values
					--Sync: default status setting
					--Hide: default status setting
					--Enable/Disable: default status setting
					SET @xmlStrDisabled = (
							SELECT (
									SELECT DISTINCT ft.bitmapOrder	AS '@b'
										, ft.IsDisabled	AS '@s'
									FROM #SportBettypeFilter13 ft 	
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
									FROM #SportBettypeFilter13 ft 	
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
								FROM #SportBettypeFilter13 ft 	
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
					SELECT @ErrCode = 13

					DELETE FROM CustProductStatus WHERE CustID = @CustID
					RETURN
				END CATCH
			END

			/********************************************* NewProductStatus: SettingType = 21 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter21(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
			INSERT INTO #SportBettypeFilter21(SportType, Bettype, IsLive, SettingType, IsDisabled, IsHidden, IsSync, bitmapOrder)
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
				INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
				INNER JOIN @OfferedProduct op ON op.Bettype = pbs.Bettype AND op.Sporttype = pbs.Sporttype
				INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,21,@SettingStatus) t ON pbs.SportType = t.SportType AND pbs.BetType = t.BetType AND psd.SettingType = t.SettingType
			WHERE op.IsHiddenSource <> 0 OR op.IsHiddenDes <> 0

			IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter21)
			BEGIN							
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter21 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE stt.Currency = @_Currency AND (stt.SiteID = @_SiteID OR stt.SiteID = 0)
			
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter21 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE (stt.Currency = @_Currency OR stt.Currency = 0 ) AND stt.SiteID = @_SiteID
		
				BEGIN TRY				
					--Get from default status values
					--Sync: default status setting
					--Hide: default status setting
					--Enable/Disable: default status setting
					SET @xmlStrDisabled = (
							SELECT (
									SELECT DISTINCT ft.bitmapOrder	AS '@b'
										, ft.IsDisabled	AS '@s'
									FROM #SportBettypeFilter21 ft 	
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
									FROM #SportBettypeFilter21 ft 	
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
								FROM #SportBettypeFilter21 ft 	
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
					SELECT @ErrCode = 21

					DELETE FROM CustProductStatus WHERE CustID = @CustID
					RETURN
				END CATCH
			END
			
			/********************************************* Game Status: SettingType = 11 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter11(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
			
			INSERT INTO #SportBettypeFilter11(SportType,Bettype,IsLive, SettingType,IsDisabled,IsHidden,IsSync,bitmapOrder)		
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
				INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
				INNER JOIN @OfferedProduct op ON op.Bettype = pbs.Bettype AND op.Sporttype = pbs.Sporttype
				INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(NULL,11,@SettingStatus) t ON pbs.SportType = t.SportType AND pbs.BetType = t.BetType AND psd.SettingType = t.SettingType
			WHERE op.IsHiddenSource <> 0 OR op.IsHiddenDes <> 0

			IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter11)
			BEGIN						
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter11 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE stt.Currency = @_Currency AND (stt.SiteID = @_SiteID OR stt.SiteID = 0)
			
				UPDATE main
				SET main.IsDisabled = stt.IsDisabled, 
					main.IsHidden = stt.IsHidden
				FROM #SportBettypeFilter11 main
					INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON main.SportType = stt.SportType AND main.Bettype = stt.Bettype
				WHERE (stt.Currency = @_Currency OR stt.Currency = 0 ) AND stt.SiteID = @_SiteID
		
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
		END		
	END

	if (dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1	
		AND dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1
		AND dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1
	   )
	BEGIN					
		CREATE TABLE #ProductSettingDetail(
			[SettingType] [smallint] NOT NULL,
			[ProductID] [tinyint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsLive] [bit] NOT NULL,
			[IsHiddenSource] [BIT] NOT NULL,
			[HasSyncSource] [BIT] NOT NULL
		)
		CREATE TABLE #OfferedProductList(
			[ProductID] [tinyint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsHidden] [BIT] NOT NULL,
			[IsHiddenSource] [BIT] NOT NULL,
			[HasSyncSource] [BIT] NOT NULL
		)

		SELECT @AgentID = recommend, @RoleID = roleid, @_Site = Site, @_Currency = currency FROM Customer WITH (NOLOCK) WHERE custid = @CustID
		IF @RoleID = 1
			SELECT @_Site = Site FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @AgentID 			

		SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

		SELECT @_SourceSite = Site, @_SourceCurrency = currency FROM Customer WITH (NOLOCK) WHERE custid = @ExistingCustID

		SELECT @_SourceSiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_SourceSite

		INSERT INTO #OfferedProductList (ProductID, SportType, BetType, IsHidden, IsHiddenSource,HasSyncSource)
		SELECT ps.RealProductId, ps.SportType, ps.BetType, IsHidden, IsHidden, st.value
		FROM dbo.ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN dbo.ProductStatusProfile psp WITH (NOLOCK) ON psp.Bettype = ps.BetType AND psp.Sporttype = ps.SportType
			CROSS APPLY dbo.CustProductStatus cps WITH (NOLOCK) 
			CROSS APPLY dbo.f_CustSetting_ProductStatusSel(cps.bitmapHasSynced, psp.bitmapOrder) st
		WHERE SettingType IN (4,11,13,21) AND cps.CustID = @ExistingCustID	
		
		UPDATE op
		SET op.IsHidden = stt.IsHidden
		FROM #OfferedProductList op
			INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE stt.Currency = @_Currency AND (stt.SiteID = @_SiteID OR stt.SiteID = 0)
			
		UPDATE op
		SET op.IsHidden = stt.IsHidden
		FROM #OfferedProductList op
			INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE (stt.Currency = @_Currency OR stt.Currency = 0 ) AND stt.SiteID = @_SiteID

		UPDATE op
		SET op.IsHidden = CASE WHEN @_Site = 'IMBC' THEN 0 ELSE 1 END
		FROM #OfferedProductList op
		WHERE ProductID = 20

		UPDATE op
		SET op.IsHiddenSource = stt.IsHidden
		FROM #OfferedProductList op
			INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE stt.Currency = @_SourceCurrency AND (stt.SiteID = @_SourceSiteID OR stt.SiteID = 0)
			
		UPDATE op
		SET op.IsHiddenSource = stt.IsHidden
		FROM #OfferedProductList op
			INNER JOIN dbo.ProductStatusSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE (stt.Currency = @_SourceCurrency OR stt.Currency = 0 ) AND stt.SiteID = @_SourceSiteID

		UPDATE op
		SET op.IsHiddenSource = CASE WHEN @_SourceSite = 'IMBC' THEN 0 ELSE 1 END
		FROM #OfferedProductList op
		WHERE ProductID = 20

		INSERT #ProductSettingDetail(SettingType,ProductID,SportType,BetType,IsLive,IsHiddenSource,HasSyncSource)
		SELECT SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,IsLive
				,op.IsHiddenSource
				,op.HasSyncSource
		FROM [dbo].[ProductSettingDetail] ps WITH(NOLOCK)
			INNER JOIN (SELECT DISTINCT ProductID, IsHidden, IsHiddenSource, HasSyncSource 
						FROM #OfferedProductList WITH (NOLOCK)) op ON ps.RealProductId = op.ProductID			
		WHERE op.IsHidden = 0 AND ps.SettingType NOT IN (4,11,13,21)

		UPDATE op
		SET op.IsHiddenSource = 1, HasSyncSource = 0  
		FROM #ProductSettingDetail op
			INNER JOIN dbo.SportNonOfferedSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE stt.Currency = @_SourceCurrency AND (stt.SiteID = @_SourceSiteID OR stt.SiteID = 0)
			
		UPDATE op 
		SET op.IsHiddenSource = 1, HasSyncSource = 0
		FROM #ProductSettingDetail op
			INNER JOIN dbo.SportNonOfferedSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE (stt.Currency = @_SourceCurrency OR stt.Currency = 0 ) AND stt.SiteID = @_SourceSiteID

		DELETE sb		
		FROM #ProductSettingDetail sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE ssc.Currency = @_Currency AND (ssc.SiteID = @_SiteID OR ssc.SiteID = 0)
			
		DELETE sb		
		FROM #ProductSettingDetail sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE (ssc.Currency = @_Currency OR ssc.Currency = 0 ) AND ssc.SiteID = @_SiteID

		/********************************************* Position Taking: SettingType IN (1,18) ***********************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustPTSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
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
						,cs.SportType
						,cs.BetType
						,cs.IsLive
						,[SuperPT]
						,[MasterPT]
						,[AgentPT]
						,[IsAutoMasterPT]
						,[AutoMasterPT]
						,[IsAutoSuperPT]
						,[AutoSuperPT]
						,[MinPT]
						,100 --[MaxPT]
					FROM [dbo].[CustPTSetting3rd_Agent] cs WITH(NOLOCK)
						INNER JOIN #ProductSettingDetail ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.IsLive = cs.IsLive
					WHERE CustID = @ExistingCustID AND ps.SettingType IN (1,18) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
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
				   ,[MaxPT])
				SELECT 
					@Custid
					,dtl.SportType
					,dtl.BetType
					,dtl.IsLive
					,0,0,0,0,0,0,0,0
					,100 --dtl.MaxPT
				FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = dtl.BetType AND ps.SportType = dtl.SportType AND ps.IsLive = dtl.IsLive  AND ps.SettingType = dtl.SettingType
				WHERE ps.SettingType IN (1,18) AND (ps.IsHiddenSource = 1 OR ps.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 1
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID
			
			RETURN
		END CATCH
	
		/********************************************* Bet Limit : SettingType = 2, Bet Game Limit : SettingType = 9 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustBetSetting3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
						   ([CustID]
						   ,[SportType]
						   ,[BetType]
						   ,[MinBet]
						   ,[MaxBet]
						   ,[MaxPerMatch])
				SELECT		@CustID
						   ,cs.SportType
						   ,cs.BetType
						   ,[MinBet]
						   ,[MaxBet]
						   ,[MaxPerMatch]
				FROM [dbo].[CustBetSetting3rd_Agent] cs WITH (NOLOCK)
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN (2,9,16,20) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
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
					,t.SportType
					,t.BetType
					,0
					,0
					,0
				FROM #ProductSettingDetail t 
				WHERE t.SettingType = 2 AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
				
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[MinBet]
					   ,[MaxBet]
					   ,[MaxPerMatch])
				SELECT
					@CustID
					,t.SportType
					,t.BetType
					,ps.DefaultMinBet
					,ps.DefaultMaxBet
					,ISNULL(ps.DefaultMaxPerMatch,0)
				FROM #ProductSettingDetail t 
					INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON t.SportType = ps.Sporttype AND t.Bettype = ps.Bettype AND ps.IsDep = 0 AND ps.Currency = @_Currency
				WHERE t.SettingType IN (9,16,20) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 2
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH
	
		/************************* Commision : SettingType = 3,19, Charge comm: Setting Type = 5, Ticket comm: Setting Type = 14*****************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
						   ([CustID]
						   ,[SportType]
						   ,[BetType]
						   ,[Discount])
				SELECT		@CustID
						   ,cs.SportType
						   ,cs.BetType
						   ,[Discount]
				FROM [dbo].[CustDiscount3rd_Agent] cs WITH(NOLOCK)
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN (3,5,14,19) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount])
				SELECT 
					@CustID
					,t.SportType
					,t.BetType
					,0 -- 0 zero by default
				FROM #ProductSettingDetail t 
				WHERE t.SettingType IN (3,5,14,19) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 3
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH

		/********************************************* SMA Win Loss Limit : SettingType = 6 SMA Loss Limit : SettingType = 12 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustWinLossLimit_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO [dbo].[CustWinLossLimit_Agent]
							([CustID]
							,[SportType]
							,[BetType]
							,[MaxWinLimit]
							,[MaxLossLimit]
							,[IsAutoReset])
				SELECT		@CustID
							,cs.SportType
							,cs.BetType
							,MaxWinLimit
							,MaxLossLimit
							,IsAutoReset
				FROM [dbo].[CustWinLossLimit_Agent] cs WITH (NOLOCK)
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN( 6,12) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
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
					,t.SportType
					,t.BetType
					,0
					,gs.DefaultLossLimit
					,1
				FROM #ProductSettingDetail t 
					INNER JOIN LossLimit_GlobalSetting gs ON gs.ProductId = t.ProductID
					INNER JOIN CustInfo ci WITH (NOLOCK) ON gs.ExchangeId = ci.currency
				WHERE ci.custid = @CustID AND t.SettingType IN (6,12) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 6
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH

		
		/****************************** Stake Level Member Single Selection : SettingType = 7, Group Stake Level = 8 ******************************/
		/*************************** Group Stake Level Member Single Selection : SettingType = 8 ***************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO dbo.CustStakeLevel_Agent
						(CustID
					,	SportType
					,	BetType
					,	StakeLevelList)
				SELECT	@CustID
					,	cs.SportType
					,	cs.BetType
					,	cs.StakeLevelList
				FROM dbo.CustStakeLevel_Agent AS cs
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN (7,17,8) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF	@RoleID = 4
			BEGIN
				INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType    , BetType    , StakeLevelList)
				SELECT	@CustID, ps.SportType, ps.Bettype, LEFT(sl.list, LEN(sl.list) - 1)
				FROM	#ProductSettingDetail ps 
					CROSS APPLY (
						SELECT	CAST(sl.StakeLevelID AS VARCHAR) + ','
						FROM		dbo.StakeLevel	AS sl WITH(NOLOCK)
						INNER JOIN	dbo.custInfo	AS ci WITH(NOLOCK)
								ON	ci.currency = sl.ExchangeId
						WHERE	ci.custid = @CustID
							AND	sl.GameTypeID = ps.Bettype
						FOR XML PATH ('')
					) sl(list)
				WHERE ps.SettingType IN (7,17,8) AND (ps.IsHiddenSource = 1 OR ps.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 7
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
			DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
			DELETE FROM dbo.CustStakeLevel_Agent WHERE CustID = @CustID
		
			RETURN
		END CATCH
	END	
END
GO