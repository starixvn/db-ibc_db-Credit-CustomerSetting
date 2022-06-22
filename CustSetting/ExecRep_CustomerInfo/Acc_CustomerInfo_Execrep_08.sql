/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" isFunction="0" isNested="1"></info>*/
USE [CustDB]
GO

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
*/

BEGIN
	SET NOCOUNT ON

	IF dbo.f_CheckRepTable('CustSuper') = 0
		RETURN

	IF dbo.f_CheckRepTable('CustMaster') = 0
		RETURN

	IF dbo.f_CheckRepTable('CustAgent') = 0
		RETURN

	DECLARE @SuperIdXML XML
	SELECT  @SuperIdXML = CAST(@SuperIdList AS XML)
	
	CREATE TABLE #tmpSuper(custid INT)
	
	INSERT INTO #tmpSuper(custid)
	SELECT t.c.value('@c', 'INT') AS CustId	
	FROM @SuperIdXML.nodes('/r') AS t(c)

	-- CustSuper
	BEGIN
		UPDATE s
		SET s.TransferOption = @TransferOption
		FROM dbo.CustSuper s WITH (ROWLOCK, UPDLOCK)
			INNER JOIN #tmpSuper t ON s.custid = t.CustId
		WHERE s.TransferOption <> @TransferOption
	END

	-- CustMaster
	BEGIN
		UPDATE m
		SET m.TransferOption = @TransferOption
		FROM dbo.CustMaster m WITH (ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Customer c WITH (NOLOCK) ON m.custid = c.custid
			INNER JOIN #tmpSuper t ON c.srecommend = t.CustId
		WHERE c.roleid = 3
			AND m.TransferOption <> @TransferOption
	END

	-- CustAgent
	BEGIN
		UPDATE a
		SET a.TransferOption = @TransferOption
		FROM dbo.CustAgent a WITH (ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Customer c WITH (NOLOCK) ON a.custid = c.custid
			INNER JOIN #tmpSuper t ON c.srecommend = t.CustId
		WHERE c.roleid = 2
			AND a.TransferOption <> @TransferOption
	END

	DROP TABLE #tmpSuper
END
GO