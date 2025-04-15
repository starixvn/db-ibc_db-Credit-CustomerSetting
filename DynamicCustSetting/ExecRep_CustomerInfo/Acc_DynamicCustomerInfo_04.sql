/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_04]
	@custid int,
	@roleid tinyint,
	@IsDisabled_XML VARCHAR(MAX) = NULL,
	@Suspended BIT = NULL,
	@Closed BIT = NULL,	
	@ClosedReason TINYINT = NULL,
	@Action	VARCHAR(30)	= 'ProductStatus', 
	@SettingStatus TINYINT = 0
AS
/*
	Created: 20151007@Dominic
	Task : Update customer/custinfo settings
	DB: DBCust/CustDB

	Revision: 
		- 20160801@Elodie: Implement Game status (setting type = 11) - [Redmine: #60809]   
		- 20170103@Elodie: Unhide all bettype although 1 bettype is enabled - [Redmine: #69679]   
		- 20170307@Elodie: Implement New Product status (setting type = 13) - [Redmine: #70722]    
		- 20170919@Johnson: fix the unsynchronized setting (settingType = 13), do not update status for un-sync downlines [Redmine: #72973]							
		- 20180118@Elodie: Update enable status on NAP & ExtNAP [RedmineID:#87328]
		- 20190404@Johnson: add suspendinfo [redmine: #105587]
		- 20200406@Elodie: Update unhide by RealProductID [RedmineID:#129440]
		- 20200702@Winfred: Update enable status of Cust when SettingType = 4[RedmineID:#136210]  
		- 20210505@Tina: Lock account & indirect close account [redmine: #148600]
		- 20210722@Tina: fix the issue that closeinfo cannot replicate on time [redmine: #158917]
		- 20220627@Eden:  Implement the dependency between Macau Games Product Status and Jackpot Status [Redmine: #171715]
		- 20221121@Eden: Unify RNG Lottery Customer Settings [RedmineID: #180640]
		- 20241125@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]	
		- 20241230@Aries: Scale Out DBCUST - Apply Inhouse replication for the remaning tables [Redmine: #215627]
		- 20250224@Johnson: remove f_CheckRepTable for customer/custinfo [RedmineID: #212684]
		- 20241230@Aries: Scale Out DBCUST - Apply Inhouse replication for CustLoginInfo_Member [Redmine: #215627]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
*/
BEGIN
	SET NOCOUNT ON 
	
	--Check if XML is null or empty
	IF @Action NOT IN ('SuspendInfo', 'CloseInfo') AND ( @IsDisabled_XML IS NULL OR @IsDisabled_XML='') RETURN

	CREATE TABLE #ProductSettingDetail_tmp04(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[RealProductID] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)
	
	IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
		AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
	BEGIN		
		INSERT INTO #ProductSettingDetail_tmp04(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,RealProductID)
		SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel,RealProductID 
		FROM dbo.f_CustSetting_ProductSettingDetailSel(@SettingStatus)
			
		DECLARE @iDoc INT, 
				@xmlStrDisabledMasters XML, 
				@xmlStrDisabledAgents XML, 
				@xmlStrDisabledMembers XML, 
				@xmlStrDisabledSuperDirectMembers XML, 
				@xmlStrDisabledMasterDirectMembers XML, 
				@xmlStrHidden XML, 
				@xmlStrDisabled XML, 
				@ProductID INT,
				@BitmapOrder TINYINT
		
		IF @Action = 'SuspendInfo'		
		BEGIN
			CREATE TABLE #tblCust (CustID INT, OldSuspendInfo TINYINT, NewSuspendInfo TINYINT)
						
			IF @roleid = 4
			BEGIN			
				UPDATE	cs 
				SET	SuspendInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(4,@Suspended,ISNULL(SuspendInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				OUTPUT DELETED.custid, DELETED.SuspendInfo, INSERTED.SuspendInfo
				INTO #tblCust
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	SRecommend = @CustID;
				
			END	
			ELSE IF @roleid = 3
			BEGIN			
				UPDATE	cs 
				SET	SuspendInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(3,@Suspended,ISNULL(SuspendInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				OUTPUT DELETED.custid, DELETED.SuspendInfo, INSERTED.SuspendInfo
				INTO #tblCust
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	mRecommend = @CustID;
									
			END	
			ELSE IF @roleid = 2
			BEGIN			
				UPDATE	cs 
				SET	SuspendInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(2,@Suspended,ISNULL(SuspendInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				OUTPUT DELETED.custid, DELETED.SuspendInfo, INSERTED.SuspendInfo
				INTO #tblCust
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	Recommend = @CustID;			
			END	
			
			IF @suspended = 1
			BEGIN
				DELETE #tblCust 
				WHERE (OldSuspendInfo > 0 AND NewSuspendInfo > 0) OR (OldSuspendInfo = NewSuspendInfo) 
			END	
			ELSE
			BEGIN
				DELETE #tblCust WHERE OldSuspendInfo > 0 AND NewSuspendInfo > 0
			END
			
			SELECT custid FROM #tblCust
			
			DROP TABLE #tblCust
		END	
		ELSE IF @Action = 'ProductStatus' --Setting type = 4
		BEGIN
			CREATE TABLE #DisableStatTbl(
					SportType SMALLINT,
					BetType SMALLINT,
					IsDisabled BIT,
					IsDisabledDownline BIT
				)

			--Parse XML				
			EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
			
			INSERT INTO #DisableStatTbl
			SELECT *
			FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
			WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT
				)	
			
			EXEC sp_xml_removedocument @iDoc
		
			SET @xmlStrDisabled = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.IsDisabled	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #DisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.IsDisabled = 1 OR (tmp.IsDisabled = 0 AND tmp.IsDisabledDownline = 0)
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
					
			IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabledDownline = 0 AND IsDisabled = 0)
			BEGIN
				SELECT TOP 1 @ProductID = ps.ProductID
				FROM #DisableStatTbl dis 
					INNER JOIN #ProductSettingDetail_tmp04 ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
				WHERE dis.IsDisabled = 0 AND IsDisabledDownline = 0 AND ps.SettingType IN (4)

				SET @xmlStrHidden = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, 0	AS '@s'
							FROM dbo.ProductStatusProfile psp (NOLOCK)
								INNER JOIN #ProductSettingDetail_tmp04 ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
							WHERE ps.ProductID = @ProductID AND ps.SettingType IN (4)
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
			END	
			
			SELECT TOP 1 @BitmapOrder = psp.bitmapOrder
			FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
				INNER JOIN #DisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType		
				INNER JOIN #ProductSettingDetail_tmp04 ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
			WHERE ps.SettingType IN (4)	
			
			IF @RoleID=4
			BEGIN
				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)				
				
				IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
				BEGIN
				
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T  WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
					
				END
				
			END
			ELSE IF @RoleID=3
			BEGIN
				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
				
				IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
				BEGIN
				
					UPDATE T
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T  WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
					
				END
			END
			ELSE IF @RoleID=2
			BEGIN
				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1
				
				IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.recommend = @custid AND CI.roleid = 1
					
				END
			END
		END
		IF @Action = 'NewProductStatus' --Setting type in (4,13,21)
		BEGIN
			CREATE TABLE #NewStatTbl(
					SportType			SMALLINT,
					BetType				SMALLINT,
					IsDisabled			BIT,
					UpdateAllMasters	BIT,
					UpdateAllAgents		BIT,
					UpdateAllMembers	BIT,
					DisableAllMasters	BIT,
					DisableAllAgents	BIT,
					DisableAllMembers	BIT,
					UpdateAllSuperDirectMembers	BIT,
					UpdateAllMasterDirectMembers	BIT,
					DisableAllSuperDirectMembers	BIT,
					DisableAllMasterDirectMembers	BIT,
					RealProductId		TINYINT
				)

			--Parse XML				
			EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
			
			INSERT INTO #NewStatTbl (SportType, BetType, IsDisabled, UpdateAllMasters, UpdateAllAgents, UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers,UpdateAllSuperDirectMembers, UpdateAllMasterDirectMembers, DisableAllSuperDirectMembers, DisableAllMasterDirectMembers)
			SELECT SportType, BetType, IsDisabled, UpdateAllMasters, UpdateAllAgents, UpdateAllMembers,DisableAllMasters,DisableAllAgents,DisableAllMembers,UpdateAllSuperDirectMembers, UpdateAllMasterDirectMembers, DisableAllSuperDirectMembers, DisableAllMasterDirectMembers
			FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
			WITH(SportType smallint,BetType smallint,IsDisabled BIT,UpdateAllMasters BIT,UpdateAllAgents BIT,UpdateAllMembers BIT,DisableAllMasters BIT,DisableAllAgents BIT,DisableAllMembers BIT,UpdateAllSuperDirectMembers BIT, UpdateAllMasterDirectMembers BIT, DisableAllSuperDirectMembers BIT, DisableAllMasterDirectMembers BIT)	
		
			EXEC sp_xml_removedocument @iDoc
			
			UPDATE ns 
			SET ns.RealProductId = ps.RealProductId
			FROM #NewStatTbl ns
				INNER JOIN #ProductSettingDetail_tmp04 ps ON ns.Sporttype = ps.SportType AND ns.Bettype = ps.BetType

			IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
			BEGIN
				SET @xmlStrHidden = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, 0	AS '@s'
							FROM dbo.ProductStatusProfile psp (NOLOCK)
								INNER JOIN #ProductSettingDetail_tmp04 ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
								LEFT JOIN #NewStatTbl ns ON psp.Sporttype = ns.SportType AND psp.Bettype = ns.BetType
							WHERE ps.SettingType  IN ( 13, 4, 21) AND ps.RealProductId IN (SELECT DISTINCT RealProductId FROM #NewStatTbl WHERE IsDisabled = 0)
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
			END	
			
			SELECT TOP 1 @BitmapOrder = psp.bitmapOrder
			FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
				INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType		
				INNER JOIN #ProductSettingDetail_tmp04 ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
			WHERE ps.SettingType IN ( 13, 4, 21)
			
			IF @RoleID=4
			BEGIN			
				SET @xmlStrDisabledMasters = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMasters	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE UpdateAllMasters = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				SET @xmlStrDisabledAgents = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllAgents	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllAgents = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
				
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

			SET @xmlStrDisabledSuperDirectMembers = (
				SELECT (
						SELECT DISTINCT psp.bitmapOrder	AS '@b'
							, tmp.DisableAllSuperDirectMembers	AS '@s'
						FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
							INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						WHERE tmp.UpdateAllSuperDirectMembers = 1
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)

			SET @xmlStrDisabledMasterDirectMembers = (
				SELECT (
						SELECT DISTINCT psp.bitmapOrder	AS '@b'
							, tmp.DisableAllMasterDirectMembers	AS '@s'
						FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
							INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						WHERE tmp.UpdateAllMasterDirectMembers = 1
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasters))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 3
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				
				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 2
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 1 AND CI.recommend NOT IN (-3,-4)			-- Update bitmapIsDisabled Normal Member
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledSuperDirectMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 1 AND CI.recommend = -4
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasterDirectMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 1 AND CI.recommend = -3
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T  WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			END
			ELSE IF @RoleID=3
			BEGIN
				SET @xmlStrDisabledAgents = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllAgents	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllAgents = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
				
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

			SET @xmlStrDisabledMasterDirectMembers = (
				SELECT (
						SELECT DISTINCT psp.bitmapOrder	AS '@b'
							, tmp.DisableAllMasterDirectMembers	AS '@s'
						FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
							INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						WHERE tmp.UpdateAllMasterDirectMembers = 1
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 2
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 1 AND CI.recommend NOT IN (-3,-4)			-- Update bitmapIsDisabled Normal Member
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasterDirectMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 1 AND CI.recommend = -3
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			END
			ELSE IF @RoleID=2
			BEGIN
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #NewStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1 AND CI.recommend NOT IN (-3,-4)			-- Update bitmapIsDisabled Normal Member
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.recommend = @custid AND CI.roleid = 1
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			END		
		END
		ELSE IF @Action = 'GameStatus' --Setting type = 11
		BEGIN		
			CREATE TABLE #GameDisableStatTbl(
					SportType SMALLINT,
					BetType SMALLINT,
					IsDisabled BIT,
					UpdateAllMasters	BIT,
					UpdateAllAgents		BIT,
					UpdateAllMembers	BIT,
					DisableAllMasters	BIT,
					DisableAllAgents	BIT,
					DisableAllMembers	BIT
				)

			--Parse XML		
			EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
			
			INSERT INTO #GameDisableStatTbl
			SELECT *
			FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
			WITH(SportType smallint,BetType smallint,IsDisabled BIT,UpdateAllMasters BIT,UpdateAllAgents BIT,UpdateAllMembers BIT,DisableAllMasters BIT,DisableAllAgents BIT,DisableAllMembers BIT)	
			
			EXEC sp_xml_removedocument @iDoc
		
			IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				SELECT TOP 1 @ProductID = ps.ProductID
				FROM #GameDisableStatTbl dis 
					INNER JOIN #ProductSettingDetail_tmp04 ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
					WHERE dis.IsDisabled = 0 AND ps.SettingType = 11

				SET @xmlStrHidden = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, 0	AS '@s'
							FROM ProductStatusProfile psp (NOLOCK)
								INNER JOIN #ProductSettingDetail_tmp04 ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
							WHERE ps.ProductID = @ProductID AND ps.SettingType = 11
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
			END	

			--Get 1 bettype as representation to check Synced
			SELECT TOP 1 @BitmapOrder = psp.bitmapOrder
			FROM ProductStatusProfile psp WITH (NOLOCK)
				INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
				INNER JOIN #ProductSettingDetail_tmp04 ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
			WHERE ps.SettingType = 11

			IF @RoleID=4
			BEGIN
				SET @xmlStrDisabledMasters = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMasters	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE UpdateAllMasters = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				SET @xmlStrDisabledAgents = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllAgents	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllAgents = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
				
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasters))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 3
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				
				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 2
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid = 1
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			
			END
			ELSE IF @RoleID=3
			BEGIN
				SET @xmlStrDisabledAgents = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllAgents	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllAgents = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)
				
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 2
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 1
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			END
			ELSE IF @RoleID=2
			BEGIN
				SET @xmlStrDisabledMembers = (
					SELECT (
							SELECT DISTINCT psp.bitmapOrder	AS '@b'
								, tmp.DisableAllMembers	AS '@s'
							FROM dbo.ProductStatusProfile psp WITH (NOLOCK)
								INNER JOIN #GameDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
							WHERE tmp.UpdateAllMembers = 1
							FOR XML PATH('r')
								, TYPE
							)
					FOR XML PATH('root')
						, TYPE
					)

				UPDATE T 
					SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers))),
						RepUpdateTime = dbo.f_GetDateTime2()
				FROM  dbo.CustProductStatus T WITH (ROWLOCK, UPDLOCK)
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

				IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
				BEGIN
					UPDATE T 
						SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden))),
							RepUpdateTime = dbo.f_GetDateTime2()
					FROM CustProductStatus T WITH (ROWLOCK, UPDLOCK)
						INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
					WHERE CI.mrecommend = @custid AND CI.roleid = 1
						AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
				END
			END
		END
	END--run on DBCUST KBT only
	
	IF @Action = 'CloseInfo'
	BEGIN
		IF dbo.f_CheckServerName() = 1 -- run on DBCUST ONLY	
			AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
		BEGIN
			IF @roleid = 4
			BEGIN			
				UPDATE	cs 
				SET	CloseInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(4,@Closed,ISNULL(CloseInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	SRecommend = @CustID;
				
			END	
			ELSE IF @roleid = 3
			BEGIN			
				UPDATE	cs 
				SET	CloseInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(3,@Closed,ISNULL(CloseInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	mRecommend = @CustID;
									
			END	
			ELSE IF @roleid = 2
			BEGIN			
				UPDATE	cs 
				SET	CloseInfo = (SELECT suspendinfo FROM dbo.f_GenerateSuspendInfo(2,@Closed,ISNULL(CloseInfo,0))),
					RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
				WHERE	Recommend = @CustID;			
			END	
		END
		
		IF @roleid = 4
		BEGIN
			IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
			BEGIN
				UPDATE	cs 
				SET	 cs.ClosedReason = @ClosedReason
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.CustID = ci.custid
					CROSS APPLY  (SELECT CASE WHEN cl.MasterStatus + cl.AgentStatus > 0 THEN 1 ELSE 0 END AS closed
								  FROM dbo.CustProductStatus cp WITH(NOLOCK)
										CROSS APPLY (SELECT * FROM f_GetInfoStatus(cp.CloseInfo)) AS cl
								  WHERE CustID = ci.custid
								  ) AS cps
				WHERE ci.SRecommend = @CustID AND cs.CustID <> @CustID 
					AND 1 = (CASE WHEN @Closed = 1 AND cps.closed <> @Closed THEN 1
								 WHEN @Closed = 0 AND cps.closed = @Closed THEN 1
								 ELSE 0 END)	;

				UPDATE	cs 
				SET	 ClosedReason = @ClosedReason
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo_Member cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN cl.MasterStatus + cl.AgentStatus + cl.MemberStatus > 0 THEN 1 ELSE 0 END AS closed
								  FROM dbo.CustProductStatus cp WITH(NOLOCK)
										CROSS APPLY (SELECT * FROM f_GetInfoStatus(cp.CloseInfo)) AS cl
								  WHERE CustID = ci.custid
								  ) AS cps
				WHERE ci.SRecommend = @CustID AND cs.CustID <> @CustID
					AND 1 = (CASE WHEN @Closed = 1 AND cps.closed <> @Closed THEN 1
								 WHEN @Closed = 0 AND cps.closed = @Closed THEN 1
								 ELSE 0 END)	;
			END
		END	
		ELSE IF @roleid = 3
		BEGIN	
			IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active' -- run on KBT
			BEGIN
				UPDATE	cs 
				SET	 ClosedReason = @ClosedReason
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN cl.AgentStatus > 0 THEN 1 ELSE 0 END AS closed
								  FROM dbo.CustProductStatus cp WITH(NOLOCK)
										CROSS APPLY (SELECT * FROM f_GetInfoStatus(cp.CloseInfo)) AS cl
								  WHERE CustID = ci.custid
								  ) AS cps
				WHERE ci.MRecommend = @CustID AND cs.CustID <> @CustID
					AND 1 = (CASE WHEN @Closed = 1 AND cps.closed <> @Closed THEN 1
								 WHEN @Closed = 0 AND cps.closed = @Closed THEN 1
								 ELSE 0 END)	;

				UPDATE	cs 
				SET	 ClosedReason = @ClosedReason
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo_Member cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN cl.AgentStatus + cl.MemberStatus > 0 THEN 1 ELSE 0 END AS closed
								  FROM dbo.CustProductStatus cp WITH(NOLOCK)
										CROSS APPLY (SELECT * FROM f_GetInfoStatus(cp.CloseInfo)) AS cl
								  WHERE CustID = ci.custid
								  ) AS cps
				WHERE ci.MRecommend = @CustID AND cs.CustID <> @CustID
					AND 1 = (CASE WHEN @Closed = 1 AND cps.closed <> @Closed THEN 1
								 WHEN @Closed = 0 AND cps.closed = @Closed THEN 1
								 ELSE 0 END)	;
			ENd
							
		END	
		ELSE IF @roleid = 2
		BEGIN	
			IF dbo.f_CheckServerName() = 1 AND dbo.f_CheckEnvironment() = 'Active'
			BEGIN
				UPDATE	cs 
				SET	 ClosedReason = @ClosedReason
					,RepUpdateTime = dbo.f_GetDateTime2()
				FROM CustLoginInfo_Member cs WITH (ROWLOCK, UPDLOCK) 
					INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
					CROSS APPLY  (SELECT CASE WHEN cl.MemberStatus > 0 THEN 1 ELSE 0 END AS closed
								  FROM dbo.CustProductStatus cp WITH(NOLOCK)
										CROSS APPLY (SELECT * FROM f_GetInfoStatus(cp.CloseInfo)) AS cl
								  WHERE CustID = ci.custid
								  ) AS cps
				WHERE ci.Recommend = @CustID
					AND 1 = (CASE WHEN @Closed = 1 AND cps.closed <> @Closed THEN 1
								 WHEN @Closed = 0 AND cps.closed = @Closed THEN 1
								 ELSE 0 END)	;
			END
		END


			
	END
	DROP TABLE #ProductSettingDetail_tmp04
END
GO

