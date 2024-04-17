/*<info serverAlias="DBCUST-CUSTDB" executers="wsv_nap,wsv_alp,wsv_alpv" viewers="" isFunction="0"></info>*/

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
		EXEC CS_CustSetting_PTSetting_Sel @RoleId = 2, @CustID = 34240046, @IsTest = 1
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @IsEditablePT BIT
	SELECT @IsEditablePT = IsEditablePT FROM f_CS_GetEditablePTDate(@ProductID)
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId

	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	IF @IsEditablePT = 1
	BEGIN
		IF @RoleId = 4
		BEGIN
			SELECT acs.sporttype, acs.bettype, acs.Islive, MAX(acs.SuperPT + acs.MasterPT + acs.AgentPT) AS MaxPTDownline 
			INTO #PTDownlines4
			FROM dbo.custInfo a WITH (NOLOCK) 	
				CROSS APPLY dbo.f_CS_GetPTGroup_Member(a.custid) acs
				INNER JOIN #SportBettypeFilter1 ft ON acs.SportType = ft.SportType AND acs.BetType = ft.BetType AND acs.IsLive = ft.IsLive
			WHERE a.srecommend = @CustId AND a.roleid = 2
			GROUP BY acs.sporttype, acs.bettype, acs.Islive

			SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.SuperPT) AS MaxSuperPT
			INTO #PTMaster4
			FROM dbo.custInfo ci WITH (NOLOCK) 	
				CROSS APPLY dbo.f_CS_GetPT_Agent(ci.custid) cs
				INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			WHERE ci.srecommend = @CustId AND ci.roleid = 3
			GROUP BY cs.sporttype, cs.bettype, cs.Islive
			
			SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT2 AS CurrentSuperMinPT, spt.MaxPT2 AS CurrentSuperMaxPT, 
				spt.MinPT AS SuperMinPT, spt.MaxPT AS SuperMaxPT, 
				0 AS MinSuperMinPT, ps.MaxPT AS MaxSuperMinPT, 
				CASE WHEN ISNULL(dl.MaxPTDownline,0) > ISNULL(mpt.MaxSuperPT,0) THEN ISNULL(dl.MaxPTDownline,0) ELSE ISNULL(mpt.MaxSuperPT,0) END AS MinSuperMaxPT, ps.MaxPT AS MaxSuperMaxPT
			FROM dbo.f_CS_GetPT_Agent(@CustId) spt	
				LEFT JOIN #PTDownlines4 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
				LEFT JOIN #PTMaster4 mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
				INNER JOIN dbo.CS_ProductSettingDetail ps WITH (NOLOCK) ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType			

			DROP TABLE #PTDownlines4
			DROP TABLE #PTMaster4
		END
		ELSE IF @RoleId = 3
		BEGIN
			SELECT cs.sporttype, cs.bettype, cs.Islive, MAX(cs.MasterPT + cs.AgentPT) AS MaxPTDownline, MIN(cs.MasterPT + cs.AgentPT) AS MinPTDownline  
			INTO #PTDownlines3
			FROM dbo.custInfo ci WITH (NOLOCK) 	
				CROSS APPLY dbo.f_CS_GetPT_Agent(ci.custid) cs
				INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			WHERE ci.srecommend = @SuperId AND ci.roleid = 2 AND ci.mrecommend = @CustID
			GROUP BY cs.sporttype, cs.bettype, cs.Islive

			IF @@ROWCOUNT <> 0 --If Master has at least 1 Agent: Range: [Max(0, Super Min PT - (Master PT + Agent PT)); Super Max PT - (Master PT + Agent PT)]
			BEGIN
				SELECT ft.SportType, ft.Bettype, ft.IsLive, mpt.SuperPT2 AS CurrentSuperPT, mpt.SuperPT AS SuperPT,
					CASE WHEN spt.MinPT > ISNULL(dl.MinPTDownline,0) THEN spt.MinPT - ISNULL(dl.MinPTDownline,0) ELSE 0 END AS MinSuperPT, 
					CASE WHEN spt.MaxPT > ISNULL(dl.MaxPTDownline,0) THEN spt.MaxPT - ISNULL(dl.MaxPTDownline,0) ELSE 0 END AS MaxSuperPT
				FROM dbo.f_CS_GetPT_Agent(@SuperId) spt
					INNER JOIN dbo.f_CS_GetPT_Agent(@CustID) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
					LEFT JOIN #PTDownlines3 dl ON spt.SportType = dl.SportType AND spt.BetType = dl.BetType AND spt.IsLive = dl.IsLive
					INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive		
			END
			ELSE --If Master has no Agent: Range: [0; Super Max PT]
			BEGIN
				SELECT ft.SportType, ft.Bettype, ft.IsLive, mpt.SuperPT2 AS CurrentSuperPT, mpt.SuperPT AS SuperPT,
					0 AS MinSuperPT, 
					spt.MaxPT AS MaxSuperPT
				FROM dbo.f_CS_GetPT_Agent(@SuperId) spt
					INNER JOIN dbo.f_CS_GetPT_Agent(@CustID) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
					INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive		
			END
			
			DROP TABLE #PTDownlines3
		END	
		ELSE IF @RoleId = 2
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 
				CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END AS MinAllowedPT, 
				CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAllowedPT, 
				apt.MasterPT2 AS CurrentMasterPT, apt.AgentPT2 AS CurrentAgentPT,
				apt.MasterPT AS MasterPT, apt.AgentPT AS AgentPT,
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
	ELSE
	BEGIN
		IF @RoleId = 4
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT AS CurrentSuperMinPT, spt.MaxPT AS CurrentSuperMaxPT
			FROM dbo.f_CS_GetPT_Agent(@CustId) spt	
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		END
		ELSE IF @RoleId = 3
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, mpt.SuperPT AS CurrentSuperPT
			FROM dbo.f_CS_GetPT_Agent(@CustID) mpt 
				INNER JOIN #SportBettypeFilter1 ft ON mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive		
		END	
		ELSE IF @RoleId = 2
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, 
				CASE WHEN spt.MinPT > mpt.SuperPT THEN spt.MinPT - mpt.SuperPT ELSE 0 END AS MinAllowedPT, 
				CASE WHEN spt.MaxPT > mpt.SuperPT THEN spt.MaxPT - mpt.SuperPT ELSE 0 END AS MaxAllowedPT, 
				apt.MasterPT AS CurrentMasterPT, apt.AgentPT AS CurrentAgentPT
			FROM dbo.f_CS_GetPT_Agent (@SuperId) spt 			
				INNER JOIN dbo.f_CS_GetPT_Agent (@MasterId) mpt ON spt.SportType = mpt.SportType AND spt.BetType = mpt.BetType AND spt.IsLive = mpt.IsLive
				INNER JOIN dbo.f_CS_GetPT_Agent (@CustID) apt ON apt.SportType = mpt.SportType AND apt.BetType = mpt.BetType AND apt.IsLive = mpt.IsLive
				INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive
		END	
	END

	DROP TABLE #SportBettypeFilter1
END
GO
