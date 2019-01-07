/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_PTSetting_Sel
	@RoleId TINYINT,
	@CustID INT,
	@ProductID TINYINT = 1,
	@IsTest BIT = 0
AS
/*
	Created: 20181212@Elodie
	Task : Select PT info when update PT
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		• @RoleId:
			= 4: Update super 
			= 3: Update master 
			= 2: Update agent 			
	Example: 
		EXEC CS_CustSetting_PTSetting_Sel @RoleId = 4, @CustID = 33418956, @IsTest = 1
		EXEC CS_CustSetting_PTSetting_Sel @RoleId = 3, @CustID = 33418956, @IsTest = 1
		EXEC CS_CustSetting_PTSetting_Sel @RoleId = 2, @CustID = 33418957, @IsTest = 1
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId

	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	IF @RoleId = 4
	BEGIN
		SELECT cs.sporttype, cs.bettype, cs.Islive, MIN(cs.SuperPT + cs.MasterPT + cs.AgentPT) AS MinPTDownline, MAX(cs.SuperPT + cs.MasterPT + cs.AgentPT) AS MaxPTDownline 
		INTO #PTDownlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPTGroup_Member(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 2
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.SuperPT) AS MaxSuperPT
		INTO #PTMaster4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPT_Agent(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT AS SuperMinPT, spt.MaxPT AS SuperMaxPT, 
			0 AS MinSuperMinPT, ISNULL(dl.MinPTDownline,spt.MaxPT) AS MaxSuperMinPT, 
			CASE WHEN ISNULL(dl.MaxPTDownline,0) > ISNULL(mpt.MaxSuperPT,0) THEN ISNULL(dl.MaxPTDownline,0) ELSE ISNULL(mpt.MaxSuperPT,0) END AS MinSuperMaxPT, ps.MaxPT AS MaxSuperMaxPT
		FROM dbo.f_CS_GetPT_Agent(@CustId) spt	
			LEFT JOIN #PTDownlines4 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
			LEFT JOIN #PTMaster4 mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductSettingDetail ps WITH (NOLOCK) ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType	
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.MasterPT + cs.AgentPT) AS MaxPTDownline 
		INTO #PTDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetPTGroup_Member(ci.custid) cs
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
		WHERE ci.srecommend = @SuperId AND ci.roleid = 2
		GROUP BY cs.sporttype, cs.bettype, cs.Islive

		SELECT ft.SportType, ft.Bettype, ft.IsLive, mpt.SuperPT,
			CASE WHEN spt.MinPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MinPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END AS MinSuperPT, 
			CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END AS MaxSuperPT
		FROM dbo.f_CS_GetPT_Agent(@SuperId) spt
			INNER JOIN dbo.f_CS_GetPT_Agent(@CustID) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			LEFT JOIN #PTDownlines3 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive		
	END	
	ELSE IF @RoleId = 2
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 
			CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END AS MinAllowedPT, 
			CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAllowedPT, 
			apt.MasterPT, apt.AgentPT,
			0 AS MinMasterPT, 
			CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxMasterPT,
			0 AS MinAgentPT, 
			CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAgentPT
		FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
			INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
			INNER JOIN dbo.f_CS_GetPT_Agent (@CustID) apt ON apt.SportType = mpt.SportType AND apt.BetType = mpt.BetType AND apt.IsLive = mpt.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
	END	
END
GO
