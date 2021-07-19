/*<info serverAlias="DBCUST-CUSTDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].Acc_Enabled_Disabled_Status_ByAdmin (
	 @UserName 	VARCHAR(MAX),  --support multi username
	 @Enabled	BIT --1: Enabled 0: Disabled 
)
AS
/*
	Created: 20210713@Eden
	Task : SP to support request enabled/disabled account by Username, must close/open status first
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden: Support to open back account SGRD for AhWan [RedmineID: #154863]

	Parameter Definition

	Example: 
		EXEC [Acc_Enabled_Disabled_Status_ByAdmin] 
			@UserName = 'Eden0616UUS04CashOut',
			@Enabled = 1
	
*/
DECLARE @TmpUsername TABLE(Username varchar(30))

INSERT INTO @TmpUsername(Username)
SELECT val
FROM dbo.f_stringsplit(@UserName, ',')
OPTION (MAXRECURSION 0)

UPDATE c
SET c.Enabled = @Enabled
FROM Custinfo c WITH(ROWLOCK)
	INNER JOIN @TmpUsername t ON c.username = t.Username
WHERE c.Enabled <> @Enabled

GO