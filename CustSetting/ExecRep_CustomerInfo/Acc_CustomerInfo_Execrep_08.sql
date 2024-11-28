/*<info serverAlias="DBCUST-CustDB" executers="wsv_nap" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerInfo_Execrep_08]
	@SuperIdList		VARCHAR(MAX)
	,@TransferOption	TINYINT
AS

/*
	Created: 20190409@Percy
	Task: Update transfer option
	DB: DBCUST.CustDB
	
	Revisions:
		- 20170703@Percy: Initialize SP [RedmineID: #111365]
		- 20220616@Johnson: define temp table to avoid dump db [redmine:#174035]
		- 20241121@Johnson: Apply In-house replication for Credit Setting [RedmineID: #212684]
*/

BEGIN
	SET NOCOUNT ON

	IF @@SERVERNAME NOT IN ('DBCUST','DBSPARE','SITDBCUST','TESTDBCUST','DB-60\DEVDBCUST')
		RETURN;

	DECLARE @SuperIdXML XML
	SELECT  @SuperIdXML = CAST(@SuperIdList AS XML)
	
	CREATE TABLE #tmpSuper(custid INT)
	
	INSERT INTO #tmpSuper(custid)
	SELECT t.c.value('@c', 'INT') AS CustId	
	FROM @SuperIdXML.nodes('/r') AS t(c)

	-- CustSuper
	BEGIN
		UPDATE s
		SET s.TransferOption = @TransferOption,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustSuper s WITH (ROWLOCK, UPDLOCK)
			INNER JOIN #tmpSuper t ON s.custid = t.CustId
		WHERE s.TransferOption <> @TransferOption
	END

	-- CustMaster
	BEGIN
		UPDATE m
		SET m.TransferOption = @TransferOption,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustMaster m WITH (ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Customer c WITH (NOLOCK) ON m.custid = c.custid
			INNER JOIN #tmpSuper t ON c.srecommend = t.CustId
		WHERE c.roleid = 3
			AND m.TransferOption <> @TransferOption
	END

	-- CustAgent
	BEGIN
		UPDATE a
		SET a.TransferOption = @TransferOption,
			RepUpdateTime = dbo.f_GetDateTime2()
		FROM dbo.CustAgent a WITH (ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Customer c WITH (NOLOCK) ON a.custid = c.custid
			INNER JOIN #tmpSuper t ON c.srecommend = t.CustId
		WHERE c.roleid = 2
			AND a.TransferOption <> @TransferOption
	END

	DROP TABLE #tmpSuper
END
GO