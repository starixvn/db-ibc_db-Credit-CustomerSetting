/*<info serverAlias="DBTXN-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
CREATE PROCEDURE [DBA_ArchiveAccount3_ClearBalance_Super]
	@srecommend INT,
	@UserID		INT			  = 10278938, --starixIT
	@IP			VARCHAR(45)='',
	@ErrMsg		NVARCHAR(200) = '' OUTPUT,
	@ErrCode	INT			  = 0 OUTPUT
AS
/*
		Description: Clear balance super
		Create date: 20230608
		Original SP: 
		DB: DBTXN/bodb02
		
		Revisions:    
			- 20230608@Danny: Clear super balance [Redmine:183447]	
			- 20230818@Eden : Archive super level 789y [Redmine: #183447]
			- 20241118@Max: Offer Direct Member for Super/Master [Redmine: #211969]
*/
BEGIN

	SET NOCOUNT ON
	-- Super  info
	DECLARE @FromUsername	NVARCHAR(50),
			@FromCurrency	INT,
			@FromActualRate FLOAT,
			@Balance		MONEY,
			@Balance_Clear	MONEY,
			@FromRoleID		TINYINT,
			@Remark			NVARCHAR(200),
			@FromCurrCode	VARCHAR(12)

	DECLARE @toCustID	INT,
			@ToUsername	NVARCHAR(50),
			@ToActualRate	FLOAT,
			@ToCurrency	INT,
			@ToCurrCode VARCHAR(12)

	SELECT  @FromUsername	= c.username,
			@FromRoleID		= c.roleid,
			@FromCurrency	= c.currency,
			@FromActualRate = e.actualrate,
			@FromCurrCode	= e.Code
	from CustDB.dbo.Custinfo c WITH(NOLOCK)
	INNER JOIN CustDB.dbo.Exchange e WITH(NOLOCK) ON c.currency = e.exchangeid
	WHERE c.custid = @srecommend

	IF @FromRoleID <> 4 RETURN

	-- Calculate Super balance
	DECLARE @MBBU TABLE (BalanceUpDay SMALLDATETIME, MoveBetsDay SMALLDATETIME)
	INSERT INTO @MBBU (BalanceUpDay, MoveBetsDay)
	EXEC dbo.Age_SelBalanceUpDay

	DECLARE @BalanceUpDate SMALLDATETIME
	SELECT  @BalanceUpDate = BalanceUpDay FROM @MBBU

	CREATE TABLE #temp_recommend (recommend INT PRIMARY KEY)
	CREATE TABLE #temp_Cust (custID INT PRIMARY KEY)
	CREATE TABLE #temp_DirectMember (custID INT PRIMARY KEY)
	
	INSERT INTO #temp_recommend (recommend)
	SELECT DISTINCT custid
	FROM CustDB.dbo.custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid = 2

	INSERT INTO #temp_Cust (custID)
	SELECT DISTINCT custid
	FROM CustDB.dbo.custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid IN (3,4)

	INSERT INTO #temp_DirectMember (custID)
	SELECT DISTINCT custid
	FROM CustDB.dbo.custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid = 1 AND recommend = -4

	IF EXISTS(select 1 from dbo.transfer WITH (NOLOCK) where Recommend IN (SELECT recommend FROM #temp_recommend) AND bettype < 20000)
	BEGIN
		SELECT @ErrMsg = @FromUsername +':'+ 'This super just got active trans while processing!', @ErrCode = 101
		INSERT INTO [dbo].[CustArc_NewActive] (custid, roleid) VALUES(@srecommend, 4) 
		PRINT @ErrMsg
		RETURN
	END

	DECLARE @Balance_Recommend MONEY
	DECLARE @Balance_master_super MONEY
	DECLARE @Balance_DirectMember MONEY

	SELECT @Balance_Recommend = ISNULL(SUM(winlost - actual_stake + swinlost+ mwinlost +  awinlost + scomm), 0) 
	FROM #temp_recommend r
		INNER JOIN dbo.transfer b WITH (NOLOCK, INDEX = IX_recommend) ON r.recommend = b.recommend
	WHERE 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
					 WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
					 ELSE 1 END
	OPTION (MAXDOP 1)	
		
	SELECT @Balance_master_super =  ISNULL(SUM(winlost - actual_stake + swinlost+ mwinlost +  awinlost + scomm), 0) 
	FROM transfer b WITH (NOLOCK)
	WHERE custid IN (SELECT z.custID FROM #temp_Cust z)
		AND 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
					 WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
					 ELSE 1 END

	SELECT @Balance_DirectMember =  ISNULL(SUM(winlost-actual_stake+playercomm), 0) 
	FROM transfer b WITH (NOLOCK)
	WHERE custid IN (SELECT z.custID FROM #temp_DirectMember z)
		AND 1 = CASE WHEN bettype = 20000 AND winlostdate > @BalanceUpDate THEN 0 --> new bal
					 WHEN winlostdate < @BalanceUpDate THEN 0 --> old data
					 ELSE 1 END

	SELECT @Balance =  @Balance_Recommend + @Balance_master_super + @Balance_DirectMember

	IF @Balance = 0
		RETURN

	--Ger sitelabel of super
	DECLARE @Sitelabel varchar(50)
	SELECT @Sitelabel = s.SiteLabel
	FROM custdb.dbo.customer c WITH(NOLOCK)
		INNER JOIN custdb.dbo.Site s WITH(NOLOCK) On s.site = c.site
	WHERE c.custid = @srecommend

	-- Start transfer
	DECLARE  @GetHeadLineFromCustID TABLE (custID INT, HeadlineID INT) 
	DECLARE @sql VARCHAR(4000) = '
		SELECT custID,HeadlineID FROM OPENQUERY(DBCUST,''SELECT custID,HeadlineID FROM CustDB.dbo.f_CustSetting_GetHeadLineFromCustID('+ CAST (@srecommend AS VARCHAR(50)) +')'')
	'
	INSERT INTO @GetHeadLineFromCustID
	EXEC( @sql)

	SELECT  @toCustID =  CASE WHEN h.FinanceCode IS NOT NULL THEN h.FinanceCode
							  WHEN h.FinanceCode IS NULL AND @Sitelabel = '789y' THEN 14835730 --THAUSD
						 END
	FROM  CustDB.dbo.custinfo ci WITH(NOLOCK)
	  CROSS APPLY @GetHeadLineFromCustID sp
	  LEFT JOIN dbo.f_CustSetting_GetArchiveHeadline () h
		ON sp.HeadlineID = h.headlineID 
	WHERE ci.roleid = 4
	  AND ci.custid = @srecommend

	IF @toCustID IS NULL 
	BEGIN
		SELECT @ErrCode = 102, @ErrMsg = 'Can not get finance account!'
		RETURN
	END
		
	SELECT  @ToUsername	= c.username,
			@ToCurrency	= c.currency,
			@ToActualRate = e.actualrate,
			@ToCurrCode	= e.Code
	FROM	CustDB.dbo.Custinfo c WITH(NOLOCK)
		INNER JOIN CustDB.dbo.Exchange e WITH(NOLOCK) ON c.currency = e.exchangeid
	WHERE	c.custid = @toCustID

	

	IF @ToCurrCode = @FromCurrCode --direct transfer
	BEGIN
		SELECT @Balance_Clear = -@Balance

		EXEC [dbo].[Acc_BettransInsTransfer]
				@FromCustID		= @srecommend
				,@ToUserName	= @ToUsername 
				,@Amount		= @Balance_Clear
				,@ExchangeRate	= 1
				,@Remark		= ''
				,@UserID		= @UserID
				,@IP			= @IP
				,@isCollection 	= 0
				,@Language		= 'E'
				,@ErrCode		= @ErrCode OUTPUT
				,@ErrMsg		= @ErrMsg OUTPUT
	END

	
	DROP TABLE #temp_Cust
	DROP TABLE #temp_recommend
	DROP TABLE #temp_DirectMember
END
