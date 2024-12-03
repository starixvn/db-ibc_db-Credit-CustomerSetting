/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_Initial_DCS_ScanConfig]
	@ConfigID INT = 0 OUTPUT,
	@IsProd BIT = 0 OUTPUT, --1: PROD env, 0: Testing env ( to config more replicated server)
	@MaxcustID INT = 0 OUTPUT,
	@XMLConfig VARCHAR(MAX) = 0 OUTPUT ,
	@IsTest BIT = NULL
AS
/*
	Created: 20210713@Eden
	Task : Job detect initial Setting Process
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden:  Flexible Initializing Customer Setting [RedmineID: #156667]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 
	- 20241122@Elodie : Initial by Super for UUS and YNG [Redmine: #214128]
	Value Mapping
		CurrentStep = :
			1: Delete existing customer setting
			2: Insert customer setting
			3: Enable status
			4: Insert setting for new customers
			5: Enable status for new customers
			6: Adjust setting
			7: Adjust status
			8: Disable status headline
			....

	Example: 
	DECLARE @ConfigID INT, @XMLConfig VARCHAR(MAX), @MaxcustID INT, @IsProd BIT
	EXEC [Acc_Initial_DCS_ScanConfig] 
		@ConfigID = @ConfigID OUTPUT,
		@XMLConfig = @XMLConfig OUT,
		@IsProd = @IsProd OUT,
		@MaxcustID = @MaxcustID OUT
	SELECT @ConfigID, @IsProd,@XMLConfig, @MaxcustID
	
	*/
BEGIN
	SET NOCOUNT ON
	CREATE TABLE #Supers(SuperID INT PRIMARY KEY, Site VARCHAR(10))
	CREATE TABLE #DirectAcc( CustID INT PRIMARY KEY, srecommend INT, mrecommend INT, recommend INT, RoleID TINYINT)
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_recommend ON #DirectAcc(recommend)
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_mrecommend ON #DirectAcc(mrecommend) 
	CREATE NONCLUSTERED INDEX ix_TmpDirectAcc_srecommend ON #DirectAcc(srecommend)

	SELECT @ConfigID = 0

	IF @@SERVERNAME = 'DBCUST'
		SET @IsProd = 1
	ELSE
		SET @IsProd = 0

	IF @IsTest IS NULL
	BEGIN
		IF @IsProd = 1 
			SET @IsTest = 0 -- dont't initial for test config on PRODUCTION
		ELSE
			SET @IsTest = 1
	END

	IF EXISTS ( SELECT 1 FROM Initial_ProductConfig WITH(NOLOCK) WHERE Status = 1 AND IsTest <= @IsTest) --RUNNING
	BEGIN
		PRINT 'Have process is running'
		GOTO ReturnLB;
	END

	SELECT TOP(1) @ConfigID = ConfigID  
	FROM Initial_ProductConfig WITH(NOLOCK) 
	WHERE Status IN (0) --Planned
		AND StartTime <= GETDATE()
		AND IsTest <= @IsTest
		AND ConfigID > 0
	ORDER BY StartTime, ConfigID

	IF @ConfigID IS NOT NULL
	BEGIN
		EXEC [Acc_Initial_DCS_ConfigStatus_Upd] 
			@ConfigID = @ConfigID,
			@Status = 1
	END
	ELSE
	BEGIN
		PRINT 'Have no process need to be run on this time'
		GOTO ReturnLB;
	END
	
	-------------------> Start initial data for running process-----------------------------------
	DECLARE @Site VARCHAR(MAX), @Currency VARCHAR(MAX)
	DECLARE @TBL_site TABLE(SiteID INT,Site VARCHAR(10) PRIMARY KEY)
	DECLARE @TBL_Currency TABLE(Currency INT PRIMARY KEY)

	SELECT @Site = Site, @Currency = Currency
	FROM Initial_ProductConfig WITH(NOLOCK)
	WHERE ConfigID = @ConfigID
		AND Status = 1 --Running

	IF @@ROWCOUNT = 0
	BEGIN
		PRINT 'No site/currency'
		GOTO ReturnLB;
	END
	
	IF EXISTS(
		SELECT TOP 1 1 
		FROM Initial_ProductConfig_Detail WITH(NOLOCK)
		WHERE ConfigID = @ConfigID
	)
	BEGIN
		SELECT @XMLConfig = (
		SELECT	 idt.SportType
				,idt.BetType
				,idt.IsLive
				,idt.SettingType
				,idt.IsDefault
				,idt.CopyFromSportType
				,idt.CopyFromBetType
				,idt.DefaultValueSuper
				,idt.DefaultValueMaster
				,idt.DefaultValueAgent
				,idt.DefaultValueMember
				,idt.SpecialRequirement
				,t.SettingName
		FROM Initial_ProductConfig_Detail idt WITH(NOLOCK)
			INNER JOIN ProductSettingType t WITH(NOLOCK) ON t.SettingType = idt.SettingType
		WHERE ConfigID = @ConfigID
		FOR XML RAW('R'))

		SELECT @XMLConfig = '<ROOT> ' + @XMLConfig + ' </ROOT>'
	END
	ELSE
	BEGIN
		PRINT 'No Setting'
		GOTO ReturnLB;
	END

	--> Insert Initial_StepByConfig
	EXEC Acc_Initial_DCS_InsertStepByConfigID @ConfigID = @ConfigID

	--> Get List of Site/Currency by config
	INSERT INTO @TBL_site(SiteID,Site)
	SELECT DISTINCT s.siteid, s.site
	FROM Site s WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Site,',') t ON s.siteid = t.value OR @Site = '0'
	WHERE s.isActive = 1
		AND s.isLicensee = 0
		AND s.siteid NOT IN (329)--CN88

	INSERT INTO @TBL_Currency(Currency)
	SELECT DISTINCT e.ExchangeId
	FROM exchange e WITH(NOLOCK)
		INNER JOIN STRING_SPLIT(@Currency,',') t ON e.ExchangeId = t.value OR @Currency = '0'
	WHERE e.IsActive = 1

	DECLARE @MaxCustTBL TABLE( custid INT)
	DECLARE @sql nvarchar(max) = ''

	--> Get @maxcustID
	IF @IsProd = 1 --PRODUCTION --> get maxcustid from DBTP
	BEGIN
		SET @sql = '
		SELECT Custid
		FROM OPENQUERY (DBTP, ''SELECT  TOP (1) c.Custid 
								FROM bodb02.dbo.custInfo c WITH(NOLOCK)
								ORDER BY c.CustID DESC'')'

		INSERT INTO @MaxCustTBL(custid)
		EXEC (@sql)

		SELECT @MaxcustID = custid 
		FROM @MaxCustTBL
	END
	ELSE
	BEGIN
		SELECT  TOP (1) @maxcustID = c.Custid 
		FROM custInfo c WITH(NOLOCK)
		ORDER BY c.CustID DESC
	END
	  
	TRUNCATE TABLE Initial_Customer

	--------Insert direct account to Queue
	INSERT INTO #Supers(SuperID,Site)
	SELECT ci.custid, ci.site
	FROM customer ci WITH (NOLOCK) 
		INNER JOIN @TBL_Currency ex ON ci.currency = ex.Currency
		INNER JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
		INNER JOIN custInfo c WITH(NOLOCK) ON c.custid = ci.custid
	WHERE ci.roleid = 4  
		AND ci.username NOT LIKE '3rdSuper%'
		AND cs.isinternal = 0
		AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.Enabled = 1
		AND ci.custid <= @maxcustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID)
	SELECT d.CustID
		,c.srecommend
		,c.mrecommend
		,c.recommend
		,c.roleid
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK,FORCESEEK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustAgent ca WITH(NOLOCK) ON ca.custid = c.recommend AND ca.IsInternal = 0
	WHERE c.roleid = 1
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND ci.custid <= @maxcustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID)
	SELECT d.CustID
		,c.srecommend
		,c.mrecommend
		,0
		,c.roleid
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK,FORCESEEK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustAgent ca WITH(NOLOCK) ON ca.custid = c.custid AND ca.IsInternal = 0
	WHERE c.roleid = 2
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.custid NOT IN ( SELECT recommend FROM #DirectAcc)
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND ci.custid <= @maxcustID

	INSERT INTO #DirectAcc(CustID,srecommend,mrecommend,recommend,RoleID)
	SELECT d.CustID
		,c.srecommend
		,0
		,0
		,c.roleid
	FROM CustDirectAccount d WITH(NOLOCK)
		INNER JOIN customer c WITH (NOLOCK,FORCESEEK) ON c.custid = d.custid
		INNER JOIN custinfo ci WITH(NOLOCK) on d.CustID = ci.custid
		INNER JOIN @TBL_site s ON c.site = s.site
		INNER JOIN @TBL_Currency ex ON c.currency = ex.Currency
		INNER JOIN CustMaster cm WITH(NOLOCK) ON cm.custid = c.custid AND cm.IsInternal = 0
	WHERE c.roleid = 3
		AND c.srecommend NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
		AND c.custid NOT IN ( SELECT mrecommend FROM #DirectAcc)
		AND EXISTS( SELECT TOP 1 1 FROM #Supers WHERE SuperID = c.srecommend) --Super is enabled
		AND ci.custid <= @maxcustID

	--> Insert supers to queue
	INSERT INTO Initial_Customer(CustID,RoleID,CurrentStep)
	SELECT t.SuperID,4,0
	FROM #Supers t
		INNER JOIN @TBL_site s ON t.Site = s.Site
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM #DirectAcc WHERE t.SuperID = srecommend)

	--> Insert direct accounts to queue
	INSERT INTO Initial_Customer(CustID,RoleID,CurrentStep)
	SELECT t.CustID,t.RoleID,0
	FROM #DirectAcc t

	IF @@SERVERNAME IN( 'DBSPARE','DBBACKUP2') -- DBTEST --> Get MaxcustID to test new accs steps
	BEGIN
		SELECT @MaxcustID = MIN(custid)
		FROM
		(
			SELECT TOP (500) ci.custid
			FROM Initial_Customer it WITH(NOLOCK)
				INNER JOIN custInfo ci WITH(NOLOCK) ON it.CustID = ci.srecommend
			WHERE it.RoleID = 4
			ORDER BY ci.custid DESC
		)topx

		--Delete direct acc > @MaxcustID
		DELETE 
		FROM Initial_Customer WITH(ROWLOCK,UPDLOCK) 
		WHERE CustID > @MaxcustID
	END
		
	IF @Currency = '20' OR @Currency = '72'
	BEGIN
		DECLARE @ExchangeId INT = CAST(@Currency AS INT)
		IF EXISTS (SELECT custid FROM f_Initial_DCS_InitialSettingBySuper(@ExchangeId))
		BEGIN
			DELETE 
			FROM Initial_Customer WITH(ROWLOCK,UPDLOCK) 
			WHERE CustID NOT IN (SELECT custid FROM f_Initial_DCS_InitialSettingBySuper(@ExchangeId))
		END
	END

	ReturnLB:
	SELECT CAST(StepID AS INT) AS StepID, IsScanCustomer, @XMLConfig AS XMLConfig
	FROM Initial_StepByConfig WITH(NOLOCK) 
	ORDER BY SortOrder

	DROP TABLE #DirectAcc
	DROP TABLE #Supers
END
GO


