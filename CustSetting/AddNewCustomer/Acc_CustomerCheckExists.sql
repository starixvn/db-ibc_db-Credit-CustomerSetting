/*<info serverAlias="DBGLOB-GLOBCUSTDB" executers="wsv_nap,wsv_alp,wsv_xnap" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE dbo.Acc_CustomerCheckExists
(
	@username	VARCHAR(30)
	,@isExists	BIT = 0 OUTPUT
)
AS
/*
	Created: 20240704@Louisa 
	Task: Check existing
	DB: DBGLOB-GLOBCUSTDB
	
	Revisions:
		- 20240704@Louisa :scaleout DBCUST [Redmine:#206823]
		
	Parameter's Explanation:
		
*/	
BEGIN
	SET NOCOUNT ON
	SELECT  @username = RTRIM(LTRIM(@username))
	IF EXISTS (	SELECT 1 FROM dbo.CustInfoMini WITH(NOLOCK) WHERE username = @username)
		OR EXISTS (SELECT 1 FROM dbo.CustInfoMini WITH (NOLOCK) WHERE username2 = @username)
		OR EXISTS (SELECT 1 FROM dbo.CustSubMini WITH (NOLOCK) WHERE username = @username)
		OR EXISTS (SELECT 1 FROM dbo.CustSubMini WITH (NOLOCK) WHERE username2 = @username)
	
	SELECT @isExists = 1

END