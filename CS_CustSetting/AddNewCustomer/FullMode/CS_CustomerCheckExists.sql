/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv" viewers="vnteam" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[CS_CustomerCheckExists]
	@username	VARCHAR(50),
	@Mode		BIT,
	@isExists	BIT = 0 OUTPUT
AS
/*
	Created: Elodie
	Date: 20190507
	Task: Check user name is valid or not for creating CN88's customer
	DB: DBCUST.CustDB
	
	Revisions:
		- 20190507@Elodie: Offer Unique Nickname for CN88 [Redmine:112287]
	Parameter's Explanation:
	    -@Mode: 0: Check username
		        1: Check nickname
*/	
BEGIN
	SET NOCOUNT ON
	DECLARE @NickName VARCHAR(50) 
	SELECT @NickName = NickName FROM f_CS_GetNickName(@username, 1)

	IF @Mode = 0
	BEGIN
		IF EXISTS(SELECT 1 FROM customer WITH(NOLOCK) WHERE username = @username)
			OR EXISTS (SELECT 1 FROM customer WITH (NOLOCK) WHERE username2 = @username)
			OR EXISTS (SELECT 1 FROM customer WITH (NOLOCK) WHERE username2 = @NickName)
			OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username = @username)
			OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username2 = @username)
			OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username2 = @NickName)
			OR EXISTS(SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username= @username)
			OR EXISTS (SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username2 = @username)
			OR EXISTS (SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username2 = @NickName)
				SELECT @isExists = 1
		ELSE 
				SELECT @isExists = 0
	END
	ELSE 
	BEGIN
		IF EXISTS(SELECT 1 FROM customer WITH(NOLOCK) WHERE username = @NickName)
			OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username = @NickName)
			OR EXISTS (SELECT 1 FROM customer WITH (NOLOCK) WHERE username2 = @NickName)
			OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username2 = @NickName)
			OR EXISTS(SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username= @NickName)

			OR EXISTS(SELECT 1 FROM customer WITH(NOLOCK) WHERE username = @username AND site = 'CN88')
			OR EXISTS (SELECT 1 FROM customer WITH (NOLOCK) WHERE username2 = @username AND site = 'CN88')
			OR EXISTS(SELECT 1 FROM custsub cs WITH (NOLOCK) 
						INNER JOIN dbo.Customer c WITH (NOLOCK) ON cs.custid = c.custid
						WHERE cs.username2 = @username AND c.site = 'CN88')
			OR EXISTS(SELECT 1 FROM custsub cs WITH (NOLOCK) 
						INNER JOIN dbo.Customer c WITH (NOLOCK) ON cs.custid = c.custid
						WHERE cs.username = @username AND c.site = 'CN88')
				SELECT @isExists = 1
		ELSE 
				SELECT @isExists = 0
	END
END
GO
 