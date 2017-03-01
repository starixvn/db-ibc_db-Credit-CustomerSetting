/*
	Created: Helen
	Task: Copy PT & Comm & WinLossLimit for All Bet from Live Casino
	DB: DBCUST/CustDB
	Date: 20160226
*/ 

ALTER PROCEDURE [dbo].[Acc_DynamicCustSetting3rd_09]
	@srecommend INT	
	,@ExchangeID INT	
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
	IF dbo.f_CheckRepTable('CustDiscount3rd_Member') = 0 RETURN
	IF dbo.f_CheckRepTable('CustDiscount3rd_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Agent') = 0 RETURN
	IF dbo.f_CheckRepTable('CustWinLossLimit_Member') = 0 RETURN	
	
	CREATE TABLE #DestinationSportBetType(fSportType SMALLINT, fBetType SMALLINT,tSportType SMALLINT, tBetType SMALLINT, IsLive BIT,  SettingType INT)
	INSERT INTO #DestinationSportBetType
	VALUES
	(162, 1101, 211	, 2401, 0, 1), --PT
	(162, 1101, 211	, 2401, 0, 3), --Comm
	(162, 1101, 211	, 2401, 0, 6) --WinLossLimit

	CREATE TABLE #MemberTemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		SyncLiveCasino BIT,
		MaxWinLiveCasino SMALLMONEY,
		isAutoResetLiveCasino BIT
	)

	CREATE TABLE #SMATemp
	(
		CustID INT PRIMARY KEY CLUSTERED,
		roleid TINYINT,
		SyncLiveCasino BIT,
		MaxWinLiveCasino SMALLMONEY,
		isAutoResetLiveCasino BIT
	)
	CREATE TABLE #DirectMaster (CustID INT PRIMARY KEY,roleid INT)
	CREATE TABLE #DirectAgent (CustID INT PRIMARY KEY,mrecommend INT,roleid INT)
	
	BEGIN 
		
		--- get direct master
		INSERT INTO #DirectMaster (CustID,roleid)
		SELECT custid, roleid
		FROM Customer with(nolock)
		WHERE SITE in ('733333','222223')

			and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and srecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and roleid=3 AND srecommend = @srecommend AND custid <= @maxcustid 
			
		--- get direct agent
		INSERT INTO #DirectAgent (CustID,mrecommend,roleid)
		SELECT custid, mrecommend,roleid
		FROM Customer WITH(NOLOCK)
		WHERE SITE in ('733333','222223')

			and custid NOT IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and mrecommend IN (SELECT custid from Acc_CustDirect WITH(NOLOCK))
			and roleid=2 AND srecommend = @srecommend AND custid <= @maxcustid

		----------- For SMA  -----------
		INSERT INTO #SMATemp (CustID,roleid,SyncLiveCasino)
		SELECT CustID,roleid,SyncLiveCasino
		FROM custInfo CI WITH (NOLOCK)
		WHERE CI.custid = @srecommend -- SUPER
		UNION ALL

		SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Direct Master 
		FROM custInfo CI WITH (NOLOCK)
			INNER JOIN #DirectMaster D ON CI.custid = D.CustID 
		UNION ALL
		SELECT DISTINCT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Master of direct agent
		FROM custInfo CI WITH (NOLOCK)
			INNER JOIN #DirectAgent D ON CI.custid = D.mrecommend 
			
		UNION ALL

		SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Agent of direct master
		FROM custInfo CI WITH (NOLOCK)
			INNER JOIN #DirectMaster D ON CI.mrecommend = D.CustID 
		WHERE CI.roleid = 2
		UNION ALL
		SELECT CI.CustID,CI.roleid,CI.SyncLiveCasino -- Direct Agent
		FROM custInfo CI WITH (NOLOCK)
			INNER JOIN #DirectAgent D ON CI.custid = D.CustID 
		---------- For members ---------
		INSERT INTO #MemberTemp (CustID, SyncLiveCasino)
		SELECT CI.custid, SyncLiveCasino
		FROM Custinfo CI WITH (NOLOCK)
			INNER JOIN #DirectMaster M ON CI.mrecommend = M.CustID
		WHERE CI.roleid = 1	

		UNION ALL
		SELECT CI.custid, SyncLiveCasino
		FROM Custinfo CI WITH (NOLOCK)
			INNER JOIN #DirectAgent M ON CI.recommend = M.CustID
		WHERE CI.roleid = 1

		
		---- REMOVE SMA OR member if existing Allbet Setting
		DELETE ps
		FROM   CustWinLossLimit_Agent ps
			INNER JOIN #SMATemp M WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211
			
		DELETE ps
		FROM CustWinLossLimit_Member ps 
			INNER JOIN #MemberTemp M  WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211
			
		DELETE ps
		FROM   CustPTSetting3rd_Agent ps
			INNER JOIN #SMATemp M WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211
			
		DELETE ps
		FROM CustPTSetting3rd_Member ps 
			INNER JOIN #MemberTemp M  WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211
		
		DELETE ps
		FROM   CustDiscount3rd_Agent ps
			INNER JOIN #SMATemp M WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211
			
		DELETE ps
		FROM CustDiscount3rd_Member ps 
			INNER JOIN #MemberTemp M  WITH (NOLOCK) ON M.CustID = PS.CustID AND PS.SportType = 211	
				
	END		
	
	DECLARE @MaxPT TINYINT, @MaxComm DECIMAL(9,8)
	SELECT @MaxPT = MaxPT FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 1
	SELECT @MaxComm = MaxDiscount FROM dbo.ProductSettingDetail WITH (NOLOCK) WHERE ProductID = 21 AND SettingType = 3
	
	DECLARE @DefaultLossLimit MONEY
	
	SELECT @DefaultLossLimit = ISNULL(DefaultLossLimit,0)
	FROM LossLimit_GlobalSetting WITH (NOLOCK)
	WHERE ProductId = 21 AND ExchangeId = @ExchangeID
	--------------------------------------WinLossLimit-------------------------------------------------
	--SuperLevel
	INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT custid, dest.tSportType, dest.tBetType	
		, CASE WHEN ci.SyncLiveCasino = 0 THEN 0 ELSE MaxWinLiveCasino END AS MaxWinLimit
		, @DefaultLossLimit AS MaxLossLimit 
		,CASE WHEN ci.SyncLiveCasino = 0 THEN 1 ELSE isAutoResetLiveCasino END AS IsAutoReset
	FROM #SMATemp ci WITH(NOLOCK)	
		CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
	WHERE ci.custid = @srecommend AND dest.SettingType = 6 
									
	--Master Level
	INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT ci.custid, dest.tSportType, dest.tBetType	
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
				WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
				ELSE 0 END AS MaxWinLimit
		
		,@DefaultLossLimit AS MaxLossLimit 
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
				WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
				ELSE 1 END AS IsAutoReset
	FROM dbo.custInfo ci WITH(NOLOCK) -- master	
		INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid -- srecommend
		CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
	WHERE ci.srecommend = @srecommend AND ci.roleid = 3 AND dest.SettingType = 6 

	--Agent Level
	INSERT INTO CustWinLossLimit_Agent(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT ci.custid, dest.tSportType, dest.tBetType	
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
				WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
				WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
				ELSE 0 END AS MaxWinLimit
		,@DefaultLossLimit AS MaxLossLimit 
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
				WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
				WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
				ELSE 1 END AS IsAutoReset
	FROM dbo.custInfo ci WITH(NOLOCK)
		INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
		INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
		CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
	WHERE ci.srecommend = @srecommend AND ci.roleid = 2 AND dest.SettingType = 6
	
	--Member Level
	INSERT INTO CustWinLossLimit_Member(CustId, SportType, BetType, MaxWinLimit, MaxLossLimit, IsAutoReset)
	SELECT ci.custid, dest.tSportType, dest.tBetType	
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.MaxWinLiveCasino
				WHEN ai.SyncLiveCasino = 1 THEN ai.MaxWinLiveCasino 
				WHEN mi.SyncLiveCasino = 1 THEN mi.MaxWinLiveCasino 
				WHEN si.SyncLiveCasino = 1 THEN si.MaxWinLiveCasino 
				ELSE 0 END AS MaxWinLimit
		,@DefaultLossLimit AS MaxLossLimit 
		,CASE	WHEN ci.SyncLiveCasino  = 1 THEN ci.isAutoResetLiveCasino
				WHEN ai.SyncLiveCasino = 1 THEN ai.isAutoResetLiveCasino 
				WHEN mi.SyncLiveCasino = 1 THEN mi.isAutoResetLiveCasino 
				WHEN si.SyncLiveCasino = 1 THEN si.isAutoResetLiveCasino 
				ELSE 1 END AS IsAutoReset
	FROM dbo.custInfo ci WITH(NOLOCK)
		INNER JOIN #SMATemp ai WITH (NOLOCK) ON ci.recommend = ai.custid
		INNER JOIN #SMATemp mi WITH (NOLOCK) ON ci.mrecommend = mi.custid	
		INNER JOIN #SMATemp si WITH (NOLOCK) ON ci.srecommend = si.custid
		CROSS JOIN #DestinationSportBetType dest WITH(NOLOCK) 
	WHERE ci.srecommend = @srecommend AND ci.roleid = 1 AND dest.SettingType = 6 
	
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
		,93
	FROM dbo.CustSettingGame cs WITH(NOLOCK) 
		INNER JOIN dbo.custOverrideGame co WITH(NOLOCK) ON cs.custid = co.custid and cs.sporttype = co.sporttype and cs.bettype = co.bettype
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
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
	
	DECLARE @apos SMALLMONEY,
			@mpos SMALLMONEY
	
	UPDATE cs
	SET cs.MinPT = @MaxPT
	FROM dbo.CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE MinPT > @MaxPT		
	
	UPDATE cs
	SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
		cs.AgentPT = @apos,
		@mpos = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END,
		cs.MasterPT = @mpos,
		cs.SuperPT = CASE WHEN @apos + @mpos + cs.SuperPT > @MaxPT THEN @MaxPT - @mpos -@apos ELSE cs.SuperPT END
	FROM  CustPTSetting3rd_Member cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE cs.SuperPT + cs.MasterPT + cs.AgentPT > @MaxPT
		
	UPDATE cs
	SET @apos = CASE WHEN cs.AgentPT > @MaxPT THEN @MaxPT ELSE cs.AgentPT END,
		cs.AgentPT = @apos,
		cs.MasterPT = CASE WHEN @apos + cs.MasterPT > @MaxPT THEN @MaxPT- @apos ELSE cs.MasterPT END		
	FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE cs.MasterPT + cs.AgentPT > @MaxPT	AND roleid = 2
	
	UPDATE cs
	SET @mpos = CASE WHEN cs.MasterPT > @MaxPT THEN @MaxPT ELSE cs.MasterPT END,
		cs.MasterPT = @mpos,
		cs.SuperPT = CASE WHEN cs.SuperPT + @mpos > @MaxPT THEN @MaxPT - @mpos ELSE cs.SuperPT END 		
	FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE cs.MasterPT + cs.SuperPT > @MaxPT	AND roleid = 3
		
	UPDATE cs
	SET cs.SuperPT = CASE WHEN cs.SuperPT > @MaxPT THEN @MaxPT ELSE cs.SuperPT END 		
	FROM  CustPTSetting3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 1 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
	WHERE ci.custid = @srecommend		
		AND cs.SuperPT > @MaxPT	
	
	
	--Update m4 = s4, a4 = s4 
	UPDATE CustPTSetting3rd_Agent
		SET  [MasterPT] = [SuperPT],
			[AgentPT] = [SuperPT]
	WHERE SportType = 211 AND BetType = 2401
			AND Custid IN (SELECT CustID FROM #SMATemp WHERE roleid = 4)

	--------------------------------------Commission Setting-------------------------------------------------		
	--Agent Level
	INSERT INTO dbo.CustDiscount3rd_Agent(CustID, SportType, BetType, Discount)
	SELECT cs.custid, dest.tsporttype, dest.tbettype, 
			CASE	WHEN roleid = 4 THEN cs.sdiscount
					WHEN roleid = 3 THEN cs.adiscount
					WHEN roleid = 2 THEN cs.discount END
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN #SMATemp ci WITH(NOLOCK) ON ci.custid = cs.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType
		 
	--Member Level
	INSERT INTO dbo.CustDiscount3rd_Member(CustID, SportType, BetType, PlayerDiscount, AgentDiscount, MasterDiscount, SuperDiscount)
	SELECT cs.custid, dest.tsporttype, dest.tbettype, cs.PlayerDiscount, cs.discount, cs.adiscount, cs.sdiscount
	FROM dbo.CustSettingGame cs WITH(NOLOCK)
		INNER JOIN #MemberTemp ci WITH(NOLOCK) ON cs.CustID = ci.custid
		INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.fBetType AND cs.sporttype = dest.fSportType

	--adjust commission Super = [0; 0.007]	
	--correct for super level
	IF EXISTS(	SELECT 1
				FROM dbo.CustDiscount3rd_Agent cs WITH(NOLOCK)
					INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
				WHERE cs.CustID = @srecommend AND cs.Discount > @MaxComm)
	BEGIN
		UPDATE cs
		SET cs.Discount = @MaxComm
		FROM  CustDiscount3rd_Agent cs WITH(UPDLOCK,ROWLOCK) 
			INNER JOIN #SMATemp ci ON cs.CustID = ci.CustID
			INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType
		WHERE cs.Discount > @MaxComm
		
		UPDATE cs
		SET cs.SuperDiscount = CASE WHEN cs.SuperDiscount > @MaxComm THEN @MaxComm ELSE cs.SuperDiscount END,
			cs.MasterDiscount = CASE WHEN cs.MasterDiscount > cs.SuperDiscount THEN cs.SuperDiscount ELSE cs.MasterDiscount END,
			cs.AgentDiscount = CASE WHEN cs.AgentDiscount > cs.MasterDiscount THEN cs.MasterDiscount ELSE cs.AgentDiscount END,
			cs.PlayerDiscount = CASE WHEN cs.PlayerDiscount > cs.AgentDiscount THEN cs.AgentDiscount ELSE cs.PlayerDiscount END
		FROM dbo.CustDiscount3rd_Member cs WITH(UPDLOCK, ROWLOCK)
			INNER JOIN #MemberTemp ci ON cs.CustID = ci.CustID
			INNER JOIN #DestinationSportBetType dest WITH(NOLOCK) ON dest.SettingType = 3 AND cs.bettype = dest.tBetType AND cs.sporttype = dest.tSportType		
		WHERE cs.SuperDiscount > @MaxComm 
			OR cs.MasterDiscount > cs.SuperDiscount 
			OR cs.AgentDiscount > cs.MasterDiscount 
			OR cs.PlayerDiscount > cs.AgentDiscount
		  
	END		
	
	DROP TABLE #SMATemp
	DROP TABLE #MemberTemp
	DROP TABLE #DestinationSportBetType		
END
GO
-- END STEP 1: DEPLOY THIS SP @DBCUST.CustDB --------
------------------------------------------------------	

-- BEGIN STEP 2: RUN THIS SCRIPT AT ALL REPLICATED SERVERS (06/DBTP) -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,exchangeid INT,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT, @exchangeid INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid,exchangeid)
SELECT ci.custid,ci.currency
FROM dbo.Customer ci WITH(NOLOCK)
WHERE custid in (2,13)
		

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
		,@exchangeid = exchangeid 
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK
			
	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend , @Exchangeid = @exchangeid
			,@maxcustid = @max_custid
			,@target = 'REPLICATED'
			
			
	waitfor delay '00:00:0.280'
END

-- BEGIN STEP 3: RUN THIS SCRIPT AT DBCUST -----
--------------------------------------------------------------------------------------
CREATE TABLE #supers (custid int,exchangeid INT,isfinished bit default(0))

DECLARE @max_custid INT, @srecommend INT, @exchangeid INT

SELECT @max_custid = xxx

INSERT INTO #supers(custid,exchangeid)
SELECT ci.custid,ci.currency
FROM dbo.Customer ci WITH(NOLOCK)
WHERE custid in (2,13)

WHILE (1 = 1)
BEGIN
	UPDATE TOP (1) #Supers
	SET isfinished = 1
		,@srecommend = custid	
		,@exchangeid = exchangeid 
	WHERE isfinished = 0
	
	IF @@ROWCOUNT = 0 BREAK

	EXEC dbo.Acc_DynamicCustSetting3rd_09 @srecommend = @srecommend, @Exchangeid = @exchangeid
			,@maxcustid = @max_custid
			,@target = 'DBCUST'
						
	waitfor delay '00:00:0.280'
END