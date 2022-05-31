/*<info serverAlias="DBACC-bodb02" executers="" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [DBA_ArchiveAccount_UpdateException_ByCust]
	@CustID INT,
	@ErrCode INT = 0 OUTPUT,
	@ErrMsg NVARCHAR(4000) = '' OUTPUT
AS
/*
	Created: 20220517@Eden
	Task: Update exception list by custID (for SMA only)
	DB: DBACC/bodb02
	Original:

	Revisions:
		20220517@Eden: Exclude internal usage account from Archiving credit accounts process [#RM:172372]
	Param's Explanation:
	DECLARE @ErrCode INT = 0, @ErrMsg NVARCHAR(4000) = '' 
	EXEC [DBA_ArchiveAccount_UpdateException_ByCust] 
		@CustID = 11760921,
		@ErrCode = @ErrCode OUT,
		@ErrMsg = @ErrMsg OUT
	SELECT @ErrCode,@ErrMsg
*/
SET NOCOUNT ON
DECLARE @RoleID TINYINT
SELECT @RoleID = ci.roleid FROM custinfo ci WITH(NOLOCK) WHERE ci.custid = @CustID

IF @RoleID IS NULL
BEGIN
	SELECT @ErrCode = 101,
		@ErrMsg = 'Invalid user'
	RETURN
END
IF @RoleID NOT IN(2,3,4)
BEGIN
	SELECT @ErrCode = 102,
		@ErrMsg = 'User must be SMA level'
	RETURN
END

SELECT TOP (1) @ErrCode = 103, @ErrMsg = 'User or upline exists already: ' + ce.Remark
FROM dbo.custinfo ci WITH(NOLOCK)
	INNER JOIN  bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON ce.custid IN (ci.recommend,ci.mrecommend,ci.srecommend)
WHERE ci.custid = @CustID

IF @ErrCode <> 0
	RETURN

INSERT INTO bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception](CustID,Remark)
SELECT ci.custid,ci.username
FROM dbo.custinfo ci WITH(NOLOCK)
	LEFT JOIN  bodb_report.dbo.[Task_Cust_ArchiveAcc_Exception] ce WITH (NOLOCK) ON ce.custid IN (ci.recommend,ci.mrecommend,ci.srecommend)
WHERE ci.custid = @CustID
	AND ci.roleid IN(2,3,4)
	AND ce.custid IS NULL