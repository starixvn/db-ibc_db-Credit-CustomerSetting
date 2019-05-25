/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="vnteam" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Age_CustomerCheckExists]
	@username	 VARCHAR(50),
	@isExists	 BIT = 0 OUTPUT
AS
/*
	Created: Johnson
	Date: 2015-04-06
	Task: Check user name/nickname is valid or not for creating MBC's customer 
	DB: DBCUST.CustDB
	
	Revisions:
		- 20150610@Kos: Separate CustDB to DBCUST server (Move SP to DBCUST.CustDB)
		- 20181002@Dominic: Check existing username/username2 in archived DB  [Redmine:99882]
		- 20190325@Elodie: Grant permission to bodbAdminNet [Redmine:105338]
		- 20190422@Elodie: Check username2 in CustSub table [Redmine:112287]
	Parameter's Explanation:
*/	
BEGIN
	SET NOCOUNT ON
	
	IF EXISTS(SELECT 1 FROM customer WITH(NOLOCK) WHERE username = @username)
		OR EXISTS (SELECT 1 FROM customer WITH (NOLOCK) WHERE username2 = @username)
		OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username = @username)
		OR EXISTS(SELECT 1 FROM custsub WITH (NOLOCK) WHERE username2 = @username)
		OR EXISTS(SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username= @username)
		OR EXISTS (SELECT 1 FROM Dep_Customer_Archived WITH (NOLOCK) WHERE username2 = @username)
			SELECT @isExists = 1
	ELSE 
			SELECT @isExists = 0
END
GO
 