/*<info serverAlias="DBCUST-CUSTDB" executers="bodbAdminNet,bodbDownlineNet,bodbDownlineNetView,bodbExtAccNet" viewers="" isFunction="0"></info>*/

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
		
	Param's Explanation:
		• @RoleId:
			= 4: Create super 
			= 3: Create master 
			= 2: Create agent 			
	Example: 
		EXEC CS_PTSetting_CustomerIns_Sel @RoleId = 4, @IsTest = 1
		EXEC CS_PTSetting_CustomerIns_Sel @RoleId = 3, @CustID = 33418956, @IsTest = 1
		EXEC CS_PTSetting_CustomerIns_Sel @RoleId = 2, @CustID = 33418957, @IsTest = 1
*/

BEGIN
	SET NOCOUNT ON
	
	/********************************************* Position Taking: SettingType = 1 ***********************************/
	SELECT t.* INTO #SportBettypeFilter1
	FROM dbo.f_CS_SportBetTypeSettingSelect(@ProductID,1, @IsTest) t
	
	IF @RoleId = 4
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinSuperMinPT, ps.MaxPT AS MaxSuperMinPT, 0 AS MinSuperMaxPT, ps.MaxPT AS MaxSuperMaxPT
		FROM dbo.CS_ProductSettingDetail ps WITH (NOLOCK)
			INNER JOIN #SportBettypeFilter1 ft ON ps.SportType = ft.SportType AND ps.BetType = ft.BetType AND ps.IsLive = ft.IsLive AND ps.SettingType = ft.SettingType
	END
	ELSE IF @RoleId = 3
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, 0 AS MinSuperPT, pt.MaxPT AS MaxSuperPT
		FROM dbo.f_CS_GetPT_Agent (@CustID)	pt 		
			INNER JOIN #SportBettypeFilter1 ft ON pt.SportType = ft.SportType AND pt.BetType = ft.BetType AND pt.IsLive = ft.IsLive
	END	
	ELSE IF @RoleId = 2
	BEGIN
		SELECT ft.SportType, ft.Bettype, ft.IsLive, spt.MinPT - mpt.SuperPT AS MinAllowedPT, spt.MaxPT - mpt.SuperPT AS MaxAllowedPT, 0 AS MinMasterPT, spt.MaxPT - mpt.SuperPT AS MaxMasterPT, 0 AS MinAgentPT, spt.MaxPT - mpt.SuperPT AS MaxAgentPT
		FROM CustInfo ci WITH (NOLOCK) 
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.srecommend) spt 			
			CROSS APPLY dbo.f_CS_GetPT_Agent (ci.custid) mpt 
			INNER JOIN #SportBettypeFilter1 ft ON spt.SportType = ft.SportType AND spt.BetType = ft.BetType AND spt.IsLive = ft.IsLive AND mpt.SportType = ft.SportType AND mpt.BetType = ft.BetType AND mpt.IsLive = ft.IsLive 
		WHERE ci.custid = @CustId
	END	
END
GO
