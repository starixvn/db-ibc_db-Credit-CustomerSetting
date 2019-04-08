/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_04]
	@custid int,
	@roleid tinyint,
	@IsDisabled_XML VARCHAR(MAX) = NULL,
	@Suspended BIT = NULL,	
	@Action	VARCHAR(30)	= 'ProductStatus'
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
*/
BEGIN
	SET NOCOUNT ON 
	
	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustProductStatus') = 0 RETURN
	
	--Check if XML is null or empty
	IF @Action <> 'SuspendInfo'AND ( @IsDisabled_XML IS NULL OR @IsDisabled_XML='') RETURN
		
	DECLARE @iDoc INT, 
			@xmlStrDisabledMasters XML, 
			@xmlStrDisabledAgents XML, 
			@xmlStrDisabledMembers XML, 
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
			SET	SuspendInfo = dbo.f_GenerateSuspendInfo(4,@Suspended,SuspendInfo)
			OUTPUT DELETED.custid, DELETED.SuspendInfo, INSERTED.SuspendInfo
			INTO #tblCust
			FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
				INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
			WHERE	SRecommend = @CustID;
			
		END	
		ELSE IF @roleid = 3
		BEGIN			
			UPDATE	cs 
			SET	SuspendInfo = dbo.f_GenerateSuspendInfo(3,@Suspended,SuspendInfo)
			OUTPUT DELETED.custid, DELETED.SuspendInfo, INSERTED.SuspendInfo
			INTO #tblCust
			FROM CustProductStatus cs WITH (ROWLOCK, UPDLOCK) 
				INNER JOIN custinfo ci WITH(NOLOCK) ON cs.custid = ci.custid
			WHERE	mRecommend = @CustID;
								
		END	
		ELSE IF @roleid = 2
		BEGIN			
			UPDATE	cs 
			SET	SuspendInfo = dbo.f_GenerateSuspendInfo(2,@Suspended,SuspendInfo)
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
			DELETE #tblCust WHERE OldSuspendInfo > 0 AND NewSuspendInfo = 0
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
						SELECT psp.bitmapOrder	AS '@b'
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
				INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
			WHERE dis.IsDisabled = 0 AND IsDisabledDownline = 0 AND ps.SettingType IN (4)

			SET @xmlStrHidden = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, 0	AS '@s'
						FROM dbo.ProductStatusProfile psp (NOLOCK)
							INNER JOIN ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
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
			INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
		WHERE ps.SettingType IN (4)	
		
		IF @RoleID=4
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)				
			
			IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
			BEGIN
			
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
				
			END
			
		END
		ELSE IF @RoleID=3
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
			
			IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
			BEGIN
			
				UPDATE T WITH (UPDLOCK,ROWLOCK)
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
				
			END
		END
		ELSE IF @RoleID=2
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.recommend = @custid AND CI.roleid = 1
			
			IF EXISTS (SELECT 1 FROM #DisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1
				
			END
		END
	END
	IF @Action = 'NewProductStatus' --Setting type = 13
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
				DisableAllMembers	BIT
			)

		--Parse XML				
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
		
		INSERT INTO #NewStatTbl
		SELECT *
		FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
		WITH(SportType smallint,BetType smallint,IsDisabled BIT,UpdateAllMasters BIT,UpdateAllAgents BIT,UpdateAllMembers BIT,DisableAllMasters BIT,DisableAllAgents BIT,DisableAllMembers BIT)	
		
		EXEC sp_xml_removedocument @iDoc
		
		IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
		BEGIN
			SELECT TOP 1 @ProductID = ps.ProductID
			FROM #NewStatTbl dis 
				INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
			WHERE dis.IsDisabled = 0 AND ps.SettingType = 13

			SET @xmlStrHidden = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, 0	AS '@s'
						FROM dbo.ProductStatusProfile psp (NOLOCK)
							INNER JOIN ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
						WHERE ps.ProductID = @ProductID AND ps.SettingType = 13
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
			INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
		WHERE ps.SettingType = 13
		
		IF @RoleID=4
		BEGIN			
			SET @xmlStrDisabledMasters = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasters)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 3
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 2
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			UPDATE T 
			SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
		ELSE IF @RoleID=3
		BEGIN
			SET @xmlStrDisabledAgents = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid = 2
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
					INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
		ELSE IF @RoleID=2
		BEGIN
			SET @xmlStrDisabledMembers = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.recommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #NewStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM dbo.CustProductStatus T 
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
				INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
				WHERE dis.IsDisabled = 0 AND ps.SettingType = 11

			SET @xmlStrHidden = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, 0	AS '@s'
						FROM ProductStatusProfile psp (NOLOCK)
							INNER JOIN ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
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
			INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = tmp.BetType AND ps.SportType = tmp.SportType
		WHERE ps.SettingType = 11

		IF @RoleID=4
		BEGIN
			SET @xmlStrDisabledMasters = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMasters)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 3
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 2
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		
		END
		ELSE IF @RoleID=3
		BEGIN
			SET @xmlStrDisabledAgents = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledAgents)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid = 2
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
		ELSE IF @RoleID=2
		BEGIN
			SET @xmlStrDisabledMembers = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
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
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabledMembers)))	
			FROM  dbo.CustProductStatus T
				INNER JOIN dbo.custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.recommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #GameDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid = 1
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
	END
END
GO

