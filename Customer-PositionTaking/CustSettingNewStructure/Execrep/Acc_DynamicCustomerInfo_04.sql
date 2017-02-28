ALTER PROCEDURE [dbo].[Acc_DynamicCustomerInfo_04]
	@custid int,
	@roleid tinyint,
	@IsDisabled_XML VARCHAR(MAX) = NULL,
	@Action	VARCHAR(30)	= 'ProductStatus'
AS
/*
	Created: 20151007@Dominic
	Task : Update customer/custinfo settings
	DB: DBCust/CustDB

	Revision: 
		- 20160801@Elodie: Implement Game status (setting type = 11) - [Redmine: #60809]   
		- 20170103@Elodie: Unhide all bettype although 1 bettype is enabled - [Redmine: #69679]   

*/
BEGIN
	SET NOCOUNT ON 
	
	IF dbo.f_CheckRepTable('custinfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustProductStatus') = 0 RETURN
	
	--Check if XML is null or empty
	IF @IsDisabled_XML IS NULL OR @IsDisabled_XML='' RETURN
		
	DECLARE @iDoc INT, @xmlStrDisabled XML, @xmlStrHidden XML, @ProductID INT

	CREATE TABLE #NewDisableStatTbl(
				SportType SMALLINT,
				BetType SMALLINT,
				IsDisabled BIT,
				IsDisabledDownline BIT
			)
	IF @Action = 'ProductStatus'
	BEGIN
		--Parse XML				
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
		
		INSERT INTO #NewDisableStatTbl
		SELECT *
		FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
		WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT
			)	
		
		EXEC sp_xml_removedocument @iDoc
	
		SET @xmlStrDisabled = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, tmp.IsDisabled	AS '@s'
						FROM ProductStatusProfile psp WITH (NOLOCK)
							INNER JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						WHERE tmp.IsDisabled = 1 OR (tmp.IsDisabled = 0 AND tmp.IsDisabledDownline = 0)
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)
	
		IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabledDownline = 0 AND IsDisabled = 0)
		BEGIN
			SELECT TOP 1 @ProductID = ps.ProductID
			FROM #NewDisableStatTbl dis 
				INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) ON ps.BetType = dis.BetType AND ps.SportType = dis.SportType
			WHERE dis.IsDisabled = 0 AND IsDisabledDownline = 0 AND ps.SettingType = 4

			SET @xmlStrHidden = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, 0	AS '@s'
						FROM ProductStatusProfile psp (NOLOCK)
							INNER JOIN ProductSettingDetail ps ON PSP.Sporttype = ps.SportType AND psp.Bettype = ps.BetType
						WHERE ps.ProductID = @ProductID AND ps.SettingType = 4
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)
		END	
	
		IF @RoleID=4
		BEGIN
		
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
		
			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
		
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
			
			END
		
		END
	
		ELSE IF @RoleID=3
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
		
			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
		
				UPDATE T WITH (UPDLOCK,ROWLOCK)
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
			
			END
		END
		ELSE IF @RoleID=2
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.recommend = @custid AND CI.roleid = 1
		
			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1
			
			END
		END
	END
	ELSE IF @Action = 'GameStatus'
	BEGIN
		--Parse XML		
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @IsDisabled_XML
		
		INSERT INTO #NewDisableStatTbl
		SELECT *
		FROM OPENXML (@iDoc, '/ROOT/ProductStatus',1) 
		WITH(SportType smallint, BetType smallint, IsDisabled BIT,IsDisabledDownline BIT
			)	
		
		EXEC sp_xml_removedocument @iDoc
	
		SET @xmlStrDisabled = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, tmp.IsDisabled	AS '@s'
						FROM ProductStatusProfile psp WITH (NOLOCK)
							JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
	
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)
		DECLARE @BitmapOrder TINYINT

		--Get 1 bettype as representation to check Synced
		SELECT TOP 1 @BitmapOrder = psp.bitmapOrder
		FROM ProductStatusProfile psp WITH (NOLOCK)
			INNER JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType

		IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
		BEGIN
			SET @xmlStrHidden = (
				SELECT (
						SELECT psp.bitmapOrder	AS '@b'
							, 0	AS '@s'
						FROM ProductStatusProfile psp (NOLOCK)
							JOIN #NewDisableStatTbl tmp ON PSP.Sporttype = tmp.SportType AND psp.Bettype = tmp.BetType
						WHERE tmp.IsDisabled=0	
						FOR XML PATH('r')
							, TYPE
						)
				FOR XML PATH('root')
					, TYPE
				)
		END	
	
		IF @RoleID=4
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.srecommend = @custid AND CI.roleid IN (1,2,3)
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
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
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
		
			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T WITH (UPDLOCK,ROWLOCK)
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.mrecommend = @custid AND CI.roleid IN (1,2)
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
		ELSE IF @RoleID=2
		BEGIN
			UPDATE T 
				SET bitmapIsDisabled = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (T.bitmapIsDisabled, CONVERT(VARCHAR(MAX),@xmlStrDisabled)))	
			FROM  CustProductStatus T
				INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
			WHERE CI.recommend = @custid AND CI.roleid = 1
				AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1

			IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
			BEGIN
				UPDATE T 
					SET bitmapIsHidden = (SELECT bitmap FROM dbo.f_GenerateProductStatus_multiple (bitmapIsHidden, CONVERT(VARCHAR(MAX),@xmlStrHidden)))	
				FROM CustProductStatus T 
					INNER JOIN custInfo CI WITH (NOLOCK) ON T.CustID = CI.custid	
				WHERE CI.recommend = @custid AND CI.roleid = 1
					AND (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(bitmapHasSynced, @BitmapOrder)) = 1
			END
		END
	END
END


GO
GRANT EXECUTE ON [dbo].[Acc_DynamicCustomerInfo_04] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_DynamicCustomerInfo_04] TO [vnteam] AS [dbo]
