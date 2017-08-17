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

	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN

	DECLARE @msgDone NVARCHAR(200) = 'Done for sporttype %d, bettype %d.'

	DECLARE @ProductID TINYINT = 5
	DECLARE @fSportType SMALLINT, @fBetType SMALLINT, @tSportType SMALLINT, @tBetType SMALLINT, @IsLive BIT

	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT, IsFinished BIT)
	INSERT INTO #DestinationSportBetType(fSportType, fBetType,tSportType, tBetType, IsLive,  SettingType, IsFinished)
	SELECT	CASE WHEN SportType IN (190, 191, 199) THEN 180 ELSE SportType END, 
			CASE WHEN SportType IN (190, 191, 199) THEN 1201 ELSE BetType END, 
			SportType, BetType, 0, SettingType, 0
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (1, 2)

	--------------------------------------PT Setting-------------------------------------------------	
	WHILE (1 = 1)
	BEGIN		
		CREATE TABLE #SMAList_PT (custid INT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY, MinPositionTaking SMALLMONEY)
		CREATE TABLE #MemberList_PT (custid INT, SPositionTaking SMALLMONEY, MPositionTaking SMALLMONEY, APositionTaking SMALLMONEY, IsAutoMPositionTaking BIT, AutoMPositionTaking SMALLMONEY, IsAutoPositionTaking BIT, AutoPositionTaking SMALLMONEY)	

		UPDATE TOP (1) #DestinationSportBetType
		SET IsFinished = 1
			,@fBetType = fBetType	
			,@fSportType = fSportType
			,@tBetType = tBetType
			,@tSportType = tSportType
			,@IsLive = IsLive
		WHERE IsFinished = 0
			AND SettingType = 1

		IF @@ROWCOUNT = 0 BREAK
	
		--------------------------------------Get Affected Cust List-------------------------------------------------	
		--Agent Level
		INSERT INTO #SMAList_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking, MinPositionTaking)
		SELECT ci.custid, csa.SuperPT, csa.MasterPT, csa.AgentPT, csa.IsAutoMasterPT, csa.AutoMasterPT, csa.IsAutoSuperPT, csa.AutoSuperPT, csa.MinPT
		FROM dbo.CustSetting3rd cs WITH(NOLOCK) 
			INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
			INNER JOIN dbo.custOverride3rd co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype	
			INNER JOIN dbo.CustPTSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = cs.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType AND csa.SportType = @tSportType AND csa.BetType = @tBetType
				AND ci.roleid IN (2,3,4) AND Enabled = 1			
				AND (
					cs.SPositionTaking * 100 <> csa.SuperPT
					OR cs.MPositionTaking * 100 <> csa.MasterPT
					OR cs.APositionTaking * 100 <> csa.AgentPT
					OR cs.IsAutoMPositionTaking <> csa.IsAutoMasterPT
					OR cs.AutoMPositionTaking * 100 <> csa.AutoMasterPT
					OR cs.IsAutoPositionTaking <> csa.IsAutoSuperPT
					OR cs.AutoPositionTaking * 100 <> csa.AutoSuperPT
					OR co.MinPositionTaking  * 100 <> csa.MinPT 
					)

		RAISERROR('Done: Get the affected SMA list for PT', 0, 1)  WITH NOWAIT
	
		--Member Level
		INSERT INTO #MemberList_PT (custid, SPositionTaking, MPositionTaking, APositionTaking, IsAutoMPositionTaking, AutoMPositionTaking, IsAutoPositionTaking, AutoPositionTaking)
		SELECT ci.custid, csm.SuperPT, csm.MasterPT, csm.AgentPT, csm.IsAutoMasterPT, csm.AutoMasterPT, csm.IsAutoSuperPT, csm.AutoSuperPT
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN dbo.custInfo ci WITH (NOLOCK) ON ci.custid = cs.custid
			INNER JOIN dbo.CustPTSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = cs.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType AND csm.SportType = @tSportType AND csm.BetType = @tBetType
				AND ci.roleid = 1 AND Enabled = 1
				AND (
					cs.SPositionTaking  * 100 <> csm.SuperPT
					OR cs.MPositionTaking  * 100 <> csm.MasterPT
					OR cs.APositionTaking  * 100 <> csm.AgentPT
					OR cs.IsAutoMPositionTaking <> csm.IsAutoMasterPT
					OR cs.AutoMPositionTaking * 100 <> csm.AutoMasterPT
					OR cs.IsAutoPositionTaking <> csm.IsAutoSuperPT
					OR cs.AutoPositionTaking  * 100 <> csm.AutoSuperPT
					)

		RAISERROR('Done: Get the affected member list for PT', 0, 1)  WITH NOWAIT
		-------------------------------------------------Adjust data----------------------------------------------------
		--Agent Level
		UPDATE csa
		SET	csa.spositiontaking = cs.spositiontaking  / 100
			,csa.mpositiontaking =  cs.mpositiontaking  /100
			,csa.apositiontaking = cs.apositiontaking  /100
			,csa.isautompositiontaking = cs.isautompositiontaking
			,csa.autompositiontaking = cs.autompositiontaking /100
			,csa.isautopositiontaking = cs.isautopositiontaking 
			,csa.autopositiontaking = cs.autopositiontaking  /100
		FROM dbo.CustSetting3rd csa WITH(ROWLOCK,UPDLOCK) 
			INNER JOIN #SMAList_PT cs WITH (NOLOCK) ON cs.custid = csa.custid
		WHERE csa.SportType = @fSportType AND csa.BetType = @fBetType
	
		UPDATE csa
		SET	csa.minpositiontaking = cs.minpositiontaking /100
		FROM dbo.custOverride3rd csa WITH(ROWLOCK,UPDLOCK) 
			INNER JOIN #SMAList_PT cs WITH (NOLOCK) ON cs.custid = csa.custid
		WHERE csa.SportType = @fSportType AND csa.BetType = @fBetType		

		RAISERROR('Done: Update the affected SMA list for PT', 0, 1)  WITH NOWAIT

		--MEMBER LEVEL
		UPDATE csm
		SET	csm.spositiontaking = cs.spositiontaking  /100
			,csm.mpositiontaking =  cs.mpositiontaking  /100
			,csm.apositiontaking = cs.apositiontaking  /100
			,csm.isautompositiontaking = cs.isautompositiontaking
			,csm.autompositiontaking = cs.autompositiontaking /100
			,csm.isautopositiontaking = cs.isautopositiontaking 
			,csm.autopositiontaking = cs.autopositiontaking  /100
		FROM dbo.CustSetting3rd csm WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_PT cs WITH (NOLOCK) ON cs.custid = csm.custid
		WHERE csm.SportType = @fSportType AND csm.BetType = @fBetType			

		RAISERROR('Done: Update the affected member list for PT', 0, 1)  WITH NOWAIT

		RAISERROR(@msgDone, 0, 1, @tSportType, @tBetType)  WITH NOWAIT

		DROP TABLE #SMAList_PT
		DROP TABLE #MemberList_PT
	END

	--------------------------------------Bet Setting-------------------------------------------------		
	WHILE (1 = 1)
	BEGIN		
		CREATE TABLE #SMAList_BetSetting (custid INT, minBet MONEY, MaxBet MONEY)
		CREATE TABLE #MemberList_BetSetting (custid INT, minBet MONEY, MaxBet MONEY)

		UPDATE TOP (1) #DestinationSportBetType
		SET IsFinished = 1
			,@fBetType = fBetType	
			,@fSportType = fSportType
			,@tBetType = tBetType
			,@tSportType = tSportType
			,@IsLive = IsLive
		WHERE IsFinished = 0
			AND SettingType = 2

		IF @@ROWCOUNT = 0 BREAK

		--Agent Level
		INSERT INTO #SMAList_BetSetting (custid, minBet, MaxBet)
		SELECT c.custid, csa.minBet, csa.MaxBet
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid
			INNER JOIN dbo.CustBetSetting3rd_Agent csa WITH(NOLOCK) ON csa.custid = cs.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType AND csa.SportType = @tSportType AND csa.BetType = @tBetType
				AND c.roleid IN (2,3,4) AND Enabled = 1
				AND (
					cs.minBet <> csa.minBet
					OR cs.MaxBet <> csa.MaxBet
					)

		RAISERROR('Done: Get the affected SMA list for bet setting', 0, 1)  WITH NOWAIT

		--Member Level
		INSERT INTO #MemberList_BetSetting (custid, minBet, MaxBet)
		SELECT c.custid, csm.minBet, csm.MaxBet
		FROM dbo.CustSetting3rd cs WITH(NOLOCK)
			INNER JOIN custInfo c WITH(NOLOCK) ON cs.CustID = c.custid		
			INNER JOIN dbo.CustBetSetting3rd_Member csm WITH(NOLOCK) ON csm.custid = cs.custid
		WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType AND csm.SportType = @tSportType AND csm.BetType = @tBetType
				AND c.roleid = 1 AND Enabled = 1
				AND (
					cs.minBet <> csm.minBet
					OR cs.MaxBet <> csm.MaxBet
					)
	
		RAISERROR('Done: Get the affected member list for bet setting', 0, 1)  WITH NOWAIT

		--------------------------------------Bet Setting-------------------------------------------------		
		--Agent Level
		UPDATE csa
		SET csa.minBet = cs.minbet,       
			csa.MaxBet = cs.MaxBet
		FROM dbo.CustSetting3rd csa WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #SMAList_BetSetting cs WITH(NOLOCK) ON csa.CustID = cs.custid
		WHERE csa.SportType = @fSportType AND csa.BetType = @fBetType

		RAISERROR('Done: Update the affected SMA list for bet setting', 0, 1)  WITH NOWAIT

		--Member Level
		UPDATE csm
		SET csm.minBet = cs.minbet,       
			csm.MaxBet = cs.MaxBet
		FROM dbo.CustSetting3rd csm WITH(ROWLOCK,UPDLOCK)
			INNER JOIN #MemberList_BetSetting cs WITH(NOLOCK) ON csm.CustID = cs.custid
		WHERE csm.SportType = @fSportType AND csm.BetType = @fBetType
		
		RAISERROR('Done: Update the affected member list for bet setting', 0, 1)  WITH NOWAIT

		RAISERROR(@msgDone, 0, 1, @tSportType, @tBetType)  WITH NOWAIT

		DROP TABLE #SMAList_BetSetting
		DROP TABLE #MemberList_BetSetting
	END
END		
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT DBCUST SERVERS -----
--------------------------------------------------------------------------------------
EXEC dbo.Acc_DynamicCustSetting3rd_09 

