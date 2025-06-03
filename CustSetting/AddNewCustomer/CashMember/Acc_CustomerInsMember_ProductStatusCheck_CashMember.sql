/*<info serverAlias="DBCust-CustDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustomerInsMember_ProductStatusCheck_CashMember
	@recommend INT,
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	@SystemID TINYINT = 1,
	
	@GroupTypeT160 VARCHAR(MAX)= '',
	@SettingStatus TINYINT = 0,

	@ErrCode INT = 0 OUTPUT,
	@MsgType INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20250509@Elodie	
	Task: Validate when Agent create cash member
	DB: DBCUST.CustDB
	
	Revisions:
		- 20250423@Elodie: Offer Cash Member [redmine: #223896] 

	Param's Explanation: 
		- @GroupTypeT160 :
			[
				{ "SportType":"9906" , "BetType":"4001" , "IsDisabled":"1" }, 
				{ "SportType":"9918" , "BetType":"4601" , "IsDisabled":"1" }, 
				{ "SportType":"9904" , "BetType":"4001" , "IsDisabled":"1" }, 
				{ "SportType":"9911" , "BetType":"2400" , "IsDisabled":"1" }
			]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #TblStatus
	(
			  SportType			SMALLINT
			, BetType			SMALLINT
			, IsDisabled		BIT
			, ParentSporttype		SMALLINT
			, ParentBetType		SMALLINT
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
	DECLARE @xml		XML

	SELECT @ErrCode = 0, @MsgType = 0, @ErrMsg	= ''

	IF ISNULL(@GroupTypeT160,'') = ''
		RETURN

	-- Parse Data Json
	INSERT INTO #TblStatus(SportType,BetType,IsDisabled)
	SELECT SportType, BetType, IsDisabled
	FROM OPENJSON(@GroupTypeT160) WITH (
		SportType			SMALLINT	
		, BetType			SMALLINT
		, IsDisabled			BIT
	) AS DisabledProductStatus

	CREATE TABLE #ProductSettingDetail_StatusCheck(
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

	INSERT INTO #ProductSettingDetail_StatusCheck(ProductID,SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel)
	SELECT ProductID,SportType,BetType,SettingType,IsLive,Parent_ProductSettingID,ProductSettingID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType = 160

	--Get error data
	--60033: Account disabled for this product. Unable to edit downlines.
	IF EXISTS (SELECT 1 FROM #TblStatus WHERE IsDisabled = 0)
	BEGIN
		INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID)
			SELECT PSP.SportType
				, psp.BetType
				, 60033 AS MsgID
			FROM #TblStatus tmp
				INNER JOIN dbo.ProductStatusProfile PSP WITH (NOLOCK) ON PSP.Sporttype = TMP.SportType AND PSP.Bettype = TMP.BetType
				INNER JOIN dbo.CustProductStatus stt WITH (NOLOCK) ON  stt.CustID	= @recommend
			WHERE dbo.f_GetProductStatus(stt.bitmapIsDisabled, PSP.bitmapOrder) = 1
				AND tmp.IsDisabled	= 0
	END

	IF EXISTS (SELECT TOP 1 1 FROM #ErrorSportTypeTbl)
	BEGIN
		GOTO RETURNTBL;
	END

	UPDATE t 
	SET t.ParentSporttype = par.SportType, t.ParentBetType = par.BetType
	FROM #TblStatus t
		INNER JOIN #ProductSettingDetail_StatusCheck d WITH(NOLOCK)  
			ON t.SportType = d.SportType and t.BetType = d.BetType AND d.SettingType = 21
		INNER JOIN #ProductSettingDetail_StatusCheck par WITH(NOLOCK) 
			ON d.Parent_ProductSettingID = par.ProductSettingID

	INSERT INTO #ErrorSportTypeTbl (SportType, BetType, MsgID,ParentSporttype,ParentBetType)
	SELECT TOP(1) t.SportType
			, t.BetType
			, 60037 AS MsgID
			, t.ParentSporttype
			, t.ParentBetType
	FROM #TblStatus t
		INNER JOIN #TblStatus par 
			ON t.ParentSporttype = par.SportType AND t.ParentBetType = par.BetType
	WHERE t.IsDisabled < par.IsDisabled

	IF @@ROWCOUNT > 0
	BEGIN
		GOTO RETURNTBL;
	END

	--END
	RETURNTBL:
	
	UPDATE t 
	SET t.SettingLevel = d.SettingLevel
	FROM #ErrorSportTypeTbl t
		INNER JOIN #ProductSettingDetail_StatusCheck d WITH(NOLOCK)  
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
	DROP TABLE #TblStatus
	DROP TABLE #ProductSettingDetail_StatusCheck
END

GO