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

	CREATE TABLE #OfferedSite (site VARCHAR(10))
	INSERT INTO #OfferedSite (site)
	VALUES  ('755555'), ('Indo'), ('KORIBC'), ('733333'), ('222223'), ('222225'), ('222227')
	          
	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT
	)
	
	CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
	CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
	CREATE TABLE #DirectMember (CustID INT PRIMARY KEY,recommend INT,mrecommend INT,roleid INT)			
	--- get direct master
	INSERT INTO #DirectMaster (CustID,roleid)
	SELECT ci.custid, ci.roleid
	FROM Customer ci with(nolock)
	INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
	WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
		AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
		AND ci.roleid=3 AND ci.srecommend = @srecommend 
		AND ci.custid <= @maxcustid 
		AND c.Enabled=1
		
	--- get direct agent
	INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
	SELECT ci.custid, ci.mrecommend,ci.roleid
	FROM Customer ci WITH(NOLOCK)
	INNER JOIN custInfo c WITH(NOLOCK) ON ci.custid=c.custid
	WHERE  EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ci.site)
		AND  EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
		and ci.roleid = 2 AND ci.srecommend = @srecommend 
		AND ci.custid <= @maxcustid
		AND c.Enabled=1

	INSERT INTO #DirectMember(CustID,recommend,mrecommend,roleid)
	SELECT c.custid, c.recommend,c.mrecommend,c.roleid
	FROM Customer c WITH(NOLOCK)
	INNER JOIN Customer ca (nolock) on c.recommend=ca.custid 
	INNER JOIN custInfo ci WITH(NOLOCK) ON ci.custid=c.custid
	WHERE EXISTS (SELECT 1 FROM #OfferedSite WHERE site = ca.site)
		AND EXISTS (SELECT custid from dbo.CustDirectAccount WITH(NOLOCK) WHERE CustID = ci.custid)
		AND c.roleid=1 AND c.srecommend = @srecommend 		
		AND c.custid <= @maxcustid 
		AND ci.Enabled=1

	----------- For SMA  -----------
	INSERT INTO #SMATemp (CustID,RoleID)
	SELECT @srecommend, 4 -- Super
	UNION ALL
	-----------------------Master--------------------------------------
	SELECT d.CustID, 3 -- Direct Master 
	FROM #DirectMaster d	
	UNION 
	SELECT DISTINCT d.mrecommend, 3 -- Master of direct agent
	FROM #DirectAgent d
	UNION 
	SELECT DISTINCT d.mrecommend, 3 -- Master of direct member
	FROM #DirectMember D 	
	UNION 
	-----------------------Agent--------------------------------------
	SELECT ci.CustID,2 -- Agent of direct master
	FROM custInfo ci WITH (NOLOCK)
		INNER JOIN #DirectMaster D ON ci.mrecommend = d.CustID 
	WHERE ci.roleid = 2 AND ci.Enabled=1 AND ci.custid <= @maxcustid 
	UNION
	SELECT DISTINCT d.recommend, 2 -- agent of direct member
	FROM #DirectMember D 	
	UNION 
	SELECT d.CustID, 2 -- Direct Agent
	FROM #DirectAgent D
	 	
	---------- For members ---------
	INSERT INTO #MemberTemp (CustID)
	SELECT  ci.custid -- member of direct master
	FROM Custinfo ci WITH (NOLOCK)
		INNER JOIN #DirectMaster m ON ci.mrecommend = m.CustID
	WHERE ci.roleid = 1	AND ci.custid <= @maxcustid AND ci.Enabled = 1 			
	UNION ALL -- member of direct agent
	SELECT  ci.custid
	FROM Custinfo ci WITH (NOLOCK)
		INNER JOIN #DirectAgent a ON ci.recommend = a.CustID
	WHERE ci.roleid = 1 AND ci.custid <= @maxcustid AND ci.Enabled = 1 			
	-- Direct member		
	UNION ALL
	SELECT ci.custid
	FROM #DirectMember ci

	DECLARE @MaxPT TINYINT, @Currency INT--, @MaxComm DECIMAL(9,8)
	SELECT TOP 1 @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 1
	--SELECT TOP 1 @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = @ProductID AND SettingType = 3
	SELECT @Currency = currency FROM customer WITH (NOLOCK) WHERE custid = @srecommend
	
	--------------------------------------PT Setting-------------------------------------------------	
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
		cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
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
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
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
		cs.custid, dest.tsporttype, dest.tbettype, dest.IsLive
		,cs.spositiontaking  *100
		,cs.mpositiontaking  *100
		,cs.apositiontaking  *100
		,cs.isautompositiontaking
		,cs.autompositiontaking *100
		,cs.isautopositiontaking 
		,cs.autopositiontaking  *100
	FROM dbo.custSettingGame cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
	--DECLARE @apos SMALLMONEY,
	--		@mpos SMALLMONEY
	
	--UPDATE cs
	--SET cs.MinPT = @MaxPT
	--FROM dbo.CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE MinPT > @MaxPT		
	
	--UPDATE cs
	--SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	--	cs.AgentPT = @apos,
	--	@mpos = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END,
	--	cs.MasterPT = @mpos,
	--	cs.SuperPT = CASE WHEN @apos + @mpos + cs.SuperPT > @MaxPT THEN @MaxPT - @mpos -@apos ELSE cs.SuperPT END
	--FROM  CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > @MaxPT
		
	--UPDATE cs
	--SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
	--	cs.AgentPT = @apos,
	--	cs.MasterPT = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END		
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.MasterPT + cs.AgentPT > @MaxPT	AND roleid = 2
	
	--UPDATE cs
	--SET @mpos = CASE WHEN cs.MasterPT > @MaxPT THEN @MaxPT ELSE cs.MasterPT END,
	--	cs.MasterPT = @mpos,
	--	cs.SuperPT = CASE WHEN cs.SuperPT + @mpos > @MaxPT THEN @MaxPT - @mpos ELSE cs.SuperPT END 		
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE cs.MasterPT + cs.SuperPT > @MaxPT	AND roleid = 3
		
	--UPDATE cs
	--SET cs.SuperPT = CASE WHEN cs.SuperPT <> @MaxPT THEN @MaxPT ELSE cs.SuperPT END, 		
	--	cs.MasterPT = CASE WHEN cs.MasterPT <> @MaxPT THEN @MaxPT ELSE cs.MasterPT END, 	
	--	cs.AgentPT = CASE WHEN cs.AgentPT <> @MaxPT THEN @MaxPT ELSE cs.AgentPT END 	
	--FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
	--	INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
	--	INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	--WHERE ci.custid = @srecommend		
	--	AND (cs.SuperPT <> @MaxPT	
	--		OR cs.MasterPT <> @MaxPT
	--		OR cs.AgentPT <> @MaxPT)	

	--------------------------------------Bet Setting-------------------------------------------------		
	--Agent Level
	INSERT INTO dbo.CustBetSetting3rd_Agent(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType			
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType

	--Member Level
	INSERT INTO dbo.CustBetSetting3rd_Member(CustID, SportType, BetType, MinBet, MaxBet, MaxPerMatch)
	SELECT ci.custid, dest.tsporttype, dest.tbettype, cs.minbet, cs.maxbet, cs.MaxPerGameType					
	FROM dbo.CustGameType cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 2 AND cs.GameTypeID = dest.fBetType
	
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

----Get list dummy super
--SELECT DISTINCT srecommend
--FROM CustDirectAccount da WITH (NOLOCK)
--	INNER JOIN customer ci WITH(NOLOCK) ON da.CustID = ci.custid
--WHERE ci.site IN ('755555', 'Indo', 'KORIBC', '733333', '222223', '222225', '222227')
--	AND ci.roleid IN (2, 3)
--UNION 
--SELECT DISTINCT ci.srecommend
--FROM CustDirectAccount da WITH (NOLOCK)
--	INNER JOIN customer ci WITH(NOLOCK) ON da.CustID = ci.custid
--	INNER JOIN customer ca WITH(NOLOCK) ON ci.recommend = ca.custid
--WHERE ca.site IN ('755555', 'Indo', 'KORIBC', '733333', '222223', '222225', '222227')
--	AND ci.roleid IN (1)
--ORDER BY srecommend

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid IN (2,3,4,5,12,13,15) -- dummy account	

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
			
			
	waitfor delay '00:00:0.280'
END
GO

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid)
SELECT ci.custid
FROM dbo.Customer ci WITH(NOLOCK)
WHERE ci.custid IN (2,3,4,5,12,13,15) -- dummy account	

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
						
	waitfor delay '00:00:0.280'
END