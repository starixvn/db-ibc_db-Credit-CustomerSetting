/*
	Created: Elodie
	Task: Copy PT & Bet Setting & WinLossLimit for Lottery
	DB: DBCUST/CustDB
	Date: 20170801
*/ 

ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@srecommend INT	
	,@maxcustid INT
	,@target VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	
	IF (@target = 'REPLICATED' AND @@SERVERNAME = 'DBCUST') RETURN	-- run at all replicated servers
	IF (@target = 'DBCUST' AND @@SERVERNAME <> 'DBCUST') RETURN -- run at dbtrans only
	
	IF dbo.f_CheckRepTable('CustInfo') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustPTGroupSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustBetSetting3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN	

	DECLARE @fSportType SMALLINT, @fBetType SMALLINT

	DECLARE @ProductID TINYINT = 28
	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT, IsFinished BIT)
	INSERT INTO #DestinationSportBetType (fSportType, fBetType, tSportType, tBetType, IsLive, SettingType, IsFinished)
	SELECT	202, 1501, SportType, BetType, 0, SettingType, 0
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (1,6)

	--get Bet Setting of Keno - Max Keno (bet type id  = 1515)  to apply for all game types of Lottery (Max5D, Max3D, Max11x5, MaxDice)
	--Use GameTypeID = 15 in CustGameType table
	INSERT INTO #DestinationSportBetType (fSportType, fBetType, tSportType, tBetType, IsLive, SettingType, IsFinished)
	SELECT	202, 15, SportType, BetType, 0, SettingType, 0 
	FROM dbo.ProductSettingDetail WITH (NOLOCK)
	WHERE ProductID = @ProductID AND SettingType IN (2)

	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT
	)
	
	INSERT INTO #MemberTemp (CustID)
	SELECT custid
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid = 1  AND Enabled = 1 AND custid <= @maxcustid
	
	
	INSERT INTO #SMATemp (CustID, roleid)
	SELECT custid, roleid
	FROM Custinfo WITH (NOLOCK)
	WHERE srecommend = @srecommend AND roleid IN (2,3,4) AND Enabled = 1 AND custid <= @maxcustid 

	DECLARE @MaxPT TINYINT, @Currency INT--, @MaxComm DECIMAL(9,8)
	SELECT TOP 1 @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 1
	--SELECT TOP 1 @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 3
	SELECT @Currency = currency FROM customer WITH (NOLOCK) WHERE custid = @srecommend
	
	--------------------------------------PT Setting-------------------------------------------------	
	SELECT TOP (1) @fBetType = fBetType, @fSportType = fSportType 
	FROM #DestinationSportBetType		
	WHERE SettingType = 1

	--AGENT LEVEL
	INSERT INTO dbo.CustPTSetting3rd_Agent
		(	[CustID]
			,[SportType]
			,[BetType]
			,[IsLive]
			,[SuperPT]
			,[MasterPT]
			,[AgentPT]
			,[IsAutoMasterPT]
			,[AutoMasterPT]
			,[IsAutoSuperPT]
			,[AutoSuperPT]
			,[MinPT]
			,[MaxPT])
	SELECT 
		cs.custid, dest.tSportType, dest.tBetType, dest.IsLive
		,cs.spositiontaking  *100
		,cs.mpositiontaking  *100
		,cs.apositiontaking  *100
		,cs.isautompositiontaking
		,cs.autompositiontaking *100
		,cs.isautopositiontaking 
		,cs.autopositiontaking  *100
		,co.minpositiontaking  *100
		,@MaxPT
	FROM dbo.custSettingGame cs WITH(NOLOCK) 
		INNER JOIN dbo.CustOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		CROSS APPLY #DestinationSportBetType dest
	WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType
		AND dest.SettingType = 1
	
	--MEMBER LEVEL
	INSERT INTO dbo.CustPTSetting3rd_Member
		(	[custid]
			,	[sporttype]
			,	[bettype]
			,	[islive]
			,	[superPT]
			,	[masterPT]
			,	[agentPT]
			,	[IsAutoMasterPT]
			,	[AutoMasterPT]
			,	[IsAutoSuperPT]
			,	[AutoSuperPT])
	SELECT 
		cs.custid, dest.tSportType, dest.tBetType, dest.IsLive
		,cs.spositiontaking  *100
		,cs.mpositiontaking  *100
		,cs.apositiontaking  *100
		,cs.isautompositiontaking
		,cs.autompositiontaking *100
		,cs.isautopositiontaking 
		,cs.autopositiontaking  *100
	FROM dbo.custSettingGame cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		CROSS APPLY #DestinationSportBetType dest
	WHERE cs.bettype = @fBetType AND cs.sporttype = @fSportType
		AND dest.SettingType = 1

	--------------------------------------Bet Setting-------------------------------------------------		
	SELECT TOP (1) @fBetType = fBetType, @fSportType = fSportType 
	FROM #DestinationSportBetType		
	WHERE SettingType = 2

	--Agent Level
	INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType			
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		CROSS APPLY #DestinationSportBetType dest
	WHERE cs.GameTypeID = @fBetType
		AND dest.SettingType = 2

	--Member Level
	INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType					
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		CROSS APPLY #DestinationSportBetType dest
	WHERE cs.GameTypeID = @fBetType
		AND dest.SettingType = 2
	
	--------------------------------------Win Loss Limit-------------------------------------------------		
	--Agent Level
	INSERT INTO dbo.CustWinLossLimit_Agent (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, 0, cs.DefaultLossLimit, 1
	FROM #SMATemp ci WITH(NOLOCK) 
		CROSS APPLY #DestinationSportBetType dest WITH(NOLOCK) 
		CROSS APPLY dbo.LossLimit_GlobalSetting cs WITH(NOLOCK)
	WHERE dest.SettingType = 6 AND cs.ExchangeId = @Currency AND cs.ProductId = @ProductID

	--Member Level
	INSERT INTO dbo.CustWinLossLimit_Member (CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, 0, cs.DefaultLossLimit, 1
	FROM #MemberTemp ci WITH(NOLOCK) 
		CROSS APPLY #DestinationSportBetType dest WITH(NOLOCK) 
		CROSS APPLY dbo.LossLimit_GlobalSetting cs WITH(NOLOCK)
	WHERE dest.SettingType = 6 AND cs.ExchangeId = @Currency AND cs.ProductId = @ProductID

	DROP TABLE #SMATemp
	DROP TABLE #MemberTemp
	DROP TABLE #DestinationSportBetType			
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
	AND ci.username NOT LIKE '3rdSuper%'
	AND cs.isinternal = 0
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND s.islicensee = 0
	AND ci.custid <= @max_custid
	AND ci.site IN ('755555', 'Indo', 'KORIBC', '733333', '222223', '222225', '222227')

-- For deployer info
DECLARE @super_cnt INT, @index INT = 0
DECLARE @msg NVARCHAR(200) = 'Currently at order %d, SuperID: %d.'
DECLARE @msg_total NVARCHAR(200) = 'Total of supers: %d.'

SET @super_cnt = (SELECT COUNT(*) FROM #supers )
RAISERROR (@msg_total, 0, 1, @super_cnt) WITH NOWAIT

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
	
	SET @index = @index + 1
	RAISERROR (@msg, 0, 1, @index, @srecommend) WITH NOWAIT

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.200'
END
GO

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
PRINT N'Step 2: Start on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.';  

CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM customer ci WITH (NOLOCK) 
	INNER JOIN site s WITH (NOLOCK) ON ci.site = s.site
	LEFT JOIN custsuper cs WITH (NOLOCK) ON ci.custid = cs.custid
WHERE ci.roleid = 4  
	AND ci.username NOT LIKE '3rdSuper%'
	AND cs.isinternal = 0
	AND ci.custid NOT IN (SELECT custid FROM Dep_CustSuper WITH(NOLOCK))
	AND s.islicensee = 0
	AND ci.custid <= @max_custid
	AND ci.site IN ('755555', 'Indo', 'KORIBC', '733333', '222223', '222225', '222227')

-- For deployer info
DECLARE @super_cnt INT, @index INT = 0
DECLARE @msg NVARCHAR(200) = 'Currently at order %d, SuperID: %d.'
DECLARE @msg_total NVARCHAR(200) = 'Total of supers: %d.'

SET @super_cnt = (SELECT COUNT(*) FROM #supers )
RAISERROR (@msg_total, 0, 1, @super_cnt) WITH NOWAIT

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	SET @index = @index + 1
	RAISERROR (@msg, 0, 1, @index, @srecommend) WITH NOWAIT

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.200'
END

PRINT N'Step 2: End on ' + CAST(GETDATE() AS NVARCHAR(30)) + N'.'; 