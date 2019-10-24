/*<info serverAlias="DBEXT-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[Acc_CustomerNoCommSelBettypes] 

AS
/*
	Created: 20171025@Winnie
	Task : Select bettypes
	DB: DBEXT/bodb02

	Revisions: 	
		- 20171025@Winnie: Select bettypes [RedmineID:#83334]
		- 20180125@Winnie: Hide inactive products [RedmineID: #86086]  
	
	Param's Explanation:
*/

SELECT 1 AS SportType,1 AS bettype,'Asian HDC, OU, OE' AS GroupBettype
UNION
SELECT 1 AS SportType,5 AS bettype,'1x2' AS GroupBettype
UNION
SELECT 1 AS SportType,4 AS bettype,'Other Bettypes' AS GroupBettype

GO