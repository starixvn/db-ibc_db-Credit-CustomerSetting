/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" viewers="vnteam" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[Acc_CustVirtualMultiplierInvalid_Check]
	@UsernameLst VARCHAR(MAX)
AS
/*    
	Created: 20190626@Dominic    
	Task :  Check usernames before update  [Redmind: #114830]
	DB: DBACC/bodb02    
	Param's Explanation:  
		• @UsernameLst: comma separated string | ex 'member01,member02' 
	Revisions:    
		- 20190626@Dominic : First commit

  
*/ 
BEGIN
	DECLARE @XML XML
	SET @XML = N'<root><r>' + REPLACE(@UsernameLst, ',', '</r><r>') + '</r></root>'

	CREATE TABLE #LstUsername(Username VARCHAR(50), IsValid BIT )

	INSERT INTO #LstUsername(Username, IsValid) 
	SELECT r.value('.','VARCHAR(50)'), 0 IsValid
	FROM @xml.nodes('//root/r') AS RECORDS(r)

	UPDATE main
	SET IsValid = 1
	FROM #LstUsername main
		INNER JOIN Customer c (NOLOCK) ON c.username = main.Username

	SELECT * 
	FROM #LstUsername
	ORDER BY Username
END