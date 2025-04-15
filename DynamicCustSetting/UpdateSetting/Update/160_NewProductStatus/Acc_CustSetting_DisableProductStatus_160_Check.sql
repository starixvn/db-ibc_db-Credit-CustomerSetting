/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
CREATE PROCEDURE dbo.Acc_CustSetting_DisableProductStatus_160_Check
	  @CustID			INT				
	, @RoleID			INT
	, @AgentID			INT
	, @MasterID			INT
	, @SuperID			INT
	, @IsDisabled		VARCHAR(MAX)
	, @SystemID			TINYINT	
	, @GroupID			TINYINT			= 3
	, @GroupType		TINYINT			= 160
	, @SettingStatus		TINYINT			= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(MAX)		= ''		OUTPUT
AS
/*
	Created: 20240216@Helios
	Task : Validate enabled status product Live & RNG Casino
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DisableNewProductStatusCheck

	Revision: 
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 
		- 20241107@Helios: Offer Direct Member for Super/Master [redmine: #211969]
	Param's Explanation:
	- @IsDisabled
		'[
			{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
			{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
			{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
			{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
		]'
	• @SystemID: 1 = NAP, 2 = ALPHA, 4 = EXT
	*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #NewDisableStatTblCheck
	(
			  SportType			SMALLINT
			, BetType			SMALLINT
			, IsDisabled		BIT
			, ParentSporttype		SMALLINT
			, ParentBetType		SMALLINT
	)
	CREATE TABLE #OldDisableStatTbl 
	(
			SportType			SMALLINT
			, BetType			SMALLINT
			, IsDisabled		BIT
	)
	CREATE TABLE #ErrorSportTypeTbl
	(
			  SportType			SMALLINT
			, BetType			SMALLINT
			, MsgID			INT
			, ParentSporttype		SMALLINT
			, ParentBetType		SMALLINT
			, SettingLevel		TINYINT
	)
	DECLARE 
		@xml		XML, 
		@iDoc		INT, 
		@SiteID	INT,
		@Currency	SMALLINT

	SELECT @ErrCode = 0
		, @ErrMsg	= ''


	-- Parse Data Json
	INSERT INTO #NewDisableStatTblCheck(SportType,BetType,IsDisabled)
	SELECT SportType, BetType, IsDisabled
	FROM OPENJSON(@IsDisabled)
	WITH 
		(
			SportType			SMALLINT	
		    , BetType			SMALLINT
		    , IsDisabled			BIT
		) AS DisabledProductStatus

	IF @RoleID = 4
		SET @custID = @SuperID
	IF @RoleID = 3
		SET @custID = @MasterID
	IF @RoleID = 2
		SET @custID = @AgentID

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		, @currency = currency
		, @siteid   = s.siteid
	FROM dbo.Customer  c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE custid = @CustID

	CREATE TABLE #ProductSettingDetail_Check(
		[ProductID] [int],
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[Parent_ProductSettingID] [int],
		[ProductSettingID] [int],
		[SettingLevel] [TINYINT],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	INSERT INTO #ProductSettingDetail_Check(ProductID,SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel)
	SELECT ProductID,SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	--Exclude Update for Sport is having UM
	DELETE t
	FROM #NewDisableStatTblCheck t
		INNER JOIN #ProductSettingDetail_Check ps
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE u.FunctionType = 1 --Edit Customer

	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #NewDisableStatTblCheck WHERE IsDisabled = 0)
	BEGIN
	
		IF (@RoleID = 3) OR (@RoleID = 1 AND @AgentID = -4)	-- Master or SuperDirectMember : Collect Upline Super
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
		ELSE IF (@RoleID = 2) OR (@RoleID = 1 AND @AgentID = -3)	-- Agent or MasterDirectMember : Collect Upline Super, Master
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
		ELSE IF @RoleID = 1 AND @AgentID NOT IN (-4,-3) --Normal member : Collect Upline Super, Master, Agent
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
	IF EXISTS (
			SELECT TOP 1 1
			FROM #ErrorSportTypeTbl
			)
	BEGIN
		GOTO RETURNTBL;
	END
	
	--IF @Settingtype = 21 -- Check status dependency
	--BEGIN

	UPDATE t 
	SET t.ParentSporttype = par.SportType, t.ParentBetType = par.BetType
	FROM #NewDisableStatTblCheck t
		INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
			ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
		INNER JOIN #ProductSettingDetail_Check par WITH(NOLOCK) 
			ON d.Parent_ProductSettingID = par.ProductSettingID

	INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
	SELECT TOP(1) t.SportType
			, t.BetType
			, 60037 AS MsgID
			, t.ParentSporttype
			, t.ParentBetType
	FROM #NewDisableStatTblCheck t
		LEFT JOIN #NewDisableStatTblCheck par 
			ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType
		INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
			ON p.Sporttype = t.ParentSporttype AND p.Bettype = t.ParentBetType
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = @custID
		CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
	WHERE t.IsDisabled < ISNULL(par.IsDisabled,s.value)

	IF @@ROWCOUNT > 0
	BEGIN
		GOTO RETURNTBL;
	END

	INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
	SELECT TOP(1) de.SportType
			, de.BetType
			, 60037 AS MsgID
			, t.Sporttype AS ParentSporttype
			, t.BetType AS ParentBetType
	FROM #NewDisableStatTblCheck t
		INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
			ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
		INNER JOIN #ProductSettingDetail_Check de WITH(NOLOCK) 
			ON d.ProductSettingID = de.Parent_ProductSettingID 
		LEFT JOIN #NewDisableStatTblCheck tempde --Check exists depended Sport on input
			ON de.SportType = tempde.SportType AND de.BetType = tempde.BetType
		INNER JOIN ProductStatusProfile p WITH(NOLOCK) 
			ON p.Sporttype = de.SportType AND p.Bettype = de.BetType
		INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID = @custID
		CROSS APPLY dbo.f_CustSetting_ProductStatusSel(stt.bitmapIsDisabled,p.bitmapOrder) s
	WHERE tempde.SportType IS NULL 
		AND t.IsDisabled > s.value

	IF @@ROWCOUNT > 0
	BEGIN
		GOTO RETURNTBL;
	END

	--END
	RETURNTBL:
	
	UPDATE t 
	SET t.SettingLevel = d.SettingLevel
	FROM #ErrorSportTypeTbl t
		INNER JOIN #ProductSettingDetail_Check d WITH(NOLOCK)  
			ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21

	IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60033)
	BEGIN
		SET @xml = (
				SELECT 60033 AS '@MsgID'
					, 'Account disabled for this product. Unable to edit downlines.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
							, SettingLevel AS '@SettingLevel'
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
							, SettingLevel AS '@SettingLevel'
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
	ELSE IF EXISTS(SELECT TOP 1 1 FROM #ErrorSportTypeTbl WHERE MsgID = 60037)
	BEGIN
		SET @xml = (
				SELECT 60037 AS '@MsgID'
					, 'You cannot Enable {ChildSport} when {ParentSport} is Disabled.' AS '@Msg'
					, (
						SELECT SportType AS '@SportType'
							, BetType AS '@BetType'
							, ParentSportType AS '@ParentSportType'
							, ParentBetType AS '@ParentBetType'
							, SettingLevel AS '@SettingLevel'
						FROM #ErrorSportTypeTbl
						WHERE MsgID = 60037
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 92
		SET @ErrCode = 103
		
		RETURN
	END
	DROP TABLE #ErrorSportTypeTbl
	DROP TABLE #NewDisableStatTblCheck
	DROP TABLE #OldDisableStatTbl
	DROP TABLE #ProductSettingDetail_Check
END

GO