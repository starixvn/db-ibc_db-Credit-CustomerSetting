/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/
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

	Revision: 
		- 20170307@Elodie: Apply New Direction of enabling status for 3rd party products [RedmineID: #72336]
		- 20170613@Elodie: Change logic to get HasDownlines and IsDisableDownline value [RedmineID:#78225]
		- 20180112@Elodie: Remove IsDisableDownline value [RedmineID:#87328]
		- 20200914@Eden: Minimize UM Time - Lock updating customer settings [#136464]

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"						
				/>
		</ROOT>
	• @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #NewDisableStatTblCheck
	(
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsDisabled		BIT
	)
	CREATE TABLE #OldDisableStatTbl 
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
	)
	CREATE TABLE #ErrorSportTypeTbl
	(
			SportType	SMALLINT
			, BetType	SMALLINT
			, MsgID		INT
	)
	DECLARE @xml XML, @iDoc INT

	SELECT @ErrCode = 0
		, @ErrMsg	= ''

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @IsDisabled

	INSERT INTO #NewDisableStatTblCheck
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			)

	EXEC sp_xml_removedocument @iDoc

	DECLARE @custID INT 
	IF @RoleID = 4
		SET @custID = @SuperID
	IF @RoleID = 3
		SET @custID = @MasterID
	IF @RoleID = 2
		SET @custID = @AgentID

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #NewDisableStatTblCheck t
		INNER JOIN dbo.ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 13
		AND u.FunctionType = 1 --Edit Customer

	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 0)
	BEGIN
	
		IF @RoleID = 3
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
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
			FROM #NewDisableStatTblCheck tmp
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
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
		END
	END

	--60035: You are not allowed to disable for downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 1) AND @SystemID = 2
	BEGIN
		IF @RoleID = 4
		BEGIN
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled
			FROM #NewDisableStatTblCheck ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @SuperID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0
		END
		ELSE IF @RoleID = 3
		BEGIN
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled					
			FROM #NewDisableStatTblCheck ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @MasterID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @MasterID
			WHERE tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0
		END
		ELSE IF @RoleID = 2
		BEGIN			
			INSERT INTO #OldDisableStatTbl(SportType, BetType, IsDisabled)
			SELECT	ft.SportType,
					ft.BetType,
					(SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) as isDisabled					
			FROM #NewDisableStatTblCheck ft 
				INNER JOIN ProductStatusProfile psp WITH (NOLOCK) ON PSP.Bettype = ft.BetType AND PSP.Sporttype = ft.SportType															
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK)	ON stt.CustID = @AgentID

			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60035 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN #OldDisableStatTbl Otmp ON Otmp.SportType = tmp.SportType AND Otmp.BetType = tmp.BetType
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE tmp.IsDisabled = 1 AND Otmp.IsDisabled = 0
		END
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
	DROP TABLE #ErrorSportTypeTbl
	DROP TABLE #NewDisableStatTblCheck
	
END
GO