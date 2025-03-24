/*<info serverAlias="DBCust-CustDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_Initial_DCS_InitProductStatus
	 @DirectCustID INT
	,@Maxcustid INT
	,@StepID TINYINT = 0
	,@XMLConfig VARCHAR(MAX) = NULL	
AS
/*
	Created: 20250324@Eden
	Task : Flexible Initializing Customer Setting
	DB: DBCUST/CustDB
	Original: Acc_DynamicCustomerInfo_05

	Revisions:
		- 20250324@Eden: Reduce the partial UM for the initial customer setting [Redmine: #219867]

	Param's Explanation:
		@StepID = :
			3: Enable status  

*/
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TempConfig(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit],
		[SettingType] [tinyint],
		[IsDefault] [bit],
		[CopyFromSportType] [smallint],
		[CopyFromBetType] [smallint],
		[DefaultValueSuper] [decimal](11,8),
		[DefaultValueMaster] [decimal](11,8),
		[DefaultValueAgent] [decimal](11,8),
		[DefaultValueMember] [decimal](11,8),
		[SpecialRequirement] [varchar](MAX),
		[SettingName] [varchar](30),
		[bitmapOrder] [tinyint],
		[bitmapOrder_Source] [tinyint],
		[IsFinished] [bit] default 0
	)
	
	DECLARE @DocHandler INT	
	IF ISNULL(@XMLConfig,'') <> ''
	BEGIN
		-- For read xml					
		EXEC sp_xml_preparedocument @DocHandler OUTPUT, @XMLConfig
		INSERT INTO #TempConfig (
			 SportType
			,BetType
			,IsLive
			,SettingType
			,IsDefault
			,CopyFromSportType
			,CopyFromBetType
			,DefaultValueSuper
			,DefaultValueMaster
			,DefaultValueAgent
			,DefaultValueMember
			,SpecialRequirement
			,SettingName
		)
		SELECT Data.SportType
			,Data.BetType
			,Data.IsLive
			,Data.SettingType
			,Data.IsDefault
			,Data.CopyFromSportType
			,Data.CopyFromBetType
			,Data.DefaultValueSuper
			,Data.DefaultValueMaster
			,Data.DefaultValueAgent
			,Data.DefaultValueMember
			,Data.SpecialRequirement
			,Data.SettingName
		FROM OPENXML (@DocHandler, '/ROOT/R',1) 
		WITH (
			[SportType] [smallint],
			[BetType] [smallint],
			[IsLive] [bit],
			[SettingType] [tinyint],
			[IsDefault] [bit],
			[CopyFromSportType] [smallint],
			[CopyFromBetType] [smallint],
			[DefaultValueSuper] [decimal](11,8),
			[DefaultValueMaster] [decimal](11,8),
			[DefaultValueAgent] [decimal](11,8),
			[DefaultValueMember] [decimal](11,8),
			[SpecialRequirement] [varchar](MAX),
			[SettingName] [varchar](30)
		) AS Data
		WHERE Data.SettingName = 'Product Status'

		EXEC sp_xml_removedocument @DocHandler
		-- end read xml	
	END	
	
	--> Update default Values for status
	UPDATE t
	SET t.DefaultValueSuper = CASE WHEN t.DefaultValueSuper = 1 THEN 0 ELSE 1 END,
		t.DefaultValueMaster = CASE WHEN t.DefaultValueMaster = 1 THEN 0 ELSE 1 END,
		t.DefaultValueAgent = CASE WHEN t.DefaultValueAgent = 1 THEN 0 ELSE 1 END,
		t.DefaultValueMember = CASE WHEN t.DefaultValueMember = 1 THEN 0 ELSE 1 END
	FROM #TempConfig t
	WHERE t.SettingName = 'Product Status'

	DECLARE @BatchNum INT = 5000
	DECLARE @BitMapOrder TINYINT, @BitMapOrder_S TINYINT
	DECLARE @IsDisableSuper BIT, @IsDisableMaster BIT,  @IsDisableAgent BIT,  @IsDisableMember BIT  

	IF NOT EXISTS( SELECT 1 FROM #TempConfig)
		RETURN

	--> Get bitmapOrder
	UPDATE t
	SET t.bitmapOrder = p.bitmapOrder,
		t.bitmapOrder_Source = pS.bitmapOrder
	FROM #TempConfig t
		INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
			ON t.SportType = p.Sporttype
			AND t.BetType = p.Bettype
		LEFT JOIN ProductStatusProfile pS WITH(NOLOCK) 
			ON t.CopyFromSportType = pS.Sporttype
			AND t.CopyFromBetType = pS.Bettype
			AND t.IsDefault = 0

	IF EXISTS( SELECT 1 FROM #TempConfig WHERE BitMapOrder IS NULL)
		RETURN

	IF EXISTS( SELECT 1 FROM #TempConfig WHERE bitmapOrder_Source IS NULL AND IsDefault = 0)
		RETURN

	IF EXISTS(  SELECT 1 
				FROM #TempConfig 
				WHERE (DefaultValueSuper IS NULL 
						OR DefaultValueMaster IS NULL 
						OR DefaultValueAgent IS NULL 
						OR DefaultValueMember IS NULL)
					AND IsDefault = 1
				)
		RETURN
			
	CREATE TABLE #MemberTemp(CustID INT PRIMARY KEY CLUSTERED, IsFinished bit default 0)
	CREATE TABLE #SMATemp(CustID INT PRIMARY KEY CLUSTERED, roleid TINYINT, IsFinished bit default 0)
	CREATE TABLE #CustTempBatch(CustID INT)
	CREATE TABLE #DummyAcc(custid INT PRIMARY KEY, RoleID INT)

	DECLARE @DirectCustRoleID TINYINT
	DECLARE @DummySuper INT, @DummyMaster INT, @DummyAgent INT

	--> Get Dummy uplines if they are enabled (need to be initialized setting)
	SELECT  @DirectCustRoleID = c.roleid,
			@DummySuper = CASE WHEN c.roleid IN(1,2,3) AND up.roleid = 4 THEN up.custid ELSE @DummySuper END,
			@DummyMaster = CASE WHEN c.roleid IN(1,2) AND up.roleid = 3 THEN up.custid ELSE @DummyMaster END,
			@DummyAgent = CASE WHEN c.roleid = 1 AND up.roleid = 2 THEN up.custid ELSE @DummyAgent END
	FROM custInfo c WITH(NOLOCK) 
		INNER JOIN custinfo Up WITH(NOLOCK) 
			ON up.custID IN (c.srecommend,c.mrecommend,c.recommend) 
			AND up.Enabled = 1
	WHERE c.custid = @DirectCustID

	INSERT INTO #DummyAcc(custid,RoleID)
	SELECT @DummySuper, 4 WHERE @DummySuper IS NOT NULL UNION ALL
	SELECT @DummyMaster, 3 WHERE @DummyMaster IS NOT NULL UNION ALL
	SELECT @DummyAgent, 2 WHERE @DummyAgent IS NOT NULL
	
	IF @DirectCustRoleID = 4
	BEGIN
		INSERT INTO #MemberTemp (CustID)
		SELECT custid
		FROM Custinfo WITH (NOLOCK)
		WHERE srecommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE srecommend = @DirectCustID AND roleid IN (2,3,4) AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 3
	BEGIN
		INSERT INTO #MemberTemp (CustID)
		SELECT custid
		FROM Custinfo WITH (NOLOCK)
		WHERE mrecommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE mrecommend = @DirectCustID AND roleid IN (2,3) AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 2
	BEGIN
		INSERT INTO #MemberTemp (CustID)
		SELECT custid
		FROM Custinfo WITH (NOLOCK)
		WHERE recommend = @DirectCustID AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
		INSERT INTO #SMATemp (CustID, roleid)
		SELECT custid, roleid
		FROM Custinfo WITH (NOLOCK)
		WHERE recommend = @DirectCustID AND roleid = 2 AND Enabled = 1 AND custid <= @maxcustid
	END
	ELSE IF @DirectCustRoleID = 1
	BEGIN
		INSERT INTO #MemberTemp (CustID)
		SELECT custid
		FROM Custinfo WITH (NOLOCK)
		WHERE custid = @DirectCustID AND roleid = 1 AND Enabled = 1 AND custid <= @maxcustid
	END

	---------------------PROCESS UPDATE Status----------------------------------------------------------
	IF @StepID = 3
	BEGIN
		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Product Status' AND IsDefault = 0)
		BEGIN
			UPDATE #TempConfig SET IsFinished = 0

			WHILE 1 = 1
			BEGIN 
				UPDATE TOP (1) t
				SET t.IsFinished = 1,
					@BitMapOrder = t.bitmapOrder,
					@BitMapOrder_S = t.bitmapOrder_Source
				FROM #TempConfig t
				WHERE t.IsFinished = 0
					AND t.IsDefault = 0

				IF @@ROWCOUNT = 0
					BREAK

				UPDATE #SMATemp SET IsFinished = 0
				UPDATE #MemberTemp SET IsFinished = 0

				IF @DirectCustRoleID <> 4
				BEGIN
					--Dummy SMA
					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #DummyAcc ci ON ci.custid = cs.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END

				--SMA level
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #SMATemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END

				--Member level
				WHILE 1 = 1
				BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #MemberTemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_ProductStatusSel(CS.bitmapIsDisabled, @BitMapOrder_S) as isDisabled_S
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,isDisabled_S.value) as Dis
				END
			END
		END

		IF EXISTS( SELECT 1 FROM #TempConfig WHERE SettingName = 'Product Status' AND IsDefault = 1)
		BEGIN
			UPDATE #TempConfig SET IsFinished = 0

			WHILE 1 = 1
			BEGIN 
				UPDATE TOP (1) t
				SET t.IsFinished = 1,
					@BitMapOrder = t.bitmapOrder,
					@IsDisableSuper = t.DefaultValueSuper,
					@IsDisableMaster = t.DefaultValueMaster,
					@IsDisableAgent = t.DefaultValueAgent,
					@IsDisableMember = t.DefaultValueMember
				FROM #TempConfig t
				WHERE t.IsFinished = 0
					AND t.IsDefault = 1

				IF @@ROWCOUNT = 0
					BREAK

				UPDATE #MemberTemp SET IsFinished = 0

				IF @DirectCustRoleID <> 4
				BEGIN
					--Dummy SMA
					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #DummyAcc ci ON ci.custid = cs.CustID
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis
				END

				--Direct SMA Level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap,
					cs.RepupdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis
				WHERE cs.CustID = @DirectCustID

				--Master level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap,
					cs.RepupdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid = 3
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableMaster) as Dis
				WHERE ci.CustID <> @DirectCustID

				--Agent level
				UPDATE cs
				SET cs.bitmapIsHidden = hid.NewBitmap,
					bitmapIsDisabled = dis.NewBitmap,
					cs.RepupdateTime = dbo.f_GetDateTime2()
				FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
					INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID AND ci.roleid = 2
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
					CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableAgent) as Dis
				WHERE ci.CustID <> @DirectCustID

				
				IF @DirectCustRoleID = 1 --Direct member
				BEGIN
					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #MemberTemp ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableSuper) as Dis
					WHERE cs.CustID = @DirectCustID
				END
				ELSE
				BEGIN
					--Member level
					WHILE 1 = 1
					BEGIN
					TRUNCATE TABLE #CustTempBatch

					UPDATE TOP(@BatchNum) t
					SET t.IsFinished = 1
					OUTPUT deleted.custid INTO #CustTempBatch(custid)
					FROM #MemberTemp t
					WHERE t.IsFinished = 0

					IF @@ROWCOUNT = 0
						BREAK

					UPDATE cs
					SET cs.bitmapIsHidden = hid.NewBitmap,
						bitmapIsDisabled = dis.NewBitmap,
						cs.RepupdateTime = dbo.f_GetDateTime2()
					FROM [dbo].[CustProductStatus] cs WITH(ROWLOCK,UPDLOCK)
						INNER JOIN #CustTempBatch ci ON cs.CustID = ci.CustID
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsHidden,@BitMapOrder,0) as Hid
						CROSS APPLY dbo.f_CustSetting_GenerateProductStatus(cs.bitmapIsDisabled,@BitMapOrder,@IsDisableMember) as Dis
				END
				END
			END
		END
	END

	DROP TABLE #CustTempBatch
	DROP TABLE #MemberTemp
	DROP TABLE #SMATemp
	DROP TABLE #TempConfig
END
GO

