ALTER PROCEDURE [dbo].[Acc_CustSetting_DisableNewProductStatusCheck] 
	  @IsDisabled	VARCHAR(MAX)
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @SystemID			TINYINT	
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20170125@ELodie
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"
						IsDisabledDownline="1"
				/>
		</ROOT>

	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #NewDisableStatTbl 
	(
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsDisabled		BIT
			,IsDisabledDownline	BIT
	)
	CREATE TABLE #OldDisableStatTbl 
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
	)
	CREATE TABLE #ErrorSportTypeTbl
	(
			SportType	SMALLINT
			, BetType	SMALLINT
			, MsgID		INT
	)
	DECLARE @xml		XML, @HasDownlines BIT

	SELECT @ErrCode = 0
		, @ErrMsg	= ''

	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsDisabled

	INSERT INTO #NewDisableStatTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, IsDisabledDownline	BIT
			)

	EXEC sp_xml_removedocument @iDoc

	IF @RoleID = 4
	BEGIN
		IF EXISTS (SELECT 1
				FROM custinfo WITH (NOLOCK)
				WHERE srecommend = @SuperID AND roleid = 3
				)
			SET @HasDownlines = 1
	END
	ELSE IF @RoleID = 3
	BEGIN
		IF EXISTS (SELECT 1
				FROM custinfo WITH (NOLOCK)
				WHERE mrecommend = @MasterID AND roleid = 2
				)
			SET @HasDownlines = 1
	END
	ELSE IF @RoleID = 2
	BEGIN
		IF EXISTS (SELECT 1
					FROM custinfo WITH (NOLOCK)
					WHERE recommend = @AgentID AND roleid = 1
					)
			SET @HasDownlines = 1	
	END
	ELSE IF @RoleID = 1
	BEGIN
		SET @HasDownlines = 0
	END
	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 0)
	BEGIN
	
		IF @RoleID = 3
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
		ELSE IF @RoleID = 2
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @MasterID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
				
		END
		ELSE IF @RoleID = 1
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
	END

	--60035: You are not allowed to disable for downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1 OR IsDisabledDownline = 1) AND @SystemID <> 1
	BEGIN
		IF @RoleID = 4
		BEGIN
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled, IsDisabledDownline)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
					CAST(CASE WHEN @HasDownlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
								ELSE ISNULL((
											SELECT TOP 1 1
											FROM dbo.custInfo ci WITH (NOLOCK)
												INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
											WHERE srecommend = @SuperID AND roleid = 3
												AND IsSynced.value = 1
												AND IsDisabled.value = 1
											), 0) END AS BIT) AS IsDisabledDownline
			FROM #NewDisableStatTbl ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @SuperID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE (tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0) OR (tmp.IsDisabledDownline = 1 AND Otmp.IsDisabledDownline = 0 AND @HasDownlines = 1)
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled, IsDisabledDownline)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
					CAST(CASE WHEN @HasDownlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
								ELSE ISNULL((
											SELECT TOP 1 1
											FROM dbo.custInfo ci WITH (NOLOCK)
												INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
											WHERE mrecommend = @MasterID AND roleid = 2
												AND IsSynced.value = 1
												AND IsDisabled.value = 1
											), 0) END AS BIT) AS IsDisabledDownline
			FROM #NewDisableStatTbl ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @MasterID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @MasterID
			WHERE (tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0) OR (tmp.IsDisabledDownline = 1 AND Otmp.IsDisabledDownline = 0 AND @HasDownlines = 1)
		END
		ELSE IF @RoleID = 2
		BEGIN			
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled, IsDisabledDownline)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled,
					CAST(CASE WHEN @HasDownlines = 0 THEN ISNULL(dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder),0)
								ELSE ISNULL((
											SELECT TOP 1 1
											FROM dbo.custInfo ci WITH (NOLOCK)
												INNER JOIN dbo.CustProductStatus cps_temp ON ci.custid = cps_temp.CustID
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapIsDisabled, PSP.bitmapOrder) AS IsDisabled
												OUTER APPLY dbo.f_CustSetting_ProductStatusSel(cps_temp.bitmapHasSynced, PSP.bitmapOrder) AS IsSynced
											WHERE recommend = @AgentID AND roleid = 1
												AND IsSynced.value = 1
												AND IsDisabled.value = 1
											), 0) END AS BIT) AS IsDisabledDownline
			FROM #NewDisableStatTbl ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @AgentID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTbl tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE (tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0) OR (tmp.IsDisabledDownline = 1 AND Otmp.IsDisabledDownline = 0 AND @HasDownlines = 1)
		END
	END

	--90012: You are not allowed to perform this action.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1 AND IsDisabledDownline = 0) AND @HasDownlines = 1
	BEGIN
		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
		SELECT tmp.SportType
			, tmp.BetType
			, 90012 AS MsgID
		FROM #NewDisableStatTbl tmp
		WHERE tmp.IsDisabled = 1 AND tmp.IsDisabledDownline = 0
	END
	--IF there's no error data then return
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM #ErrorSportTypeTbl
			)
		RETURN

	IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60033)
	BEGIN
		SET @xml = (
				SELECT 60033 AS '@MsgID'
					, 'Account disabled for this product. Unable to edit downlines.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 60033
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 101
		
		RETURN
	END
	ELSE IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60035)
	BEGIN
		SET @xml = (
				SELECT 60035 AS '@MsgID'
					, 'You are not allowed to disable for downlines.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 60035
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 102
		
		RETURN
	END
	ELSE IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 90012)
	BEGIN
		SET @xml = (
				SELECT 90012 AS '@MsgID'
					, 'You are not allowed to perform this action.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 90012
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 91
		SET @ErrCode = 103
		
		RETURN
	END
	DROP TABLE #ErrorSportTypeTbl
	DROP TABLE #NewDisableStatTbl
	
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusCheck] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusCheck] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_DisableNewProductStatusCheck] TO [bodbExtAccNet]