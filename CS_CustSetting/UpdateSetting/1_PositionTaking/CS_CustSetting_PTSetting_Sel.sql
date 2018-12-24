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
		SELECT ft.SportType, ft.Bettype, ft.IsLive, cs.MinPT, cs.MaxPT, 0 AS MinMinPT, MIN(csa.SuperPT + csa.MasterPT + csa.AgentPT) AS MaxMinPT, MAX(csa.SuperPT + csa.MasterPT + csa.AgentPT) AS MinMaxPT, ps.MaxPT AS MaxMaxPT
		FROM dbo.f_CS_GetPT_Agent(@CustID) cs		
			INNER JOIN dbo.f_CS_GetPTGroup_Member(@AgentId) csa ON cs.SportType = csa.SportType AND csa.BetType = cs.BetType AND csa.IsLive = cs.IsLive
			INNER JOIN #SportBettypeFilter1 ft ON cs.SportType = ft.SportType AND cs.BetType = ft.BetType AND cs.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductSettingDetail ps WITH (NOLOCK) ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
		GROUP BY ft.SportType, ft.Bettype, ft.IsLive, cs.MinPT, cs.MaxPT, ps.MaxPT
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinPT, pt.MaxPT AS MaxPT
		FROM dbo.f_CS_GetPT_Agent (@CustID)	pt 		
			INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
	END	
	ELSE IF @RoleId = 2
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT - mpt.SuperPT AS MinPT, spt.MaxPT - mpt.SuperPT AS MaxPT
		FROM CustInfo ci WITH (NOLOCK) 
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.srecommend) spt 			
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.custid) mpt 
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive AND mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive 
		WHERE ci.custid = @CustId
	END	
END
GO
