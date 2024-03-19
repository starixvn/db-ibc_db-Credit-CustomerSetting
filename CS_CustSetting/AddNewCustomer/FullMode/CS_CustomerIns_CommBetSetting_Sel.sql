/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,wsv_nap,bodbDownlineNet,wsv_alp,bodbDownlineNetView,wsv_alpv" viewers="" isFunction="0"></info>*/

ALTER PROCEDURE CS_CustomerIns_CommBetSetting_Sel
	@RoleId TINYINT,
	@CustID INT	= NULL,
	@Currency INT = NULL, 
	--@uGroup VARCHAR(3) = NULL,
	@ProductID TINYINT = 1,
	@IsTest BIT = 0
AS
/*
	Created: 20181212@Elodie
	Task : Select some info of commission and betsetting when creating new downline
	DB: DBCUST/CustDB
	Original:

	Revisions:
		- 20181212@Elodie: Initial SP [Redmine:#105338]
		- 20190627@Elodie: Apply currency min bet constrain for Bet Setting [Redmine:#115126]
		- 20190712@Elodie: Remove currency min bet constrain for Bet Setting [Redmine:#116723]
		- 20190724@Elodie: Apply global max bet setting constrain [Redmine:#117459]

	Param's Explanation:
		• @RoleId:
			= 4: Create super 
			= 3: Create master 
			= 2: Create agent 
			= 1: Create member 
	Example: 
		EXEC CS_CustomerIns_CommBetSetting_Sel @RoleId = 4, @IsTest = 1
		EXEC CS_CustomerIns_CommBetSetting_Sel @RoleId = 3, @CustID = 33418956, @IsTest = 1
		EXEC CS_CustomerIns_CommBetSetting_Sel @RoleId = 2, @CustID = 33418957, @IsTest = 1 
		EXEC CS_CustomerIns_CommBetSetting_Sel @RoleId = 1, @CustID = 33418960, @uGroup = 'cna', @IsTest = 1 
		
*/

BEGIN
	SET NOCOUNT ON
	
	/********************************************* Comm & BetSetting: SettingType = 2 ***********************************/	

	SELECT t.* INTO #SportBettypeFilter2
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID, 2, @IsTest) t
	
	IF @RoleId <> 4
	BEGIN 
		SELECT @Currency =  ci.currency FROM dbo.custInfo ci WITH (NOLOCK) WHERE ci.custid = @CustID
	END

	IF @RoleId = 4
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, 
			CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END AS MaxComm,
			CASE WHEN gc.GroupId IS NULL THEN ps.MaxDiscount ELSE gc.MaxValue END AS Comm,
			0 AS MinMaxBet, gb.MaxBet AS MaxBet, gb.MaxBet AS MaxMaxBet, gb.MaxPerEvent AS MaxPerEvent, gb.MaxPerEvent AS MaxMaxPerEvent
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter2 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
			LEFT JOIN dbo.CS_ProductBetSetting gb ON gb.SportType = ft.SportType AND gb.BetType = ft.Bettype AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, sc.Discount AS MaxComm, sc.Discount AS Comm,
			0 AS MinMaxBet, CASE WHEN bs.MaxBet > gb.MaxBet THEN gb.MaxBet ELSE bs.MaxBet END AS MaxMaxBet, bs.MaxBet, 
			0 AS MinMaxPerEvent, CASE WHEN bs.MaxPerEvent > gb.MaxPerEvent THEN gb.MaxPerEvent ELSE bs.MaxPerEvent END AS MaxMaxPerEvent, bs.MaxPerEvent
		FROM dbo.f_CS_GetDiscount_Agent (@CustID) sc			
			RIGHT JOIN dbo.CS_CustBetSetting_Agent bs WITH (NOLOCK) ON bs.SportType = sc.SportType AND bs.BetType = sc.BetType AND bs.IsLive = sc.IsLive			
			INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductBetSetting gb ON gb.SportType = ft.SportType AND gb.BetType = ft.Bettype AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive  AND gc.GroupId = sc.GroupId
		WHERE bs.CustId = @CustID
	END
	ELSE IF @RoleId = 2
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, mc.Discount AS MaxComm, mc.Discount AS Comm,
			0 AS MinMaxBet, CASE WHEN bs.MaxBet > gb.MaxBet THEN gb.MaxBet ELSE bs.MaxBet END AS MaxMaxBet, bs.MaxBet, 
			0 AS MinMaxPerEvent, CASE WHEN bs.MaxPerEvent > gb.MaxPerEvent THEN gb.MaxPerEvent ELSE bs.MaxPerEvent END AS MaxMaxPerEvent, bs.MaxPerEvent
		FROM dbo.f_CS_GetDiscount_Agent (@CustID) mc			
			RIGHT JOIN dbo.CS_CustBetSetting_Agent bs WITH (NOLOCK) ON bs.SportType = mc.SportType AND bs.BetType = mc.BetType AND bs.IsLive = mc.IsLive
			INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductBetSetting gb ON gb.SportType = ft.SportType AND gb.BetType = ft.Bettype AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = mc.GroupId
		WHERE bs.CustId = @CustID
	END
	ELSE IF @RoleId = 1
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, gc.GroupId, gc.GroupName,
			0 AS MinComm, ac.Discount AS MaxComm, ac.Discount AS Comm,
			0 AS MinMaxBet, CASE WHEN bs.MaxBet > gb.MaxBet THEN gb.MaxBet ELSE bs.MaxBet END AS MaxMaxBet, bs.MaxBet, 
			0 AS MinMaxPerEvent, CASE WHEN bs.MaxPerEvent > gb.MaxPerEvent THEN gb.MaxPerEvent ELSE bs.MaxPerEvent END AS MaxMaxPerEvent, bs.MaxPerEvent
		FROM dbo.f_CS_GetDiscount_Agent (@CustID) ac			
			RIGHT JOIN dbo.CS_CustBetSetting_Agent bs WITH (NOLOCK) ON bs.SportType = ac.SportType AND bs.BetType = ac.BetType AND bs.IsLive = ac.IsLive
			INNER JOIN #SportBettypeFilter2 ft ON bs.SportType = ft.SportType AND bs.BetType = ft.BetType AND bs.IsLive = ft.IsLive
			INNER JOIN dbo.CS_ProductBetSetting gb ON gb.SportType = ft.SportType AND gb.BetType = ft.Bettype AND gb.IsLive = ft.IsLive AND gb.Currency = @Currency
			LEFT JOIN dbo.CS_GroupConfig gc ON gc.SportType = ft.SportType AND gc.BetType = ft.BetType AND gc.IsLive = ft.IsLive AND gc.GroupId = ac.GroupId 
		WHERE bs.CustId = @CustID --AND (gc.uGroup = @uGroup OR gc.GroupId IS NULL)
	END
	
	DROP TABLE #SportBettypeFilter2
END
GO
