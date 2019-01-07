/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbExtAccNet" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustSetting_CommBetSetting_Upd
	@RoleId			TINYINT,
	@CustID			INT,
	@CommSetting	VARCHAR(MAX),
	@BetSetting		VARCHAR(MAX),
	@ProductID		TINYINT = 1,
	@IsTest			BIT = 0,

	@SubAccID		INT = 0,
	@UserID			INT = 0,       
	@IP				VARCHAR(15)='',
	@ErrCode		INT	= 0 OUTPUT,
	@MsgType		INT	= 0 OUTPUT,
	@ErrMsg			VARCHAR(MAX) = '' OUTPUT
AS
/*
	Created: 20181212@Elodie
	Task : Update comm and bet setting
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		
	Param's Explanation:
		@RoleId 
			= 4,3,2: Update super, master, agent
				@CommSetting: <ROOT>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "1" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "2" ValueId = "11"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "3" ValueId = "17"/>
								<Comm SportType="1" BetType="1" IsLive="0" GroupId = "4" ValueId = "21"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "5" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "6" ValueId = "11"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "7" ValueId = "17"/>
								<Comm SportType="1" BetType="1" IsLive="1" GroupId = "8" ValueId = "21"/>
								<Comm SportType="1" BetType="5" IsLive="0" GroupId = "5" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="0" GroupId = "6" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="1" GroupId = "7" ValueId = "21"/>	
								...						
							</ROOT>
				@BetSetting: <ROOT>
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								...						
							</ROOT>
			= 1: Update member 
				@CommSetting: <ROOT>
								<Comm SportType="1" BetType="1" IsLive="0" ValueId = "6"/>
								<Comm SportType="1" BetType="1" IsLive="1" ValueId = "6"/>
								<Comm SportType="1" BetType="5" IsLive="0" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="0" ValueId = "21"/>
								<Comm SportType="1" BetType="9999" IsLive="1" ValueId = "21"/>	
								...						
							</ROOT>
				@BetSetting: <ROOT>
								<BetSetting SportType="1" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="1" BetType="9999" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="1" IsLive="1" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="5" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								<BetSetting SportType="2" BetType="9999" IsLive="0" MaxBet = "8000" MaxPerMatch = "80000"/>
								...						
							</ROOT>		
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @SuperId INT, @MasterId INT, @AgentId INT, @uGroup VARCHAR(3)
	SELECT @SuperId = srecommend, @MasterId = mrecommend, @AgentId = recommend FROM dbo.custInfo WITH (NOLOCK) WHERE custid = @CustID AND roleid = @RoleId

	/********************************************* Comm & BetSetting: SettingType = 2 ***********************************/
	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t
	
	IF @RoleId = 4
	BEGIN
		SELECT mb.sporttype, mb.bettype, mb.Islive, mc.GroupId,
			MAX(mb.MaxBet) AS MaxMaxBetDownline, MAX(mb.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(mc.Discount) AS MaxCommDownline
		INTO #Downlines4
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) mc
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.CustId = ci.custid AND mc.sporttype = mb.SportType AND mc.Bettype = mb.BetType AND mc.isLive = mb.IsLive
			INNER JOIN #SportBettypeFilter2 ft ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
		WHERE ci.srecommend = @CustId AND ci.roleid = 3
		GROUP BY mb.sporttype, mb.bettype, mb.Islive, mc.GroupId
		
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(mb.MaxCommDownline,0) AS MinComm, CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END AS MaxComm,
			sc.Discount AS Comm,
			ISNULL(mb.MaxMaxBetDownline,0) AS MinMaxBet, ISNULL(mb.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch,
			sb.MaxBet AS MaxBet, sb.MaxPerMatch AS MaxPerMatch
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter2 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) sc ON sc.SportType = ft.SportType AND sc.BetType = ft.BetType AND sc.IsLive = ft.IsLive			
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive 
			LEFT JOIN #Downlines4 mb ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive AND sc.groupID = mb.groupID
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND  gc.GroupId = sc.GroupId
		WHERE sb.CustId = @CustID
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ab.sporttype, ab.bettype, ab.Islive, ac.groupID, 
			MAX(ab.MaxBet) AS MaxMaxBetDownline, MAX(ab.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(ac.Discount) AS MaxCommDownline
		INTO #Downlines3
		FROM dbo.custInfo ci WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Agent(ci.custid) ac
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.CustId = ci.custid AND ab.SportType = ac.sporttype AND ab.BetType = ac.bettype AND ab.IsLive = ac.isLive
			INNER JOIN #SportBettypeFilter2 ft ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
		WHERE ci.mrecommend = @CustId AND ci.roleid = 2
		GROUP BY ab.sporttype, ab.bettype, ab.Islive, ac.groupID

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			ISNULL(ab.MaxCommDownline,0) AS MinComm, sc.Discount AS MaxComm, mc.Discount AS Comm,
			ISNULL(ab.MaxMaxBetDownline,0) AS MinMaxBet, sb.MaxBet AS MaxMaxBet,
			ISNULL(ab.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch, sb.MaxPerMatch AS MaxMaxPerMatch,
			mb.MaxBet AS MaxBet, mb.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@SuperId) sc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) mc ON mc.sporttype = sc.sporttype AND mc.bettype = sc.bettype AND mc.isLive = sc.isLive AND mc.groupID = sc.groupID
			INNER JOIN #SportBettypeFilter2 ft ON sc.SportType = ft.SportType AND sc.BetType = ft.BetType AND sc.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent mb ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive 
			INNER JOIN dbo.CS_CustBetSetting_Agent sb ON sb.SportType = ft.SportType AND sb.BetType = ft.BetType AND sb.IsLive = ft.IsLive 
			LEFT JOIN #Downlines3 ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive AND sc.groupID = ab.groupID
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive  AND gc.GroupId = sc.GroupId
		WHERE mb.CustId = @CustID AND sb.CustId = @SuperId
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT memb.sporttype, memb.bettype, memb.Islive, gc.GroupId,
			MAX(memb.MaxBet) AS MaxMaxBetDownline, MAX(memb.MaxPerMatch) AS MaxMaxPerMatchDownline, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #Downlines2
		FROM dbo.customer c WITH (NOLOCK) 	
			CROSS APPLY dbo.f_CS_GetDiscount_Member(c.custid) memc 
			INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.CustId = c.custid AND memb.SportType = memc.sporttype AND memb.BetType = memc.bettype AND memb.IsLive = memc.isLive
			INNER JOIN #SportBettypeFilter2 ft ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustId AND c.roleid = 1
		GROUP BY memb.sporttype, memb.bettype, memb.Islive, gc.GroupId
		
		SELECT memc.sporttype, memc.bettype, memc.Islive, gc.GroupId, MAX(memc.PlayerDiscount) AS MaxCommDownline
		INTO #GroupDownlines2
		FROM dbo.f_CS_GetGroupDiscount_Member(@CustID) memc  
			CROSS JOIN dbo.customer c WITH (NOLOCK) 	
			INNER JOIN dbo.CS_CustSettingMode cm WITH (NOLOCK) ON cm.CustId = c.custid 			
			INNER JOIN #SportBettypeFilter2 ft ON memc.SportType = ft.SportType AND memc.BetType = ft.BetType AND memc.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.uGroup = c.ugroup
		WHERE c.recommend = @CustID AND c.roleid = 1 AND cm.IsGroupComm = 1
		GROUP BY memc.sporttype, memc.bettype, memc.Islive, gc.GroupId

		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			CASE WHEN ISNULL(memb.MaxCommDownline,0) > ISNULL(dlg.MaxCommDownline,0) THEN ISNULL(memb.MaxCommDownline,0) ELSE ISNULL(dlg.MaxCommDownline,0) END AS MinComm, 
			mc.Discount AS MaxComm, ac.Discount AS Comm,
			ISNULL(memb.MaxMaxBetDownline,0) AS MinMaxBet, mb.MaxBet AS MaxMaxBet, 
			ISNULL(memb.MaxMaxPerMatchDownline,0) AS MinMaxPerMatch, mb.MaxPerMatch AS MaxMaxPerMatch,
			ab.MaxBet AS MaxBet, ab.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@MasterId) mc
			INNER JOIN dbo.f_CS_GetDiscount_Agent (@CustID) ac ON ac.sporttype = mc.sporttype AND ac.bettype = mc.bettype AND ac.isLive = mc.isLive AND ac.groupID = mc.groupID
			INNER JOIN #SportBettypeFilter2 ft ON mc.SportType = ft.SportType AND mc.BetType = ft.BetType AND mc.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent mb WITH (NOLOCK) ON mb.SportType = ft.SportType AND mb.BetType = ft.BetType AND mb.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			LEFT JOIN #Downlines2 memb ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive AND mc.groupID = memb.GroupId
			LEFT JOIN #GroupDownlines2 dlg ON dlg.SportType = ft.SportType AND dlg.BetType = ft.BetType AND dlg.IsLive = ft.IsLive AND mc.groupID = dlg.GroupId
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = mc.GroupId
		WHERE ab.CustId = @CustID AND mb.CustId = @MasterId
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT @uGroup = ugroup FROM dbo.customer WITH (NOLOCK) WHERE custid = @CustID
		
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, ac.Discount AS MaxComm, memc.PlayerDiscount AS Comm,
			0 AS MinMaxBet, ab.MaxBet AS MaxMaxBet,
			0 AS MinMaxPerMatch, ab.MaxPerMatch AS MaxMaxPerMatch,
			memb.MaxBet AS MaxBet, memb.MaxPerMatch AS MaxPerMatch
		FROM dbo.f_CS_GetDiscount_Agent (@AgentId) ac
			INNER JOIN dbo.f_CS_GetDiscount_Member(@CustID) memc ON memc.sporttype = ac.sporttype AND memc.bettype = ac.bettype AND memc.isLive = ac.isLive
			INNER JOIN #SportBettypeFilter2 ft ON ac.SportType = ft.SportType AND ac.BetType = ft.BetType AND ac.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Agent ab WITH (NOLOCK) ON ab.SportType = ft.SportType AND ab.BetType = ft.BetType AND ab.IsLive = ft.IsLive
			INNER JOIN dbo.CS_CustBetSetting_Member memb WITH (NOLOCK) ON memb.SportType = ft.SportType AND memb.BetType = ft.BetType AND memb.IsLive = ft.IsLive
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = ac.GroupId 
		WHERE (gc.uGroup = @uGroup OR gc.GroupId IS NULL) AND ab.CustId = @AgentId AND memb.CustId = @CustID
	END
END
GO
