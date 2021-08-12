/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_MaxPayoutUpd] 
	  @CustID		INT
	, @MaxPayoutLimit VARCHAR(MAX)
	, @Language VARCHAR(2)= 'E'
	, @SubAccID		INT				= 0
	, @UserID		INT
	, @IP			VARCHAR(50)		= ''
	, @ErrCode		INT				= 0		OUTPUT
	, @ErrMsg		NVARCHAR(MAX)	= ''	OUTPUT
AS
/*
	Created: 20210518@Winfred
	Task : Update Customer's Parlay Max Payout
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20210518@Winfred: Initial SP  [RedmineID:#154104]

	Param's Explanation:
	• @@MaxPayoutLimit:
		'<ROOT>				<MaxPayoutLimit 						SportType="1" 						BetType="1" 						SingleMatchParlay="3000" 						Combo2="40000" 						Combo35="6000000"						ComboOver6="1000000"				/>		</ROOT>'

	*/
BEGIN
	SET NOCOUNT ON
	DECLARE @LogAction TABLE (ActionID INT, IsFinished BIT DEFAULT (0))
	DECLARE @startRun	DATETIME
		, @endRun		DATETIME
		, @duration		INT
		, @ActionID			INT
		
	DECLARE @logSpData		NVARCHAR(MAX)
		, @logSpData_Old	NVARCHAR(MAX)
		,@logSpData_Indirectly	NVARCHAR(MAX)
		, @logSpData_Old_Indirectly	NVARCHAR(MAX)
		, @xml				XML
		,@UserName		NVARCHAR(50)
		
	DECLARE @AgentID		INT
		, @MasterID			INT
		, @SuperID			INT
		, @RoleID			INT
		
	DECLARE @OldMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)
	DECLARE @NewMaxPayoutTbl TABLE (
		SportType			SMALLINT
		, BetType			SMALLINT
		, SingleMatchParlay	MONEY
		, Combo2			MONEY
		, Combo35			MONEY
		, ComboOver6		MONEY
		)

	--Check if XML is null or empty
	IF @MaxPayoutLimit IS NULL
		OR @MaxPayoutLimit = ''
		RETURN

	SET @startRun = GETDATE()
	SELECT	@ErrCode	= 0	,	@ErrMsg			= ''

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @ErrCode = 101
		RETURN
	END

	--> Check UM config
	EXEC [Acc_CheckUM] @CustID = @CustID, @ProductID = 1
		, @Language = @Language, @FunctionType = 1
		, @ErrCode = @ErrCode OUTPUT, @ErrMsg = @ErrMsg OUTPUT 
		, @ReturnUMData = 0
		
	IF @ErrCode <>0 
		RETURN

	SET @ErrCode = ''

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		,@UserName = username
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Check belonging
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0)
	BEGIN
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END
	
	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
												@custid		= @custid
											,	@roleid		= @roleid
											,	@isExecRep	= 1
											,	@Language	= @Language
											,	@ErrCode	= @ErrCode	OUTPUT
											,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		RETURN
	END

	--Parse XML	
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @MaxPayoutLimit

	INSERT @NewMaxPayoutTbl (SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
	SELECT SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6
	FROM OPENXML(@iDoc, '/ROOT/MaxPayoutLimit', 1) WITH (
			SportType			SMALLINT
			, BetType			SMALLINT
			, SingleMatchParlay	MONEY
			, Combo2			MONEY
			, Combo35			MONEY
			, ComboOver6		MONEY
			)

	EXEC sp_xml_removedocument @iDoc

	IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END
	
	--Validate new Max Payout settings
	EXEC [dbo].[Acc_CustSetting_MaxPayoutCheck] @CustID	= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @MaxPayoutLimit	= @MaxPayoutLimit
						, @Language	= @Language
						, @ErrCode		= @ErrCode	OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	IF @RoleID = 1
	BEGIN
		--get old settings
		INSERT INTO @OldMaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, bl.SingleMatchParlay
			, bl.Combo2
			, bl.Combo35
			, bl.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Member bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID AND ( bl.Combo2 <> tmp.Combo2 OR bl.Combo35 <> tmp.Combo35 
		OR bl.SingleMatchParlay <> tmp.SingleMatchParlay OR bl.ComboOver6 <> tmp.ComboOver6)
		
		DELETE a FROM @NewMaxPayoutTbl a 
		WHERE NOT EXISTS( SELECT 1 FROM @OldMaxPayoutTbl WHERE SportType = a.SportType  AND BetType = a.BetType)

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END  
	 
		--update new settings
		UPDATE main
		SET main.SingleMatchParlay	 = tmp.SingleMatchParlay
			, main.Combo2		= tmp.Combo2
			, main.Combo35	= tmp.Combo35
			, main.ComboOver6	= tmp.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Member main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.SingleMatchParlay		<> tmp.SingleMatchParlay
				OR main.Combo2		<> tmp.Combo2
				OR main.Combo35 <> tmp.Combo35
				OR main.ComboOver6 <> tmp.ComboOver6
				)
	END
	ELSE IF @RoleID IN (2, 3, 4)
	BEGIN
		--get old settings
		INSERT INTO @OldMaxPayoutTbl(SportType,BetType,SingleMatchParlay,Combo2,Combo35,ComboOver6)
		SELECT bl.SportType
			, bl.BetType
			, bl.SingleMatchParlay
			, bl.Combo2
			, bl.Combo35
			, bl.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Agent bl WITH (NOLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= bl.sporttype
				AND tmp.BetType = bl.bettype
		WHERE bl.custid = @CustID AND ( bl.Combo2 <> tmp.Combo2 OR bl.Combo35 <> tmp.Combo35 
		OR bl.SingleMatchParlay <> tmp.SingleMatchParlay OR bl.ComboOver6 <> tmp.ComboOver6)
		
		DELETE a FROM @NewMaxPayoutTbl a 
		WHERE NOT EXISTS( SELECT 1 FROM @OldMaxPayoutTbl WHERE SportType = a.SportType  AND BetType = a.BetType)

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END  

		IF NOT EXISTS( SELECT 1 FROM @NewMaxPayoutTbl)  
		BEGIN
		  RETURN  
		END 
		
		--update new settings
		UPDATE main
		SET main.SingleMatchParlay	 = tmp.SingleMatchParlay
			, main.Combo2		= tmp.Combo2
			, main.Combo35	= tmp.Combo35
			, main.ComboOver6	= tmp.ComboOver6
		FROM dbo.CustMaxPayoutSetting_Agent main WITH(ROWLOCK,UPDLOCK)
		INNER JOIN @NewMaxPayoutTbl tmp
			ON tmp.SportType	= main.sporttype
				AND tmp.BetType = main.bettype
		WHERE main.custid = @CustID
			AND (
					main.SingleMatchParlay		<> tmp.SingleMatchParlay
				OR main.Combo2		<> tmp.Combo2
				OR main.Combo35 <> tmp.Combo35
				OR main.ComboOver6 <> tmp.ComboOver6
				)
		-- update Downline
		EXEC dbo.Acc_CustSetting_12
			@CustId = @CustId
			,@RoleId = @RoleId
			,@XML = @MaxPayoutLimit
			,@Mode='MaxPayout'
	END
	

	--START LOGGING
	DECLARE @SPName varchar(100) = 'Acc_CustSetting_MaxPayoutUpd'

	SELECT @SPName = LogStr 
	FROM f_CustSetting_FormatLog (@SPName)
	
	INSERT INTO @LogAction (ActionID)
	SELECT l.ActionID
	FROM DBLOG.bodb_CustomerLog.dbo.LogAction l WITH (NOLOCK)
		INNER JOIN DBLOG.bodb_CustomerLog.dbo.LogActionDetail ld WITH (NOLOCK) ON ld.ActionID = l.ActionID	
	WHERE l.SPName = @SPName AND ld.ProductID = 1 AND ld.Level = @RoleID
	
	-- Log old data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@UserName						AS '@SourceAccount',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CASE WHEN SingleMatchParlay = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), SingleMatchParlay) AS VARCHAR(20))  END AS '@SingleMatchParlay',
							CASE WHEN Combo2 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo2) AS VARCHAR(20))  END AS '@Combo2',
							CASE WHEN Combo35 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo35) AS VARCHAR(20))	 END AS '@Combo35',
							CASE WHEN ComboOver6 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), ComboOver6) AS VARCHAR(20))	 END AS '@ComboOver6'
					FROM @OldMaxPayoutTbl
					FOR XML PATH('MaxPayoutLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_MaxPayoutUpd'),
		TYPE )
	
	SET @logSpData_Old_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	---- Log new updated data
	SET @xml = (
		SELECT	@CustID							AS '@CustID',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@UserName						AS '@SourceAccount',
				@IP								AS '@IP',
				(
					SELECT	SportType							AS '@SportType',
							BetType								AS '@BetType',
							CASE WHEN SingleMatchParlay = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), SingleMatchParlay) AS VARCHAR(20)) END AS '@SingleMatchParlay',
							CASE WHEN Combo2 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo2) AS VARCHAR(20))	 END AS '@Combo2',
							CASE WHEN Combo35 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), Combo35) AS VARCHAR(20)) END AS '@Combo35',
							CASE WHEN ComboOver6 = 0 THEN 'Unlimited' ELSE CAST(CONVERT(DECIMAL(20,2), ComboOver6) AS VARCHAR(20))  END AS '@ComboOver6'
					FROM @NewMaxPayoutTbl
					FOR XML PATH('MaxPayoutLimit'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_MaxPayoutUpd'),
		TYPE )
	SET @logSpData_Indirectly = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old_Indirectly = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old_Indirectly)
	SELECT @logSpData_Indirectly = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Indirectly)

	SET @logSpData = REPLACE(@logSpData_Indirectly, 'SourceAccount="'+ @UserName +'"', '')
	SET @logSpData_Old = REPLACE(@logSpData_Old_Indirectly, 'SourceAccount="'+ @UserName +'"', '')

	SELECT @endRun = GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	WHILE (1=1)
	BEGIN
		UPDATE TOP (1) @LogAction
		SET IsFinished = 1, @ActionID = ActionID
		WHERE IsFinished = 0

		IF @@ROWCOUNT = 0 BREAK
		
		IF @ActionID NOT IN (220001,220003,220005)
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @LogSPData,
				@TrackingValue2 = @logSPData_Old,
				@duration = @duration	
		END
		ELSE
		BEGIN
			EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
				@UserID = @UserID,
				@CustID = @CustID,
				@ActionID = @ActionID,
				@TrackingValue = @logSpData_Indirectly,
				@TrackingValue2 = @logSpData_Old_Indirectly,
				@duration = @duration	
		END
		
		
	END

END
GO
