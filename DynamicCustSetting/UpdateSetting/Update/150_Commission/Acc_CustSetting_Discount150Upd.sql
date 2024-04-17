/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustSetting_Discount150Upd]
	@custid			INT			,
	@Commission			VARCHAR(MAX)	,
	@SubAccID			INT			= 0,
	@UserID			INT			,	
	@IP				VARCHAR(15)		= '',
	@SettingStatus		TINYINT		= 0,
	@ErrCode			INT			= 0  OUTPUT,
	@ErrMsg			NVARCHAR(MAX)	= '' OUTPUT,
	@MsgType			INT			= 0  OUTPUT,
	@GroupID			TINYINT		= 1,
	@GroupType			TINYINT		= 150

AS
/*
	Created: 20231005@Helios
	Task : Update Commission of Sportbook (use for all level Super/master/agent/member)
	DB: DBCUST/CUSTDB
	Original: Acc_CustomerUpdSuper_Commission
		    Acc_CustomerUpdMaster_Commission
		    Acc_CustomerUpdAgent_Commission
		    Acc_CustomerUpdMember_Commission

	Revisions:
		- 20230310@Helios: Customer Setting - Migrate Sportsbook to DCS [RedmineID: #193083] 

	Param's Explanation:
	- @ErrCode:
		= 0: Update successfully.
		> 0: Specific Error. 
  
	- @ErrMsg: Error description.

	- @Commission: Json Type
		'[ 
					{ "SportType": "1", "BetType": "1", "Discount": "0.00150000" },
					{ "SportType": "1", "BetType": "3", "Discount": "0.00050000" },
					{ "SportType": "1", "BetType": "4", "Discount": "0.00350000" },
					{ "SportType": "1", "BetType": "5", "Discount": "0.00450000" },
					{ "SportType": "1", "BetType": "7", "Discount": "0.00550000" },
					{ "SportType": "1", "BetType": "8", "Discount": "0.00650000" },
					{ "SportType": "2", "BetType": "1", "Discount": "0.00100000" }
		]'
*/

BEGIN
	SET NOCOUNT ON


	----------------------------------------------------------------------------------------------------------------------------

	-- Declare Param
	DECLARE 
	  @startRun			DATETIME
	, @RoleID			TINYINT
	, @recommend		INT
	, @mrecommend		INT
	, @srecommend		INT
	, @UserName			VARCHAR(30)
	, @SiteID			INT 
	, @CurrencyID		INT
	, @JsonValues		VARCHAR(MAX)
	, @uGroup			VARCHAR(10)
	, @IsAgentNoCom		BIT	= 0
	
	-- Declare Table
	DECLARE @New_Commission TABLE (
		SportType		SMALLINT ,
		BetType		SMALLINT ,
		Discount		DECIMAL (9,8)
	)

	DECLARE @Old_Commission TABLE (
		SportType		SMALLINT ,
		BetType		SMALLINT ,
		Discount		DECIMAL (9,8),
		AgentDiscount	DECIMAL (9,8)
	)

	DECLARE @LogCommission TABLE (
		SportType		SMALLINT ,
		BetType		SMALLINT ,
		NewDiscount		DECIMAL (9,8),
		OldDiscount		DECIMAL (9,8),
		AgentDiscount	DECIMAL (9,8),
		Order_Comm		TINYINT,
		SettingLevel	TINYINT,
		ProductID		TINYINT
	)

	CREATE TABLE #ProductSettingDetail(
		ProductID		TINYINT,
		RealProductID	TINYINT,		
		SportType		SMALLINT,
		BetType		SMALLINT,
		MaxDiscount		DECIMAL(19,8),
		IntervalValue	DECIMAL(19,8),
		Child_DisplayOrder TINYINT,
		SettingType		SMALLINT,
		SettingLevel	TINYINT
	PRIMARY KEY(SportType ASC , BetType ASC)
	)
	

	SET @startRun = GETDATE()
	----------------------------------------------------------------------------------------------------------------------------
	-- Check if JSON is null or empty
	IF @Commission IS NULL OR @Commission = ''
		RETURN;

	SELECT	@ErrCode	= 0
		,	@ErrMsg	= ''
		,	@MsgType	= 0

	-- Check disable user
	EXEC dbo.Acc_CustomerSelCheckEnable 
						@custid		= @custid
					,	@ErrCode		= @ErrCode OUTPUT
					,	@ErrMsg		= @ErrMsg  OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END

	-- Check belonging
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

	-- Get line information
	SELECT @UserName = username, @recommend = recommend, @mrecommend = mrecommend, @srecommend = srecommend, @RoleID=RoleID, @SiteID = s.siteid , @CurrencyID = c.currency , @uGroup = c.ugroup
	FROM customer c WITH (NOLOCK)
	INNER JOIN Site s WITH (NOLOCK) ON s.site=c.site
	WHERE CustID = @CustID

	-- Check Allowed downlines	
	EXEC dbo.Acc_CustomerSelCheckAllowedDownlines 
							@custid		= @custid
						,	@RoleID		= @RoleID
						,	@isExecRep		= 1
						,	@Language		= 'E'
						,	@ErrCode		= @ErrCode	OUTPUT
						,	@ErrMsg		= @ErrMsg	OUTPUT

	IF @ErrCode > 0
	BEGIN
		SET @MsgType = 101
		RETURN
	END


	-- Get Product Setting
	INSERT INTO #ProductSettingDetail 	(ProductID , RealProductID , SportType , BetType , MaxDiscount , IntervalValue , Child_DisplayOrder , SettingType , SettingLevel)
	SELECT ProductID ,RealProductID , SportType , Bettype , MaxDiscount , IntervalValue , Child_DisplayOrder , SettingType , SettingLevel
	FROM dbo.f_CustSetting_ProductProfileSel(NULL,@SettingStatus,@SiteID,@CurrencyID)
	WHERE Grouptype = @GroupType
	AND (GroupID = @GroupID OR @GroupID IS NULL)
	
	

	-- Parse Data Json
	INSERT INTO @New_Commission  ( SportType , BetType , Discount )
	SELECT Comm.SportType , Comm.BetType , Comm.Discount
	FROM OPENJSON(@Commission)
	WITH 
		(
			SportType		SMALLINT,
			BetType		SMALLINT,
			Discount		DECIMAL (9,8)
		) AS Comm


	-- Exclude Update for Sport is having UM
	DELETE t
	FROM @New_Commission t
		INNER JOIN #ProductSettingDetail ps WITH (NOLOCK) 
			ON ps.BetType = t.BetType AND ps.SportType = t.SportType
		INNER JOIN [dbo].[f_CustSetting_SportUMByCust](@CustID) u 
			ON u.SportType    IN ( t.SportType,0)
			AND u.SettingType IN (ps.SettingType,0)
			AND u.ProductID   IN (ps.ProductID, 0)
	WHERE ps.SettingType = 25
		AND u.FunctionType = 1 --Edit Customer

	IF NOT EXISTS( SELECT 1 FROM @New_Commission)
	BEGIN
		SELECT @ErrCode = 90017,
				@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](90017,'E')

		RETURN
	END

	-- Check new values Comm is invalid
	EXEC dbo.Acc_CustSetting_Discount150Check
		@CustID		= @CustID
	,	@Discount		= @Commission
	,	@siteid		= @siteid
	,	@CurrencyID		= @CurrencyID
	,	@GroupID		= @GroupID
	,	@GroupType		= @GroupType
	,	@ErrCode		= @ErrCode		OUTPUT
	,	@MsgType		= @MsgType		OUTPUT
	,	@ErrMsg		= @ErrMsg		OUTPUT

	IF @ErrCode <> 0
		RETURN


	-- UPDATE START:
	IF @RoleID = 1 
	BEGIN

	-- Check rule Change GroupDiscount > Upline or Not
		-- Check rule CustNoComm
		IF NOT EXISTS (SELECT 1 FROM CustNoComm cnc WITH (NOLOCK) WHERE cnc.CustID = @custid) 	
			BEGIN
				-- Check rule Change GroupDiscount > Upline or Not of GroupDiscount?
				DECLARE @AgentDiscount DECIMAL (9,8)

				SELECT @AgentDiscount = (
									SELECT cda.Discount
									FROM CustDiscount3rd_Agent cda WITH (NOLOCK)
									WHERE cda.CustID =  @recommend
									AND cda.SportType = 1
									AND cda.BetType = (CASE 
													WHEN @ugroup IN ('a' , 'hka' , 'dea') THEN 1
													WHEN @ugroup IN ('b' , 'hkb' , 'deb') THEN 3
													WHEN @ugroup IN ('c' , 'hkc' , 'dec') THEN 7
													WHEN @uGroup IN ('d' , 'hkd' , 'ded') THEN 8
												 END)
								)

				UPDATE nc SET nc.Discount = CASE WHEN nc.Discount > @AgentDiscount THEN @AgentDiscount ELSE nc.Discount END
				FROM @New_Commission nc
				WHERE SportType = 1 AND BetType = 1

				-- Check rule Change GroupDiscount > Upline or Not of 1X2Discount & Other Discount?
				
				UPDATE nc
					SET nc.Discount = CASE WHEN nc.Discount > cda.Discount THEN cda.Discount ELSE nc.Discount END
				FROM @New_Commission nc
				INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON cda.SportType = nc.SportType AND nc.BetType = cda.BetType
				WHERE cda.CustID =  @recommend
				AND cda.SportType = 1 
				AND cda.BetType IN (4,5)
			END

		-- Of MO Odds?
		UPDATE nc
			SET nc.Discount = CASE WHEN nc.Discount > cda.Discount THEN cda.Discount ELSE nc.Discount END
		FROM @New_Commission nc
		INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON cda.SportType = nc.SportType AND cda.BetType = nc.BetType
		WHERE cda.CustID =  @recommend
		AND cda.SportType = 2 
		AND cda.BetType = 1

	-- End Check

		-- Get Old Comm for write log
		INSERT INTO @Old_Commission (SportType , BetType , Discount , AgentDiscount)
		SELECT cda.SportType , cda.BetType , cda.PlayerDiscount , cda.AgentDiscount
		FROM CustDiscount3rd_Member cda WITH (NOLOCK)
		INNER JOIN #ProductSettingDetail psd ON cda.SportType = psd.SportType AND cda.BetType = psd.BetType
		WHERE cda.CustID = @custid	


		-- Collect Data for write log
		INSERT INTO @LogCommission (SportType , BetType , NewDiscount , OldDiscount , AgentDiscount , Order_Comm , SettingLevel , ProductID)
		SELECT 
			psd.SportType
		,	psd.BetType
		,	nc.Discount				AS NewDiscount
		,	oc.Discount				AS OldDiscount
		,	oc.AgentDiscount
		,	psd.Child_DisplayOrder		 AS Order_Comm
		,	psd.SettingLevel
		,	psd.ProductID
		FROM #ProductSettingDetail psd
		INNER JOIN @New_Commission nc ON psd.SportType = nc.SportType AND psd.BetType = nc.BetType
		INNER JOIN @Old_Commission oc ON psd.SportType = oc.SportType AND psd.BetType = oc.BetType

		-- Collect Json to run execrep
		SELECT @JsonValues = (  SELECT  nc.SportType 
							, nc.BetType 
							, nc.Discount 
						FROM @New_Commission nc
						FOR JSON PATH
					)

		--Call SP Execrep to update for downline:
		EXEC dbo.Acc_CustSetting_06
							  @CustId			     = @CustId
							, @RoleId			     = @RoleID
							, @JsonComm			     = @JsonValues
							, @GroupType		     = @GroupType
	END

	ELSE IF @RoleID > 1 
	BEGIN
		
		UPDATE nc
			SET nc.Discount = CASE WHEN nc.Discount > cda.Discount THEN cda.Discount ELSE nc.Discount END
		FROM @New_Commission nc
		INNER JOIN CustDiscount3rd_Agent cda WITH (NOLOCK) ON cda.SportType = nc.SportType AND nc.BetType = cda.BetType
		WHERE cda.CustID =  (CASE 
						WHEN @RoleID = 2 THEN @mrecommend
						WHEN @RoleID = 3 THEN @srecommend
					  END)

		-- Get Old Comm for write log
		INSERT INTO @Old_Commission (SportType , BetType , Discount)
		SELECT cda.SportType , cda.BetType , cda.Discount
		FROM CustDiscount3rd_Agent 	cda WITH (NOLOCK)
		INNER JOIN #ProductSettingDetail psd ON cda.SportType = psd.SportType AND cda.BetType = psd.BetType
		WHERE cda.CustID = @CustID

		-- Collect Data for write log
		INSERT INTO @LogCommission (SportType , BetType , NewDiscount , OldDiscount , Order_Comm , SettingLevel , ProductID)
		SELECT 
			psd.SportType
		,	psd.BetType
		,	nc.Discount				AS NewDiscount
		,	oc.Discount				AS OldDiscount
		,	psd.Child_DisplayOrder		AS Order_Comm
		,	psd.SettingLevel
		,	psd.ProductID
		FROM #ProductSettingDetail psd
		INNER JOIN @New_Commission nc ON psd.SportType = nc.SportType AND psd.BetType = nc.BetType
		INNER JOIN @Old_Commission oc ON psd.SportType = oc.SportType AND psd.BetType = oc.BetType

		--Start to Update
		IF EXISTS (SELECT 1 FROM CustNoComm cnc WITH (NOLOCK) WHERE cnc.CustID = @custid AND @RoleID = 2) 
		BEGIN
			--Don't Update Discount Values Of Agent , Member related If exists Agent in CustNoCom
			SET @IsAgentNoCom = 1
		END

		IF @IsAgentNoCom = 0
		BEGIN
		-- Collect Json to run execrep
		SELECT @JsonValues = (  SELECT  nc.SportType 
							, nc.BetType 
							, nc.Discount 
					FROM @New_Commission nc
					FOR JSON PATH
					)

		--Call SP Execrep to update for downline:
		EXEC dbo.Acc_CustSetting_06
							  @CustId			     = @CustId
							, @RoleId			     = @RoleID
							, @JsonComm			     = @JsonValues
							, @GroupType		     = @GroupType

		END
	END 

	------------------------------ write log-------------------------------

	DECLARE	
		@LogSPData			NVARCHAR (MAX)
	,	@LogSPData_Old		NVARCHAR (MAX)
	,	@endRun			DATETIME  
	,	@duration			INT 
	,	@ActionID			INT
	,	@XML				XML
	,	@XML_Old			XML

	IF @RoleID > 1
	BEGIN
		SET @XML = (
		SELECT 
			@CustID					AS [@CustID]
		,	dbo.f_GetSubUsername(@SubAccID)	AS [@SubAccName]
		,	@IP						AS [@IP]
		,	(
				SELECT 
					SportType			AS [@SportType]
				,	BetType			AS [@BetType]
				,	NewDiscount			AS [@Discount]
				,	SettingLevel		AS [@SettingLevel]
				,	ProductID			AS [@ProductID]
				FROM @LogCommission
				ORDER BY Order_Comm
				FOR XML PATH ('Comm'),
				TYPE
			)
		FOR XML PATH ('ROOT'),
		TYPE
		)

		SET @XML_Old = (
		SELECT 
			@CustID					AS [@CustID]
		,	dbo.f_GetSubUsername(@SubAccID)	AS [@SubAccName]
		,	@IP						AS [@IP]
		,	(
				SELECT 
					SportType			AS [@SportType]
				,	BetType			AS [@BetType]
				,	OldDiscount			AS [@Discount]
				,	SettingLevel		AS [@SettingLevel]
				,	ProductID			AS [@ProductID]
				FROM @LogCommission
				ORDER BY Order_Comm
				FOR XML PATH ('Comm'),
				TYPE
			)
		FOR XML PATH ('ROOT'),
		TYPE
		)	
	END

	ELSE 
	BEGIN
		SET @XML = (
		SELECT 
			@CustID					AS [@CustID]
		,	dbo.f_GetSubUsername(@SubAccID)	AS [@SubAccName]
		,	@IP						AS [@IP]
		,	(
				SELECT 
					SportType			AS [@SportType]
				,	BetType			AS [@BetType]
				,	NewDiscount			AS [@PlayerDiscount]
				,	AgentDiscount		AS [@AgentDiscount]
				,	SettingLevel		AS [@SettingLevel]
				,	ProductID			AS [@ProductID]
				FROM @LogCommission
				ORDER BY Order_Comm
				FOR XML PATH ('Comm'),
				TYPE
			)
		FOR XML PATH ('ROOT'),
		TYPE
		)	

		SET @XML_Old = (
		SELECT 
			@CustID					AS [@CustID]
		,	dbo.f_GetSubUsername(@SubAccID)	AS [@SubAccName]
		,	@IP						AS [@IP]
		,	(
				SELECT 
					SportType			AS [@SportType]
				,	BetType			AS [@BetType]
				,	OldDiscount			AS [@PlayerDiscount]
				,	AgentDiscount		AS [@AgentDiscount]
				,	SettingLevel		AS [@SettingLevel]
				,	ProductID			AS [@ProductID]
				FROM @LogCommission
				ORDER BY Order_Comm
				FOR XML PATH ('Comm'),
				TYPE
			)
		FOR XML PATH ('ROOT'),
		TYPE
		)	
	END

	SET @LogSPData	 = REPLACE(CONVERT(VARCHAR(MAX), @XML), '" />', '"/"')
	SET @LogSPData_Old = REPLACE(CONVERT(VARCHAR(MAX), @XML_Old), '" />', '"/"')

	SELECT @LogSPData = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData)
	SELECT @LogSPData_Old = LogStr 
	FROM f_CustSetting_FormatLog (@LogSPData_Old)

	SET @endRun = GETDATE()
	SET @duration  = DATEDIFF (MILLISECOND,@startRun,@endRun)

	IF @RoleID = 4
		SET @ActionID = 251
	ELSE IF @RoleID = 3
		SET @ActionID = 252
	ELSE IF @RoleID = 2
		SET @ActionID = 253
	ELSE IF @RoleID = 1
		SET @ActionID = 254

	EXEC dbo.Acc_WriteLog_UserLog_RunSP_Wrapper
			  @UserID			= @UserID
			, @CustID			= @CustID
			, @ActionID			= @ActionID
			, @TrackingValue		= @LogSPData
			, @TrackingValue2		= @LogSPData_Old
			, @duration			= @duration
END



