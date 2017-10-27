/*<info serverAlias="DBEXT-bodb02" executers="bodbadminNet" viewers="vnteam" isFunction="0"></info>*/
USE [bodb02]
GO

CREATE PROCEDURE [dbo].[Acc_CustomerNoCommSelBettypes] 

AS
/*
Created: 20171025@Winnie
Task : Select bettypes
DB: dbcust/custdb

Revisions: 	
- 20171025@Winnie: Select bettypes [RedmineID:#83334]
Param's Explanation:
*/

SELECT DISTINCT s.SportType,s.bettype,'Asian HDC, OU, OE' AS GroupBettype
FROM SportBettypeMatrix s WITH(NOLOCK) 
	INNER JOIN bettype b WITH(NOLOCK)  ON s.BetType=b.typeid
WHERE ProductID=1 and bettype IN (1,2,3,7,8) AND SportType<>154

UNION
SELECT DISTINCT s.SportType,s.bettype,'1x2' AS GroupBettype
FROM SportBettypeMatrix s WITH(NOLOCK) 
	INNER JOIN bettype b WITH(NOLOCK)  ON s.BetType=b.typeid
WHERE ProductID=1 and bettype =5

UNION 
SELECT 154 AS SportType,20 AS bettype,'HR Fixed Odds' AS GroupBettype

UNION
SELECT DISTINCT s.SportType,s.bettype,'Other Bettypes' AS GroupBettype
FROM SportBettypeMatrix s WITH(NOLOCK) 
	INNER JOIN bettype b WITH(NOLOCK)  ON s.BetType=b.typeid
WHERE ProductID=1 and bettype IN (4,6,9,10,20,21,22,9999) AND SportType<>154

GO