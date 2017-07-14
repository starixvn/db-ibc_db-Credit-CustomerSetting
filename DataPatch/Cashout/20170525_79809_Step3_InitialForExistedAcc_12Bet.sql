/*
	Created: 20170714@Elodie
	Task : Initial data CashOut for 12Bet - Enable CashOut for existed customer [RedmineID: #79809]
	DB: DBCust/CustDB	 
*/
------------------------------------------------------
ALTER PROCEDURE dbo.Acc_CustSetting3rd_19 
	@srecommend INT
	, @maxcustid INT
	, @target VARCHAR(20)
	, @ApplyToMember BIT
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' and @@servername = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' and @@servername <> 'DBCUST') RETURN -- run at dbtrans only
		
	IF NOT (dbo.f_CheckRepTable('Dep_CustProductSetting') = 1 
		   AND dbo.f_CheckRepTable('Dep_SupperProductSetting') = 1	 
		   AND dbo.f_CheckRepTable('Customer') = 1	 
		   )
		RETURN		
	
	INSERT INTO dbo.Dep_SupperProductSetting (CustID, ProductId, IsEnabled)
	VALUES (@srecommend, 25, 1)
	
	IF @ApplyToMember = 1
	BEGIN
		INSERT INTO dbo.Dep_CustProductSetting (CustID, ProductId, IsEnabled)
		SELECT c.CustID, 25, 1
		FROM Customer c WITH(NOLOCK) 
		WHERE custid <= @maxcustid AND srecommend = @srecommend AND roleid=1 
	END
END
go
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB ------
------------------------------------------------------

---
---
-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
--------------------------------------------------------------------------------------

DECLARE @MaxCustId INT, @srecommend INT, @ApplyToMember BIT = 0

SET @MaxCustId = xxx -- SELECT MAX(custID) FROM CustInfo WITH (NOLOCK)

CREATE TABLE #supers (custid INT PRIMARY KEY, isfinished BIT DEFAULT(0))

INSERT INTO #supers(custid)
SELECT ci.srecommend
FROM Customer ci WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ((ci.roleid = 4 	
	AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
	AND c.Enabled=1	
	AND ci.site IN ('12Bet')
	AND ci.currency = 20) OR ci.custid = 14543986) --vndcsd
	AND c.custid<=@MaxCustId


WHILE 1 = 1
BEGIN
	UPDATE TOP (1) #supers
	SET isFinished = 1
		, @srecommend = custid
	WHERE isFinished = 0
	
	if @@ROWCOUNT = 0 BREAK

	IF @srecommend = 3167631 --super of vndcsd
		SELECT @ApplyToMember = 0

	EXEC dbo.Acc_CustSetting3rd_19 
			@srecommend = @srecommend
			, @maxcustid = @maxcustid
			, @ApplyToMember = @ApplyToMember
			, @target = 'REPLICATED'
	
	WAITFOR DELAY '00:00:0.280'

END
GO
-- END STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
-----------------------------------------------------------------------------------

---
-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
DECLARE @MaxCustId INT, @srecommend INT, @ApplyToMember BIT = 0

SET @MaxCustId = xxx

CREATE TABLE #supers (custid INT PRIMARY KEY, isfinished BIT DEFAULT(0))

INSERT INTO #supers(custid)
SELECT ci.srecommend
FROM Customer ci WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
WHERE ((ci.roleid = 4 	
	AND ci.custid IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK)) 
	AND c.Enabled=1	
	AND ci.site IN ('12Bet')
	AND ci.currency = 20) OR ci.custid = 14543986) --vndcsd
	AND c.custid<=@MaxCustId


WHILE 1 = 1
BEGIN
	UPDATE TOP (1) #supers
	SET isFinished = 1
		, @srecommend = custid
	WHERE isFinished = 0
	
	if @@ROWCOUNT = 0 BREAK

	IF @srecommend = 3167631 --super of vndcsd
		SELECT @ApplyToMember = 0

	EXEC dbo.Acc_CustSetting3rd_19 
			@srecommend = @srecommend
			, @maxcustid = @maxcustid
			, @ApplyToMember = @ApplyToMember
			, @target = 'DBCUST'
	
	WAITFOR DELAY '00:00:0.280'

END
GO

-- END STEP 3: RUN THIS SCRIPT AT DBCUST -----
-----------------------------------------------------------------------------------

