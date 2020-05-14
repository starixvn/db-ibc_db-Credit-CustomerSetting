/*<info serverAlias="DBCUST-CustDB" executers="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_00] 
	@CustID				INT
	, @SuperID			INT
	, @MasterID			INT
	, @AgentID			INT
	, @RoleID			TINYINT	
	, @ProductID		TINYINT = NULL
	, @isSearchAndCopy 	BIT = 0
	, @copyFromCustID 	INT = 0
	, @ErrCode			INT	= 0 OUTPUT
AS
/*
	Created: 20150916@Dominic
	Task : Insert Settings Into DCS Structure
	DB:  DBCUST/CustDB
	Original:
	
	Revision
		- 20151215: Enhance proscess to create new customer #49344
		- 20151228@Helen: Enhance process to create new customer #49344
		- 20151230@Helen: Add more conditions to detect dummy account -  #49344
		- 20160104@Dominic: + Implementing Charge Commission Plugin - Redmine #49689
							+ Insert iCricket data for IMBC only#49689
		- 20160108@Elodie: Implementing SMA WinLossLimit Plugin - [Redmine # 
		- 20160125@Billy: Implementing Stake Level Settings - [Redmine: #51026]
		- 20160309@Dominic: Support controling default product status by site and by currency - [Redmine: #53604]
		- 20160406@Winnie: Implementing Group Stake Level Settings - [Redmine: #55532]
		- 20160801@Elodie: Implementing GameBetLimit Plugin, GameStatus Plugin - [Redmine #60809]
		- 20161011@Winnie: Implement for Loss limit setting type - [RedmineID: #65472]
		- 20160801@Elodie: Implementing NewProductStatus Plugin - [Redmine #70722]					
		- 20170223@Elodie: Fix bug "newly created direct agent does not follow status of dummy master" - [Redmine #71925]
		- 20170223@Elodie: Change preset PT to max PT - [Redmine: #71883]
		- 20170530@Elodie: Implementing TicketCommission Plugin - [Redmine #75221]	
		- 20171017@Elodie: Implementing BetSetting Plugin - [Redmine #83729]	
		- 20180206@Elodie: Fix bug "default status of new direct master does not take into ProductStatusSiteCurrency table" - [Redmine #90570]
		- 20190408@Johnson: add suspendInfo [Redmine: #105587]
		- 20200325@Elodie: Only insert sport is unhided [RedmineID:#128058]
		- 20200414@Tiara: Add new Setting Type 17 for mulitple stakelevel for member [Redmine: #131171]

	Parameter's explanation:
		-@isSearchAndCopy & @copyFromCustID : support to copy suspendinfo for roleid = 1
	*/

BEGIN
	SELECT @ErrCode = 0
	DECLARE @_Site VARCHAR(10), @_SiteID INT, @_Currency TINYINT

	if (dbo.f_CheckRepTable('CustProductStatus') = 1
		AND dbo.f_CheckRepTable('ProductSettingDetail') = 1 
		AND dbo.f_CheckRepTable('ProductStatusProfile') = 1
		AND dbo.f_CheckRepTable('ProductStatusSiteCurrency') = 1
	)
	BEGIN
		DECLARE @xmlStrDisabled XML
		DECLARE @xmlStrHidden XML
		DECLARE @xmlStrSync XML

		/*********************** Product Status: SettingType = 4 & New Product Status: SettingType = 13**************************/
		--Get sporttype/Bettype for this setting type	
		SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
		INTO #SportBettypeFilter4
		FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
			INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.[SportType] = psd.[SportType]	AND pbs.[BetType] = psd.[BetType]
			INNER JOIN (SELECT Sporttype, bettype FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,4)
						UNION ALL SELECT Sporttype, bettype FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,13))t ON pbs.[SportType] = t.[SportType]	AND pbs.[BetType] = t.[BetType]
		WHERE psd.SettingType = 4 OR psd.SettingType = 13
			
		----Hard code to hide CF if Upline is a dummy Super or Master
		DECLARE @DirectUplineID INT, @IsDirect BIT = 0
		
		IF (@RoleID = 3) 
			SET @DirectUplineID = @SuperID
		ELSE IF (@RoleID = 2)
			SET @DirectUplineID = @MasterID	
		ELSE IF @RoleID = 1
			SET @DirectUplineID = @AgentID
			
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
			SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID
			SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

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
									SELECT ft.bitmapOrder	AS '@b'
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
									SELECT ft.bitmapOrder	AS '@b'
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
								SELECT ft.bitmapOrder	AS '@b'
									, ft.IsSync	AS '@s'
								FROM #SportBettypeFilter4 ft 	
								FOR XML PATH('r')
									, TYPE
								)
						FOR XML PATH('root')
							, TYPE
						)
				END
						
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo)
				SELECT	@CustID
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrHidden)))
						, (select bitmap from dbo.f_GenerateProductStatus_multiple (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, CONVERT(VARCHAR(MAX),@xmlStrSync)))
						, 0
						
			END	ELSE IF @RoleID IN (3,2,1)
			BEGIN
				--Get from Super
				--Sync: upline status
				--Enable/Disable: upline status
				DECLARE @UplineID INT,
						@CopySuspendInfo TINYINT
						
				IF @RoleID = 3
					SET @UplineID = @SuperID
				ELSE IF @RoleID = 2
					SET @UplineID = @MasterID
				ELSE IF @RoleID = 1
					SET @UplineID = @AgentID		
			
				INSERT INTO [dbo].[CustProductStatus]([CustID],bitmapIsDisabled,bitmapIsHidden,bitmapHasSynced,SuspendInfo)
				SELECT @CustID, cs.bitmapIsDisabled,cs.bitmapIsHidden,cs.bitmapHasSynced, cs.SuspendInfo
				FROM [dbo].[CustProductStatus] cs WITH (NOLOCK)
				WHERE cs.CustID = @UplineID
				
				IF @isSearchAndCopy = 1
				BEGIN
					SELECT @CopySuspendInfo = SuspendInfo
					FROM CustProductStatus WITH(NOLOCK)
					WHERE custid = @copyFromCustID
					
					UPDATE CustProductStatus WITH(UPDLOCK,ROWLOCK)
					SET suspendInfo = @CopySuspendInfo
					WHERE custid = @custid
				END
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 4

			DELETE FROM CustProductStatus WHERE CustID = @CustID
			RETURN
		END CATCH

		/********************************************* Game Status: SettingType = 11 ************************************/
		--Get sporttype/Bettype for this setting type	
		SELECT DISTINCT psd.SportType,psd.Bettype,psd.IsLive, psd.SettingType,psd.IsDisabled,psd.IsHidden,psd.IsSync,pbs.bitmapOrder 
		INTO #SportBettypeFilter11
		FROM dbo.ProductSettingDetail psd WITH(NOLOCK)  
			INNER JOIN ProductStatusProfile pbs WITH (NOLOCK) ON pbs.SportType = psd.SportType	AND pbs.BetType = psd.BetType
			INNER JOIN dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,11) t ON pbs.SportType = t.SportType	AND pbs.BetType = t.BetType AND psd.SettingType = t.SettingType
		
		IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter11)
		BEGIN
			IF @RoleID = 1
				SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @AgentID 			
			ELSE
				SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID 			

			SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site
			
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
								SELECT ft.bitmapOrder	AS '@b'
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
								SELECT ft.bitmapOrder	AS '@b'
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
							SELECT ft.bitmapOrder	AS '@b'
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

	if(dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustSettingMode3rd') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 1
		AND dbo.f_CheckRepTable('CustDiscount3rd_Member') = 1
		AND dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 1
		AND dbo.f_CheckRepTable('CustWinLossLimit_Member') = 1
		AND dbo.f_CheckRepTable('ProductSettingDetail') = 1 
		AND	dbo.f_CheckRepTable('CustStakeLevel_Agent') = 1
		AND	dbo.f_CheckRepTable('CustStakeLevel_Member') = 1
	   )
	 BEGIN
		CREATE TABLE #ProductSettingDetail(
			[SettingType] [smallint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsLive] [bit] NOT NULL
		)
		CREATE TABLE #OfferedProductList(
			[ProductID] [tinyint] NOT NULL,
			[SportType] [smallint] NOT NULL,
			[BetType] [smallint] NOT NULL,
			[IsHidden] [BIT] NOT NULL
		)

		IF @RoleID = 4
		BEGIN
			SELECT @_Site = Site, @_Currency = currency FROM dbo.Customer WITH(NOLOCK) WHERE CustID = @CustID
			SELECT @_SiteID = siteid FROM dbo.Site WITH(NOLOCK) WHERE site = @_Site

			INSERT INTO #OfferedProductList (ProductID, SportType, BetType, IsHidden)
			SELECT RealProductId, SportType, BetType, IsHidden
			FROM dbo.ProductSettingDetail WITH (NOLOCK)
			WHERE SettingType IN (4,11,13)
		
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

			INSERT #ProductSettingDetail(SettingType,SportType,BetType,IsLive)
			SELECT SettingType
				  ,ps.SportType
				  ,ps.BetType
				  ,IsLive
			FROM [dbo].[ProductSettingDetail] ps WITH(NOLOCK)
				INNER JOIN (SELECT DISTINCT ProductID, IsHidden FROM #OfferedProductList WITH (NOLOCK)) op ON ps.RealProductId = op.ProductID
			WHERE op.IsHidden = 0 AND ps.SettingType NOT IN (4,11,13)
		END

		/********************************************* Position Taking: SettingType = 1 ***********************************/
		SELECT t.* INTO #SportBettypeFilter1
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,1) t
		
		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				--s4: 0
				--m4: 0
				--a4: 0
				--n4: 0
				--l4: Default Max PT
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
					,dtl.MaxPT
				FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter1 ft ON dtl.SportType = ft.SportType AND dtl.BetType = ft.BetType AND dtl.IsLive = ft.IsLive AND dtl.SettingType = ft.SettingType
					INNER JOIN #ProductSettingDetail fil ON ft.SettingType = fil.SettingType AND ft.SportType = fil.SportType AND ft.BetType = fil.BetType AND ft.IsLive = fil.IsLive
			END
			ELSE IF @RoleID = 3
			BEGIN
				--s3: 0
				--m3: 0
				--is3: 0
				--us3: 0
				--n3: 0
				--l3: Default Max PT
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
					,dtl.SportType
					,dtl.BetType
					,dtl.IsLive
					,spt.SuperPT,0,0,0,0,0,0,0
					,dtl.MaxPT
				FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter1 ft ON dtl.SportType = ft.SportType AND dtl.BetType = ft.BetType AND dtl.IsLive = ft.IsLive AND dtl.SettingType = ft.SettingType
					INNER JOIN CustPTSetting3rd_Agent spt ON dtl.SportType = spt.SportType AND dtl.BetType = spt.BetType AND dtl.IsLive = spt.IsLive
				WHERE dtl.SettingType = 1 AND spt.CustID = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				--m2: 0
				--a2: 0
				--im2: 0
				--um2: 0
				--n2: 0
				--l2: Default Max PT
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
				@custid,dtl.SportType,dtl.BetType,dtl.IsLive,
					0,mpt.MasterPT,0,0,0,0,0,0
					,dtl.MaxPT
				FROM dbo.ProductSettingDetail dtl WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter1 ft ON dtl.SportType = ft.SportType AND dtl.BetType = ft.BetType AND dtl.IsLive = ft.IsLive AND dtl.SettingType = ft.SettingType
					INNER JOIN CustPTSetting3rd_Agent mpt ON dtl.SportType = mpt.SportType AND dtl.BetType = mpt.BetType AND dtl.IsLive = mpt.IsLive
				WHERE dtl.SettingType = 1 AND mpt.custid = @MasterID
			END
			ELSE
			BEGIN --RoleID = 1
				DECLARE @n2 SMALLMONEY, @l2 SMALLMONEY
				DECLARE @im2 bit, @um2 SMALLMONEY
				DECLARE @a1 SMALLMONEY, @m1 SMALLMONEY, @s1 SMALLMONEY, @i1 bit, @u1 SMALLMONEY, @im1 bit, @um1 SMALLMONEY
				DECLARE @temp1 SMALLMONEY, @temp2 SMALLMONEY, @temp3 SMALLMONEY
				DECLARE @s_new SMALLMONEY, @m_new SMALLMONEY, @a_new SMALLMONEY
		
				DECLARE @MemberPTTbl TABLE (
						CustID		INT
					, [SportType]	SMALLINT
					, [BetType]		SMALLINT
					, [Islive]		BIT	
					, [SuperPT]		TINYINT	
					, [MasterPT]	TINYINT
					, [AgentPT]		TINYINT
					, [IsAutoMPT]	BIT
					, [AutoMPT]		TINYINT
					, [IsAutoSPT]	BIT
					, [AutoSPT]		TINYINT
				)
			
				--Get default PT settings	
				--s1: s3
				--m1: m2
				--a1: a2
				--is1: 0
				--us1: 0
				--im1: 0
				--um1: 0
				INSERT INTO @MemberPTTbl (
					CustID
					, SportType
					, BetType
					, Islive
					, SuperPT
					, MasterPT
					, AgentPT
					, IsAutoMPT
					, AutoMPT
					, IsAutoSPT
					, AutoSPT
					)
				SELECT @CustID
					, acs.SportType
					, acs.BetType
					, acs.IsLive
					, mcs.superPT
					, acs.masterPT
					, acs.agentPT
					, 0
					, 0
					, 0
					, 0
				FROM dbo.CustPTSetting3rd_Agent acs WITH (NOLOCK)
					INNER JOIN dbo.CustPTSetting3rd_Agent mcs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND acs.islive = mcs.islive AND mcs.custid = @MasterID
					INNER JOIN #SportBettypeFilter1 ft ON mcs.SportType = ft.SportType AND mcs.BetType = ft.BetType AND mcs.IsLive = ft.IsLive
				WHERE acs.custid = @AgentID
			
				--Correct PT
				UPDATE cs
				SET @a1 = cs.AgentPT
					,@m1 = cs.MasterPT
					,@s1 = cs.SuperPT
					,@n2 = acs.MinPT
					,@l2 = acs.MaxPT
					,@im2 = acs.IsAutoMasterPT
					,@um2 = acs.AutoMasterPT
					,@i1 = cs.IsAutoSPT
					,@u1 = cs.AutoSPT
					,@im1 = cs.IsAutoMPT
					,@um1 = cs.AutoMPT
				
					-- rule #1: s1 = min(s1,s4-m3) if i=0
					,@s1 = CASE WHEN @i1 = 0 AND m.IsAutoSuperPT = 0 AND s.SuperPT-m.MasterPT < @s1 THEN s.SuperPT-m.MasterPT ELSE @s1 END

					-- rule #2: a1 = max(a1,n2); m1 = (a1<n2) ? m3-n2 : m1 --agent min
					,@a_new = CASE WHEN @a1 < @n2 THEN @n2 ELSE @a1 END
					,@m_new = CASE WHEN @a1 < @n2 AND @m1+@n2 > m.MasterPT THEN m.MasterPT-@n2 ELSE @m1 END
					,@a1 = @a_new
					,@m1 = @m_new								

					-- rule #3: a1 = min(a1,l2) -- agent max         
					,@a1 = CASE WHEN @a1 > @l2 THEN @l2 ELSE @a1 END

					-- rule #4: m1 = min(m3-a1,u2) if master auto -- Recalculate AUTO MPT 
					,@temp1 = CASE WHEN @im1 = 1 THEN @um1 ELSE @um2 END			
					,@m1 = CASE 
								WHEN @im2 = 1 OR @im1 = 1 
								THEN CASE WHEN m.MasterPT-@a1 > @temp1 THEN @temp1 ELSE m.MasterPT-@a1 END 
								ELSE @m1 
							END		

					-- rule #5: m1 = max(m1,n3-a1) -- master min   
					,@m1 = CASE WHEN @m1 < m.MinPT-@a1 THEN m.MinPT-@a1 ELSE @m1 END
				         
					-- rule #6: check master max 
					/*	@x1 = min(m3,l3) -- mpt max
						@x2 = max(@x1-a1,0) --mpt
						m1 = (a1+m1>l3) ? @x2 : m1
						@x3 = (a1+@x2 > @x1) ? @x1-@x2 : a1
						a1 = (a1+m1>l1) ? max(@x3, n2) : a1
					*/ 
					,@temp1 = CASE WHEN m.MasterPT > m.MaxPT THEN m.MaxPT ELSE m.MasterPT END
					,@temp2 = CASE WHEN @temp1-@a1 < 0 THEN 0 ELSE @temp1-@a1 END
					,@m_new = CASE WHEN @a1+@m1 > m.MaxPT THEN @temp2 ELSE @m1 END
					,@temp3 = CASE WHEN @a1+@temp2 > @temp1 THEN @temp1-@temp2 ELSE @a1 END
					,@a_new = CASE 
								WHEN @a1+@m1 > m.MaxPT 
								THEN CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
								ELSE @a1 
							END	
					
					,@m1 = @m_new
					,@a1 = @a_new
					-- rule #7: s1 = min(s4-m1-a1, i1?u1:u3) --Recalculate auto pt
					/*
						@x1 = (i1=1) ? u1 : u3
						s1 = (s4-m1-a1 > @x1) ? @x1 : s4-m1-a1 
					*/
					,@temp1 = CASE WHEN @i1 = 1 THEN @u1 ELSE m.AutoSuperPT END			
					,@s1 = CASE 
								WHEN @i1 = 1 OR m.IsAutoSuperPT = 1 
								THEN CASE WHEN s.SuperPT-@m1-@a1 > @temp1 THEN @temp1 ELSE s.SuperPT-@m1-@a1 END
								ELSE @s1
							END		

					-- rule #8: s1 = max(n4-m1-a1,s1) --super min
					,@s1 = CASE WHEN @a1+@m1+@s1 < s.MinPT THEN s.MinPT-@m1-@a1 ELSE @s1 END	

					-- rule #9: UPDATE s1,m1,a1 in case s1+m1+a1>s4
					/* -- explanation
						@x1 = (s4-m1-a1 < 0) ? 0 : s4-m1-a1
						s1 = (s1+a1+m1 > s4) ? @x1 : s1
						@x1 = (@x1+m1+a1 > s4) ? s4-@x1 : m1+a1
						@x2 = (m3 > l3) ? l3 : m3
						@x2 = (@x1 > @x2) ? @x2 : @x1
						@x2 = (@x2 < n3) ? n3 : @x2
						@x3 = (@x2-a1 < 0) ? 0 : @x2-a1
						m1 = (s1+a1+m1 > s4) ? @x3 : m1
						@x3 = (a1+@x3>@x2) ? @x2-@x3 : a1
						@x3 =  (@x3 < n2) ? n2 : @x3
						a1 = (s1+a1+m1 > s4) ? @x3 : a1				
					*/             
					,@temp1 = CASE WHEN s.SuperPT-@m1-@a1 < 0 THEN 0 ELSE s.SuperPT-@m1-@a1 END
					,@s_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp1 ELSE @s1 END
					,@temp1 = CASE WHEN @temp1+@m1+@a1 > s.SuperPT THEN s.SuperPT-@temp1 ELSE @m1+@a1 END
					,@temp2 = CASE WHEN m.MasterPT > m.MaxPT THEN m.MaxPT ELSE m.MasterPT END
					,@temp2 = CASE WHEN @temp1 > @temp2 THEN @temp2 ELSE @temp1 END
					,@temp2 = CASE WHEN @temp2 < m.MinPT THEN m.MinPT ELSE @temp2 END
					,@temp3 = CASE WHEN @temp2-@a1 < 0 THEN 0 ELSE @temp2-@a1 END
					,@m_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp3 ELSE @m1 END
					,@temp3 = CASE WHEN @a1+@temp3 > @temp2 THEN @temp2-@temp3 ELSE @a1 END
					,@temp3 = CASE WHEN @temp3 < @n2 THEN @n2 ELSE @temp3 END
					,@a_new = CASE WHEN @s1+@a1+@m1 > s.SuperPT THEN @temp3 ELSE @a1 END
					,@s1 = @s_new
					,@m1 = @m_new
					,@a1 = @a_new
				
					--PT values must be in [0,100]
					,@s1 = CASE WHEN @s1 < 0 THEN 0 ELSE @s1 END
					,@s1 = CASE WHEN @s1 > 100 THEN 100 ELSE @s1 END
					,@m1 = CASE WHEN @m1 < 0 THEN 0 ELSE @m1 END
					,@m1 = CASE WHEN @m1 > 100 THEN 100 ELSE @m1 END
					,@a1 = CASE WHEN @a1 < 0 THEN 0 ELSE @a1 END
					,@a1 = CASE WHEN @a1 > 100 THEN 100 ELSE @a1 END
			
					--------------------------------	
					-- done apply all rule, then update to destination table
					,cs.AgentPT = @a1
					,cs.MasterPT = @m1
					,cs.SuperPT = @s1								       
				FROM @MemberPTTbl cs 
					INNER JOIN dbo.CustPTSetting3rd_Agent acs WITH(NOLOCK) 
						ON @AgentID = acs.custid 
							AND cs.sporttype = acs.sporttype 
							AND cs.bettype = acs.bettype 
							AND cs.IsLive = acs.IsLive
					INNER JOIN dbo.CustPTSetting3rd_Agent m WITH(NOLOCK) 
						ON @MasterID = m.custid 
							AND cs.sporttype = m.sporttype 
							AND cs.bettype = m.bettype 
							AND cs.IsLive = m.IsLive
					INNER JOIN dbo.CustPTSetting3rd_Agent s WITH(NOLOCK)  
						ON @SuperID = s.custid 
							AND cs.sporttype = s.sporttype 
							AND cs.bettype = s.bettype 
							AND cs.IsLive = s.IsLive
						
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
					@AgentID,SportType,BetType,Islive,
					SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsAutoSPT,AutoSPT
				FROM @MemberPTTbl
				WHERE NOT EXISTS(SELECT TOP 1 1 FROM dbo.CustPTGroupSetting3rd_Member WHERE AgentID = @AgentID)
				AND @SuperID IN (
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
								FROM dbo.CustPTGroupSetting3rd_Member grp
								JOIN @memberPTTbl tmp ON tmp.SportType = grp.SportType
														AND tmp.BetType = grp.BetType
														AND tmp.Islive = grp.Islive
								WHERE grp.AgentID = @AgentID
								AND (
									tmp.SuperPT <> grp.SuperPT
									OR
									tmp.MasterPT <> grp.MasterPT
									OR
									tmp.AgentPT <> grp.AgentPT
									OR
									tmp.IsAutoMPT <> grp.IsAutoMasterPT
									OR
									tmp.AutoMPT <> grp.AutoMasterPT
									OR
									tmp.IsAutoSPT <> grp.IsAutoSuperPT
									OR
									tmp.AutoSPT <> grp.AutoSuperPT
								))
						OR @SuperID NOT IN (
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
							SuperPT,MasterPT,AgentPT,IsAutoMPT,AutoMPT,IsAutoSPT,AutoSPT
						FROM @memberPTTbl
					
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
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		/********************************************* Bet Limit : SettingType = 2 ****************************************/
	
		SELECT t.* INTO #SportBettypeFilter2
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,2) t			
	
		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter2)
				BEGIN
					--Min: 0
					--Max: 0
					--Max Per Match: 0
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
					FROM #SportBettypeFilter2 t
						INNER JOIN #ProductSettingDetail fil ON t.SettingType = fil.SettingType AND t.SportType = fil.SportType AND t.BetType = fil.BetType AND t.IsLive = fil.IsLive
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				--Min: super.minbet
				--Max: super.maxbet
				--Max Per Match: super.maxpermatch
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
				FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter2 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE custid = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				--Min: max(master.minbet; super.minbet)
				--Max: min(master.maxbet; super.maxbet)
				--Max Per Match: min(master.maxpermatch; super.maxpermatch)
				DECLARE @BetlimitAgent TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY
					)
				INSERT INTO @BetlimitAgent
				SELECT smcs.SportType,smcs.BetType,
						 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
						 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
						 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent smcs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter2 s ON s.SportType = smcs.SportType AND s.Bettype = smcs.BetType
				WHERE smcs.custid = @SuperID 
						OR smcs.custid = @MasterID
				GROUP BY smcs.SportType,smcs.BetType
			
				INSERT INTO [dbo].[CustBetSetting3rd_Agent]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,SportType
					,BetType
					,ISNULL(MinBet,0)
					,ISNULL(MaxBet,0)
					,ISNULL(MaxPerMatch,0)
				FROM @BetlimitAgent
			END
			ELSE
			BEGIN
				--Min: max(agent.minbet; master.minbet; super.minbet)
				--Max: min(agent.maxbet; master.maxbet; super.maxbet)
				--Max Per Match: min(agent.maxpermatch; master.maxpermatch; super.maxpermatch)
			
				DECLARE @BetlimitMember TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY
					)
				INSERT INTO @BetlimitMember
				SELECT smcs.SportType,smcs.BetType,
						 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
						 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
						 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent smcs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter2 s ON s.SportType = smcs.SportType AND s.Bettype = smcs.BetType
				WHERE custid = @SuperID 
						OR custid = @MasterID
						OR custid = @AgentID
				GROUP BY smcs.SportType,smcs.BetType
			
				INSERT INTO [dbo].[CustBetSetting3rd_Member]
				   ([CustID]
				   ,[SportType]
				   ,[BetType]
				   ,[MinBet]
				   ,[MaxBet]
				   ,[MaxPerMatch])
				SELECT
					@CustID
					,SportType
					,BetType
					,ISNULL(MinBet,0)
					,ISNULL(MaxBet,0)
					,ISNULL(MaxPerMatch,0)
				FROM @BetlimitMember
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 2
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID		
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH
	
		/********************************************* Commision : SettingType = 3, Ticket Commision : SettingType = 14 ****************************************/
		SELECT * INTO #SportBettypeFilter3
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,3)
		INSERT INTO #SportBettypeFilter3
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,14)

		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter3)
				BEGIN
					INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount])
					SELECT 
						@CustID
						,ft.SportType
						,ft.BetType
						,0 -- 0 zero by default
					FROM #SportBettypeFilter3 ft 
						INNER JOIN #ProductSettingDetail fil ON ft.SettingType = fil.SettingType AND ft.SportType = fil.SportType AND ft.BetType = fil.BetType 
				END
			END
			ELSE IF @RoleID = 3
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
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK) 
					INNER JOIN #SportBettypeFilter3 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
				WHERE CustID = @SuperID
			END
			ELSE IF @RoleID = 2
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
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK) 
					INNER JOIN #SportBettypeFilter3 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType
				WHERE CustID = @MasterID
			END
			ELSE
			BEGIN
				--super.discount: super.discount
				--master.discount: master.discount
				--agent.discount: agent.discount
				--playerdiscount: 0
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
					,acs.SportType
					,acs.BetType
					,0
					,acs.Discount
					,mcs.Discount
					,scs.Discount
				FROM dbo.CustDiscount3rd_Agent acs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter3 f ON acs.SportType = f.SportType AND acs.BetType = f.BetType
					INNER JOIN dbo.CustDiscount3rd_Agent mcs WITH (NOLOCK) ON acs.sporttype = mcs.sporttype AND acs.bettype = mcs.bettype AND mcs.custid = @MasterID
					INNER JOIN dbo.CustDiscount3rd_Agent scs WITH (NOLOCK) ON acs.sporttype = scs.sporttype AND acs.bettype = scs.bettype AND scs.custid = @SuperID
				WHERE acs.custid=@AgentID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 3
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		/*********************************************Charge Commision : SettingType = 5 ****************************************/
		SELECT * INTO #SportBettypeFilter5
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,5)
	
		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				IF EXISTS(
					SELECT TOP 1 1
					FROM #SportBettypeFilter5
				)
				BEGIN
					INSERT INTO [dbo].[CustDiscount3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[Discount])
					SELECT 
						@CustID
						,ft.SportType
						,ft.BetType
						,0 -- 0 zero by default
					FROM #SportBettypeFilter5 ft 
						INNER JOIN #ProductSettingDetail fil ON ft.SettingType = fil.SettingType AND ft.SportType = fil.SportType AND ft.BetType = fil.BetType 
				END
			END
			ELSE IF @RoleID = 3
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
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter5 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType 
				WHERE CustID = @SuperID
			END
			ELSE IF @RoleID = 2
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
					,0 -- 0 zero by default
				FROM CustDiscount3rd_Agent dc WITH(NOLOCK) 
					INNER JOIN #SportBettypeFilter5 f ON dc.SportType = f.SportType AND dc.BetType = f.BetType 
				WHERE CustID = @MasterID
			END
			ELSE
			BEGIN
				--super.discount: super.discount
				--master.discount: master.discount
				--agent.discount: agent.discount
				--playerdiscount: Maximum Charge Comm
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
					,acs.SportType
					,acs.BetType
					,ps.MaxDiscount
					,acs.Discount
					,mcs.Discount
					,scs.Discount
				FROM dbo.CustDiscount3rd_Agent acs WITH (NOLOCK)
					INNER JOIN dbo.CustDiscount3rd_Agent mcs WITH (NOLOCK)
								ON acs.sporttype = mcs.sporttype
								AND acs.bettype = mcs.bettype
								AND mcs.custid = @MasterID
					INNER JOIN dbo.CustDiscount3rd_Agent scs WITH (NOLOCK)
								ON acs.sporttype = scs.sporttype
								AND acs.bettype = scs.bettype
								AND scs.custid = @SuperID
					INNER JOIN #SportBettypeFilter5 f ON acs.SportType = f.SportType AND acs.BetType = f.BetType 
					INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = acs.BetType AND ps.SportType = acs.SportType AND ps.SettingType = 5
				WHERE acs.custid=@AgentID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 5
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH

		/********************************************* SMA WinLimit : SettingType = 6 ****************************************/
		/********************************************* SMA LossLimit : SettingType = 12 ****************************************/
		SELECT * INTO #SportBettypeFilter6
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,6)
		INSERT INTO #SportBettypeFilter6
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,12)
		
		BEGIN TRY
			IF @RoleID = 4
			BEGIN	
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter6)			
				BEGIN			
					--MaxWinLimit: 0 (Unlimited)
					--MaxLossLimit: get from global setting based on currency
					--IsAutoReset: 1		
					INSERT INTO [dbo].[CustWinLossLimit_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[MaxWinLimit]
					   ,[MaxLossLimit]
					   ,[IsAutoReset])
					SELECT
						@CustID
						,ft.SportType
						,ft.BetType
						,0
						,gs.DefaultLossLimit
						,1
					FROM #SportBettypeFilter6 ft 
						INNER JOIN #ProductSettingDetail fil ON ft.SettingType = fil.SettingType AND ft.SportType = fil.SportType AND ft.BetType = fil.BetType 
						INNER JOIN LossLimit_GlobalSetting gs ON gs.ProductId = ft.ProductID
						INNER JOIN CustInfo ci WITH (NOLOCK) ON gs.ExchangeId = ci.currency
					WHERE ci.custid = @CustID
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				--MaxWinLimit: super.MaxWinLimit
				--MaxLossLimit: super.MaxLossLimit
				--IsAutoReset: super.IsAutoReset
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
					,MaxWinLimit
					,MaxLossLimit
					,IsAutoReset
				FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType
				WHERE custid = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				--MaxWinLimit: master.MaxWinLimit
				--MaxLossLimit: master.MaxLossLimit
				--IsAutoReset: master.IsAutoReset
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
					,MaxWinLimit
					,MaxLossLimit
					,IsAutoReset
				FROM dbo.CustWinLossLimit_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter6 f ON f.Bettype = cs.BetType AND f.SportType = cs.SportType
				WHERE custid = @MasterID
			END
			ELSE
			BEGIN
				--MaxWinLimit: agent.MaxWinLimit
				--MaxLossLimit: agent.MaxLossLimit
				--IsAutoReset: agent.IsAutoReset
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
				WHERE custid = @AgentID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 6
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH

		
		/****************************** Stake Level Member Single Selection : SettingType = 7 ******************************/
		/****************************** Stake Level Member Multiple Selection : SettingType = 17 ******************************/
		/*************************** Group Stake Level Member Single Selection : SettingType = 8 ***************************/

		SELECT * INTO #SportBettypeFilter7
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,7)
		INSERT INTO #SportBettypeFilter7
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,17)
		UNION ALL
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,8)

		BEGIN TRY
			IF	@RoleID = 4
			BEGIN
				INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType    , BetType    , StakeLevelList)
				SELECT	@CustID, sbf.SportType, sbf.Bettype, LEFT(sl.list, LEN(sl.list) - 1)
				FROM	#SportBettypeFilter7 AS sbf
					INNER JOIN #ProductSettingDetail ps ON ps.BetType = sbf.Bettype AND ps.SportType = sbf.SportType AND ps.SettingType = sbf.SettingType
					CROSS APPLY (
						SELECT	CAST(sl.StakeLevelID AS VARCHAR) + ','
						FROM		dbo.StakeLevel	AS sl WITH(NOLOCK)
						INNER JOIN	dbo.custInfo	AS ci WITH(NOLOCK)
								ON	ci.currency = sl.ExchangeId
						WHERE	ci.custid = @CustID
							AND	sl.GameTypeID = sbf.Bettype
						FOR XML PATH ('')
					) sl(list)
			END
			ELSE IF	@RoleID = 3
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType     , BetType     , StakeLevelList     )
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @SuperID
			END
			ELSE IF	@RoleID = 2
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Agent
					(	CustID , SportType     , BetType     , StakeLevelList     )
				SELECT	@CustID, csla.SportType, csla.BetType, csla.StakeLevelList
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
				WHERE	csla.CustID = @MasterID
			END
			ELSE IF	@RoleID = 1
			BEGIN
			    INSERT INTO	dbo.CustStakeLevel_Member
					(	CustID , SportType     , BetType     , StakeLevelList                 , LastUpdated)
				SELECT	@CustID, csla.SportType, csla.BetType, ISNULL(sr.LowestStakeLevel, ''), GETDATE()
				FROM	dbo.CustStakeLevel_Agent AS csla WITH(NOLOCK)
					INNER JOIN #SportBettypeFilter7 f ON f.Bettype = csla.BetType AND f.SportType = csla.SportType
					OUTER APPLY (
						SELECT TOP(1) ISNULL(CONVERT(VARCHAR(20), sl.StakeLevelID), '') AS LowestStakeLevel
						FROM (
							SELECT	CAST(val AS INT) AS val
							FROM	dbo.strSplit(csla.StakeLevelList, ',')
						) AS ss
						INNER JOIN	dbo.StakeLevel AS sl WITH(NOLOCK)
								ON	ss.val = sl.StakeLevelID
						ORDER BY	sl.MaxStake, sl.MinStake, sl.GameGroupID
					) sr
				WHERE	csla.CustID = @AgentID
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 7
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM dbo.CustStakeLevel_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM dbo.CustStakeLevel_Agent WHERE CustID = @CustID
			END
			RETURN
		END CATCH
		
		/********************************************* Bet Game Limit : SettingType = 9 ****************************************/
	
		SELECT t.* INTO #SportBettypeFilter9
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,9) t
		INSERT INTO #SportBettypeFilter9
		SELECT * 
		FROM dbo.f_CustSetting_SportBetTypeSettingSelect(@ProductID,16)

		BEGIN TRY
			IF @RoleID = 4
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM #SportBettypeFilter9)
				BEGIN
					--Min: 0
					--Max: 0
					--Max Per Match: 0
					INSERT INTO [dbo].[CustBetSetting3rd_Agent]
					   ([CustID]
					   ,[SportType]
					   ,[BetType]
					   ,[MinBet]
					   ,[MaxBet]
					   ,[MaxPerMatch])
					SELECT
						@CustID
						,s.SportType
						,s.BetType
						,ps.DefaultMinBet
						,ps.DefaultMaxBet
						,ps.DefaultMaxPerMatch
					FROM #SportBettypeFilter9 s
						INNER JOIN #ProductSettingDetail fil ON s.SettingType = fil.SettingType AND s.SportType = fil.SportType AND s.BetType = fil.BetType AND s.IsLive = fil.IsLive
						INNER JOIN dbo.ProductBetSetting ps WITH (NOLOCK) ON s.SportType = ps.Sporttype AND s.Bettype = ps.Bettype AND ps.IsDep = 0 AND ps.Currency = @_Currency
				END
			END
			ELSE IF @RoleID = 3
			BEGIN
				--Min: super.minbet
				--Max: super.maxbet
				--Max Per Match: super.maxpermatch
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
				FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter9 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
				WHERE custid = @SuperID
			END
			ELSE IF @RoleID = 2
			BEGIN
				--Min: max(master.minbet; super.minbet)
				--Max: min(master.maxbet; super.maxbet)
				--Max Per Match: min(master.maxpermatch; super.maxpermatch)
				DECLARE @BetGamelimitAgent TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY
					)

				DECLARE @BetGameUnlimit TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						IsAllowUnlimit BIT
					)
				INSERT INTO @BetGamelimitAgent
				SELECT smcs.SportType,smcs.BetType,
						 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
						 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
						 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent smcs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter9 s ON s.SportType = smcs.SportType AND s.Bettype = smcs.BetType
				WHERE smcs.custid = @SuperID 
						OR smcs.custid = @MasterID
				GROUP BY smcs.SportType,smcs.BetType
			
				INSERT INTO @BetGameUnlimit				
				SELECT cs.SportType,cs.BetType,
						CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
									OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
				FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter9 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
					INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = cs.SportType AND ps.Bettype = cs.BetType
				WHERE cs.custid = @SuperID AND ps.Currency = @_Currency

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
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MinBet,0) < ps.MinBet THEN ps.MinBet ELSE ISNULL(cs.MinBet,0) END AS MinBet
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MaxBet,0) > ps.MaxBet THEN ps.MaxBet ELSE ISNULL(cs.MaxBet,0) END AS MaxBet
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MaxPerMatch,0) > ps.MaxPerMatch THEN ps.MaxPerMatch ELSE ISNULL(cs.MaxPerMatch,0) END AS MaxPerMatch
				FROM @BetGamelimitAgent cs
					INNER JOIN @BetGameUnlimit bu ON cs.SportType = bu.SportType AND bu.BetType = cs.BetType
					INNER JOIN dbo.ProductBetSetting ps ON cs.SportType = ps.SportType AND bu.BetType = ps.BetType AND ps.Currency = @_Currency
			END
			ELSE
			BEGIN
				--Min: max(agent.minbet; master.minbet; super.minbet)
				--Max: min(agent.maxbet; master.maxbet; super.maxbet)
				--Max Per Match: min(agent.maxpermatch; master.maxpermatch; super.maxpermatch)
			
				DECLARE @BetGamelimitMember TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						MinBet MONEY,
						MaxBet MONEY,
						MaxPerMatch MONEY
					)
				DECLARE @BetGameUnlimitSuper TABLE(
						SportType SMALLINT,
						BetType SMALLINT,
						IsAllowUnlimit BIT
					)

				INSERT INTO @BetGamelimitMember
				SELECT smcs.SportType,smcs.BetType,
						 Max(case when MinBet = 0 then NULL else MinBet end) MinBet,
						 Min(case when MaxBet = 0 then NULL else MaxBet end) MaxBet,
						 Min(case when MaxPerMatch = 0 then NULL else MaxPerMatch end) MaxPerMatch
				FROM dbo.CustBetSetting3rd_Agent  smcs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter9 s ON s.SportType = smcs.SportType AND s.Bettype = smcs.BetType
				WHERE custid = @SuperID 
						OR custid = @MasterID
						OR custid = @AgentID
				GROUP BY smcs.SportType,smcs.BetType
			
				INSERT INTO @BetGameUnlimitSuper							
				SELECT cs.SportType,cs.BetType,
						CASE WHEN (cs.MinBet = 0 AND cs.MaxBet = 0 AND cs.MaxPerMatch = 0) 
									OR (ps.MinBet = 0 AND ps.MaxBet = 0 AND ps.MaxPerMatch = 0) THEN 1 ELSE 0 END AS IsAllowUnlimit
				FROM dbo.CustBetSetting3rd_Agent cs WITH (NOLOCK)
					INNER JOIN #SportBettypeFilter9 s ON s.SportType = cs.SportType AND s.Bettype = cs.BetType
					INNER JOIN dbo.ProductBetSetting ps ON ps.Sporttype = cs.SportType AND ps.Bettype = cs.BetType
				WHERE cs.custid = @SuperID AND ps.Currency = @_Currency

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
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MinBet,0) < ps.MinBet THEN ps.MinBet ELSE ISNULL(cs.MinBet,0) END AS MinBet
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MaxBet,0) > ps.MaxBet THEN ps.MaxBet ELSE ISNULL(cs.MaxBet,0) END AS MaxBet
					,CASE WHEN bu.IsAllowUnlimit = 0 AND ISNULL(cs.MaxPerMatch,0) > ps.MaxPerMatch THEN ps.MaxPerMatch ELSE ISNULL(cs.MaxPerMatch,0) END AS MaxPerMatch
				FROM @BetGamelimitMember cs
					INNER JOIN @BetGameUnlimitSuper bu ON cs.SportType = bu.SportType AND bu.BetType = cs.BetType
					INNER JOIN dbo.ProductBetSetting ps ON cs.SportType = ps.SportType AND bu.BetType = ps.BetType AND ps.Currency = @_Currency
			END
		END TRY
		BEGIN CATCH
			SELECT @ErrCode = 9
			DELETE FROM CustProductStatus WHERE CustID = @CustID
			IF @RoleID = 1
			BEGIN
				DELETE FROM CustPTSetting3rd_Member WHERE CustID = @CustID
				DELETE FROM CustSettingMode3rd WHERE CustID = @CustID
				DELETE FROM CustBetSetting3rd_Member WHERE CustID = @CustID	
				DELETE FROM CustDiscount3rd_Member WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Member WHERE CustID = @CustID
				DELETE FROM dbo.CustStakeLevel_Member WHERE CustID = @CustID
			END
			ELSE --SMA
			BEGIN
				DELETE FROM CustPTSetting3rd_Agent WHERE CustID = @CustID	
				DELETE FROM CustBetSetting3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustDiscount3rd_Agent WHERE CustID = @CustID
				DELETE FROM CustWinLossLimit_Agent WHERE CustID = @CustID
				DELETE FROM dbo.CustStakeLevel_Agent WHERE CustID = @CustID
			END

			RETURN
		END CATCH

		DROP TABLE #SportBettypeFilter1
		DROP TABLE #SportBettypeFilter2
		DROP TABLE #SportBettypeFilter3
		DROP TABLE #SportBettypeFilter5
		DROP TABLE #SportBettypeFilter6
		DROP TABLE #SportBettypeFilter7
		DROP TABLE #SportBettypeFilter9
	END
	
END
GO


