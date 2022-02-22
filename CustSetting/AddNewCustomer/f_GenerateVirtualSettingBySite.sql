/*<info serverAlias="DBCUST-CustDB" executers="" viewers="vnteam" isFunction="1"></info>*/
USE [CustDB]
GO

ALTER FUNCTION [dbo].[f_GenerateVirtualSettingBySite] (@Site NVARCHAR(50), @CustId INT)   
RETURNS TABLE   
AS  
/*
	Created: Elodie
	DB: DBCust/CustDB
	Revision:      
		- 20220222@Elodie: Generate VR setting by site [RedmineID:#168885]
	Example: SELECT * FROM f_GenerateVirtualSettingBySite ('789y',1)
		
*/ 
RETURN  
	SELECT	@CustId as Custid, 
				seqNo,
				(
					SELECT TOP 1 bitmap
					FROM dbo.f_GenerateVirtualSetting_multiple(0x00, CONVERT(VARCHAR(MAX), virtualXML))
				) AS bitmapVirtual
		FROM (
			SELECT DISTINCT seqNo
			FROM ProfileVirtualSetting WITH(NOLOCK)
		) pvs
		CROSS APPLY (
			SELECT (
				SELECT	(
							SELECT ipvs.profileID AS '@p',
							CASE WHEN @site IN ('789y') THEN CASE	WHEN ipvs.bettype IN (1,7) AND ipvs.Islive = 1 THEN 0.12 
																	WHEN ipvs.bettype IN (1,7) AND ipvs.Islive = 0 THEN 0.1 
																	WHEN ipvs.bettype IN (3,8) THEN 0.08
																	ELSE 0.15 END
								ELSE 1 END AS '@v'
						FROM ProfileVirtualSetting AS ipvs WITH(NOLOCK)
						WHERE	ipvs.seqNo = pvs.seqNo
						FOR XML PATH ('r'), 
						TYPE
						)
				FOR XML PATH ('root'), 
				TYPE
			) AS virtualXML
		) p	
GO