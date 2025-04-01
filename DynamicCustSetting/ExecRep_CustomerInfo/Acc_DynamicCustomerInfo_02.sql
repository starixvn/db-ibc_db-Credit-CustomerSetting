/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" IsNested = "1"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_02] 
	@CustID				INT		= 0
	, @ExistingCustID	INT		= 0
	, @ErrCode			INT		= 0		OUTPUT
	, @SettingStatus	TINYINT = 0
	, @ProductProfile	VARCHAR(MAX) = NULL OUTPUT -- Json
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
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20230307@Eden: Migrate NG and Keno to DCS structure [Redmine: #179711]
		- 202300801@Helios: Customer Setting - Simplify Live Casino Customer Setting [RedmineID: #189389] 
		- 20231228@Eden: DCS Sportsbook Credit[redmine: #193083]
		- 20240628@Johnson: scale out DBCUST [redmine: #199915]
		- 20240520@Eden: Unify RNG Games [redmine: #204358] 
		- 20241204@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
		- 20250324@Johnson: change datatype for ExchangeID[redmine: #221098]
	Parameter's explanation:
		- @SettingStatus: 0: Pro, 1: UAT
	*/
BEGIN	
	IF NOT (dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT	
		)
	RETURN;
				
	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency INT, @_SourceSite VARCHAR(10), @_SourceSiteID INT, @_SourceCurrency INT
	DECLARE @AgentID INT, @RoleID TINYINT		
	DECLARE @xmlStrDisabled XML, @xmlStrHidden XML, @xmlStrSync XML

	IF @ExistingCustID = 0 RETURN
	
	SELECT @ErrCode = 0

	CREATE TABLE #ProductSettingDetail_tmp02(
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
		SubType	tinyint,
		PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	--Get site/currency
	SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID
	SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

	INSERT INTO #ProductSettingDetail_tmp02(SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
		,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType)
	SELECT SettingType,SportType,BetType,IsLive,ProductID,MaxPT,MaxDiscount,IsSync,IsHidden,IsDisabled,SettingLevel,DisplayOrder
			,SettingStatus,IntervalValue,RealProductId,MaxChoice,ProductSettingID,Parent_ProductSettingID,Child_DisplayOrder,SubType
	FROM dbo.f_CustSetting_ProductProfileSel (NULL,@SettingStatus,@_SiteID,@_Currency) 
		
	BEGIN
		SELECT @AgentID = recommend, @RoleID = roleid FROM Customer WITH (NOLOCK) WHERE custid = @CustID
		IF @RoleID = 1
			SELECT @_Site = Site FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @AgentID 			
			
		/********************** Product Status: SettingType = 4, Game Status: SettingType = 11, NewProductStatus = 13, NewProductStatus = 21*************/
		--Copy all status from source super
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[CustProductStatus] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
			BEGIN
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,suspendinfo,CloseInfo,RepUpdateTime)
				SELECT @CustID,cs.bitmapIsDisabled,cs.bitmapIsHidden,
						CASE WHEN @RoleID = 4 THEN 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ELSE bitmapHasSynced END,
						suspendinfo,
						CloseInfo,
						dbo.f_GetDateTime2()
				FROM [dbo].[CustProductStatus] cs WITH(NOLOCK)
				WHERE CustID = @ExistingCustID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4			
			RETURN
		END CATCH

		IF @RoleID = 4 --copy status theo site, currency of super [Redmine:#73155]
		BEGIN
			SELECT @_SourceSite = Site, @_SourceCurrency = currency FROM Customer WITH (NOLOCK) WHERE custid = @ExistingCustID

			SELECT @_SourceSiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_SourceSite

			DECLARE @OfferedProduct TABLE (Sporttype SMALLINT, Bettype INT, IsHiddenSource BIT, IsHiddenDes BIT)

			INSERT INTO @OfferedProduct (Sporttype, Bettype, IsHiddenSource, IsHiddenDes)
			SELECT Sporttype, Bettype, IsHidden, IsHidden
			FROM #ProductSettingDetail_tmp02 WITH (NOLOCK)
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
			FROM #ProductSettingDetail_tmp02 psd WITH(NOLOCK)  
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
						bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync))),
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
					WHERE cs.CustID = @CustID     

				END TRY
				BEGIN CATCH
					SELECT @ErrCode = 4
					RETURN
				END CATCH
			END

				/********************************************* NewProductStatus: SettingType = 13 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter13(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
			INSERT INTO #SportBettypeFilter13(SportType, Bettype, IsLive, SettingType, IsDisabled, IsHidden, IsSync, bitmapOrder)
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM #ProductSettingDetail_tmp02 psd WITH(NOLOCK)  
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
						bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync))),
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
					WHERE cs.CustID = @CustID     

				END TRY
				BEGIN CATCH
					SELECT @ErrCode = 13
					RETURN
				END CATCH
			END

			/********************************************* NewProductStatus: SettingType = 21 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter21(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
		
			INSERT INTO #SportBettypeFilter21(SportType, Bettype, IsLive, SettingType, IsDisabled, IsHidden, IsSync, bitmapOrder)
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM #ProductSettingDetail_tmp02 psd WITH(NOLOCK)  
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
						bitmapHasSynced = (select bitmap from dbo.f_GenerateProductStatus_multiple (bitmapHasSynced, CONVERT(VARCHAR(MAX),@xmlStrSync))),
						RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus cs WITH (ROWLOCK,UPDLOCK)
					WHERE cs.CustID = @CustID     

				END TRY
				BEGIN CATCH
					SELECT @ErrCode = 21
					RETURN
				END CATCH
			END
			
			/********************************************* Game Status: SettingType = 11 ************************************/
			--Get sporttype/Bettype for this setting type	
			CREATE TABLE #SportBettypeFilter11(SportType SMALLINT, Bettype SMALLINT, IsLive BIT, SettingType SMALLINT, IsDisabled BIT,IsHidden BIT,IsSync BIT, bitmapOrder TINYINT)
			
			INSERT INTO #SportBettypeFilter11(SportType,Bettype,IsLive, SettingType,IsDisabled,IsHidden,IsSync,bitmapOrder)		
			SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
			FROM #ProductSettingDetail_tmp02 psd WITH(NOLOCK)  
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
		END		
						
		CREATE TABLE #ProductProfile(
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
			[HasSyncSource] [BIT] NOT NULL,
			[DummyProductID] [tinyint] NOT NULL,
			[ProductSettingID] [int]
		)

		SELECT @AgentID = recommend, @RoleID = roleid, @_Site = Site, @_Currency = currency FROM Customer WITH (NOLOCK) WHERE custid = @CustID
		IF @RoleID = 1
			SELECT @_Site = Site FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @AgentID 			

		SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

		SELECT @_SourceSite = Site, @_SourceCurrency = currency FROM Customer WITH (NOLOCK) WHERE custid = @ExistingCustID

		SELECT @_SourceSiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_SourceSite

		INSERT INTO #OfferedProductList (ProductID, SportType, BetType, IsHidden, IsHiddenSource,HasSyncSource,DummyProductID,ProductSettingID)
		SELECT ps.RealProductId, ps.SportType, ps.BetType, IsHidden, IsHidden, st.value, ps.ProductID,ProductSettingID
		FROM #ProductSettingDetail_tmp02 ps WITH (NOLOCK)
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

		INSERT #ProductProfile(SettingType,ProductID,SportType,BetType,IsLive,IsHiddenSource,HasSyncSource)
		SELECT SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,IsLive
				,op.IsHiddenSource
				,op.HasSyncSource
		FROM #ProductSettingDetail_tmp02 ps WITH(NOLOCK)
			INNER JOIN (
							SELECT DISTINCT ProductID, IsHiddenSource, HasSyncSource 
							FROM #OfferedProductList WITH (NOLOCK)
							WHERE IsHidden = 0
						) op ON ps.RealProductId = op.ProductID			
		WHERE ps.SettingType NOT IN (4,11,13,21)
			AND ps.Parent_ProductSettingID IS NULL
		UNION -- Hidden if all hidden, Sync if any sync
		SELECT   ps.SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,ps.IsLive
				,MIN(CAST(op.IsHiddenSource AS INT)) AS IsHiddenSource
				,MAX(CAST(op.HasSyncSource AS INT)) AS HasSyncSource
		FROM #ProductSettingDetail_tmp02 ps WITH(NOLOCK)
			INNER JOIN (
							SELECT DISTINCT  DummyProductID,IsHiddenSource, HasSyncSource
							FROM #OfferedProductList WITH (NOLOCK)
							WHERE IsHidden = 0
						) op ON ps.ProductID = op.DummyProductID			
		WHERE ps.SettingType = 22
			AND ps.Parent_ProductSettingID IS NULL
		GROUP BY ps.SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,ps.IsLive
				,op.IsHiddenSource
				,op.HasSyncSource
		UNION -- Ref Status
		SELECT SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,ps.IsLive
				,op.IsHiddenSource
				,op.HasSyncSource
		FROM #ProductSettingDetail_tmp02 ps WITH(NOLOCK)
			INNER JOIN (
							SELECT DISTINCT ProductSettingID, IsHiddenSource, HasSyncSource
							FROM #OfferedProductList WITH (NOLOCK) 
							WHERE IsHidden = 0
						) op ON ps.Parent_ProductSettingID = op.ProductSettingID
		WHERE ps.SettingType NOT IN (4,11,13,21)
		UNION -- alway offer
		SELECT SettingType
				,ps.ProductId
				,ps.SportType
				,ps.BetType
				,ps.IsLive
				,0 AS IsHiddenSource
				,1 AS HasSyncSource
		FROM #ProductSettingDetail_tmp02 ps WITH(NOLOCK)
		WHERE ps.SettingType NOT IN (4,11,13,21)
			AND ps.Parent_ProductSettingID = 0

		--> Update Non offer Products
		UPDATE op
		SET op.IsHiddenSource = 1, HasSyncSource = 0  
		FROM #ProductProfile op
			INNER JOIN dbo.SportNonOfferedSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE stt.Currency = @_SourceCurrency AND (stt.SiteID = @_SourceSiteID OR stt.SiteID = 0)
			
		UPDATE op 
		SET op.IsHiddenSource = 1, HasSyncSource = 0
		FROM #ProductProfile op
			INNER JOIN dbo.SportNonOfferedSiteCurrency stt WITH(NOLOCK) ON op.SportType = stt.SportType AND op.Bettype = stt.Bettype
		WHERE (stt.Currency = @_SourceCurrency OR stt.Currency = 0 ) AND stt.SiteID = @_SourceSiteID

		DELETE sb		
		FROM #ProductProfile sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE ssc.Currency = @_Currency AND (ssc.SiteID = @_SiteID OR ssc.SiteID = 0)
			
		DELETE sb		
		FROM #ProductProfile sb
			INNER JOIN dbo.SportNonOfferedSiteCurrency ssc WITH(NOLOCK) ON sb.SportType = ssc.SportType AND sb.Bettype = ssc.Bettype
		WHERE (ssc.Currency = @_Currency OR ssc.Currency = 0 ) AND ssc.SiteID = @_SiteID

		--Output Json
		SELECT @ProductProfile = ( 
			SELECT SettingType,ProductID,SportType,BetType,IsLive,IsHiddenSource,HasSyncSource
			FROM #ProductProfile
			FOR JSON PATH
		)
		
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
						,[MaxPT]
						,RepUpdateTime)
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
						,dbo.f_GetDateTime2()
					FROM [dbo].[CustPTSetting3rd_Agent] cs WITH(NOLOCK)
						INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType AND ps.IsLive = cs.IsLive
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
				   ,[MaxPT]
				   ,RepUpdateTime)
				SELECT 
					@Custid
					,dtl.SportType
					,dtl.BetType
					,dtl.IsLive
					,0,0,0,0,0,0,0,0
					,100 --dtl.MaxPT
					,dbo.f_GetDateTime2()
				FROM #ProductSettingDetail_tmp02 dtl WITH (NOLOCK)
					INNER JOIN #ProductProfile ps ON ps.BetType = dtl.BetType AND ps.SportType = dtl.SportType AND ps.IsLive = dtl.IsLive  AND ps.SettingType = dtl.SettingType
				WHERE ps.SettingType IN (1,18) AND (ps.IsHiddenSource = 1 OR ps.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 1
			RETURN
		END CATCH
	
		/********************************************* Bet Limit : SettingType = 2,9,16,20,23 ****************************************/
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
					INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
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
				FROM #ProductProfile t 
				WHERE t.SettingType IN (2) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
				
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
				FROM #ProductProfile t 
					INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON t.SportType = ps.Sporttype AND t.Bettype = ps.Bettype AND ps.IsDep = 0 AND ps.Currency = @_Currency
				WHERE t.SettingType IN (9,16,20) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 2
			RETURN
		END CATCH
	
		/************************* Commision : SettingType = 3,19, Charge comm: Setting Type = 5, Ticket comm: Setting Type = 14*****************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustDiscount3rd_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
						   ([CustID]
						   ,[SportType]
						   ,[BetType]
						   ,[Discount]
						   ,RepUpdateTime)
				SELECT		@CustID
						   ,cs.SportType
						   ,cs.BetType
						   ,[Discount]
						   ,dbo.f_GetDateTime2()
				FROM [dbo].[CustDiscount3rd_Agent] cs WITH(NOLOCK)
					INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN (3,5,14,19) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
			BEGIN
				INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount]
					   ,RepUpdateTime)
				SELECT 
					@CustID
					,t.SportType
					,t.BetType
					,0 -- 0 zero by default
					,dbo.f_GetDateTime2()
				FROM #ProductProfile t 
				WHERE t.SettingType IN (3,5,14,19) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 3
			RETURN
		END CATCH

		/********************************************* SMA Win Loss Limit : SettingType = 6, 22 SMA Loss Limit : SettingType = 12 ****************************************/
		BEGIN TRY
			IF EXISTS(SELECT TOP 1 1 FROM [dbo].[CustWinLossLimit_Agent] WITH(NOLOCK) WHERE CustID = @ExistingCustID)
				INSERT INTO [dbo].[CustWinLossLimit_Agent]
							([CustID]
							,[SportType]
							,[BetType]
							,[MaxWinLimit]
							,[MaxLossLimit]
							,[IsAutoReset]
							,RepUpdateTime)
				SELECT		@CustID
							,cs.SportType
							,cs.BetType
							,MaxWinLimit
							,MaxLossLimit
							,IsAutoReset
							,dbo.f_GetDateTime2()
				FROM [dbo].[CustWinLossLimit_Agent] cs WITH (NOLOCK)
					INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN( 6,12,22) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF @RoleID = 4
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
					,t.SportType
					,t.BetType
					,0
					,gs.DefaultLossLimit
					,1
					,dbo.f_GetDateTime2()
				FROM #ProductProfile t 
					INNER JOIN LossLimit_GlobalSetting gs ON gs.ProductId = t.ProductID
					INNER JOIN CustInfo ci WITH (NOLOCK) ON gs.ExchangeId = ci.currency
				WHERE ci.custid = @CustID AND t.SettingType IN (6,12,22) AND (t.IsHiddenSource = 1 OR t.HasSyncSource = 0)
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 6
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
					,	StakeLevelList
					,	RepUpdateTime)
				SELECT	@CustID
					,	cs.SportType
					,	cs.BetType
					,	cs.StakeLevelList
					,	dbo.f_GetDateTime2()
				FROM dbo.CustStakeLevel_Agent AS cs
					INNER JOIN #ProductProfile ps ON ps.BetType = cs.BetType AND ps.SportType = cs.SportType
				WHERE CustID = @ExistingCustID AND ps.SettingType IN (7,17,8) AND ps.IsHiddenSource = 0 AND (@RoleID <> 4 OR ps.HasSyncSource = 1)

			IF	@RoleID = 4
			BEGIN
				INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType    , BetType    , StakeLevelList, RepUpdateTime)
				SELECT	@CustID, ps.SportType, ps.Bettype, LEFT(sl.list, LEN(sl.list) - 1), dbo.f_GetDateTime2()
				FROM	#ProductProfile ps 
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
			RETURN
		END CATCH
	END	

	DROP TABLE #ProductSettingDetail_tmp02
END
GO