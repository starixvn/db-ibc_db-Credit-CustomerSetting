/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/
USE CustDB
GO

ALTER PROCEDURE [dbo].[Acc_CustSetting_TicketCommissionUpd] 
	  @CustID				INT
	, @Commission			VARCHAR(MAX)
	, @SubAccID				INT				= 0
	, @UserID				INT
	, @IP					VARCHAR(50)		= ''
	, @ErrCode				INT				= 0		OUTPUT
	, @MsgType				INT				= 0		OUTPUT
	, @ErrMsg				NVARCHAR(MAX)	= ''	OUTPUT
	, @SettingType			INT
AS
/*
	Created: 20170424@Elodie
	Task : Update Customer's Ticket Commission
	DB: DBCUST/CustDB
	Original:

	Revisions:

	Param's Explanation:
		• @Commission:
			<ROOT>
					<Commission 
							SportType="160" 
							BetType="1601" 
							Commission="0.070"
					/>
			</ROOT>
		
		
	
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @iDoc INT
	
	DECLARE @startRun				DATETIME
		,	@endRun					DATETIME
		,	@duration				INT
		,	@CorrectedComm_XML	VARCHAR(MAX)
		
	DECLARE @logSpData		NVARCHAR(MAX)
		,	@logSpData_Old	NVARCHAR(MAX)
		,	@xml			XML
		
	DECLARE @AgentID		INT
		,	@MasterID		INT
		,	@SuperID		INT
		,	@RoleID			INT
		
		
	DECLARE @NewCommTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Commission	DECIMAL(9, 8)
		)
		
	DECLARE @OldCommTbl TABLE (
				SportType	SMALLINT
			,	BetType		SMALLINT
			,	Commission	DECIMAL(9, 8)
		)

	DECLARE @ProductID		TINYINT,
			@ProductName	VARCHAR(50),
			@SettingLevel	TINYINT

	--Check if XML is null or empty
	IF @Commission IS NULL
		OR @Commission = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	SET @startRun = GETDATE()

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
										@custid		= @custid
									,	@ErrCode	= @ErrCode OUTPUT
									,	@ErrMsg		= @ErrMsg OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END
	
	--Check belonging
	EXEC dbo.Age_CustomerSelCheckBelonging 
		@SessionCustID	= @Userid 
		,@Custid		= @custid		
		,@roleid		= @roleid OUTPUT
	IF (@roleid = 0)
	BEGIN
		SET @MsgType = 101
		SET @ErrCode = 101
		SET @ErrMsg = 'Users are not in the same line!'
		RETURN
	END

	--Get line information
	SELECT @AgentID = recommend
		, @MasterID = mrecommend
		, @SuperID = srecommend
		, @RoleID = RoleID
	FROM dbo.custInfo WITH (NOLOCK)
	WHERE custid = @CustID

	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
												@custid		= @custid
											,	@roleid		= @roleid
											,	@isExecRep	= 1
											,	@Language	= 'E'
											,	@ErrCode	= @ErrCode	OUTPUT
											,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	--Parse XML
	EXEC sp_xml_preparedocument @iDoc OUTPUT
		, @Commission

	INSERT @NewCommTbl
	SELECT SportType
		, BetType
		, CAST(Commission AS DECIMAL(9, 8)) AS Commission
	FROM OPENXML(@iDoc, '/ROOT/Commission', 1) WITH (
			SportType SMALLINT
			, BetType SMALLINT
			, Commission VARCHAR(15)
			)

	EXEC sp_xml_removedocument @iDoc

	EXEC [dbo].[Acc_CustSetting_TicketCommissionCheck] 
						@CustID				= @CustID
						, @RoleID			= @RoleID
						, @AgentID			= @AgentID
						, @MasterID			= @MasterID
						, @SuperID			= @SuperID
						, @Commission		= @Commission
						, @ErrCode			= @ErrCode	OUTPUT
						, @MsgType			= @MsgType  OUTPUT
						, @ErrMsg			= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	--Get old comm
	IF @RoleID IN (2, 3, 4)
	BEGIN
		INSERT INTO @OldCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.Discount
		FROM @NewCommTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @OldCommTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM @NewCommTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END

	IF @RoleID = 3
	BEGIN
		--Update NEW_Commission = MIN( @NEW_Commission, super_Commission)
		UPDATE tmp
		SET tmp.Commission = CASE 
				WHEN tmp.Commission < dcs.Discount
					THEN tmp.Commission
				ELSE dcs.Discount
				END
		FROM @NewCommTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH (NOLOCK)
			ON tmp.SportType	= dcs.SportType
				AND tmp.BetType = dcs.BetType
				AND dcs.custid	= @SuperID
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Update NEW_Commission = MIN( @NEW_Commission, master_Commission)
		UPDATE tmp
		SET tmp.Commission = CASE 
				WHEN tmp.Commission < dcm.Discount
					THEN tmp.Commission
				ELSE dcm.Discount
				END
		FROM @NewCommTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH (NOLOCK)
			ON tmp.SportType	= dcm.SportType
				AND tmp.BetType = dcm.BetType
				AND dcm.custid	= @MasterID
	END
	ELSE IF @RoleID = 1 AND @SettingType = 3
	BEGIN
		--Update NEW_Commission = MIN( @NEW_Commission, agent_Commission)
		UPDATE tmp
		SET tmp.Commission = CASE 
				WHEN tmp.Commission < dca.Discount
					THEN tmp.Commission
				ELSE dca.Discount
				END
		FROM @NewCommTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH (NOLOCK)
			ON dca.SportType	= tmp.SportType
				AND dca.BetType = tmp.BetType
				AND dca.custid	= @AgentID
	END

	--Return XML result
	SELECT @CorrectedDiscount_XML = (
			SELECT *
			FROM @NewCommTbl
			FOR XML RAW('Commission')
			)

	SELECT @CorrectedDiscount_XML = '<ROOT>' + @CorrectedDiscount_XML + '</ROOT>'

	--execrept to update commission
	EXEC dbo.Acc_DynamicCustSetting3rd_06
			@CustId			= @custid
			, @RoleId		= @RoleId
			, @SettingType  = @SettingType
			, @Commission_XML = @CorrectedDiscount_XML
			

	--START LOGGING		

	-- Select ProductID and SettingLevel
	SELECT @ProductID = ProductID, @SettingLevel = SettingLevel
	FROM (	SELECT TOP 1 psd.ProductID, psd.SettingLevel
			FROM		ProductSettingDetail AS psd WITH(NOLOCK)
			INNER JOIN	@NewCommTbl AS tmp
					ON	psd.SportType = tmp.SportType
					AND	psd.BetType = tmp.BetType
			WHERE	psd.ProductID IS NOT NULL
				AND	psd.SettingLevel IS NOT NULL
				AND psd.SettingType = @SettingType	-- Discount
		 ) iq

	-- Select ProductName
	SELECT @ProductName = p.ProductName
	FROM DBPRO.bodb02.dbo.Products AS p WITH(NOLOCK)
	WHERE p.ProductID = @ProductID

	-- Log old value
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	@ProductID			AS '@ProductID',
							Commission			AS '@Commission'
					FROM	@OldCommTbl
					FOR XML PATH('Commission'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType			AS '@SportType',
							Commission			AS '@Commission'
					FROM	@OldCommTbl
					FOR XML PATH('Commission'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	BetType				AS '@BetType',
							Commission			AS '@Commission'
					FROM	@OldCommTbl
					FOR XML PATH('Commission'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
					SELECT	SportType			AS '@SportType',
							BetType				AS '@BetType',
							Commission			AS '@Commission'
					FROM	@OldCommTbl
					FOR XML PATH('Commission'),
					TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated value
	IF @SettingLevel = 1			-- Product setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
				SELECT	@ProductID				AS '@ProductID',
						Commission				AS '@Commission'
				FROM	@NewCommTbl
				FOR XML PATH('Commission'),
				TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 2		-- SportType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
				SELECT	SportType				AS '@SportType',
						Commission				AS '@Commission'
				FROM	@NewCommTbl
				FOR XML PATH('Commission'),
				TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 3		-- BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
				SELECT	BetType					AS '@BetType',
						Commission				AS '@Commission'
				FROM	@NewCommTbl
				FOR XML PATH('Commission'),
				TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	ELSE IF @SettingLevel = 4		-- SportType BetType setting level
	BEGIN
		SET @xml = (
		SELECT	@ProductID						AS '@ProductID',
				@ProductName					AS '@ProductName',
				@CustID							AS '@CustID',
				@SettingType					AS '@SettingType',
				@UserID							AS '@UserID',
				dbo.f_GetSubUsername(@SubAccID) AS '@SubAccName',
				@IP								AS '@IP',
				(
				SELECT	SportType				AS '@SportType',
						BetType					AS '@BetType',
						Commission				AS '@Commission'
				FROM	@NewCommTbl
				FOR XML PATH('Commission'),
				TYPE
				)
		FOR XML PATH('Acc_CustSetting_TicketCommissionUpd'),
		TYPE
	)
	END
	SET @logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	BEGIN TRY
		EXEC DBLOG.bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID				= @UserID
			, @CustID			= @CustID
			, @ActionID			= 250
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH
		EXEC bodb_CustomerLog.dbo.WriteLog_UserLog_RunSP 
			@UserID				= @UserID
			, @CustID			= @CustID
			, @ActionID			= 250
			, @TrackingValue	= @logSpData
			, @TrackingValue2	= @logSpData_Old
			, @duration			= @duration
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_TicketCommissionUpd] TO [bodbadminNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_TicketCommissionUpd] TO [bodbDownlineNet]
GO
GRANT EXECUTE ON [dbo].[Acc_CustSetting_TicketCommissionUpd] TO [bodbExtAccNet]
GO
GRANT VIEW DEFINITION ON [dbo].[Acc_CustSetting_TicketCommissionUpd] TO [vnteam]