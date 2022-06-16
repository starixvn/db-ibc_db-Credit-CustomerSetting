/*<info serverAlias="DBCUST-CustDB" executers="" selecters="" viewers="" isFunction="0" isNested="1"></info>*/
ALTER PROCEDURE [dbo].Acc_Enabled_Disabled_Status_ByAdmin (
	 @UserName 	VARCHAR(MAX),  --support multi username
	 @Enabled	BIT --1: Enabled 0: Disabled 
)
AS
/*
	Created: 20210713@Eden
	Task : SP@Enabled to support request enabled/disabled account by Username
	DB: DBCUST/CUSTDB
	Original:

	Revisions:  
	- 20210713@Eden: Support to open back account SGRD for AhWan [RedmineID: #154863]
	- 20220614@Eden: DBCUST - modify sp syntax to adapt with the SQL Server upgrade to 2019 [Redmine: #171831] 

	Parameter Definition

	Example: 
		EXEC [Acc_Enabled_Disabled_Status_ByAdmin] 
			@UserName = 'Eden0616UUS04CashOut',
			@Enabled = 1
	
*/
DECLARE @TmpUsername TABLE(Username varchar(30))

INSERT INTO @TmpUsername(Username)
SELECT value
FROM STRING_SPLIT(@UserName, ',')
WHERE value <> ''

UPDATE c
SET c.Enabled = @Enabled
FROM Custinfo c WITH(ROWLOCK)
	INNER JOIN @TmpUsername t ON c.username = t.Username
WHERE c.Enabled <> @Enabled