/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [dbo].[Acc_CustSetting_Discount_156_Upd] 
	  @CustID			INT
	, @Discount			VARCHAR(MAX)
	, @SubAccID			INT				= 0
	, @UserID			INT
	, @IP				VARCHAR(50)			= ''
	, @isSearchAndCopy	BIT				= 0
	, @GroupID			TINYINT			= 3
	, @GroupType		TINYINT			= 156 
	, @SettingStatus		TINYINT			= 0
	, @ErrCode			INT				= 0		OUTPUT
	, @MsgType			INT				= 0		OUTPUT
	, @ErrMsg			NVARCHAR(200)		= ''		OUTPUT
AS
/*
	Created: 20141111@Dominic
	Task : Update Customer's Discount
	DB: DBCUST/CustDB
	Original: Acc_CustSetting_DiscountUpd

	Revisions:
		- 20240216@Helios: Unify Live RNG Casino [Redmine: #198960] 

	Param's Explanation:
		- @Discount:
				'[
					{ "SportType":"9911"  , "BetType":"2400"  , "Discount":"0.0025" }, 
					{ "SportType":"242"  , "BetType":"3201"  , "Discount":"0.0025" }
				]'
		
		• @SettingType: 3 - Given Comm
						5 - Charge Comm
	
	*/
BEGIN
	SET NOCOUNT ON

	DECLARE @iDoc INT
	
	DECLARE    @startRun				DATETIME
		,	@endRun				DATETIME
		,	@duration				INT
		,	@CorrectedDiscount_XML		VARCHAR(MAX)
		
		
	DECLARE     @logSpData				NVARCHAR(MAX)
		,	@logSpData_Old			NVARCHAR(MAX)
		,	@xml					XML
		
	DECLARE     @AgentID				INT
		,	@MasterID				INT
		,	@SuperID				INT
		,	@RoleID				INT
		,	@SiteID				SMALLINT
		,	@Currency				TINYINT
		,	@SettingType			SMALLINT
		
		
	DECLARE @NewDiscountTbl TABLE (
				SportType		SMALLINT
			,	BetType		SMALLINT
			,	Discount		DECIMAL(9, 8)
		)
		
	DECLARE @oldDiscountTbl TABLE (
				SportType		SMALLINT
			,	BetType		SMALLINT
			,	Discount		DECIMAL(9, 8)
		)

	CREATE TABLE #ProductSettingDetail(
		[SettingType] [smallint],
		[SportType] [smallint],
		[BetType] [smallint],
		[IsLive] [bit] ,
		[ProductID] [tinyint],
		[SettingLevel] [tinyint],
	PRIMARY KEY([SettingType] ASC,[SportType] ASC,[BetType] ASC,[IsLive] ASC)
	)

	--Check if XML is null or empty
	IF @Discount IS NULL
		OR @Discount = ''
		RETURN

	SELECT	@ErrCode	= 0
		,	@MsgType	= 0
		,	@ErrMsg			= ''

	SET @startRun = GETDATE()

	--Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
			@custid		= @custid
		,	@ErrCode		= @ErrCode OUTPUT
		,	@ErrMsg		= @ErrMsg  OUTPUT

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
		, @SuperID	= srecommend
		, @RoleID	= RoleID
		, @currency = currency
		, @siteid   = s.siteid
	FROM dbo.Customer  c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON c.site = s.site
	WHERE custid = @CustID

	--Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
					@custid		= @custid
				,	@roleid		= @roleid
				,	@isExecRep		= 1
				,	@Language		= 'E'
				,	@ErrCode		= @ErrCode	OUTPUT
				,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	INSERT INTO #ProductSettingDetail(SportType,BetType,SettingType,IsLive,ProductID,SettingLevel)
	SELECT SportType,BetType,SettingType,IsLive,ProductID,SettingLevel 
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@Currency)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)

	-- Parse Data Json
	INSERT INTO @NewDiscountTbl ( SportType , BetType , Discount )
	SELECT Comm.SportType , Comm.BetType , Comm.Discount
	FROM OPENJSON(@Discount)
	WITH 
		(
			SportType		SMALLINT,
			BetType		SMALLINT,
			Discount		DECIMAL (9,8)
		) AS Comm


	--Exclude Update for Sport is having UM
	DELETE t
	FROM @NewDiscountTbl t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType IN( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID  IN (ps.ProductID, 0)
	WHERE ps.SettingType = 19
		AND u.FunctionType = 1 --Edit Customer
	
	IF NOT EXISTS( SELECT 1 FROM @NewDiscountTbl)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END

	EXEC [dbo].[Acc_CustSetting_Discount_156_Check] 
						  @CustID		= @CustID
						, @RoleID		= @RoleID
						, @AgentID		= @AgentID
						, @MasterID		= @MasterID
						, @SuperID		= @SuperID
						, @Discount		= @Discount
						, @GroupID		= @GroupID
						, @GroupType	= @GroupType
						, @SettingStatus  = @SettingStatus
						, @ErrCode		= @ErrCode	OUTPUT
						, @MsgType		= @MsgType  OUTPUT
						, @ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode <> 0
		RETURN

	--Get old comm
	IF @RoleID IN (2, 3, 4)
	BEGIN
		INSERT INTO @oldDiscountTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.Discount
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END
	ELSE IF @RoleID = 1
	BEGIN
		INSERT INTO @oldDiscountTbl
		SELECT dc.SportType
			, dc.BetType
			, dc.PlayerDiscount
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Member dc WITH (NOLOCK)
			ON dc.SportType		= tmp.SportType
				AND dc.BetType	= tmp.BetType
				AND dc.CustID	= @CustID
	END

	IF @RoleID = 3
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, super_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dcs.Discount
					THEN tmp.Discount
				ELSE dcs.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcs WITH (NOLOCK)
			ON tmp.SportType	= dcs.SportType
				AND tmp.BetType = dcs.BetType
				AND dcs.custid	= @SuperID
	END
	ELSE IF @RoleID = 2
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, master_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dcm.Discount
					THEN tmp.Discount
				ELSE dcm.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dcm WITH (NOLOCK)
			ON tmp.SportType	= dcm.SportType
				AND tmp.BetType = dcm.BetType
				AND dcm.custid	= @MasterID
	END
	ELSE IF @RoleID = 1
	BEGIN
		--Update NEW_DISCOUNT = MIN( @NEW_DISCOUNT, agent_discount)
		UPDATE tmp
		SET tmp.Discount = CASE 
				WHEN tmp.Discount < dca.Discount
					THEN tmp.Discount
				ELSE dca.Discount
				END
		FROM @NewDiscountTbl tmp
		INNER JOIN dbo.CustDiscount3rd_Agent dca WITH (NOLOCK)
			ON dca.SportType	= tmp.SportType
				AND dca.BetType = tmp.BetType
				AND dca.custid	= @AgentID
	END

	--Return XML result
	SELECT @CorrectedDiscount_XML = (
			SELECT *
			FROM @NewDiscountTbl
			FOR XML RAW('Discount')
			)

	SELECT @CorrectedDiscount_XML = '<ROOT>' + @CorrectedDiscount_XML + '</ROOT>'

	--execrept to update commission
	IF @isSearchAndCopy=1
	BEGIN
		EXEC Acc_DynamicCustomerInfo_01 
				@CustID		= @CustID,
				@SettingList	= @CorrectedDiscount_XML,
				@SettingType	= 19,
				@AgentID		= @AgentID
	END
	ELSE
	BEGIN
		EXEC dbo.Acc_DynamicCustSetting3rd_06
				@CustId			= @custid,
				@RoleId			= @RoleId,
				@SettingType		= 19,
				@Discount_XML		= @CorrectedDiscount_XML
	END		

	--START LOGGING		

	-- Log old value
	SET @xml = (
				SELECT	@CustID							AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						(
							SELECT	@GroupID				AS '@GroupID',
									psd.ProductID			AS '@ProductID',
									psd.SportType			AS '@SportType',
									psd.BetType				AS '@BetType',
									psd.SettingLevel			AS '@SettingLevel',
									Discount				AS '@Discount'
							FROM	@oldDiscountTbl d
							INNER JOIN #ProductSettingDetail psd ON d.SportType = psd.SportType AND d.BetType = psd.BetType
							FOR XML PATH('Discount'),
							TYPE
						)
				FOR XML PATH('ROOT'),
				TYPE
			)

	SET @logSpData_Old = REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	-- Log new updated value
	SET @xml = (
				SELECT	@CustID							AS '@CustID',
						dbo.f_GetSubUsername(@SubAccID)			AS '@SubAccName',
						@IP								AS '@IP',
						(
							SELECT	@GroupID				AS '@GroupID',
									psd.ProductID			AS '@ProductID',
									psd.SportType			AS '@SportType',
									psd.BetType				AS '@BetType',
									psd.SettingLevel			AS '@SettingLevel',
									Discount				AS '@Discount'
							FROM	@NewDiscountTbl d
							INNER JOIN #ProductSettingDetail psd ON d.SportType = psd.SportType AND d.BetType = psd.BetType
							FOR XML PATH('Discount'),
							TYPE
						)
				FOR XML PATH('ROOT'),
				TYPE
			)

	SET @logSpData	= REPLACE(CONVERT(VARCHAR(MAX), @xml), '" />', '"/"')

	SELECT @logSpData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData_Old)
	SELECT @logSpData = LogStr 
	FROM f_CustSetting_FormatLog (@logSpData)

	SELECT @endRun	= GETDATE()
		, @duration = DATEDIFF(MILLISECOND, @startRun, @endRun)

	DECLARE @ActionID INT = 255

	BEGIN TRY

		EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			  @UserID			= @UserID
			, @CustID			= @CustID
			, @ActionID			= @ActionID
			, @TrackingValue		= @logSpData
			, @TrackingValue2		= @logSpData_Old
			, @duration			= @duration
	END TRY

	BEGIN CATCH

		EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			  @UserID			= @UserID
			, @CustID			= @CustID
			, @ActionID			= @ActionID
			, @TrackingValue		= @logSpData
			, @TrackingValue2		= @logSpData_Old
			, @duration			= @duration
	END CATCH
	
	DROP TABLE #ProductSettingDetail
END