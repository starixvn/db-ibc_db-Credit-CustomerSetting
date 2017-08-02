/*
	Created: Elodie
	Task: Adjust Setting for BetRadarVS
	DB: DBCUST/CustDB
	Date: 20170801
*/ 
ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @msgDone NVARCHAR(200) = 'Done for sporttype %d, bettype %d.'
	
	DECLARE @fSportType SMALLINT, @fBetType SMALLINT, @tSportType SMALLINT, @tBetType SMALLINT, @IsLive BIT
	DECLARE @Threshold INT = 1000000
	DECLARE @MaxCustID INT = 0, @MinCustID INT = 0	
	CREATE TABLE #tblCust_BetSetting (custid INT,SportType SMALLINT, Bettype SMALLINT,  minbet MONEY, maxbet MONEY, maxpermatch MONEY)
	CREATE TABLE #tblCustNew_BetSetting (custid INT PRIMARY KEY,SportType SMALLINT, Bettype SMALLINT,  minbet MONEY, maxbet MONEY, maxpermatch MONEY)	
	CREATE TABLE #tblCustOld_BetSetting (custid INT PRIMARY KEY,SportType SMALLINT, Bettype SMALLINT,  minbet MONEY, maxbet MONEY, maxpermatch MONEY)

	CREATE TABLE #tblCust_PT (custid INT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY, MinPositionTaking SMALLMONEY)
	CREATE TABLE #tblCustNew_PT (custid INT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY, MinPositionTaking SMALLMONEY)
	CREATE TABLE #tblCustOld_PT (custid INT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY, MinPositionTaking SMALLMONEY)	
	
	DECLARE @ProductID TINYINT = 28
	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
	INSERT INTO #DestinationSportBetType
	SELECT	202, 1501, SportType, BetType, 0, SettingType
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (1,6)

	INSERT INTO #DestinationSportBetType
	SELECT	202, 15, SportType, BetType, 0, SettingType
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (2)

	--------------------------------------PT Setting-------------------------------------------------	
	SELECT TOP (1) @fBetType = fBetType, @fSportType = fSportType , @tSportType = tSportType, @tBetType = tBetType
	FROM #DestinationSportBetType		
	WHERE SettingType = 1

	--AGENT LEVEL
	WHILE (1 = 1 )
	BEGIN
		INSERT INTO #tblCustNew_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking, MinPositionTaking)			
		SELECT DISTINCT TOP (@Threshold) cs.CustID, cs.SuperPT, CS.MasterPT, cs.AgentPT, cs.IsAutoMasterPT, cs.AutoMasterPT, cs.IsAutoSuperPT, cs.AutoSuperPT, cs.MinPT
		FROM dbo.CustPTSetting3rd_Agent cs WITH (NOLOCK) 			
		WHERE cs.SportType = @tSportType AND cs.BetType = @tBetType
			AND cs.CustID > @MinCustID
		ORDER BY cs.custid

		IF @@ROWCOUNT = 0 
		BEGIN
			TRUNCATE TABLE #tblCust_PT
			TRUNCATE TABLE #tblCustOld_PT
			TRUNCATE TABLE #tblCustNew_PT
				
			BREAK
		END
	
		INSERT INTO #tblCustOld_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking, MinPositionTaking)			
		SELECT DISTINCT cs.CustID, CS.spositiontaking, CS.mpositiontaking, cs.apositiontaking, cs.isautompositiontaking, cs.autompositiontaking, cs.isautopositiontaking, cs.autopositiontaking, co.minpositiontaking
		FROM custSettingGame cs WITH (NOLOCK) 
			INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype	
		WHERE CS.sporttype = @fSportType AND cs.BetType = @fBetType
			AND cs.CustID > @MinCustID AND cs.custid <= @MaxCustID
		ORDER BY cs.custid

		INSERT INTO #tblCust_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking)			
		SELECT co.CustID, co.spositiontaking, co.mpositiontaking, co.apositiontaking, co.isautompositiontaking, co.autompositiontaking, co.isautopositiontaking, co.autopositiontaking, co.minpositiontaking
		FROM #tblCustNew_PT cn
			INNER JOIN #tblCustOld_PT co ON co.custid = cn.custid 
		WHERE (
				cn.SPositionTaking * 100 <> co.SPositionTaking
				OR cn.MPositionTaking * 100 <> co.MPositionTaking
				OR cn.APositionTaking * 100 <> co.APositionTaking
				OR cn.IsAutoMPositionTaking <> co.IsAutoMPositionTaking
				OR cn.AutoMPositionTaking * 100 <> co.AutoMPositionTaking
				OR cn.IsAutoPositionTaking <> co.IsAutoPositionTaking
				OR cn.AutoPositionTaking * 100 <> co.AutoPositionTaking
				OR cn.MinPositionTaking  * 100 <> co.MinPositionTaking 
				)

		UPDATE csa
		SET	csa.SuperPT = cs.spositiontaking  *100
			,csa.MasterPT =  cs.mpositiontaking  *100
			,csa.AgentPT = cs.apositiontaking  *100
			,csa.IsAutoMasterPT = cs.isautompositiontaking
			,csa.AutoMasterPT = cs.autompositiontaking *100
			,csa.IsAutoSuperPT = cs.isautopositiontaking 
			,csa.AutoSuperPT = cs.autopositiontaking  *100
			,csa.MinPT = cs.minpositiontaking *100
		FROM dbo.CustPTSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #tblCust_PT cs WITH (NOLOCK) ON cs.custid = csa.custid
		WHERE csa.SportType = @tSportType
	
		SELECT @MinCustID = @MaxCustID			

		TRUNCATE TABLE #tblCust_PT
		TRUNCATE TABLE #tblCustOld_PT
		TRUNCATE TABLE #tblCustNew_PT
	END

	--Member LEVEL
	WHILE (1 = 1 )
	BEGIN
		INSERT INTO #tblCustNew_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking)			
		SELECT DISTINCT TOP (@Threshold) cs.CustID, cs.SuperPT, CS.MasterPT, cs.AgentPT, cs.IsAutoMasterPT, cs.AutoMasterPT, cs.IsAutoSuperPT, cs.AutoSuperPT
		FROM dbo.CustPTSetting3rd_Member cs WITH (NOLOCK) 			
		WHERE cs.SportType = @tSportType AND cs.BetType = @tBetType
			AND cs.CustID > @MinCustID
		ORDER BY cs.custid

		IF @@ROWCOUNT = 0 
			BREAK
	
		INSERT INTO #tblCustOld_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking, MinPositionTaking)			
		SELECT DISTINCT cs.CustID, CS.spositiontaking, CS.mpositiontaking, cs.apositiontaking, cs.isautompositiontaking, cs.autompositiontaking, cs.isautopositiontaking, cs.autopositiontaking, co.minpositiontaking
		FROM custSettingGame cs WITH (NOLOCK) 
			INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype	
		WHERE CS.sporttype = @fSportType AND cs.BetType = @fBetType
			AND cs.CustID > @MinCustID AND cs.custid <= @MaxCustID
		ORDER BY cs.custid

		INSERT INTO #tblCust_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking)			
		SELECT co.CustID, co.spositiontaking, co.mpositiontaking, co.apositiontaking, co.isautompositiontaking, co.autompositiontaking, co.isautopositiontaking, co.autopositiontaking, co.minpositiontaking
		FROM #tblCustNew_PT cn
			INNER JOIN #tblCustOld_PT co ON co.custid = cn.custid 
		WHERE (
				cn.SPositionTaking * 100 <> co.SPositionTaking
				OR cn.MPositionTaking * 100 <> co.MPositionTaking
				OR cn.APositionTaking * 100 <> co.APositionTaking
				OR cn.IsAutoMPositionTaking <> co.IsAutoMPositionTaking
				OR cn.AutoMPositionTaking * 100 <> co.AutoMPositionTaking
				OR cn.IsAutoPositionTaking <> co.IsAutoPositionTaking
				OR cn.AutoPositionTaking * 100 <> co.AutoPositionTaking
				OR cn.MinPositionTaking  * 100 <> co.MinPositionTaking 
				)

		UPDATE csa
		SET	csa.SuperPT = cs.spositiontaking  *100
			,csa.MasterPT =  cs.mpositiontaking  *100
			,csa.AgentPT = cs.apositiontaking  *100
			,csa.IsAutoMasterPT = cs.isautompositiontaking
			,csa.AutoMasterPT = cs.autompositiontaking *100
			,csa.IsAutoSuperPT = cs.isautopositiontaking 
			,csa.AutoSuperPT = cs.autopositiontaking  *100
			,csa.MinPT = cs.minpositiontaking *100
		FROM dbo.CustPTSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #tblCust_PT cs WITH (NOLOCK) ON cs.custid = csa.custid
		WHERE csa.SportType = @tSportType
	
		SELECT @MinCustID = @MaxCustID			
	END

	--MEMBER LEVEL
	UPDATE csm
	SET	csm.SuperPT = cs.spositiontaking  *100
		,csm.MasterPT =  cs.mpositiontaking  *100
		,csm.AgentPT = cs.apositiontaking  *100
		,csm.IsAutoMasterPT = cs.isautompositiontaking
		,csm.AutoMasterPT = cs.autompositiontaking *100
		,csm.IsAutoSuperPT = cs.isautopositiontaking 
		,csm.AutoSuperPT = cs.autopositiontaking  *100
	FROM dbo.custSettingGame cs WITH(NOLOCK)
		INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
		INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK) ON csm.custid = cs.custid and csm.sporttype = tSportType and csm.bettype = tBetType	
	WHERE ci.roleid = 1 AND Enabled = 1
			AND (
				cs.SPositionTaking  * 100 <> csm.SuperPT
				OR cs.MPositionTaking  * 100 <> csm.MasterPT
				OR cs.APositionTaking  * 100 <> csm.AgentPT
				OR cs.IsAutoMPositionTaking <> csm.IsAutoMasterPT
				OR cs.AutoMPositionTaking * 100 <> csm.AutoMasterPT
				OR cs.IsAutoPositionTaking <> csm.IsAutoSuperPT
				OR cs.AutoPositionTaking  * 100 <> csm.AutoSuperPT
				)

	--------------------------------------Bet Setting-------------------------------------------------		
	--Agent Level
	UPDATE csa
	SET csa.minBet = cs.MinBet,       
		csa.MaxBet = cs.MaxBet,   
		csa.maxperMatch = cs.MaxPerGameType
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType
		INNER JOIN dbo.CustBetSetting3rd_Agent csa WITH(ROWLOCK,UPDLOCK) ON csa.custid = cs.custid and csa.sporttype = tSportType and csa.bettype = tBetType	
	WHERE c.roleid IN (2,3,4) AND Enabled = 1
			AND (
				cs.minBet <> csa.minBet
				OR cs.MaxBet <> csa.MaxBet
				OR cs.MaxPerGameType <> csa.maxperMatch			
				)

	--Member Level
	UPDATE csm
	SET csm.minBet = cs.minbet,       
		csm.MaxBet = cs.MaxBet,   
		csm.maxperMatch = cs.MaxPerGameType
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType
		INNER JOIN dbo.CustBetSetting3rd_Member csm WITH(ROWLOCK,UPDLOCK) ON csm.custid = cs.custid and csm.sporttype = tSportType and csm.bettype = tBetType	
	WHERE c.roleid = 1 AND Enabled = 1
			AND (
				cs.minBet <> csm.minBet
				OR cs.MaxBet <> csm.MaxBet
				OR cs.MaxPerGameType <> csm.maxperMatch			
				)

	DROP TABLE #DestinationSportBetType		