/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInsMember_WinlossLimitCheck_CashMember] 
	@recommend INT,
	@siteid SMALLINT =0,
	@currency SMALLINT =0,
	
	@GroupTypeT161 VARCHAR(MAX)= '',
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
		- @GroupTypeT161 :
				[
					{ "SportType":"9918"  , "BetType":"4601"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9906"  , "BetType":"4001"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }, 
					{ "SportType":"9911"  , "BetType":"2400"  , "MaxWinLimit":"20000"  , "IsAutoReset":"0" }

				]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @xml XML, @Credit MONEY
	DECLARE @UplineLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		MONEY		
			, IsAutoReset		BIT
			)

	DECLARE @NewLimitTbl TABLE (
			SportType			SMALLINT
			, BetType			SMALLINT
			, MaxWinLimit		MONEY 			
			, IsAutoReset		BIT
			)

	CREATE TABLE #ProductSettingDetail_WLCheck(
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
		[Child_DisplayOrder] [INT]
	)
	
	IF ISNULL(@GroupTypeT161,'') = ''
		RETURN
	
	SELECT	@ErrCode = 0, @MsgType = 0,	@ErrMsg	 = ''
	SELECT @Credit = ISNULL(Credit, 0) FROM dbo.CustInfo WITH (NOLOCK) WHERE CustID = @recommend

	INSERT INTO #ProductSettingDetail_WLCheck(SportType,BetType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,IsLive,ProductID,SettingLevel
	FROM dbo.f_CustSetting_ProductProfileCashSel(NULL,@SettingStatus,@siteid,@currency)
	WHERE GroupType = 161

	-- Parse Data Json
	INSERT @NewLimitTbl (SportType, BetType, MaxWinLimit, IsAutoReset)
	SELECT SportType, BetType, MaxWinLimit, IsAutoReset
	FROM OPENJSON(@GroupTypeT161)
	WITH (
			  SportType		SMALLINT
			, BetType		SMALLINT
			, MaxWinLimit	MONEY		
			, IsAutoReset	BIT
		) AS Limit

	--Get agent's bet limit
	INSERT INTO @UplineLimitTbl
	SELECT wl.SportType
		, wl.BetType
		, wl.MaxWinLimit * @Credit
		, wl.IsAutoReset
	FROM dbo.CustWinLossLimit_Agent wl WITH (NOLOCK)
		INNER JOIN @NewLimitTbl tmp ON tmp.SportType = wl.SportType AND tmp.BetType = wl.BetType
	WHERE wl.CustID	= @recommend		

	--Check Upline's win limit >= Win Limit
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
			)
	BEGIN
		SET @xml = (
				SELECT 10024 AS '@MsgID'
					, 'Maximum Win should be less than or equal to Maximum Win of Direct Upline!' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
							, psd.SettingLevel AS '@SettingLevel'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
							INNER JOIN #ProductSettingDetail_WLCheck psd ON uwl.SportType = psd.SportType AND uwl.BetType = psd.BetType
						WHERE uwl.MaxWinLimit > 0 AND (nwl.MaxWinLimit = 0 OR uwl.MaxWinLimit < nwl.MaxWinLimit)
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 111
		SET @ErrCode = 2

		RETURN
	END	

	--Check Upline's auto reset = 0 and auto reset = 1
	IF EXISTS(	SELECT TOP 1 1 
				FROM @UplineLimitTbl uwl
					INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
				WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
			)
	BEGIN
		SET @xml = (
				SELECT 10022 AS '@MsgID'
					, 'You are not allowed to change Daily auto reset limit.' AS '@Msg'
					, (
						SELECT uwl.SportType AS '@SportType'
							, uwl.BetType AS '@BetType'
							, psd.SettingLevel AS '@SettingLevel'
						FROM @UplineLimitTbl uwl
							INNER JOIN @NewLimitTbl nwl ON uwl.Sporttype = nwl.SportType AND uwl.Bettype = nwl.BetType
							INNER JOIN #ProductSettingDetail_WLCheck psd ON uwl.SportType = psd.SportType AND uwl.BetType = psd.BetType
						WHERE uwl.IsAutoReset = 0 AND nwl.IsAutoReset = 1
						FOR XML PATH('Row')
							, TYPE
						)
				FOR XML PATH('Root')
					, TYPE
				)		
		SET @ErrMsg = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')
		SET @MsgType = 113
		SET @ErrCode = 4

		RETURN	
	END

	DROP TABLE #ProductSettingDetail_WLCheck
END
GO
