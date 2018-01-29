/*<info serverAlias="DBCust-CustDB" executers="bodbadminNet,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
USE CustDB
GO

CREATE PROCEDURE [dbo].[Acc_Admin_DisableNewProductStatusCheck] 
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
	Created: 20180118@ELodie
	Task : Validate enabled status
	DB: DBCUST/CustDB
	Original:

	Revision: 
		- 20180118@Elodie: Validate enable status on NAP & ExtNAP [RedmineID:#87328]

	Param's Explanation:
	• @IsDisabled
		<ROOT>
				<ProductStatus
						SportType="1" 
						BetType="1" 
						IsDisabled="1"			
						UpdateAllMasters="1"					
						UpdateAllAgents="1"
						UpdateAllMembers="1"
						DisableAllMasters="0"
						DisableAllAgents="0"
						DisableAllMembers="0"			
				/>
		</ROOT>
	• @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #NewDisableStatTbl 
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents		BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
	)
	CREATE TABLE #OldDisableStatTbl 
	(
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents		BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT			
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

	INSERT INTO #NewDisableStatTbl
	SELECT *
	FROM OPENXML(@iDoc, '/ROOT/ProductStatus', 1) WITH (
			SportType				SMALLINT
			, BetType				SMALLINT
			, IsDisabled			BIT
			, UpdateAllMasters		BIT
			, UpdateAllAgents		BIT
			, UpdateAllMembers		BIT
			, DisableAllMasters		BIT
			, DisableAllAgents		BIT
			, DisableAllMembers		BIT
			)

	EXEC sp_xml_removedocument @iDoc

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

	--90012: You are not allowed to perform this action.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE IsDisabled = 1 AND ((UpdateAllMasters = 1 AND DisableAllMasters = 0) OR (UpdateAllAgents = 1 AND DisableAllAgents = 0) OR (UpdateAllMembers = 1 AND DisableAllMembers = 0)))
		OR EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE UpdateAllMasters = 1 AND DisableAllMasters = 1 AND ((UpdateAllAgents = 1 AND DisableAllAgents = 0) OR (UpdateAllMembers = 1 AND DisableAllMembers = 0)))
		OR EXISTS (SELECT 1 FROM #NewDisableStatTbl WHERE UpdateAllAgents = 1 AND DisableAllAgents = 1 AND UpdateAllMembers = 1 AND DisableAllMembers = 0)
	BEGIN
		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
		SELECT tmp.SportType
			, tmp.BetType
			, 90012 AS MsgID
		FROM #NewDisableStatTbl tmp
		WHERE (IsDisabled = 1 AND ((UpdateAllMasters = 1 AND DisableAllMasters = 0) OR (UpdateAllAgents = 1 AND DisableAllAgents = 0) OR (UpdateAllMembers = 1 AND DisableAllMembers = 0)))
			OR (UpdateAllMasters = 1 AND DisableAllMasters = 1 AND ((UpdateAllAgents = 1 AND DisableAllAgents = 0) OR (UpdateAllMembers = 1 AND DisableAllMembers = 0)))
			OR (UpdateAllAgents = 1 AND DisableAllAgents = 1 AND UpdateAllMembers = 1 AND DisableAllMembers = 0)
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