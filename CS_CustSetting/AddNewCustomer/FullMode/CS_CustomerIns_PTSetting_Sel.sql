/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerIns_PTSetting_Sel
	@RoleId TINYINT,
	@CustID INT	= NULL,
	@ProductID TINYINT = 1,
	@IsTest BIT = 0
AS
/*
	Created: 20181212@Elodie
	Task : Select PT info when creating new downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190724@Elodie: Apply default value for PT [Redmine:#117459]
		- 20200106@Elodie: Apply default value for MinPT = 70 [Redmine:#126606]
		- 20201125@Winfred: Apply default value for MinPT = 75, MaxPT = 90 [Redmine:#145992]
		
	Param's Explanation:
		• @RoleId:
			= 4: Create super 
			= 3: Create master 
			= 2: Create agent 			
	Example: 
		EXEC CS_CustomerIns_PTSetting_Sel @RoleId = 4, @IsTest = 1
		EXEC CS_CustomerIns_PTSetting_Sel @RoleId = 3, @CustID = 33418956, @IsTest = 1
		EXEC CS_CustomerIns_PTSetting_Sel @RoleId = 2, @CustID = 33418957, @IsTest = 1
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @IsEditablePT BIT
	SELECT @IsEditablePT = IsEditablePT FROM f_CS_GetEditablePTDate(@ProductID)

	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	IF @RoleId = 4
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinSuperMinPT, ps.MaxPT AS MaxSuperMinPT, 0 AS MinSuperMaxPT, ps.MaxPT AS MaxSuperMaxPT, 75 AS SuperMinPT, 80 AS SuperMaxPT
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter1 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
	END
	ELSE IF @RoleId = 3
	BEGIN
		IF @IsEditablePT = 1 
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinSuperPT, CASE WHEN pt.MaxPT > pt.MaxPT2 THEN pt.MaxPT2 ELSE pt.MaxPT END AS MaxSuperPT
			FROM dbo.f_CS_GetPT_Agent (@CustID)	pt 		
				INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
		END
		ELSE 
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinSuperPT, pt.MaxPT AS MaxSuperPT
			FROM dbo.f_CS_GetPT_Agent (@CustID)	pt 		
				INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
		END
	END	
	ELSE IF @RoleId = 2
	BEGIN
		CREATE TABLE #tmpAllowedPT (SportType SMALLINT, Bettype SMALLINT, IsLive BIT, MinAllowedPT TINYINT, MaxAllowedPT TINYINT)

		IF @IsEditablePT = 1 
		BEGIN
			--Min. Allowed: <Max (Old SMA Min Possess% - Old SMA Possess%, New SMA Min Possess% - New SMA Possess%)>%
			--Max. Allowed: <Min (Old SMA Max Possess% - Old SMA Possess%, New SMA Max Possess% - New SMA Possess%)>%
			INSERT INTO #tmpAllowedPT (SportType, Bettype, IsLive, MinAllowedPT, MaxAllowedPT)
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 				
					CASE	WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) AND (spt.MinPT - mpt.SuperPT) >= (spt.MinPT2 - mpt.SuperPT2) THEN spt.MinPT - mpt.SuperPT 
							WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) AND (spt.MinPT - mpt.SuperPT) < (spt.MinPT2 - mpt.SuperPT2) THEN spt.MinPT2 - mpt.SuperPT2
							WHEN (spt.MinPT < mpt.SuperPT) AND (spt.MinPT2 >= mpt.SuperPT2) THEN spt.MinPT2 - mpt.SuperPT2
							WHEN (spt.MinPT >= mpt.SuperPT) AND (spt.MinPT2 < mpt.SuperPT2) THEN spt.MinPT - mpt.SuperPT
							ELSE 0 END AS MinAllowedPT, 				
					CASE	WHEN (spt.MaxPT >= mpt.SuperPT) AND (spt.MaxPT2 >= mpt.SuperPT2) AND (spt.MaxPT - mpt.SuperPT) <= (spt.MaxPT2 - mpt.SuperPT2) THEN spt.MaxPT - mpt.SuperPT 
							WHEN (spt.MaxPT >= mpt.SuperPT) AND (spt.MaxPT2 >= mpt.SuperPT2) AND (spt.MaxPT - mpt.SuperPT) > (spt.MaxPT2 - mpt.SuperPT2) THEN spt.MaxPT2 - mpt.SuperPT2					
							ELSE 0 END AS MaxAllowedPT
			FROM CustInfo ci WITH (NOLOCK) 
				CROSS APPLY dbo.f_CS_GetPT_Agent (ci.srecommend) spt 			
				CROSS APPLY dbo.f_CS_GetPT_Agent (ci.custid) mpt 
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive AND mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive 
			WHERE ci.custid = @CustId
		END
		ELSE
		BEGIN
			--Min. Allowed: <New SMA Min Possess% - New SMA Possess%>%
			--Max. Allowed: <New SMA Max Possess% - New SMA Possess%>%
			INSERT INTO #tmpAllowedPT (SportType, Bettype, IsLive, MinAllowedPT, MaxAllowedPT)
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 				
					CASE	WHEN (spt.MinPT >= mpt.SuperPT) THEN spt.MinPT - mpt.SuperPT ELSE 0 END AS MinAllowedPT, 				
					CASE	WHEN (spt.MaxPT >= mpt.SuperPT) THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAllowedPT
			FROM CustInfo ci WITH (NOLOCK) 
				CROSS APPLY dbo.f_CS_GetPT_Agent (ci.srecommend) spt 			
				CROSS APPLY dbo.f_CS_GetPT_Agent (ci.custid) mpt 
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive AND mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive 
			WHERE ci.custid = @CustId
		END

		SELECT SportType, Bettype, IsLive, 				
				MinAllowedPT, MaxAllowedPT, 
				0 AS MinMasterPT, MaxAllowedPT AS MaxMasterPT, 
				0 AS MinAgentPT, MaxAllowedPT AS MaxAgentPT
		FROM #tmpAllowedPT 

		DROP TABLE #tmpAllowedPT
	END	

	DROP TABLE #SportBettypeFilter1
END
GO
