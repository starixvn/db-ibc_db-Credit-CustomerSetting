/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_CommBetSetting_Sel
	@RoleId TINYINT,
	@CustID INT,	
	@ProductID TINYINT = 1,
	@IsTest BIT = 0
AS
/*
	Created: 20181212@Elodie
	Task : Select some info of commission and betsetting when update comm and bet setting
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190627@Elodie: Apply currency min bet constrain for Bet Setting [Redmine:#115126]
				
	Param's Explanation:
		• @RoleId:
			= 4: Update super 
			= 3: Update master 
			= 2: Update agent 
			= 1: Update member 
	Example: 
		EXEC CS_CustSetting_CommBetSetting_Sel @RoleId = 4, @CustId = 33554349, @IsTest = 1
		EXEC CS_CustSetting_CommBetSetting_Sel @RoleId = 3, @CustID = 34239602, @IsTest = 1
		EXEC CS_CustSetting_CommBetSetting_Sel @RoleId = 2, @CustID = 34239985, @IsTest = 1 
		EXEC CS_CustSetting_CommBetSetting_Sel @RoleId = 1, @CustID = 33554405, @IsTest = 1 
		
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @uGroup VARCHAR(3), @IsGroupComm BIT, @Currency INT
	
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend, @Currency = currency 
	FROM dbo.custInfo WITH (NOLOCK) 
	WHERE custid = @CustID AND roleid = @RoleId

	/********************************************* Comm & BetSetting: SettingType = 2 ***********************************/
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t
	
	IF @RoleId = 4
	BEGIN
		SELECT mb.sporttype, mb.bettype, mb.Islive, 
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.CustId = ci.custid
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mb.sporttype, mb.bettype, mb.Islive
		
		SELECT mc.sporttype, mc.bettype, mc.Islive, mc.GroupId, MAX(mc.Discount) AS MaxCommDownline
		INTO #CommDownlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) mc
			INNER JOIN #SportBettypeFilter2 ft ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mc.sporttype, mc.bettype, mc.Islive, mc.GroupId

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(mc.MaxCommDownline,0) AS MinComm, CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END AS MaxComm,
			sc.Discount AS Comm,
			CASE WHEN gb.MinBet > ISNULL(mb.MaxMaxBetDownline,0) THEN gb.MinBet ELSE ISNULL(mb.MaxMaxBetDownline,0) END AS MinMaxBet, 
			ISNULL(mb.MaxMaxPerEventDownline,0) AS MinMaxPerEvent, 
			sb.MaxBet AS MaxBet, sb.MaxPerEvent AS MaxPerEvent
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN dbo.CS_ProductBetSetting gb WITH (NOLOCK) ON gb.SportType = ps.SportType AND gb.BetType = ps.BetType AND gb.IsLive = ps.IsLive AND gb.Currency = @Currency
			INNER JOIN #SportBettypeFilter2 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive 
			LEFT JOIN #BetDownlines4 mb ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
			LEFT JOIN dbo.f_CS_GetDiscount_Agent (@CustID) sc ON sc.SportType = ft.SportType AND sc.BetType = ft.BetType AND sc.IsLive = ft.IsLive			
			LEFT JOIN #CommDownlines4 mc ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive AND sc.groupID = mc.groupID
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND  gc.GroupId = sc.GroupId
		WHERE sb.CustId = @CustID

		DROP TABLE #BetDownlines4
		DROP TABLE #CommDownlines4
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ab.sporttype, ab.bettype, ab.Islive, 
			MAX(ab.MaxBet) AS MaxMaxBetDownline, MAX(ab.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.CustId = ci.custid
			INNER JOIN #SportBettypeFilter2 ft ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY ab.sporttype, ab.bettype, ab.Islive

		SELECT ac.sporttype, ac.bettype, ac.Islive, ac.groupID, MAX(ac.Discount) AS MaxCommDownline
		INTO #CommDownlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) ac
			INNER JOIN #SportBettypeFilter2 ft ON ac.SportType = ft.SportType AND ac.BetType = ft.BetType AND ac.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY ac.sporttype, ac.bettype, ac.Islive, ac.groupID

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(ac.MaxCommDownline,0) AS MinComm, sc.Discount AS MaxComm, mc.Discount AS Comm,
			CASE WHEN gb.MinBet > ISNULL(ab.MaxMaxBetDownline,0) THEN gb.MinBet ELSE ISNULL(ab.MaxMaxBetDownline,0) END AS MinMaxBet, 
			sb.MaxBet AS MaxMaxBet,
			ISNULL(ab.MaxMaxPerEventDownline,0) AS MinMaxPerEvent, sb.MaxPerEvent AS MaxMaxPerEvent,
			mb.MaxBet AS MaxBet, mb.MaxPerEvent AS MaxPerEvent
		FROM dbo.f_CS_GetDiscount_Agent (@SuperId) sc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) mc ON mc.sporttype = sc.sporttype AND mc.bettype = sc.bettype AND mc.isLive = sc.isLive AND mc.groupID = sc.groupID			
			RIGHT JOIN dbo.CS_CustBetSetting_Agent mb ON mb.SportType = mc.SportType AND mb.BetType = mc.BetType AND mb.IsLive = mc.IsLive 
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = mb.SportType AND sb.BetType = mb.BetType AND sb.IsLive = mb.IsLive 
			INNER JOIN #SportBettypeFilter2 ft ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductBetSetting gb WITH (NOLOCK) ON gb.SportType = ft.SportType AND gb.BetType = ft.BetType AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN #CommDownlines3 ac WITH (NOLOCK) ON ac.SportType = ft.SportType AND ac.BetType = ft.BetType AND ac.IsLive = ft.IsLive AND sc.groupID = ac.groupID
			LEFT JOIN #BetDownlines3 ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive  AND gc.GroupId = sc.GroupId
		WHERE mb.CustId = @CustID AND sb.CustId = @SuperId

		DROP TABLE #BetDownlines3
		DROP TABLE #CommDownlines3
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT memb.sporttype, memb.bettype, memb.Islive,
			MAX(memb.MaxBet) AS MaxMaxBetDownline, MAX(memb.MaxPerEvent) AS MaxMaxPerEventDownline
		INTO #BetDownlines2
		FROM dbo.customer c WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.CustId = c.custid 
			INNER JOIN #SportBettypeFilter2 ft ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
		WHERE c.recommend = @CustId AND c.roleid = 1
		GROUP BY memb.sporttype, memb.bettype, memb.Islive

		SELECT memc.sporttype, memc.bettype, memc.Islive, ISNULL(gc.GroupId,0) AS GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #CommDownlines2
		FROM dbo.customer c WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Member(c.custid) memc 
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustId AND c.roleid = 1
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId
		
		SELECT memc.sporttype, memc.bettype, memc.Islive, ISNULL(gc.GroupId,0) AS GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #GroupCommDownlines2
		FROM dbo.f_CS_GetGroupDiscount_Member(@CustID) memc  
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.Bettype AND gc.IsLive = ft.IsLive AND memc.uGroup = gc.uGroup
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			CASE WHEN ISNULL(memc.MaxCommDownline,0) > ISNULL(dlg.MaxCommDownline,0) THEN ISNULL(memc.MaxCommDownline,0) ELSE ISNULL(dlg.MaxCommDownline,0) END AS MinComm, 
			mc.Discount AS MaxComm, ac.Discount AS Comm,
			CASE WHEN gb.MinBet > ISNULL(memb.MaxMaxBetDownline,0) THEN gb.MinBet ELSE ISNULL(memb.MaxMaxBetDownline,0) END AS MinMaxBet, 
			mb.MaxBet AS MaxMaxBet, 
			ISNULL(memb.MaxMaxPerEventDownline,0) AS MinMaxPerEvent, mb.MaxPerEvent AS MaxMaxPerEvent,
			ab.MaxBet AS MaxBet, ab.MaxPerEvent AS MaxPerEvent
		FROM dbo.f_CS_GetDiscount_Agent (@MasterId) mc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) ac ON ac.sporttype = mc.sporttype AND ac.bettype = mc.bettype AND ac.isLive = mc.isLive AND ac.groupID = mc.groupID			
			RIGHT JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.SportType = mc.SportType AND mb.BetType = mc.BetType AND mb.IsLive = mc.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = mb.SportType AND ab.BetType = mb.BetType AND ab.IsLive = mb.IsLive
			INNER JOIN #SportBettypeFilter2 ft ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductBetSetting gb WITH (NOLOCK) ON gb.SportType = ft.SportType AND gb.BetType = ft.BetType AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN #BetDownlines2 memb ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
			LEFT JOIN #CommDownlines2 memc ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive AND mc.groupID = memc.GroupId
			LEFT JOIN #GroupCommDownlines2 dlg ON dlg.SportType = ft.SportType AND dlg.BetType = ft.BetType AND dlg.IsLive = ft.IsLive AND mc.groupID = dlg.GroupId
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = mc.GroupId
		WHERE ab.CustId = @CustID AND mb.CustId = @MasterId

		DROP TABLE #BetDownlines2
		DROP TABLE #CommDownlines2
		DROP TABLE #GroupCommDownlines2
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT @uGroup = ugroup FROM dbo.customer WITH (NOLOCK) WHERE custid = @CustID
		SELECT @IsGroupComm = IsGroupComm FROM dbo.CS_CustSettingMode WITH (NOLOCK) WHERE custid = @CustID
		
		IF @IsGroupComm = 1
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
				0 AS MinComm, ac.Discount AS MaxComm, memc.PlayerDiscount AS Comm,
				gb.MinBet AS MinMaxBet, ab.MaxBet AS MaxMaxBet,
				0 AS MinMaxPerEvent, ab.MaxPerEvent AS MaxMaxPerEvent,
				memb.MaxBet AS MaxBet, memb.MaxPerEvent AS MaxPerEvent
			FROM dbo.f_CS_GetDiscount_Agent (@AgentId) ac
				INNER JOIN dbo.f_CS_GetGroupDiscount_Member(@AgentId) memc ON memc.sporttype = ac.sporttype AND memc.bettype = ac.bettype AND memc.isLive = ac.isLive AND memc.uGroup = @uGroup				
				RIGHT JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ac.SportType AND ab.BetType = ac.BetType AND ab.IsLive = ac.IsLive
				INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.SportType = ab.SportType AND memb.BetType = ab.BetType AND memb.IsLive = ab.IsLive
				INNER JOIN #SportBettypeFilter2 ft ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
				INNER JOIN dbo.CS_ProductBetSetting gb WITH (NOLOCK) ON gb.SportType = ft.SportType AND gb.BetType = ft.BetType AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
				LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = ac.GroupId 
			WHERE (gc.uGroup = @uGroup OR gc.GroupId IS NULL) AND ab.CustId = @AgentId AND memb.CustId = @CustID 
		END
		ELSE
		BEGIN
			SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
				0 AS MinComm, ac.Discount AS MaxComm, memc.PlayerDiscount AS Comm,
				gb.MinBet AS MinMaxBet, ab.MaxBet AS MaxMaxBet,
				0 AS MinMaxPerEvent, ab.MaxPerEvent AS MaxMaxPerEvent,
				memb.MaxBet AS MaxBet, memb.MaxPerEvent AS MaxPerEvent
			FROM dbo.f_CS_GetDiscount_Agent (@AgentId) ac
				INNER JOIN dbo.f_CS_GetDiscount_Member(@CustID) memc ON memc.sporttype = ac.sporttype AND memc.bettype = ac.bettype AND memc.isLive = ac.isLive				
				RIGHT JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ac.SportType AND ab.BetType = ac.BetType AND ab.IsLive = ac.IsLive
				INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.SportType = ab.SportType AND memb.BetType = ab.BetType AND memb.IsLive = ab.IsLive
				INNER JOIN #SportBettypeFilter2 ft ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
				INNER JOIN dbo.CS_ProductBetSetting gb WITH (NOLOCK) ON gb.SportType = ps.SportType AND gb.BetType = ps.BetType AND gb.IsLive = ps.IsLive AND gb.Currency = @Currency
				LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = ac.GroupId 
			WHERE (gc.uGroup = @uGroup OR gc.GroupId IS NULL) AND ab.CustId = @AgentId AND memb.CustId = @CustID
		END
	END
	
	DROP TABLE #SportBettypeFilter2
END
GO
