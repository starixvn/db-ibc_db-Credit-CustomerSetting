/*<info serverAlias="DBCUST-CustDB" executers="bodbAdminNet" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerCheckValidAutoTransferAgent]
	@username VARCHAR(MAX) = ''
AS

/*
	Created: Johnson
	Date: 2014-09-29
	Task: Check valid agents before insert into automate transfer list
	DB: DBCUST.CustDB
		
	Revisions:
		- 20190409@Percy: Check existing super for case insert master/agent [RedmineID: #111365]
		
	Parameter's Explanation:
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @tmpUser TABLE (custid INT, username VARCHAR(50), srecommend INT)
	DECLARE @tmpResult TABLE (username VARCHAR(50), remark VARCHAR(100), isValid bit)
	
	INSERT INTO @tmpUser(username)
	SELECT val
	FROM strSplit (@username,',')
	
	UPDATE t
	SET t.custid = c.custid, t.srecommend = CASE WHEN c.roleid < 4 THEN c.srecommend END
	FROM @tmpUser t
		LEFT JOIN dbo.Customer c WITH (NOLOCK) ON t.username = c.username AND c.roleid > 1
	
	/* ===== Invalid case ===== */
	BEGIN
		-- Duplicate Username
		INSERT INTO @tmpResult (username, remark, isValid)
		SELECT username, 'Duplicate Username.', 0
		FROM @tmpUser
		WHERE custid IS NOT NULL
		GROUP BY username
		HAVING COUNT(1) > 1

		-- Invalid Username
		INSERT INTO @tmpResult (username, remark, isValid)
		SELECT username, 'Invalid Username.', 0
		FROM @tmpUser
		WHERE custid IS NULL

		-- Existing Username
		INSERT INTO @tmpResult (username, remark, isValid)
		SELECT t.username, 'Existing Username.', 0
		FROM Acc_ClearBalanceList ac WITH (NOLOCK)
			INNER JOIN @tmpUser t ON ac.custid = t.custid

		-- Existing Super (case Master/Agent)
		INSERT INTO @tmpResult (username, remark, isValid)
		SELECT t.username, 'Existing Super.', 0
		FROM Acc_ClearBalanceList ac WITH (NOLOCK)
			INNER JOIN @tmpUser t ON ac.custid = t.srecommend
	END
	
	/* ===== Valid case ===== */
	BEGIN
		INSERT INTO @tmpResult(username,remark,isValid)
		SELECT t.username, 'Valid Username.', 1
		FROM @tmpUser t 
			LEFT JOIN @tmpResult rs ON t.username = rs.username
		WHERE rs.username IS NULL
	END

	/* ===== Return result ===== */
	SELECT username, remark, isValid FROM @tmpResult
END
GO