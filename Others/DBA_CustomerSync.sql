/*<info serverAlias="DBCUST-CustDB" executers="vnteam" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[DBA_CustomerSync]
	@CustIDs NVARCHAR(MAX) = NULL, -- List custid
	@Usernames NVARCHAR(MAX) = NULL, -- List username
	@Mode TINYINT = 1 
AS
/*
	Created: 20250227@Tacy  
	Task : Sync customer/custinfo to the replicated servers
	DB:  DBCUST-CustDB
	
	Revisions: 
		- 20250227@Tacy: Init SP [redmine: #212684]

		* @Mode = 1 ~ Customer
				= 2 ~ Custinfo
*/
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @cnt INT, @__msg NVARCHAR(200) 

	IF ISNULL(@CustIDs,'')='' AND ISNULL(@Usernames,'')=''
		RETURN
	
	CREATE TABLE #tmpCustomers (CustID INT PRIMARY KEY)

	IF @CustIDs IS NOT NULL
	BEGIN
		INSERT INTO #tmpCustomers (CustID)
		SELECT TRIM(ss.value)
		FROM STRING_SPLIT(@CustIDs, ',') ss
		WHERE TRIM(ss.value)<>''
	END
	ELSE IF @Usernames IS NOT NULL
	BEGIN
		INSERT INTO #tmpCustomers (CustID)
		SELECT c.custid
		FROM STRING_SPLIT(@Usernames, ',') ss
		INNER JOIN Customer c WITH (NOLOCK) ON c.username=TRIM(ss.value)
		WHERE TRIM(ss.value)<>''
	END

	SELECT @cnt=COUNT(1) FROM #tmpCustomers
	
	IF @cnt>2000
	BEGIN
		SET @__msg = 'You can only sync up to 2,000 customers per request.'
		GOTO ErrMsg
	END
	ELSE
		SET @__msg = 'The total of customers will be synced: %d.'

	IF @Mode=1
	BEGIN
		UPDATE c
		SET RepUpdateTime=dbo.f_GetDateTime2()
		FROM Customer c WITH (ROWLOCK, UPDLOCK)
		INNER JOIN #tmpCustomers t ON t.CustID=c.custid
	END

	IF @Mode=2
	BEGIN
		UPDATE c
		SET RepUpdateTime=dbo.f_GetDateTime2()
		FROM custInfo c WITH (ROWLOCK, UPDLOCK)
		INNER JOIN #tmpCustomers t ON t.CustID=c.custid
	END

	ErrMsg:
		RAISERROR (@__msg, 0, 1, @cnt) WITH NOWAIT

	DROP TABLE #tmpCustomers
END
GO