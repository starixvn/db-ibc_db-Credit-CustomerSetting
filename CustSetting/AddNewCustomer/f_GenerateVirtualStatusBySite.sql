/*<info serverAlias="DBCUST-CustDB" executers="" viewers="vnteam" isFunction="1"></info>*/
USE [CustDB]
GO

ALTER FUNCTION [dbo].[f_GenerateVirtualStatusBySite] (@Site NVARCHAR(50))   
RETURNS TABLE   
AS  
/*
	Created: Elodie
	DB: DBCust/CustDB
	Revision:      
		- 20220222@Elodie: Generate VR status by site [RedmineID:#168885]
	Example: SELECT * FROM f_GenerateVirtualStatusBySite ('789y')
		
*/ 
RETURN  
	SELECT CASE WHEN @Site IN ('789y') THEN 1 ELSE 0 END AS EnableVR
GO