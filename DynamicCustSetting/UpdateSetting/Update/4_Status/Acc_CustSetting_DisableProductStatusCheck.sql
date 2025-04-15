/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_xnap,wsv_alp" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_DisableProductStatusCheck] 
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
	Created:  20200702@Winfred
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:
	
	Revision:
		- 20200702@Winfred: Validate enabled status of Cust when SettingType = 4 (ProductStatus) [RedmineID:#136210]
		- 20200914@Eden: Minimize UM Time - Lock updating customer settings [#136464]
		- 20241219@Johnson: Change to use ProductSettingProfile [RedmineID: #212684]
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969] 
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

	DELETE t
	FROM #NewDisableStatTblCheck t
		INNER JOIN dbo.ProductSettingProfile ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 4
		AND u.FunctionType = 1 --Edit Customer

	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 0)
	BEGIN
	
		IF (@RoleID = 3) OR (@RoleID = 1 AND @AgentID = -4)				-- Master or SuperDirectMember : Collect Upline Super
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @SuperID
			WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
				AND tmp.IsDisabled	= 0
		END
		ELSE IF (@RoleID = 2) OR (@RoleID = 1 AND @AgentID = -3)	-- Agent or MasterDirectMember : Collect Upline Super, Master
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @MasterID
			WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
				AND tmp.IsDisabled	= 0
				
		END
		ELSE IF @RoleID = 1 AND @AgentID NOT IN (-4,-3) --Normal member : Collect Upline Super, Master, Agent
		BEGIN
			INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #NewDisableStatTblCheck tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @AgentID
			WHERE (SELECT value FROM dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled, PSP.bitmapOrder)) = 1
				AND tmp.IsDisabled	= 0
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
	DROP TABLE #ErrorSportTypeTbl
	DROP TABLE #NewDisableStatTblCheck
END
GO