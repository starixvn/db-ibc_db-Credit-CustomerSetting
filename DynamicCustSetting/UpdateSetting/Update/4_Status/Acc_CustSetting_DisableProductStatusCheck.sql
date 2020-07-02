/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbExtAccNet,bodbDownlineNet" viewers="" isFunction="0"></info>*/
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
		- 20200702@Winfred: Validate enabled status of a product saba [RedmineID:#136210]
	
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