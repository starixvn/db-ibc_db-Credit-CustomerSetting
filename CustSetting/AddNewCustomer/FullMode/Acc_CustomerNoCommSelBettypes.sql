/*<info serverAlias="DBEXT-bodb02" executers="bodbadminNet" viewers="vnteam" isFunction="0"></info>*/
USE [bodb02]
GO

ALTER PROCEDURE [dbo].[Acc_CustomerNoCommSelBettypes] 

AS
/*
Created: 20171025@Winnie
Task : Select bettypes
DB: dbcust/custdb

Revisions: 	
- 20171025@Winnie: Select bettypes [RedmineID:#83334]
Param's Explanation:
*/

SELECT 1 AS SportType,1 AS bettype,'Asian HDC, OU, OE' AS GroupBettype
UNION
SELECT 1 AS SportType,5 AS bettype,'1x2' AS GroupBettype
UNION 
SELECT 154 AS SportType,20 AS bettype,'HR Fixed Odds' AS GroupBettype
UNION
SELECT 1 AS SportType,4 AS bettype,'Other Bettypes' AS GroupBettype

GO