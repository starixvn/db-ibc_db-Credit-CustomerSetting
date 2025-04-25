/*<info serverAlias="DBTXN-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_CheckActiveSMA]
	@AccName VARCHAR(50) = NULL,	
	@IsActive BIT = 0 OUTPUT
AS
/*
	Task: scan ticket om bettranxx, transfer table under SMA
	Created: 20250102@Eden
	Database: DBTXN/bodb02

	Revisions:    
		- 20250102@Eden: Archiving direct member [redmine: #215533] 

	Sample :
		DECLARE @IsActive bit = 0
		EXEC dbo.[DBA_ArchiveAccount_CheckActiveSMA] @AccName = 'supertest1' ,@IsActive = @IsActive OUTPUT
		SELECT @Isactive
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @DDate DATE 
	SET @DDate = DATEADD(mm,-2,GETDATE())
	SET @IsActive = 0

	CREATE TABLE #temp_recommend (recommend INT PRIMARY KEY)
	CREATE TABLE #temp_DirectMember (custid INT PRIMARY KEY)

	DECLARE @roleid int, @CustID INT

	SELECT @roleid = roleid, 
		@CustID = custid
	FROM custdb.dbo.custinfo WITH(nolock)
	WHERE username = @AccName

	IF @roleid = 4
	BEGIN
		IF EXISTS(SELECT 1 FROM dbo.SabaWalletTicket WITH (NOLOCK) WHERE srecommend = @CustID AND custid <> 0 AND WinlostDate >= @DDate)
		BEGIN
			SELECT @IsActive = 1
			RETURN
		END

		INSERT INTO #temp_recommend (recommend)
		SELECT DISTINCT custid
		FROM CustDB.dbo.custinfo WITH (NOLOCK)
		WHERE srecommend = @CustID AND roleid = 2

		INSERT INTO #temp_DirectMember(custid)
		SELECT DISTINCT custid
		FROM CustDB.dbo.custinfo WITH (NOLOCK)
		WHERE srecommend = @CustID AND roleid = 1 AND recommend = -4
	END
	ELSE IF @roleid = 3
	BEGIN
		IF EXISTS(SELECT 1 FROM dbo.SabaWalletTicket WITH (NOLOCK) WHERE mrecommend = @CustID AND custid <> 0 AND WinlostDate >= @DDate)
		BEGIN
			SELECT @IsActive = 1
			RETURN
		END

		INSERT INTO #temp_recommend (recommend)
		SELECT DISTINCT custid
		FROM CustDB.dbo.custinfo WITH (NOLOCK)
		WHERE mrecommend = @CustID AND roleid = 2

		INSERT INTO #temp_DirectMember(custid)
		SELECT DISTINCT custid
		FROM CustDB.dbo.custinfo WITH (NOLOCK)
		WHERE mrecommend = @CustID AND roleid = 1 AND recommend = -3
	END
	ELSE IF @roleid = 2
	BEGIN
		IF EXISTS(SELECT 1 FROM dbo.SabaWalletTicket WITH (NOLOCK) WHERE recommend = @CustID AND custid <> 0 AND WinlostDate >= @DDate)
		BEGIN
			SELECT @IsActive = 1
			RETURN
		END

		INSERT INTO #temp_recommend (recommend)
		SELECT @CustID
	END
	ELSE 
	BEGIN
		RETURN
	END

	-- Check active transaction
	IF EXISTS(SELECT 1 FROM dbo.transfer WITH (NOLOCK) WHERE Recommend IN (SELECT recommend FROM #temp_recommend) AND bettype <> 20000)
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettrans WITH (NOLOCK) WHERE Recommend IN (SELECT recommend FROM #temp_recommend) AND bettype < 19999)
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.translog WITH (NOLOCK) WHERE Recommend IN (SELECT recommend FROM #temp_recommend))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettransLC WITH (NOLOCK) WHERE Recommend IN (SELECT recommend FROM #temp_recommend))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettransRNG WITH (NOLOCK) WHERE Recommend IN (SELECT recommend FROM #temp_recommend))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	--Check active transaction for direct members
	IF NOT EXISTS( SELECT 1 FROM #temp_DirectMember)
		RETURN

	IF EXISTS(SELECT 1 FROM dbo.transfer WITH (NOLOCK) WHERE custid IN (SELECT CustId FROM #temp_DirectMember) AND bettype <> 20000)
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettrans WITH (NOLOCK) WHERE custid IN (SELECT CustId FROM #temp_DirectMember) AND bettype < 19999)
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.translog WITH (NOLOCK) WHERE custid IN (SELECT CustId FROM #temp_DirectMember))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettransLC WITH (NOLOCK) WHERE custid IN (SELECT CustId FROM #temp_DirectMember))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	IF EXISTS(SELECT 1 FROM dbo.bettransRNG WITH (NOLOCK) WHERE custid IN (SELECT CustId FROM #temp_DirectMember))
	BEGIN
		SELECT @IsActive = 1
		RETURN
	END

	DROP TABLE #temp_DirectMember
	DROP TABLE #temp_recommend
END
GO
